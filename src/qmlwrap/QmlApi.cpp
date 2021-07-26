// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include "QmlApi.h"

Q_INVOKABLE QString QmlApi::doAPIRequests() {
  std::string requests = API::buildMultiRequest(this->requestList);
  return QString::fromStdString(API::httpGetRequest(requests));
}

Q_INVOKABLE void QmlApi::buildBlockNumberReq() {
  Request req{this->requestList.size() + size_t(1), "2.0", "eth_blockNumber", json::array()};
  this->requestList.push_back(req);
  return;
}

Q_INVOKABLE void QmlApi::buildCustomEthCallReq(QString contract, QString ABI) {
  json params;
  params["to"] = contract.toStdString();
  params["data"] = ABI.toStdString();
  json array = json::array();
  array.push_back(params);
  array.push_back("latest");

  Request req{this->requestList.size() + size_t(1), "2.0", "eth_getBalance", array};
  this->requestList.push_back(req);
  return;
}

Q_INVOKABLE void QmlApi::buildGetTokenBalanceReq(QString contract, QString address) {
  std::string tmp_address = address.toStdString();
  if (tmp_address.substr(0,2) == "0x") {
    tmp_address = tmp_address.substr(2);
  }

  json params;
  params["to"] = contract.toStdString();
  params["data"] = std::string("0x70a08231000000000000000000000000") + tmp_address;
  json array = json::array();
  array.push_back(params);
  array.push_back("latest");

  Request req{this->requestList.size() + size_t(1), "2.0", "eth_getBalance", array};
  this->requestList.push_back(req);
}

Q_INVOKABLE QString QmlApi::buildCustomABI(QString input) {
  return QString::fromStdString(ABI::encodeABIfromJson(input.toStdString()));
}
