#include "main-cli.h"

// Implementation of AVME Wallet as a CLI program.

int main() {
  // Set logging options to default to suppress debug strings (e.g. when reading key files).
  dev::LoggingOptions loggingOptions;
  loggingOptions.verbosity = 0; // No WARN messages
  dev::setupLogging(loggingOptions);

  Wallet w;
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
      if (w.create(walletFile, secretsPath, pass)) {
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
    if (w.load(walletFile, secretsPath, pass)) {
      std::cout << "Wallet loaded." << std::endl;
      pass = "";
      break;
    } else {
      std::cout << "Error loading Wallet: wrong passphrase. Please try again." << std::endl;
    }
  }
  std::cout << "Loading Wallet Accounts. This may take a while, please wait..." << std::endl;
  w.loadAccounts();

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
      std::vector<Account> list = w.accounts;
      if (!list.empty()) {
        for (Account a : list) {
          a.balancesThreadLock.lock();
          std::cout << a.id << " "
                    << a.name << " "
                    << a.address << " "
                    << a.balanceAVAX << std::endl;
          a.balancesThreadLock.unlock();
        }
      } else {
        std::cout << "No Accounts found." << std::endl;
      }

    // List AVME Accounts and balances
    } else if (menuOp == "2") {
      std::vector<Account> list = w.accounts;
      if (!list.empty()) {
        for (Account a : list) {
          a.balancesThreadLock.lock();
          std::cout << a.id << " "
                    << a.name << " "
                    << a.address << " "
                    << a.balanceAVME << std::endl;
          a.balancesThreadLock.unlock();
        }
      } else {
        std::cout << "No Accounts found." << std::endl;
      }

    // List LP Accounts and balances
    } else if (menuOp == "3") {
      std::vector<Account> list = w.accounts;
      if (!list.empty()) {
        for (Account a : list) {
          a.balancesThreadLock.lock();
          std::cout << a.id << " "
                    << a.name << " "
                    << a.address << " "
                    << a.balanceLPFree << " "
                    << a.balanceLPLocked << std::endl;
          a.balancesThreadLock.unlock();
        }
      } else {
        std::cout << "No Accounts found." << std::endl;
      }

    // Send AVAX/AVME transactions
    } else if (menuOp == "4" || menuOp == "5") {
      TransactionSkeleton txSkel;
      std::string from, to, value, gasLimit, gasPrice, signedTx, txLink, operation, feeOp;

      from = menuChooseSenderAddress(w);
      to = menuChooseReceiverAddress();
      if (menuOp == "4") {  // AVAX
        value = menuChooseAVAXAmount(from);
      } else if (menuOp == "5") { // AVME
        value = menuChooseAVMEAmount(from);
      }
      std::cout << "Do you want to set your own fee or use an automatic fee?\n" <<
        "1 - Automatic\n2 - Set my own" << std::endl;
      std::getline(std::cin, feeOp);
      if (feeOp == "1") {
        if (menuOp == "4") {  // AVAX
          gasLimit = "21000";
        } else if (menuOp == "5") { // AVME
          gasLimit = "80000";
        }
        gasPrice = Network::getAutomaticFee();
      } else if (feeOp == "2") {
        gasLimit = menuSetGasLimit();
        gasPrice = menuSetGasPrice();
      }
      gasPrice = boost::lexical_cast<std::string>(
        boost::lexical_cast<u256>(gasPrice) * raiseToPow(10,9)
      );

      std::string pass;
      while (true) {
        std::cout << "Please authenticate with your Wallet's passphrase to confirm the action." << std::endl;
        std::getline(std::cin, pass);
        if (w.auth(pass)) break;
        std::cout << "Wrong passphrase, please try again." << std::endl;
      }

      std::cout << "Building transaction..." << std::endl;
      if (menuOp == "4") {  // AVAX
        txSkel = w.buildTransaction(from, to, value, gasLimit, gasPrice);
      } else if (menuOp == "5") { // AVME
        txSkel = w.buildTransaction(from, Pangolin::tokenContracts["AVME"], "0", gasLimit, gasPrice, Pangolin::transfer(to, value));
      }
      if (txSkel.nonce == Utils::MAX_U256_VALUE()) {
        std::cout << "Error in transaction building" << std::endl;
        continue;
      }

      std::cout << "Signing transaction..." << std::endl;
      signedTx = w.signTransaction(txSkel, pass);
      std::cout << "Transaction signed: " << signedTx << std::endl;

      std::cout << "Broadcasting transaction..." << std::endl;
      if (menuOp == "4") {  // AVAX
        operation = "Send AVAX";
      } else if (menuOp == "5") { // AVME
        operation = "Send AVME";
      }
      txLink = w.sendTransaction(signedTx, operation);
      if (txLink == "") {
        std::cout << "Transaction failed. Please try again." << std::endl;
        continue;
      }
      while (txLink.find("Transaction nonce is too low") != std::string::npos ||
          txLink.find("Transaction with the same hash was already imported") != std::string::npos) {
        std::cout << "Transaction failed. Either the nonce is too low, or a "
                  << "transaction with the same hash was already imported." << std::endl
                  << "Trying again with a higher nonce..." << std::endl;
        txSkel.nonce++;
        signedTx = w.signTransaction(txSkel, pass);
        txLink = w.sendTransaction(signedTx, operation);
      }
      std::cout << "Transaction sent! Link: " << txLink << std::endl;
      pass = "";
      std::cout << "Reloading Accounts..." << std::endl;
      w.loadAccounts();

    // Create new account
    } else if (menuOp == "6") {
      std::string name, pass;

      // Get Account name (or not)
      std::cout << "Give a name to your Account (optional, leave blank for nothing)." << std::endl;
      std::getline(std::cin, name);
      while (true) {
        std::cout << "Please authenticate with your Wallet's passphrase to confirm the action." << std::endl;
        std::getline(std::cin, pass);
        if (w.auth(pass)) break;
        std::cout << "Wrong passphrase, please try again." << std::endl;
      }

      // Create the Account
      std::cout << "Creating a new Account..." << std::endl;
      Account a = w.createAccount(name, pass);
      std::cout << "Created key " << a.id << std::endl
                << "  Name: " << a.name << std::endl
                << "  Address: " << a.address << std::endl;
      std::cout << "This is your seed for this Account. Please write it down:" << std::endl;
      for (std::string word : a.seed) { std::cout << word << " "; }
      std::cout << "\nOnce you're done, hit ENTER to continue." << std::endl;
      std::string enterStr;
      std::getline(std::cin, enterStr);
      std::cout << "Reloading Wallet..." << std::endl;
      w.load(walletFile, secretsPath, pass);
      pass = "";
      std::cout << "Reloading Accounts..." << std::endl;
      w.loadAccounts();

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
          if (!BIP39::wordExists(word)) {
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

      // Generate the Account with the given seed
      std::cout << "Generating Account..." << std::endl;
      bip3x::Bip39Mnemonic::MnemonicResult encodedMnemonic;
      encodedMnemonic.words = mnemonicPhrase;
      bip3x::HDKey key = BIP39::createKey(encodedMnemonic.raw, derivPath);

      // Add a name to it (or not) and authenticate
      std::string name, pass;
      std::cout << "Give a name to your Account (optional, leave blank for nothing)." << std::endl;
      std::getline(std::cin, name);
      while (true) {
        std::cout << "Please authenticate with your Wallet's passphrase to confirm the action." << std::endl;
        std::getline(std::cin, pass);
        if (w.auth(pass)) break;
        std::cout << "Wrong passphrase, please try again." << std::endl;
      }

      // Import the Account and reload the Wallet
      std::cout << "Importing Account..." << std::endl;
      Account a = w.importAccount(name, pass, key);
      std::cout << "Imported key " << a.id << std::endl
                << "  Name: " << a.name << std::endl
                << "  Address: " << a.address << std::endl;
      std::cout << "Reloading Wallet..." << std::endl;
      w.load(walletFile, secretsPath, pass);
      pass = "";
      std::cout << "Reloading Accounts..." << std::endl;
      w.loadAccounts();

    // Erase account
    } else if (menuOp == "8") {
      std::string account = menuChooseAccountErase(w);
      if (menuConfirmAccountErase()) {
        std::string pass;
        while (true) {
          std::cout << "Please authenticate with your Wallet's passphrase to confirm the action." << std::endl;
          std::getline(std::cin, pass);
          if (w.auth(pass)) break;
          std::cout << "Wrong passphrase, please try again." << std::endl;
        }

        std::cout << "Erasing Account..." << std::endl;
        if (w.eraseAccount(account)) {
          std::cout << "Account erased: " << account << std::endl;
          std::cout << "Reloading Wallet..." << std::endl;
          w.load(walletFile, secretsPath, pass);
          pass = "";
          std::cout << "Reloading Accounts..." << std::endl;
          w.loadAccounts();
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
      TxData tx = Utils::decodeRawTransaction(rawTxHex);
      std::cout << "Link: " << tx.txlink << std::endl
                << "Operation: " << tx.operation << std::endl
                << "Hex: " << tx.hex << std::endl
                << "Type: " << tx.type << std::endl
                << "Code: " << tx.code << std::endl
                << "To: " << tx.to << std::endl
                << "From: " << tx.from << std::endl
                << "Data: " << tx.data << std::endl
                << "Creates: " << tx.creates << std::endl
                << "Value: " << tx.value << std::endl
                << "Nonce: " << tx.nonce << std::endl
                << "Gas: " << tx.gas << std::endl
                << "Gas Price: " << tx.price << std::endl
                << "Hash: " << tx.hash << std::endl
                << "v: " << tx.v << std::endl
                << "r: " << tx.r << std::endl
                << "s: " << tx.s << std::endl
                << "Date: " << tx.humanDate << " (UNIX timestamp: " << tx.unixDate << ")" << std::endl
                << "Confirmed: " << tx.confirmed << std::endl;

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
