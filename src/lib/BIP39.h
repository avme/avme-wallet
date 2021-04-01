#ifndef BIP39_H
#define BIP39_H

#include <string>
#include <vector>

#include <boost/lexical_cast.hpp>

#include <bip3x/bip39.h>
#include <bip3x/Bip39Mnemonic.h>
#include <bip3x/HDKeyEncoder.h>
#include <bip3x/utils.h>
#include <bip3x/wordlist.h>

#include "JSON.h"
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
};

#endif // BIP39_H
