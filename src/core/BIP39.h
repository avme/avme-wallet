// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef BIP39_H
#define BIP39_H

#include <string>
#include <vector>
#include <utility>

#include <boost/lexical_cast.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string/replace.hpp>

#include <openssl/rand.h>

#include <bip3x/bip39.h>
#include <bip3x/Bip39Mnemonic.h>
#include <bip3x/HDKeyEncoder.h>
#include <bip3x/utils.h>
#include <bip3x/wordlist.h>

#include "Cipher.h"
#include "Utils.h"

/**
 * Namespace for BIP39-related functions (mnemonics, wordlists, etc.).
 */
namespace BIP39 {
  /**
   * Generate a new random mnemonic phrase.
   * Returns the mnemonic phrase.
   */
  bip3x::Bip39Mnemonic::MnemonicResult createNewMnemonic();

  /**
   * Create a public/private key pair for an Account using a mnemonic phrase
   * and a derivation path (e.g. "m/44'/60'/0'/0" for Ethereum).
   * Returns the key pair for the Account.
   */
  bip3x::HDKey createKey(std::string phrase, std::string derivPath);

  /**
   * Check if a word exists in the English BIP39 wordlist.
   * Returns true on success, false on failure.
   */
  bool wordExists(std::string word);

  /**
   * Generate a list with 10 Accounts based on a given seed and a starting index.
   * Returns a vector with the addresses.
   */
  std::vector<std::string> generateAccountsFromSeed(std::string seed, int64_t start);

  /**
   * Save a mnemonic phrase to a JSON file in the default path.
   * This should be called only when creating a new wallet,
   * to avoid the risk of overwritting an already saved mnemonic.
   * Returns a bool/string pair (write success and potential error message).
   */
  std::pair<bool,std::string> saveEncryptedMnemonic(
    bip3x::Bip39Mnemonic::MnemonicResult &mnemonic, std::string &password
  );

  /**
   * Load an already saved mnemonic from a JSON file in the default path.
   * Returns a bool/string pair (read success and potential error message).
   */
  std::pair<bool,std::string> loadEncryptedMnemonic(
    bip3x::Bip39Mnemonic::MnemonicResult &mnemonic, std::string &password
  );
};

#endif // BIP39_H
