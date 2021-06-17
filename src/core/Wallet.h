// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef WALLET_H
#define WALLET_H

#include <atomic>
#include <fstream>
#include <iosfwd>
#include <iostream>
#include <mutex>
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
#include <boost/chrono.hpp>

#include <lib/devcore/CommonIO.h>
#include <lib/devcore/FileSystem.h>
#include <lib/devcore/SHA3.h>
#include <lib/ethcore/KeyManager.h>
#include <lib/ethcore/TransactionBase.h>

#include <core/BIP39.h>
#include <core/JSON.h>
#include <core/Utils.h>

using namespace dev;  // u256
using namespace dev::eth; // TransactionBase
using namespace boost::algorithm;
using namespace boost::filesystem;

/**
 * Class for the Wallet and related functions.
 * e.g. create/load, authenticate, manage Accounts and their tx history,
 * build/sign/send transactions, etc.
 */
class Wallet {
  private:
    // The "proper" Wallet. Functions interact directly with this object.
    KeyManager km;

    // Password hash, salt and the number of iterations used to create the hash.
    bytesSec passHash;
    h256 passSalt;
    int passIterations = 100000;

    // Current Account and its tx history.
    std::pair<std::string, std::string> currentAccount;
    std::vector<TxData> currentAccountHistory;

    // Lists of Accounts being used.
    std::map<std::string, std::string> accounts;
    std::map<std::string, std::string> ledgerAccounts;

  public:
    // Getters for private vars
    std::pair<std::string, std::string> getCurrentAccount() { return this->currentAccount; }
    std::vector<TxData> getCurrentAccountHistory() { return this->currentAccountHistory; }
    std::map<std::string, std::string> getAccounts() { return this->accounts; }
    std::map<std::string, std::string> getLedgerAccounts() { return this->ledgerAccounts; }

    // ======================================================================
    // WALLET MANAGEMENT
    // ======================================================================

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

    // ======================================================================
    // ACCOUNT MANAGEMENT
    // ======================================================================

    /**
     * (Re)Load the Wallet's Accounts into the list.
     * Any function that manipulates the KeyManager's Accounts should call
     * this one at the end to refresh the list.
     */
    void loadAccounts();

    /**
     * Create/import an Account in the Wallet, based on a given seed and index.
     * Automatically reloads the Account list on success.
     * Returns a pair with the address and name, or an empty pair on failure.
     */
    std::pair<std::string, std::string> createAccount(
      std::string &seed, int64_t index, std::string name, std::string &pass
    );

    /**
     * Import a Ledger account to the Wallet's account vector.
     */
    void importLedgerAccount(std::string address, std::string path);

    /**
     * Erase an Account from the Wallet.
     * Automatically reloads the Account list on success.
     * Returns true on success, false on failure.
     */
    bool eraseAccount(std::string address);

    /**
     * Check if an Account exists (is loaded on the list).
     * Returns true on success, false on failure.
     */
    bool accountExists(std::string address);

    /**
     * Set the current Account to be used by the Wallet.
     */
    void setCurrentAccount(std::string address);

    /**
     * Check if there's an Account being used by the Wallet.
     * Returns true on success, false on failure.
     */
    bool hasAccountSet();

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

    // ======================================================================
    // TRANSACTION/HISTORY MANAGEMENT
    // ======================================================================

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

    /**
     * Convert the transaction history from the current Account to a JSON array.
     */
    json_spirit::mArray txDataToJSON();

    /**
     * (Re)Load the transaction history for the current Account.
     */
    void loadTxHistory();

    /**
     * Save a new transaction to the history and reload the list.
     * Returns true on success, false on failure.
     */
    bool saveTxToHistory(TxData tx);

    /**
     * Query the confirmed status of *all* transactions made from the
     * current Account in the API and update accordingly, then reload the list.
     * Returns true on success, false on failure.
     */
    bool updateAllTxStatus();
};

#endif // WALLET_H

