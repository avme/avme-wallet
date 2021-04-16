// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef WALLET_H
#define WALLET_H

#include <atomic>
#include <fstream>
#include <iosfwd>
#include <iostream>
#include <string>
#include <thread>
#include <vector>
#include <ctime>
#include <iomanip>

#include <boost/algorithm/string.hpp>
#include <boost/algorithm/string/trim_all.hpp>
#include <boost/filesystem.hpp>
#include <boost/thread.hpp>
#include <boost/lexical_cast.hpp>

#include <libdevcore/CommonIO.h>
#include <libdevcore/FileSystem.h>
#include <libdevcore/LoggingProgramOptions.h>
#include <libdevcore/SHA3.h>
#include <libethcore/KeyManager.h>
#include <libethcore/TransactionBase.h>

#include "Account.h"
#include "BIP39.h"
#include "Network.h"
#include "Utils.h"

using namespace dev;  // u256
using namespace dev::eth;
using namespace boost::algorithm;
using namespace boost::filesystem;

/**
 * Class for the Wallet and related functions.
 * e.g. create/load, authenticate, manage Accounts, build/sign/send transactions, etc.
 */
class Wallet {
  private:
    KeyManager km;  // The "proper" Wallet. Functions interact directly with this object.
    bytesSec passHash;
    h256 passSalt;
    int passIterations = 100000;

  public:
    std::vector<Account> accounts;  // The list of Accounts that belong to this Wallet.

    /**
     * Create a new Wallet, which should be loaded manually afterwards.
     * Automatically hashes+salts the passphrase and stores both.
     * Returns true on success, false on failure.
     */
    bool create(boost::filesystem::path folder, std::string pass);

    /**
     * Load and authenticate a Wallet from the given paths.
     * Automatically hashes+salts the passphrase and stores both.
     * Returns true on success, false on failure.
     */
    bool load(boost::filesystem::path folder, std::string pass);

    /**
     * Clean Wallet data.
     */
    void close();

    /**
     * Check if the Wallet is properly loaded.
     * Returns true on success, false on failure.
     */
    bool isLoaded();

    /**
     * Check if the passphrase input matches the stored hash.
     * Returns true on success, false on failure.
     */
    bool auth(std::string pass);

    /**
     * Create/import an Account in the Wallet, based on a given seed and index.
     * Returns a struct with the Account's data, or an empty struct on failure.
     */
    Account createAccount(
      std::string &seed, int64_t index, std::string name, std::string &pass
    );

    /**
     * Load the Wallet's Accounts and their coin and token balances.
     * Tokens are loaded from their proper contract address, beside their
     * respective Wallet Accounts.
     */
    void loadAccounts();

    /**
     * Get an Account from the list using its name or address, respectively.
     * Returns the initialized Account object, or an "empty" one if not found.
     */
    Account getAccountByName(std::string name);
    Account getAccountByAddress(std::string address);

    /**
     * Erase an Account from the Wallet.
     * Returns true on success, false on failure.
     */
    bool eraseAccount(std::string account);

    /**
     * Check if an Account exists in the Wallet.
     * Returns true on success, false on failure.
     */
    bool accountExists(std::string account);

    /**
     * Select the appropriate Account name or address stored in
     * KeyManager from user input string.
     * Returns the proper address in Hex (without the "0x" part),
     * or an empty address on failure.
     */
    Address userToAddress(std::string const& input);

    /**
     * Get the secret key for a given Account.
     * Returns the proper Secret, or an "empty" Secret on failure.
     */
    Secret getSecret(std::string const& account, std::string pass);

    /**
     * Build a transaction from user data.
     * Coin transactions would have a blank dataHex and the "to" address
     * being the destination address.
     * Token transactions would have a filled dataHex, 0 txValue and
     * the "to" address being the token contract's address.
     * Returns a skeleton filled with data for the transaction, which has to be signed.
     */
    TransactionSkeleton buildTransaction(
      std::string from, std::string to, std::string value,
      std::string gasLimit, std::string gasPrice, std::string dataHex = ""
    );

    /**
     * Sign a transaction with user credentials.
     * Returns a string with the raw signed transaction in Hex,
     * or an empty string on failure.
     */
    std::string signTransaction(TransactionSkeleton txSkel, std::string pass);

    /**
     * Send a signed transaction for broadcast and store it in history if successful.
     * Returns a link to the transaction in the blockchain, or an empty string on failure.
     */
    std::string sendTransaction(std::string txidHex, std::string operation);
};

#endif // WALLET_H

