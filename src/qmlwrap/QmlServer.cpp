// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>
#include <network/Server.h> // https://stackoverflow.com/a/4964508


void QmlSystem::handleServer(std::string inputStr, session *session_) {
  // Run answer in another thread to allow the Server to take more inputs
  std::cout << "Request!" << std::endl;
  json request = json::parse(inputStr);
  QtConcurrent::run([=](){
    json response;
    // Some requests does not require permission from the user.
    // For security reasons, we lock out the possibility for the website
    // To get the user address until he approves it
    // Besides that, basic requests such as "eth_chainId"
    // DOES NOT contain "__frameOrigin" to define which website it came from.
    bool requirePermission = false;
    // Initialize response with common information.
    response["jsonrpc"] = "2.0";
    response["id"] = request["id"];
    if (request["method"] == "eth_chainId") {
        response["result"] = "0xa86a";
        requirePermission = false;
    } else if (request["method"] == "net_version") {
        response["result"] = "43114";
        requirePermission = false;
    } else if(request["method"] == "eth_requestAccounts") {
        response["result"] = json::array();
        response["result"].push_back(this->getCurrentAccount().toStdString());   
        requirePermission = true;
    } else if(request["method"] == "eth_subscribe") {
        response["error"]["code"] = -32601;
        response["error"]["message"] = "Method not found";
        requirePermission = false;
    } else {
        // Route any future request to our API.
        response = json::parse(API::httpGetRequest(request.dump()));
        requirePermission = false;
    }
    if (response["method"] != "eth_call") { // eth_call is garbage for us, do not print it
    //      std::cout << "Request: " << request.dump(2) << std::endl;
    //      std::cout << "Response: " << response.dump(2) << std::endl;
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
        userInputRequest.lock();
        // Tell QML to show and ask for permission for given website
        std::cout << request.dump(2) << std::endl;
        std::string website = request["__frameOrigin"];
        emit askForPermission(QString::fromStdString(website));
        userInputAnswer.lock();
        userInputAnswer.lock(); // Wait until user completed the input
        // The reason to lock twice, is to give "control" of this thread to 
        // The function "addToPermissionList", which will unlock this thread after
        // user input.
        // Check what permission he gave for the website.
        for (auto websitePermission : permissionList) {
          std::cout << websitePermission.first << std::endl;
          std::cout << request["__frameOrigin"].get<std::string>() << std::endl;
          if (request["__frameOrigin"].get<std::string>() == websitePermission.first)
            permission = websitePermission.second;
        }
        userInputAnswer.unlock();
        userInputRequest.unlock();
      }

      this->permissionListMutex.unlock();
      if (permission == false) {
        session_->close(); // Close the session if not permitted.
        return; // We should not answer the website 
      }      
    }

    session_->do_write(response.dump());
  });
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

Q_INVOKABLE void QmlSystem::addToPermissionList(QString website, bool allow) {
  permissionList.push_back(std::make_pair(website.toStdString(), allow));
  userInputAnswer.unlock(); // Unlock for handleServer self-lock.
}