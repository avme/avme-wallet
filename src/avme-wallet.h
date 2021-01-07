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
#include <boost/filesystem.hpp>
#include <boost/thread.hpp>
#include <boost/lexical_cast.hpp>

#include <libdevcore/CommonIO.h>
#include <libdevcore/FileSystem.h>
#include <libdevcore/LoggingProgramOptions.h>
#include <libdevcore/SHA3.h>
#include <libethcore/KeyManager.h>
#include <libethcore/TransactionBase.h>

#include <json_spirit/JsonSpiritHeaders.h>

#include "network.h"

using namespace dev;
using namespace dev::eth;
using namespace boost::algorithm;
using namespace boost::filesystem;

class BadArgument: public Exception {};

class WalletManager {
  private:
    // The proper wallet
    KeyManager wallet;

    // Get object item from a JSON element.
    const json_spirit::mValue get_object_item(
      const json_spirit::mValue element, const std::string name
    );

    // Get array item from a JSON element.
    const json_spirit::mValue get_array_item(
      const json_spirit::mValue element, size_t index
    );

  public:
    // Set MAX_U256_VALUE for error handling.
    u256 MAX_U256_VALUE();

    // Load and authenticate a wallet from the given paths.
    bool loadWallet(path walletPath, path secretsPath, std::string walletPass);

    /**
     * Load the SecretStore (an object inside KeyManager that contains all secrets
     * for the addresses stored in it).
     */
    SecretStore& secretStore();

    // Create a new wallet, which should be loaded manually afterwards.
    bool createNewWallet(path walletPath, path secretsPath, std::string walletPass);

    // Create a new Account in the given wallet and encrypt it.
    std::vector<std::string> createNewAccount(
      std::string name, std::string pass, std::string hint, bool usesMasterPass
    );

    // Hash a given phrase to create a new address based on that phrase.
    void createKeyPairFromPhrase(std::string phrase);

    // Erase an Account from the wallet.
    bool eraseAccount(std::string account);

    // Check if an account is completely empty.
    bool accountIsEmpty(std::string account);

    // Select the appropriate account name or address stored in KeyManager from user input string.
    Address userToAddress(std::string const& input);

    // Load the secret key for a given address in the wallet.
    Secret getSecret(std::string const& signKey, std::string pass);

    // Create a key from a random string of characters. Check FixedHash.h for more info.
    KeyPair makeKey();

    // Convert a full amount of ETH in Wei to a fixed point, more human-friendly value.
    std::string convertWeiToFixedPoint(std::string amount, size_t digits);

    // Convert a fixed point amount of ETH to a full amount in Wei.
    std::string convertFixedPointToWei(std::string amount, int digits);

    // List the wallet's ETH accounts and their amounts.
    std::vector<std::string> listETHAccounts();

    /**
     * List the wallet's TAEX accounts and their amounts.
     * ERC-20 tokens need to be loaded in a different way, from their proper
     * contract address, beside their respective wallet address.
     */
    std::vector<std::string> listTAEXAccounts();

    // Get an automatic amount of fees for the transaction.
    std::string getAutomaticFee();

    // Build transaction data to send ERC-20 tokens.
    std::string buildTxData(std::string txValue, std::string destWallet);

    // Build an ETH transaction from user data.
    TransactionSkeleton buildETHTransaction(
      std::string signKey, std::string destWallet,
      std::string txValue, std::string txGas, std::string txGasPrice
    );

    // Build a TAEX transaction from user data.
    TransactionSkeleton buildTAEXTransaction(
      std::string signKey, std::string destWallet,
      std::string txValue, std::string txGas, std::string txGasPrice
    );

    // Sign a transaction with user credentials.
    std::string signTransaction(
      TransactionSkeleton txSkel, std::string pass, std::string signKey
    );

    // Send a transaction to the API provider for processing.
    std::string sendTransaction(std::string txidHex);

    // Decode a raw transaction and show information about it.
    void decodeRawTransaction(std::string rawTxHex);
};

