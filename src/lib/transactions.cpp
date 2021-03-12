#include "transactions.h"

void TransactionList::LoadAllTransactions() {
  try {
    json_spirit::mValue txData = storage::readJsonFile(this->address.c_str());
    json_spirit::mValue TxArray = JSON::objectItem(txData, "transactions");
    this->transactions.clear();
    for (int i = 0; i < TxArray.get_array().size(); ++i) {
      WalletTxData tmpData;
      tmpData.txlink = JSON::objectItem(JSON::arrayItem(TxArray, i), "txlink").get_str();
      tmpData.operation = JSON::objectItem(JSON::arrayItem(TxArray, i), "operation").get_str();
      tmpData.hex = JSON::objectItem(JSON::arrayItem(TxArray, i), "hex").get_str();
      tmpData.type = JSON::objectItem(JSON::arrayItem(TxArray, i), "type").get_str();
      tmpData.code = JSON::objectItem(JSON::arrayItem(TxArray, i), "code").get_str();
      tmpData.to = JSON::objectItem(JSON::arrayItem(TxArray, i), "to").get_str();
      tmpData.from = JSON::objectItem(JSON::arrayItem(TxArray, i), "from").get_str();
      tmpData.data = JSON::objectItem(JSON::arrayItem(TxArray, i), "data").get_str();
      tmpData.creates = JSON::objectItem(JSON::arrayItem(TxArray, i), "creates").get_str();
      tmpData.value = JSON::objectItem(JSON::arrayItem(TxArray, i), "value").get_str();
      tmpData.nonce = JSON::objectItem(JSON::arrayItem(TxArray, i), "nonce").get_str();
      tmpData.gas = JSON::objectItem(JSON::arrayItem(TxArray, i), "gas").get_str();
      tmpData.price = JSON::objectItem(JSON::arrayItem(TxArray, i), "price").get_str();
      tmpData.hash = JSON::objectItem(JSON::arrayItem(TxArray, i), "hash").get_str();
      tmpData.v = JSON::objectItem(JSON::arrayItem(TxArray, i), "v").get_str();
      tmpData.r = JSON::objectItem(JSON::arrayItem(TxArray, i), "r").get_str();
      tmpData.s = JSON::objectItem(JSON::arrayItem(TxArray, i), "s").get_str();
      tmpData.humanDate = JSON::objectItem(JSON::arrayItem(TxArray, i), "humanDate").get_str();
      tmpData.unixDate = JSON::objectItem(JSON::arrayItem(TxArray, i), "unixDate").get_uint64();
      tmpData.confirmed = JSON::objectItem(JSON::arrayItem(TxArray, i), "confirmed").get_bool();
      this->transactions.push_back(tmpData);
    }
  } catch (std::exception &e) {
    std::cout << "Error " << e.what() << std::endl;
  }
}

json_spirit::mArray TransactionList::LoadAllLocalTransactions() {
  json_spirit::mArray transactionsArray;
  for (WalletTxData savedTxData : this->transactions) {
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
    transactionsArray.push_back(savedTransaction);
  }
  return transactionsArray;
}

bool TransactionList::saveTransaction(WalletTxData TxData) {
  LoadAllTransactions();
  json_spirit::mObject transactionsRoot;
  json_spirit::mArray transactionsArray = LoadAllLocalTransactions();
  json_spirit::mObject transaction;

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
  transactionsArray.push_back(transaction);

  transactionsRoot["transactions"] = transactionsArray;
  json_spirit::mValue success = storage::writeJsonFile(transactionsRoot, this->address.c_str());

  try {
    std::string error = success.get_obj().at("ERROR").get_str();
    std::cout << "Error happened when writing JSON file" << error << std::endl;
  } catch (std::exception &e) {
    LoadAllTransactions();
    return true;
  }
  LoadAllTransactions();
  return false;
}

/**
 * TODO: currently there's no need to implement transaction saving using only
 * the transaction hash, since we have access to the raw transaction itself.
 */
bool TransactionList::saveTransactionHash(std::string TxHex) {
  return false;
}

bool TransactionList::updateAllTransactions() {
  LoadAllTransactions();
  try {
    for (WalletTxData &txData : this->transactions) {
      if (!txData.confirmed) {
        json_spirit::mValue request;
        std::string jsonRequest = Network::getTransactionReceipt(txData.hex);
        json_spirit::read_string(jsonRequest,request);
        json_spirit::mValue result = JSON::objectItem(request, "result");
        json_spirit::mValue jsStatus = JSON::objectItem(result, "status");
        std::string status = jsStatus.get_str();
        if (status == "0x1") txData.confirmed = true;
      }
    }
  } catch (std::exception &e) {
    std::cout << "Error: " << e.what();
  }
  json_spirit::mObject transactionsRoot;
  json_spirit::mArray transactionsArray = LoadAllLocalTransactions();
  transactionsRoot["transactions"] = transactionsArray;
  json_spirit::mValue success = storage::writeJsonFile(transactionsRoot, this->address.c_str());

  try {
    std::string error = success.get_obj().at("ERROR").get_str();
    std::cout << "Error happened when writing JSON file" << error << std::endl;
  } catch (std::exception &e) {
    LoadAllTransactions();
    return true;
  }
  LoadAllTransactions();
  return false;
}

