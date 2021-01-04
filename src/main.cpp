#include "avme-wallet.h"

/**
 * The structure of this program is very simple:
 * - Check if a default wallet exists already. If it does, ask the user if
 *   he wants to load their default wallet or create/load from a different
 *   place. If it doesn't, ask the user to create a new one.
 * - After loading the wallet, store it in a dev::eth::KeyManager object, which
 *   will be used to call different functions for the wallet (e.g. looking up
 *   an address, signing a transaction, etc.)
 * - Use those different functions accordingly to the user input, which is
 *   filtered and processed in the switch case block below
 * Check the header file for more information on what does what.
 * NOTE: some features may not exist or be buggy, take caution.
 */
int main () {
  /**
   * Setup logging options to default so we're not flooded with thousands of
   * debug strings when using the program
   */
  dev::LoggingOptions loggingOptions;
  dev::setupLogging(loggingOptions);

  dev::eth::KeyManager wallet;
  std::string walletPass;
  boost::filesystem::path walletPath;
  boost::filesystem::path secretsPath;
  std::string menuOp;

  // Block that loads/creates the wallet
  std::cout << "Hello! Welcome to the AVME TAEX-CLI wallet." << std::endl;
  bool defaultWalletExists = boost::filesystem::exists(KeyManager::defaultPath());
  bool defaultSecretExists = boost::filesystem::exists(SecretStore::defaultPath());

  if (defaultWalletExists && defaultSecretExists) {
    std::cout << "Default wallet found. How do you want to proceed?\n" <<
                 "1 - Load the default wallet\n" <<
                 "2 - Load another existing wallet\n" <<
                 "3 - Create and load a new wallet" << std::endl;
  } else {
    std::cout << "Default wallet not found. How do you want to proceed?\n" <<
                 "2 - Load an existing wallet\n" <<
                 "3 - Create and load a new wallet" << std::endl;
  }
  std::getline(std::cin, menuOp);

  if (menuOp == "1") {
    walletPath = KeyManager::defaultPath();
    secretsPath = SecretStore::defaultPath();
    wallet = KeyManager(walletPath, secretsPath);
    std::cout << "Enter your wallet's passphrase." << std::endl;
    std::getline(std::cin, walletPass);
  } else if (menuOp == "2") {
    // TODO: fix program not finding just the ".ethereum" folder
    // (it needs to be ".ethereum/keys.info", just ".web3" works fine tho)
    std::string wBuf;
    std::string sBuf;
    std::cout << "Please inform the full path for your wallet." << std::endl;
    std::getline(std::cin, wBuf);
    walletPath = wBuf;
    std::cout << "Please inform the full path for your wallet's secrets." << std::endl;
    std::getline(std::cin, sBuf);
    secretsPath = sBuf;
    wallet = KeyManager(walletPath, secretsPath);
    std::cout << "Enter your wallet's passphrase." << std::endl;
    std::getline(std::cin, walletPass);
  } else if (menuOp == "3") {
    std::string wBuf;
    std::string sBuf;
    std::cout << "Please inform the full path for your wallet, or leave blank for the default." << std::endl;
    std::cout << "Default is " << KeyManager::defaultPath() << std::endl;
    std::getline(std::cin, wBuf);
    walletPath = (wBuf.empty()) ? KeyManager::defaultPath() : wBuf;
    std::cout << "Please inform the full path for your wallet's secrets, or leave blank for the default." << std::endl;
    std::cout << "Default is " << SecretStore::defaultPath() << std::endl;
    std::getline(std::cin, sBuf);
    secretsPath = (sBuf.empty()) ? SecretStore::defaultPath() : sBuf;
    while (true) {
      std::string passConf;
      std::cout << "Enter a master passphrase to protect your key store (make it strong!)." << std::endl;
      std::getline(std::cin, walletPass);
      std::cout << "Please confirm the master passphrase by entering it again." << std::endl;
      std::getline(std::cin, passConf);
      if (walletPass == passConf) { break; }
      std::cout << "Passwords were different. Try again." << std::endl;
    }
    std::cout << "Creating new wallet..." << std::endl;
    wallet = createNewWallet(walletPath, secretsPath, walletPass);
  }
  std::cout << "Loading wallet..." << std::endl;
  if (!loadWallet(wallet, walletPass)) {
    std::cout << "Error loading wallet: wrong passphrase" << std::endl;
    exit(0);
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
      "6 - Erase account\n" <<
      "7 - Create private key from Word/Phrase\n" <<
      "8 - Decode raw transaction\n" <<
      "9 - Exit" << std::endl;
    std::getline(std::cin, menuOp);

    // List accounts
    if (menuOp == "1") {
      std::vector<std::string> ETHAccounts = listETHAccounts(wallet);
      if (!ETHAccounts.empty()) {
        for (auto account : ETHAccounts) {
          std::cout << account << std::endl;
        }
      } else {
        std::cout << "No accounts found." << std::endl;
      }
    } else if (menuOp == "2") {
      std::vector<std::string> TAEXAccounts = listTAEXAccounts(wallet);
      if (!TAEXAccounts.empty()) {
        for (auto account : TAEXAccounts) {
          std::cout << account << std::endl;
        }
      } else {
        std::cout << "No accounts found." << std::endl;
      }

    // Send ETH transactions
    } else if (menuOp == "3") {
      std::string pass;
      std::string passConf;
      std::string signKey;
      std::string destWallet;
      std::string txValue;
      std::string txGas;
      std::string txGasPrice;
      TransactionSkeleton txSkel;
      std::string signedTx;
      std::string transactionLink;

      std::cout << "From which address do you want to send a transaction?" << std::endl;
      std::getline(std::cin, signKey);
      std::cout << "Which address are you sending ETH to?" << std::endl;
      std::getline(std::cin, destWallet);
      std::cout << "How much ETH will you send? (value in fixed point, e.g. 0.5)" << std::endl;
      std::getline(std::cin, txValue);
      txValue = convertFixedPointToWei(txValue, 18);
      std::cout << "Do you want to set your own fee or use an automatic fee?\n" <<
                   "1 - Automatic (default)\n2 - Set my own" << std::endl;
      std::getline(std::cin, menuOp);
      if (menuOp == "1") {
        txGas = "70000";
        txGasPrice = "2500000000";
      } else if (menuOp == "2") {
        // TODO: set custom tax
      }
      while (true) {
        std::cout << "Enter your account's passphrase." << std::endl;
        std::getline(std::cin, pass);
        std::cout << "Please confirm the passphrase by entering it again." << std::endl;
        std::getline(std::cin, passConf);
        if (pass == passConf) { break; }
        std::cout << "Passwords were different. Try again." << std::endl;
      }

      std::cout << "Building transaction..." << std::endl;
      txSkel = buildETHTransaction(signKey, destWallet, txValue, txGas, txGasPrice);
      std::cout << "Signing transaction..." << std::endl;
      signedTx = signTransaction(wallet, pass, signKey, txSkel);
      std::cout << "Transaction signed, broadcasting..." << std::endl;
      transactionLink = sendTransaction(signedTx);
      while (transactionLink.find("Transaction nonce is too low") != std::string::npos ||
          transactionLink.find("Transaction with the same hash was already imported") != std::string::npos) {
        std::cout << "Transaction nonce is too low, trying again with a higher nonce..." << std::endl;
        txSkel.nonce++;
        signedTx = signTransaction(wallet, pass, signKey, txSkel);
        transactionLink = sendTransaction(signedTx);
      }
      std::cout << "Transaction sent! Link: " << transactionLink << std::endl;

    // Send TAEX transactions
    } else if (menuOp == "4") {
      std::string pass;
      std::string passConf;
      std::string signKey;
      std::string destWallet;
      std::string txValue;
      std::string txGas;
      std::string txGasPrice;
      TransactionSkeleton txSkel;
      std::string signedTx;
      std::string transactionLink;

      std::cout << "From which address do you want to send a transaction?" << std::endl;
      std::getline(std::cin, signKey);
      std::cout << "Which address are you sending TAEX to?" << std::endl;
      std::getline(std::cin, destWallet);
      std::cout << "How much TAEX will you send? (value in fixed point, e.g. 0.5 - MAXIMUM 4 DECIMALS!)" << std::endl;
      std::getline(std::cin, txValue);
      txValue = convertFixedPointToWei(txValue, 4);
      std::cout << "Do you want to set your own fee or use an automatic fee?\n" <<
                   "1 - Automatic (default)\n2 - Set my own" << std::endl;
      std::getline(std::cin, menuOp);
      if (menuOp == "1") {
        txGas = "70000";
        txGasPrice = "2500000000";
      } else if (menuOp == "2") {
        // TODO: set custom tax
      }
      while (true) {
        std::cout << "Enter your account's passphrase." << std::endl;
        std::getline(std::cin, pass);
        std::cout << "Please confirm the passphrase by entering it again." << std::endl;
        std::getline(std::cin, passConf);
        if (pass == passConf) { break; }
        std::cout << "Passwords were different. Try again." << std::endl;
      }

      std::cout << "Building transaction..." << std::endl;
      txSkel = buildTAEXTransaction(signKey, destWallet, txValue, txGas, txGasPrice);
      std::cout << "Signing transaction..." << std::endl;
      signedTx = signTransaction(wallet, pass, signKey, txSkel);
      std::cout << "Transaction signed, broadcasting..." << std::endl;
      transactionLink = sendTransaction(signedTx);
      while (transactionLink.find("Transaction nonce is too low") != std::string::npos ||
          transactionLink.find("Transaction with the same hash was already imported") != std::string::npos) {
        std::cout << "Transaction nonce is too low, trying again with a higher nonce..." << std::endl;
        txSkel.nonce++;
        signedTx = signTransaction(wallet, pass, signKey, txSkel);
        transactionLink = sendTransaction(signedTx);
      }
      std::cout << "Transaction sent! Link: " << transactionLink << std::endl;

    // Create new account
    } else if (menuOp == "5") {
      std::string name;
      std::string aPass;
      std::string aPassConf;
      std::string aPassHint;
      bool usesMasterPass;

      std::cout << "Give a name to your account (for ease of use)." << std::endl;
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
        std::cout << "Passwords were different. Try again." << std::endl;
      }
      std::cout << "Creating a new account..." << std::endl;
      std::cout << createNewAccount(wallet, name, aPass, aPassHint, usesMasterPass);
      std::cout << "Reloading wallet..." << std::endl;
      wallet = KeyManager(walletPath, secretsPath);
      loadWallet(wallet, walletPass);

    // Erase account
    // TODO: erase by account name (when the display gets fixed),
    // maybe ask for passphrase too
    } else if (menuOp == "6") {
      std::string account;
      std::cout << "Please inform the account that you want to delete (no going back from here!)." << std::endl;
      std::getline(std::cin, account);
      std::cout << "Erasing account..." << std::endl;
      if (eraseAccount(wallet, account)) {
        std::cout << "Account erased: " << account << std::endl;
        std::cout << "Reloading wallet..." << std::endl;
        wallet = KeyManager(walletPath, secretsPath);
        loadWallet(wallet, walletPass);
      } else {
        std::cout << "Couldn't erase " << account << "; account not found." << std::endl;
      }

    // Create private key
    } else if (menuOp == "7") {
      std::string phrase;
      std::cout << "Please input the passphrase for the wallet." << std::endl;
      std::getline(std::cin, phrase);
      std::cout << "Creating a key pair..." << std::endl;
      createKeyPairFromPhrase(phrase);

    // Exit
    } else if (menuOp == "8") {
      std::string rawTxHex;
      std::cout << "Please input the raw transaction in Hex." << std::endl;
      std::getline(std::cin, rawTxHex);
      decodeRawTransaction(rawTxHex);
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
