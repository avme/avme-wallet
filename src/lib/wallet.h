// Aleth: Ethereum C++ client, tools and libraries.
// Copyright 2015-2019 Aleth Authors.
// Licensed under the GNU General Public License, Version 3.
/// @file
/// CLI module for key management.
#ifndef WALLET_H
#define WALLET_H

#include <atomic>
#include <chrono>
#include <fstream>
#include <iosfwd>
#include <iostream>
#include <string>
#include <thread>
#include <vector>
#include <mutex>

#include <boost/algorithm/string.hpp>
#include <boost/algorithm/string/trim_all.hpp>
#include <boost/filesystem.hpp>
#include <boost/thread.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/chrono.hpp>

#include <libdevcore/CommonIO.h>
#include <libdevcore/FileSystem.h>
#include <libdevcore/LoggingProgramOptions.h>
#include <libdevcore/SHA3.h>
#include <libethcore/KeyManager.h>
#include <libethcore/TransactionBase.h>

#include <json_spirit/JsonSpiritHeaders.h>

#include "network.h"
#include "json.h"

using namespace dev;
using namespace dev::eth;
using namespace boost::algorithm;
using namespace boost::filesystem;

class BadArgument: public Exception {};

// Struct for account data
typedef struct WalletAccount {
  std::string id;
  std::string privKey;
  std::string name;
  std::string address;
  std::string balanceAVAX;
  std::string balanceTAEX;
} WalletAccount;

// Struct for raw transaction data
typedef struct WalletTxData {
  std::string hex;
  std::string type;
  std::string code;
  std::string to;
  std::string from;
  std::string data;
  std::string creates;
  std::string value;
  std::string nonce;
  std::string gas;
  std::string price;
  std::string hash;
  std::string v;
  std::string r;
  std::string s;
} WalletTxData;

// Mutex for account refresh thread.
static std::mutex balancesThreadLock;

class WalletManager {
  private:
    // The proper Wallet.
    KeyManager wallet;

    // The Wallet's password hash, salt and iterations for the hash.
    bytesSec passHash;
    h256 passSalt;
    int passIterations = 100000;

    // Called by loadWalletAccounts().
    void reloadAccountsBalancesThread();

  public:
    // Set MAX_U256_VALUE for error handling.
    u256 MAX_U256_VALUE();

    // Hash the Wallet's password with a random salt and store both for auth checks.
    void storeWalletPass(std::string pass);

    // Check if the password input matches the stored hash.
    bool checkWalletPass(std::string pass);

    /**
     * Load and authenticate a wallet from the given paths.
     * Returns true on success, false on failure.
     */
    bool loadWallet(path walletFile, path secretsPath, std::string pass);

    /**
     * Create a new Wallet, which should be loaded manually afterwards.
     * Returns true on success, false on failure.
     */
    bool createNewWallet(path walletFile, path secretsPath, std::string pass);

    /**
     * Create a new Account in the given Wallet and encrypt it.
     * An Account contains an AVAX address and other stuff.
     * See https://ethereum.org/en/developers/docs/accounts/ for more info.
     * Returns a struct with the account's data.
     */
    WalletAccount createNewAccount(std::string name, std::string pass);

    /**
     * Create a private/public key pair from random or a given string of characters.
     * Check FixedHash.h for more info.
     * Returns the key pair.
     */
    KeyPair makeKey(std::string phrase = "");

    /**
     * Erase an Account from the Wallet.
     * Returns true on success, false on failure.
     */
    bool eraseAccount(std::string account);

    /**
     * Select the appropriate Account name or address stored in KeyManager
     * from user input string.
     * Returns the proper address in Hex (without the "0x" part), or an empty
     * address on failure.
     */
    Address userToAddress(std::string const& input);

    /**
     * Check if an Account exists.
     * Returns true on success, false on failure.
     */
    bool accountExists(std::string account);

    /**
     * Load the secret key for a given address in the wallet.
     * Returns the proper Secret, or aborts the program on failure.
     */
    Secret getSecret(std::string const& address, std::string pass);

    /**
     * Convert a full Wei amount to a fixed point amount and vice-versa.
     * BTC has 8 decimals but is considered a full integer in code, so 1.0 BTC
     * actually means 100000000 satoshis.
     * Likewise with ETH, AVAX, etc., which have 18 digits, so 1.0 ETH/AVAX
     * actually means 1000000000000000000 Wei.
     * Operations are actually done with the full amounts in Wei, but to make
     * those operations more human-friendly, we show to/collect from the user
     * fixed point values, and convert those to Wei and back as required.
     * Returns the fixed point and full amounts, respectively.
     */
    std::string convertWeiToFixedPoint(std::string amount, size_t digits);
    std::string convertFixedPointToWei(std::string amount, int decimals);

    /**
     * Load the Wallet's Accounts and their coin and token balances.
     * Tokens are loaded from their proper contract address, beside their
     * respective Wallet Accounts.
     * loadWalletAccounts(true) should be called only once, right after
     * loading the Wallet, which will create a thread that occasionally calls
     * ReadWriteWalletVector, which refreshes the Account list on the background.
     * loadWalletAccounts(false) should be called after any add/remove Account
     * operation, or after a transaction has been done.
     * reloadAccountsBalances is a forced Account balance refresh.
     */
    void reloadAccountsBalances();
    void loadWalletAccounts(bool start);
    std::vector<WalletAccount> ReadWriteWalletVector(
      bool write, bool changeVector, std::vector<WalletAccount> accountToWrite
    );

    /**
     * Get the recommended gas price for a transaction.
     * Returns the gas price in Gwei, which has to be converted to Wei
     * when building a transaction.
     */
    std::string getAutomaticFee();

    /**
     * Build transaction data to send tokens.
     * Returns a string with said data.
     */
    std::string buildTxData(std::string txValue, std::string destWallet);

    /**
     * Build a coin or token transaction from user data.
     * Returns a skeleton filled with data for a coin/token transaction,
     * respectively, which has to be signed.
     */
    TransactionSkeleton buildAVAXTransaction(
      std::string srcAddress, std::string destAddress,
      std::string txValue, std::string txGas, std::string txGasPrice
    );
    TransactionSkeleton buildTAEXTransaction(
      std::string srcAddress, std::string destAddress,
      std::string txValue, std::string txGas, std::string txGasPrice
    );

    /**
     * Sign a transaction with user credentials.
     * Returns a string with the raw signed transaction in Hex,
     * or an empty string on failure.
     */
    std::string signTransaction(
      TransactionSkeleton txSkel, std::string pass, std::string address
    );

    /**
     * Send a signed transaction for processing.
     * Returns a link to the transaction in the blockchain.
     */
    std::string sendTransaction(std::string txidHex);

    /**
     * Decode a raw transaction in Hex.
     * Returns a structure with the transaction's data.
     */
    WalletTxData decodeRawTransaction(std::string rawTxHex);
};

#endif // WALLET_H
