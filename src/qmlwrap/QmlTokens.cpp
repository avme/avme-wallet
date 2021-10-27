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
  boost::filesystem::path filePath = Utils::walletFolderPath.string()
    + "/wallet/c-avax/tokens/icons";
  if (!boost::filesystem::exists(filePath)) {
    boost::filesystem::create_directories(filePath);
  }
  API::httpGetFile(
    "raw.githubusercontent.com",
    "/avme/avme-wallet-tokenlist/main/icons/"
      + Utils::toLowerCaseAddress(address.toStdString()) + "/logo.png",
    filePath.string() + "/" + Utils::toCamelCaseAddress(address.toStdString()) + ".png"
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

QVariantList QmlSystem::getARC20TokenList() {
  QVariantList ret;
  boost::filesystem::path filePath = Utils::walletFolderPath.string()
    + "/wallet/c-avax/tokenlist.json";
  // Always force-refresh the list
  if (boost::filesystem::exists(filePath)) { boost::filesystem::remove(filePath); }
  API::httpGetFile(
    "raw.githubusercontent.com",
    "/avme/avme-wallet-tokenlist/main/tokenlist.json",
    filePath.string()
  );
  json tokenlist = json::parse(Utils::readJSONFile(filePath));
  json tokens = tokenlist["tokens"];
  for (auto& token : tokens) {
    QVariantMap tokenObj;
    tokenObj["address"] = QString::fromStdString(token["contract-address"].get<std::string>());
    tokenObj["name"] = QString::fromStdString(token["name"].get<std::string>());
    tokenObj["symbol"] = QString::fromStdString(token["symbol"].get<std::string>());
    tokenObj["decimals"] = token["decimals"].get<int>();
    tokenObj["icon"] = QString::fromStdString(token["logoURI"].get<std::string>());
    ret << tokenObj;
  }
  return ret;
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

bool QmlSystem::ARC20TokenExists(QString address) {
  std::string addressStr = Utils::toCamelCaseAddress(address.toStdString());
  json supplyJson, balanceJson, nameJson, symbolJson, decimalsJson;
  json supplyJsonArr = json::array();
  json balanceJsonArr = json::array();
  json nameJsonArr = json::array();
  json symbolJsonArr = json::array();
  json decimalsJsonArr = json::array();
  supplyJson["to"] = balanceJson["to"] = addressStr;
  nameJson["to"] = symbolJson["to"] = decimalsJson["to"] = addressStr;
  supplyJson["data"] = Pangolin::ERC20Funcs["totalSupply"];
  balanceJson["data"] = Pangolin::ERC20Funcs["balanceOf"] + Utils::addressToHex(addressStr);
  nameJson["data"] = Pangolin::ERC20Funcs["name"];
  symbolJson["data"] = Pangolin::ERC20Funcs["symbol"];
  decimalsJson["data"] = Pangolin::ERC20Funcs["decimals"];
  supplyJsonArr.push_back(supplyJson);
  supplyJsonArr.push_back("latest");
  balanceJsonArr.push_back(balanceJson);
  balanceJsonArr.push_back("latest");
  nameJsonArr.push_back(nameJson);
  nameJsonArr.push_back("latest");
  symbolJsonArr.push_back(symbolJson);
  symbolJsonArr.push_back("latest");
  decimalsJsonArr.push_back(decimalsJson);
  decimalsJsonArr.push_back("latest");
  Request supplyReq{1, "2.0", "eth_call", supplyJsonArr};
  Request balanceReq{1, "2.0", "eth_call", balanceJsonArr};
  Request nameReq{1, "2.0", "eth_call", nameJsonArr};
  Request symbolReq{1, "2.0", "eth_call", symbolJsonArr};
  Request decimalsReq{1, "2.0", "eth_call", decimalsJsonArr};
  std::string supplyQuery, supplyResp, supplyHex;
  std::string balanceQuery, balanceResp, balanceHex;
  std::string nameQuery, nameResp, nameHex;
  std::string symbolQuery, symbolResp, symbolHex;
  std::string decimalsQuery, decimalsResp, decimalsHex;
  supplyQuery = API::buildRequest(supplyReq);
  balanceQuery = API::buildRequest(balanceReq);
  nameQuery = API::buildRequest(nameReq);
  symbolQuery = API::buildRequest(symbolReq);
  decimalsQuery = API::buildRequest(decimalsReq);
  supplyResp = API::httpGetRequest(supplyQuery);
  balanceResp = API::httpGetRequest(balanceQuery);
  nameResp = API::httpGetRequest(nameQuery);
  symbolResp = API::httpGetRequest(symbolQuery);
  decimalsResp = API::httpGetRequest(decimalsQuery);
  json supplyRespJson = json::parse(supplyResp);
  json balanceRespJson = json::parse(balanceResp);
  json nameRespJson = json::parse(nameResp);
  json symbolRespJson = json::parse(symbolResp);
  json decimalsRespJson = json::parse(decimalsResp);
  try {
    supplyHex = supplyRespJson["result"].get<std::string>();
    balanceHex = balanceRespJson["result"].get<std::string>();
    nameHex = nameRespJson["result"].get<std::string>();
    symbolHex = symbolRespJson["result"].get<std::string>();
    decimalsHex = decimalsRespJson["result"].get<std::string>();
  } catch (...) { return false; }
  if (supplyHex == "0x" || supplyHex == "") { return false; }
  if (balanceHex == "0x" || balanceHex == "") { return false; }
  if (nameHex == "0x" || nameHex == "") { return false; }
  if (symbolHex == "0x" || symbolHex == "") { return false; }
  if (decimalsHex == "0x" || decimalsHex == "") { return false; }
  return true;
}

QVariantMap QmlSystem::getARC20TokenData(QString address) {
  std::string addressStr = Utils::toCamelCaseAddress(address.toStdString());
  json nameJson, symbolJson, decimalsJson, pairJson;
  nameJson["to"] = symbolJson["to"] = decimalsJson["to"] = addressStr;
  pairJson["to"] = Pangolin::contracts["factory"];
  nameJson["data"] = Pangolin::ERC20Funcs["name"];
  symbolJson["data"] = Pangolin::ERC20Funcs["symbol"];
  decimalsJson["data"] = Pangolin::ERC20Funcs["decimals"];
  pairJson["data"] = Pangolin::factoryFuncs["getPair"]
    + Utils::addressToHex(addressStr)
    + Utils::addressToHex(Pangolin::contracts["AVAX"]);
  Request nameReq{1, "2.0", "eth_call", {nameJson, "latest"}};
  Request symbolReq{1, "2.0", "eth_call", {symbolJson, "latest"}};
  Request decimalsReq{1, "2.0", "eth_call", {decimalsJson, "latest"}};
  Request pairReq{1, "2.0", "eth_call", {pairJson, "latest"}};
  std::string nameQuery, nameResp, nameHex, symbolQuery, symbolResp, symbolHex,
    decimalsQuery, decimalsResp, decimalsHex, pairQuery, pairResp, pairHex;
  nameQuery = API::buildRequest(nameReq);
  symbolQuery = API::buildRequest(symbolReq);
  decimalsQuery = API::buildRequest(decimalsReq);
  pairQuery = API::buildRequest(pairReq);
  nameResp = API::httpGetRequest(nameQuery);
  symbolResp = API::httpGetRequest(symbolQuery);
  decimalsResp = API::httpGetRequest(decimalsQuery);
  pairResp = API::httpGetRequest(pairQuery);
  json nameRespJson = json::parse(nameResp);
  json symbolRespJson = json::parse(symbolResp);
  json decimalsRespJson = json::parse(decimalsResp);
  json pairRespJson = json::parse(pairResp);
  nameHex = nameRespJson["result"].get<std::string>();
  symbolHex = symbolRespJson["result"].get<std::string>();
  decimalsHex = decimalsRespJson["result"].get<std::string>();
  pairHex = pairRespJson["result"].get<std::string>();
  ARC20Token token;
  token.address = addressStr;
  token.name = Utils::bytesFromHex(nameHex);
  token.symbol = Utils::bytesFromHex(symbolHex);
  token.decimals = boost::lexical_cast<int>(Utils::uintFromHex(decimalsHex));
  token.avaxPairContract = Utils::addressFromHex(pairHex);
  QVariantMap tokenObj;
  tokenObj.insert("address", QString::fromStdString(token.address));
  tokenObj.insert("symbol", QString::fromStdString(token.symbol));
  tokenObj.insert("name", QString::fromStdString(token.name));
  tokenObj.insert("decimals", token.decimals);
  tokenObj.insert("avaxPairContract", QString::fromStdString(token.avaxPairContract));
  return tokenObj;
}

bool QmlSystem::ARC20TokenWasAdded(QString address) {
  std::string addressStr = Utils::toCamelCaseAddress(address.toStdString());
  std::string avmeStr = Pangolin::contracts["AVME"];
  if (addressStr == avmeStr) { return true; }
  return QmlSystem::w.ARC20TokenWasAdded(addressStr);
}
