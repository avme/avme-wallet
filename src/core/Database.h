// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef DATABASE_H
#define DATABASE_H

#include <string>

#include <network/Pangolin.h>
#include <core/Utils.h>

#include <lib/nlohmann_json/json.hpp>
#include <boost/filesystem.hpp>
#include <leveldb/db.h>

using namespace boost::filesystem;

/**
 * Class for abstracting LevelDB operations.
 */
class Database {
  private:
    // The ARC20 token database, options, status and value.
    leveldb::DB* tokenDB;
    leveldb::Options tokenOpts;
    leveldb::Status tokenStatus;
    std::string tokenValue;

    // The tx history database, options, status and value.
    leveldb::DB* historyDB;
    leveldb::Options historyOpts;
    leveldb::Status historyStatus;
    std::string historyValue;

    // The Ledger account database, options, status and value.
    leveldb::DB* ledgerDB;
    leveldb::Options ledgerOpts;
    leveldb::Status ledgerStatus;
    std::string ledgerValue;

  public:
    // Constructor. Set up any required options here.
    Database() {
      this->tokenOpts.create_if_missing = true;
      this->historyOpts.create_if_missing = true;
      this->ledgerOpts.create_if_missing = true;
      tokenDB = NULL;
      historyDB = NULL;
      ledgerDB = NULL;
    }

    // Token database functions.
    bool openTokenDB();
    std::string getTokenDBStatus();
    void closeTokenDB();
    bool isTokenDBOpen();
    bool tokenDBKeyExists(std::string key);
    std::string getTokenDBValue(std::string key);
    bool putTokenDBValue(std::string key, std::string value);
    bool deleteTokenDBValue(std::string key);
    std::vector<std::string> getAllTokenDBValues();

    // Tx history database functions.
    bool openHistoryDB(std::string address);
    std::string getHistoryDBStatus();
    void closeHistoryDB();
    bool isHistoryDBOpen();
    bool historyDBKeyExists(std::string key);
    std::string getHistoryDBValue(std::string key);
    bool putHistoryDBValue(std::string key, std::string value);
    bool deleteHistoryDBValue(std::string key);
    std::vector<std::string> getAllHistoryDBValues();

    // Ledger account database functions.
    bool openLedgerDB();
    std::string getLedgerDBStatus();
    void closeLedgerDB();
    bool isLedgerDBOpen();
    bool ledgerDBKeyExists(std::string key);
    std::string getLedgerDBValue(std::string key);
    bool putLedgerDBValue(std::string key, std::string value);
    bool deleteLedgerDBValue(std::string key);
    std::vector<std::string> getAllLedgerDBValues();
};

#endif  // DATABASE_H

