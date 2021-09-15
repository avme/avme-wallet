// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

void QmlSystem::downloadAppList() {
  QtConcurrent::run([=](){
    boost::filesystem::path filePath = Utils::walletFolderPath.string()
      + "/wallet/c-avax/applist.json";
    // Force download the list every time
    if (boost::filesystem::exists(filePath)) { boost::filesystem::remove(filePath); }
    API::httpGetFile(
      "raw.githubusercontent.com",
      "/avme/avme-wallet-applications/main/applist.json",
      filePath.string() + "/applist.json"
    );
    if (boost::filesystem::exists(filePath)) {
      emit appListDownloaded();
    } else {
      emit appListDownloadFailed();
    }
  });
}

QVariantList QmlSystem::loadAppsFromList() {
  QVariantList ret;
  json applist = json::parse(Utils::readJSONFile(
    Utils::walletFolderPath.string() + "/wallet/c-avax/applist.json"
  ));
  json apps = applist["apps"];
  for (auto& app : apps) {
    QVariantMap appObj;
    appObj["chainId"] = app["chainId"].get<int>();
    appObj["folder"] = QString::fromStdString(app["folder"].get<std::string>());
    appObj["name"] = QString::fromStdString(app["name"].get<std::string>());
    appObj["major"] = app["major"].get<int>();
    appObj["minor"] = app["minor"].get<int>();
    appObj["patch"] = app["patch"].get<int>();
    ret << appObj;
  }
  return ret;
}

QVariantList QmlSystem::loadInstalledApps() {
  QVariantList ret;
  json apps = this->w.getInstalledApps();
  for (auto& app : apps) {
    QVariantMap appObj;
    appObj["chainId"] = app["chainId"].get<int>();
    appObj["folder"] = QString::fromStdString(app["folder"].get<std::string>());
    appObj["name"] = QString::fromStdString(app["name"].get<std::string>());
    appObj["major"] = app["major"].get<int>();
    appObj["minor"] = app["minor"].get<int>();
    appObj["patch"] = app["patch"].get<int>();
    ret << appObj;
  }
  return ret;
}

bool QmlSystem::appIsInstalled(QString folder) {
  return this->w.appIsInstalled(folder.toStdString());
}

bool QmlSystem::installApp(QVariantMap data) {
  return this->w.installApp(
    data["chainId"].toInt(), data["folder"].toString().toStdString(),
    data["name"].toString().toStdString(), data["major"].toInt(),
    data["minor"].toInt(), data["patch"].toInt()
  );
}

bool QmlSystem::uninstallApp(QString folder) {
  return this->w.uninstallApp(folder.toStdString());
}

