// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

bool QmlSystem::checkFolderForWallet(QString folder) {
  QString walletFile = QString(folder + "/wallet/c-avax/wallet.info");
  QString secretsFolder = QString(folder + "/wallet/c-avax/accounts/secrets");
  return (QFile::exists(walletFile) && QFile::exists(secretsFolder));
}

void QmlSystem::createWallet(QString folder, QString pass, QString seed) {
  QtConcurrent::run([=](){
    std::string folderStr = folder.toStdString();
    std::string passStr = pass.toStdString();
    std::string seedStr = seed.toStdString();
    bip3x::Bip39Mnemonic::MnemonicResult mnemonic;
    bool createSuccess = this->w.create(folderStr, passStr);
    if (seedStr.empty()) {
      mnemonic = BIP39::createNewMnemonic();
    } else {
      mnemonic.raw = seedStr;
    }
    std::pair<bool,std::string> seedSuccess = BIP39::saveEncryptedMnemonic(mnemonic, passStr);
    emit walletCreated(createSuccess && seedSuccess.first);
  });
}

void QmlSystem::loadWallet(QString folder, QString pass) {
  QtConcurrent::run([=](){
    std::string passStr = pass.toStdString();
    bool loadSuccess = this->w.load(folder.toStdString(), passStr);
    emit walletLoaded(loadSuccess);
  });
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
  if (ct != 12 && ct != 24) { return false; }
  return true;
}

bool QmlSystem::checkForApp(QString folder) {
  QString appFile = QString(folder + "/main.qml");
  return QFile::exists(appFile);
}
