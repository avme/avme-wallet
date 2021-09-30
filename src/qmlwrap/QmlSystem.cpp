// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

QString QmlSystem::getLastWalletPath() {
  QString path = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
  if (path.isEmpty()) return "";
  boost::filesystem::path walletPath = path.toStdString() + "/lastWallet.json";
  if (!boost::filesystem::exists(walletPath)) return "";
  boost::filesystem::path lastWallet = json::parse(
    Utils::readJSONFile(walletPath)
  )["path"].get<std::string>();
  if (!boost::filesystem::exists(lastWallet)) { return ""; }
  return QString::fromStdString(lastWallet.string());
}

bool QmlSystem::saveLastWalletPath() {
  QString path = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
  if (path.isEmpty()) return false;
  boost::filesystem::path walletPath = path.toStdString() + "/lastWallet.json";
  if (!boost::filesystem::exists(walletPath.parent_path())) {
    boost::filesystem::create_directories(walletPath.parent_path());
  };
  if (boost::filesystem::exists(walletPath)) { boost::filesystem::remove(walletPath); }
  json lastWallet = json::object();
  lastWallet["path"] = Utils::walletFolderPath.string();
  return (Utils::writeJSONFile(lastWallet, walletPath) == "");
}

bool QmlSystem::deleteLastWalletPath() {
  QString path = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
  return boost::filesystem::remove(path.toStdString() + "/lastWallet.json");
}

QString QmlSystem::getProjectVersion() {
  return QString::fromStdString(PROJECT_VERSION);
}

void QmlSystem::openQtAbout() {
  QApplication::aboutQt();
}

void QmlSystem::setScreen(QObject* loader, QString qmlFile) {
  loader->setProperty("source", "qrc:/" + qmlFile);
}

void QmlSystem::setLocalScreen(QObject* loader, QString qmlFile) {
  loader->setProperty(
    "source", "file:" + qmlFile
  );
}

void QmlSystem::copyToClipboard(QString str) {
  QApplication::clipboard()->setText(str);
}

QStringList QmlSystem::copySeedFromClipboard() {
  return QApplication::clipboard()->text().split(" ");
}

QString QmlSystem::getDefaultWalletPath() {
  return QString::fromStdString(Utils::getDataDir().string());
}

QString QmlSystem::cleanPath(QString path) {
  #ifdef __MINGW32__
    return path.remove("file:///");
  #else
    return path.remove("file://");
  #endif
}

QString QmlSystem::fixedPointToWei(QString amount, int decimals) {
  return QString::fromStdString(
    Utils::fixedPointToWei(amount.toStdString(), decimals)
  );
}

QString QmlSystem::weiToFixedPoint(QString amount, int decimals) {
  return QString::fromStdString(
    Utils::weiToFixedPoint(amount.toStdString(), decimals)
  );
}

bool QmlSystem::balanceIsZero(QString amount, int decimals) {
  u256 amountU256 = u256(Utils::fixedPointToWei(amount.toStdString(), decimals));
  return (amountU256 == 0);
}

bool QmlSystem::firstHigherThanSecond(QString first, QString second) {
  bigfloat firstFloat = boost::lexical_cast<bigfloat>(first.toStdString());
  bigfloat secondFloat = boost::lexical_cast<bigfloat>(second.toStdString());
  return (firstFloat > secondFloat);
}

QString QmlSystem::getContract(QString name) {
  return QString::fromStdString(Pangolin::contracts[name.toStdString()]);
}

void QmlSystem::storePass(QString pass) {
  int minutes = std::stoi(this->w.getConfigValue("storePass"));
  std::time_t deadline = std::time(nullptr) + (minutes * 60); // std::time is in seconds
  this->w.startPassThread(pass.toStdString(), deadline);
}

QString QmlSystem::retrievePass() {
  return QString::fromStdString(this->w.getStoredPass());
}

void QmlSystem::resetPass() {
  this->w.stopPassThread();
}

void QmlSystem::checkIfUrlExists(QUrl url) {
  // Adapted from https://stackoverflow.com/a/28498623
  QtConcurrent::run([=](){
    bool ret = false;
    QSslSocket sck;
    sck.connectToHostEncrypted(url.host(), 443);
    if (sck.waitForConnected()) {
      sck.write(
        "HEAD " + url.path().toUtf8() + " HTTP/1.1\r\n"
        "Host: " + url.host().toUtf8() + "\r\n\r\n"
      );
      if (sck.waitForReadyRead()) { ret = sck.readAll().contains("200 OK"); }
    }
    emit urlChecked(url.url(), ret);
  });
}

QString QmlSystem::getConfigValue(QString key) {
  return QString::fromStdString(this->w.getConfigValue(key.toStdString()));
}

bool QmlSystem::setConfigValue(QString key, QString value) {
  return this->w.setConfigValue(key.toStdString(), value.toStdString());
}

