#include "main-cli.h"

// Implementation of AVME Wallet as a CLI program.

int main() {
  // Set logging options to default to suppress debug strings (e.g. when reading key files).
  dev::LoggingOptions loggingOptions;
  dev::setupLogging(loggingOptions);

  WalletManager wm;
  std::string walletPass;
  boost::filesystem::path walletFile, secretsPath;

  std::cout << "Hello! Welcome to the AVME CLI wallet." << std::endl;

  // Handle wallet loading/creation options
  while (true) {
    std::string menuOp = menuCheckWallet();
    if (menuOp == "1") {  // Load the default wallet
      walletFile = KeyManager::defaultPath();
      secretsPath = SecretStore::defaultPath();
      break;
    } else if (menuOp == "2") { // Load an existing wallet
      walletFile = menuLoadWalletFile();
      secretsPath = menuLoadWalletSecrets();
      break;
    } else if (menuOp == "3") { // Create a new wallet
      walletFile = menuCreateWalletFile();
      secretsPath = menuCreateWalletSecrets();
      std::cout << "Protect your wallet with a master passphrase (make it strong!)." << std::endl;
      walletPass = menuCreatePass();
      std::cout << "Creating new wallet..." << std::endl;
      if (wm.createNewWallet(walletFile, secretsPath, walletPass)) {
        std::cout << "Wallet successfully created!" << std::endl;
        break;
      } else {
        std::cout << "Failed to create wallet, please try again." << std::endl;
      }
    }
  }

  // Load the proper wallet with the given paths
  while (true) {
    std::cout << "Enter your wallet's passphrase." << std::endl;
    std::getline(std::cin, walletPass);
    std::cout << "Loading wallet..." << std::endl;
    if (wm.loadWallet(walletFile, secretsPath, walletPass)) {
      std::cout << "Wallet loaded." << std::endl;
      break;
    } else {
      std::cout << "Error loading wallet: wrong passphrase. Please try again." << std::endl;
    }
  }

  // Menu loop
  while (true) {
    std::string menuOp;
    std::cout << "What are you looking to do?" << std::endl
              << "1 - List AVAX accounts and balances" << std::endl
              << "2 - List TAEX accounts and balances" << std::endl
              << "3 - Send an AVAX transaction" << std::endl
              << "4 - Send a TAEX transaction" << std::endl
              << "5 - Create a new account" << std::endl
              << "6 - Erase an existing account" << std::endl
              << "7 - Decode a raw transaction" << std::endl
              << "8 - Exit" << std::endl;
    std::getline(std::cin, menuOp);

    // List AVAX accounts
    if (menuOp == "1") {
      std::vector<WalletAccount> AVAXAccounts = wm.listAVAXAccounts();
      if (!AVAXAccounts.empty()) {
        for (WalletAccount accountData : AVAXAccounts) {
          std::cout << accountData.id << " "
                    << accountData.privKey << " "
                    << accountData.name << " "
                    << accountData.address << " "
                    << accountData.balanceAVAX << std::endl;
        }
      } else {
        std::cout << "No accounts found." << std::endl;
      }

    // List TAEX accounts
    } else if (menuOp == "2") {
      std::vector<WalletAccount> TAEXAccounts = wm.listTAEXAccounts();
      if (!TAEXAccounts.empty()) {
        for (WalletAccount accountData : TAEXAccounts) {
          std::cout << accountData.id << " "
                    << accountData.privKey << " "
                    << accountData.name << " "
                    << accountData.address << " "
                    << accountData.balanceTAEX << std::endl;
        }
      } else {
        std::cout << "No accounts found." << std::endl;
      }

    // Send AVAX/TAEX transactions
    } else if (menuOp == "3" || menuOp == "4") {
      TransactionSkeleton txSkel;
      std::string srcAddress, destAddress, txValue, txGasLimit, txGasPrice,
                  signedTx, transactionLink, feeOp;

      srcAddress = menuChooseSenderAddress(wm);
      destAddress = menuChooseReceiverAddress();
      if (menuOp == "3") {  // AVAX
        txValue = menuChooseAVAXAmount(srcAddress, wm);
      } else if (menuOp == "4") { // TAEX
        txValue = menuChooseTAEXAmount(srcAddress, wm);
      }
      std::cout << "Do you want to set your own fee or use an automatic fee?\n" <<
                   "1 - Automatic\n2 - Set my own" << std::endl;
      std::getline(std::cin, feeOp);
      if (feeOp == "1") {
        if (menuOp == "3") {  // AVAX
          txGasLimit = "21000";
        } else if (menuOp == "4") { // TAEX
          txGasLimit = "80000";
        }
        txGasPrice = wm.getAutomaticFee();
      } else if (feeOp == "2") {
        txGasLimit = menuSetGasLimit();
        txGasPrice = menuSetGasPrice();
      }
      txGasPrice = boost::lexical_cast<std::string>(
        boost::lexical_cast<u256>(txGasPrice) * raiseToPow(10,9)
      );

      std::string pass, conf;
      while (true) {
        // TODO: fix passphrase logic (should be the account's pass, not the wallet's)
        std::cout << "Enter your wallet's passphrase." << std::endl;
        std::getline(std::cin, pass);
        std::cout << "Please confirm the passphrase by entering it again." << std::endl;
        std::getline(std::cin, conf);
        if (pass == conf && pass == walletPass) { break; }
        std::cout << "Passphrases were different or don't match the wallet's. Try again." << std::endl;
      }

      std::cout << "Building transaction..." << std::endl;
      if (menuOp == "3") {  // AVAX
        txSkel = wm.buildAVAXTransaction(srcAddress, destAddress, txValue, txGasLimit, txGasPrice);
      } else if (menuOp == "4") { // TAEX
        txSkel = wm.buildTAEXTransaction(srcAddress, destAddress, txValue, txGasLimit, txGasPrice);
      }
      if (txSkel.nonce == wm.MAX_U256_VALUE()) {
        std::cout << "Error in transaction building" << std::endl;
        continue;
      }

      std::cout << "Signing transaction..." << std::endl;
      signedTx = wm.signTransaction(txSkel, pass, srcAddress);
      std::cout << "Transaction signed: " << signedTx << std::endl;

      std::cout << "Broadcasting transaction..." << std::endl;
      transactionLink = wm.sendTransaction(signedTx);
      if (transactionLink == "") {
        std::cout << "Transaction failed. Please try again." << std::endl;
        continue;
      }
      while (transactionLink.find("Transaction nonce is too low") != std::string::npos ||
          transactionLink.find("Transaction with the same hash was already imported") != std::string::npos) {
        std::cout << "Transaction failed. Either the nonce is too low, or a "
                  << "transaction with the same hash was already imported." << std::endl
                  << "Trying again with a higher nonce..." << std::endl;
        txSkel.nonce++;
        signedTx = wm.signTransaction(txSkel, pass, srcAddress);
        transactionLink = wm.sendTransaction(signedTx);
      }
      std::cout << "Transaction sent! Link: " << transactionLink << std::endl;

    // Create new account
    } else if (menuOp == "5") {
      std::string name, aPass, aPassConf, aPassHint;
      bool usesMasterPass;

      std::cout << "Give a name to your account (optional)." << std::endl;
      std::getline(std::cin, name);
      std::cout << "Protect your account with a passphrase." << std::endl
                << "Leave blank to use your wallet's master passphrase." << std::endl;
      aPass = menuCreatePass();
      if (aPass == "") {  // Using the master passphrase
        usesMasterPass = true;
        aPass = walletPass;
        aPassHint = "";
      } else {  // Using a normal passphrase
        usesMasterPass = false;
        std::cout << "Enter a hint to help you remember this passphrase (optional)." << std::endl;
        std::getline(std::cin, aPassHint);
      }

      std::cout << "Creating a new account..." << std::endl;
      WalletAccount data = wm.createNewAccount(name, aPass, aPassHint, usesMasterPass);
      std::cout << "Created key " << data.id << std::endl
                << "  Name: " << data.name << std::endl
                << "  Address: " << data.address << std::endl
                << "  Hint: " << data.hint << std::endl;
      std::cout << "Reloading wallet..." << std::endl;
      wm.loadWallet(walletFile, secretsPath, walletPass);

    // Erase account
    } else if (menuOp == "6") {
      std::string account;

      account = menuChooseAccountErase(wm);
      if (!wm.accountIsEmpty(account)) {
        std::cout << "The account " << account << " has funds in it." << std::endl
                  << "If you choose to erase it, all funds will be *permanently* lost." << std::endl;
      }
      if (menuConfirmAccountErase()) {
        while (true) {
          // TODO: fix passphrase logic (should be the account's pass, not the wallet's)
          std::string pass, conf;
          std::cout << "Enter your wallet's passphrase." << std::endl;
          std::getline(std::cin, pass);
          std::cout << "Please confirm the passphrase by entering it again." << std::endl;
          std::getline(std::cin, conf);
          if (pass == conf && pass == walletPass) { break; }
          std::cout << "Passphrases were different or don't match the wallet's. Try again." << std::endl;
        }
        std::cout << "Erasing account..." << std::endl;
        if (wm.eraseAccount(account)) {
          std::cout << "Account erased: " << account << std::endl;
          std::cout << "Reloading wallet..." << std::endl;
          wm.loadWallet(walletFile, secretsPath, walletPass);
        } else {
          std::cout << "Failed to erase account " << account << "; account doesn't exist" << std::endl;
        }
      } else {
        std::cout << "Aborted." << std::endl;
      }

    // Decode raw transaction
    } else if (menuOp == "7") {
      std::string rawTxHex;
      std::cout << "Please input the raw transaction in Hex." << std::endl;
      std::getline(std::cin, rawTxHex);
      WalletTxData txData = wm.decodeRawTransaction(rawTxHex);
      std::cout << "Transaction: " << txData.hex << std::endl
                << "Type: " << txData.type << std::endl
                << "Code: " << txData.code << std::endl
                << "To: " << txData.to << std::endl
                << "From: " << txData.from << std::endl
                << "Creates: " << txData.creates << std::endl
                << "Value: " << txData.value << std::endl
                << "Nonce: " << txData.nonce << std::endl
                << "Gas: " << txData.gas << std::endl
                << "Gas Price: " << txData.price << std::endl
                << "Hash: " << txData.hash << std::endl
                << "v: " << txData.v << std::endl
                << "r: " << txData.r << std::endl
                << "s: " << txData.s << std::endl;
    // Exit
    } else if (menuOp == "8") {
      std::cout << "Exiting..." << std::endl;
      exit(0);

    // Wrong input
    } else {
      std::cout << "Wrong input, please try again" << std::endl;
    }
  } // End of menu loop

  return 0;
}
