// Wallet management, based on Ethereum's Aleth libraries.
// Aleth: Ethereum C++ client, tools and libraries.
// Copyright 2015-2019 Aleth Authors.
// Licensed under the GNU General Public License, Version 3.
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
#include <ctime>
#include <iomanip>

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

#include <bip3x/bip39.h>
#include <bip3x/Bip39Mnemonic.h>
#include <bip3x/HDKeyEncoder.h>
#include <bip3x/utils.h>
#include <bip3x/wordlist.h>

#include "network.h"
#include "json.h"
#include "transactions.h"

using namespace dev;
using namespace dev::eth;
using namespace boost::algorithm;
using namespace boost::filesystem;

class BadArgument: public Exception {};

// Struct for account data.
typedef struct WalletAccount {
  std::string id;
  std::string privKey;
  std::string name;
  std::string address;
  std::vector<std::string> seed;
  std::string balanceAVAX;
  std::string balanceAVME;
  std::string balanceLPFree;
  std::string balanceLPLocked;
} WalletAccount;

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

    // Hash the Wallet's passphrase with a random salt and store both for auth checks.
    void storeWalletPass(std::string pass);

    // Check if the passphrase input matches the stored hash.
    bool checkWalletPass(std::string pass);

    /**
     * Load and authenticate a Wallet from the given paths.
     * Returns true on success, false on failure.
     */
    bool loadWallet(path walletFile, path secretsPath, std::string pass);

    /**
     * Create a new Wallet, which should be loaded manually afterwards.
     * Returns true on success, false on failure.
     */
    bool createNewWallet(path walletFile, path secretsPath, std::string pass);

    /**
     * Generate a new random mnemonic phrase.
     * Returns the mnemonic phrase.
     */
    bip3x::Bip39Mnemonic::MnemonicResult createNewMnemonic();

    /**
     * Create a new public/private root key pair based on a mnemonic phrase.
     * This is used in conjunction with a derivation path (see below)
     * and index (starting at 0) to generate "infinite" Accounts/key pairs.
     * Returns the root key pair.
     */
    bip3x::HDKey createBip32RootKey(bip3x::Bip39Mnemonic::MnemonicResult phrase);

    /**
     * Create a public/private key pair for an Account using the
     * root key pair and a derivation path.
     * Returns the key pair for the Account.
     */
    bip3x::HDKey createBip32Key(bip3x::HDKey rootKey, std::string derivPath);

    /**
     * Provide a list of "infinite" Accounts based on the root key pair,
     * derivation path and starting from a given index. e.g.:
     * "m/44'/60'/0'/0" is the default derivation path for Ethereum.
     * "m/44'/60'/0'/0/0" will generate the address 0xaaaaaaaaaaaaaaaaaa...
     * "m/44'/60'/0'/0/1" will generate the address 0xbbbbbbbbbbbbbbbbbb...
     * "m/44'/60'/0'/0/2" will generate the address 0xcccccccccccccccccc...
     * and so on and so forth.
     * Since we are storing the keys in keystore files, we can only store
     * one key pair at a time, so the user has to choose an Account from
     * the list to be imported into the Wallet.
     * Returns the Account list.
     */
    // TODO: find a way to store the root key so the user won't need to
    // re-enter the mnemonic to create a second Account based on the same mnemonic
    // TODO: the user should be able to choose the derivation path they want to use (it's hardcoded right now)
    std::vector<std::string> addressListBasedOnRootIndex(bip3x::HDKey rootKey, int64_t index);

    /**
     * Check if a word exists in the English BIP39 wordlist.
     * Returns true on success, false on failure.
     */
    bool wordExists(std::string word);

    /**
     * Create a new Account in the given Wallet and encrypt it.
     * See the WalletAccount struct for details on what an Account has, or
     * https://ethereum.org/en/developers/docs/accounts/ for more info on Accounts.
     * Returns a struct with the Account's data.
     */
    WalletAccount createNewAccount(std::string name, std::string pass);

    /**
     * Import an Account from a given BIP39 key pair.
     * Returns a struct with the Account's data.
     */
    WalletAccount importAccount(std::string name, std::string pass, bip3x::HDKey keyPair);

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
     * Select the appropriate Account name or address stored in
     * KeyManager from user input string.
     * Returns the proper address in Hex (without the "0x" part),
     * or an empty address on failure.
     */
    Address userToAddress(std::string const& input);

    /**
     * Check if an Account exists in the Wallet.
     * Returns true on success, false on failure.
     */
    bool accountExists(std::string account);

    /**
     * Load the secret key for a given address in the Wallet.
     * Returns the proper Secret, or an "empty" Secret on failure.
     */
    Secret getSecret(std::string const& address, std::string pass);

    /**
     * Convert a full Wei amount to a fixed point amount and vice-versa,
     * in the given amount of digits/decimals.
     * BTC has 8 decimals but is considered a full integer in code, so 1.0 BTC
     * actually means 100000000 satoshis.
     * Likewise with ETH, AVAX, etc., which have 18 digits, so 1.0 ETH/AVAX
     * actually means 1000000000000000000 Wei.
     * This also applies to their respective tokens.
     * Operations are actually done with full amounts, but to make those
     * operations more human-friendly, we show to and collect from the user
     * fixed point values, then convert those to full amounts and back.
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
     * when building a transaction (1 Gwei = 10^9 Wei).
     */
    std::string getAutomaticFee();

    /**
     * Build transaction data to send tokens.
     * Returns a string with said data.
     */
    std::string buildTxData(std::string txValue, std::string destWallet);

    /**
     * Build a coin or token transaction from user data.
     * Returns a skeleton filled with data for a coin or token transaction,
     * respectively, which has to be signed.
     */
    TransactionSkeleton buildAVAXTransaction(
      std::string srcAddress, std::string destAddress,
      std::string txValue, std::string txGas, std::string txGasPrice
    );
    TransactionSkeleton buildAVMETransaction(
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

    /**
     * Approve a given Account for staking.
     * Returns true on success, false on failure.
     */
    bool approveStaking(std::string account);

    /**
     * Check if a given Account was approved for staking.
     * Approval is checked by searching an approval transaction in the
     * blockchain, and checking if it was successfully made.
     * Returns true on success, false on failure.
     */
    bool isApprovedForStaking(std::string account);

    /**
     * Stake/unstake a given amount of LP tokens in the pool, respectively.
     * Returns true on success, false on failure.
     */
    bool stake(std::string account, std::string lpAmount);
    bool unstake(std::string account, std::string lpAmount);

    /**
     * Harvest available farmed tokens in the pool for the given Account.
     * Returns true on sucess, false on failure.
     */
    bool harvest(std::string account);

    /**
     * Exit the LP pool (harvest all + unstake all).
     * This would be the equivalent of calling harvest() then unstake()
     * with a max amount.
     * Returns true on success, false on failure.
     */
    bool exitPool(std::string account);
};

#endif // WALLET_H
