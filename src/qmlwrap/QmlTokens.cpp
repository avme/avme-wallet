// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

void QmlSystem::loadARC20Tokens() {
  QmlSystem::w.loadARC20Tokens();
}

QVariantList QmlSystem::getARC20Tokens() {
  std::vector<ARC20Token> list = QmlSystem::w.getARC20Tokens();
  QVariantList ret;
  for (ARC20Token token : list) {
    QVariantMap tokenObj;
    tokenObj.insert("address", QString::fromStdString(token.address));
    tokenObj.insert("symbol", QString::fromStdString(token.symbol));
    tokenObj.insert("name", QString::fromStdString(token.name));
    tokenObj.insert("decimals", token.decimals);
    tokenObj.insert("avaxPairContract", QString::fromStdString(token.avaxPairContract));
    ret << tokenObj;
  }
  return ret;
}

void QmlSystem::downloadARC20TokenImage(QString address) {
  std::string addressStr = address.toStdString();
  boost::filesystem::path filePath = Utils::walletFolderPath.string()
    + "/wallet/c-avax/tokens/icons";
  if (!boost::filesystem::exists(filePath)) {
    boost::filesystem::create_directories(filePath);
  }
  API::httpGetFile(
    "raw.githubusercontent.com",
    "/ava-labs/bridge-tokens/main/avalanche-tokens/" + addressStr + "/logo.png",
    filePath.string() + "/" + addressStr + ".png"
  );
}

QString QmlSystem::getARC20TokenImage(QString address) {
  boost::filesystem::path filePath = Utils::walletFolderPath.string()
    + "/wallet/c-avax/tokens/icons/" + address.toStdString() + ".png";
  if (boost::filesystem::exists(filePath)) {
    return QString::fromStdString(filePath.string());
  } else {
    return "";
  }
}

bool QmlSystem::addARC20Token(
  QString address, QString symbol, QString name, int decimals, QString avaxPairContract
) {
  return QmlSystem::w.addARC20Token(
    address.toStdString(), symbol.toStdString(), name.toStdString(),
    decimals, avaxPairContract.toStdString()
  );
}

bool QmlSystem::removeARC20Token(QString address) {
  return QmlSystem::w.removeARC20Token(address.toStdString());
}

QVariantMap QmlSystem::getAVMEData() {
  QVariantMap tokenObj;
  tokenObj.insert("address", QString::fromStdString(Pangolin::contracts["AVME"]));
  tokenObj.insert("symbol", QString::fromStdString("AVME"));
  tokenObj.insert("name", QString::fromStdString("AV Me"));
  tokenObj.insert("decimals", 18);
  tokenObj.insert("avaxPairContract", QString::fromStdString(Pangolin::contracts["AVAX-AVME"]));
  return tokenObj;
}

bool QmlSystem::ARC20TokenExists(QString address) {
  std::string addressStr = address.toStdString();
  json supplyJson, balanceJson;
  json supplyJsonArr = json::array();
  json balanceJsonArr = json::array();
  supplyJson["to"] = balanceJson["to"] = addressStr;
  supplyJson["data"] = Pangolin::ERC20Funcs["totalSupply"];
  balanceJson["data"] = Pangolin::ERC20Funcs["balanceOf"] + Utils::addressToHex(addressStr);
  supplyJsonArr.push_back(supplyJson);
  supplyJsonArr.push_back("latest");
  balanceJsonArr.push_back(supplyJson);
  balanceJsonArr.push_back("latest");
  Request supplyReq{1, "2.0", "eth_call", supplyJsonArr};
  Request balanceReq{1, "2.0", "eth_call", balanceJsonArr};
  std::string supplyQuery, supplyResp, supplyHex, balanceQuery, balanceResp, balanceHex;
  supplyQuery = API::buildRequest(supplyReq);
  balanceQuery = API::buildRequest(balanceReq);
  supplyResp = API::httpGetRequest(supplyQuery);
  balanceResp = API::httpGetRequest(balanceQuery);
  json supplyRespJson = json::parse(supplyResp);
  json balanceRespJson = json::parse(balanceResp);
  supplyHex = supplyRespJson["result"].get<std::string>();
  balanceHex = balanceRespJson["result"].get<std::string>();
  if (supplyHex == "0x" || supplyHex == "") { return false; }
  if (balanceHex == "0x" || balanceHex == "") { return false; }
  return true;
}

QVariantMap QmlSystem::getARC20TokenData(QString address) {
  std::string addressStr = address.toStdString();
  json nameJson, symbolJson, decimalsJson;
  json nameJsonArr = json::array();
  json symbolJsonArr = json::array();
  json decimalsJsonArr = json::array();
  nameJson["to"] = symbolJson["to"] = decimalsJson["to"] = addressStr;
  nameJson["data"] = Pangolin::ERC20Funcs["name"];
  symbolJson["data"] = Pangolin::ERC20Funcs["symbol"];
  decimalsJson["data"] = Pangolin::ERC20Funcs["decimals"];
  nameJsonArr.push_back(nameJson);
  symbolJsonArr.push_back(symbolJson);
  decimalsJsonArr.push_back(decimalsJson);
  Request nameReq{1, "2.0", "eth_call", nameJsonArr};
  Request symbolReq{1, "2.0", "eth_call", symbolJsonArr};
  Request decimalsReq{1, "2.0", "eth_call", decimalsJsonArr};
  std::string nameQuery, nameResp, nameHex, symbolQuery, symbolResp, symbolHex,
    decimalsQuery, decimalsResp, decimalsHex;
  nameQuery = API::buildRequest(nameReq);
  symbolQuery = API::buildRequest(symbolReq);
  decimalsQuery = API::buildRequest(decimalsReq);
  nameResp = API::httpGetRequest(nameQuery);
  symbolResp = API::httpGetRequest(symbolQuery);
  decimalsResp = API::httpGetRequest(decimalsQuery);
  json nameRespJson = json::parse(nameResp);
  json symbolRespJson = json::parse(symbolResp);
  json decimalsRespJson = json::parse(decimalsResp);
  nameHex = nameRespJson["result"].get<std::string>();
  symbolHex = symbolRespJson["result"].get<std::string>();
  decimalsHex = decimalsRespJson["result"].get<std::string>();
  ARC20Token token;
  token.address = addressStr;
  token.name = Utils::stringFromHex(nameHex);
  token.symbol = Utils::stringFromHex(symbolHex);
  token.decimals = boost::lexical_cast<int>(Utils::uintFromHex(decimalsHex));
  QVariantMap tokenObj;
  tokenObj.insert("address", QString::fromStdString(token.address));
  tokenObj.insert("symbol", QString::fromStdString(token.symbol));
  tokenObj.insert("name", QString::fromStdString(token.name));
  tokenObj.insert("decimals", token.decimals);
  tokenObj.insert("avaxPairContract", QString::fromStdString(token.avaxPairContract));
  return tokenObj;
}

bool QmlSystem::ARC20TokenWasAdded(QString address) {
  std::string addressStr = address.toStdString();
  std::string avmeStr = Pangolin::contracts["AVME"];
  std::transform(addressStr.begin(), addressStr.end(), addressStr.begin(), ::tolower);
  std::transform(avmeStr.begin(), avmeStr.end(), avmeStr.begin(), ::tolower);
  if (addressStr == avmeStr) { return true; }
  return QmlSystem::w.ARC20TokenWasAdded(addressStr);
}
