#ifndef MAIN_GUI_H
#define MAIN_GUI_H

#include <QtWidgets/QApplication>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtCore/QString>
#include <QtCore/QVariant>
//#include <QtCore/QJsonObject>
//#include <QtCore/QJsonDocument>
//#include <QtCore/QJsonArray>
#include <QtCore/qplugin.h>

#ifdef __MINGW32__
Q_IMPORT_PLUGIN(QWindowsIntegrationPlugin)
#else
Q_IMPORT_PLUGIN(QXcbIntegrationPlugin)
#endif
Q_IMPORT_PLUGIN(QtQuick2Plugin)
Q_IMPORT_PLUGIN(QtQuick2WindowPlugin)
Q_IMPORT_PLUGIN(QtQuickTemplates2Plugin)
Q_IMPORT_PLUGIN(QtQuickControls2Plugin)
Q_IMPORT_PLUGIN(QtLabsPlatformPlugin)

#include "lib/wallet.h"

// QObject/wrapper for interfacing between C++ (wallet) and QML (gui)
class System : public QObject {
  Q_OBJECT

  private:
    WalletManager wm;

  public:
    // Change the current loaded screen
    Q_INVOKABLE void setScreen(QObject* loader, QString qmlFile) {
      loader->setProperty("source", "qrc:/" + qmlFile);
    }

    // Create a new Wallet
    Q_INVOKABLE bool createNewWallet(
      QString walletFile, QString secretsPath, QString walletPass
    ) {
      return this->wm.createNewWallet(
        walletFile.remove("file://").toStdString(),
        secretsPath.remove("file://").toStdString(),
        walletPass.toStdString()
      );
    }

    // Load a Wallet
    Q_INVOKABLE bool loadWallet(
      QString walletFile, QString secretsPath, QString walletPass
    ) {
      return this->wm.loadWallet(
        walletFile.remove("file://").toStdString(),
        secretsPath.remove("file://").toStdString(),
        walletPass.toStdString()
      );
    }

    // List the Wallet's Accounts
    Q_INVOKABLE QVariantList listAccounts(QString type) {
      QVariantList ret;
      std::string delim = " ";
      std::vector<WalletAccount> walist;

      if (type == "eth") {
        walist = this->wm.listETHAccounts();
        for (WalletAccount wa : walist) {
          std::string obj = "{\"account\": \"" + wa.address + "\", \"amount\": \"" + wa.balanceETH + "\"}";
          ret << QString::fromStdString(obj);
        }
      } else if (type == "taex") {
        walist = this->wm.listTAEXAccounts();
        for (WalletAccount wa : walist) {
          std::string obj = "{\"account\": \"" + wa.address + "\", \"amount\": \"" + wa.balanceTAEX + "\"}";
          ret << QString::fromStdString(obj);
        }
      }

      return ret;
    }
};

#endif // MAIN_GUI_H
