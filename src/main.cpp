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
  std::cout << "Hello! Welcome to the AVME TAEX-CLI wallet" << std::endl;

  /**
   * Setup logging options to default so we're not flooded with thousands of
   * debug strings when using the program
   */
  dev::LoggingOptions loggingOptions;
  dev::setupLogging(loggingOptions);

  std::cout << "Loading wallet..." << std::endl;
  dev::eth::KeyManager wallet = LoadWallet();
  std::cout << "Wallet loaded." << std::endl;

  while (true) {
    std::cout << "What you are looking to do today?\n" <<
      "1 - List ETH accounts and balances\n" <<
      "2 - List TAEX accounts and balances\n" <<
      "3 - Send an ETH Transaction\n" <<
      "4 - Send a TAEX Transaction\n" <<
      "5 - Create a new account\n" <<
      "6 - Erase account\n" <<
      "7 - Create private key from Word/Phrase\n" <<
      "8 - Exit" << std::endl;
    /**
     * Clean input beforehand. Uncomment these and you will see some
     * stupid bugs that can happen.
     */
    cin.clear();
    fflush(stdin);

    // Process user input
    int userinput;
    std::cin >> userinput;
    switch (userinput) {
      case 1:
        ListETHAccounts(wallet);
        break;
      case 2:
        ListTAEXAccounts(wallet);
        break;
      case 3:
        SignETHTransaction(wallet);
        break;
      case 4:
        SignTAEXTransaction(wallet);
        break;
      case 5:
        {
          std::string name;
          std::cout << "Please inform an account name" << std::endl;
          std::cin.clear();
          std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
          std::getline(std::cin, name);
          CreateNewAccount(wallet, name);
          std::cout << "Reloading account..." << std::endl;
          wallet = LoadWallet();
        }
        break;
      case 6:
        EraseAccount(wallet);
        std::cout << "Reloading account..." << std::endl;
        wallet = LoadWallet();
        break;
      case 7:
        {
          std::string phrase;
          std::cout << "Please input the passphrase for the wallet" << std::endl;
          std::cin.clear();
          std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
          std::getline(std::cin, phrase);
          CreateKeyPairFromPhrase(phrase);
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
