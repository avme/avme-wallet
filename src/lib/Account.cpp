#include "Account.h"

void Account::reloadBalances() {
  balancesThreadLock.lock();

  // Get the balances from the network
  // TODO: change FreeLP and LockedLP addresses to the real ones
  json_spirit::mValue AVAXBal = JSON::getValue(
    Network::getAVAXBalance(this->address), "result"
  );
  json_spirit::mValue AVMEBal = JSON::getValue(Network::getAVMEBalance(
    this->address, "0xA687A9cff994973314c6e2cb313F82D6d78Cd232"
  ), "result");
  json_spirit::mValue FreeLPBal = JSON::getValue(Network::getAVMEBalance(
    this->address, "0xA687A9cff994973314c6e2cb313F82D6d78Cd232"
  ), "result");
  json_spirit::mValue LockedLPBal = JSON::getValue(Network::getAVMEBalance(
    this->address, "0xA687A9cff994973314c6e2cb313F82D6d78Cd232"
  ), "result");

  // Convert the balances to u256, then to string
  u256 AVAXu256 = boost::lexical_cast<HexTo<u256>>(AVAXBal.get_str());
  u256 AVMEu256 = boost::lexical_cast<HexTo<u256>>(AVMEBal.get_str());
  u256 FreeLPu256 = boost::lexical_cast<HexTo<u256>>(FreeLPBal.get_str());
  u256 LockedLPu256 = boost::lexical_cast<HexTo<u256>>(LockedLPBal.get_str());
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
    balancesThreadLock.unlock();
    return;
  }

  // Update the balances
  this->balanceAVAX = Utils::weiToFixedPoint(AVAXstr, 18);
  this->balanceAVME = Utils::weiToFixedPoint(AVMEstr, 18);
  this->balanceLPFree = Utils::weiToFixedPoint(FreeLPstr, 18);
  this->balanceLPLocked = Utils::weiToFixedPoint(LockedLPstr, 18);
  balancesThreadLock.unlock();
  return;
}

void Account::reloadBalancesThreadHandler() {
  while (true) {
    boost::this_thread::sleep_for(boost::chrono::seconds(10));
    reloadBalances();
  }
  return;
}

void Account::startBalancesThread() {
  this->balancesThread = boost::thread(&Account::reloadBalancesThreadHandler, this);
  this->balancesThread.detach();
}

void Account::stopBalancesThread() {
  this->balancesThread.boost::thread::~thread();
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
    transactionsArray.push_back(savedTransaction);
  }
  return transactionsArray;
}

void Account::loadTxHistory() {
  try {
    json_spirit::mValue txData = JSON::readFile(this->address.c_str());
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
      this->history.push_back(txData);
    }
  } catch (std::exception &e) {
    std::cout << "Error " << e.what() << std::endl;
  }
}

bool Account::saveTxToHistory(TxData TxData) {
  loadTxHistory();
  json_spirit::mObject transactionsRoot;
  json_spirit::mArray transactionsArray = txDataToJSON();
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
  json_spirit::mValue success = JSON::writeFile(transactionsRoot, this->address.c_str());

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
  loadTxHistory();
  try {
    for (TxData &txData : this->history) {
      if (!txData.confirmed) {
        json_spirit::mValue request;
        std::string jsonRequest = Network::getTxReceipt(txData.hex);
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
  json_spirit::mArray transactionsArray = txDataToJSON();
  transactionsRoot["transactions"] = transactionsArray;
  json_spirit::mValue success = JSON::writeFile(transactionsRoot, this->address.c_str());

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
