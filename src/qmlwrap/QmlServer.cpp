// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>
#include <network/Server.h> // https://stackoverflow.com/a/4964508


void QmlSystem::handleServer(std::string inputStr, session *session_) {
  // Run answer in another thread to allow the Server to take more inputs
  json request = json::parse(inputStr);
  QtConcurrent::run([=](){
    json response;
    // Initialize response with common information.
    response["jsonrpc"] = "2.0";
    response["id"] = request["id"];
    if (request["method"] == "eth_chainId") {
        response["result"] = "0xa86a";
    } else if (request["method"] == "net_version") {
        response["result"] = "43114";
    } else if(request["method"] == "eth_requestAccounts") {
        response["result"] = json::array();
        response["result"].push_back(this->getCurrentAccount().toStdString());   
    } else if(request["method"] == "eth_subscribe") {
        response["error"]["code"] = -32601;
        response["error"]["message"] = "Method not found";
    } else {
        response = json::parse(API::httpGetRequest(request.dump()));
    }
    if (response["method"] != "eth_call") { // eth_call is garbage for us, do not print it
        std::cout << "Request: " << request.dump(2) << std::endl;
        std::cout << "Response: " << response.dump(2) << std::endl;
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