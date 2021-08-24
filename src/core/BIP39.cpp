// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "BIP39.h"

bip3x::Bip39Mnemonic::MnemonicResult BIP39::createNewMnemonic() {
  return bip3x::Bip39Mnemonic::generate();
}

bip3x::HDKey BIP39::createKey(std::string phrase, std::string derivPath) {
  bip3x::bytes_64 seed = bip3x::HDKeyEncoder::makeBip39Seed(phrase);
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

std::vector<std::string> BIP39::generateAccountsFromSeed(std::string seed, int64_t index) {
  std::vector<std::string> ret;
  for (int64_t i = 0; i < 10; ++i, ++index) {
    std::string address;
    std::string derivPath = "m/44'/60'/0'/0/" + boost::lexical_cast<std::string>(index);
    bip3x::HDKey rootKey = BIP39::createKey(seed, derivPath);
    KeyPair k(Secret::frombip3x(rootKey.privateKey));
    address += boost::lexical_cast<std::string>(index) + " " + "0x" + k.address().hex();
    ret.push_back(address);
  }
  return ret;
}

std::pair<bool,std::string> BIP39::saveEncryptedMnemonic(
  bip3x::Bip39Mnemonic::MnemonicResult &mnemonic, std::string &password
) {
  std::pair <bool,std::string> result;
  boost::filesystem::path seedPath = Utils::walletFolderPath.string() + "/wallet/c-avax/seed.json";

  // Initialize the seed json and cipher, then create the salt.
  // Use exactly as many bytes for the cipher as needed.
  json seedJson;
  Cipher cipher("aes-256-cbc", "sha256");
  unsigned char saltBytes[CIPHER_SALT_BYTES] = {0};

  /**
   * Use std::random_device (thin wrapper around /dev/urandom) on Linux,
   * it is the most secure source of entropy on the system.
   */
#ifdef __linux__
  std::random_device rd;
  for (int i = 0; i < CIPHER_SALT_BYTES; i++){ saltBytes[i] = rd(); }
#else
#ifdef MERSENNE_TWISTER
  std::mt19937 rd(std::random_device{}());
  for (int i = 0; i < CIPHER_SALT_BYTES; i++){ saltBytes[i] = rd(); }
#else
  RAND_bytes(saltBytes, CIPHER_SALT_BYTES); // OpenSSL fallback
#endif // MERSENNE_TWISTER
#endif // __linux__

  /**
   * TODO: use full entropy instead of half entropy.
   * As stated by keggek:
   * @GEK bugfix- you were taking your 32 bytes of perfectly good randomness,
   * and reducing them down to 4 (as 8 hex digits).
   */
  std::string salt = toHex(
    dev::sha3(std::string((char*)saltBytes, sizeof(saltBytes)), false)
  ).substr(0, CIPHER_SALT_BYTES);
  /*
  std::string salt;
  for(int i = 0; i < CIPHER_SALT_BYTES; i++){ salt.push_back(' '); }
  memcpy((char*)salt.c_str(), saltBytes, CIPHER_SALT_BYTES);
  */

  // Encrypt the mnemonic
  std::string encryptedPhrase;
  try {
    encryptedPhrase = cipher.encrypt(mnemonic.raw, password, salt);
    // Replace newlines with space, when saving to JSON newlines will break it
    boost::replace_all(encryptedPhrase, "\n", " ");
  } catch (std::exception &e) {
    result.first = false;
    result.second = "Error when encrypting: ";
    result.second += e.what();
    Utils::logToDebug(result.second);
    return result;
  }

  // Add information to JSON object and write it in a file
  seedJson["seed"] = encryptedPhrase;
  seedJson["salt"] = salt;
  std::string success = Utils::writeJSONFile(seedJson, seedPath);
  if (success.empty()) {
    result.first = true;
    result.second = "";
  } else {
    json jsonErr = json::parse(success);
    result.first = false;
    result.second = "Error happened when writing JSON file: "
      + jsonErr["ERROR"].get<std::string>();
    Utils::logToDebug(result.second);
  }
  return result;
}

std::pair<bool,std::string> BIP39::loadEncryptedMnemonic(
  bip3x::Bip39Mnemonic::MnemonicResult &mnemonic, std::string &password
) {
  std::pair <bool,std::string> result;
  boost::filesystem::path seedPath = Utils::walletFolderPath.string() + "/wallet/c-avax/seed.json";

  // Initialize the cipher, read the JSON file and check for errors
  Cipher cipher("aes-256-cbc", "sha256");
  json seedJson = json::parse(Utils::readJSONFile(seedPath));
  try {
    // This is the error block, the logic is inverted here
    std::string error = seedJson["ERROR"].get<std::string>();
    result.first = false;
    result.second = "Error happened when reading JSON file: " + error;
    Utils::logToDebug(result.second);
    return result;
  } catch (std::exception &e) {}

  // Read JSON to string and check for errors
  std::string encryptedPhrase;
  std::string salt;
  try {
    encryptedPhrase = seedJson["seed"].get<std::string>();
    salt = seedJson["salt"].get<std::string>(); // TODO: Decode salt from base64
    // Replace spaces with newlines, cipher only accepts newlines since it's base64
    boost::replace_all(encryptedPhrase, " ", "\n");
  } catch (std::exception &e) {
    result.first = false;
    result.second = "Error happened when reading JSON to string: ";
    result.second += e.what();
    Utils::logToDebug(result.second);
    return result;
  }

  // Decrypt the mnemonic and check for errors
  try {
    mnemonic.raw = cipher.decrypt(encryptedPhrase, password, salt);
  } catch (std::exception &e) {
    result.first = true;
    result.second = "Error happened when decrypting, perhaps wrong password? ";
    result.second += e.what();
    Utils::logToDebug(result.second);
    return result;
  }
  result.first = true;
  result.second = "";
  return result;
}

