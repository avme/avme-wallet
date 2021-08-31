// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef QMLSYSTEM_H
#define QMLSYSTEM_H

#include <QtConcurrent/qtconcurrentrun.h>
#include <QtCore/QFile>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QVariant>
#include <QtGui/QClipboard>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtWidgets/QApplication>

#include <lib/ledger/ledger.h>

#include <network/API.h>
#include <core/BIP39.h>
#include <core/Utils.h>
#include <core/Wallet.h>
#include <network/Graph.h>
#include <network/Pangolin.h>
#include <network/Staking.h>

#include "version.h"

/**
 * Class for wrapping C++ and QML together.
 */
class QmlSystem : public QObject {
  Q_OBJECT

  private:
    Wallet w;
    ledger::device ledgerDevice;
    bool firstLoad;
    bool ledgerFlag = false;
    QString currentHardwareAccount;
    QString currentHardwareAccountPath; 

  public slots:
    // Clean database, threads, etc before closing the program
    void cleanAndClose() {
      this->w.closeTokenDB();
      this->w.closeHistoryDB();
      this->w.closeLedgerDB();
      return;
    }

  signals:
    // Common signals
    void hideMenu();
    void goToOverview();

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
    void txStart(
      QString operation, QString from,
      QString to, QString value,
      QString txData, QString gas,
      QString gasPrice, QString pass
    );
    void operationOverride(
      QString op, QString amountCoin, QString amountToken, QString amountLP
    );
    void txBuilt(bool b);
    void txSigned(bool b, QString msg);
    void txSent(bool b, QString linkUrl);
    void txRetry();
    void ledgerRequired();
    void ledgerDone();

  public:
    // ======================================================================
    // COMMON FUNCTIONS
    // ======================================================================

    // Getters/Setters for private vars
    Q_INVOKABLE bool getFirstLoad() { return firstLoad; }
    Q_INVOKABLE void setFirstLoad(bool b) { firstLoad = b; }
    Q_INVOKABLE bool getLedgerFlag() { return ledgerFlag; }
    Q_INVOKABLE void setLedgerFlag(bool b) { ledgerFlag = b; }
    Q_INVOKABLE void setCurrentHardwareAccount(QString b) { currentHardwareAccount = b; }
    Q_INVOKABLE QString getCurrentHardwareAccount() { return currentHardwareAccount; }
    Q_INVOKABLE void setCurrentHardwareAccountPath(QString b) { currentHardwareAccountPath = b; }
    Q_INVOKABLE QString getCurrentHardwareAccountPath() { return currentHardwareAccountPath; }


    // Get the project's version
    Q_INVOKABLE QString getProjectVersion();

    // Open the "About Qt" window
    Q_INVOKABLE void openQtAbout();

    // Change the current loaded screen
    Q_INVOKABLE void setScreen(QObject* loader, QString qmlFile);

    // Copy a string to the system clipboard
    Q_INVOKABLE void copyToClipboard(QString str);

    // Get a BIP39 seed from the clipboard, split into individual words
    Q_INVOKABLE QStringList copySeedFromClipboard();

    // Get the default path for the Wallet
    Q_INVOKABLE QString getDefaultWalletPath();

    // Remove the "file://" prefix from a folder path
    Q_INVOKABLE QString cleanPath(QString path);

    // Convert fixed point to Wei and vice-versa
    Q_INVOKABLE QString fixedPointToWei(QString amount, int decimals);
    Q_INVOKABLE QString weiToFixedPoint(QString amount, int digits);

    // Check if a balance is zero or higher than another, respectively
    Q_INVOKABLE bool balanceIsZero(QString amount, int decimals);
    Q_INVOKABLE bool firstHigherThanSecond(QString first, QString second);

    // Get the given hardcoded contract address
    Q_INVOKABLE QString getContract(QString name);

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

    // Create a new Account.
    // Emits accountCreated() on success, accountCreationFailed() on failure
    Q_INVOKABLE void createAccount(QString seed, int index, QString name, QString pass);

    // Import a Ledger account to the Wallet DB
    Q_INVOKABLE void importLedgerAccount(QString address, QString path);
    
    // Delete a ledger account on the wallet DB
    Q_INVOKABLE bool deleteLedgerAccount(QString address);

    // Erase an Account
    Q_INVOKABLE bool eraseAccount(QString account);

    // Check if Account exists
    Q_INVOKABLE bool accountExists(QString account);

    // Get an Account's private keys
    Q_INVOKABLE QString getPrivateKeys(QString account, QString pass);

    // Get the AVAX balance and price (in USD, 2 decimals) for one or multiple
    // Accounts, respectively.
    // Emits accountAVAXBalancesUpdated() for each Account
    Q_INVOKABLE void getAccountAVAXBalances(QString address);
    Q_INVOKABLE void getAllAVAXBalances(QStringList addresses);

    // Get the balances of all registered tokens for a specific Account
    Q_INVOKABLE void getAccountAllBalances(QString address);

    // (Re)Load the token and tx history databases, respectively.
    Q_INVOKABLE bool loadTokenDB();
    Q_INVOKABLE bool loadHistoryDB(QString address);

    // (Re)Load ledger DB which contains ledger accoutns

    Q_INVOKABLE bool loadLedgerDB();

    // Set/Create default folder path when loading with Ledger.
    Q_INVOKABLE void setDefaultPathFolders();

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

    // ======================================================================
    // SEND SCREEN FUNCTIONS
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

    // Make a transaction with the collected data.
    // Emits txBuilt(), txSigned(), txSent() and txRetry()

    Q_INVOKABLE void makeTransaction(
      QString operation, QString from, QString to,
      QString value, QString txData, QString gas,
      QString gasPrice, QString pass
    );

    // ======================================================================
    // EXCHANGE SCREEN FUNCTIONS
    // ======================================================================

    // Get the first (lower) address from a pair
    Q_INVOKABLE QString getFirstFromPair(QString assetAddressA, QString assetAddressB);

    // Check if approval needs to be refreshed
    Q_INVOKABLE bool isApproved(QString amount, QString allowed);

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

    // Estimate the amount of coin/token that will be exchanged
    Q_INVOKABLE QString queryExchangeAmount(QString amount, QString fromName, QString toName);

    // Calculate the Account's share in AVAX/AVME/LP in the pool, respectively
    Q_INVOKABLE QVariantMap calculatePoolShares(
      QString asset1Reserves, QString asset2Reserves,
      QString userLiquidity, QString totalLiquidity
    );

    // Same as above but for advanced compound
    Q_INVOKABLE QVariantMap calculatePoolSharesForTokenValue(
      QString lowerReserves, QString higherReserves, QString totalLiquidity, QString LPTokenValue
    );
};

#endif  //QMLSYSTEM_H
