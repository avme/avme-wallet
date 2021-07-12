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

// TODO: image
QVariantMap QmlSystem::getAVMEData() {
  QVariantMap tokenObj;
  tokenObj.insert("address", QString::fromStdString(Pangolin::tokenContracts["AVME"]));
  tokenObj.insert("symbol", QString::fromStdString("AVME"));
  tokenObj.insert("name", QString::fromStdString("AV Me"));
  tokenObj.insert("decimals", 18);
  tokenObj.insert("avaxPairContract", QString::fromStdString(Pangolin::pairContracts["WAVAX-AVME"]));
  return tokenObj;
}
