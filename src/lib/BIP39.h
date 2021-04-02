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
   * Save an mnemonic phrase to an json file in the default path.
   * This should be called only when creating an new wallet, a.k.a first time running the wallet
   * for the purpose of avoiding overwritting an already saved mnemonic.
   */
  std::pair<bool,std::string> saveEncryptedMnemonic(bip3x::Bip39Mnemonic::MnemonicResult &mnemonic, std::string &password);
  
  /**
   * Load an already saved mnemonic from an json file on the default path.
   */
   
  std::pair<bool,std::string>  loadEncryptedMnemonic(bip3x::Bip39Mnemonic::MnemonicResult &mnemonic, std::string &password);

  /**
   * Check if a word exists in the English BIP39 wordlist.
   * Returns true on success, false on failure.
   */
  bool wordExists(std::string word);
};

#endif // BIP39_H
