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
#include <core/JSON.h>
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
    bool ledgerFlag;

  public slots:
    void cleanAndClose() {
      // TODO: Clean database, threads, etc before closing the program
      return;
    }

  signals:
    // Common signals
    void hideMenu();
    void goToOverview();

    // Account screen signals
    void accountGenerated(QVariantMap data);
    void ledgerAccountGenerated(QVariantMap data);
    void accountCreated(QVariantMap data);
    void accountCreationFailed();

    // Overview screen signals
    void accountBalancesUpdated(QVariantMap data);
    void accountFiatBalancesUpdated(QVariantMap data);
    void walletBalancesUpdated(QVariantMap data);
    void walletFiatBalancesUpdated(QVariantMap data);
    void roiCalculated(QString ROI);
    void marketDataUpdated(
      int days, QString currentAVAXPrice, QString currentAVMEPrice, QVariantList AVMEHistory
    );

    // History screen signals
    void historyLoaded(QVariantList data);

    // Send screen signals
    void operationOverride(
      QString op, QString amountCoin, QString amountToken, QString amountLP
    );
    void txStart(
      QString operation, QString to,
      QString coinAmount, QString tokenAmount, QString lpAmount,
      QString gasLimit, QString gasPrice, QString pass
    );
    void txBuilt(bool b);
    void txSigned(bool b, QString msg);
    void txSent(bool b, QString linkUrl);
    void txRetry();

    // Exchange screen signals
    // TODO: split into exchangeAllowancesUpdated and stakingAllowancesUpdated
    void allowancesUpdated(
      QString exchangeAllowance, QString liquidityAllowance, QString stakingAllowance, QString compoundAllowance
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

    // Staking screen signals
    void rewardUpdated(QString poolReward);
    void compoundUpdated(QString reinvestReward);

  public:
    // ======================================================================
    // COMMON FUNCTIONS
    // ======================================================================

    // Getters/Setters for private vars
    Q_INVOKABLE bool getFirstLoad() { return firstLoad; }
    Q_INVOKABLE void setFirstLoad(bool b) { firstLoad = b; }
    Q_INVOKABLE bool getLedgerFlag() { return ledgerFlag; }
    Q_INVOKABLE void setLedgerFlag(bool b) { ledgerFlag = b; }

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

    // ======================================================================
    // START/WALLET SCREEN FUNCTIONS
    // ======================================================================

    // Check if a Wallet exists in a given folder
    Q_INVOKABLE bool checkFolderForWallet(QString folder);

    // Create, import, load and close a Wallet, respectively
    // TODO: join create and import with 'QString seed = ""' as a parameter
    Q_INVOKABLE bool createWallet(QString folder, QString pass);
    Q_INVOKABLE bool importWallet(QString seed, QString folder, QString pass);
    Q_INVOKABLE bool loadWallet(QString folder, QString pass);
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

    // Get the list of registered tokens from the Wallet
    Q_INVOKABLE QVariantList getARC20Tokens();

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

    // Check if an Account has loaded the balances
    // TODO: check this later
    //Q_INVOKABLE bool accountHasBalances(QString address);

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

    // Import a Ledger account to the Wallet
    Q_INVOKABLE void importLedgerAccount(QString address, QString path);

    // Erase an Account
    Q_INVOKABLE bool eraseAccount(QString account);

    // Check if Account exists
    Q_INVOKABLE bool accountExists(QString account);

    // Get an Account's private keys
    Q_INVOKABLE QString getPrivateKeys(QString account, QString pass);

    // Get an Account's AVAX balance and value in fiat, respectively.
    // TODO: use signals on both
    Q_INVOKABLE QString getAccountAVAXBalance(QString address);
    Q_INVOKABLE QString getAccountAVAXValue(QString address, QString amount);

    // ======================================================================
    // OVERVIEW SCREEN FUNCTIONS
    // ======================================================================

    // TODO: check all of those later
    // Get the crypto and fiat balances for an Account and the whole Wallet, respectively.
    // Emits, in order: accountBalancesUpdated(), accountFiatBalancesUpdated(),
    // walletBalancesUpdated() and walletFiatBalancesUpdated()
    //Q_INVOKABLE void getAccountBalancesOverview(QString address);
    //Q_INVOKABLE void getAccountFiatBalancesOverview(QString address);
    //Q_INVOKABLE void getAllAccountBalancesOverview();
    //Q_INVOKABLE void getAllAccountFiatBalancesOverview();

    // Get the current ROI for the staking reward.
    // Emits roiCalculated()
    Q_INVOKABLE void calculateRewardCurrentROI();

    // Get data for the market chart for the last X days (most to least recent).
    // Emits marketDataUpdated()
    Q_INVOKABLE void getMarketData(int days);

    // ======================================================================
    // HISTORY SCREEN FUNCTIONS
    // ======================================================================

    // List the Account's transactions, updating their statuses on the spot if required.
    // Emits historyLoaded()
    Q_INVOKABLE void listAccountTransactions(QString address);

    // Update the statuses of all transactions in the list
    Q_INVOKABLE void updateTransactionStatus();

    // ======================================================================
    // SEND SCREEN FUNCTIONS
    // ======================================================================

    // Get gas price from network
    Q_INVOKABLE QString getAutomaticFee();

    // Create a RegExp for transaction amount inputs
    Q_INVOKABLE QRegExp createTxRegExp(int decimals);

    // Calculate the real amount of a max AVAX transaction (minus gas costs)
    Q_INVOKABLE QString getRealMaxAVAXAmount(QString gasLimit, QString gasPrice);

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
     * TODO: maybe invert this logic to hasFunds?
     */
    Q_INVOKABLE bool hasInsufficientFunds(
      QString senderAmount, QString receiverAmount, int decimals
    );

    // Make a transaction with the collected data.
    // Emits txBuilt(), txSigned(), txSent() and txRetry()
    Q_INVOKABLE void makeTransaction(
      QString operation, QString to,
      QString coinAmount, int coinDecimals,
      QString tokenAmount, int tokenDecimals,
      QString lpAmount, int lpDecimals,
      QString gasLimit, QString gasPrice, QString pass
    );

    // ======================================================================
    // EXCHANGE SCREEN FUNCTIONS
    // ======================================================================

    // Get approval amounts for exchange and liquidity.
    // Emits allowancesUpdated()
    Q_INVOKABLE void getAllowances();

    // Check if approval needs to be refreshed
    Q_INVOKABLE bool isApproved(QString amount, QString allowed);

    // Update reserves for the exchange screen.
    // Emits exchangeDataUpdated()
    Q_INVOKABLE void updateExchangeData(QString tokenNameA, QString tokenNameB);

    // Update reserves and liquidity supply for the exchange screen.
    // Emits liquidityDataUpdated()
    Q_INVOKABLE void updateLiquidityData(QString tokenNameA, QString tokenNameB);

    /**
     * Calculate the estimated output amount and price impact for a
     * coin/token exchange, respectively
     */
    Q_INVOKABLE QString calculateExchangeAmount(
      QString amountIn, QString reservesIn, QString reservesOut
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
      QString lowerReserves, QString higherReserves, QString percentage
    );

    // Estimate the amount of coin/token that will be exchanged
    Q_INVOKABLE QString queryExchangeAmount(QString amount, QString fromName, QString toName);

    // Calculate the Account's share in AVAX/AVME/LP in the pool, respectively
    Q_INVOKABLE QVariantMap calculatePoolShares(
      QString lowerReserves, QString higherReserves, QString totalLiquidity
    );

    // Same as above but for advanced compound
    Q_INVOKABLE QVariantMap calculatePoolSharesForTokenValue(
      QString lowerReserves, QString higherReserves, QString totalLiquidity, QString LPTokenValue
    );

    // ======================================================================
    // EXCHANGE SCREEN FUNCTIONS
    // ======================================================================

    // Get the staking and compound rewards for a given Account, respectively.
    // Emits, in order: rewardUpdated() and compoundUpdated()
    Q_INVOKABLE void getPoolReward();
    Q_INVOKABLE void getCompoundReward();
};

#endif  //QMLSYSTEM_H
