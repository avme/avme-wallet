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
    this->requestList.erase(requestID);
    requestListLock.unlock();
    std::string response = API::httpGetRequest(requests);
    emit apiRequestAnswered(QString::fromStdString(response), requestID);
  });
}

Q_INVOKABLE void QmlApi::doCustomHttpRequest(
  QString reqBody, QString host, QString port, QString target,
  QString requestType, QString contentType, QString requestID
) {
  QtConcurrent::run([=](){
    std::string ret;
    ret = API::customHttpRequest(
      reqBody.toStdString(), host.toStdString(), port.toStdString(),
      target.toStdString(), requestType.toStdString(), contentType.toStdString()
    );
    emit customApiRequestAnswered(QString::fromStdString(ret), requestID);
  });
}

void QmlApi::clearAPIRequests(QString requestID) {
  requestListLock.lock();
    try {
      this->requestList[requestID].clear();
      this->requestList.erase(requestID);
    } catch (std::exception &e) {
      //std::cout << e.what() << std::endl;
    }
  requestListLock.unlock();
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

void QmlApi::buildGetTokenBalanceReq(QString tokenContract, QString address, QString requestID) {
  std::string addressStr = address.toStdString();
  if (addressStr.substr(0,2) == "0x") { addressStr = addressStr.substr(2); }
  json params;
  json array = json::array();
  params["to"] = tokenContract.toStdString();
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

void QmlApi::buildGetTxReceiptReq(QString txidHex, QString requestID) {
  requestListLock.lock();
  Request req{
    this->requestList[requestID].size() + size_t(1), "2.0", "eth_getTransactionReceipt",
    {"0x" + txidHex.toStdString()}
  };
  this->requestList[requestID].push_back(req);
  requestListLock.unlock();
}

void QmlApi::buildGetEstimateGasLimitReq(QString jsonStr, QString requestID) {
  json inputParams = json::parse(jsonStr.toStdString());
  json paramsArr = json::array();
  paramsArr.push_back(inputParams);
  requestListLock.lock();
  Request req{
    this->requestList[requestID].size() + size_t(1), "2.0", "eth_estimateGas", paramsArr
  };
  this->requestList[requestID].push_back(req);
  requestListLock.unlock();
  return;
}

void QmlApi::buildARC20TokenExistsReq(QString address, QString requestID) {
  json supplyJson, balanceJson;
  json supplyJsonArr = json::array();
  json balanceJsonArr = json::array();
  supplyJson["to"] = balanceJson["to"] = address.toStdString();
  supplyJson["data"] = Pangolin::ERC20Funcs["totalSupply"];
  balanceJson["data"] = Pangolin::ERC20Funcs["balanceOf"] + Utils::addressToHex(address.toStdString());
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

void QmlApi::buildGetARC20TokenDataReq(QString address, QString requestID) {
  json nameJson, symbolJson, decimalsJson;
  json nameJsonArr, symbolJsonArr, decimalsJsonArr;
  nameJson["to"] = symbolJson["to"] = decimalsJson["to"] = address.toStdString();
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

void QmlApi::buildGetPairReq(QString assetAddress1, QString assetAddress2, QString factoryContract,QString requestID) {
  json params;
  json array = json::array();
  params["to"] = factoryContract.toStdString();
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

QString QmlApi::getFirstFromPair(QString assetAddressA, QString assetAddressB) {
  return QString::fromStdString(
    Pangolin::getFirstFromPair(assetAddressA.toStdString(), assetAddressB.toStdString())
  );
}

void QmlApi::getTokenPriceHistory(QString address, int days, QString requestID) {
  QtConcurrent::run([=](){
    emit tokenPriceHistoryAnswered(QString::fromStdString(Graph::getTokenPriceHistory(address.toStdString(), days).dump()), requestID, days);
  });
}

QString QmlApi::getARC20TokenImage(QString address) {
  boost::filesystem::path filePath = Utils::walletFolderPath.string()
    + "/wallet/c-avax/tokens/icons/" + address.toStdString() + ".png";
  if (boost::filesystem::exists(filePath)) {
    return QString::fromStdString(filePath.string());
  } else {
    return "";
  }
}

QString QmlApi::buildCustomABI(QString input) {
  return QString::fromStdString(ABI::encodeABIfromJson(input.toStdString()));
}

QString QmlApi::weiToFixedPoint(QString amount, int decimals) {
  return QString::fromStdString(Utils::weiToFixedPoint(amount.toStdString(), decimals));
}
QString QmlApi::fixedPointToWei(QString amount, int decimals) {
  return QString::fromStdString(Utils::fixedPointToWei(amount.toStdString(), decimals));
}

QString QmlApi::uintToHex(QString input, bool isPadded) {
  return QString::fromStdString(Utils::uintToHex(input.toStdString(), isPadded));
}

QString QmlApi::uintFromHex(QString hex) {
  return QString::fromStdString(Utils::uintFromHex(hex.toStdString()));
}

QString QmlApi::addressToHex(QString input) {
  return QString::fromStdString(Utils::addressToHex(input.toStdString()));
}

QString QmlApi::addressFromHex(QString hex) {
  return QString::fromStdString(Utils::addressFromHex(hex.toStdString()));
}

QString QmlApi::bytesToHex(QString input, bool isUint) {
  return QString::fromStdString(Utils::bytesToHex(input.toStdString(), isUint));
}

QString QmlApi::bytesFromHex(QString hex) {
  return QString::fromStdString(Utils::bytesFromHex(hex.toStdString()));
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

QString QmlApi::sum(QString a, QString b) {
  bigfloat result;
  bigfloat an = boost::lexical_cast<bigfloat>(a.toStdString());
  bigfloat bn = boost::lexical_cast<bigfloat>(b.toStdString());
  result = an + bn;
  return QString::fromStdString(boost::lexical_cast<std::string>(result.str(256)));
}

QString QmlApi::sub(QString a, QString b) {
  bigfloat result;
  bigfloat an = boost::lexical_cast<bigfloat>(a.toStdString());
  bigfloat bn = boost::lexical_cast<bigfloat>(b.toStdString());
  result = an - bn;
  return QString::fromStdString(boost::lexical_cast<std::string>(result.str(256)));
}

QString QmlApi::mul(QString a, QString b) {
  bigfloat result;
  bigfloat an = boost::lexical_cast<bigfloat>(a.toStdString());
  bigfloat bn = boost::lexical_cast<bigfloat>(b.toStdString());
  result = an * bn;
  return QString::fromStdString(boost::lexical_cast<std::string>(result.str(256)));
}

QString QmlApi::div(QString a, QString b) {
  bigfloat result;
  bigfloat an = boost::lexical_cast<bigfloat>(a.toStdString());
  bigfloat bn = boost::lexical_cast<bigfloat>(b.toStdString());
  result = an / bn;
  return QString::fromStdString(boost::lexical_cast<std::string>(result.str(256)));
}

QString QmlApi::round(QString a) {
  bigfloat result;
  bigfloat an = boost::lexical_cast<bigfloat>(a.toStdString());
  result = boost::multiprecision::round(an);
  return QString::fromStdString(boost::lexical_cast<std::string>(result.str(256)));
}

QString QmlApi::floor(QString a) {
  bigfloat result;
  bigfloat an = boost::lexical_cast<bigfloat>(a.toStdString());
  result = boost::multiprecision::floor(an);
  return QString::fromStdString(boost::lexical_cast<std::string>(result.str(256)));
}

QString QmlApi::ceil(QString a) {
  bigfloat result;
  bigfloat an = boost::lexical_cast<bigfloat>(a.toStdString());
  result = boost::multiprecision::ceil(an);
  return QString::fromStdString(boost::lexical_cast<std::string>(result.str(256)));
}

QRegExp QmlApi::createRegExp(QString desiredRegex) {
  QRegExp rx;
  rx.setPattern(desiredRegex);
  return rx;
}
