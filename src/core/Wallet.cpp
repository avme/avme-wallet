// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "Wallet.h"

void Wallet::storedPassThreadHandler() {
  while (true) {
    std::time_t now = std::time(nullptr);
    if (now > this->storedPassDeadline) break;
    boost::this_thread::sleep_for(boost::chrono::seconds(1));
  }
  this->storedPass = "";
  this->storedPassDeadline = 0;
}

void Wallet::startPassThread(std::string pass, std::time_t deadline) {
  this->storedPass = pass;
  this->storedPassDeadline = deadline;
  this->storedPassThread = boost::thread(boost::bind(&Wallet::storedPassThreadHandler, this));
  this->storedPassThread.detach();
}

void Wallet::stopPassThread() {
  this->storedPass = "";
  this->storedPassDeadline = 0;  // This ensures the thread will be terminated
}

void Wallet::setDefaultPathFolders() {
  auto defaultPath = Utils::getDataDir();
  boost::filesystem::path walletFile = defaultPath.string() + "/wallet/c-avax/wallet.info";
  boost::filesystem::path secretsFolder = defaultPath.string() + "/wallet/c-avax/accounts/secrets";
  boost::filesystem::path historyFolder = defaultPath.string() + "/wallet/c-avax/accounts/transactions";
  if (!exists(walletFile.parent_path())) { create_directories(walletFile.parent_path()); }
  if (!exists(secretsFolder)) { create_directories(secretsFolder); }
  if (!exists(historyFolder)) { create_directories(historyFolder); }
  Utils::walletFolderPath = defaultPath;
  return;
}

bool Wallet::create(boost::filesystem::path folder, std::string pass) {
  // Create the paths if they don't exist yet
  boost::filesystem::path walletFile = folder.string() + "/wallet/c-avax/wallet.info";
  boost::filesystem::path secretsFolder = folder.string() + "/wallet/c-avax/accounts/secrets";
  boost::filesystem::path historyFolder = folder.string() + "/wallet/c-avax/accounts/transactions";
  if (!exists(walletFile.parent_path())) { create_directories(walletFile.parent_path()); }
  if (!exists(secretsFolder)) { create_directories(secretsFolder); }
  if (!exists(historyFolder)) { create_directories(historyFolder); }

  // Initialize a new Wallet
  KeyManager w(walletFile, secretsFolder);
  try {
    w.create(pass);
    Utils::walletFolderPath = folder;
    return true;
  } catch (Exception const& _e) {
    Utils::logToDebug(std::string("Unable to create wallet: ") + boost::diagnostic_information(_e));
    return false;
  }
}

bool Wallet::load(boost::filesystem::path folder, std::string pass) {
  // Load the Wallet, hash+salt the passphrase and store both
  boost::filesystem::path walletFile = folder.string() + "/wallet/c-avax/wallet.info";
  boost::filesystem::path secretsFolder = folder.string() + "/wallet/c-avax/accounts/secrets";
  KeyManager w(walletFile, secretsFolder);
  if (w.load(pass)) {
    this->km = w;
    this->passSalt = h256::random();
    this->passHash = dev::pbkdf2(pass, this->passSalt.asBytes(), this->passIterations);
    Utils::walletFolderPath = folder;
    return true;
  } else {
    return false;
  }
}

void Wallet::close() {
  this->currentAccount = std::make_pair("", "");
  this->currentAccountHistory.clear();
  this->accounts.clear();
  this->ledgerAccounts.clear();
  this->passHash = bytesSec();
  this->passSalt = h256();
  this->km = KeyManager();
  Utils::walletFolderPath = "";
}

bool Wallet::isLoaded() {
  return this->km.exists();
}

bool Wallet::auth(std::string pass) {
  bytesSec hash = dev::pbkdf2(pass, passSalt.asBytes(), passIterations);
  return (hash.ref().toString() == passHash.ref().toString());
}

bool Wallet::loadTokenDB() {
  if (this->db.isTokenDBOpen()) { this->db.closeTokenDB(); }
  return this->db.openTokenDB();
}

bool Wallet::loadHistoryDB(std::string address) {
  if (this->db.isHistoryDBOpen()) { this->db.closeHistoryDB(); }
  return this->db.openHistoryDB(address);
}

bool Wallet::loadLedgerDB() {
  if (this->db.isLedgerDBOpen()) { this->db.closeLedgerDB(); }
  return this->db.openLedgerDB();
}

bool Wallet::loadAppDB() {
  if (this->db.isAppDBOpen()) { this->db.closeAppDB(); }
  return this->db.openAppDB();
}

bool Wallet::loadAddressDB() {
  if (this->db.isAddressDBOpen()) { this->db.closeAddressDB(); }
  return this->db.openAddressDB();
}

bool Wallet::loadConfigDB() {
  if (this->db.isConfigDBOpen()) { this->db.closeConfigDB(); }
  return this->db.openConfigDB();
}

void Wallet::closeTokenDB() { this->db.closeTokenDB(); }
void Wallet::closeHistoryDB() { this->db.closeHistoryDB(); }
void Wallet::closeLedgerDB() { this->db.closeLedgerDB(); }
void Wallet::closeAppDB() { this->db.closeAppDB(); }
void Wallet::closeAddressDB() { this->db.closeAddressDB(); }
void Wallet::closeConfigDB() { this->db.closeConfigDB(); }

void Wallet::loadARC20Tokens() {
  this->ARC20Tokens.clear();
  std::vector<std::string> tokenJsonList = this->db.getAllTokenDBValues();
  for (std::string tokenJson : tokenJsonList) {
    ARC20Token token;
    json tokenData = json::parse(tokenJson);
    token.address = tokenData["address"].get<std::string>();
    token.symbol = tokenData["symbol"].get<std::string>();
    token.name = tokenData["name"].get<std::string>();
    token.decimals = tokenData["decimals"].get<int>();
    token.avaxPairContract = tokenData["avaxPairContract"].get<std::string>();
    this->ARC20Tokens.push_back(token);
  }
}

bool Wallet::addARC20Token(
  std::string address, std::string symbol, std::string name,
  int decimals, std::string avaxPairContract
) {
  json token;
  token["address"] = address;
  token["symbol"] = symbol;
  token["name"] = name;
  token["decimals"] = decimals;
  token["avaxPairContract"] = avaxPairContract;
  bool success = this->db.putTokenDBValue(address, token.dump());
  if (success) { loadARC20Tokens(); }
  return success;
}

bool Wallet::removeARC20Token(std::string address) {
  bool success = this->db.deleteTokenDBValue(address);
  if (success) { loadARC20Tokens(); }
  return success;
}

bool Wallet::ARC20TokenWasAdded(std::string address) {
  return this->db.tokenDBKeyExists(address);
}

void Wallet::loadAccounts() {
  this->accounts.clear();
  if (this->km.store().keys().empty()) { return; }
  AddressHash got;
  std::vector<h128> keys = this->km.store().keys();
  for (auto const& u : keys) {
    if (Address a = this->km.address(u)) {
      got.insert(a);
      this->accounts.emplace(
        "0x" + boost::lexical_cast<std::string>(a),
        this->km.accountName(a)
      );
    }
  }
}

std::pair<std::string, std::string> Wallet::createAccount(
  std::string &seed, int64_t index, std::string name, std::string &pass
) {
  bip3x::Bip39Mnemonic::MnemonicResult mnemonic;
  if (!seed.empty()) { // Using a foreign seed
    mnemonic.raw = seed;
  } else {  // Using the Wallet's own seed
    std::pair<bool,std::string> seedSuccess = BIP39::loadEncryptedMnemonic(mnemonic, pass);
    if (!seedSuccess.first) { return std::make_pair("", ""); }
  }
  std::string indexStr = boost::lexical_cast<std::string>(index);
  bip3x::HDKey keyPair = BIP39::createKey(mnemonic.raw, "m/44'/60'/0'/0/" + indexStr);
  KeyPair k(Secret::frombip3x(keyPair.privateKey));
  h128 u = this->km.import(k.secret(), name, pass, "");
  loadAccounts();
  return std::make_pair(k.address().hex(), name);
}

bool Wallet::importLedgerAccount(std::string address, std::string path) {
  json ledgerAccount;
  ledgerAccount["address"] = address;
  ledgerAccount["index"] = path;
  bool success = this->db.putLedgerDBValue(address, ledgerAccount.dump());
  if (success) { loadLedgerDB(); }
  return success;
}

std::vector<ledger::account> Wallet::getAllLedgerAccounts() {
  std::vector<ledger::account> ret;
  auto accountsList = this->db.getAllLedgerDBValues();
  for (auto account : accountsList) {
    auto accountJson = json::parse(account);
    ret.push_back({accountJson["address"], accountJson["index"]});
  }
  return ret;
}


bool Wallet::deleteLedgerAccount(std::string address) {
  bool success = this->db.deleteLedgerDBValue(address);
  return success;
}
bool Wallet::eraseAccount(std::string address) {
  if (accountExists(address)) {
    this->km.kill(userToAddress(address));
    loadAccounts();
    return true;
  }
  return false; // Account was not found
}

bool Wallet::accountExists(std::string address) {
  return (this->accounts.find(address) != this->accounts.end());
}

void Wallet::setCurrentAccount(std::string address) {
  if (accountExists(address)) {
    this->currentAccount = *this->accounts.find(address);
  }
}

bool Wallet::hasAccountSet() {
  return (!this->currentAccount.first.empty() && !this->currentAccount.second.empty());
}

Address Wallet::userToAddress(std::string const& input) {
  if (h128 u = fromUUID(input)) { return this->km.address(u); }
  DEV_IGNORE_EXCEPTIONS(return toAddress(input));
  for (Address const& a: this->km.accounts()) {
    if (this->km.accountName(a) == input) { return a; }
  }
  return Address();
}

Secret Wallet::getSecret(std::string const& address, std::string pass) {
  if (h128 u = fromUUID(address)) {
    return Secret(this->km.store().secret(u, [&](){ return pass; }, false));
  }
  Address a;
  try {
    a = toAddress(address);
  } catch (...) {
    for (Address const& aa: this->km.accounts()) {
      if (this->km.accountName(aa) == address) {
        a = aa;
        break;
      }
    }
  }
  if (a && accountExists("0x" + boost::lexical_cast<std::string>(a))) {
    return this->km.secret(a, [&](){ return pass; }, false);
  } else {
    std::cerr << "Bad file, UUID or address: " << address << std::endl;
    return Secret();
  }
}

json Wallet::getRegisteredApps() {
  json appList = json::array();
  std::vector<std::string> appJsonList = this->db.getAllAppDBValues();
  for (std::string appJson : appJsonList) {
    appList.push_back(json::parse(appJson));
  }
  return appList;
}

bool Wallet::appIsRegistered(std::string folder) {
  return this->db.appDBKeyExists(folder);
}

bool Wallet::registerApp(
  int chainId, std::string folder, std::string name,
  int major, int minor, int patch
) {
  json app;
  app["chainId"] = chainId;
  app["folder"] = folder;
  app["name"] = name;
  app["major"] = major;
  app["minor"] = minor;
  app["patch"] = patch;
  return this->db.putAppDBValue(folder, app.dump());
}

bool Wallet::unregisterApp(std::string folder) {
  return this->db.deleteAppDBValue(folder);
}

std::map<std::string, std::string> Wallet::getContacts() {
  std::map<std::string, std::string> ret;
  std::vector<std::string> contacts = this->db.getAllAddressDBValues();
  for (std::string contact : contacts) {
    json contactJson = json::parse(contact);
    ret.emplace(contactJson["address"], contactJson["name"]);
  }
  return ret;
}

bool Wallet::addContact(std::string address, std::string name) {
  json contact = json::object();
  contact["address"] = address;
  contact["name"] = name;
  return this->db.putAddressDBValue(address, contact.dump());
}

bool Wallet::removeContact(std::string address) {
  return this->db.deleteAddressDBValue(address);
}

int Wallet::importContacts(std::string file) {
  int ret = 0;
  boost::filesystem::path filePath = file;
  if (!boost::filesystem::exists(filePath)) { return ret; }
  json contacts = json::parse(Utils::readJSONFile(filePath))["contacts"];
  for (json contact : contacts) {
    ret += this->db.putAddressDBValue(contact["address"], contact.dump());
  }
  return ret;
}

int Wallet::exportContacts(std::string file) {
  int ret = 0;
  boost::filesystem::path filePath = file;
  if (!boost::filesystem::exists(filePath.parent_path())) {
    boost::filesystem::create_directories(filePath.parent_path());
  }
  std::vector<std::string> contacts = this->db.getAllAddressDBValues();
  json contactObj = json::object();
  contactObj["contacts"] = json::array();
  for (std::string contact : contacts) {
    json contactJson = json::parse(contact);
    contactObj["contacts"].push_back(contactJson);
    ret++;
  }
  std::string success = Utils::writeJSONFile(contactObj, filePath);
  return (success.empty()) ? ret : 0;
}

TransactionSkeleton Wallet::buildTransaction(
  std::string from, std::string to, std::string value,
  std::string gasLimit, std::string gasPrice, std::string dataHex, std::string txNonce
) {
  TransactionSkeleton txSkel;

  std::cout << txNonce << std::endl;
  // Building the transaction structure
  txSkel.creation = false;
  std::cout << "from: " << from << std::endl;
  txSkel.from = toAddress(from);
  txSkel.to = toAddress(to);
  txSkel.value = u256(value);
  if (!dataHex.empty()) { txSkel.data = fromHex(dataHex); }
  txSkel.nonce = boost::lexical_cast<int>(txNonce);
  txSkel.gas = u256(gasLimit);
  txSkel.gasPrice = u256(gasPrice);
  txSkel.chainId = 43114; // Support for EIP-155
  return txSkel;
}

std::string Wallet::signTransaction(TransactionSkeleton txSkel, std::string pass) {
  std::cout << "Sign from: " << txSkel.from << std::endl;
  std::cout << "Password: " << pass << std::endl;
  Secret s = getSecret("0x" + boost::lexical_cast<std::string>(txSkel.from), pass);
  std::stringstream txHexBuffer;

  try {
    TransactionBase t = TransactionBase(txSkel);
    t.setNonce(txSkel.nonce);
    t.sign(s);
    txHexBuffer << toHex(t.rlp());
  } catch (Exception& ex) {
    Utils::logToDebug(std::string("Invalid Transaction: ") + ex.what());
    return "";
  }

  return txHexBuffer.str();
}

json Wallet::sendTransaction(std::string txidHex, std::string operation) {
  // Send the transaction
  json transactionResult = json::parse(API::broadcastTx(txidHex));

  /**
   * Store the successful transaction in the Account's history.
   * Since the AVAX chain is pretty fast, we can ask if the transaction was
   * already confirmed even immediately after sending it.
   */
  if (transactionResult.contains("result")) {
    std::string txLink = "https://cchain.explorer.avax.network/tx/" + transactionResult["result"].get<std::string>();
    TxData txData = Utils::decodeRawTransaction(txidHex);
    txData.txlink = txLink;
    txData.operation = operation;
    saveTxToHistory(txData);
  }
  return transactionResult;
}

json Wallet::txDataToJSON() {
  json transactionsArray;
  for (TxData savedTxData : this->currentAccountHistory) {
    json savedTransaction;
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

void Wallet::loadTxHistory() {
  this->currentAccountHistory.clear();
  std::vector<std::string> txData = this->db.getAllHistoryDBValues();
  for (std::string txStr : txData) {
    json tx = json::parse(txStr);
    TxData txData;
    txData.txlink = tx["txlink"].get<std::string>();
    txData.operation = tx["operation"].get<std::string>();
    txData.hex = tx["hex"].get<std::string>();
    txData.type = tx["type"].get<std::string>();
    txData.code = tx["code"].get<std::string>();
    txData.to = tx["to"].get<std::string>();
    txData.from = tx["from"].get<std::string>();
    txData.data = tx["data"].get<std::string>();
    txData.creates = tx["creates"].get<std::string>();
    txData.value = tx["value"].get<std::string>();
    txData.nonce = tx["nonce"].get<std::string>();
    txData.gas = tx["gas"].get<std::string>();
    txData.price = tx["price"].get<std::string>();
    txData.hash = tx["hash"].get<std::string>();
    txData.v = tx["v"].get<std::string>();
    txData.r = tx["r"].get<std::string>();
    txData.s = tx["s"].get<std::string>();
    txData.humanDate = tx["humanDate"].get<std::string>();
    txData.unixDate = tx["unixDate"].get<uint64_t>();
    txData.confirmed = tx["confirmed"].get<bool>();
    txData.invalid = tx["invalid"].get<bool>();
    this->currentAccountHistory.push_back(txData);
  }
}

bool Wallet::saveTxToHistory(TxData tx) {
  json transaction;
  transaction["txlink"] = tx.txlink;
  transaction["operation"] = tx.operation;
  transaction["hex"] = tx.hex;
  transaction["type"] = tx.type;
  transaction["code"] = tx.code;
  transaction["to"] = tx.to;
  transaction["from"] = tx.from;
  transaction["data"] = tx.data;
  transaction["creates"] = tx.creates;
  transaction["value"] = tx.value;
  transaction["nonce"] = tx.nonce;
  transaction["gas"] = tx.gas;
  transaction["price"] = tx.price;
  transaction["hash"] = tx.hash;
  transaction["v"] = tx.v;
  transaction["r"] = tx.r;
  transaction["s"] = tx.s;
  transaction["humanDate"] = tx.humanDate;
  transaction["unixDate"] = tx.unixDate;
  transaction["confirmed"] = tx.confirmed;
  transaction["invalid"] = tx.invalid;
  return this->db.putHistoryDBValue(tx.hash, transaction.dump());
}

bool Wallet::updateAllTxStatus() {
  loadTxHistory();
  u256 currentBlock = boost::lexical_cast<HexTo<u256>>(API::getCurrentBlock());
  for (TxData &tx : this->currentAccountHistory) {
    if (!tx.invalid && !tx.confirmed) {
      const auto p1 = std::chrono::system_clock::now();
      uint64_t now = std::chrono::duration_cast<std::chrono::seconds>(p1.time_since_epoch()).count();
      std::string status = API::getTxStatus(tx.hex);
      if (status == "0x1") tx.confirmed = true;
      if (status == "0x0") {
        u256 transactionBlock = boost::lexical_cast<HexTo<u256>>(API::getTxBlock(tx.hex));
        tx.invalid = (currentBlock > transactionBlock);
      }
    }
    saveTxToHistory(tx);
  }
  return true;
}

std::string Wallet::getConfigValue(std::string key) {
  return this->db.getConfigDBValue(key);
}

bool Wallet::setConfigValue(std::string key, std::string value) {
  return this->db.putConfigDBValue(key, value);
}

