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

  // Initialize a new Wallet, hash+salt the passphrase and store both
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
  this->accounts.clear();
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

Account Wallet::createAccount(
  std::string &seed, int64_t index, std::string name, std::string &pass
) {
  bip3x::Bip39Mnemonic::MnemonicResult mnemonic;
  if (!seed.empty()) { // Using a foreign seed
    mnemonic.raw = seed;
  } else {  // Using the Wallet's own seed
    std::pair<bool,std::string> seedSuccess = BIP39::loadEncryptedMnemonic(mnemonic, pass);
    if (!seedSuccess.first) { return Account(); }
  }
  std::string indexStr = boost::lexical_cast<std::string>(index);
  bip3x::HDKey keyPair = BIP39::createKey(mnemonic.raw, "m/44'/60'/0'/0/" + indexStr);
  KeyPair k(Secret::frombip3x(keyPair.privateKey));
  h128 u = this->km.import(k.secret(), name, pass, "");
  return Account(toUUID(u), name, k.address().hex());
}

void Wallet::loadAccounts() {
  this->accounts.clear();
  if (this->km.store().keys().empty()) { return; }
  AddressHash got;
  std::vector<h128> keys = this->km.store().keys();
  for (auto const& u : keys) {
    if (Address a = this->km.address(u)) {
      got.insert(a);
      Account acc(toUUID(u), this->km.accountName(a),
        "0x" + boost::lexical_cast<std::string>(a));
      this->accounts.push_back(acc);
    }
  }
}

Account Wallet::getAccountByName(std::string name) {
  for (int i = 0; i < this->accounts.size(); i++) {
    if (this->accounts[i].name == name) {
      return this->accounts[i];
    }
  }
  return Account();
}

Account Wallet::getAccountByAddress(std::string address) {
  // Add the "0x" if it's missing
  if (address.substr(0, 2) != "0x") { address.insert(0, "0x"); }
  for (int i = 0; i < this->accounts.size(); i++) {
    if (this->accounts[i].address == address) {
      return this->accounts[i];
    }
  }
  return Account();
}

bool Wallet::eraseAccount(std::string account) {
  if (accountExists(account)) {
    this->km.kill(userToAddress(account));
    return true;
  }
  return false; // Account was not found
}

bool Wallet::accountExists(std::string account) {
  for (Address const& a: this->km.accounts()) {
    std::string acc = "0x" + boost::lexical_cast<std::string>(a);
    std::string acc2 = "0x" + boost::lexical_cast<std::string>(userToAddress(account));
    if (acc == acc2) { return true; }
  }
  return false;
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
  if (a && accountExists(boost::lexical_cast<std::string>(a))) {
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
  Account a = getAccountByAddress(txData.from);
  a.saveTxToHistory(txData);
  a.updateAllTxStatus();
  return txLink;
}

