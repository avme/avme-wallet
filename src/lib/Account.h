#ifndef ACCOUNT_H
#define ACCOUNT_H

#include <atomic>
#include <fstream>
#include <iosfwd>
#include <iostream>
#include <mutex>
#include <string>
#include <thread>
#include <vector>
#include <ctime>
#include <iomanip>

#include <boost/algorithm/string.hpp>
#include <boost/algorithm/string/trim_all.hpp>
#include <boost/filesystem.hpp>
#include <boost/thread.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/chrono.hpp>

#include <libdevcore/CommonIO.h>
#include <libdevcore/FileSystem.h>
#include <libdevcore/LoggingProgramOptions.h>
#include <libdevcore/SHA3.h>
#include <libethcore/KeyManager.h>
#include <libethcore/TransactionBase.h>

#include "JSON.h"
#include "Network.h"
#include "Utils.h"

using namespace dev::eth; // TransactionBase

// Mutex for Account balance thread.
static std::mutex balancesThreadLock;

/**
 * Class for a given Account and related functions.
 * e.g. reload balances, show tx history, etc.
 */
class Account {
  public:
    std::string id;
    std::string name;
    std::string address;
    std::vector<std::string> seed;
    std::string balanceAVAX;
    std::string balanceAVME;
    std::string balanceLPFree;
    std::string balanceLPLocked;
    std::vector<TxData> history;
    std::atomic_bool balancesThreadFlag;

    // Constructors (empty, copy and initializer)
    Account(){}
    Account(const Account& acc){
      this->id = acc.id;
      this->name = acc.name;
      this->address = acc.address;
      this->seed = acc.seed;
      this->balanceAVAX = acc.balanceAVAX;
      this->balanceAVME = acc.balanceAVME;
      this->balanceLPFree = acc.balanceLPFree;
      this->balanceLPLocked = acc.balanceLPLocked;
      this->history = acc.history;
    }
    Account(std::string id, std::string name, std::string address, std::vector<std::string> seed) {
      this->id = id;
      this->name = name;
      this->address = address;
      this->seed = seed;
    }

    // Reload an Account's balances.
    static void reloadBalances(Account &a);

    // Handle a thread for reloading Account balances.
    static void balanceThreadHandler(Account &a);
    static void startBalancesThread(Account &a);
    static void stopBalancesThread(Account &a);

    // Convert the transaction history to a JSON array.
    json_spirit::mArray txDataToJSON();

    /**
     * (Re)Load all transactions for the Account from a JSON file to the history.
     * All functions should call this one after they're done, so the
     * transaction list remains updated.
     */
    void loadTxHistory();

    /**
     * Save a new transaction and reload the list.
     * Returns true on success, false on failure.
     */
    bool saveTxToHistory(TxData tx);

    /**
     * Query the confirmed status of *all* transactions made from the Account
     * in the API and update accordingly, then reload the list afterwards.
     * Returns true on success, false on failure.
     */
    bool updateAllTxStatus();
};

#endif // ACCOUNT_H

