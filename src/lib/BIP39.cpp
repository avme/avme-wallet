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

std::pair<bool,std::string> BIP39::saveEncryptedMnemonic(bip3x::Bip39Mnemonic::MnemonicResult &mnemonic, std::string &password) {
	std::pair <bool,std::string> result;
	boost::filesystem::path seedPath = "seed.json";
	// Initialize the seed json
	json_spirit::mObject seedJson;
	// Initialize the cipher
	Cipher cipher("aes-256-cbc", "sha256");
	// Create the salt
	unsigned char saltBytes[32];
	RAND_bytes(saltBytes, sizeof(saltBytes));
	std::string salt = toHex(dev::sha3(std::string((char*)saltBytes, sizeof(saltBytes)), false)).substr(0,8);
	
	// Encrypt mnemonic
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
	
	// Add information to json object
	seedJson["seed"] = encryptedPhrase;
	seedJson["salt"] = salt;
	
	json_spirit::mValue success = JSON::writeFile(seedJson, "seed.json");
	
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

std::pair<bool,std::string> BIP39::loadEncryptedMnemonic(bip3x::Bip39Mnemonic::MnemonicResult &mnemonic, std::string &password) {
    std::pair <bool,std::string> result;
	// Initialize cipher
	Cipher cipher("aes-256-cbc", "sha256");
	// Read file and check for errors
	json_spirit::mValue seedJson = JSON::readFile("seed.json");
	try {
      std::string error = seedJson.get_obj().at("ERROR").get_str();
      result.first = false;
      result.second = "Error happened when reading JSON file: " + error;
      return result;
    } catch (std::exception &e) {
    }
	
	// Read json to string and check for errors
	std::string encryptedPhrase;
	std::string salt;
	
	try {
		encryptedPhrase = JSON::objectItem(seedJson, "seed").get_str();
		salt = JSON::objectItem(seedJson, "salt").get_str();
		// Replace spaces with newlines, the cipher will only accept newline since it is base64 formatted.
		boost::replace_all(encryptedPhrase, " ", "\n");
	} catch (std::exception &e) {
		result.first = false;
		result.second = "Error happened when reading JSON to string: ";
		result.second += e.what();
		return result;
	}
	
	// Decrypt and check for errors.
	
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

