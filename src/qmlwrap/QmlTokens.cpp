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
  return API::isARC20Token(address.toStdString());
}

QVariantMap QmlSystem::getARC20TokenData(QString address) {
  ARC20Token token = API::getARC20TokenData(address.toStdString());
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
