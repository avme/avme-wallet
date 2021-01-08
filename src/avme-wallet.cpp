// Aleth: Ethereum C++ client, tools and libraries.
// Copyright 2015-2019 Aleth Authors.
// Licensed under the GNU General Public License, Version 3.
/// @file
/// CLI module for key management.
#pragma once

#include "avme-wallet.h"

// Get object item from a JSON element.
const json_spirit::mValue WalletManager::get_object_item(
  const json_spirit::mValue element, const std::string name
) {
  return element.get_obj().at(name);
}

// Get array item from a JSON element.
const json_spirit::mValue WalletManager::get_array_item(
  const json_spirit::mValue element, size_t index
) {
  return element.get_array().at(index);
}

// Get a specific value from a JSON element.
std::string WalletManager::get_json_value(std::string json, std::string value) {
  std::string ret;
  json_spirit::mValue jsonValue;
  auto jsonSuccess = json_spirit::read_string(json, jsonValue);

  if (jsonSuccess) {
    try {
      ret = get_object_item(jsonValue, value).get_str();
    } catch (std::exception &e) {
      std::cout << "Error when reading json for \"" << value << "\": " << e.what() << std::endl;
      ret = get_object_item(get_object_item(jsonValue, "error"), "message").get_str();
      std::cout << "Message: " << ret << std::endl;
    }
  } else {
    std::cout << "Error reading json, check json value: " << json << std::endl;
    ret = "";
  }

  return ret;
}

// Set MAX_U256_VALUE for error handling.
u256 WalletManager::MAX_U256_VALUE() {
  return (raiseToPow(2, 256) - 1);
}

// Load and authenticate a wallet from the given paths.
bool WalletManager::loadWallet(path walletPath, path secretsPath, std::string walletPass) {
  KeyManager w(walletPath, secretsPath);
  if (w.load(walletPass)) {
    this->wallet = w;
    return true;
  } else {
    return false;
  }
}

/**
 * Load the SecretStore (an object inside KeyManager that contains all secrets
 * for the addresses stored in it).
 */
SecretStore& WalletManager::secretStore() {
  return this->wallet.store();
}

// Create a new wallet, which should be loaded manually afterwards.
bool WalletManager::createNewWallet(path walletPath, path secretsPath, std::string walletPass) {
  // Create the paths if they don't exist yet.
  // Remember walletPath points to a *file*, and secretsPath points to a *dir*.
  if (!exists(walletPath.parent_path())) {
    create_directories(walletPath.parent_path());
  }
  if (!exists(secretsPath)) {
    create_directories(secretsPath);
  }

  // Initialize the new wallet
  KeyManager w(walletPath, secretsPath);
  try {
    w.create(walletPass);
    return true;
  } catch (Exception const& _e) {
    std::cerr << "Unable to create wallet" << std::endl << boost::diagnostic_information(_e);
    return false;
  }
}

/**
 * Create a new Account in the given wallet and encrypt it.
 * An Account contains an ETH address and other stuff.
 * See https://ethereum.org/en/developers/docs/accounts/ for more info.
 */
WalletAccount WalletManager::createNewAccount(
  std::string name, std::string pass, std::string hint, bool usesMasterPass
) {
  auto k = makeKey();
  h128 u = this->wallet.import(k.secret(), name, pass, hint);
  WalletAccount ret;

  ret.id = toUUID(u);
  ret.name = name;
  ret.address = k.address().hex();
  ret.hint = (usesMasterPass) ? "Uses master passphrase" : hint;

  return ret;
}

/**
 * Hash a given phrase to create a new address based on that phrase.
 * It's easier to hash since hashing creates the 256-bit variable used by
 * the private key.
 */
void WalletManager::createKeyPairFromPhrase(std::string phrase) {
  std::string shahash = dev::sha3(phrase, false);
  for (auto i = 0; i < 1048577; ++i) {
    shahash = dev::sha3(shahash, false);
  }
  KeyPair k(Secret::fromString(shahash));
  k = KeyPair(Secret(sha3(k.secret().ref())));
  std::cout << "Wallet generated! Address: " << k.address().hex() << std::endl;
  std::cout << "Hashed: " << shahash << "Size: " << shahash.size() << std::endl;
  return;
}

// Erase an Account from the wallet.
bool WalletManager::eraseAccount(std::string account) {
  if (Address a = userToAddress(account)) {
    if (accountIsEmpty(account)) {
      this->wallet.kill(a);
      return true;
    }
  }
  return false; // Account was either not found or has funds in it
}

// Check if an account is completely empty.
bool WalletManager::accountIsEmpty(std::string account) {
  if (account.find("0x") == std::string::npos) {
    account = "0x" + boost::lexical_cast<std::string>(userToAddress(account));
  }
  std::string requestETH = Network::getETHBalance(account);
  std::string requestTAEX = Network::getTAEXBalance(account);
  std::string amountETH = get_json_value(requestETH, "result");
  std::string amountTAEX = get_json_value(requestTAEX, "result");
  return (amountETH == "0" && amountTAEX == "0");
}

// Select the appropriate account name or address stored in KeyManager from user input string.
Address WalletManager::userToAddress(std::string const& input) {
  if (h128 u = fromUUID(input)) { return this->wallet.address(u); }
  DEV_IGNORE_EXCEPTIONS(return toAddress(input));
  for (Address const& a: this->wallet.accounts()) {
    if (this->wallet.accountName(a) == input) { return a; }
  }
  return Address();
}

// Load the secret key for a given address in the wallet.
Secret WalletManager::getSecret(std::string const& signKey, std::string pass) {
  if (h128 u = fromUUID(signKey)) {
    return Secret(secretStore().secret(u, [&](){ return pass; }));
  }

  Address a;
  try {
    a = toAddress(signKey);
  } catch (...) {
    for (Address const& aa: this->wallet.accounts()) {
      if (this->wallet.accountName(aa) == signKey) {
        a = aa;
        break;
      }
    }
  }

  if (a) {
    return this->wallet.secret(a, [&](){ return pass; });
  } else {
    std::cerr << "Bad file, UUID or address: " << signKey << std::endl;
    exit(-1);
  }
}

// Create a key from a random string of characters. Check FixedHash.h for more info.
KeyPair WalletManager::makeKey() {
  KeyPair k(Secret::random());
  k = KeyPair(Secret(sha3(k.secret().ref())));
  return k;
}

/**
 * Convert a full amount of ETH in Wei to a fixed point, more human-friendly value.
 * BTC has 8 decimals but is considered a full integer in code, so 1.0 BTC
 * actually means 100000000 satoshis.
 * Likewise with ETH, which has 18 digits, so 1.0 ETH actually means
 * 1000000000000000000 Wei.
 * To make it easier/better for the user to e.g. view their balance, we have
 * to convert this many digits to a fixed point value.
 */
std::string WalletManager::convertWeiToFixedPoint(std::string amount, size_t digits) {
  std::string result;

  if (amount.size() <= digits) {
    size_t ValueToPoint = digits - amount.size();
    result += "0.";
    for (size_t i = 0; i < ValueToPoint; ++i) {
      result += "0";
    }
    result += amount;
  } else {
    result = amount;
    size_t pointToPlace = result.size() - digits;
    result.insert(pointToPlace, ".");
  }

  return result;
}

/**
 * Convert a fixed point amount of ETH to a full amount in Wei.
 * Likewise, we also need to convert user-provided fixed point values
 * back to the original 18-decimals Wei amount to create transactions.
 */
std::string WalletManager::convertFixedPointToWei(std::string amount, int decimals) {
  std::string digitPadding = "";
  std::string valuestr = "";

  // Check if input is valid
  for (auto &c : amount)
    if (!std::isdigit(c) && c != '.')
      return "";

  // Read value from input string
  size_t index = 0;
  while (index < amount.size() && amount[index] != '.') {
    valuestr += amount[index];
    ++index;
  }

  // Jump fixed point.
  ++index;

  // Check if fixed point exists
  if (amount[index-1] == '.' && (amount.size() - (index)) > decimals)
    return "";

  // Check if input precision matches digit precision
  if (index < amount.size()) {
    // Read precision point into digitPadding
    while (index < amount.size()) {
      digitPadding += amount[index];
      ++index;
    }
  }

  // Create padding if there are missing decimals
  while(digitPadding.size() < decimals)
    digitPadding += '0';
  valuestr += digitPadding;
  while(valuestr[0] == '0')
    valuestr.erase(0,1);

  return valuestr;
}

// List the wallet's ETH accounts and their balances.
std::vector<WalletAccount> WalletManager::listETHAccounts() {
  if (this->wallet.store().keys().empty()) { return {}; }
  AddressHash got;
  std::vector<WalletAccount> ret;

  for (auto const& u: this->wallet.store().keys()) {
    WalletAccount wa;
    if (Address a = this->wallet.address(u)) {  // Normal accounts
      got.insert(a);
      wa.id = toUUID(u);
      wa.privKey = a.abridged();
      wa.name = this->wallet.accountName(a);
      wa.address = "0x" + boost::lexical_cast<std::string>(a);
      std::string balance = get_json_value(Network::getETHBalance(wa.address), "result");
      if (balance == "") { return {}; }
      for (auto &c : balance) {
        if (!std::isdigit(c) && c != '.') {
          return {};
        }
      }
      wa.balanceETH = convertWeiToFixedPoint(balance, 18);
    } else {  // Bare accounts
      wa.address = "0x" + boost::lexical_cast<std::string>(a) + " (Bare)";
    }
    ret.push_back(wa);
  }

  return ret;
}

/**
 * List the wallet's TAEX accounts and their amounts.
 * ERC-20 tokens need to be loaded in a different way, from their proper
 * contract address, beside their respective wallet address.
 */
std::vector<WalletAccount> WalletManager::listTAEXAccounts() {
  if (this->wallet.store().keys().empty()) { return {}; }
  AddressHash got;
  std::vector<WalletAccount> ret;

  for (auto const& u: this->wallet.store().keys()) {
    WalletAccount wa;
    if (Address a = this->wallet.address(u)) {  // Normal accounts
      got.insert(a);
      wa.id = toUUID(u);
      wa.privKey = a.abridged();
      wa.name = this->wallet.accountName(a);
      wa.address = "0x" + boost::lexical_cast<std::string>(a);
      std::string balance = get_json_value(Network::getTAEXBalance(wa.address), "result");
      if (balance == "") { return {}; }
      for (auto &c : balance) {
        if (!std::isdigit(c) && c != '.') {
          return {};
        }
      }
      wa.balanceTAEX = convertWeiToFixedPoint(balance, 4);
    } else {  // Bare accounts
      wa.address = "0x" + boost::lexical_cast<std::string>(a) + " (Bare)";
    }
    ret.push_back(wa);
  }

  return ret;
}

// Get an automatic amount of fees for the transaction.
// TODO: make the user choose between slower or faster fees from the data at:
// https://ropsten.etherscan.io/api?module=gastracker&action=gasoracle&apikey=6342MIVP4CD1ZFDN3HEZZG4QB66NGFZ6RZ
std::string WalletManager::getAutomaticFee() {
  std::string txGasPrice;
  std::string txGasPriceGwei;
  u256 txGasPriceu256;
  std::string txGasPriceRequest = Network::getTxFees();
  json_spirit::mValue txGasPriceJson;

  // TODO: incorporate this into get_json_value somehow (try block has two layers instead of one)
  auto success = json_spirit::read_string(txGasPriceRequest, txGasPriceJson);
  if (success) {
    try {
      auto jsonResult = get_object_item(get_object_item(txGasPriceJson,"result"), "SafeGasPrice");
      txGasPriceGwei = jsonResult.get_str();
    } catch (std::exception &e) {
      std::cout << "Error when reading json for SafeGasPrice: " << e.what() << std::endl;
      auto jsonResult = get_object_item(get_object_item(txGasPriceJson,"error"), "message");
      std::cout << "Json message: " << jsonResult.get_str() << std::endl;
      std::cout << "Setting txGasPrice to default..." << std::endl;
      txGasPriceGwei = "50";
    }
  } else {
    std::cout << "Error reading json, check json value: " << txGasPriceRequest << std::endl;
  }
  txGasPriceu256 = boost::lexical_cast<u256>(txGasPriceGwei) * raiseToPow(10, 9);
  txGasPrice = boost::lexical_cast<std::string>(txGasPriceu256);

  return txGasPrice;
}

// Build transaction data to send ERC-20 tokens.
std::string WalletManager::buildTxData(std::string txValue, std::string destWallet) {
  std::string txdata;
  // Hex and padding that will call the "send" function of the address
  std::string sendpadding = "a9059cbb000000000000000000000000";
  // Padding for the value variable of the "send" function
  std::string valuepadding = "0000000000000000000000000000000000000000000000000000000000000000";

  txdata += sendpadding;
  if (destWallet[0] == '0' && destWallet[1] == 'x') {
    destWallet.erase(0,2);
  }
  txdata += destWallet;

  // Convert to HEX
  u256 intValue = boost::lexical_cast<u256>(intValue);
  std::stringstream ss;
  ss << std::hex << intValue;
  std::string amountStrHex = ss.str();

  for (auto& c : amountStrHex) {
    if (std::isupper(c)) {
      c = std::tolower(c);
    }
  }

  for (size_t i = (amountStrHex.size() - 1), x = (valuepadding.size() - 1),
      counter = 0; counter < amountStrHex.size(); --i, --x, ++counter) {
    valuepadding[x] = amountStrHex[i];
  }

  txdata += valuepadding;
  return txdata;
}

// Build an ETH transaction from user data.
TransactionSkeleton WalletManager::buildETHTransaction(
  std::string signKey, std::string destWallet,
  std::string txValue, std::string txGas, std::string txGasPrice
) {
  TransactionSkeleton txSkel;
  int txNonce;

  std::string nonceApiRequest = Network::getTxNonce(signKey);
  std::string txNonceStr = get_json_value(nonceApiRequest, "result");
  // Check if nonce is valid (not an error message)
  if (txNonceStr == "") {
    txSkel.nonce = MAX_U256_VALUE();
    return txSkel;
  }
  std::stringstream nonceStrm;
  nonceStrm << std::hex << txNonceStr;
  nonceStrm >> txNonce;

  // Building the transaction structure
  txSkel.creation = false;
  txSkel.to = toAddress(destWallet);
  txSkel.value = u256(txValue);
  txSkel.nonce = txNonce;
  txSkel.gas = u256(txGas);
  txSkel.gasPrice = u256(txGasPrice);

  return txSkel;
}

// Build a TAEX transaction from user data.
TransactionSkeleton WalletManager::buildTAEXTransaction(
  std::string signKey, std::string destWallet,
  std::string txValue, std::string txGas, std::string txGasPrice
) {
  TransactionSkeleton txSkel;
  int txNonce;
  std::string contractWallet = "9c19d746472978750778f334b262de532d9a85f9";

  std::string nonceApiRequest = Network::getTxNonce(signKey);
  std::string txNonceStr = get_json_value(nonceApiRequest, "result");
  // Check if nonce is valid (not an error message)
  if (txNonceStr == "") {
    txSkel.nonce = MAX_U256_VALUE();
    return txSkel;
  }
  std::stringstream nonceStrm;
  nonceStrm << std::hex << txNonceStr;
  nonceStrm >> txNonce;

  // Building the transaction structure
  txSkel.creation = false;
  txSkel.to = toAddress(contractWallet);
  txSkel.value = u256(0);
  txSkel.data = fromHex(buildTxData(txValue, destWallet));
  txSkel.nonce = txNonce;
  txSkel.gas = u256(txGas);
  txSkel.gasPrice = u256(txGasPrice);

  return txSkel;
}

// Sign a transaction with user credentials.
std::string WalletManager::signTransaction(
  TransactionSkeleton txSkel, std::string pass, std::string signKey
) {
  Secret s = getSecret(signKey, pass);
  std::stringstream txHexBuffer;

  try {
    TransactionBase t = TransactionBase(txSkel);
    t.setNonce(txSkel.nonce);
    t.sign(s);
    txHexBuffer << toHex(t.rlp());
  } catch (Exception& ex) {
    std::cerr << "Invalid transaction: " << ex.what() << std::endl;
  }

  return txHexBuffer.str();
}

// Send a transaction to the API provider for processing.
std::string WalletManager::sendTransaction(std::string txidHex) {
  std::string txidApiRequest = Network::broadcastTransaction(txidHex);
  std::string txid = get_json_value(txidApiRequest, "result");
  std::string txLink = "https://ropsten.etherscan.io/tx/" + txid;
  return txLink;
}

// Decode a raw transaction and show information about it.
WalletTxData WalletManager::decodeRawTransaction(std::string rawTxHex) {
  TransactionBase transaction = TransactionBase(fromHex(rawTxHex), CheckTransaction::None);
  WalletTxData ret;

  ret.hex = transaction.sha3().hex();
  if (transaction.isCreation()) {
    ret.type = "creation";
    ret.code = toHex(transaction.data());
  } else {
    ret.type = "message";
    ret.to = boost::lexical_cast<std::string>(transaction.to());
    ret.data = (transaction.data().empty() ? "none" : toHex(transaction.data()));
  }
  try {
    auto s = transaction.sender();
    if (transaction.isCreation()) {
      ret.creates = boost::lexical_cast<std::string>(toAddress(s, transaction.nonce()));
    }
    ret.from = boost::lexical_cast<std::string>(s);
  } catch(...) {
    ret.from = "<unsigned>";
  }
  ret.value = formatBalance(transaction.value()) + " (" +
    boost::lexical_cast<std::string>(transaction.value()) + " wei)";
  ret.nonce = boost::lexical_cast<std::string>(transaction.nonce());
  ret.gas = boost::lexical_cast<std::string>(transaction.gas());
  ret.price = formatBalance(transaction.gasPrice()) + " (" +
    boost::lexical_cast<std::string>(transaction.gasPrice()) + " wei)";
  ret.hash = transaction.sha3(WithoutSignature).hex();
  if (transaction.safeSender()) {
    ret.v = boost::lexical_cast<std::string>(transaction.signature().v);
    ret.r = boost::lexical_cast<std::string>(transaction.signature().r);
    ret.s = boost::lexical_cast<std::string>(transaction.signature().s);
  }

  return ret;
}

