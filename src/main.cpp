#include "avme-wallet.h"

// Implementation of AVME Wallet as a CLI program.

int main () {
  /**
   * Setup logging options to default so we're not flooded with thousands of
   * debug strings when using the program
   */
  dev::LoggingOptions loggingOptions;
  dev::setupLogging(loggingOptions);

  WalletManager wm;
  std::string walletPass, menuOp;
  boost::filesystem::path walletPath, secretsPath;

  // Prompt for loading/creating user wallet
  std::cout << "Hello! Welcome to the AVME CLI wallet." << std::endl;
  bool defaultWalletExists = boost::filesystem::exists(KeyManager::defaultPath());
  bool defaultSecretExists = boost::filesystem::exists(SecretStore::defaultPath());
  if (defaultWalletExists && defaultSecretExists) {
    std::cout << "Default wallet found. How do you want to proceed?\n" <<
                 "1 - Load the default wallet\n" <<
                 "2 - Load an existing wallet\n" <<
                 "3 - Create and load a new wallet" << std::endl;
  } else {
    std::cout << "Default wallet not found. How do you want to proceed?\n" <<
                 "2 - Load an existing wallet\n" <<
                 "3 - Create and load a new wallet" << std::endl;
  }
  std::getline(std::cin, menuOp);

  // Load the default wallet (if it exists)
  if (menuOp == "1") {
    walletPath = KeyManager::defaultPath();
    secretsPath = SecretStore::defaultPath();

  // Load an existing wallet
  } else if (menuOp == "2") {
    std::string wBuf, sBuf;
    std::cout << "Please inform the full path of your wallet file." << std::endl;
    std::getline(std::cin, wBuf);
    std::cout << "Please inform the full path of your wallet secrets folder." << std::endl;
    std::getline(std::cin, sBuf);
    walletPath = wBuf;
    secretsPath = sBuf;

  // Create and load a new wallet
  } else if (menuOp == "3") {
    std::string wBuf, sBuf, passConf;
    std::cout << "Please inform the full path of your wallet file, or leave blank for default." << std::endl;
    std::cout << "Default is " << KeyManager::defaultPath() << std::endl;
    std::getline(std::cin, wBuf);
    std::cout << "Please inform the full path of your wallet secrets folder, or leave blank for default." << std::endl;
    std::cout << "Default is " << SecretStore::defaultPath() << std::endl;
    std::getline(std::cin, sBuf);
    walletPath = (wBuf.empty()) ? KeyManager::defaultPath() : wBuf;
    secretsPath = (sBuf.empty()) ? SecretStore::defaultPath() : sBuf;
    while (true) {
      std::cout << "Enter a master passphrase to protect your key store (make it strong!)." << std::endl;
      std::getline(std::cin, walletPass);
      std::cout << "Please confirm the master passphrase by entering it again." << std::endl;
      std::getline(std::cin, passConf);
      if (walletPass == passConf) { break; }
      std::cout << "Passwords were different. Try again." << std::endl;
    }
    std::cout << "Creating new wallet..." << std::endl;
    wm.createNewWallet(walletPath, secretsPath, walletPass);
  }

  // Load the proper wallet
  while (true) {
    std::cout << "Enter your wallet's passphrase." << std::endl;
    std::getline(std::cin, walletPass);
    std::cout << "Loading wallet..." << std::endl;
    if (!wm.loadWallet(walletPath, secretsPath, walletPass)) {
      std::cout << "Error loading wallet: wrong passphrase. Please try again." << std::endl;
    }
  }
  std::cout << "Wallet loaded." << std::endl;

  // Menu loop
  while (true) {
    std::cout << "What are you looking to do?\n" <<
      "1 - List ETH accounts and balances\n" <<
      "2 - List TAEX accounts and balances\n" <<
      "3 - Send an ETH Transaction\n" <<
      "4 - Send a TAEX Transaction\n" <<
      "5 - Create a new account\n" <<
      "6 - Erase an existing account\n" <<
      "7 - Create a private key from a word/phrase\n" <<
      "8 - Decode a raw transaction\n" <<
      "9 - Exit" << std::endl;
    std::getline(std::cin, menuOp);

    // List accounts
    if (menuOp == "1") {
      std::vector<WalletAccount> ETHAccounts = wm.listETHAccounts();
      if (!ETHAccounts.empty()) {
        for (WalletAccount accountData : ETHAccounts) {
          std::cout << accountData.id << " "
                    << accountData.privKey << " "
                    << accountData.name << " "
                    << accountData.address << " "
                    << accountData.balanceETH << std::endl;
        }
      } else {
        std::cout << "No accounts found." << std::endl;
      }
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

    // Send ETH transactions
    } else if (menuOp == "3") {
      std::string signKey, destWallet, txValue, txGas, txGasPrice,
                  signedTx, transactionLink, pass, passConf;
      TransactionSkeleton txSkel;

      std::cout << "From which address do you want to send a transaction?" << std::endl;
      std::getline(std::cin, signKey);
      std::cout << "Which address are you sending ETH to?" << std::endl;
      std::getline(std::cin, destWallet);
      std::cout << "How much ETH will you send? (amount in fixed point, e.g. 0.5)" << std::endl;
      std::getline(std::cin, txValue);
      txValue = wm.convertFixedPointToWei(txValue, 18);
      if (txValue == "") {
        std::cout << "Invalid amount, please check if your input is correct." << std::endl;
        continue;
      }
      std::cout << "Do you want to set your own fee or use an automatic fee?\n" <<
                   "1 - Automatic\n2 - Set my own" << std::endl;
      std::getline(std::cin, menuOp);
      if (menuOp == "1") {
        txGas = "21000";
        txGasPrice = wm.getAutomaticFee();
      } else if (menuOp == "2") {
        std::cout << "Set a gas limit for the transaction (recommended: 21000)." << std::endl;
        std::getline(std::cin, menuOp);
        if(!is_digits(menuOp)) {
          std::cout << "Invalid amount, please check if your input is correct." << std::endl;
          continue;
        }
        txGas = menuOp;
        std::cout << "Set a gas price (in GWEI) for the transaction (recommended: 50)." << std::endl;
        std::getline(std::cin, menuOp);
        if (!is_digits(menuOp)) {
          std::cout << "Invalid amount, please check if your input is correct." << std::endl;
          continue;
        }
        u256 GasPrice;
        GasPrice = boost::lexical_cast<u256>(menuOp) * raiseToPow(10,9);
        txGasPrice = boost::lexical_cast<std::string>(GasPrice);
      }
      while (true) {
        // TODO: fix passphrase logic (should be the account's pass, not the wallet's)
        std::cout << "Enter your wallet's passphrase." << std::endl;
        std::getline(std::cin, pass);
        std::cout << "Please confirm the passphrase by entering it again." << std::endl;
        std::getline(std::cin, passConf);
        if (pass == passConf) { break; }
        std::cout << "Passphrases were different or don't match the wallet's. Try again." << std::endl;
      }

      std::cout << "Building transaction..." << std::endl;
      txSkel = wm.buildETHTransaction(signKey, destWallet, txValue, txGas, txGasPrice);
      if (txSkel.nonce == wm.MAX_U256_VALUE()) {
        std::cout << "Error in transaction building" << std::endl;
        continue;
      }
      std::cout << "Signing transaction..." << std::endl;
      signedTx = wm.signTransaction(txSkel, pass, signKey);
      std::cout << "Transaction signed: " << signedTx << std::endl;
      std::cout << "Broadcasting transaction..." << std::endl;
      transactionLink = wm.sendTransaction(signedTx);
      if (transactionLink == "") {
        std::cout << "Transaction failed. Please try again." << std::endl;
      }
      while (transactionLink.find("Transaction nonce is too low") != std::string::npos ||
          transactionLink.find("Transaction with the same hash was already imported") != std::string::npos) {
        std::cout << "Transaction failed. Either the nonce is too low, or a "
                  << "transaction with the same hash was already imported." << std::endl
                  << "Trying again with a higher nonce..." << std::endl;
        txSkel.nonce++;
        signedTx = wm.signTransaction(txSkel, pass, signKey);
        transactionLink = wm.sendTransaction(signedTx);
      }
      std::cout << "Transaction sent! Link: " << transactionLink << std::endl;

    // Send TAEX transactions
    } else if (menuOp == "4") {
      std::string signKey, destWallet, txValue, txGas, txGasPrice,
                  signedTx, transactionLink, pass, passConf;
      TransactionSkeleton txSkel;

      std::cout << "From which address do you want to send a transaction?" << std::endl;
      std::getline(std::cin, signKey);
      std::cout << "Which address are you sending TAEX to?" << std::endl;
      std::getline(std::cin, destWallet);
      std::cout << "How much TAEX will you send? (amount in fixed point, e.g. 0.5 - MAXIMUM 4 DECIMALS!)" << std::endl;
      std::getline(std::cin, txValue);
      txValue = wm.convertFixedPointToWei(txValue, 4);
      if (txValue == "") {
        std::cout << "Invalid amount, please check if your input is correct." << std::endl;
        continue;
      }
      std::cout << "Do you want to set your own fee or use an automatic fee?\n" <<
                   "1 - Automatic\n2 - Set my own" << std::endl;
      std::getline(std::cin, menuOp);
      if (menuOp == "1") {
        txGas = "80000";
        txGasPrice = wm.getAutomaticFee();
      } else if (menuOp == "2") {
        std::cout << "Set a gas limit for the transaction (recommended: 21000)." << std::endl;
        std::getline(std::cin, menuOp);
        if(!is_digits(menuOp)) {
          std::cout << "Invalid amount, please check if your input is correct." << std::endl;
          continue;
        }
        txGas = menuOp;
        std::cout << "Set a gas price (in GWEI) for the transaction (recommended: 50)." << std::endl;
        std::getline(std::cin, menuOp);
        if (!is_digits(menuOp)) {
          std::cout << "Invalid amount, please check if your input is correct." << std::endl;
          continue;
        }
        u256 GasPrice;
        GasPrice = boost::lexical_cast<u256>(menuOp) * raiseToPow(10,9);
        txGasPrice = boost::lexical_cast<std::string>(GasPrice);
      }
      while (true) {
        // TODO: fix passphrase logic (should be the account's pass, not the wallet's)
        std::cout << "Enter your wallet's passphrase." << std::endl;
        std::getline(std::cin, pass);
        std::cout << "Please confirm the passphrase by entering it again." << std::endl;
        std::getline(std::cin, passConf);
        if (pass == passConf && pass == walletPass) { break; }
        std::cout << "Passphrases were different or don't match the wallet's. Try again." << std::endl;
      }

      std::cout << "Building transaction..." << std::endl;
      txSkel = wm.buildTAEXTransaction(signKey, destWallet, txValue, txGas, txGasPrice);
      if (txSkel.nonce == wm.MAX_U256_VALUE()) {
        std::cout << "Error in transaction building" << std::endl;
        continue;
      }
      std::cout << "Signing transaction..." << std::endl;
      signedTx = wm.signTransaction(txSkel, pass, signKey);
      std::cout << "Transaction signed: " << signedTx;
      std::cout << "Broadcasting transaction..." << std::endl;
      transactionLink = wm.sendTransaction(signedTx);
      while (transactionLink.find("Transaction nonce is too low") != std::string::npos ||
          transactionLink.find("Transaction with the same hash was already imported") != std::string::npos) {
        std::cout << "Transaction failed. Either the nonce is too low, or a "
                  << "transaction with the same hash was already imported." << std::endl
                  << "Trying again with a higher nonce..." << std::endl;
        txSkel.nonce++;
        signedTx = wm.signTransaction(txSkel, pass, signKey);
        transactionLink = wm.sendTransaction(signedTx);
      }
      std::cout << "Transaction sent! Link: " << transactionLink << std::endl;

    // Create new account
    } else if (menuOp == "5") {
      std::string name, aPass, aPassConf, aPassHint;
      bool usesMasterPass;

      std::cout << "Give a name to your account." << std::endl;
      std::getline(std::cin, name);
      while (true) {
        std::cout << "Enter a passphrase to secure this account (or leave blank to use the wallet's master passphrase)." << std::endl;
        std::getline(std::cin, aPass);
        std::cout << "Please confirm the passphrase by entering it again." << std::endl;
        std::getline(std::cin, aPassConf);
        if (aPass == aPassConf) {
          if (aPass == "") {  // Using the master passphrase
            usesMasterPass = true;
            aPass = walletPass;
            aPassHint = "";
          } else {  // Using a normal passphrase
            usesMasterPass = false;
            std::cout << "Enter a hint to help you remember this passphrase (or leave blank for nothing)." << std::endl;
            std::getline(std::cin, aPassHint);
          }
          break;
        }
        std::cout << "Passphrases were different. Try again." << std::endl;
      }
      std::cout << "Creating a new account..." << std::endl;
      WalletAccount data = wm.createNewAccount(name, aPass, aPassHint, usesMasterPass);
      std::cout << "Created key " << data.id << std::endl
                << "  Name: " << data.name << std::endl
                << "  Address: " << data.address << std::endl
                << "  Hint: " << data.hint << std::endl;
      std::cout << "Reloading wallet..." << std::endl;
      wm.loadWallet(walletPath, secretsPath, walletPass);

    // Erase account
    } else if (menuOp == "6") {
      std::string account, pass, passConf;

      std::cout << "Please inform the account name or address that you want to delete." << std::endl;
      std::getline(std::cin, account);
      while (true) {
        // TODO: fix passphrase logic (should be the account's pass, not the wallet's)
        std::cout << "Enter your wallet's passphrase." << std::endl;
        std::getline(std::cin, pass);
        std::cout << "Please confirm the passphrase by entering it again." << std::endl;
        std::getline(std::cin, passConf);
        if (pass == passConf && pass == walletPass) { break; }
        std::cout << "Passphrases were different or don't match the wallet's. Try again." << std::endl;
      }
      std::cout << "Erasing account..." << std::endl;
      if (wm.eraseAccount(account)) {
        std::cout << "Account erased: " << account << std::endl;
        std::cout << "Reloading wallet..." << std::endl;
        wm.loadWallet(walletPath, secretsPath, walletPass);
      } else {
        std::cout << "Couldn't erase account " << account
                  << "; either it doesn't exist or has funds in it." << std::endl;
      }

    // Create private key
    } else if (menuOp == "7") {
      std::string phrase;
      std::cout << "Enter your wallet's passphrase." << std::endl;
      std::getline(std::cin, phrase);
      std::cout << "Creating a key pair..." << std::endl;
      wm.createKeyPairFromPhrase(phrase);

    // Decode raw transaction
    } else if (menuOp == "8") {
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
    } else if (menuOp == "9") {
      std::cout << "Exiting..." << std::endl;
      exit(0);

    // Wrong input
    } else {
      std::cout << "Wrong input, please try again" << std::endl;
    }
  } // End of menu loop

  return 0;
}
