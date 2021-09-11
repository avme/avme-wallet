// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

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

QString QmlSystem::weiToFixedPoint(QString amount, int digits) {
  return QString::fromStdString(
    Utils::weiToFixedPoint(amount.toStdString(), digits)
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

QString QmlSystem::getConfigValue(QString key) {
  return QString::fromStdString(this->w.getConfigValue(key.toStdString()));
}

bool QmlSystem::setConfigValue(QString key, QString value) {
  return this->w.setConfigValue(key.toStdString(), value.toStdString());
}

std::string QmlSystem::handleServer(std::string input) {
  std::string response;
  // TODO: treat input here
  return response;
}

