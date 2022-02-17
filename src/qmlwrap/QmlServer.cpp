// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>
#include <network/Server.h> // https://stackoverflow.com/a/4964508

// I Kept the mutex'es here to easily see them when needed
// Instead of placing them on QmlSystem.h

std::mutex preRequest;
std::mutex posRequest;
enum RequestSignTypes {eth_sign, personal_sign};


// TODO: Fix the mess of mutexes here and on Server.cpp
void QmlSystem::handleServer(std::string inputStr, std::shared_ptr<session> session_) {
  // Run answer in another thread to allow the Server to take more inputs

  json request = json::parse(inputStr);
  json response;
  // Some requests does not require permission from the user.
  // For security reasons, we lock out the possibility for the website
  // To get the user address until he approves it
  // Besides that, basic requests such as "eth_chainId"
  // DOES NOT contain "__frameOrigin" to define which website it came from.
  bool requirePermission = false;
  bool requestTransaction = false; // Reason inside "eth_sendTransaction" if Initialize response with common information.
  bool requestSign = false;
  RequestSignTypes requestSignType;
  response["jsonrpc"] = "2.0";
  response["id"] = request["id"];
  if (request["method"] == "eth_chainId") {
    response["result"] = "0xa86a";
    requirePermission = false;
  } else if (request["method"] == "net_version") {
    response["result"] = "43114";
    requirePermission = false;
  } else if(request["method"] == "eth_requestAccounts" || request["method"] == "eth_accounts") {
    response["result"] = json::array();
    response["result"].push_back(this->getCurrentAccount().toStdString());
  requirePermission = true;
  } else if(request["method"] == "eth_subscribe") {
    response["error"]["code"] = -32601;
    response["error"]["message"] = "Method not found";
    requirePermission = false;
  } else if (request["method"] == "eth_sendTransaction") {
    // We cannot request the transaction here, we need to wait until it checks
    // Against websites permissions.
    // It is a mess, I do agree with you, but it is effective
    requestTransaction = true;
    requirePermission = true;
  } else if (request["method"] == "eth_sign") {
    // Same as above.
    requirePermission = true;
    requestSign = true;
    requestSignType = eth_sign;
  } else if (request["method"] == "personal sign" || request["method"] == "personal_sign") {
    requirePermission = true;
    requestSign = true;
    requestSignType = personal_sign;
  } else if (request["method"] == "wallet_addEthereumChain") {
    // The method MUST return null if the request was successful, and an error otherwise.
    // See https://eips.ethereum.org/EIPS/eip-3085
    // TODO: When implementing multichain, ask the user to accept a new network from the website
    if (request["params"][0]["chainId"] =! "0xa86a") {
      response["error"]["code"] = -32601;
      response["error"]["message"] = "Method not found";
    }
  } else { 
    // Route any future request to the avalanche PUBLIC API.
    if (!session_->is_running) {
      return;
    }
    std::string response_str = API::httpGetRequest(request.dump(), true);
    try {
      response = json::parse(response_str);
    } catch (std::exception &e) {
      Utils::logToDebug(std::string("ERROR PARSING: ") + e.what() + response_str);
      return;
    }
    if (!session_->is_running) {
      return;
    }
    requirePermission = false;
  }
  if (request["method"] != "eth_call" &&
      request["method"] != "eth_chainId" &&
      request["method"] != "eth_estimateGas" &&
      request["method"] != "net_version" &&
      request["method"] != "eth_requestAccounts" &&
      request["method"] != "eth_blockNumber" &&
      request["method"] != "eth_accounts" &&
      request["method"] != "eth_syncing" &&
      request["method"] != "eth_getBalance"
     ) { // eth_call is garbage for us, do not print it
    //std::cout << "Request: " << request.dump(2) << std::endl;
    //std::cout << "Response: " << response.dump(2) << std::endl;
  }
  // This section below is confusing
  // Due to the nature of being asynchronous
  // We need to wait until the user have provided permission
  // to connect with the website
  if (requirePermission == true) {
    this->permissionListMutex.lock();
    bool found = false;
    bool permission = false;
    for (auto websitePermission : permissionList) {
      if (request["__frameOrigin"].get<std::string>() == websitePermission.first) {
        permission = websitePermission.second;
        found = true;
      }
    }
    if (!found) {
      // Ask user to give permission or not.
      //std::cout << "Lock global" << std::endl;
      globalUserInputRequest.lock();
      //std::cout << "Global locked" << std::endl;
      PLuserInputRequest.lock();
      // Tell QML to show and ask for permission for given website
      std::string website = request["__frameOrigin"];
      emit askForPermission(QString::fromStdString(website));
      PLuserInputAnswer.lock();
      PLuserInputAnswer.lock(); // Wait until user completed the input
      // The reason to lock twice, is to give "control" of this thread to
      // The function "addToPermissionList", which will unlock this thread after
      // user input.
      // Check what permission he gave for the website.
      for (auto websitePermission : permissionList) {
        if (request["__frameOrigin"].get<std::string>() == websitePermission.first)
          permission = websitePermission.second;
      }
      PLuserInputAnswer.unlock();
      PLuserInputRequest.unlock();
      //std::cout << "Unlock global" << std::endl;
      globalUserInputRequest.unlock();
      //std::cout << "Global unlocked" << std::endl;
    }
   this->permissionListMutex.unlock();
    if (permission == false) {
      session_->close(); // Close the session if not permitted.
      return; // We should not answer the website
    }
  }
 // Process with a transaction request.
  if (requestTransaction) {
    //std::cout << "Lock global TX" << std::endl;
    globalUserInputRequest.lock();
    //std::cout << "Global locked TX" << std::endl;
    requestTransactionMutex.lock();
    // 4001 	User Rejected Request 	The user rejected the request.
    RTuserInputRequest.lock();
    RTuserInputAnswer.lock();
    std::string data, from, gas, to, website, value;
    // Optional! empty if there is none
    if (request["params"][0].contains("data")) {
      data = request["params"][0]["data"];
    } else {
      data = "";
    }
    from = request["params"][0]["from"];
    // Optional! defaults to 800000
    if (request["params"][0].contains("gas")) {
      gas = request["params"][0]["gas"];
    } else {
      gas = "0xc3500";
    }
    to = request["params"][0]["to"];
    website = request["__frameOrigin"];
    if (request["params"][0].contains("value")) { // Value input is optional! check if exists to set it properly.
      value = request["params"][0]["value"];
    } else {
      value = "0x0";
    }
    emit askForTransaction(
      QString::fromStdString(data),
      QString::fromStdString(from),
      QString::fromStdString(gas),
      QString::fromStdString(to),
      QString::fromStdString(value),
      QString::fromStdString(website)
    );
    RTuserInputAnswer.lock(); // We lock twice for the same reason as above
    if (RTtxid == "") { // Treat "refused" response
      // 4001 	User Rejected Request 	The user rejected the request.
      response["error"]["code"] = 4001;
      response["error"]["message"] = "The user rejected the request";
    } else {
      response["result"] = RTtxid;
    }
    RTuserInputAnswer.unlock();
    RTuserInputRequest.unlock();
    requestTransactionMutex.unlock();
    //std::cout << "Unlock global TX" << std::endl;
    globalUserInputRequest.unlock();
    //std::cout << "Global unlocked TX" << std::endl;
  }
 if (requestSign) {
    //std::cout << "Lock global TX" << std::endl;
    globalUserInputRequest.lock();
    //std::cout << "Global locked TX" << std::endl;
    requestSignMutex.lock();
    // 4001 	User Rejected Request 	The user rejected the request.
    RSuserInputRequest.lock();
    RSuserInputAnswer.lock();
    // Address, Data and Website
    std::string address;
    std::string data;
    // The location where the arguments for signing are located are different
    // for different type of signatures requested. requiring us to manually filter them.
    if (requestSignType == eth_sign) {
        address = request["params"][0];
        data = request["params"][1];
    }
    // Eth Sign provides us with the raw hex to sign
    // Where personal_sign provides us with a hex-encoded string.
    // We need to decode this string, concatenate it with a special string and hash it
    // *then* sign the hash.
    if (requestSignType == personal_sign ) {
      address = request["params"][1];
      data = request["params"][0];
      if (data[0] == '0' || data[1] == 'x') {
        data.erase(0,2);
      }
      data = Utils::hexToString(data); // Convert the hex-encoded string to plain string.
    }
    std::string website = request["__frameOrigin"];
    emit askForSign(
      QString::fromStdString(address),
      QString::fromStdString(data),
      QString::fromStdString(website),
      requestSignType
    );
    RSuserInputAnswer.lock(); // We lock twice for the same reason as above
    if (RSmsg == "") { // Treat "refused" response
      // 4001 	User Rejected Request 	The user rejected the request.
      response["error"]["code"] = 4001;
      response["error"]["message"] = "The user rejected the request";
    } else {
      response["result"] = RSmsg;
    }
    RSuserInputAnswer.unlock();
    RSuserInputRequest.unlock();
    requestSignMutex.unlock();
    //std::cout << "Unlock global TX" << std::endl;
    globalUserInputRequest.unlock();
    //std::cout << "Global unlocked TX" << std::endl;
  }
  //std::cout << "Writing back: " << response.dump() << std::endl;
  posRequest.lock();
  if (session_->is_running) {
    session_->do_write(response.dump());
  }
  posRequest.unlock();
  return;
}

void QmlSystem::setWSServer() {
  this->s.setQmlSystem(this);
  return;
}

// Should run *inside* another thread, to avoid getting stuck at .run()
Q_INVOKABLE void QmlSystem::startWSServer() {
  QtConcurrent::run([=](){
    this->s.start();
  });
}

Q_INVOKABLE void QmlSystem::stopWSServer() {
  this->s.stop();
}

Q_INVOKABLE void QmlSystem::loadPermissionList() {
  // No lock required as there will be only one thread reading/writing to the permission list
  std::string configValue  = getConfigValue(QString::fromStdString("websitePermissions")).toStdString();
  if (!(configValue.find("NotFound") != std::string::npos)) {
    json storedPermissionList = json::parse(configValue);
    // Clear the permission list.
    permissionList.clear();
    if (!storedPermissionList.empty()) {
      for (auto item : storedPermissionList.items()) {
        permissionList.push_back(std::make_pair(item.key(), item.value()));
      }
    }
  }
}

Q_INVOKABLE void QmlSystem::addToPermissionList(QString website, bool allow) {
  // We don't need a mutex lock here,
  // Because handleServer is waiting for it to be unlocked below
  // In order to read the permissionList
  // Meaning, there is only one thread accessing the variabl
  std::string configValue = getConfigValue(QString::fromStdString("websitePermissions")).toStdString();
  json storedPermissionList;
  if (!(configValue.find("NotFound") != std::string::npos)) {
    storedPermissionList = json::parse(configValue);
  }
  storedPermissionList[website.toStdString()] = allow;
  setConfigValue(QString::fromStdString("websitePermissions"), QString::fromStdString(storedPermissionList.dump()));
  loadPermissionList();
  PLuserInputAnswer.unlock(); // Unlock for handleServer self-lock.
}

Q_INVOKABLE void QmlSystem::requestedTransactionStatus(bool approved, QString txid) {
  if (approved) {
    RTtxid = txid.toStdString();
    RTuserInputAnswer.unlock();
  } else {
    RTtxid = "";
    RTuserInputAnswer.unlock();
  }
}

Q_INVOKABLE void QmlSystem::requestedSignStatus(bool hasSigned, QString signature) {
  if (hasSigned) {
    RSmsg = signature.toStdString();
    RSuserInputAnswer.unlock();
  } else {
    RSmsg = "";
    RSuserInputAnswer.unlock();
  }
}

QString QmlSystem::getWebsitePermissionList() {
  json ret;
  for (auto permission : permissionList) {
    ret[permission.first] = permission.second;
  }
  return QString::fromStdString(ret.dump());
}

void QmlSystem::clearWebsitePermissionList() {
  json cleanJson;
  setConfigValue(QString::fromStdString("websitePermissions"), QString::fromStdString(cleanJson.dump()));
  loadPermissionList();
}
