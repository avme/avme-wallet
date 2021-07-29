// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "Wallet.h"

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

void Wallet::closeTokenDB() {
  this->db.closeTokenDB();
}

void Wallet::closeHistoryDB() {
  this->db.closeHistoryDB();
}

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

void Wallet::importLedgerAccount(std::string address, std::string path) {
  // Only import if it hasn't been imported yet
  if (this->ledgerAccounts.find(address) == this->ledgerAccounts.end()) {
    this->ledgerAccounts.emplace(address, "ledger-" + path);
  }
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

TransactionSkeleton Wallet::buildTransaction(
  std::string from, std::string to, std::string value,
  std::string gasLimit, std::string gasPrice, std::string dataHex
) {
  TransactionSkeleton txSkel;
  int txNonce;

  // Check if nonce is valid (not an error message)
  std::string txNonceStr = API::getNonce(from);
  if (txNonceStr == "") {
    txSkel.nonce = Utils::MAX_U256_VALUE();
    return txSkel;
  }
  std::stringstream nonceStrm;
  nonceStrm << std::hex << txNonceStr;
  nonceStrm >> txNonce;

  // Building the transaction structure
  txSkel.creation = false;
  txSkel.from = toAddress(from);
  txSkel.to = toAddress(to);
  txSkel.value = u256(value);
  if (!dataHex.empty()) { txSkel.data = fromHex(dataHex); }
  txSkel.nonce = txNonce;
  txSkel.gas = u256(gasLimit);
  txSkel.gasPrice = u256(gasPrice);

  // Support for EIP-155
  #ifdef TESTNET
    txSkel.chainId = 43113;
  #else
    txSkel.chainId = 43114;
  #endif

  return txSkel;
}

std::string Wallet::signTransaction(TransactionSkeleton txSkel, std::string pass) {
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

std::string Wallet::sendTransaction(std::string txidHex, std::string operation) {
  // Send the transaction
  std::string txid = API::broadcastTx(txidHex);
  if (txid == "") { return ""; }
  #ifdef TESTNET
    std::string txLink = "https://cchain.explorer.avax-test.network/tx/" + txid;
  #else
    std::string txLink = "https://cchain.explorer.avax.network/tx/" + txid;
  #endif

  /**
   * Store the successful transaction in the Account's history.
   * Since the AVAX chain is pretty fast, we can ask if the transaction was
   * already confirmed even immediately after sending it.
   */
  TxData txData = Utils::decodeRawTransaction(txidHex);
  txData.txlink = txLink;
  txData.operation = operation;
  saveTxToHistory(txData);
  updateAllTxStatus();
  return txLink;
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
  boost::filesystem::path txFilePath = Utils::walletFolderPath.string()
    + "/wallet/c-avax/accounts/transactions/" + this->currentAccount.first.c_str();
  json txData = json::parse(Utils::readJSONFile(txFilePath));
  try {
    json txArray = txData["transactions"];
    this->currentAccountHistory.clear();
    for (auto& tx : txArray) {
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
  } catch (std::exception &e) {
    Utils::logToDebug(std::string("Couldn't load history for account ")
      + this->currentAccount.first + " : " + txData["ERROR"].get<std::string>());
    // Uncomment to see output
    //std::cout << "Couldn't load history for Account " << this->currentAccount.first
    //          << ": " << txData["ERROR"].get<std::string>() << std::endl;
  }
}

bool Wallet::saveTxToHistory(TxData TxData) {
  loadTxHistory();
  json transactionsRoot, transactionsArray, transaction;
  transactionsArray = txDataToJSON();
  boost::filesystem::path txFilePath = Utils::walletFolderPath.string()
    + "/wallet/c-avax/accounts/transactions/" + this->currentAccount.first.c_str();

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
  std::string success = Utils::writeJSONFile(transactionsRoot, txFilePath);

  // Try/Catch logic is "inverted" - if there's no error it will throw,
  // meaning that it was successful.
  try {
    json err = json::parse(success);
    std::string errMsg = err["ERROR"].get<std::string>();
    Utils::logToDebug("Error happened when writing JSON file: " + errMsg);
  } catch (std::exception &e) {
    loadTxHistory();
    return true;
  }
  loadTxHistory();
  return false;
}

bool Wallet::updateAllTxStatus() {
  boost::filesystem::path txFilePath = Utils::walletFolderPath.string()
    + "/wallet/c-avax/accounts/transactions/" + this->currentAccount.first.c_str();
  loadTxHistory();
  u256 currentBlock = boost::lexical_cast<HexTo<u256>>(API::getCurrentBlock());
  try {
    for (TxData &txData : this->currentAccountHistory) {
      if (!txData.invalid && !txData.confirmed) {
        const auto p1 = std::chrono::system_clock::now();
        uint64_t now = std::chrono::duration_cast<std::chrono::seconds>(p1.time_since_epoch()).count();
        std::string status = API::getTxStatus(txData.hex);
        if (status == "0x1") txData.confirmed = true;
        if (status == "0x0") {
          u256 transactionBlock = boost::lexical_cast<HexTo<u256>>(API::getTxBlock(txData.hex));
          if (currentBlock > transactionBlock) {
            txData.invalid = true;
          }
        }
      }
    }
  } catch (std::exception &e) {
    Utils::logToDebug(std::string("Error when updating AllTxStatus: ") + e.what());
  }
  json transactionsRoot, transactionsArray;
  transactionsArray = txDataToJSON();
  transactionsRoot["transactions"] = transactionsArray;
  std::string success = Utils::writeJSONFile(transactionsRoot, txFilePath);
  // Try/Catch logic is "inverted" - if there's no error it will throw,
  // meaning that it was successful.
  try {
    json err = json::parse(success);
    std::string error = err["ERROR"].get<std::string>();
    Utils::logToDebug(std::string("Error happened when writing JSON file: ") + error);
  } catch (std::exception &e) {
    loadTxHistory();
    return true;
  }
  loadTxHistory();
  return false;
}

