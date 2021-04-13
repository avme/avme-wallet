#ifndef MAIN_GUI_H
#define MAIN_GUI_H

#include <QtWidgets/QApplication>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtCore/QFile>
#include <QtCore/QString>
#include <QtCore/QVariant>
#include <QtCore/qplugin.h>
#include <QtGui/QClipboard>
#include <QtGui/QFont>
#include <QtGui/QFontDatabase>
#include <QtGui/QIcon>
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

#include "lib/Account.h"
#include "lib/Network.h"
#include "lib/BIP39.h"
#include "lib/Pangolin.h"
#include "lib/Staking.h"
#include "lib/Utils.h"
#include "lib/Wallet.h"

// QObject/wrapper for interfacing between C++ (wallet) and QML (gui)
class System : public QObject {
  Q_OBJECT

  signals:
    void hideMenu();
    void walletLoaded();
    void accountChosen();
    void accountsGenerated(QVariantList accounts);
    void accountCreated(QVariantMap data);
    void accountCreationFailed();
    void txStart(QString pass);
    void txBuilt(bool b);
    void txSigned(bool b);
    void txSent(bool b, QString linkUrl);
    void txRetry();
    void allowancesUpdated(
      QString exchangeAllowance, QString liquidityAllowance, QString stakingAllowance
    );
    void exchangeDataUpdated(
      QString lowerTokenName, QString lowerTokenReserves,
      QString higherTokenName, QString higherTokenReserves
    );
    void liquidityDataUpdated(
      QString lowerTokenName, QString lowerTokenReserves,
      QString higherTokenName, QString higherTokenReserves,
      QString totalLiquidity
    );
    void rewardUpdated(QString poolReward);

  private:
    Wallet w;
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
    std::string txReceiverLPAmount;
    std::string txGasLimit;
    std::string txGasPrice;
    std::string txOperation;

  public:
    // Getters/Setters for private vars
    Q_INVOKABLE QString getCurrentCoin() { return QString::fromStdString(this->currentCoin); }
    Q_INVOKABLE void setCurrentCoin(QString coin) { this->currentCoin = coin.toStdString(); }

    Q_INVOKABLE bool getFirstLoad() { return this->firstLoad; }
    Q_INVOKABLE void setFirstLoad(bool b) { this->firstLoad = b; }

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

    Q_INVOKABLE QString getTxReceiverLPAmount() { return QString::fromStdString(this->txReceiverLPAmount); }
    Q_INVOKABLE void setTxReceiverLPAmount(QString amount) { this->txReceiverLPAmount = amount.toStdString(); }

    Q_INVOKABLE QString getTxGasLimit() { return QString::fromStdString(this->txGasLimit); }
    Q_INVOKABLE void setTxGasLimit(QString limit) { this->txGasLimit = limit.toStdString(); }

    Q_INVOKABLE QString getTxGasPrice() { return QString::fromStdString(this->txGasPrice); }
    Q_INVOKABLE void setTxGasPrice(QString price) { this->txGasPrice = price.toStdString(); }

    Q_INVOKABLE QString getTxOperation() { return QString::fromStdString(this->txOperation); }
    Q_INVOKABLE void setTxOperation(QString op) { this->txOperation = op.toStdString(); }

    // Change the current loaded screen
    Q_INVOKABLE void setScreen(QObject* loader, QString qmlFile) {
      loader->setProperty("source", "qrc:/" + qmlFile);
    }

    // Copy a string to the system clipboard
    Q_INVOKABLE void copyToClipboard(QString str) {
      QApplication::clipboard()->setText(str);
    }

    // Remove the "file://" prefix from a folder path
    Q_INVOKABLE QString cleanPath(QString path) {
      #ifdef __MINGW32__
        return path.remove("file:///");
      #else
        return path.remove("file://");
      #endif
    }

    // Check if a Wallet exists in a given folder
    Q_INVOKABLE bool checkFolderForWallet(QString folder) {
      QString walletFile = QString(folder + "/wallet/c-avax/wallet.info");
      QString secretsFolder = QString(folder + "/wallet/c-avax/accounts/secrets");
      return (QFile::exists(walletFile) && QFile::exists(secretsFolder));
    }

    // Check if given passphrase equals the Wallet's
    Q_INVOKABLE bool checkWalletPass(QString pass) {
      return w.auth(pass.toStdString());
    }

    // Create, import, load and close a Wallet, respectively
    Q_INVOKABLE bool createWallet(QString folder, QString pass) {
      std::string passStr = pass.toStdString();
      bool createSuccess = this->w.create(folder.toStdString(), passStr);
      bip3x::Bip39Mnemonic::MnemonicResult mnemonic = BIP39::createNewMnemonic();
      std::pair<bool,std::string> seedSuccess = BIP39::saveEncryptedMnemonic(mnemonic, passStr);
      return (createSuccess && seedSuccess.first);
    }

    Q_INVOKABLE bool importWallet(QString seed, QString folder, QString pass) {
      std::string passStr = pass.toStdString();
      bool createSuccess = this->w.create(folder.toStdString(), passStr);
      bip3x::Bip39Mnemonic::MnemonicResult mnemonic;
      mnemonic.raw = seed.toStdString();
      std::pair<bool,std::string> seedSuccess = BIP39::saveEncryptedMnemonic(mnemonic, passStr);
      return (createSuccess && seedSuccess.first);
    }

    Q_INVOKABLE bool loadWallet(QString folder, QString pass) {
      std::string passStr = pass.toStdString();
      bool loadSuccess = this->w.load(folder.toStdString(), passStr);
      return loadSuccess;
    }

    Q_INVOKABLE void closeWallet() {
      this->w.close();
    }

    // Check if a Wallet is loaded
    Q_INVOKABLE bool isWalletLoaded() {
      return this->w.isLoaded();
    }

    // Get the seed for the Wallet
    Q_INVOKABLE QString getWalletSeed(QString pass) {
      std::string passStr = pass.toStdString();
      bip3x::Bip39Mnemonic::MnemonicResult mnemonic;
      std::pair<bool,std::string> seedSuccess = BIP39::loadEncryptedMnemonic(mnemonic, passStr);
      return (seedSuccess.first) ? QString::fromStdString(mnemonic.raw) : "";
    }

    // Load the Accounts into the Wallet
    Q_INVOKABLE void loadAccounts() {
      this->w.loadAccounts();
    }

    // List the Wallet's Accounts
    Q_INVOKABLE QVariantList listAccounts() {
      QVariantList ret;
      for (Account &a : w.accounts) {
        std::string obj;
        a.balancesThreadLock.lock();
        obj += "{\"account\": \"" + a.address;
        obj += "\", \"name\": \"" + a.name;
        obj += "\", \"coinAmount\": \"" + a.balanceAVAX;
        obj += "\", \"tokenAmount\": \"" + a.balanceAVME;
        obj += "\", \"freeLPAmount\": \"" + a.balanceLPFree;
        obj += "\", \"lockedLPAmount\": \"" + a.balanceLPLocked;
        obj += "\"}";
        a.balancesThreadLock.unlock();
        ret << QString::fromStdString(obj);
      }
      return ret;
    }

    // Start/stop balance threads for one/all Accounts, respectively
    Q_INVOKABLE void startBalanceThread(QString address) {
      for (Account &a : w.accounts) {
        if (a.address == address.toStdString()) {
          Account::startBalancesThread(a);
          break;
        }
      }
    }

    Q_INVOKABLE void stopBalanceThread(QString address) {
      for (Account &a : w.accounts) {
        if (a.address == address.toStdString()) {
          a.interruptThread = true;
          while (!a.threadWasInterrupted) {
              boost::this_thread::sleep_for(boost::chrono::milliseconds(100));
          }
        }
      }
    }

    Q_INVOKABLE void startAllBalanceThreads() {
      for (Account &a : w.accounts) {
        Account::startBalancesThread(a);
      }
    }

    Q_INVOKABLE void stopAllBalanceThreads() {
      for (Account &a : w.accounts) {
        a.interruptThread = true;
      }
      for (Account &a : w.accounts) {
        while (!a.threadWasInterrupted) {
            boost::this_thread::sleep_for(boost::chrono::milliseconds(100));
        }
      }
    }

    // Generate an Account list from a given seed, starting from a given index
    Q_INVOKABLE void generateAccounts(QString seed, int idx) {
      QtConcurrent::run([=](){
        QVariantList ret;
        std::vector<std::string> list = BIP39::generateAccountsFromSeed(seed.toStdString(), idx);
        for (std::string s : list) {
          std::stringstream listss(s);
          std::string item, obj;
          int ct = 0;
          while (std::getline(listss, item, ' ')) {
            switch (ct) {
              case 0: obj += "{\"idx\": \"" + item; break;
              case 1: obj += "\", \"account\": \"" + item; break;
              case 2: obj += "\", \"balance\": \"" + item; break;
            }
            ct++;
          }
          obj += "\"}";
          ret << QString::fromStdString(obj);
        }
        emit accountsGenerated(ret);
      });
    }

    // Create a new Account
    Q_INVOKABLE void createAccount(QString seed, int index, QString name, QString pass) {
      QtConcurrent::run([=](){
        QVariantMap obj;
        std::string seedStr = seed.toStdString();
        std::string nameStr = name.toStdString();
        std::string passStr = pass.toStdString();
        Account a = this->w.createAccount(seedStr, index, nameStr, passStr);
        if (!a.id.empty()) {
          obj.insert("accId", QString::fromStdString(a.id));
          obj.insert("accName", QString::fromStdString(a.name));
          obj.insert("accAddress", QString::fromStdString(a.address));
          emit accountCreated(obj);
        } else {
          emit accountCreationFailed();
        }
      });
    }

    // Erase an Account
    Q_INVOKABLE bool eraseAccount(QString account) {
      return this->w.eraseAccount(account.toStdString());
    }

    // Check if Account exists
    Q_INVOKABLE bool accountExists(QString account) {
      return this->w.accountExists(account.toStdString());
    }

    // List the Account's transactions
    Q_INVOKABLE QVariantList listAccountTransactions(QString address) {
      QVariantList ret;
      for (Account &a : w.accounts) {
        if (a.address == address.toStdString()) {
          a.loadTxHistory();
          for (TxData tx : a.history) {
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
          break;
        }
      }
      return ret;
    }

    // Get an Account's balances
    Q_INVOKABLE QVariantMap getAccountBalances(QString address) {
      QVariantMap ret;
      for (Account &a : w.accounts) {
        if (a.address == address.toStdString()) {
          a.balancesThreadLock.lock();
          ret.insert("balanceAVAX", QString::fromStdString(a.balanceAVAX));
          ret.insert("balanceAVME", QString::fromStdString(a.balanceAVME));
          ret.insert("balanceLPFree", QString::fromStdString(a.balanceLPFree));
          ret.insert("balanceLPLocked", QString::fromStdString(a.balanceLPLocked));
          a.balancesThreadLock.unlock();
          break;
        }
      }
      return ret;
    }

    // Get the sum of all Accounts' balances in the Wallet
    Q_INVOKABLE QVariantMap getAllAccountBalances() {
      QVariantMap ret;
      u256 totalAVAX = 0, totalAVME = 0, totalLPFree = 0, totalLPLocked = 0;
      std::string totalAVAXStr = "", totalAVMEStr = "", totalLPFreeStr = "", totalLPLockedStr = "";

      for (Account &a : w.accounts) {
        a.balancesThreadLock.lock();
        totalAVAX += boost::lexical_cast<u256>(
          Utils::fixedPointToWei(a.balanceAVAX, this->currentCoinDecimals)
        );
        totalAVME += boost::lexical_cast<u256>(
          Utils::fixedPointToWei(a.balanceAVME, this->currentTokenDecimals)
        );
        totalLPFree += boost::lexical_cast<u256>(
          Utils::fixedPointToWei(a.balanceLPFree, 18)
        );
        totalLPLocked += boost::lexical_cast<u256>(
          Utils::fixedPointToWei(a.balanceLPLocked, 18)
        );
        a.balancesThreadLock.unlock();
      }

      totalAVAXStr = Utils::weiToFixedPoint(
        boost::lexical_cast<std::string>(totalAVAX), this->currentCoinDecimals
      );
      totalAVMEStr = Utils::weiToFixedPoint(
        boost::lexical_cast<std::string>(totalAVME), this->currentTokenDecimals
      );
      totalLPFreeStr = Utils::weiToFixedPoint(
        boost::lexical_cast<std::string>(totalLPFree), 18
      );
      totalLPLockedStr = Utils::weiToFixedPoint(
        boost::lexical_cast<std::string>(totalLPLocked), 18
      );

      ret.insert("balanceAVAX", QString::fromStdString(totalAVAXStr));
      ret.insert("balanceAVME", QString::fromStdString(totalAVMEStr));
      ret.insert("balanceLPFree", QString::fromStdString(totalLPFreeStr));
      ret.insert("balanceLPLocked", QString::fromStdString(totalLPLockedStr));
      return ret;
    }

    // Get an Account's private keys
    Q_INVOKABLE QString getPrivateKeys(QString account, QString pass) {
      Secret s = w.getSecret(account.toStdString(), pass.toStdString());
      std::string key = toHex(s.ref());
      return QString::fromStdString(key);
    }

    // Check if Account seed is valid
    Q_INVOKABLE bool seedIsValid(QString seed) {
      std::stringstream ss(seed.toStdString());
      std::string word;
      int ct = 0;

      while (std::getline(ss, word, ' ')) {
        if (!BIP39::wordExists(word)) { return false; }
        ct++;
      }
      if (ct != 12) { return false; }

      return true;
    }

    // Get gas price from network
    Q_INVOKABLE QString getAutomaticFee() {
      return QString::fromStdString(Network::getAutomaticFee());
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

    // Convert fixed point to Wei and vice-versa
    Q_INVOKABLE QString fixedPointToWei(QString amount, int decimals) {
      return QString::fromStdString(
        Utils::fixedPointToWei(amount.toStdString(), decimals)
      );
    }

    Q_INVOKABLE QString weiToFixedPoint(QString amount, int digits) {
      return QString::fromStdString(
        Utils::weiToFixedPoint(amount.toStdString(), digits)
      );
    }

    // Calculate the real amount of a max AVAX transaction (minus gas costs)
    Q_INVOKABLE QString getRealMaxAVAXAmount(QString gasLimit, QString gasPrice) {
      std::string gasLimitStr = gasLimit.toStdString(); // Already in Wei
      std::string gasPriceStr = Utils::fixedPointToWei(gasPrice.toStdString(), 9); // Gwei, so 10^9 Wei
      u256 gasLimitU256 = u256(gasLimitStr);
      u256 gasPriceU256 = u256(gasPriceStr);

      QVariantMap acc = getAccountBalances(QString::fromStdString(this->txSenderAccount));
      std::string balanceStr = acc["balanceAVAX"].toString().toStdString();
      u256 totalU256 = u256(Utils::fixedPointToWei(balanceStr, this->currentCoinDecimals));
      totalU256 -= (gasLimitU256 + gasPriceU256);
      std::string totalStr = Utils::weiToFixedPoint(
        boost::lexical_cast<std::string>(totalU256), 18
      );
      return QString::fromStdString(totalStr);
    }

    /**
     * Calculate the total cost of a transaction.
     * Calculation is done with values converted to Wei, while the result
     * is converted back to fixed point.
     */
    Q_INVOKABLE QString calculateTransactionCost(
      QString amount, QString gasLimit, QString gasPrice
    ) {
      std::string amountStr = Utils::fixedPointToWei(amount.toStdString(), 18);  // Fixed point, so 10^18 Wei
      std::string gasLimitStr = gasLimit.toStdString(); // Already in Wei
      std::string gasPriceStr = Utils::fixedPointToWei(gasPrice.toStdString(), 9); // Gwei, so 10^9 Wei
      u256 amountU256 = u256(amountStr);
      u256 gasLimitU256 = u256(gasLimitStr);
      u256 gasPriceU256 = u256(gasPriceStr);
      u256 totalU256 = amountU256 + gasLimitU256 + gasPriceU256;
      // Uncomment to see the values in Wei
      //std::cout << "Total: " << totalU256 << std::endl;
      //std::cout << "Amount: " << amountU256 << std::endl;
      //std::cout << "Gas Limit: " << gasLimitU256 << std::endl;
      //std::cout << "Gas Price: " << gasPriceU256 << std::endl;
      std::string totalStr = Utils::weiToFixedPoint(
        boost::lexical_cast<std::string>(totalU256), 18
      );
      return QString::fromStdString(totalStr);
    }

    // Check for insufficient funds in coin and token transactions, respectively
    Q_INVOKABLE bool hasInsufficientCoinFunds(QString senderAmount, QString receiverAmount) {
      std::string senderStr, receiverStr;
      u256 senderU256, receiverU256;
      senderStr = Utils::fixedPointToWei(senderAmount.toStdString(), this->currentCoinDecimals);
      receiverStr = Utils::fixedPointToWei(receiverAmount.toStdString(), this->currentCoinDecimals);
      senderU256 = u256(senderStr);
      receiverU256 = u256(receiverStr);
      return (receiverU256 > senderU256);
    }

    Q_INVOKABLE bool hasInsufficientTokenFunds(QString senderAmount, QString receiverAmount) {
      std::string senderStr, receiverStr;
      u256 senderU256, receiverU256;
      senderStr = Utils::fixedPointToWei(senderAmount.toStdString(), this->currentTokenDecimals);
      receiverStr = Utils::fixedPointToWei(receiverAmount.toStdString(), this->currentTokenDecimals);
      senderU256 = u256(senderStr);
      receiverU256 = u256(receiverStr);
      return (receiverU256 > senderU256);
    }

    // Make a coin or token transaction with the collected data
    Q_INVOKABLE void makeTransaction(QString pass) {
      QtConcurrent::run([=](){
        // Convert the values required for a transaction to their Wei formats.
        // Gas price is in Gwei (10^9 Wei) and amounts are in fixed point.
        // Gas limit is already in Wei so we skip that.
        this->txReceiverCoinAmount = Utils::fixedPointToWei(
          this->txReceiverCoinAmount, this->currentCoinDecimals
        );
        this->txReceiverTokenAmount = Utils::fixedPointToWei(
          this->txReceiverTokenAmount, this->currentTokenDecimals
        );
        this->txReceiverLPAmount = Utils::fixedPointToWei(
          this->txReceiverLPAmount, 18
        );
        this->txGasPrice = boost::lexical_cast<std::string>(
          boost::lexical_cast<u256>(this->txGasPrice) * raiseToPow(10, 9)
        );

        // Build the transaction and data hex according to the operation
        std::string dataHex;
        TransactionSkeleton txSkel;
        if (this->txOperation == "Send AVAX") {
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, this->txReceiverAccount,
            this->txReceiverCoinAmount, this->txGasLimit, this->txGasPrice
          );
        } else if (this->txOperation == "Send AVME") {
          dataHex = Pangolin::transfer(
            this->txReceiverAccount, this->txReceiverTokenAmount
          );
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, Pangolin::tokenContracts[this->currentToken],
            "0", this->txGasLimit, this->txGasPrice, dataHex
          );
        } else if (this->txOperation == "Approve Exchange") {
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, Pangolin::tokenContracts["AVME"],
            "0", this->txGasLimit, this->txGasPrice,
            Pangolin::approve(Pangolin::routerContract)
          );
        } else if (this->txOperation == "Approve Liquidity") {
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, Pangolin::getPair(this->currentCoin, this->currentToken),
            "0", this->txGasLimit, this->txGasPrice,
            Pangolin::approve(Pangolin::routerContract)
          );
        } else if (this->txOperation == "Approve Staking") {
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, Pangolin::getPair(this->currentCoin, this->currentToken),
            "0", this->txGasLimit, this->txGasPrice,
            Pangolin::approve(Pangolin::stakingContract)
          );
        } else if (this->txOperation == "Swap AVAX -> AVME") {
          u256 amountOutMin = boost::lexical_cast<u256>(this->txReceiverTokenAmount);
          amountOutMin -= (amountOutMin / 1000); // 0.1%
          dataHex = Pangolin::swapExactAVAXForTokens(
            // amountOutMin, path, to, deadline
            boost::lexical_cast<std::string>(amountOutMin),
            { Pangolin::tokenContracts["WAVAX"], Pangolin::tokenContracts["AVME"] },
            this->txSenderAccount,
            boost::lexical_cast<std::string>(
              std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
              ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
            )
          );
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, Pangolin::routerContract,
            this->txReceiverCoinAmount, this->txGasLimit, this->txGasPrice, dataHex
          );
        } else if (this->txOperation == "Swap AVME -> AVAX") {
          u256 amountOutMin = boost::lexical_cast<u256>(this->txReceiverCoinAmount);
          amountOutMin -= (amountOutMin / 1000); // 0.1%
          dataHex = Pangolin::swapExactTokensForAVAX(
            // amountIn, amountOutMin, path, to, deadline
            this->txReceiverTokenAmount,
            boost::lexical_cast<std::string>(amountOutMin),
            { Pangolin::tokenContracts["AVME"], Pangolin::tokenContracts["WAVAX"] },
            this->txSenderAccount,
            boost::lexical_cast<std::string>(
              std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
              ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
            )
          );
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, Pangolin::routerContract,
            "0", this->txGasLimit, this->txGasPrice, dataHex
          );
        } else if (this->txOperation == "Add Liquidity") {
          u256 amountAVAXMin = boost::lexical_cast<u256>(this->txReceiverCoinAmount);
          u256 amountTokenMin = boost::lexical_cast<u256>(this->txReceiverTokenAmount);
          amountAVAXMin -= (amountAVAXMin / 200); // 0.5%
          amountTokenMin -= (amountTokenMin / 200); // 0.5%
          dataHex = Pangolin::addLiquidityAVAX(
            // tokenAddress, amountTokenDesired, amountTokenMin, amountAVAXMin, to, deadline
            Pangolin::tokenContracts[this->currentToken],
            this->txReceiverTokenAmount,
            boost::lexical_cast<std::string>(amountTokenMin),
            boost::lexical_cast<std::string>(amountAVAXMin),
            this->txSenderAccount,
            boost::lexical_cast<std::string>(
              std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
              ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
            )
          );
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, Pangolin::routerContract,
            this->txReceiverCoinAmount, this->txGasLimit, this->txGasPrice, dataHex
          );
        } else if (this->txOperation == "Remove Liquidity") {
          u256 amountAVAXMin = boost::lexical_cast<u256>(this->txReceiverCoinAmount);
          u256 amountTokenMin = boost::lexical_cast<u256>(this->txReceiverTokenAmount);
          amountAVAXMin -= (amountAVAXMin / 200); // 0.5%
          amountTokenMin -= (amountTokenMin / 200); // 0.5%
          dataHex = Pangolin::removeLiquidityAVAX(
            // tokenAddress, liquidity, amountTokenMin, amountAVAXMin, to, deadline
            Pangolin::tokenContracts[this->currentToken],
            this->txReceiverLPAmount,
            boost::lexical_cast<std::string>(amountTokenMin),
            boost::lexical_cast<std::string>(amountAVAXMin),
            this->txSenderAccount,
            boost::lexical_cast<std::string>(
              std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
              ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
            )
          );
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, Pangolin::routerContract,
            "0", this->txGasLimit, this->txGasPrice, dataHex
          );
        } else if (this->txOperation == "Stake LP") {
          dataHex = Staking::stake(this->txReceiverLPAmount);
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, Pangolin::stakingContract,
            "0", this->txGasLimit, this->txGasPrice, dataHex
          );
        } else if (this->txOperation == "Unstake LP") {
          dataHex = Staking::withdraw(this->txReceiverLPAmount);
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, Pangolin::stakingContract,
            "0", this->txGasLimit, this->txGasPrice, dataHex
          );
        } else if (this->txOperation == "Harvest AVME") {
          dataHex = Staking::getReward();
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, Pangolin::stakingContract,
            "0", this->txGasLimit, this->txGasPrice, dataHex
          );
        } else if (this->txOperation == "Exit Staking") {
          dataHex = Staking::exit();
          txSkel = this->w.buildTransaction(
            this->txSenderAccount, Pangolin::stakingContract,
            "0", this->txGasLimit, this->txGasPrice, dataHex
          );
        }
        emit txBuilt(txSkel.nonce != Utils::MAX_U256_VALUE());

        // Sign the transaction
        std::string signedTx = this->w.signTransaction(txSkel, pass.toStdString());
        emit txSigned(!signedTx.empty());

        // Send the transaction
        std::string txLink = this->w.sendTransaction(signedTx, this->txOperation);
        if (txLink.empty()) { emit txSent(false, ""); }
        while (txLink.find("Transaction nonce is too low") != std::string::npos ||
            txLink.find("Transaction with the same hash was already imported") != std::string::npos) {
          emit txRetry();
          txSkel.nonce++;
          signedTx = this->w.signTransaction(txSkel, pass.toStdString());
          txLink = this->w.sendTransaction(signedTx, this->txOperation);
        }
        emit txSent(true, QString::fromStdString(txLink));
      });
    }

    // Get approval amount for the exchange and liquidity screens
    Q_INVOKABLE void getAllowances() {
      QtConcurrent::run([=](){
        std::string exchangeAllowance = Pangolin::allowance(
          Pangolin::tokenContracts[this->currentToken],
          this->txSenderAccount, Pangolin::routerContract
        );
        std::string liquidityAllowance = Pangolin::allowance(
          Pangolin::getPair(this->currentCoin, this->currentToken),
          this->txSenderAccount, Pangolin::routerContract
        );
        std::string stakingAllowance = Pangolin::allowance(
          Pangolin::getPair(this->currentCoin, this->currentToken),
          this->txSenderAccount, Pangolin::stakingContract
        );
        emit allowancesUpdated(
          QString::fromStdString(exchangeAllowance),
          QString::fromStdString(liquidityAllowance),
          QString::fromStdString(stakingAllowance)
        );
      });
    }

    // Check if approval needs to be refreshed
    Q_INVOKABLE bool isApproved(QString amount, QString allowed) {
      if (amount.isEmpty()) { amount = QString("0"); }
      if (allowed.isEmpty()) { allowed = QString("0"); }
      u256 amountU256 = boost::lexical_cast<u256>(
        Utils::fixedPointToWei(amount.toStdString(), 18)
      );
      u256 allowedU256 = boost::lexical_cast<u256>(allowed.toStdString());
      return ((allowedU256 > 0) && (allowedU256 >= amountU256));
    }

    // Update reserves for the exchange screen
    Q_INVOKABLE void updateExchangeData(QString tokenNameA, QString tokenNameB) {
      QtConcurrent::run([=](){
        QVariantMap ret;
        std::string strA = tokenNameA.toStdString();
        std::string strB = tokenNameB.toStdString();
        if (strA == "AVAX") { strA = "WAVAX"; }
        if (strB == "AVAX") { strB = "WAVAX"; }

        std::vector<std::string> reserves = Pangolin::getReserves(strA, strB);
        std::string first = Pangolin::getFirstFromPair(strA, strB);
        if (strA == first) {
          emit exchangeDataUpdated(
            tokenNameA, QString::fromStdString(reserves[0]),
            tokenNameB, QString::fromStdString(reserves[1])
          );
        } else if (strB == first) {
          emit exchangeDataUpdated(
            tokenNameA, QString::fromStdString(reserves[1]),
            tokenNameB, QString::fromStdString(reserves[0])
          );
        }
      });
    }

    // Update reserves and liquidity supply for the exchange screen
    Q_INVOKABLE void updateLiquidityData(QString tokenNameA, QString tokenNameB) {
      QtConcurrent::run([=](){
        QVariantMap ret;
        std::string strA = tokenNameA.toStdString();
        std::string strB = tokenNameB.toStdString();
        if (strA == "AVAX") { strA = "WAVAX"; }
        if (strB == "AVAX") { strB = "WAVAX"; }

        std::vector<std::string> reserves = Pangolin::getReserves(strA, strB);
        std::string liquidity = Pangolin::totalSupply(strA, strB);
        std::string first = Pangolin::getFirstFromPair(strA, strB);
        if (strA == first) {
          emit liquidityDataUpdated(
            tokenNameA, QString::fromStdString(reserves[0]),
            tokenNameB, QString::fromStdString(reserves[1]),
            QString::fromStdString(liquidity)
          );
        } else if (strB == first) {
          emit liquidityDataUpdated(
            tokenNameA, QString::fromStdString(reserves[1]),
            tokenNameB, QString::fromStdString(reserves[0]),
            QString::fromStdString(liquidity)
          );
        }
      });
    }

    // Calculate the estimated amount for a coin/token exchange
    Q_INVOKABLE QString calculateExchangeAmount(
      QString amountIn, QString reservesIn, QString reservesOut
    ) {
      std::string amountInWei = Utils::fixedPointToWei(amountIn.toStdString(), 18);
      std::string amountOut = Pangolin::calcExchangeAmountOut(
        amountInWei, reservesIn.toStdString(), reservesOut.toStdString()
      );
      amountOut = Utils::weiToFixedPoint(amountOut, 18);
      return QString::fromStdString(amountOut);
    }

    /**
     * Calculate the estimated amounts of AVAX/AVME when adding/removing
     * liquidity from the pool, respectively
     */
    Q_INVOKABLE QString calculateAddLiquidityAmount(
      QString amountIn, QString reservesIn, QString reservesOut
    ) {
      std::string amountInWei = Utils::fixedPointToWei(amountIn.toStdString(), 18);
      std::string amountOut = Pangolin::calcLiquidityAmountOut(
        amountInWei, reservesIn.toStdString(), reservesOut.toStdString()
      );
      amountOut = Utils::weiToFixedPoint(amountOut, 18);
      return QString::fromStdString(amountOut);
    }

    Q_INVOKABLE QVariantMap calculateRemoveLiquidityAmount(
      QString lowerReserves, QString higherReserves, QString percentage
    ) {
      QVariantMap ret;
      if (lowerReserves.isEmpty()) { lowerReserves = QString("0"); }
      if (higherReserves.isEmpty()) { higherReserves = QString("0"); }

      u256 lowerReservesU256 = boost::lexical_cast<u256>(lowerReserves.toStdString());
      u256 higherReservesU256 = boost::lexical_cast<u256>(higherReserves.toStdString());
      u256 userLPWei = boost::lexical_cast<u256>(
        Utils::fixedPointToWei(this->txSenderLPFreeAmount, 18)
      );
      bigfloat pc = bigfloat(boost::lexical_cast<double>(percentage.toStdString()) / 100);

      u256 userLowerReservesU256 = u256(bigfloat(lowerReservesU256) * bigfloat(pc));
      u256 userHigherReservesU256 = u256(bigfloat(higherReservesU256) * bigfloat(pc));
      u256 userLPReservesU256 = u256(bigfloat(userLPWei) * bigfloat(pc));

      std::string lower = boost::lexical_cast<std::string>(userLowerReservesU256);
      std::string higher = boost::lexical_cast<std::string>(userHigherReservesU256);
      std::string lp = Utils::weiToFixedPoint(
        boost::lexical_cast<std::string>(userLPReservesU256), 18
      );

      ret.insert("lower", QString::fromStdString(lower));
      ret.insert("higher", QString::fromStdString(higher));
      ret.insert("lp", QString::fromStdString(lp));
      return ret;
    }

    // Estimate the amount of coin/token that will be exchanged
    Q_INVOKABLE QString queryExchangeAmount(QString amount, QString fromName, QString toName) {
      // Convert QStrings to std::strings
      std::string amountStr = amount.toStdString();
      std::string fromStr = fromName.toStdString();
      std::string toStr = toName.toStdString();
      if (fromStr == "AVAX") { fromStr = "WAVAX"; }
      if (toStr == "AVAX") { toStr = "WAVAX"; }

      // reserves[0] = first/lower token, reserves[1] = second/higher token
      std::vector<std::string> reserves = Pangolin::getReserves(fromStr, toStr);
      std::string first = Pangolin::getFirstFromPair(fromStr, toStr);
      std::string input = Utils::fixedPointToWei(amountStr, 18);
      std::string output;
      if (fromStr == first) {
        output = Pangolin::calcExchangeAmountOut(input, reserves[0], reserves[1]);
      } else if (toStr == first) {
        output = Pangolin::calcExchangeAmountOut(input, reserves[1], reserves[0]);
      }
      output = Utils::weiToFixedPoint(output, 18);
      return QString::fromStdString(output);
    }

    // Calculate the Account's share in AVAX/AVME/LP in the pool, respectively
    Q_INVOKABLE QVariantMap calculatePoolShares(
      QString lowerReserves, QString higherReserves, QString totalLiquidity
    ) {
      QVariantMap ret;
      u256 lowerReservesU256 = boost::lexical_cast<u256>(lowerReserves.toStdString());
      u256 higherReservesU256 = boost::lexical_cast<u256>(higherReserves.toStdString());
      u256 totalLiquidityU256 = boost::lexical_cast<u256>(totalLiquidity.toStdString());
      u256 userLiquidityU256 = boost::lexical_cast<u256>(
        Utils::fixedPointToWei(this->txSenderLPFreeAmount, 18)
      );

      bigfloat userLPPercentage = (
        bigfloat(userLiquidityU256) / bigfloat(totalLiquidityU256)
      );
      u256 userLowerReservesU256 = u256(bigfloat(lowerReservesU256) * userLPPercentage);
      u256 userHigherReservesU256 = u256(bigfloat(higherReservesU256) * userLPPercentage);

      std::string lower = boost::lexical_cast<std::string>(userLowerReservesU256);
      std::string higher = boost::lexical_cast<std::string>(userHigherReservesU256);
      std::string liquidity = boost::lexical_cast<std::string>(userLPPercentage * 100);

      ret.insert("lower", QString::fromStdString(lower));
      ret.insert("higher", QString::fromStdString(higher));
      ret.insert("liquidity", QString::fromStdString(liquidity));
      return ret;
    }

    // Get the staking rewards for a given Account
    Q_INVOKABLE void getPoolReward() {
      QtConcurrent::run([=](){
        std::string poolRewardWei = Staking::earned(this->txSenderAccount);
        std::string poolReward = Utils::weiToFixedPoint(poolRewardWei, this->currentCoinDecimals);
        emit rewardUpdated(QString::fromStdString(poolReward));
      });
    }
};

#endif // MAIN_GUI_H
