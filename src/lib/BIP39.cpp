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
    std::string toPushBack;

    // Get the index and address
    std::string derivPath = "m/44'/60'/0'/0/" + boost::lexical_cast<std::string>(index);
    bip3x::HDKey rootKey = BIP39::createKey(seed, derivPath);
    KeyPair k(Secret::frombip3x(rootKey.privateKey));
    toPushBack += boost::lexical_cast<std::string>(index) + " " + "0x" + k.address().hex();

    // Get the balance
    std::string bal = API::getAVAXBalance("0x" + k.address().hex());
    u256 AVAXbalance = boost::lexical_cast<HexTo<u256>>(bal);
    std::string balanceStr = boost::lexical_cast<std::string>(AVAXbalance);

    // Don't write to vector if an error occurs while reading the JSON
    if (balanceStr == "" || balanceStr.find_first_not_of("0123456789.") != std::string::npos) {
      return {};
    }
    toPushBack += " " + Utils::weiToFixedPoint(balanceStr, 18);
    ret.push_back(toPushBack);
  }

  return ret;
}

std::pair<bool,std::string> BIP39::saveEncryptedMnemonic(
  bip3x::Bip39Mnemonic::MnemonicResult &mnemonic, std::string &password
) {
  std::pair <bool,std::string> result;
  boost::filesystem::path seedPath = Utils::walletFolderPath.string() + "/wallet/c-avax/seed.json";

  // Initialize the seed json and cipher, then create the salt
  json_spirit::mObject seedJson;
  Cipher cipher("aes-256-cbc", "sha256");
  unsigned char saltBytes[32];
  RAND_bytes(saltBytes, sizeof(saltBytes));
  std::string salt = toHex(
    dev::sha3(std::string((char*)saltBytes, sizeof(saltBytes)), false)
  ).substr(0,8);

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
    return result;
  }

  // Add information to JSON object and write it in a file
  seedJson["seed"] = encryptedPhrase;
  seedJson["salt"] = salt;
  json_spirit::mValue success = JSON::writeFile(seedJson, seedPath);
  try {
    std::string error = success.get_obj().at("ERROR").get_str();
    result.first = false;
    result.second = "Error happened when writing JSON file: " + error;
    return result;
  } catch (std::exception &e) {
    result.first = true;
    result.second = "";
    return result;
  }
  result.first = false;
  result.second = "Unknown Error";
  return result;
}

std::pair<bool,std::string> BIP39::loadEncryptedMnemonic(
  bip3x::Bip39Mnemonic::MnemonicResult &mnemonic, std::string &password
) {
  std::pair <bool,std::string> result;
  boost::filesystem::path seedPath = Utils::walletFolderPath.string() + "/wallet/c-avax/seed.json";

  // Initialize the cipher, read the JSON file and check for errors
  Cipher cipher("aes-256-cbc", "sha256");
  json_spirit::mValue seedJson = JSON::readFile(seedPath);
  try {
    std::string error = seedJson.get_obj().at("ERROR").get_str();
    result.first = false;
    result.second = "Error happened when reading JSON file: " + error;
    return result;
  } catch (std::exception &e) {
    ;
  }

  // Read JSON to string and check for errors
  std::string encryptedPhrase;
  std::string salt;
  try {
    encryptedPhrase = JSON::objectItem(seedJson, "seed").get_str();
    salt = JSON::objectItem(seedJson, "salt").get_str();
    // Replace spaces with newlines, cipher only accepts newlines since it's base64
    boost::replace_all(encryptedPhrase, " ", "\n");
  } catch (std::exception &e) {
    result.first = false;
    result.second = "Error happened when reading JSON to string: ";
    result.second += e.what();
    return result;
  }

  // Decrypt the mnemonic and check for errors
  try {
    mnemonic.raw = cipher.decrypt(encryptedPhrase, password, salt);
  } catch (std::exception &e) {
    result.first = true;
    result.second = "Error happened when decrypting, perhaps wrong password? ";
    result.second += e.what();
    return result;
  }
  result.first = true;
  result.second = "";
  return result;
}

