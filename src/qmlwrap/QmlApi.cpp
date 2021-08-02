// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include "QmlApi.h"

QString QmlApi::doAPIRequests() {
  std::string requests = API::buildMultiRequest(this->requestList);
  std::string response = API::httpGetRequest(requests);
  this->requestList.clear();
  return QString::fromStdString(response);
}

void QmlApi::clearAPIRequests() {
  this->requestList.clear();
}

void QmlApi::buildGetBalanceReq(QString address) {
  Request req{
    this->requestList.size() + size_t(1), "2.0", "eth_getBalance",
    {address.toStdString(), "latest"}
  };
  this->requestList.push_back(req);
}

void QmlApi::buildGetTokenBalanceReq(QString contract, QString address) {
  std::string addressStr = address.toStdString();
  if (addressStr.substr(0,2) == "0x") { addressStr = addressStr.substr(2); }
  json params;
  json array = json::array();
  params["to"] = contract.toStdString();
  params["data"] = "0x70a08231000000000000000000000000" + addressStr;
  array.push_back(params);
  array.push_back("latest");
  Request req{this->requestList.size() + size_t(1), "2.0", "eth_getBalance", array};
  this->requestList.push_back(req);
}

void QmlApi::buildGetCurrentBlockNumberReq() {
  Request req{
    this->requestList.size() + size_t(1), "2.0", "eth_blockNumber", json::array()
  };
  this->requestList.push_back(req);
}

void QmlApi::buildGetTxReceiptReq(std::string txidHex) {
  Request req{
    this->requestList.size() + size_t(1), "2.0", "eth_getTransactionReceipt",
    {"0x" + txidHex}
  };
  this->requestList.push_back(req);
}

// TODO: implement this
void QmlApi::buildGetEstimateGasLimitReq() {
  ;
}

void QmlApi::buildARC20TokenExistsReq(std::string address) {
  json supplyJson, balanceJson;
  json supplyJsonArr = json::array();
  json balanceJsonArr = json::array();
  supplyJson["to"] = balanceJson["to"] = address;
  supplyJson["data"] = Pangolin::ERC20Funcs["totalSupply"];
  balanceJson["data"] = Pangolin::ERC20Funcs["balanceOf"] + Utils::addressToHex(address);
  supplyJsonArr.push_back(supplyJson);
  supplyJsonArr.push_back("latest");
  balanceJsonArr.push_back(supplyJson);
  balanceJsonArr.push_back("latest");
  Request supplyReq{this->requestList.size() + size_t(1), "2.0", "eth_call", supplyJsonArr};
  this->requestList.push_back(supplyReq);
  Request balanceReq{this->requestList.size() + size_t(1), "2.0", "eth_call", balanceJsonArr};
  this->requestList.push_back(balanceReq);
}

void QmlApi::buildGetARC20TokenDataReq(std::string address) {
  json nameJson, symbolJson, decimalsJson;
  json nameJsonArr, symbolJsonArr, decimalsJsonArr;
  nameJson["to"] = symbolJson["to"] = decimalsJson["to"] = address;
  nameJson["data"] = Pangolin::ERC20Funcs["name"];
  symbolJson["data"] = Pangolin::ERC20Funcs["symbol"];
  decimalsJson["data"] = Pangolin::ERC20Funcs["decimals"];
  nameJsonArr = symbolJsonArr = decimalsJsonArr = json::array();
  nameJsonArr.push_back(nameJson);
  symbolJsonArr.push_back(symbolJson);
  decimalsJsonArr.push_back(decimalsJson);
  Request nameReq{
    this->requestList.size() + size_t(1), "2.0", "eth_call", nameJsonArr
  };
  this->requestList.push_back(nameReq);
  Request symbolReq{
    this->requestList.size() + size_t(1), "2.0", "eth_call", symbolJsonArr
  };
  this->requestList.push_back(symbolReq);
  Request decimalsReq{
    this->requestList.size() + size_t(1), "2.0", "eth_call", decimalsJsonArr
  };
  this->requestList.push_back(decimalsReq);
}

void QmlApi::buildCustomEthCallReq(QString contract, QString ABI) {
  json params;
  json array = json::array();
  params["to"] = contract.toStdString();
  params["data"] = ABI.toStdString();
  array.push_back(params);
  array.push_back("latest");
  Request req{this->requestList.size() + size_t(1), "2.0", "eth_getBalance", array};
  this->requestList.push_back(req);
}

QString QmlApi::buildCustomABI(QString input) {
  return QString::fromStdString(ABI::encodeABIfromJson(input.toStdString()));
}

QString QmlApi::getTokenPriceHistory(QString address, int days) {
  return QString::fromStdString(Graph::getTokenPriceHistory(address.toStdString(), days).dump());
}
