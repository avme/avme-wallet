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

using namespace dev;
using namespace dev::eth;
using namespace boost::algorithm;
using namespace boost::filesystem;

class BadArgument: public Exception {};

// Load a wallet.
KeyManager LoadWallet(path walletPath, path secretsPath);

/**
 * Load the SecretStore (an object inside KeyManager that contains all secrets
 * for the addresses stored in it).
 */
SecretStore& secretStore(KeyManager wallet);

// Create a new wallet.
KeyManager CreateNewWallet(path walletPath, path secretsPath, std::string pass);

// Create a new Account in the user wallet and encrypt it.
void CreateNewAccount(KeyManager wallet, std::string name, std::string pass, std::string hint);

// Hash a given phrase to create a new address based on that phrase.
void CreateKeyPairFromPhrase(std::string phrase);

// Erase an Account from the wallet.
bool EraseAccount(KeyManager wallet, std::string account);

// Select the appropriate address stored in KeyManager from user input string.
Address userToAddress(std::string const& input, KeyManager wallet);

// Load the secret key for a designed address from the KeyManager wallet.
Secret getSecret(KeyManager wallet, std::string const& signKey, std::string pass);

// Create a key from a random string of characters. Check FixedHash.h for more info.
KeyPair makeKey();

/**
 * Send an HTTP GET Request to the blockchain API provider for everything
 * related to transactions and balances.
 */
std::string httpGetRequest(std::string httpquery);

// Parse a JSON string and get the appropriate value from the API provider.
std::vector<std::string> GetJSONValue(std::string json, std::string value);

// Convert a full amount of ETH in Wei to a fixed point, more human-friendly value.
std::string convertWeiToFixedPoint(std::string amount, size_t digits);

// Convert a fixed point amount of ETH to a full amount in Wei.
std::string convertFixedPointToWei(std::string amount, int digits);

/**
 * List all the ETH accounts contained in a given wallet.
 * Also asks for the API provider to get the balances from these addresses.
 */
std::vector<std::string> ListETHAccounts(KeyManager wallet);

/**
 * Same as above, but for TAEX.
 * Here is where it starts to become tricky. Tokens needs to be loaded
 * differently and from their proper contract address, beside the respective
 * wallet address.
 */
std::vector<std::string> ListTAEXAccounts(KeyManager wallet);

// Get the ETH balance from an address from the API provider.
std::string GetETHBalance(std::string address);

// Same thing as above, but for TAEX.
std::string GetTAEXBalance(std::string address);

// Broadcast a transaction to the API provider.
std::string sendTransaction(std::string txidHex);

// Build a transaction data to send tokens.
std::string BuildTXData(std::string txValue, std::string destWallet);

// Issue an ETH transaction, sign it and broadcast it.
void SignETHTransaction(
  KeyManager wallet, std::string pass, std::string signKey, std::string destWallet,
  std::string txValue, std::string txGas, std::string txGasPrice
);

// Issue a TAEX transaction, sign it and broadcast it.
void SignTAEXTransaction(
  KeyManager wallet, std::string pass, std::string signKey, std::string destWallet,
  std::string txValue, std::string txGas, std::string txGasPrice
);

