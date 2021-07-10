// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "Database.h"

// ======================================================================
// TOKEN DATABASE FUNCTIONS
// ======================================================================

bool Database::openTokenDB(std::string path) {
  this->tokenStatus = leveldb::DB::Open(this->tokenOpts, path, &this->tokenDB);
  return this->tokenStatus.ok();
}

std::string Database::getTokenDBStatus() {
  return this->tokenStatus.toString();
}

void Database::closeTokenDB() {
  delete this->tokenDB;
}

std::string Database::getTokenDBValue(std::string key) {
  this->tokenStatus = this->tokenDB->Get(leveldb::ReadOptions(), key, &this->tokenValue);
  return (this->tokenStatus.ok()) ? this->tokenValue : this->tokenStatus.toString();
}

bool Database::putTokenDBValue(std::string key, std::string value) {
  this->tokenStatus = this->tokenDB->Put(leveldb::WriteOptions(), key, value);
  return this->tokenStatus.ok();
}

bool Database::deleteTokenDBValue(std::string key) {
  this->tokenStatus = this->tokenDB->Delete(leveldb::WriteOptions(), key);
  return this->tokenStatus.ok();
}

// ======================================================================
// TX HISTORY DATABASE FUNCTIONS
// ======================================================================

bool Database::openHistoryDB(std::string path) {
  this->historyStatus = leveldb::DB::Open(this->historyOpts, path, &this->historyDB);
  return this->historyStatus.ok();
}

std::string Database::getHistoryDBStatus() {
  return this->historyStatus.toString();
}

void Database::closeHistoryDB() {
  delete this->historyDB;
}

std::string Database::getHistoryDBValue(std::string key) {
  this->historyStatus = this->tokenDB->Get(leveldb::ReadOptions(), key, &this->historyValue);
  return (this->historyStatus.ok()) ? this->historyValue : this->historyStatus.toString();
}

bool Database::putHistoryDBValue(std::string key, std::string value) {
  this->historyStatus = this->historyDB->Put(leveldb::WriteOptions(), key, value);
  return this->historyStatus.ok();
}

bool Database::deleteHistoryDBValue(std::string key) {
  this->historyStatus = this->historyDB->Delete(leveldb::WriteOptions(), key);
  return this->historyStatus.ok();
}

