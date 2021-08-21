// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include "QmlApi.h"

void QmlApi::doAPIRequests(QString requestID) {
  QtConcurrent::run([=](){
    std::string requests;
    try {
      requestListLock.lock();
      requests = API::buildMultiRequest(this->requestList[requestID]);
    } catch (std::exception &e) {
      requestListLock.unlock();
      emit apiRequestAnswered(QString::fromStdString(std::string("{ \"ERROR\": \"") + e.what() + "\"}"), requestID);
      return;
    }
    this->requestList[requestID].clear();
    requestListLock.unlock();
    std::string response = API::httpGetRequest(requests);
    emit apiRequestAnswered(QString::fromStdString(response), requestID);
  });
}

void QmlApi::clearAPIRequests(QString requestID) {
  requestListLock.lock();
    try {
      this->requestList[requestID].clear();
      this->requestList.erase(requestID);
    } catch (std::exception &e) {
      std::cout << e.what() << std::endl;
    }
  requestListLock.unlock();
}

QStringList QmlApi::parseHex(QString hexStr, QStringList types) {
  std::vector<std::string> typesVec, parsed;
  QStringList ret;
  for (QString type : types) { typesVec.push_back(type.toStdString()); }
  try {
    parsed = Pangolin::parseHex(hexStr.toStdString(), typesVec);
  } catch (std::exception &e) {
    Utils::logToDebug(std::string("parseHex: ") + e.what());
  }
  for (std::string value : parsed) { ret << QString::fromStdString(value); }
  return ret;
}

void QmlApi::buildGetBalanceReq(QString address, QString requestID) {
  requestListLock.lock();
  Request req{
    this->requestList[requestID].size() + size_t(1), "2.0", "eth_getBalance",
    {address.toStdString(), "latest"}
  };
  this->requestList[requestID].push_back(req);
  requestListLock.unlock();
}

void QmlApi::buildGetTokenBalanceReq(QString contract, QString address, QString requestID) {
  std::string addressStr = address.toStdString();
  if (addressStr.substr(0,2) == "0x") { addressStr = addressStr.substr(2); }
  json params;
  json array = json::array();
  params["to"] = contract.toStdString();
  params["data"] = "0x70a08231000000000000000000000000" + addressStr;
  array.push_back(params);
  array.push_back("latest");
  requestListLock.lock();
  Request req{this->requestList[requestID].size() + size_t(1), "2.0", "eth_call", array};
  this->requestList[requestID].push_back(req);
  requestListLock.unlock();
}

void QmlApi::buildGetTotalSupplyReq(QString pairAddress, QString requestID) {
  json params;
  json array = json::array();
  params["to"] = pairAddress.toStdString();
  params["data"] = Pangolin::ERC20Funcs["totalSupply"];
  array.push_back(params);
  array.push_back("latest");
  requestListLock.lock();
  Request req{this->requestList[requestID].size() + size_t(1), "2.0", "eth_call", array};
  this->requestList[requestID].push_back(req);
  requestListLock.unlock();
}

void QmlApi::buildGetCurrentBlockNumberReq(QString requestID) {
  requestListLock.lock();
  Request req{
    this->requestList[requestID].size() + size_t(1), "2.0", "eth_blockNumber", json::array()
  };
  this->requestList[requestID].push_back(req);
  requestListLock.unlock();
}

void QmlApi::buildGetTxReceiptReq(std::string txidHex, QString requestID) {
  requestListLock.lock();
  Request req{
    this->requestList[requestID].size() + size_t(1), "2.0", "eth_getTransactionReceipt",
    {"0x" + txidHex}
  };
  this->requestList[requestID].push_back(req);
  requestListLock.unlock();
}

// TODO: implement this
void QmlApi::buildGetEstimateGasLimitReq(QString jsonStr, QString requestID) {
  json inputParams = json::parse(jsonStr.toStdString());
  json paramsArr = json::array();
  paramsArr.push_back(inputParams);
  requestListLock.lock();
  Request req{
    this->requestList[requestID].size() + size_t(1), "2.0", "eth_estimateGas",
    paramsArr
  };
  this->requestList[requestID].push_back(req);
  requestListLock.unlock();
  return;
}

void QmlApi::buildARC20TokenExistsReq(std::string address, QString requestID) {
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
  requestListLock.lock();
  Request supplyReq{this->requestList[requestID].size() + size_t(1), "2.0", "eth_call", supplyJsonArr};
  Request balanceReq{this->requestList[requestID].size() + size_t(1), "2.0", "eth_call", balanceJsonArr};
  this->requestList[requestID].push_back(supplyReq);
  this->requestList[requestID].push_back(balanceReq);
  requestListLock.unlock();
}

void QmlApi::buildGetARC20TokenDataReq(std::string address, QString requestID) {
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
  requestListLock.lock();
  Request nameReq{
    this->requestList[requestID].size() + size_t(1), "2.0", "eth_call", nameJsonArr
  };
  Request symbolReq{
    this->requestList[requestID].size() + size_t(1), "2.0", "eth_call", symbolJsonArr
  };
  Request decimalsReq{
    this->requestList[requestID].size() + size_t(1), "2.0", "eth_call", decimalsJsonArr
  };
  this->requestList[requestID].push_back(nameReq);
  this->requestList[requestID].push_back(symbolReq);
  this->requestList[requestID].push_back(decimalsReq);
  requestListLock.unlock();
}

void QmlApi::getTokenPriceHistory(QString address, int days, QString requestID) {
  QtConcurrent::run([=](){
    emit tokenPriceHistoryAnswered(QString::fromStdString(Graph::getTokenPriceHistory(address.toStdString(), days).dump()), requestID, days);
  });
}

void QmlApi::buildGetAllowanceReq(QString receiver, QString owner, QString spender, QString requestID) {
  json params;
  json array = json::array();
  params["to"] = receiver.toStdString();
  params["data"] = Pangolin::ERC20Funcs["allowance"]
    + Utils::addressToHex(owner.toStdString()) + Utils::addressToHex(spender.toStdString());
  array.push_back(params);
  array.push_back("latest");
  requestListLock.lock();
  Request req{this->requestList[requestID].size() + size_t(1), "2.0", "eth_call", array};
  this->requestList[requestID].push_back(req);
  requestListLock.unlock();
}

void QmlApi::buildGetPairReq(QString assetAddress1, QString assetAddress2, QString requestID) {
  json params;
  json array = json::array();
  params["to"] = Pangolin::contracts["factory"];
  params["data"] = Pangolin::factoryFuncs["getPair"]
    + Utils::addressToHex(assetAddress1.toStdString())
    + Utils::addressToHex(assetAddress2.toStdString());
  array.push_back(params);
  array.push_back("latest");
  requestListLock.lock();
  Request req{this->requestList[requestID].size() + size_t(1), "2.0", "eth_call", array};
  this->requestList[requestID].push_back(req);
  requestListLock.unlock();
}

void QmlApi::buildGetReservesReq(QString pairAddress, QString requestID) {
  json params;
  json array = json::array();
  params["to"] = pairAddress.toStdString();
  params["data"] = Pangolin::pairFuncs["getReserves"];
  array.push_back(params);
  array.push_back("latest");
  requestListLock.lock();
  Request req{this->requestList[requestID].size() + size_t(1), "2.0", "eth_call", array};
  this->requestList[requestID].push_back(req);
  requestListLock.unlock();
}

void QmlApi::buildCustomEthCallReq(QString contract, QString ABI, QString requestID) {
  json params;
  json array = json::array();
  params["to"] = contract.toStdString();
  params["data"] = ABI.toStdString();
  array.push_back(params);
  array.push_back("latest");
  requestListLock.lock();
  Request req{this->requestList[requestID].size() + size_t(1), "2.0", "eth_call", array};
  this->requestList[requestID].push_back(req);
  requestListLock.unlock();
}

QString QmlApi::buildCustomABI(QString input) {
  return QString::fromStdString(ABI::encodeABIfromJson(input.toStdString()));
}

QString QmlApi::weiToFixedPoint(QString amount, int digits) {
  return QString::fromStdString(Utils::weiToFixedPoint(amount.toStdString(), digits));
}
QString QmlApi::fixedPointToWei(QString amount, int decimals) {
  return QString::fromStdString(Utils::fixedPointToWei(amount.toStdString(), decimals));
}

QString QmlApi::uintToHex(QString input) {
  return QString::fromStdString(Utils::uintToHex(input.toStdString(), false));
}

QString QmlApi::uintFromHex(QString hex) {
  return QString::fromStdString(Utils::uintFromHex(hex.toStdString()));
}

QString QmlApi::MAX_U256_VALUE() {
  return QString::fromStdString(boost::lexical_cast<std::string>(Utils::MAX_U256_VALUE()));
}

QString QmlApi::getCurrentUnixTime() {
  const auto p1 = std::chrono::system_clock::now();
  return QString::fromStdString(boost::lexical_cast<std::string>(std::chrono::duration_cast<std::chrono::seconds>(p1.time_since_epoch()).count()));
}

QString QmlApi::getRandomID() {
  return QString::fromStdString(Utils::randomHexBytes().substr(0, 8));
}
