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
#include "lib/BIP39.h"
#include "lib/Network.h"
#include "lib/Pangolin.h"
#include "lib/Utils.h"
#include "lib/Wallet.h"

// QObject/wrapper for interfacing between C++ (wallet) and QML (gui)
class System : public QObject {
  Q_OBJECT

  signals:
    void accountCreated(QVariantMap data);
    void accountImported(bool success);
    void txStart(QString pass);
    void txBuilt(bool b);
    void txSigned(bool b);
    void txSent(bool b, QString linkUrl);
    void txRetry();
    void exchangeDataUpdated(
      QString lowerTokenName, QString lowerTokenReserves,
      QString higherTokenName, QString higherTokenReserves,
      QString totalPoolLiquidity
    );

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

    // Check if given passphrase equals the Wallet's
    Q_INVOKABLE bool checkWalletPass(QString pass) {
      return w.auth(pass.toStdString());
    }

    // Create a new Wallet
    Q_INVOKABLE bool createNewWallet(
      QString walletFile, QString secretsPath, QString pass
    ) {
      return this->w.create(
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
      return this->w.load(
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

    // Create a new Account
    Q_INVOKABLE void createNewAccount(QString name, QString pass) {
      QtConcurrent::run([=](){
        QVariantMap obj;
        QVariantList seed;
        Account a = this->w.createAccount(name.toStdString(), pass.toStdString());
        if (!a.id.empty()) {
          obj.insert("accId", QString::fromStdString(a.id));
          obj.insert("accName", QString::fromStdString(a.name));
          obj.insert("accAddress", QString::fromStdString(a.address));
          for (std::string word : a.seed) { seed << QString::fromStdString(word); }
          obj.insert("accSeed", seed);
        }
        emit accountCreated(obj);
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

    // Import an Account generated by a seed
    Q_INVOKABLE void importAccount(QString seed, QString name, QString pass) {
      QtConcurrent::run([=](){
        std::stringstream seedss(seed.toStdString());
        std::string word;
        std::vector<std::string> words;
        std::vector<std::string> mnemonicPhrase;
        std::string derivPath = "m/44'/60'/0'/0/";
        int index = 0;  // TODO: index will change in the future
        while (std::getline(seedss, word, ' ')) { words.push_back(word); }
        for (std::string word : words) { mnemonicPhrase.push_back(word); }

        bip3x::Bip39Mnemonic::MnemonicResult encodedMnemonic;
        encodedMnemonic.words = mnemonicPhrase;
        derivPath += QString::number(index).toStdString();
        bip3x::HDKey key = BIP39::createKey(encodedMnemonic.raw, derivPath);
        Account a = w.importAccount(name.toStdString(), pass.toStdString(), key);
        emit accountImported(!a.id.empty());
      });
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
        } else if (this->txOperation == "Swap AVAX -> AVME") {
          u256 amountOutMin = boost::lexical_cast<u256>(this->txReceiverTokenAmount);
          amountOutMin -= (amountOutMin / 1000); // 1%
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
          amountOutMin -= (amountOutMin / 1000); // 1%
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

    // Get approval amount for the exchange screen
    Q_INVOKABLE QString getExchangeAllowance() {
      std::string allowance = Pangolin::allowance(
        Pangolin::tokenContracts[this->currentToken],
        this->txSenderAccount, Pangolin::routerContract
      );
      return QString::fromStdString(allowance);
    }

    // Check if approval needs to be refreshed
    Q_INVOKABLE bool isExchangeAllowed(QString amount, QString allowed) {
      if (amount.isEmpty()) { amount = QString("0"); }
      if (allowed.isEmpty()) { allowed = QString("0"); }
      u256 amountU256 = boost::lexical_cast<u256>(
        Utils::fixedPointToWei(amount.toStdString(), 18)
      );
      u256 allowedU256 = boost::lexical_cast<u256>(allowed.toStdString());
      return ((allowedU256 > 0) && (allowedU256 >= amountU256));
    }

    // Update reserves and liquidity supply for the exchange screen
    Q_INVOKABLE void updateExchangeData(QString tokenNameA, QString tokenNameB) {
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
          emit exchangeDataUpdated(
            tokenNameA, QString::fromStdString(reserves[0]),
            tokenNameB, QString::fromStdString(reserves[1]),
            QString::fromStdString(liquidity)
          );
        } else if (strB == first) {
          emit exchangeDataUpdated(
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
      std::string amountOut = Pangolin::calcAmountOut(
        amountInWei, reservesIn.toStdString(), reservesOut.toStdString()
      );
      amountOut = Utils::weiToFixedPoint(amountOut, 18);
      return QString::fromStdString(amountOut);
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
        output = Pangolin::calcAmountOut(input, reserves[0], reserves[1]);
      } else if (toStr == first) {
        output = Pangolin::calcAmountOut(input, reserves[1], reserves[0]);
      }
      output = Utils::weiToFixedPoint(output, 18);
      return QString::fromStdString(output);
    }
};

#endif // MAIN_GUI_H
