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
  boost::filesystem::path walletPath;
  boost::filesystem::path secretsPath;

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
  int op;
  std::cin >> op;
  std::cin.clear();
  std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

  switch (op) {
    case 1:
      {
        walletPath = KeyManager::defaultPath();
        secretsPath = SecretStore::defaultPath();
        std::cout << "Loading default wallet..." << std::endl;
        wallet = loadWallet(walletPath, secretsPath);
        break;
      }
    case 2:
      {
        // TODO: fix program not finding just the ".ethereum" folder
        // (it needs to be ".ethereum/keys.info", just ".web3" works fine tho)
        std::string wPath;
        std::string sPath;

        std::cout << "Please inform the full path for your wallet." << std::endl;
        std::getline(std::cin, wPath);
        std::cout << "Please inform the full path for your wallet's secrets." << std::endl;
        std::getline(std::cin, sPath);
        walletPath = wPath;
        secretsPath = sPath;

        std::cout << "Loading wallet..." << std::endl;
        wallet = loadWallet(walletPath, secretsPath);
        break;
      }
    case 3:
      {
        std::string wPath;
        std::string sPath;
        std::string wPass;
        std::string wPassConf;

        std::cout << "Please inform the full path for your wallet, or leave blank for the default." << std::endl;
        std::cout << "Default is " << KeyManager::defaultPath() << std::endl;
        std::getline(std::cin, wPath);
        std::cout << "Please inform the full path for your wallet's secrets, or leave blank for the default." << std::endl;
        std::cout << "Default is " << SecretStore::defaultPath() << std::endl;
        std::getline(std::cin, sPath);
        while (true) {
          std::cout << "Enter a master passphrase to protect your key store (make it strong!)." << std::endl;
          std::getline(std::cin, wPass);
          std::cout << "Please confirm the master passphrase by entering it again." << std::endl;
          std::getline(std::cin, wPassConf);
          if (wPass == wPassConf) { break; }
          std::cout << "Passwords were different. Try again." << std::endl;
        }

        walletPath = (wPath != "") ? wPath : KeyManager::defaultPath();
        secretsPath = (sPath != "") ? sPath : SecretStore::defaultPath();
        std::cout << "Creating new wallet..." << std::endl;
        wallet = createNewWallet(walletPath, secretsPath, wPass);
        break;
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
      "6 - Erase account\n" <<
      "7 - Create private key from Word/Phrase\n" <<
      "8 - Exit" << std::endl;
    std::cin.clear();
    fflush(stdin);

    // Process user input
    int userinput;
    std::cin >> userinput;
    std::cin.clear();
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

    switch (userinput) {
      case 1:
        {
          std::vector<std::string> ETHAccounts = listETHAccounts(wallet);
          if (!ETHAccounts.empty()) {
            for (auto account : ETHAccounts) {
              std::cout << account << std::endl;
            }
          } else {
            std::cout << "No accounts found." << std::endl;
          }
          break;
        }
      case 2:
        {
          std::vector<std::string> TAEXAccounts = listTAEXAccounts(wallet);
          if (!TAEXAccounts.empty()) {
            for (auto account : TAEXAccounts) {
              std::cout << account << std::endl;
            }
          } else {
            std::cout << "No accounts found." << std::endl;
          }
          break;
        }
      case 3:
        {
          std::string pass;
          std::string passConf;
          std::string signKey;
          std::string destWallet;
          std::string txValue;
          std::string txGas;
          std::string txGasPrice;
          int op;

          std::cout << "From which address do you want to send a transaction?" << std::endl;
          std::getline(std::cin, signKey);
          std::cout << "Which address are you sending ETH to?" << std::endl;
          std::getline(std::cin, destWallet);
          std::cout << "How much ETH will you send? (value in fixed point, e.g. 0.5)" << std::endl;
          std::getline(std::cin, txValue);
          txValue = convertFixedPointToWei(txValue, 18);
          std::cout << "Do you want to set your own fee or use an automatic fee?\n" <<
                       "1 - Automatic (default)\n2 - Set my own" << std::endl;
          std::cin >> op;
          if (op == 2) {
            // TODO: set custom tax
          } else {
            txGas = "70000";
            txGasPrice = "2500000000";
          }
          while (true) {
            std::cout << "Enter your account's passphrase." << std::endl;
            std::getline(std::cin, pass);
            std::cout << "Please confirm the passphrase by entering it again." << std::endl;
            std::getline(std::cin, passConf);
            if (pass == passConf) { break; }
            std::cout << "Passwords were different. Try again." << std::endl;
          }

          TransactionSkeleton txSkel;
          std::string signedTx;
          std::string transactionLink;

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
          break;
        }
      case 4:
        {
          std::string pass;
          std::string passConf;
          std::string signKey;
          std::string destWallet;
          std::string txValue;
          std::string txGas;
          std::string txGasPrice;
          int op;

          std::cout << "From which address do you want to send a transaction?" << std::endl;
          std::getline(std::cin, signKey);
          std::cout << "Which address are you sending TAEX to?" << std::endl;
          std::getline(std::cin, destWallet);
          std::cout << "How much TAEX will you send? (value in fixed point, e.g. 0.5 - MAXIMUM 4 DECIMALS!)" << std::endl;
          std::getline(std::cin, txValue);
          txValue = convertFixedPointToWei(txValue, 4);
          std::cout << "Do you want to set your own fee or use an automatic fee?\n" <<
                       "1 - Automatic (default)\n2 - Set my own" << std::endl;
          std::cin >> op;
          if (op == 2) {
            // TODO: set custom tax
          } else {
            txGas = "70000";
            txGasPrice = "2500000000";
          }
          while (true) {
            std::cout << "Enter your account's passphrase." << std::endl;
            std::getline(std::cin, pass);
            std::cout << "Please confirm the passphrase by entering it again." << std::endl;
            std::getline(std::cin, passConf);
            if (pass == passConf) { break; }
            std::cout << "Passwords were different. Try again." << std::endl;
          }

          TransactionSkeleton txSkel;
          std::string signedTx;
          std::string transactionLink;

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
          break;
        }
      case 5:
        {
          std::string name;
          std::string aPass;
          std::string aPassConf;
          std::string aPassHint;

          std::cout << "Please inform an account name." << std::endl;
          std::getline(std::cin, name); // TODO: understand what's the purpose of the "name"
          while (true) {
            std::cout << "Enter a passphrase to secure this account (or leave blank to use the master passphrase)." << std::endl;
            std::getline(std::cin, aPass);
            std::cout << "Please confirm the passphrase by entering it again." << std::endl;
            std::getline(std::cin, aPassConf);
            if (aPass == aPassConf) {
              std::cout << "Enter a hint to help you remember this passphrase (or leave blank for nothing)." << std::endl;
              std::getline(std::cin, aPassHint);
              break;
            }
            std::cout << "Passwords were different. Try again." << std::endl;
          }

          std::cout << "Creating a new account..." << std::endl;
          createNewAccount(wallet, name, aPass, aPassHint);
          std::cout << "Reloading wallet..." << std::endl;
          wallet = loadWallet(walletPath, secretsPath);
        }
        break;
      case 6:
        {
          std::string account;
          std::cout << "Please inform the account that you want to delete (no going back from here!)." << std::endl;
          std::getline(std::cin, account);
          std::cout << "Erasing account..." << std::endl;
          if (eraseAccount(wallet, account)) {
            std::cout << "Account " << account << " erased." << std::endl;
            std::cout << "Reloading wallet..." << std::endl;
            wallet = loadWallet(walletPath, secretsPath);
          } else {
            std::cout << "Couldn't erase account " << account << "; not found." << std::endl;
          }
          break;
        }
      case 7:
        {
          std::string phrase;
          std::cout << "Please input the passphrase for the wallet." << std::endl;
          std::getline(std::cin, phrase);
          std::cout << "Creating a key pair..." << std::endl;
          createKeyPairFromPhrase(phrase);
        }
        break;
      case 8:
        std::cout << "Exiting..." << std::endl;
        exit(0);
        break;
      default:
        std::cout << "Wrong input, please check again" << std::endl;
        break;
    }
  }

  return 0;
}
