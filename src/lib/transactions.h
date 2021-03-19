#include <iostream>
#include <vector>

#include "json.h"
#include "network.h"
#include "storage.h"

// Transaction list for a single Account, given the following struct:
typedef struct WalletTxData {
  std::string txlink;
  std::string operation;
  std::string hex;
  std::string type;
  std::string code;
  std::string to;
  std::string from;
  std::string data;
  std::string creates;
  std::string value;
  std::string nonce;
  std::string gas;
  std::string price;
  std::string hash;
  std::string v;
  std::string r;
  std::string s;
  std::string humanDate;
  uint64_t unixDate;
  bool confirmed;
} WalletTxData;

// TODO: error handling on everything
class TransactionList {
  private:
    std::string address;
    std::vector<WalletTxData> transactions;

    // Convert the transaction list into an array
    json_spirit::mArray LoadAllLocalTransactions();

  public:
    TransactionList(std::string address) {
      this->address = (address.substr(0, 2) == "0x") ? address.substr(2) : address; // Remove "0x"
      LoadAllTransactions();
    }

    std::string getAddress() { return this->address; }
    WalletTxData getTransactionData(int idx) { return transactions[idx]; }
    size_t getTransactionListSize() { return transactions.size(); }

    /**
     * (Re)Load all transactions for the Account from a JSON file into the list.
     * All functions should call this one after they're done, so the
     * transaction list remains updated.
     */
    void LoadAllTransactions();

    /**
     * Save a new transaction and reload the list, using a struct or a raw
     * transaction Hex from the API, respectively.
     * Returns true on success, false on failure.
     */
    bool saveTransaction(WalletTxData TxData);
    bool saveTransactionHash(std::string TxHex);

    /**
     * Query *all* transactions made from the Account in the API and update
     * them locally in the JSON file, then reload the list afterwards.
     * Returns true on success, false on failure.
     */
    bool updateAllTransactions();
};

