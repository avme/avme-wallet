// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "Account.h"

void Account::reloadBalances(Account &a) {
  // Get the balances from the network, check if they're all here
  std::string AVAXBal = API::getAVAXBalance(a.address);
  std::string AVMEBal = API::getAVMEBalance(
    a.address, Pangolin::tokenContracts["AVME"]
  );
  std::string FreeLPBal = API::getAVMEBalance(
    a.address, Pangolin::pairContracts["WAVAX-AVME"]
  );
  std::string LockedLPBal = API::getAVMEBalance(
    a.address, Pangolin::stakingContract
  );
  if (AVAXBal == "" || AVMEBal == "" || FreeLPBal == "" || LockedLPBal == "") {
    return;
  }

  // Convert the balances from hex to u256, then to string
  u256 AVAXu256 = boost::lexical_cast<HexTo<u256>>(AVAXBal);
  u256 AVMEu256 = boost::lexical_cast<HexTo<u256>>(AVMEBal);
  u256 FreeLPu256 = boost::lexical_cast<HexTo<u256>>(FreeLPBal);
  u256 LockedLPu256 = boost::lexical_cast<HexTo<u256>>(LockedLPBal);
  std::string AVAXstr = boost::lexical_cast<std::string>(AVAXu256);
  std::string AVMEstr = boost::lexical_cast<std::string>(AVMEu256);
  std::string FreeLPstr = boost::lexical_cast<std::string>(FreeLPu256);
  std::string LockedLPstr = boost::lexical_cast<std::string>(LockedLPu256);

  // Check if strings are valid
  bool AVAXisValid = (
    AVAXstr != "" && AVAXstr.find_first_not_of("0123456789.") == std::string::npos
  );
  bool AVMEisValid = (
    AVMEstr != "" && AVMEstr.find_first_not_of("0123456789.") == std::string::npos
  );
  bool FreeLPisValid = (
    FreeLPstr != "" && FreeLPstr.find_first_not_of("0123456789.") == std::string::npos
  );
  bool LockedLPisValid = (
    LockedLPstr != "" && LockedLPstr.find_first_not_of("0123456789.") == std::string::npos
  );
  if (!AVAXisValid || !AVMEisValid || !FreeLPisValid || !LockedLPisValid) {
    return;
  }

  // Update the balances
  a.balancesThreadLock.lock();
  a.balanceAVAX = Utils::weiToFixedPoint(AVAXstr, 18);
  a.balanceAVME = Utils::weiToFixedPoint(AVMEstr, 18);
  a.balanceLPFree = Utils::weiToFixedPoint(FreeLPstr, 18);
  a.balanceLPLocked = Utils::weiToFixedPoint(LockedLPstr, 18);
  a.balancesThreadLock.unlock();
  return;
}

void Account::balanceThreadHandler(Account &a) {
  while (true) {
    //std::cout << "Ping! " << a.address << std::endl;
    Account::reloadBalances(a);
    for (int i = 0; i < 1000; i++) {
      boost::this_thread::sleep_for(boost::chrono::milliseconds(1));
      if (a.interruptThread) {
        a.threadWasInterrupted = true;
        return;
      }
    }
  }
}

void Account::startBalancesThread(Account &a) {
  a.interruptThread = false;
  a.threadWasInterrupted = false;
  a.balancesThread = boost::thread(&Account::balanceThreadHandler, boost::ref(a));
  a.balancesThread.detach();
}

void Account::stopBalancesThread(Account &a) {
  a.balancesThreadFlag = true;
}

json_spirit::mArray Account::txDataToJSON() {
  json_spirit::mArray transactionsArray;
  for (TxData savedTxData : this->history) {
    json_spirit::mObject savedTransaction;
    savedTransaction["txlink"] = savedTxData.txlink;
    savedTransaction["operation"] = savedTxData.operation;
    savedTransaction["hex"] = savedTxData.hex;
    savedTransaction["type"] = savedTxData.type;
    savedTransaction["code"] = savedTxData.code;
    savedTransaction["to"] = savedTxData.to;
    savedTransaction["from"] = savedTxData.from;
    savedTransaction["data"] = savedTxData.data;
    savedTransaction["creates"] = savedTxData.creates;
    savedTransaction["value"] = savedTxData.value;
    savedTransaction["nonce"] = savedTxData.nonce;
    savedTransaction["gas"] = savedTxData.gas;
    savedTransaction["price"] = savedTxData.price;
    savedTransaction["hash"] = savedTxData.hash;
    savedTransaction["v"] = savedTxData.v;
    savedTransaction["r"] = savedTxData.r;
    savedTransaction["s"] = savedTxData.s;
    savedTransaction["humanDate"] = savedTxData.humanDate;
    savedTransaction["unixDate"] = savedTxData.unixDate;
    savedTransaction["confirmed"] = savedTxData.confirmed;
    savedTransaction["invalid"] = savedTxData.invalid;
    transactionsArray.push_back(savedTransaction);
  }
  return transactionsArray;
}

void Account::loadTxHistory() {
  json_spirit::mValue txData, txArray;
  boost::filesystem::path txFilePath = Utils::walletFolderPath.string()
    + "/wallet/c-avax/accounts/transactions/" + this->address.c_str();

  txData = JSON::readFile(txFilePath);
  try {
    txArray = JSON::objectItem(txData, "transactions");
    json_spirit::mValue txArray = JSON::objectItem(txData, "transactions");
    this->history.clear();
    for (int i = 0; i < txArray.get_array().size(); ++i) {
      TxData txData;
      txData.txlink = JSON::objectItem(JSON::arrayItem(txArray, i), "txlink").get_str();
      txData.operation = JSON::objectItem(JSON::arrayItem(txArray, i), "operation").get_str();
      txData.hex = JSON::objectItem(JSON::arrayItem(txArray, i), "hex").get_str();
      txData.type = JSON::objectItem(JSON::arrayItem(txArray, i), "type").get_str();
      txData.code = JSON::objectItem(JSON::arrayItem(txArray, i), "code").get_str();
      txData.to = JSON::objectItem(JSON::arrayItem(txArray, i), "to").get_str();
      txData.from = JSON::objectItem(JSON::arrayItem(txArray, i), "from").get_str();
      txData.data = JSON::objectItem(JSON::arrayItem(txArray, i), "data").get_str();
      txData.creates = JSON::objectItem(JSON::arrayItem(txArray, i), "creates").get_str();
      txData.value = JSON::objectItem(JSON::arrayItem(txArray, i), "value").get_str();
      txData.nonce = JSON::objectItem(JSON::arrayItem(txArray, i), "nonce").get_str();
      txData.gas = JSON::objectItem(JSON::arrayItem(txArray, i), "gas").get_str();
      txData.price = JSON::objectItem(JSON::arrayItem(txArray, i), "price").get_str();
      txData.hash = JSON::objectItem(JSON::arrayItem(txArray, i), "hash").get_str();
      txData.v = JSON::objectItem(JSON::arrayItem(txArray, i), "v").get_str();
      txData.r = JSON::objectItem(JSON::arrayItem(txArray, i), "r").get_str();
      txData.s = JSON::objectItem(JSON::arrayItem(txArray, i), "s").get_str();
      txData.humanDate = JSON::objectItem(JSON::arrayItem(txArray, i), "humanDate").get_str();
      txData.unixDate = JSON::objectItem(JSON::arrayItem(txArray, i), "unixDate").get_uint64();
      txData.confirmed = JSON::objectItem(JSON::arrayItem(txArray, i), "confirmed").get_bool();
      txData.invalid = JSON::objectItem(JSON::arrayItem(txArray, i), "invalid").get_bool();
      this->history.push_back(txData);
    }
  } catch (std::exception &e) {
    ;
    // Uncomment to see output
    //std::cout << "Couldn't load history for Account " << this->address
    //          << ": " << JSON::objectItem(txData, "ERROR").get_str() << std::endl;
  }
}

bool Account::saveTxToHistory(TxData TxData) {
  loadTxHistory();
  json_spirit::mObject transactionsRoot;
  json_spirit::mArray transactionsArray = txDataToJSON();
  json_spirit::mObject transaction;
  boost::filesystem::path txFilePath = Utils::walletFolderPath.string()
    + "/wallet/c-avax/accounts/transactions/" + this->address.c_str();

  transaction["txlink"] = TxData.txlink;
  transaction["operation"] = TxData.operation;
  transaction["hex"] = TxData.hex;
  transaction["type"] = TxData.type;
  transaction["code"] = TxData.code;
  transaction["to"] = TxData.to;
  transaction["from"] = TxData.from;
  transaction["data"] = TxData.data;
  transaction["creates"] = TxData.creates;
  transaction["value"] = TxData.value;
  transaction["nonce"] = TxData.nonce;
  transaction["gas"] = TxData.gas;
  transaction["price"] = TxData.price;
  transaction["hash"] = TxData.hash;
  transaction["v"] = TxData.v;
  transaction["r"] = TxData.r;
  transaction["s"] = TxData.s;
  transaction["humanDate"] = TxData.humanDate;
  transaction["unixDate"] = TxData.unixDate;
  transaction["confirmed"] = TxData.confirmed;
  transaction["invalid"] = TxData.invalid;
  transactionsArray.push_back(transaction);

  transactionsRoot["transactions"] = transactionsArray;
  json_spirit::mValue success = JSON::writeFile(transactionsRoot, txFilePath);

  try {
    std::string error = success.get_obj().at("ERROR").get_str();
    std::cout << "Error happened when writing JSON file" << error << std::endl;
  } catch (std::exception &e) {
    loadTxHistory();
    return true;
  }
  loadTxHistory();
  return false;
}

bool Account::updateAllTxStatus() {
  boost::filesystem::path txFilePath = Utils::walletFolderPath.string()
    + "/wallet/c-avax/accounts/transactions/" + this->address.c_str();
  loadTxHistory();
  try {
    for (TxData &txData : this->history) {
      if (!txData.invalid && !txData.confirmed) {
        const auto p1 = std::chrono::system_clock::now();
        uint64_t now = std::chrono::duration_cast<std::chrono::seconds>(p1.time_since_epoch()).count();
        if (txData.unixDate + 60 < now) { // Tx is considered invalid after 60 seconds without confirmation
          txData.invalid = true;
        } else {
          std::string status = API::getTxStatus(txData.hex);
          if (status == "0x1") txData.confirmed = true;
        }
      }
    }
  } catch (std::exception &e) {
    std::cout << "Error: " << e.what();
  }
  json_spirit::mObject transactionsRoot;
  json_spirit::mArray transactionsArray = txDataToJSON();
  transactionsRoot["transactions"] = transactionsArray;
  json_spirit::mValue success = JSON::writeFile(transactionsRoot, txFilePath);

  try {
    std::string error = success.get_obj().at("ERROR").get_str();
    std::cout << "Error happened when writing JSON file" << error << std::endl;
  } catch (std::exception &e) {
    loadTxHistory();
    return true;
  }
  loadTxHistory();
  return false;
}

