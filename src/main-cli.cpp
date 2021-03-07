#include "main-cli.h"

// Implementation of AVME Wallet as a CLI program.

int main() {
  // Set logging options to default to suppress debug strings (e.g. when reading key files).
  dev::LoggingOptions loggingOptions;
  loggingOptions.verbosity = 0; // No WARN messages
  dev::setupLogging(loggingOptions);

  WalletManager wm;
  boost::filesystem::path walletFile, secretsPath;

  std::cout << "Hello! Welcome to the AVME CLI wallet." << std::endl;

  // Handle wallet loading/creation options
  while (true) {
    std::string menuOp = menuCheckWallet();
    if (menuOp == "1") { // Create a new wallet
      walletFile = menuCreateWalletFile();
      secretsPath = menuCreateWalletSecrets();
      std::cout << "Protect your Wallet with a master passphrase (make it strong!)." << std::endl;
      std::string pass = menuCreatePass();
      std::cout << "Creating new Wallet..." << std::endl;
      if (wm.createNewWallet(walletFile, secretsPath, pass)) {
        std::cout << "Wallet successfully created!" << std::endl;
        pass = "";
        break;
      } else {
        std::cout << "Failed to create Wallet, please try again." << std::endl;
      }
    } else if (menuOp == "2") { // Load an existing wallet
      walletFile = menuLoadWalletFile();
      secretsPath = menuLoadWalletSecrets();
      break;
    }
  }

  // Load the proper wallet with the given paths
  while (true) {
    std::string pass;
    std::cout << "Enter your Wallet's passphrase." << std::endl;
    std::getline(std::cin, pass);
    std::cout << "Loading Wallet..." << std::endl;
    if (wm.loadWallet(walletFile, secretsPath, pass)) {
      std::cout << "Wallet loaded." << std::endl;
      wm.storeWalletPass(pass);
      pass = "";
      break;
    } else {
      std::cout << "Error loading Wallet: wrong passphrase. Please try again." << std::endl;
    }
  }
  std::cout << "Loading Wallet Accounts. This may take a while, please wait..." << std::endl;
  wm.loadWalletAccounts(true);

  // Menu loop
  while (true) {
    std::string menuOp;
    std::cout << "What are you looking to do?" << std::endl
      << "1 - List AVAX Accounts and balances" << std::endl
      << "2 - List AVME Accounts and balances" << std::endl
      << "3 - List LP Accounts and balances" << std::endl
      << "4 - Send an AVAX transaction" << std::endl
      << "5 - Send an AVME transaction" << std::endl
      << "6 - Create a new Account" << std::endl
      << "7 - Import an Account with a BIP39 seed" << std::endl
      << "8 - Erase an existing Account" << std::endl
      << "9 - Decode a raw transaction" << std::endl
      << "0 - Exit" << std::endl;
    std::getline(std::cin, menuOp);

    // List AVAX Accounts and balances
    if (menuOp == "1") {
      std::vector<WalletAccount> AVAXAccounts = wm.ReadWriteWalletVector(false, false, {});
      if (!AVAXAccounts.empty()) {
        for (WalletAccount accountData : AVAXAccounts) {
          std::cout << accountData.id << " "
            << accountData.privKey << " "
            << accountData.name << " "
            << accountData.address << " "
            << accountData.balanceAVAX << std::endl;
        }
      } else {
        std::cout << "No Accounts found." << std::endl;
      }

    // List AVME Accounts and balances
    } else if (menuOp == "2") {
      std::vector<WalletAccount> AVMEAccounts = wm.ReadWriteWalletVector(false, false, {});
      if (!AVMEAccounts.empty()) {
        for (WalletAccount accountData : AVMEAccounts) {
          std::cout << accountData.id << " "
            << accountData.privKey << " "
            << accountData.name << " "
            << accountData.address << " "
            << accountData.balanceAVME << std::endl;
        }
      } else {
        std::cout << "No Accounts found." << std::endl;
      }

    // List LP Accounts and balances
    } else if (menuOp == "3") {
      std::vector<WalletAccount> LPAccounts = wm.ReadWriteWalletVector(false, false, {});
      if (!LPAccounts.empty()) {
        for (WalletAccount accountData : LPAccounts) {
          std::cout << accountData.id << " "
            << accountData.privKey << " "
            << accountData.name << " "
            << accountData.address << " "
            << accountData.balanceLPFree << " "
            << accountData.balanceLPLocked << std::endl;
        }
      } else {
        std::cout << "No Accounts found." << std::endl;
      }

    // Send AVAX/AVME transactions
    } else if (menuOp == "4" || menuOp == "5") {
      TransactionSkeleton txSkel;
      std::string srcAddress, destAddress, txValue, txGasLimit, txGasPrice,
        signedTx, transactionLink, feeOp;

      srcAddress = menuChooseSenderAddress(wm);
      destAddress = menuChooseReceiverAddress();
      if (menuOp == "4") {  // AVAX
        txValue = menuChooseAVAXAmount(srcAddress, wm);
      } else if (menuOp == "5") { // AVME
        txValue = menuChooseAVMEAmount(srcAddress, wm);
      }
      std::cout << "Do you want to set your own fee or use an automatic fee?\n" <<
        "1 - Automatic\n2 - Set my own" << std::endl;
      std::getline(std::cin, feeOp);
      if (feeOp == "1") {
        if (menuOp == "4") {  // AVAX
          txGasLimit = "21000";
        } else if (menuOp == "5") { // AVME
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

      std::string pass;
      while (true) {
        std::cout << "Please authenticate with your Wallet's passphrase to confirm the action." << std::endl;
        std::getline(std::cin, pass);
        if (wm.checkWalletPass(pass)) { pass = ""; break; }
        std::cout << "Wrong passphrase, please try again." << std::endl;
      }

      std::cout << "Building transaction..." << std::endl;
      if (menuOp == "4") {  // AVAX
        txSkel = wm.buildAVAXTransaction(srcAddress, destAddress, txValue, txGasLimit, txGasPrice);
      } else if (menuOp == "5") { // AVME
        txSkel = wm.buildAVMETransaction(srcAddress, destAddress, txValue, txGasLimit, txGasPrice);
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
      wm.reloadAccountsBalances();

    // Create new account
    } else if (menuOp == "6") {
      std::string name, pass;

      // Get Account name (or not)
      std::cout << "Give a name to your Account (optional, leave blank for nothing)." << std::endl;
      std::getline(std::cin, name);
      while (true) {
        std::cout << "Please authenticate with your Wallet's passphrase to confirm the action." << std::endl;
        std::getline(std::cin, pass);
        if (wm.checkWalletPass(pass)) { pass = ""; break; }
        std::cout << "Wrong passphrase, please try again." << std::endl;
      }

      // Create the Account
      std::cout << "Creating a new Account..." << std::endl;
      WalletAccount data = wm.createNewAccount(name, pass);
      std::cout << "Created key " << data.id << std::endl
                << "  Name: " << data.name << std::endl
                << "  Address: " << data.address << std::endl;
      std::cout << "This is your seed for this Account. Please write it down:" << std::endl;
      for (std::string word : data.seed) { std::cout << word << " "; }
      std::cout << "\nOnce you're done, hit ENTER to continue." << std::endl;
      std::string enterStr;
      std::getline(std::cin, enterStr);
      std::cout << "Reloading Wallet..." << std::endl;
      wm.loadWallet(walletFile, secretsPath, pass);
      std::cout << "Reloading Accounts..." << std::endl;
      wm.loadWalletAccounts(false);

    // Import BIP39 seed
    } else if (menuOp == "7") {
      std::vector<std::string> mnemonicPhrase;
      std::string derivPath = "m/44'/60'/0'/0/";

      // Check if seed is valid (12-word length and all words are valid)
      while (true) {
        std::string seed, word;
        std::vector<std::string> words;
        std::cout << "Please enter your 12-word seed (words separated by SPACE)." << std::endl;
        std::getline(std::cin, seed);

        bool seedIsValid = true;
        int ct = 0;
        std::stringstream ss(seed);
        while (std::getline(ss, word, ' ')) {
          if (!wm.wordExists(word)) {
            std::cout << "Invalid word: " << word << std::endl;
            seedIsValid = false; break;
          }
          words.push_back(word);
          ct++;
        }
        if (seedIsValid && words.size() != 12) {
          std::cout << "Seed is not exactly 12-word long" << std::endl;
          seedIsValid = false;
        }

        if (!seedIsValid) {
          std::cout << "Invalid seed, please try another." << std::endl;
          continue;
        } else {
          for (std::string word : words) {
            mnemonicPhrase.push_back(word);
          }
          break;
        }
      }

      // Get the derivation index
      std::string index;
      std::cout << "Please inform the derivation index you want to use, or leave blank for default (0)." << std::endl
                << "We will display up to 10 derivations starting from yours." << std::endl;
      std::getline(std::cin, index);
      if (index == "") { index = "0"; }

      // Generate and list the Accounts
      bip3x::Bip39Mnemonic::MnemonicResult encodedMnemonic;
      encodedMnemonic.words = mnemonicPhrase;
      bip3x::HDKey rootKey = wm.createBip32RootKey(encodedMnemonic);
      std::cout << "Generating Accounts..." << std::endl;
      std::vector<std::string> accountsList = wm.addressListBasedOnRootIndex(rootKey, boost::lexical_cast<int>(index));
      for (auto v : accountsList) {
        std::cout << v << std::endl;
      }

      // Get the Account that will be imported
      index = "";
      std::cout << "Please inform the index number of the Account you want to use." << std::endl;
      std::cout << "Leave blank for the default (0)." << std::endl;
      std::getline(std::cin, index);
      if (index == "") { index = "0"; }
      derivPath += index;
      bip3x::HDKey bip32key = wm.createBip32Key(rootKey, derivPath);

      // Add a name to it (or not) and authenticate
      std::string name, pass;
      std::cout << "Give a name to your Account (optional, leave blank for nothing)." << std::endl;
      std::getline(std::cin, name);
      while (true) {
        std::cout << "Please authenticate with your Wallet's passphrase to confirm the action." << std::endl;
        std::getline(std::cin, pass);
        if (wm.checkWalletPass(pass)) { pass = ""; break; }
        std::cout << "Wrong passphrase, please try again." << std::endl;
      }

      // Import the Account and reload the Wallet
      std::cout << "Importing Account..." << std::endl;
      WalletAccount data = wm.importAccount(name, pass, bip32key);
      std::cout << "Imported key " << data.id << std::endl
                << "  Name: " << data.name << std::endl
                << "  Address: " << data.address << std::endl;
      std::cout << "Reloading Wallet..." << std::endl;
      wm.loadWallet(walletFile, secretsPath, pass);
      std::cout << "Reloading Accounts..." << std::endl;
      wm.loadWalletAccounts(false);

    // Erase account
    } else if (menuOp == "8") {
      std::string account = menuChooseAccountErase(wm);
      if (menuConfirmAccountErase()) {
        std::string pass;
        while (true) {
          std::cout << "Please authenticate with your Wallet's passphrase to confirm the action." << std::endl;
          std::getline(std::cin, pass);
          if (wm.checkWalletPass(pass)) { pass = ""; break; }
          std::cout << "Wrong passphrase, please try again." << std::endl;
        }

        std::cout << "Erasing Account..." << std::endl;
        if (wm.eraseAccount(account)) {
          std::cout << "Account erased: " << account << std::endl;
          std::cout << "Reloading Wallet..." << std::endl;
          wm.loadWallet(walletFile, secretsPath, pass);
          std::cout << "Reloading Accounts..." << std::endl;
          wm.loadWalletAccounts(false);
        } else {
          std::cout << "Failed to erase Account " << account << "; Account doesn't exist" << std::endl;
        }
      } else {
        std::cout << "Aborted." << std::endl;
      }

    // Decode raw transaction
    } else if (menuOp == "9") {
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
    } else if (menuOp == "0") {
      std::cout << "Exiting..." << std::endl;
      exit(0);

    // Wrong input
    } else {
      std::cout << "Wrong input, please try again" << std::endl;
    }
  } // End of menu loop

  return 0;
}
