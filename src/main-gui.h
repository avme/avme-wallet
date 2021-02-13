#ifndef MAIN_GUI_H
#define MAIN_GUI_H

#include <QtWidgets/QApplication>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtCore/QString>
#include <QtCore/QVariant>
#include <QtCore/qplugin.h>
#include <QtGui/QClipboard>
#include <QtGui/QFont>

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

  signals:
    void walletFirstLoad();
    void txStart(QString pass);
    void txBuilt(bool b);
    void txSigned(bool b);
    void txSent(bool b);
    void txRetry();

  private:
    WalletManager wm;
    bool firstLoad;
    std::string currentCoin;
    int currentCoinDecimals;
    std::string currentToken;
    int currentTokenDecimals;
    bool txTokenFlag;
    std::string txSenderAccount;
    std::string txSenderCoinAmount;
    std::string txSenderTokenAmount;
    std::string txReceiverAccount;
    std::string txReceiverCoinAmount;
    std::string txReceiverTokenAmount;
    std::string txGasLimit;
    std::string txGasPrice;

  public:
    // Getters/Setters for private vars
    Q_INVOKABLE bool getFirstLoad() { return this->firstLoad; }
    Q_INVOKABLE void setFirstLoad(bool b) { this->firstLoad = b; }

    Q_INVOKABLE QString getCurrentCoin() { return QString::fromStdString(this->currentCoin); }
    Q_INVOKABLE void setCurrentCoin(QString coin) { this->currentCoin = coin.toStdString(); }

    Q_INVOKABLE int getCurrentCoinDecimals() { return this->currentCoinDecimals; }
    Q_INVOKABLE void setCurrentCoinDecimals(int decimals) { this->currentCoinDecimals = decimals; }

    Q_INVOKABLE QString getCurrentToken() { return QString::fromStdString(this->currentToken); }
    Q_INVOKABLE void setCurrentToken(QString token) { this->currentToken = token.toStdString(); }

    Q_INVOKABLE int getCurrentTokenDecimals() { return this->currentTokenDecimals; }
    Q_INVOKABLE void setCurrentTokenDecimals(int decimals) { this->currentTokenDecimals = decimals; }

    Q_INVOKABLE bool getTxTokenFlag() { return this->txTokenFlag; }
    Q_INVOKABLE void setTxTokenFlag(bool b) { this->txTokenFlag = b; }

    Q_INVOKABLE QString getTxSenderAccount() { return QString::fromStdString(this->txSenderAccount); }
    Q_INVOKABLE void setTxSenderAccount(QString account) { this->txSenderAccount = account.toStdString(); }

    Q_INVOKABLE QString getTxSenderCoinAmount() { return QString::fromStdString(this->txSenderCoinAmount); }
    Q_INVOKABLE void setTxSenderCoinAmount(QString amount) { this->txSenderCoinAmount = amount.toStdString(); }

    Q_INVOKABLE QString getTxSenderTokenAmount() { return QString::fromStdString(this->txSenderTokenAmount); }
    Q_INVOKABLE void setTxSenderTokenAmount(QString amount) { this->txSenderTokenAmount = amount.toStdString(); }

    Q_INVOKABLE QString getTxReceiverAccount() { return QString::fromStdString(this->txReceiverAccount); }
    Q_INVOKABLE void setTxReceiverAccount(QString account) { this->txReceiverAccount = account.toStdString(); }

    Q_INVOKABLE QString getTxReceiverCoinAmount() { return QString::fromStdString(this->txReceiverCoinAmount); }
    Q_INVOKABLE void setTxReceiverCoinAmount(QString amount) { this->txReceiverCoinAmount = amount.toStdString(); }

    Q_INVOKABLE QString getTxReceiverTokenAmount() { return QString::fromStdString(this->txReceiverTokenAmount); }
    Q_INVOKABLE void setTxReceiverTokenAmount(QString amount) { this->txReceiverTokenAmount = amount.toStdString(); }

    Q_INVOKABLE QString getTxGasLimit() { return QString::fromStdString(this->txGasLimit); }
    Q_INVOKABLE void setTxGasLimit(QString limit) { this->txGasLimit = limit.toStdString(); }

    Q_INVOKABLE QString getTxGasPrice() { return QString::fromStdString(this->txGasPrice); }
    Q_INVOKABLE void setTxGasPrice(QString price) { this->txGasPrice = price.toStdString(); }

    // Force GUI update
    Q_INVOKABLE void updateScreen() { QApplication::processEvents(); }

    // Change the current loaded screen
    Q_INVOKABLE void setScreen(QObject* loader, QString qmlFile) {
      loader->setProperty("source", "qrc:/" + qmlFile);
    }

    // Copy a string to the system clipboard
    Q_INVOKABLE void copyToClipboard(QString str) {
      QApplication::clipboard()->setText(str);
    }

    // Store the Wallet password
    Q_INVOKABLE void storeWalletPass(QString pass) {
      wm.storeWalletPass(pass.toStdString());
    }

    // Check if given passphrase equals the Wallet's
    Q_INVOKABLE bool checkWalletPass(QString pass) {
      return wm.checkWalletPass(pass.toStdString());
    }

    // Create a new Wallet
    Q_INVOKABLE bool createNewWallet(
      QString walletFile, QString secretsPath, QString pass
    ) {
      return this->wm.createNewWallet(
        #ifdef __MINGW32__
          walletFile.remove("file:///").toStdString(),
          secretsPath.remove("file:///").toStdString(),
        #else
          walletFile.remove("file://").toStdString(),
          secretsPath.remove("file://").toStdString(),
        #endif
        pass.toStdString()
      );
    }

    // Load a Wallet
    Q_INVOKABLE bool loadWallet(
        QString walletFile, QString secretsPath, QString pass
        ) {
      return this->wm.loadWallet(
        #ifdef __MINGW32__
          walletFile.remove("file:///").toStdString(),
          secretsPath.remove("file:///").toStdString(),
        #else
          walletFile.remove("file://").toStdString(),
          secretsPath.remove("file://").toStdString(),
        #endif
        pass.toStdString()
      );
    }

    // Load the Wallet's accounts
    Q_INVOKABLE void loadWalletAccounts(bool start) {
      this->wm.loadWalletAccounts(start);
    }

    // Reload the Accounts' balances
    Q_INVOKABLE void reloadAccountsBalances() {
      this->wm.reloadAccountsBalances();
    }

    // List the Wallet's Accounts
    Q_INVOKABLE QVariantList listAccounts() {
      QVariantList ret;
      std::string delim = " ";
      std::vector<WalletAccount> walist;

      walist = this->wm.ReadWriteWalletVector(false, false, {});
      for (WalletAccount wa : walist) {
        std::string obj;
        obj += "{\"account\": \"" + wa.address;
        obj += "\", \"name\": \"" + wa.name;
        obj += "\", \"coinAmount\": \"" + wa.balanceAVAX;
        obj += "\", \"tokenAmount\": \"" + wa.balanceTAEX;
        obj += "\"}";
        ret << QString::fromStdString(obj);
      }

      return ret;
    }

    // Create a new Account
    Q_INVOKABLE bool createNewAccount(QString name, QString pass) {
      WalletAccount wa = this->wm.createNewAccount(name.toStdString(), pass.toStdString());
      return !wa.id.empty();
    }

    // Erase an Account
    Q_INVOKABLE bool eraseAccount(QString account) {
      return this->wm.eraseAccount(account.toStdString());
    }

    // Check if Account exists
    Q_INVOKABLE bool accountExists(QString account) {
      return this->wm.accountExists(account.toStdString());
    }

    // Get an Account's private keys
    Q_INVOKABLE QString getPrivateKeys(QString account, QString pass) {
      Secret s = wm.getSecret(account.toStdString(), pass.toStdString());
      std::string key = toHex(s.ref());
      return QString::fromStdString(key);
    }

    // Get gas price from network
    Q_INVOKABLE QString getAutomaticFee() {
      return QString::fromStdString(this->wm.getAutomaticFee());
    }

    // Create a RegExp for coin and token transaction amount input, respectively
    Q_INVOKABLE QRegExp createCoinRegExp() {
      QRegExp rx;
      rx.setPattern("[0-9]{1,}\\.[0-9]{1," + QString::number(this->currentCoinDecimals) + "}");
      return rx;
    }

    Q_INVOKABLE QRegExp createTokenRegExp() {
      QRegExp rx;
      rx.setPattern("[0-9]{1,}\\.[0-9]{1," + QString::number(this->currentTokenDecimals) + "}");
      return rx;
    }

    /**
     * Calculate the total cost of a transaction.
     * Calculation is done with values converted to Wei, while the result
     * is converted back to fixed point.
     */
    Q_INVOKABLE QString calculateTransactionCost(
      QString amount, QString gasLimit, QString gasPrice
    ) {
      std::string amountStr = this->wm.convertFixedPointToWei(amount.toStdString(), 18);  // Fixed point, so 10^18 Wei
      std::string gasLimitStr = gasLimit.toStdString(); // Already in Wei
      std::string gasPriceStr = this->wm.convertFixedPointToWei(gasPrice.toStdString(), 9); // Gwei, so 10^9 Wei
      u256 amountU256 = u256(amountStr);
      u256 gasLimitU256 = u256(gasLimitStr);
      u256 gasPriceU256 = u256(gasPriceStr);
      u256 totalU256 = amountU256 + gasLimitU256 + gasPriceU256;
      // Uncomment to see the values in Wei
      //std::cout << "Total: " << totalU256 << std::endl;
      //std::cout << "Amount: " << amountU256 << std::endl;
      //std::cout << "Gas Limit: " << gasLimitU256 << std::endl;
      //std::cout << "Gas Price: " << gasPriceU256 << std::endl;
      std::string totalStr = this->wm.convertWeiToFixedPoint(
        boost::lexical_cast<std::string>(totalU256), 18
      );
      return QString::fromStdString(totalStr);
    }

    // Check for insufficient funds in coin and token transactions, respectively
    Q_INVOKABLE bool hasInsufficientCoinFunds(QString senderAmount, QString receiverAmount) {
      std::string senderStr, receiverStr;
      u256 senderU256, receiverU256;
      senderStr = this->wm.convertFixedPointToWei(senderAmount.toStdString(), this->currentCoinDecimals);
      receiverStr = this->wm.convertFixedPointToWei(receiverAmount.toStdString(), this->currentCoinDecimals);
      senderU256 = u256(senderStr);
      receiverU256 = u256(receiverStr);
      return (receiverU256 > senderU256);
    }

    Q_INVOKABLE bool hasInsufficientTokenFunds(QString senderAmount, QString receiverAmount) {
      std::string senderStr, receiverStr;
      u256 senderU256, receiverU256;
      senderStr = this->wm.convertFixedPointToWei(senderAmount.toStdString(), this->currentTokenDecimals);
      receiverStr = this->wm.convertFixedPointToWei(receiverAmount.toStdString(), this->currentTokenDecimals);
      senderU256 = u256(senderStr);
      receiverU256 = u256(receiverStr);
      return (receiverU256 > senderU256);
    }

    // Make a coin or token transaction with the collected data
    Q_INVOKABLE QString makeTransaction(QString pass) {
      // Part 1: Build
      // Remember gas price is in Gwei (10^9 Wei) and amount is in fixed point,
      // we have to convert both to Wei.
      TransactionSkeleton txSkel;
      if (this->txTokenFlag) {  // Token tx
        this->txReceiverTokenAmount = wm.convertFixedPointToWei(
          this->txReceiverTokenAmount, this->currentTokenDecimals
        );
        this->txGasPrice = boost::lexical_cast<std::string>(
          boost::lexical_cast<u256>(this->txGasPrice) * raiseToPow(10, 9)
        );
        txSkel = wm.buildTAEXTransaction(
          this->txSenderAccount, this->txReceiverAccount, this->txReceiverTokenAmount,
          this->txGasLimit, this->txGasPrice
        );
      } else {  // Coin tx
        this->txReceiverCoinAmount = wm.convertFixedPointToWei(
          this->txReceiverCoinAmount, this->currentCoinDecimals
        );
        this->txGasPrice = boost::lexical_cast<std::string>(
          boost::lexical_cast<u256>(this->txGasPrice) * raiseToPow(10, 9)
        );
        txSkel = wm.buildAVAXTransaction(
          this->txSenderAccount, this->txReceiverAccount, this->txReceiverCoinAmount,
          this->txGasLimit, this->txGasPrice
        );
      }
      if (txSkel.nonce != wm.MAX_U256_VALUE()) {
        emit txBuilt(true);
      } else {
        emit txBuilt(false);
        return "";
      }

      // Part 2: Sign
      std::string signedTx = wm.signTransaction(txSkel, pass.toStdString(), this->txSenderAccount);
      if (!signedTx.empty()) {
        emit txSigned(true);
      } else {
        emit txSigned(false);
        return "";
      }

      // Part 3: Send
      std::string txLink = wm.sendTransaction(signedTx);
      if (txLink.empty()) {
        emit txSent(false);
        return "";
      }
      while (txLink.find("Transaction nonce is too low") != std::string::npos ||
          txLink.find("Transaction with the same hash was already imported") != std::string::npos) {
        emit txRetry();
        txSkel.nonce++;
        signedTx = wm.signTransaction(txSkel, pass.toStdString(), this->txSenderAccount);
        txLink = wm.sendTransaction(signedTx);
      }
      emit txSent(true);
      wm.reloadAccountsBalances();
      return QString::fromStdString(txLink);
    }
};

#endif // MAIN_GUI_H
