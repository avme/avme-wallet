// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef QMLSYSTEM_H
#define QMLSYSTEM_H

#include <QtConcurrent/qtconcurrentrun.h>
#include <QtCore/QDateTime>
#include <QtCore/QFile>
#include <QtCore/QStandardPaths>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QUrl>
#include <QtCore/QVariant>
#include <QtGui/QClipboard>
#include <QtNetwork/QSslSocket>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtWidgets/QApplication>

#include <lib/ledger/ledger.h>

#include <network/API.h>
#include <network/Server.h>
#include <core/BIP39.h>
#include <core/Utils.h>
#include <core/Wallet.h>
#include <network/Graph.h>
#include <network/Pangolin.h>
#include <network/Staking.h>
#include <network/ParaSwap.h>

#include "version.h"

class Server;  // https://stackoverflow.com/a/4964508
class session;

/**
 * Class for wrapping C++ and QML together.
 */
class QmlSystem : public QObject {
  Q_OBJECT

  private:
    Wallet w;
    Server s;
    ledger::device ledgerDevice;
    bool ledgerFlag = false;
    QString currentHardwareAccount;
    QString currentHardwareAccountPath;
    QQmlApplicationEngine *engine = nullptr;

    // Permission list of websites allowed to join.
    std::vector<std::pair<std::string,bool>> permissionList;

    // Mutex locks for when dealing with WS Server.
    std::mutex permissionListMutex;
    std::mutex globalUserInputRequest;
    std::mutex PLuserInputRequest;
    std::mutex PLuserInputAnswer;
    std::mutex requestTransactionMutex;
    std::mutex RTuserInputRequest;
    std::mutex RTuserInputAnswer;
    std::mutex requestSignMutex;
    std::mutex RSuserInputRequest;
    std::mutex RSuserInputAnswer;

    // String that will hold the TXID of an approved transaction.
    std::string RTtxid = "";
    // String that will hold the signature of a sign request;
    std::string RSmsg = "";

  public slots:
    // Clean database, threads, etc before changing the Account and Wallet, respectively
    void cleanAndCloseAccount() {
      this->w.closeHistoryDB();
      stopWSServer();
    }
    void cleanAndCloseWallet() {
      this->w.closeTokenDB();
      this->w.closeHistoryDB();
      this->w.closeLedgerDB();
      this->w.closeAppDB();
      this->w.closeAddressDB();
      this->w.closeConfigDB();
      stopWSServer();
      // Wait untill all threads from QtThreadPool exits
      QThreadPool::globalInstance()->waitForDone(-1); // -1 to ignore timeout https://doc.qt.io/qt-5/qthreadpool.html#waitForDone
      return;
    }

  signals:
    // Common signals
    void urlChecked(QString link, bool b);

    // Start/Wallet screen signals
    void walletCreated(bool success);
    void walletLoaded(bool success);

    // Account screen signals
    void accountGenerated(QVariantMap data);
    void ledgerAccountGenerated(QString dataStr);
    void accountCreated(bool success, QVariantMap data);
    void accountAVAXBalancesUpdated(
      QString address, QString avaxBalance, QString avaxValue, QString avaxPrice, QString avaxPriceData
    );
    void accountAllBalancesUpdated(
      QString address, QString tokenJsonListStr, QString CoinData, QString gasPrice
    );

    // History screen signals
    void historyLoaded(QString data);

    // Send screen signals
    void operationOverride(
      QString op, QString amountCoin, QString amountToken, QString amountLP
    );
    void txBuilt(bool b, QString randomID);
    void txSigned(bool b, QString msg, QString randomID);
    void txSent(bool b, QString linkUrl, QString txid, QString msg, QString randomID);
    void txConfirmed(bool b, QString txid, QString randomID);
    void txRetry(QString randomID);
    void ledgerRequired(QString randomID);
    void ledgerDone(QString randomID);
    void accountNonceUpdate(QString nonce);

    // Applications screen signals
    void appListDownloaded();
    void appListDownloadFailed();
    void appDownloadProgressUpdated(int progress, int total);
    void appInstalled(bool success);
    void appLoaded(QString folderPath);

    // Signal for request user input to give permission for said website
    void askForPermission(QString website_);

    // Signal to request user to sign a given transaction
    void askForTransaction(QString data, QString from, QString gas, QString to, QString value, QString website_);
    
    // Signal to request user to sign a message.
    void askForSign(QString address, QString data, QString website_);

    // Signals for ParaSwap exchanging
    void gotParaSwapTokenPrices(QString priceRoute, QString id, QString request);
    void gotParaSwapTransactionData(QString transactionData, QString id, QString request);

    // Signals for when testing a user typed API

    void apiReturnedSuccessfully(bool status, QString type);

    // Signal for message has been signed.
    void messageSigned(QString message);

    // Signal for letting the user know there is a update

    void walletRequireUpdate();

  public:
    // ======================================================================
    // COMMON FUNCTIONS
    // ======================================================================

    // Getters/Setters for private vars
    Q_INVOKABLE bool getLedgerFlag() { return ledgerFlag; }
    Q_INVOKABLE void setLedgerFlag(bool b) { ledgerFlag = b; }
    Q_INVOKABLE void setCurrentHardwareAccount(QString b) { currentHardwareAccount = b; }
    Q_INVOKABLE QString getCurrentHardwareAccount() { return currentHardwareAccount; }
    Q_INVOKABLE void setCurrentHardwareAccountPath(QString b) { currentHardwareAccountPath = b; }
    Q_INVOKABLE QString getCurrentHardwareAccountPath() { return currentHardwareAccountPath; }
    void setEngine(QQmlApplicationEngine *targetEngine) { engine = targetEngine;}; // INVOKATION FROM QML SHOULD *NOT* BE ALLOWED!

    // Get, save and delete the path for the last opened Wallet, respectively.
    // Get returns an empty string if the path doesn't exist.
    Q_INVOKABLE QString getLastWalletPath();
    Q_INVOKABLE bool saveLastWalletPath();
    Q_INVOKABLE bool deleteLastWalletPath();

    // Trim component cache. Removes *only* the data not being used.
    Q_INVOKABLE void trimComponentCache() { engine->trimComponentCache(); }

    // Get the project's version
    Q_INVOKABLE QString getProjectVersion();

    // Open the "About Qt" window
    Q_INVOKABLE void openQtAbout();

    // Change the current loaded screen from the qrc resource file or a
    // local file, respectively.
    Q_INVOKABLE void setScreen(QObject* loader, QString qmlFile);
    Q_INVOKABLE void setLocalScreen(QObject* loader, QString qmlFile);

    // Copy a string to the system clipboard
    Q_INVOKABLE void copyToClipboard(QString str);

    // Get a BIP39 seed from the clipboard, split into individual words
    Q_INVOKABLE QStringList copySeedFromClipboard();

    // Get the default path for the Wallet
    Q_INVOKABLE QString getDefaultWalletPath();

    // Check if the default Wallet path exists
    Q_INVOKABLE bool defaultWalletPathExists();

    // Remove the "file://" prefix from a folder path
    Q_INVOKABLE QString cleanPath(QString path);

    // Convert fixed point to Wei and vice-versa
    Q_INVOKABLE QString fixedPointToWei(QString amount, int decimals);
    Q_INVOKABLE QString weiToFixedPoint(QString amount, int decimals);

    // Check if a balance is zero or higher than another, respectively
    Q_INVOKABLE bool balanceIsZero(QString amount, int decimals);
    Q_INVOKABLE bool firstHigherThanSecond(QString first, QString second);

    // Get the given hardcoded contract address
    Q_INVOKABLE QString getContract(QString name);

    // Store the password using a thread, retrieve it and reset it manually, respectively.
    Q_INVOKABLE void storePass(QString pass);
    Q_INVOKABLE QString retrievePass();
    Q_INVOKABLE void resetPass();

    // Check if a URL exists (has data in it).
    Q_INVOKABLE void checkIfUrlExists(QUrl url);

    // Get/Set a given value in the Settings screen.
    Q_INVOKABLE QString getConfigValue(QString key);
    Q_INVOKABLE bool setConfigValue(QString key, QString value);

    // Check if wallet is on the most updated version
    Q_INVOKABLE void checkWalletVersion();

    // ======================================================================
    // START/WALLET SCREEN FUNCTIONS
    // ======================================================================

    // Check if a Wallet exists in a given folder
    Q_INVOKABLE bool checkFolderForWallet(QString folder);

    // Create/Import a new Wallet. Importing requires seed to be non-empty.
    // Emits walletCreated(success)
    Q_INVOKABLE void createWallet(QString folder, QString pass, QString seed = "");

    // Load an existing Wallet.
    // Emits walletLoaded(success)
    Q_INVOKABLE void loadWallet(QString folder, QString pass);

    // Close the Wallet.
    Q_INVOKABLE void closeWallet();

    // Check if the Wallet is loaded
    Q_INVOKABLE bool isWalletLoaded();

    // Check if given passphrase equals the Wallet's
    Q_INVOKABLE bool checkWalletPass(QString pass);

    // Get the seed for the Wallet
    Q_INVOKABLE QString getWalletSeed(QString pass);

    // Check if Ledger device is connected
    Q_INVOKABLE QVariantMap checkForLedger();

    // Check if a BIP39 seed is valid
    Q_INVOKABLE bool seedIsValid(QString seed);

    // Check if a DApp exists in the given folder
    Q_INVOKABLE bool checkForApp(QString folder);

    // ======================================================================
    // ACCOUNT SCREEN FUNCTIONS
    // ======================================================================

    // Getter/setter for the selected Account
    Q_INVOKABLE QString getCurrentAccount();
    Q_INVOKABLE void setCurrentAccount(QString address);

    // Load the Accounts into the Wallet
    Q_INVOKABLE void loadAccounts();

    // List the Wallet's Accounts
    Q_INVOKABLE QVariantList listAccounts();

    // Generate an Account list from a given seed, starting from a given index.
    // Emits accountGenerated() for each generated Account
    Q_INVOKABLE void generateAccounts(QString seed, int idx);

    // Same as above but for Ledger devices.
    // Emits ledgerAccountGenerated() for each generated Account
    Q_INVOKABLE void generateLedgerAccounts(QString path, int idx);

    // Clean up the Ledger account vector
    Q_INVOKABLE void cleanLedgerAccounts();

    // Create a new Account with seed + index, or private key, respectively.
    // Emits accountCreated() on success, accountCreationFailed() on failure
    Q_INVOKABLE void createAccount(QString seed, int index, QString name, QString pass);
    Q_INVOKABLE void createAccount(QString privKey, QString name, QString pass);

    // Check if a private key is valid.
    Q_INVOKABLE bool isPrivateKey(QString privKey);

    // Import and delete a Ledger account to/from the Wallet DB, respectively.
    Q_INVOKABLE void importLedgerAccount(QString address, QString path);
    Q_INVOKABLE bool deleteLedgerAccount(QString address);

    // Erase an Account
    Q_INVOKABLE bool eraseAccount(QString account);

    // Check if Account exists
    Q_INVOKABLE bool accountExists(QString account);
    Q_INVOKABLE bool privateKeyExists(QString privateKey);

    // Same as above but for Ledger accounts
    Q_INVOKABLE bool ledgerAccountExists(QString account);

    // Get an Account's private keys
    Q_INVOKABLE QString getPrivateKeys(QString account, QString pass);

    // Get the AVAX balance and price (in USD, 2 decimals) for one or multiple
    // Accounts, respectively.
    // Emits accountAVAXBalancesUpdated() for each Account
    Q_INVOKABLE void getAccountAVAXBalances(QString address);
    Q_INVOKABLE void getAllAVAXBalances(QStringList addresses);

    // Get the balances of all registered tokens for a specific Account
    Q_INVOKABLE void getAccountAllBalances(QString address);

    // (Re)Load the respective wallet databases.
    Q_INVOKABLE bool loadTokenDB();
    Q_INVOKABLE bool loadHistoryDB(QString address);
    Q_INVOKABLE bool loadLedgerDB();
    Q_INVOKABLE bool loadAppDB();
    Q_INVOKABLE bool loadAddressDB();
    Q_INVOKABLE bool loadConfigDB();

    // ======================================================================
    // OVERVIEW SCREEN FUNCTIONS
    // ======================================================================

    // Get QRCode width/height size
    Q_INVOKABLE qreal getQRCodeSize(QString address);
    // Get a QVariantList with the QRCode information
    Q_INVOKABLE QVariantList getQRCodeFromAddress(QString address);

    // ======================================================================
    // TOKENS SCREEN FUNCTIONS
    // ======================================================================

    // Load and get the list of registered tokens from the Wallet, respectively.
    Q_INVOKABLE void loadARC20Tokens();
    Q_INVOKABLE QVariantList getARC20Tokens();

    // Download and get a token's image from the network, respectively.
    // get returns empty if file doesn't exist.
    Q_INVOKABLE void downloadARC20TokenImage(QString address);
    Q_INVOKABLE QString getARC20TokenImage(QString address);

    // Get the ARC20 token list from the repo.
    Q_INVOKABLE QVariantList getARC20TokenList();

    // Add and remove a token from the list, respectively.
    Q_INVOKABLE bool addARC20Token(
      QString address, QString symbol, QString name, int decimals, QString avaxPairContract
    );
    Q_INVOKABLE bool removeARC20Token(QString address);

    // Check if a token exists in the network.
    Q_INVOKABLE bool ARC20TokenExists(QString address);

    // Retrieve a token's data from the network.
    Q_INVOKABLE QVariantMap getARC20TokenData(QString address);

    // Check if a token was already added in the Wallet.
    Q_INVOKABLE bool ARC20TokenWasAdded(QString address);

    // ======================================================================
    // HISTORY SCREEN FUNCTIONS
    // ======================================================================

    // List the Account's transactions, updating their statuses on the spot if required.
    // Emits historyLoaded()
    Q_INVOKABLE void listAccountTransactions(QString address);

    // Update a given transaction's status.
    Q_INVOKABLE void updateTxStatus(QString txHash);

    // Erase the whole transaction history.
    Q_INVOKABLE void eraseAllHistory();

    // ======================================================================
    // CONTACTS SCREEN FUNCTIONS
    // ======================================================================

    // List the Wallet's contacts.
    Q_INVOKABLE QVariantList listWalletContacts();

    // Add, remove, import and export contacts, respectively.
    Q_INVOKABLE bool addContact(QString address, QString name);
    Q_INVOKABLE bool removeContact(QString address);
    Q_INVOKABLE int importContacts(QString file);
    Q_INVOKABLE int exportContacts(QString file);

    // ======================================================================
    // TRANSACTION RELATED FUNCTIONS
    // ======================================================================

    // Create a RegExp for transaction amount inputs
    Q_INVOKABLE QRegExp createTxRegExp(int decimals);

    // Calculate the real amount of a max AVAX transaction (minus gas costs)
    Q_INVOKABLE QString getRealMaxAVAXAmount(
      QString totalBalance, QString gasLimit, QString gasPrice
    );

    /**
     * Calculate the total cost of a transaction.
     * Calculation is done with values converted to Wei, while the result
     * is converted back to fixed point.
     */
    Q_INVOKABLE QString calculateTransactionCost(
      QString amount, QString gasLimit, QString gasPrice
    );

    /**
     * Check for insufficient funds in a transaction.
     * Returns true if funds are lacking, or false if they're not.
     */
    Q_INVOKABLE bool hasInsufficientFunds(
      QString senderAmount, QString receiverAmount, int decimals
    );

    Q_INVOKABLE void updateAccountNonce(QString from);

    // Make a transaction with the collected data.
    // Emits txBuilt(), txSigned(), txSent() and txRetry()
    Q_INVOKABLE void makeTransaction(
      QString operation, QString from, QString to,
      QString value, QString txData, QString gas,
      QString gasPrice, QString pass, QString txNonce, QString randomID
    );

    // Check if the transaction was confirmed or not, and if it's "stuck"
    Q_INVOKABLE void checkTransactionFor15s(QString txid, QString randomID);

    // Sign a given message.

    Q_INVOKABLE void signMessage(QString address, QString data, QString password);

    // ======================================================================
    // EXCHANGE/LIQUIDITY/STAKING SCREEN FUNCTIONS
    // ======================================================================

    /**
     * Calculate the estimated output amount and price impact for a
     * coin/token exchange, respectively
     */
    Q_INVOKABLE QString calculateExchangeAmount(
      QString amountIn, QString reservesIn, QString reservesOut, int inDecimals, int outDecimals
    );
    Q_INVOKABLE double calculateExchangePriceImpact(
      QString tokenAmount, QString tokenInput, int tokenDecimals
    );

    /**
     * Calculate the estimated amounts of AVAX/AVME when adding/removing
     * liquidity from the pool, respectively
     */
    Q_INVOKABLE QString calculateAddLiquidityAmount(
      QString amountIn, QString reservesIn, QString reservesOut
    );
    Q_INVOKABLE QVariantMap calculateRemoveLiquidityAmount(
      QString asset1Reserves, QString asset2Reserves, QString percentage, QString pairBalance
    );

    // Calculate the Account's share in AVAX/AVME/LP in the pool, respectively
    Q_INVOKABLE QVariantMap calculatePoolShares(
      QString asset1Reserves, QString asset2Reserves,
      QString userLiquidity, QString totalLiquidity
    );

    // Same as above but for advanced compound
    Q_INVOKABLE QVariantMap calculatePoolSharesForTokenValue(
      QString lowerReserves, QString higherReserves, QString totalLiquidity, QString LPTokenValue
    );

    // Same as above but for ParaSwap
    Q_INVOKABLE void getParaSwapTokenPrices(
      QString srcToken, QString srcDecimals,
      QString destToken, QString destDecimals,
      QString weiAmount, QString chainID, QString side, QString id
    );
    Q_INVOKABLE void getParaSwapTransactionData(
      QString priceRouteStr, QString slippage,
      QString userAddress, QString fee, QString id
    );

    // ======================================================================
    // WEBSOCKET SERVER FUNCTIONS
    // ======================================================================

    // Process the received messages from the WS server
    void handleServer(std::string inputStr, std::shared_ptr<session> session_);

    // Set WS server to a pointer of this
    void setWSServer();

    // Start WS Server when loading an account
    Q_INVOKABLE void startWSServer();

    // Stop WS Server when closing an account
    Q_INVOKABLE void stopWSServer();

    // Ask for user input to approve/refuse a transaction
    Q_INVOKABLE void addToPermissionList(QString website, bool allow);

    Q_INVOKABLE void loadPermissionList();

    Q_INVOKABLE void requestedTransactionStatus(bool approved, QString txid);

    Q_INVOKABLE QString getWebsitePermissionList();

    Q_INVOKABLE void clearWebsitePermissionList();

    Q_INVOKABLE void testAPI(QString host, QString port, QString target, QString type);

    Q_INVOKABLE void setWalletAPI(QString host, QString port, QString target);

    Q_INVOKABLE void setWebSocketAPI(QString host, QString port, QString target, QString pluginPort);

    // ======================================================================
    // APPLICATIONS SCREEN FUNCTIONS
    // ======================================================================

    // Download the JSON file from the repo containing the latest DApp info.
    Q_INVOKABLE void downloadAppList();

    // Load the DApp list from the stored JSON file.
    Q_INVOKABLE QVariantList loadAppsFromList();

    // Load the installed DApps from the database.
    Q_INVOKABLE QVariantList loadInstalledApps();

    // Get the full DApp folder path.
    Q_INVOKABLE QString getAppFolderPath(int chainId, QString folder);

    // Check if a DApp is installed, install and uninstall it, respectively.
    // Installs are atomic - either all files are downloaded and the DApp is
    // properly registered in the database, or the install fails altogether.
    Q_INVOKABLE bool appIsInstalled(QString folder);
    Q_INVOKABLE void installApp(QVariantMap data);
    Q_INVOKABLE bool uninstallApp(QVariantMap data);
};

#endif  //QMLSYSTEM_H
