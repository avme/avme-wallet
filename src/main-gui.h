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

Q_IMPORT_PLUGIN(QXcbIntegrationPlugin)
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
    std::string walletPass;

  public:
    // Change the current loaded screen
    Q_INVOKABLE void setScreen(QObject* loader, QString qmlFile) {
      loader->setProperty("source", "qrc:/" + qmlFile);
    }

    // Get/Set wallet password
    Q_INVOKABLE QString getWalletPass() {
      return QString::fromStdString(this->walletPass);
    }

    Q_INVOKABLE void setWalletPass(QString pass) {
      this->walletPass = pass.toStdString();
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
          std::string obj;
          obj += "{\"name\": \"" + wa.name;
          obj += "\", \"account\": \"" + wa.address;
          obj += "\", \"amount\": \"" + wa.balanceETH + "\"}";
          ret << QString::fromStdString(obj);
        }
      } else if (type == "taex") {
        walist = this->wm.listTAEXAccounts();
        for (WalletAccount wa : walist) {
          std::string obj;
          obj += "{\"name\": \"" + wa.name;
          obj += "\", \"account\": \"" + wa.address;
          obj += "\", \"amount\": \"" + wa.balanceTAEX + "\"}";
          ret << QString::fromStdString(obj);
        }
      }

      return ret;
    }

    // Create a new Account
    Q_INVOKABLE bool createNewAccount(
      QString name, QString pass, QString hint, bool usesMasterPass
    ) {
      WalletAccount wa = this->wm.createNewAccount(
        name.toStdString(), pass.toStdString(), hint.toStdString(), usesMasterPass
      );
      return !wa.id.empty();
    }

    // Erase an Account
    Q_INVOKABLE bool eraseAccount(QString account) {
      return this->wm.eraseAccount(account.toStdString());
    }
};

#endif // MAIN_GUI_H
