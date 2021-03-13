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
#include <QtCore/QThread>
#include <QtConcurrent/qtconcurrentrun.h>

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
    void refreshAccountList();
    void accountCreated(QVariantMap data);
    void accountsGenerated(QVariantList data, QString seed);
    void accountImported(bool success);

    void walletFirstLoad();
    void txStart(QString pass);
    void txBuilt(bool b);
    void txSigned(bool b);
    void txSent(bool b, QString linkUrl);
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
    std::string txSenderLPFreeAmount;
    std::string txSenderLPLockedAmount;
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

    Q_INVOKABLE QString getTxSenderLPFreeAmount() { return QString::fromStdString(this->txSenderLPFreeAmount); }
    Q_INVOKABLE void setTxSenderLPFreeAmount(QString amount) { this->txSenderLPFreeAmount = amount.toStdString(); }

    Q_INVOKABLE QString getTxSenderLPLockedAmount() { return QString::fromStdString(this->txSenderLPLockedAmount); }
    Q_INVOKABLE void setTxSenderLPLockedAmount(QString amount) { this->txSenderLPLockedAmount = amount.toStdString(); }

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

    // Refresh Account list
    Q_INVOKABLE void refreshAccounts() {
      QtConcurrent::run([=](){ QThread::msleep(10); emit refreshAccountList(); });
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
        obj += "\", \"tokenAmount\": \"" + wa.balanceAVME;
        obj += "\", \"freeLPAmount\": \"" + wa.balanceLPFree;
        obj += "\", \"lockedLPAmount\": \"" + wa.balanceLPLocked;
        obj += "\"}";
        ret << QString::fromStdString(obj);
      }

      return ret;
    }

    // Create a new Account
    Q_INVOKABLE void createNewAccount(QString name, QString pass) {
      QtConcurrent::run([=]() {
        QVariantMap waObj;
        QVariantList waSeed;
        WalletAccount wa;
        wa = this->wm.createNewAccount(name.toStdString(), pass.toStdString());
        if (!wa.id.empty()) {
          waObj.insert("accId", QString::fromStdString(wa.id));
          waObj.insert("accName", QString::fromStdString(wa.name));
          waObj.insert("accAddress", QString::fromStdString(wa.address));
          for (std::string word : wa.seed) { waSeed << QString::fromStdString(word); }
          waObj.insert("accSeed", waSeed);
        }
        emit accountCreated(waObj);
      });
    }

    // Erase an Account
    Q_INVOKABLE bool eraseAccount(QString account) {
      return this->wm.eraseAccount(account.toStdString());
    }

    // Check if Account exists
    Q_INVOKABLE bool accountExists(QString account) {
      return this->wm.accountExists(account.toStdString());
    }

    // List the Account's transactions
    Q_INVOKABLE QVariantList listAccountTransactions(QString address) {
      QVariantList ret;
      TransactionList tl(address.toStdString());

      for (int i = 0; i < tl.getTransactionListSize(); i++) {
        WalletTxData tx = tl.getTransactionData(i);
        std::string obj;
        obj += "{\"txlink\": \"" + tx.txlink;
        obj += "\", \"operation\": \"" + tx.operation;
        obj += "\", \"txdata\": \"" + tx.data;
        obj += "\", \"from\": \"" + tx.from;
        obj += "\", \"to\": \"" + tx.to;
        obj += "\", \"value\": \"" + tx.value;
        obj += "\", \"gas\": \"" + tx.gas;
        obj += "\", \"price\": \"" + tx.price;
        obj += "\", \"datetime\": \"" + tx.humanDate;
        obj += "\", \"unixtime\": " + std::to_string(tx.unixDate);
        obj += ", \"confirmed\": " + QVariant(tx.confirmed).toString().toStdString();
        obj += "}";
        ret << QString::fromStdString(obj);
      }

      return ret;
    }

    // Get an Account's private keys
    Q_INVOKABLE QString getPrivateKeys(QString account, QString pass) {
      Secret s = wm.getSecret(account.toStdString(), pass.toStdString());
      std::string key = toHex(s.ref());
      return QString::fromStdString(key);
    }

    // Check if Account seed is valid
    Q_INVOKABLE bool seedIsValid(QString seed) {
      std::stringstream ss(seed.toStdString());
      std::string word;
      int ct = 0;

      while (std::getline(ss, word, ' ')) {
        if (!wm.wordExists(word)) { return false; }
        ct++;
      }
      if (ct != 12) { return false; }

      return true;
    }

    // Generate Accounts with a seed
    Q_INVOKABLE void generateAccountsFromSeed(QString seed) {
      QtConcurrent::run([=]() {
        std::stringstream seedss(seed.toStdString());
        std::string word, derivPath;
        std::vector<std::string> words, mnemonicPhrase, accountsList;
        bip3x::Bip39Mnemonic::MnemonicResult encodedMnemonic;
        bip3x::HDKey rootKey;
        QVariantList ret;

        derivPath = "m/44'/60'/0'/0/";
        while (std::getline(seedss, word, ' ')) { words.push_back(word); }
        for (std::string word : words) { mnemonicPhrase.push_back(word); }
        encodedMnemonic.words = mnemonicPhrase;
        rootKey = wm.createBip32RootKey(encodedMnemonic);
        accountsList = wm.addressListBasedOnRootIndex(rootKey, 0);

        for (auto v : accountsList) {
          std::stringstream listss(v);
          std::string item, obj;
          int ct = 0;
          while (std::getline(listss, item, ' ')) {
            switch (ct) {
              case 0: obj += "{\"index\": \"" + item; break;
              case 1: obj += "\", \"account\": \"" + item; break;
              case 2: obj += "\", \"balance\": \"" + item; break;
            }
            ct++;
          }
          obj += "\"}";
          ret << QString::fromStdString(obj);
        }

        emit accountsGenerated(ret, seed);
      });
    }

    // Import an Account generated by a seed
    Q_INVOKABLE void importAccount(QString seed, int idx, QString name, QString pass) {
      QtConcurrent::run([=]() {
        std::stringstream seedss(seed.toStdString());
        std::string word;
        std::vector<std::string> words;
        std::vector<std::string> mnemonicPhrase;
        std::string derivPath = "m/44'/60'/0'/0/";
        while (std::getline(seedss, word, ' ')) { words.push_back(word); }
        for (std::string word : words) { mnemonicPhrase.push_back(word); }

        bip3x::Bip39Mnemonic::MnemonicResult encodedMnemonic;
        encodedMnemonic.words = mnemonicPhrase;
        bip3x::HDKey rootKey = wm.createBip32RootKey(encodedMnemonic);
        derivPath += QString::number(idx).toStdString();
        bip3x::HDKey bip32Key = wm.createBip32Key(rootKey, derivPath);
        WalletAccount data = wm.importAccount(name.toStdString(), pass.toStdString(), bip32Key);
        emit accountImported(!data.id.empty());
      });
    }

    // Get gas price from network
    Q_INVOKABLE QString getAutomaticFee() {
      return QString::fromStdString(this->wm.getAutomaticFee());
    }

    // Create a RegExp for coin and token transaction amount input, respectively
    Q_INVOKABLE QRegExp createCoinRegExp() {
      QRegExp rx;
      rx.setPattern("[0-9]{1,}(?:\\.[0-9]{1," + QString::number(this->currentCoinDecimals) + "})?");
      return rx;
    }

    Q_INVOKABLE QRegExp createTokenRegExp() {
      QRegExp rx;
      rx.setPattern("[0-9]{1,}(?:\\.[0-9]{1," + QString::number(this->currentTokenDecimals) + "})?");
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
    Q_INVOKABLE void makeTransaction(QString pass) {
      QtConcurrent::run([=]() {
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
          txSkel = wm.buildAVMETransaction(
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
        emit txBuilt(txSkel.nonce != wm.MAX_U256_VALUE());

        // Part 2: Sign
        std::string signedTx = wm.signTransaction(txSkel, pass.toStdString(), this->txSenderAccount);
        emit txSigned(!signedTx.empty());

        // Part 3: Send
        std::string txLink = wm.sendTransaction(signedTx);
        if (txLink.empty()) { emit txSent(false, ""); }
        while (txLink.find("Transaction nonce is too low") != std::string::npos ||
            txLink.find("Transaction with the same hash was already imported") != std::string::npos) {
          emit txRetry();
          txSkel.nonce++;
          signedTx = wm.signTransaction(txSkel, pass.toStdString(), this->txSenderAccount);
          txLink = wm.sendTransaction(signedTx);
        }
        emit txSent(true, QString::fromStdString(txLink));
      });
    }
};

#endif // MAIN_GUI_H
