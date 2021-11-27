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

void QmlSystem::getARC20TokenList() {
  QtConcurrent::run([=](){
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
      tokenObj["selected"] = false;
      ret << tokenObj;
    }
    emit gotTokenList(ret);
  });
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
  std::vector<Request> reqVec;
  Request supplyReq{1, "2.0", "eth_call", supplyJsonArr};
  Request balanceReq{2, "2.0", "eth_call", balanceJsonArr};
  Request nameReq{3, "2.0", "eth_call", nameJsonArr};
  Request symbolReq{4, "2.0", "eth_call", symbolJsonArr};
  Request decimalsReq{5, "2.0", "eth_call", decimalsJsonArr};
  reqVec.push_back(supplyReq);
  reqVec.push_back(balanceReq);
  reqVec.push_back(nameReq);
  reqVec.push_back(symbolReq);
  reqVec.push_back(decimalsReq);
  std::string query = API::buildMultiRequest(reqVec);
  std::string resp = API::httpGetRequest(query);
  json resultArr = json::parse(resp);
  std::string supplyHex, balanceHex, nameHex, symbolHex, decimalsHex;
  try {
    for (auto arrItem : resultArr) {
      switch (arrItem["id"].get<int>()) {
        case 1: // Supply
          supplyHex = arrItem["result"].get<std::string>(); break;
        case 2: // Balance
          balanceHex = arrItem["result"].get<std::string>(); break;
        case 3: // Name
          nameHex = arrItem["result"].get<std::string>(); break;
        case 4: // Symbol
          symbolHex = arrItem["result"].get<std::string>(); break;
        case 5: // Decimals
          decimalsHex = arrItem["result"].get<std::string>(); break;
      }
    }
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
  std::vector<Request> reqVec;
  Request nameReq{1, "2.0", "eth_call", {nameJson, "latest"}};
  Request symbolReq{2, "2.0", "eth_call", {symbolJson, "latest"}};
  Request decimalsReq{3, "2.0", "eth_call", {decimalsJson, "latest"}};
  Request pairReq{4, "2.0", "eth_call", {pairJson, "latest"}};
  reqVec.push_back(nameReq);
  reqVec.push_back(symbolReq);
  reqVec.push_back(decimalsReq);
  reqVec.push_back(pairReq);
  std::string query = API::buildMultiRequest(reqVec);
  std::string resp = API::httpGetRequest(query);
  json resultArr = json::parse(resp);
  std::string nameHex, symbolHex, decimalsHex, pairHex;
  for (auto arrItem : resultArr) {
    switch (arrItem["id"].get<int>()) {
      case 1: // Name
        nameHex = arrItem["result"].get<std::string>(); break;
      case 2: // Symbol
        symbolHex = arrItem["result"].get<std::string>(); break;
      case 3: // Decimals
        decimalsHex = arrItem["result"].get<std::string>(); break;
      case 4: // Pair
        pairHex = arrItem["result"].get<std::string>(); break;
    }
  }
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

void QmlSystem::addARC20Tokens(QVariantList addresses) {
  QtConcurrent::run([=](){
    int tokenCt = 0;
    QFutureSynchronizer<QVariantMap> sync;
    QList<QFuture<QVariantMap>> syncList;
    for (int i = 0; i < addresses.count(); i++) {
      sync.addFuture(QtConcurrent::run([=](){
        QVariantMap tokenData = getARC20TokenData(addresses[i].toString());
        downloadARC20TokenImage(addresses[i].toString());
        emit updateAddTokenProgress(addresses.count());
        return tokenData;
      }));
    }
    sync.waitForFinished();
    syncList = sync.futures();
    for (int i = 0; i < syncList.size(); i++) {
      QVariantMap tokenData = syncList.at(i);
      addARC20Token(
        tokenData["address"].toString(), tokenData["symbol"].toString(),
        tokenData["name"].toString(), tokenData["decimals"].toInt(),
        tokenData["avaxPairContract"].toString()
      );
    }
    emit addedTokens();
  });
}
