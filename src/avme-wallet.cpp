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
std::vector<std::string> WalletManager::createNewAccount(
  std::string name, std::string pass, std::string hint, bool usesMasterPass
) {
  auto k = makeKey();
  h128 u = this->wallet.import(k.secret(), name, pass, hint);
  std::vector<std::string> ret;

  // In this order: ID, name, address and hint
  ret.push_back(toUUID(u));
  ret.push_back(name);
  ret.push_back(k.address().hex());
  if (usesMasterPass) {
    ret.push_back("Uses master passphrase");
  } else {
    ret.push_back(hint);
  }

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
  std::string requestETH = Network::getETHBalance(account);
  std::string requestTAEX = Network::getTAEXBalance(account);
  json_spirit::mValue jsonETH;
  json_spirit::mValue jsonTAEX;
  std::string amountETH;
  std::string amountTAEX;

  // TODO: maybe turn this into a generic JSON checking function
  auto successETH = json_spirit::read_string(requestETH, jsonETH);
  auto successTAEX = json_spirit::read_string(requestTAEX, jsonTAEX);
  if (successETH && successTAEX) {
    try {
      auto jsonResultETH = get_object_item(jsonETH, "result");
      auto jsonResultTAEX = get_object_item(jsonTAEX, "result");
      amountETH = jsonResultETH.get_str();
      amountTAEX = jsonResultTAEX.get_str();
    } catch (std::exception &e) {
      std::cout << "Error when reading json for \"result\": " << e.what() << std::endl;
      auto jsonResultETH = get_object_item(get_object_item(jsonETH,"error"), "message");
      auto jsonResultTAEX = get_object_item(get_object_item(jsonTAEX,"error"), "message");
      amountETH = jsonResultETH.get_str();
      amountTAEX = jsonResultTAEX.get_str();
      std::cout << "Json message: " << amountETH << std::endl << amountTAEX << std::endl;
      return false;
    }
  } else {
    std::cout << "Error reading json, check json value: " << requestETH << std::endl << requestTAEX << std::endl;
  }

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

// List the wallet's ETH accounts and their amounts.
// TODO: make the data be a proper structure instead of a big string
std::vector<std::string> WalletManager::listETHAccounts() {
  if (this->wallet.store().keys().empty()) { return {}; }

  std::vector<std::string> WalletList;
  std::vector<std::string> AddressList;
  std::vector<std::string> BareList;
  AddressHash got;

  // Separating normal accounts from bare accounts
  for (auto const& u: this->wallet.store().keys()) {
    std::stringstream buffer;
    std::stringstream barebuffer;
    std::stringstream addressbuffer;
    if (Address a = this->wallet.address(u)) {
      got.insert(a);
      buffer << toUUID(u) << " " << a.abridged() << " ";
      buffer << "0x" << a << " ";
      addressbuffer << "0x" << a;
      buffer << this->wallet.accountName(a) << " ";
      WalletList.push_back(buffer.str());
      AddressList.push_back(addressbuffer.str());
    } else {
      barebuffer << "0x" << u << " (Bare)";
      BareList.push_back(barebuffer.str());
    }
  }

  // Querying account balances and joining bare accounts at the end
  for (std::size_t i = 0; i < AddressList.size(); ++i) {
    std::string balanceApiRequest = Network::getETHBalance(AddressList[i]);
    std::string balance;
    json_spirit::mValue balanceJson;
    // TODO: maybe turn this into a generic JSON checking function
    auto success = json_spirit::read_string(balanceApiRequest, balanceJson);
    if (success) {
      try {
        auto jsonResult = get_object_item(balanceJson, "result");
        balance = jsonResult.get_str();
      } catch (std::exception &e) {
        std::cout << "Error when reading json for \"result\": " << e.what() << std::endl;
        auto jsonResult = get_object_item(get_object_item(balanceJson,"error"), "message");
        balance = jsonResult.get_str();
        std::cout << "Json message: " << balance << std::endl;
        return {};
      }
    } else {
      std::cout << "Error reading json, check json value: " << balanceApiRequest << std::endl;
    }
    balance = convertWeiToFixedPoint(balance, 18);
    WalletList[i] += (balance + "\n");
  }
  if (!BareList.empty()) {
    WalletList.insert(WalletList.end(), BareList.begin(), BareList.end());
  }

  return WalletList;
}

/**
 * List the wallet's TAEX accounts and their amounts.
 * ERC-20 tokens need to be loaded in a different way, from their proper
 * contract address, beside their respective wallet address.
 */
// TODO: make the data be a proper structure instead of a big string
std::vector<std::string> WalletManager::listTAEXAccounts() {
  if (this->wallet.store().keys().empty()) { return {}; }

  std::vector<std::string> WalletList;
  std::vector<std::string> AddressList;
  std::vector<std::string> BareList;
  AddressHash got;

  // Separating normal accounts from bare accounts
  for (auto const& u: this->wallet.store().keys()) {
    std::stringstream buffer;
    std::stringstream barebuffer;
    std::stringstream addressbuffer;
    if (Address a = this->wallet.address(u)) {
      got.insert(a);
      buffer << toUUID(u) << " " << a.abridged() << " ";
      buffer << "0x" << a << " ";
      addressbuffer << "0x" << a;
      buffer << this->wallet.accountName(a) << " ";
      WalletList.push_back(buffer.str());
      AddressList.push_back(addressbuffer.str());
    } else {
      barebuffer << "0x" << u << " (Bare)";
      BareList.push_back(barebuffer.str());
    }
  }

  // Querying account balances and joining bare accounts at the end
  for (std::size_t i = 0; i < AddressList.size(); ++i) {
    std::string balanceApiRequest = Network::getTAEXBalance(AddressList[i]);
    std::string balance;
    json_spirit::mValue balanceJson;
    // TODO: maybe put this JSON checking in a function
    auto success = json_spirit::read_string(balanceApiRequest, balanceJson);
    if (success) {
      try {
        auto jsonResult = get_object_item(balanceJson, "result");
        balance = jsonResult.get_str();
      } catch (std::exception &e) {
        std::cout << "Error when reading json for \"result\": " << e.what() << std::endl;
        auto jsonResult = get_object_item(get_object_item(balanceJson,"error"), "message");
        balance = jsonResult.get_str();
        std::cout << "Json message: " << balance << std::endl;
        return {};
      }
    } else {
      std::cout << "Error reading json, check json value: " << balanceApiRequest << std::endl;
    }
    balance = convertWeiToFixedPoint(balance, 4);
    WalletList[i] += (balance + "\n");
  }
  if (!BareList.empty()) {
    WalletList.insert(WalletList.end(), BareList.begin(), BareList.end());
  }

  return WalletList;
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

  // TODO: maybe put this JSON checking in a function
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
  json_spirit::mValue nonceJson;

  // TODO: maybe put this JSON checking in a function
  auto success = json_spirit::read_string(nonceApiRequest, nonceJson);
  if (success) {
    try {
      auto jsonResult = get_object_item(nonceJson, "result");
      std::stringstream nonceStrm;
      nonceStrm << std::hex << jsonResult.get_str();
      nonceStrm >> txNonce;
    } catch (std::exception &e) {
      std::cout << "Error when reading json for \"result\": " << e.what() << std::endl;
      auto jsonResult = get_object_item(get_object_item(nonceJson,"error"), "message");
      std::cout << "Json message: " << jsonResult.get_str() << std::endl;
      txSkel.nonce = MAX_U256_VALUE();
      return txSkel;
    }
  } else {
    std::cout << "Error reading json, check json value: " << nonceApiRequest << std::endl;
  }

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
  json_spirit::mValue nonceJson;

  // TODO: maybe put this JSON checking in a function
  auto success = json_spirit::read_string(nonceApiRequest, nonceJson);
  if (success) {
    try {
      auto jsonResult = get_object_item(nonceJson, "result");
      std::stringstream nonceStrm;
      nonceStrm << std::hex << jsonResult.get_str();
      nonceStrm >> txNonce;
    } catch (std::exception &e) {
      std::cout << "Error when reading json for \"result\": " << e.what() << std::endl;
      auto jsonResult = get_object_item(get_object_item(nonceJson,"error"), "message");
      std::cout << "Json message: " << jsonResult.get_str() << std::endl;
      txSkel.nonce = MAX_U256_VALUE();
      return txSkel;
    }
  } else {
    std::cout << "Error reading json, check json value: " << nonceApiRequest << std::endl;
  }

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
  std::string tmptxid;
  std::string transactionLink = "https://ropsten.etherscan.io/tx/";
  std::string txidApiRequest = Network::broadcastTransaction(txidHex);
  json_spirit::mValue txidJson;

  // TODO: maybe put this JSON checking in a function
  auto success = json_spirit::read_string(txidApiRequest, txidJson);
  if (success) {
    try {
      auto jsonResult = get_object_item(txidJson, "result");
      tmptxid = jsonResult.get_str();
    } catch (std::exception &e) {
      std::cout << "Error when reading json for \"result\": " << e.what() << std::endl;
      auto jsonResult = get_object_item(get_object_item(txidJson,"error"), "message");
      tmptxid = jsonResult.get_str();
      std::cout << "Json message: " << tmptxid << std::endl;
    }
  } else {
    std::cout << "Error reading json, check json value: " << txidApiRequest << std::endl;
  }
  transactionLink += tmptxid;

  return transactionLink;
}

// Decode a raw transaction and show information about it.
// TODO: return a proper structure instead of using couts here
void WalletManager::decodeRawTransaction(std::string rawTxHex) {
  TransactionBase transaction = TransactionBase(fromHex(rawTxHex), CheckTransaction::None);
  std::cout << "Transaction: " << transaction.sha3().hex() << std::endl;
  if (transaction.isCreation())
  {
    std::cout << "type: creation" << std::endl;
    std::cout << "code: " << toHex(transaction.data()) << std::endl;
  } else {
    std::cout << "type: message" << std::endl;
    std::cout << "to: " << transaction.to() << std::endl;
    std::cout << "data: " << (transaction.data().empty() ? "none" : toHex(transaction.data())) << std::endl;
  }
  try {
    auto s = transaction.sender();
    if (transaction.isCreation())
      std::cout << "creates: " << toAddress(s, transaction.nonce()) << std::endl;
    std::cout << "from: " << s << std::endl;
  }
  catch (...)
  {
    std::cout << "from: <unsigned>" << std::endl;
  }
  std::cout << "value: " << formatBalance(transaction.value()) << " (" << transaction.value() << " wei)" << std::endl;
  std::cout << "nonce: " << transaction.nonce() << std::endl;
  std::cout << "gas: " << transaction.gas() << std::endl;
  std::cout << "gas price: " << formatBalance(transaction.gasPrice()) << " (" << transaction.gasPrice() << " wei)" << std::endl;
  std::cout << "signing hash: " << transaction.sha3(WithoutSignature).hex() << std::endl;
  if (transaction.safeSender())
  {
    std::cout << "v: " << (int)transaction.signature().v << std::endl;
    std::cout << "r: " << transaction.signature().r << std::endl;
    std::cout << "s: " << transaction.signature().s << std::endl;
  }
}

