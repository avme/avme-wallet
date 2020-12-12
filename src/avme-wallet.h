// Aleth: Ethereum C++ client, tools and libraries.
// Copyright 2015-2019 Aleth Authors.
// Licensed under the GNU General Public License, Version 3.
/// @file
/// CLI module for key management.
#pragma once

#include <atomic>
#include <chrono>
#include <fstream>
#include <iosfwd>
#include <iostream>
#include <string>
#include <thread>
#include <vector>

#include <boost/algorithm/string.hpp>
#include <boost/algorithm/string/trim_all.hpp>
#include <boost/asio.hpp>
#include <boost/filesystem.hpp>
#include <boost/program_options.hpp>
#include <boost/program_options/options_description.hpp>
#include <boost/thread.hpp>

#include <libdevcore/CommonIO.h>
#include <libdevcore/FileSystem.h>
#include <libdevcore/LoggingProgramOptions.h>
#include <libdevcore/SHA3.h>
#include <libethcore/KeyManager.h>
#include <libethcore/TransactionBase.h>

using namespace std;
using namespace dev;
using namespace dev::eth;
using namespace boost::algorithm;

class BadArgument: public Exception {};

// Load a wallet.
KeyManager LoadWallet();

/**
 * Load the SecretStore (an object inside KeyManager that contains all secrets
 * for the addresses stored in it).
 */
SecretStore& secretStore(KeyManager myWallet);

// Create a new wallet.
KeyManager CreateNewWallet(bool default_wallet);

// Create a new Account in the user wallet and encrypt it.
void CreateNewAccount(KeyManager myWallet, std::string m_name);

// Hash a given phrase to create a new address based on that phrase.
void CreateKeyPairFromPhrase(std::string my_phrase);

// Erase an Account from the wallet.
void EraseAccount (KeyManager myWallet);

// Select the appropriate address stored in KeyManager from user input string.
Address userToAddress(std::string const& _s, KeyManager myWallet);

// Load the secret key for a designed address from the KeyManager wallet.
Secret getSecret(std::string const& _signKey, KeyManager myWallet);

// Create a password from prompt.
string createPassword(std::string const& _prompt);

// Create a key from a random string of characters. Check FixedHash.h for more info.
KeyPair makeKey();

/**
 * Send an HTTP GET Request to the blockchain API provider for everything
 * related to transactions and balances.
 */
std::string httpGetRequest(std::string httpquery);

// Parse a JSON string and get the appropriate value from the API provider.
std::vector<std::string> GetJSONValue(std::string myJson, std::string myValue);

// Convert a full amount of ETH in Wei to a fixed point, more human-friendly value.
std::string convertWeiToFixedPoint(std::string amount, size_t digits);

// Convert a fixed point amount of ETH to a full amount in Wei.
std::string convertFixedPointToWei(std::string amount, int digits);

/**
 * Load and show to the user the ETH Accounts contained in his wallet.
 * Also asks for the API provider to get the balances from these addresses.
 */
void ListETHAccounts(KeyManager mywallet);

/**
 * Same as above, but for TAEX.
 * Here is where it starts to become tricky. Tokens needs to be loaded
 * differently and from their proper contract address, beside the respective
 * wallet address.
 */
void ListTAEXAccounts(KeyManager mywallet);

// Get the ETH balance from an address from the API provider.
std::string GetETHBalance(std::string myAddress);

// Same thing as above, but for TAEX.
std::string GetTAEXBalance(std::string myAddress);

// Broadcast an ETH Transaction to the API provider.
std::string SendETHTransaction(std::string txidHex);

// Issue an ETH transaction, sign it and broadcast it.
void SignETHTransaction(KeyManager myWallet);

// Build a transaction data to send tokens.
std::string BuildTXData(std::string txvalue, std::string destwallet);

// Issue a TAEX transaction, sign it and broadcast it.
void SignTAEXTransaction(KeyManager myWallet);

