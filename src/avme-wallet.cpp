// Aleth: Ethereum C++ client, tools and libraries.
// Copyright 2015-2019 Aleth Authors.
// Licensed under the GNU General Public License, Version 3.
/// @file
/// CLI module for key management.
#pragma once

#include "avme-wallet.h"

// Load a wallet.
bool loadWallet(KeyManager wallet, std::string walletPass) {
  return wallet.load(walletPass);
}

/**
 * Load the SecretStore (an object inside KeyManager that contains all secrets
 * for the addresses stored in it).
 */
SecretStore& secretStore(KeyManager wallet) {
  return wallet.store();
}

// Create a new wallet.
KeyManager createNewWallet(path walletPath, path secretsPath, std::string walletPass) {
  dev::eth::KeyManager wallet(walletPath, secretsPath);
  try {
    wallet.create(walletPass);
  } catch (Exception const& _e) {
    std::cerr << "Unable to create wallet" << std::endl << boost::diagnostic_information(_e);
  }
  return wallet;
}

/**
 * Create a new Account in the given wallet and encrypt it.
 * An Account contains an ETH address and other stuff.
 * See https://ethereum.org/en/developers/docs/accounts/ for more info.
 */
std::string createNewAccount(
  KeyManager wallet, std::string name, std::string pass, std::string hint, bool usesMasterPass
) {
  auto k = makeKey();
  h128 u = wallet.import(k.secret(), name, pass, hint);
  std::stringstream ret;

  ret << "Created key " << toUUID(u) << std::endl
      << "  Name: " << name << std::endl
      << "  Address: " << k.address().hex() << std::endl;
  if (usesMasterPass) {
    ret << "  Uses master passphrase" << std::endl;
  } else {
    ret << "  Passphrase hint: " << hint << std::endl;
  }

  return ret.str();
}

/**
 * Hash a given phrase to create a new address based on that phrase.
 * It's easier to hash since hashing creates the 256-bit variable used by
 * the private key.
 */
void createKeyPairFromPhrase(std::string phrase) {
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
bool eraseAccount(KeyManager wallet, std::string account) {
  if (Address a = userToAddress(account, wallet)) {
    wallet.kill(a);
    return true;
  } else {
    return false; // Account was not found
  }
}

// Select the appropriate address stored in KeyManager from user input string.
Address userToAddress(std::string const& input, KeyManager wallet) {
  if (h128 u = fromUUID(input)) { return wallet.address(u); }
  DEV_IGNORE_EXCEPTIONS(return toAddress(input));
  for (Address const& a: wallet.accounts()) {
    if (wallet.accountName(a) == input) { return a; }
  }
  return Address();
}

// Load the secret key for a designed address from the KeyManager wallet.
Secret getSecret(KeyManager wallet, std::string const& signKey, std::string pass) {
  std::string json = contentsString(signKey);
  if (!json.empty()) {
    return Secret(secretStore(wallet).secret(secretStore(wallet).readKeyContent(json), [&](){ return pass; }));
  } else {
    if (h128 u = fromUUID(signKey)) {
      return Secret(secretStore(wallet).secret(u, [&](){ return pass; }));
    }

    Address a;
    try {
      a = toAddress(signKey);
    } catch (...) {
      for (Address const& aa: wallet.accounts()) {
        if (wallet.accountName(aa) == signKey) {
          a = aa;
          break;
        }
      }
    }

    if (a) {
      return wallet.secret(a, [&](){ return pass; });
    } else {
      std::cerr << "Bad file, UUID or address: " << signKey << std::endl;
      exit(-1);
    }
  }
}

// Create a key from a random string of characters. Check FixedHash.h for more info.
KeyPair makeKey() {
  KeyPair k(Secret::random());
  k = KeyPair(Secret(sha3(k.secret().ref())));
  return k;
}

/**
 * Send an HTTP GET Request to the blockchain API provider for everything
 * related to transactions and balances. Currently using Etherscan.
 */
std::string httpGetRequest(std::string httpquery) {
  using boost::asio::ip::tcp;
  std::string server_answer;

  try {
    boost::asio::io_service io_service;
    std::string ipAddress = "api-ropsten.etherscan.io"; // IP address or hostname
    std::string portNum = "80"; // "8000" for instance
    std::string hostAddress;
    // Add ":" only if port number is not 80
    if (portNum.compare("80") != 0) {
      hostAddress = ipAddress + ":" + portNum;
    } else {
      hostAddress = ipAddress;
    }
    //string wordToQuery = "aha";
    //string queryStr = argv[3]; //"/api/v1/similar?word=" + wordToQuery;

    // Get a list of endpoints corresponding to the server name.
    tcp::resolver resolver(io_service);
    tcp::resolver::query query(ipAddress, portNum);
    tcp::resolver::iterator endpoint_iterator = resolver.resolve(query);

    // Try each endpoint until we successfully establish a connection.
    tcp::socket socket(io_service);
    boost::asio::connect(socket, endpoint_iterator);

    /**
     * Form the request. We specify the "Connection: close" header so that the
     * server will close the socket after transmitting the response. This will
     * allow us to treat all data up until the EOF as the content.
     */
    boost::asio::streambuf request;
    std::ostream request_stream(&request);
    request_stream << "GET " << httpquery << " HTTP/1.1\r\n";  // note that you can change it if you wish to HTTP/1.0
    request_stream << "Host: " << hostAddress << "\r\n";
    request_stream << "Accept: */*\r\n";
    request_stream << "Connection: close\r\n\r\n";

    // Send the request.
    boost::asio::write(socket, request);

    /**
     * Read the response status line. The response streambuf will automatically
     * grow to accommodate the entire line. The growth may be limited by passing
     * a maximum size to the streambuf constructor.
     */
    boost::asio::streambuf response;
    boost::asio::read_until(socket, response, "\r\n");

    // Check that response is OK.
    std::istream response_stream(&response);
    std::string http_version;
    response_stream >> http_version;
    unsigned int status_code;
    response_stream >> status_code;
    std::string status_message;
    std::getline(response_stream, status_message);
    if (!response_stream || http_version.substr(0, 5) != "HTTP/") {
      std::cout << "Invalid response\n";
      return "CANNOT GET BALANCE";
    }
    if (status_code != 200) {
      std::cout << "Response returned with status code " << status_code << "\n";
      return "CANNOT GET BALANCE";
    }

    // Read the response headers, which are terminated by a blank line.
    boost::asio::read_until(socket, response, "\r\n\r\n");

    // Process the response headers.
    std::string header;
    while (std::getline(response_stream, header) && header != "\r") {}

    // Write whatever content we already have to output.
    if (response.size() > 0) {
      std::stringstream answer_buffer;
      answer_buffer << &response;
      server_answer = answer_buffer.str();
    }

    // Read until EOF, writing data to output as we go.
    boost::system::error_code error;
    while (boost::asio::read(socket, response,boost::asio::transfer_at_least(1), error)) {
      std::cout << &response;
    }
    if (error != boost::asio::error::eof) {
      throw boost::system::system_error(error);
    }
  } catch (std::exception& e) {
    std::cout << "Exception: " << e.what() << "\n";
  }

  return server_answer;
}

// Parse a JSON string and get the appropriate value from the API provider.
std::vector<std::string> getJSONValue(std::string myJson, std::string myValue) {
  std::vector<std::string> jsonInputs;
  std::vector<std::string> resultValue;
  std::string value;
  bool found = false;

  for (std::size_t i = 0; i < myJson.size(); ++i) {
    if (myJson[i] == ',') {
      jsonInputs.push_back(value);
      value = "";
      continue;
    }
    if (myJson[i] == '}') {
      jsonInputs.push_back(value);
      continue;
    }
    if (myJson[i] == '{') {
      continue;
    }
    value += myJson[i];
  }

  for (std::size_t i = 0; i < jsonInputs.size(); ++i) {
    if (jsonInputs[i].find(myValue) != std::string::npos) {
      found = true;
      resultValue.push_back(jsonInputs[i]);
    }
  }

  if (!found) {
    for (std::size_t i = 0; i < jsonInputs.size(); ++i) {
      if (jsonInputs[i].find("message") != std::string::npos) {
        found = true;
        resultValue.push_back(jsonInputs[i]);
      }
    }
  }

  return resultValue;
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
std::string convertWeiToFixedPoint(std::string amount, size_t digits) {
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
 * back to the original 18-digit Wei amount to create transactions.
 */
std::string convertFixedPointToWei(std::string amount, int digits) {
  double amountValue = 0;

  std::stringstream ssi;
  ssi.precision(digits);
  ssi << std::fixed << amount;
  ssi >> amountValue;

  std::stringstream ss;
  ss.precision(digits);
  ss << std::fixed << amountValue;

  std::string valuestr = ss.str();

  valuestr.erase(std::remove(valuestr.begin(), valuestr.end(), '.'), valuestr.end());
  while (valuestr[0] == '0') {
    valuestr.erase(0,1);
  }

  return valuestr;
}

/**
 * List all the ETH accounts contained in a given wallet.
 * Also asks for the API provider to get the balances from these addresses.
 */
std::vector<std::string> listETHAccounts(KeyManager wallet) {
  if (wallet.store().keys().empty()) { return {}; }

  std::vector<std::string> WalletList;
  std::vector<std::string> AddressList;
  std::vector<std::string> BareList;
  AddressHash got;

  // Separating normal accounts from bare accounts
  for (auto const& u: wallet.store().keys()) {
    std::stringstream buffer;
    std::stringstream barebuffer;
    std::stringstream addressbuffer;
    if (Address a = wallet.address(u)) {
      got.insert(a);
      buffer << toUUID(u) << " " << a.abridged();
      buffer << " " << "0x" << a << " ";
      addressbuffer << "0x" << a;
      buffer << " " << wallet.accountName(a);
      WalletList.push_back(buffer.str());
      AddressList.push_back(addressbuffer.str());
    } else {
      barebuffer << "0x" << u << " (Bare)";
      BareList.push_back(barebuffer.str());
    }
  }

  // Querying account balances and joining bare accounts at the end
  for (std::size_t i = 0; i < AddressList.size(); ++i) {
    WalletList[i] += getETHBalance(AddressList[i]);
    WalletList[i] += "\n";
  }
  if (!BareList.empty()) {
    WalletList.insert(WalletList.end(), BareList.begin(), BareList.end());
  }

  return WalletList;
}

/**
 * Same as above, but for TAEX.
 * Here is where it starts to become tricky. Tokens needs to be loaded
 * differently and from their proper contract address, beside the respective
 * wallet address.
 */
std::vector<std::string> listTAEXAccounts(KeyManager wallet) {
  if (wallet.store().keys().empty()) { return {}; }

  std::vector<std::string> WalletList;
  std::vector<std::string> AddressList;
  std::vector<std::string> BareList;
  AddressHash got;

  // Separating normal accounts from bare accounts
  for (auto const& u: wallet.store().keys()) {
    std::stringstream buffer;
    std::stringstream barebuffer;
    std::stringstream addressbuffer;
    if (Address a = wallet.address(u)) {
      got.insert(a);
      buffer << toUUID(u) << " " << a.abridged();
      buffer << " " << "0x" << a << " ";
      addressbuffer << "0x" << a;
      buffer << " " << wallet.accountName(a);
      WalletList.push_back(buffer.str());
      AddressList.push_back(addressbuffer.str());
    } else {
      barebuffer << "0x" << u << " (Bare)";
      BareList.push_back(barebuffer.str());
    }
  }

  // Querying account balances and joining bare accounts at the end
  for (std::size_t i = 0; i < AddressList.size(); ++i) {
    WalletList[i] += getTAEXBalance(AddressList[i]);
    WalletList[i] += "\n";
  }
  if (!BareList.empty()) {
    WalletList.insert(WalletList.end(), BareList.begin(), BareList.end());
  }

  return WalletList;
}

// Get the ETH balance from an address from the API provider.
std::string getETHBalance(std::string address) {
  std::string balance;

  std::stringstream query;
  query << "/api?module=account&action=balance&address=";
  query << address;
  query << "&tag=latest&apikey=6342MIVP4CD1ZFDN3HEZZG4QB66NGFZ6RZ";

  balance = httpGetRequest(query.str());
  std::vector<std::string> jsonResult = getJSONValue(balance, "result");
  balance = jsonResult[0];
  balance.pop_back();
  balance.erase(0,10);
  balance = convertWeiToFixedPoint(balance, 18);

  return balance;
}

// Same thing as above, but for TAEX.
std::string getTAEXBalance(std::string address) {
  std::string balance;

  std::stringstream query;
  query << "/api?module=account&action=tokenbalance&contractaddress=0x9c19d746472978750778f334b262de532d9a85f9&address=";
  query << address;
  query << "&tag=latest&apikey=6342MIVP4CD1ZFDN3HEZZG4QB66NGFZ6RZ";

  balance = httpGetRequest(query.str());
  std::vector<std::string> jsonResult = getJSONValue(balance, "result");
  balance = jsonResult[0];
  balance.pop_back();
  balance.erase(0,10);
  balance = convertWeiToFixedPoint(balance, 4);

  return balance;
}

// Build a transaction data to send tokens.
std::string buildTXData(std::string txValue, std::string destWallet) {
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
  u256 intValue;
  std::stringstream ss;
  ss << txValue;
  ss >> intValue;
  std::stringstream ssi;
  ssi << std::hex << intValue;
  std::string amountStrHex = ssi.str();

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
TransactionSkeleton buildETHTransaction(
  std::string signKey, std::string destWallet,
  std::string txValue, std::string txGas, std::string txGasPrice
) {
  TransactionSkeleton txSkel;
  int txNonce;
  std::stringstream query;
  query << "/api?module=proxy&action=eth_getTransactionCount&address=";
  query << signKey;
  query << "&tag=latest&apikey=6342MIVP4CD1ZFDN3HEZZG4QB66NGFZ6RZ";

  // Requesting a nonce from the API provider
  std::string nonceRequest = httpGetRequest(query.str());
  std::cout << nonceRequest << std::endl;
  std::vector<std::string> jsonResult = getJSONValue(nonceRequest, "result");
  jsonResult[0].pop_back();
  jsonResult[0].erase(0,10);
  std::stringstream nonceStrm;
  nonceStrm << std::hex << jsonResult[0];
  nonceStrm >> txNonce;
  if (txNonce == 0) {
    ++txNonce;
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
TransactionSkeleton buildTAEXTransaction(
  std::string signKey, std::string destWallet,
  std::string txValue, std::string txGas, std::string txGasPrice
) {
  TransactionSkeleton txSkel;
  int txNonce;
  std::string contractWallet = "9c19d746472978750778f334b262de532d9a85f9";
  std::stringstream query;
  query << "/api?module=proxy&action=eth_getTransactionCount&address=";
  query << signKey;
  query << "&tag=latest&apikey=6342MIVP4CD1ZFDN3HEZZG4QB66NGFZ6RZ";

  // Requesting a nonce from the API provider
  std::string nonceRequest = httpGetRequest(query.str());
  std::vector<std::string> jsonResult = getJSONValue(nonceRequest, "result");
  jsonResult[0].pop_back();
  jsonResult[0].erase(0,10);
  std::stringstream nonceStrm;
  nonceStrm << std::hex << jsonResult[0];
  nonceStrm >> txNonce;
  if (txNonce == 0) {
    ++txNonce;
  }

  // Building the transaction structure
  txSkel.creation = false;
  txSkel.to = toAddress(contractWallet);
  txSkel.value = u256(0);
  txSkel.data = fromHex(buildTXData(txValue, destWallet));
  txSkel.nonce = txNonce;
  txSkel.gas = u256(txGas);
  txSkel.gasPrice = u256(txGasPrice);

  return txSkel;
}

// Sign a transaction with user credentials.
std::string signTransaction(
  KeyManager wallet, std::string pass,
  std::string signKey, TransactionSkeleton txSkel
) {
  Secret s = getSecret(wallet, signKey, pass);
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

// Broadcast a transaction to the API provider.
std::string sendTransaction(std::string txidHex) {
  std::stringstream txidquery;
  txidquery << "/api?module=proxy&action=eth_sendRawTransaction&hex=";
  txidquery << txidHex;
  txidquery << "&apikey=6342MIVP4CD1ZFDN3HEZZG4QB66NGFZ6RZ";

  std::string txid = httpGetRequest(txidquery.str());
  std::vector<std::string> txidJsonResult = getJSONValue(txid, "result");
  std::string transactionLink = "https://ropsten.etherscan.io/tx/";
  std::string tmptxid = txidJsonResult[0];
  tmptxid.pop_back();
  tmptxid.erase(0,10);
  transactionLink += tmptxid;

  return transactionLink;
}

