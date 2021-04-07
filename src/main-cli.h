#ifndef MAIN_CLI_H
#define MAIN_CLI_H

#include "lib/Network.h"
#include "lib/BIP39.h"
#include "lib/Pangolin.h"
#include "lib/Utils.h"
#include "lib/Wallet.h"

/**
 * Menu prompts for the AVME CLI Wallet, for containerizing logic
 * and user input error handling, according to each menu's context.
 */

// Check the existence of the Wallet
std::string menuCheckWallet() {
  std::string ret;

  while (true) {
    std::cout << "How do you want to proceed?\n"
              << "1 - Create and load a new Wallet\n"
              << "2 - Load an existing Wallet" << std::endl;
    std::getline(std::cin, ret);
    if (ret.find_first_not_of("12") == std::string::npos) {
      break;
    } else {
      std::cout << "Invalid option, please try again." << std::endl;
    }
  }

  return ret;
}

// Load a Wallet folder
std::string menuLoadWalletFolder() {
  std::string ret;

  while (true) {
    std::cout << "Please inform the full path of your Wallet folder." << std::endl;
    std::getline(std::cin, ret);
    if (boost::filesystem::exists(ret + "/wallet/c-avax/wallet.info") &&
        boost::filesystem::exists(ret + "/wallet/c-avax/accounts/secrets")) {
      break;
    } else {
      std::cout << ret << " not found, please check if it exists or try another path." << std::endl;
    }
  }

  return ret;
}

// Create a new Wallet folder
std::string menuCreateWalletFolder() {
  std::string ret;

  while (true) {
    std::cout << "Please inform the full path of your Wallet folder, or leave blank for default." << std::endl;
    std::cout << "Default is " << KeyManager::defaultPath() << std::endl;
    std::getline(std::cin, ret);
    if (ret.empty()) { ret = KeyManager::defaultPath().string(); }
    if (boost::filesystem::exists(ret + "/wallet/c-avax/wallet.info") &&
        boost::filesystem::exists(ret + "/wallet/c-avax/accounts/secrets")) {
      std::cout << "Wallet already exists here, please try another path" << std::endl;
    } else {
      break;
    }
  }

  return ret;
}

// Create a passphrase for the Wallet/Account
std::string menuCreatePass() {
  std::string ret, conf;

  while (true) {
    std::cout << "Enter your passphrase." << std::endl;
    std::getline(std::cin, ret);
    std::cout << "Please confirm your passphrase by entering it again." << std::endl;
    std::getline(std::cin, conf);
    if (ret == conf) { break; }
    std::cout << "Passphrases were different. Try again." << std::endl;
  }

  return ret;
}

// Choose which address will be the sender/receiver, respectively
std::string menuChooseSenderAddress(Wallet w) {
  std::string ret;

  while (true) {
    std::cout << "From which address do you want to send a transaction?" << std::endl;
    std::getline(std::cin, ret);
    if (ret.find("0x") == std::string::npos) { ret.insert(0, "0x"); }  // Add "0x" at the start
    if (ret.length() != 42) {
      std::cout << "Not a valid address, please check the formatting." << std::endl;
    } else if (!w.accountExists(ret)) {
      std::cout << "Address does not exist, please try another." << std::endl;
    } else {
      break;
    }
  }

  return ret;
}

std::string menuChooseReceiverAddress() {
  std::string ret;

  while (true) {
    std::cout << "Which address are you sending a transaction to?" << std::endl;
    std::getline(std::cin, ret);
    if (ret.find("0x") == std::string::npos) { ret.insert(0, "0x"); }  // Add "0x" at the start
    if (ret.length() != 42) {
      std::cout << "Not a valid address, please check the formatting." << std::endl;
    } else {
      break;
    }
  }

  return ret;
}

// Choose a coin or token amount to send from a given address
std::string menuChooseAVAXAmount(std::string address) {
  std::string ret;

  while (true) {
    std::cout << "How much AVAX do you want to send? (amount in fixed point, e.g. 0.5)" << std::endl;
    std::getline(std::cin, ret);
    ret = Utils::fixedPointToWei(ret, 18);
    if (ret == "") {
      std::cout << "Invalid amount, please check if your input is correct." << std::endl;
    } else if (ret > Network::getAVAXBalance(address)) {
      std::cout << "Insufficient funds, please try again." << std::endl;
    } else {
      break;
    }
  }

  return ret;
}

std::string menuChooseAVMEAmount(std::string address) {
  std::string ret;

  while (true) {
    std::cout << "How much AVME do you want to send? (amount in fixed point, e.g. 0.5 - MAXIMUM 18 DECIMALS!)" << std::endl;
    std::getline(std::cin, ret);
    ret = Utils::fixedPointToWei(ret, 18);
    if (ret == "") {
      std::cout << "Invalid amount, please check if your input is correct." << std::endl;
    } else if (ret > Network::getAVMEBalance(address, Pangolin::tokenContracts["AVME"])) {
      std::cout << "Insufficient funds, please try again." << std::endl;
    } else {
      break;
    }
  }

  return ret;
}

// Set a manual gas limit and gas price, respectively
std::string menuSetGasLimit() {
  std::string ret;

  while (true) {
    std::cout << "Set a gas limit (in Wei) for the transaction. Recommended: 21000" << std::endl;
    std::getline(std::cin, ret);
    if (!is_digits(ret)) {
      std::cout << "Invalid amount, please check if your input is correct." << std::endl;
    } else {
      break;
    }
  }

  return ret;
}

std::string menuSetGasPrice() {
  std::string ret;

  while (true) {
    std::cout << "Set a gas price (in Gwei) for the transaction. Recommended: 50" << std::endl;
    std::getline(std::cin, ret);
    if (!is_digits(ret)) {
      std::cout << "Invalid amount, please check if your input is correct." << std::endl;
    } else {
      break;
    }
  }

  return ret;
}

// Choose an Account to erase
std::string menuChooseAccountErase(Wallet w) {
  std::string ret;

  while (true) {
    std::cout << "Please inform the Account name or address that you want to erase." << std::endl;
    std::getline(std::cin, ret);
    if (ret.find("0x") == std::string::npos) { ret.insert(0, "0x"); }  // Add "0x" at the start
    if (ret.length() != 42) {
      std::cout << "Invalid Account, please check the formatting." << std::endl;
    } else if (!w.accountExists(ret)) {
      std::cout << "Account does not exist, please try another." << std::endl;
    } else {
      break;
    }
  }

  return ret;
}

// Confirm Account erasure
bool menuConfirmAccountErase() {
  while (true) {
    std::string conf;
    std::cout << "Are you absolutely sure you want to erase this Account?" << std::endl
              << "All funds in it will be PERMANENTLY LOST." << std::endl
              << "1 - Yes\n2 - No" << std::endl;
    std::getline(std::cin, conf);
    if (conf == "1") {
      return true;
    } else if (conf == "2") {
      return false;
    } else {
      std::cout << "Invalid option, please try again." << std::endl;
    }
  }
}

#endif // MAIN_CLI_H
