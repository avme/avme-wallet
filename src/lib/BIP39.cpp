#include "BIP39.h"

bip3x::Bip39Mnemonic::MnemonicResult BIP39::createNewMnemonic() {
  return bip3x::Bip39Mnemonic::generate();
}

bip3x::HDKey BIP39::createKey(bip3x::Bip39Mnemonic::MnemonicResult phrase, std::string derivPath) {
  bip3x::bytes_64 seed = bip3x::HDKeyEncoder::makeBip39Seed(phrase.words);
  bip3x::HDKey rootKey = bip3x::HDKeyEncoder::makeBip32RootKey(seed);
  bip3x::HDKeyEncoder::makeExtendedKey(rootKey, derivPath);
  return rootKey;
}

bool BIP39::wordExists(std::string word) {
  struct words* wordlist;
  bip39_get_wordlist(NULL, &wordlist);
  size_t idx = wordlist_lookup_word(wordlist, word);
  return (idx != 0);
}

