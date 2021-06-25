// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

bool QmlSystem::checkFolderForWallet(QString folder) {
  QString walletFile = QString(folder + "/wallet/c-avax/wallet.info");
  QString secretsFolder = QString(folder + "/wallet/c-avax/accounts/secrets");
  return (QFile::exists(walletFile) && QFile::exists(secretsFolder));
}

bool QmlSystem::createWallet(QString folder, QString pass) {
  std::string passStr = pass.toStdString();
  bool createSuccess = this->w.create(folder.toStdString(), passStr);
  bip3x::Bip39Mnemonic::MnemonicResult mnemonic = BIP39::createNewMnemonic();
  std::pair<bool,std::string> seedSuccess = BIP39::saveEncryptedMnemonic(mnemonic, passStr);
  return (createSuccess && seedSuccess.first);
}

bool QmlSystem::importWallet(QString seed, QString folder, QString pass) {
  std::string passStr = pass.toStdString();
  bool createSuccess = this->w.create(folder.toStdString(), passStr);
  bip3x::Bip39Mnemonic::MnemonicResult mnemonic;
  mnemonic.raw = seed.toStdString();
  std::pair<bool,std::string> seedSuccess = BIP39::saveEncryptedMnemonic(mnemonic, passStr);
  return (createSuccess && seedSuccess.first);
}

bool QmlSystem::loadWallet(QString folder, QString pass) {
  std::string passStr = pass.toStdString();
  bool loadSuccess = this->w.load(folder.toStdString(), passStr);
  return loadSuccess;
}

void QmlSystem::closeWallet() {
  this->w.close();
}

bool QmlSystem::isWalletLoaded() {
  return this->w.isLoaded();
}

bool QmlSystem::checkWalletPass(QString pass) {
  return this->w.auth(pass.toStdString());
}

QString QmlSystem::getWalletSeed(QString pass) {
  std::string passStr = pass.toStdString();
  bip3x::Bip39Mnemonic::MnemonicResult mnemonic;
  std::pair<bool,std::string> seedSuccess = BIP39::loadEncryptedMnemonic(mnemonic, passStr);
  return (seedSuccess.first) ? QString::fromStdString(mnemonic.raw) : "";
}

QVariantMap QmlSystem::checkForLedger() {
  QVariantMap ret;
  std::pair<bool, std::string> check = this->ledgerDevice.checkForDevice();
  ret.insert("state", check.first);
  ret.insert("message", QString::fromStdString(check.second));
  return ret;
}

bool QmlSystem::seedIsValid(QString seed) {
  std::stringstream ss(seed.toStdString());
  std::string word;
  int ct = 0;
  while (std::getline(ss, word, ' ')) {
    if (!BIP39::wordExists(word)) { return false; }
    ct++;
  }
  if (ct != 12) { return false; }
  return true;
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
