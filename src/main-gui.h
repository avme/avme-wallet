#ifndef MAIN_GUI_H
#define MAIN_GUI_H

#include <QtWidgets/QApplication>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtCore/QString>
#include <QtCore/QVariant>
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

  signals:
    void txBuilt(bool b);
    void txSigned(bool b);
    void txSent(bool b);

  private:
    WalletManager wm;
    std::string walletPass;
    std::string txSenderAccount;
    std::string txSenderAmount;
    std::string txReceiverAccount;
    std::string txAmount;
    std::string txLabel;
    std::string txGasLimit;
    std::string txGasPrice;

  public:
    // Getters/Setters for private vars
    Q_INVOKABLE QString getWalletPass() {
      return QString::fromStdString(this->walletPass);
    }

    Q_INVOKABLE void setWalletPass(QString pass) {
      this->walletPass = pass.toStdString();
    }

    Q_INVOKABLE QString getTxSenderAccount() {
      return QString::fromStdString(this->txSenderAccount);
    }

    Q_INVOKABLE void setTxSenderAccount(QString account) {
      this->txSenderAccount = account.toStdString();
    }

    Q_INVOKABLE QString getTxSenderAmount() {
      return QString::fromStdString(this->txSenderAmount);
    }

    Q_INVOKABLE void setTxSenderAmount(QString amount) {
      this->txSenderAmount = amount.toStdString();
    }

    Q_INVOKABLE QString getTxReceiverAccount() {
      return QString::fromStdString(this->txReceiverAccount);
    }

    Q_INVOKABLE void setTxReceiverAccount(QString account) {
      this->txReceiverAccount = account.toStdString();
    }

    Q_INVOKABLE QString getTxAmount() {
      return QString::fromStdString(this->txAmount);
    }

    Q_INVOKABLE void setTxAmount(QString amount) {
      this->txAmount = amount.toStdString();
    }

    Q_INVOKABLE QString getTxLabel() {
      return QString::fromStdString(this->txLabel);
    }

    Q_INVOKABLE void setTxLabel(QString label) {
      this->txLabel = label.toStdString();
    }

    Q_INVOKABLE QString getTxGasLimit() {
      return QString::fromStdString(this->txGasLimit);
    }

    Q_INVOKABLE void setTxGasLimit(QString limit) {
      this->txGasLimit = limit.toStdString();
    }

    Q_INVOKABLE QString getTxGasPrice() {
      return QString::fromStdString(this->txGasPrice);
    }

    Q_INVOKABLE void setTxGasPrice(QString price) {
      this->txGasPrice = price.toStdString();
    }

    // Change the current loaded screen
    Q_INVOKABLE void setScreen(QObject* loader, QString qmlFile) {
      loader->setProperty("source", "qrc:/" + qmlFile);
    }

    // Check if given passphrase equals the wallet's
    Q_INVOKABLE bool checkWalletPass(QString pass) {
      return (pass.toStdString() == this->walletPass);
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

    // Get gas price from network
    Q_INVOKABLE QString getAutomaticFee() {
      return QString::fromStdString(this->wm.getAutomaticFee());
    }

    // Make a transaction with the collected data
    // TODO: support tokens later on
    Q_INVOKABLE QString makeTransaction() {
      // Part 1: Build
      // Remember txGasPrice is in Gwei and txAmount is in fixed point,
      // we have to convert both to Wei.
      this->txAmount = wm.convertFixedPointToWei(this->txAmount, 18);
      this->txGasPrice = boost::lexical_cast<std::string>(
        boost::lexical_cast<u256>(this->txGasPrice) * raiseToPow(10, 9)
      );
      TransactionSkeleton txSkel = wm.buildETHTransaction(
        this->txSenderAccount, this->txReceiverAccount, this->txAmount,
        this->txGasLimit, this->txGasPrice
      );
      if (txSkel.nonce != wm.MAX_U256_VALUE()) {
        emit txBuilt(true);
      } else {
        emit txBuilt(false);
        return "";
      }

      // Part 2: Sign
      // TODO: see if checking for empty string is really the right way to know
      // whether the function worked or not
      std::string signedTx = wm.signTransaction(
        txSkel, this->walletPass, this->txSenderAccount
      );
      if (!signedTx.empty()) {
        emit txSigned(true);
      } else {
        emit txSigned(false);
        return "";
      }

      // Part 3: Send
      // TODO: maybe show on screen "Trying again with a higher nonce"?
      std::string txLink = wm.sendTransaction(signedTx);
      if (txLink.empty()) {
        emit txSent(false);
        return "";
      }
      while (txLink.find("Transaction nonce is too low") != std::string::npos ||
          txLink.find("Transaction with the same hash was already imported") != std::string::npos) {
        txSkel.nonce++;
        signedTx = wm.signTransaction(
          txSkel, this->walletPass, this->txSenderAccount
        );
        txLink = wm.sendTransaction(signedTx);
      }
      emit txSent(true);
      return QString::fromStdString(txLink);
    }
};

#endif // MAIN_GUI_H
