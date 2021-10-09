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
      filePath.string()
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
  json apps = this->w.getRegisteredApps();
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

QString QmlSystem::getAppFolderPath(int chainId, QString folder) {
  return QString::fromStdString(
    Utils::walletFolderPath.string() + "/wallet/c-avax/apps/"
    + std::to_string(chainId) + "/" + folder.toStdString()
  );
}

bool QmlSystem::appIsInstalled(QString folder) {
  return this->w.appIsRegistered(folder.toStdString());
}

void QmlSystem::installApp(QVariantMap data) {
  QtConcurrent::run([=](){
    // Retrieve DApp info
    json app;
    app["chainId"] = data["chainId"].toInt();
    app["folder"] = data["folder"].toString().toStdString();
    app["name"] = data["name"].toString().toStdString();
    app["major"] = data["major"].toInt();
    app["minor"] = data["minor"].toInt();
    app["patch"] = data["patch"].toInt();

    // Set up required variables
    boost::filesystem::path appPath = Utils::walletFolderPath.string()
      + "/wallet/c-avax/apps/" + std::to_string(app["chainId"].get<int>())
      + "/" + app["folder"].get<std::string>();
    if (!boost::filesystem::exists(appPath)) { boost::filesystem::create_directories(appPath); }
    json fileList = json::array();  // List of files to download
    int progress = 0, totalProgress = 0;  // Counters for file download progress
    int downloadRetries = 5;  // Attempts to download a file before giving up

    // Get the file list from files.json
    for (int i = 0; i < downloadRetries; i++) {
      boost::filesystem::path fileJsonPath = appPath.string() + "/files.json";
      API::httpGetFile(
        "raw.githubusercontent.com",
        "/avme/avme-wallet-applications/main/apps/"
          + std::to_string(app["chainId"].get<int>()) + "/"
          + app["folder"].get<std::string>() + "/files.json",
        fileJsonPath.string()
      );
      if (boost::filesystem::exists(fileJsonPath)) {
        if (!boost::filesystem::is_empty(fileJsonPath)) {
          json fileListJson = json::parse(Utils::readJSONFile(fileJsonPath))["files"];
          fileList.push_back("main.qml"); totalProgress++;
          fileList.push_back("icon.png"); totalProgress++;
          fileList.push_back("files.json"); totalProgress++;
          for (std::string file : fileListJson) { fileList.push_back(file); totalProgress++; }
          boost::filesystem::remove(fileJsonPath); // For progress calculation purposes
          break;
        } else {
          boost::filesystem::remove(fileJsonPath);
        }
      } else if (i == downloadRetries - 1) {  // Last retry failed
        boost::filesystem::remove_all(appPath);
        emit appInstalled(false);
        return;
      }
    }

    // Download all the files
    for (std::string file : fileList) {
      for (int i = 0; i < downloadRetries; i++) {
        boost::filesystem::path filePath = appPath.string() + "/" + file;
        if (!boost::filesystem::exists(filePath.parent_path())) {
          boost::filesystem::create_directories(filePath.parent_path());
        }
        API::httpGetFile(
          "raw.githubusercontent.com",
          "/avme/avme-wallet-applications/main/apps/"
            + std::to_string(app["chainId"].get<int>()) + "/"
            + app["folder"].get<std::string>() + "/" + file,
          filePath.string()
        );
        if (boost::filesystem::exists(filePath)) {
          if (!boost::filesystem::is_empty(filePath)) {
            emit appDownloadProgressUpdated(++progress, totalProgress);
            break;
          } else {
            boost::filesystem::remove(filePath);
          }
        } else if (i == downloadRetries - 1) {  // Last retry failed
          boost::filesystem::remove_all(appPath);
          emit appInstalled(false);
          return;
        }
      }
    }

    // Register the DApp in the database
    bool success = this->w.registerApp(
      app["chainId"].get<int>(), app["folder"].get<std::string>(),
      app["name"].get<std::string>(), app["major"].get<int>(),
      app["minor"].get<int>(), app["patch"].get<int>()
    );
    if (!success) { boost::filesystem::remove_all(appPath); }
    emit appInstalled(success);
  });
}

bool QmlSystem::uninstallApp(QVariantMap data) {
  // Retrieve DApp info
  json app;
  app["chainId"] = data["chainId"].toInt();
  app["folder"] = data["folder"].toString().toStdString();
  boost::filesystem::path appPath = Utils::walletFolderPath.string()
    + "/wallet/c-avax/apps/" + std::to_string(app["chainId"].get<int>())
    + "/" + app["folder"].get<std::string>();
  // Delete the DApp contents and unregister it from the database
  if (boost::filesystem::exists(appPath)) {
    boost::filesystem::remove_all(appPath); // Contents first...
    boost::filesystem::remove(appPath);     // ...then the proper folder
  }
  return this->w.unregisterApp(app["folder"].get<std::string>());
}

