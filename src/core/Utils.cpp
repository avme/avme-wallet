// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "Utils.h"

boost::filesystem::path Utils::walletFolderPath;
std::mutex Utils::debugFileLock;
std::mutex Utils::storageThreadLock;
u256 Utils::MAX_U256_VALUE() { return (raiseToPow(2, 256) - 1); }

void Utils::logToDebug(std::string debug) {
  boost::filesystem::path debugFilePath = walletFolderPath / "debug.log";
  debugFileLock.lock();
  // Timestamps (epoch and human-readable) and confirmed
  const auto p1 = std::chrono::system_clock::now();
  auto t = std::time(nullptr);
  auto tm = *std::localtime(&t);
  std::stringstream timestream;
  timestream << std::put_time(&tm, "[%d-%m-%Y %H-%M-%S] ");
  std::string toWrite = timestream.str();
  toWrite += debug;

  std::ofstream debugFile (debugFilePath.c_str(), std::ios::out | std::ios::app);
  debugFile << toWrite << std::endl;
  debugFile.close();

  debugFileLock.unlock();
  return;
}

std::string Utils::randomHexBytes() {
  unsigned char saltBytes[32];
  RAND_bytes(saltBytes, sizeof(saltBytes));
  return toHex(
    dev::sha3(std::string((char*)saltBytes, sizeof(saltBytes)), false)
  ).substr(0,16);
}

TxData Utils::decodeRawTransaction(std::string rawTxHex) {
  TransactionBase transaction = TransactionBase(fromHex(rawTxHex), CheckTransaction::None);
  TxData ret;

  // Creation, message, sender, receiver and data
  ret.hex = transaction.sha3().hex();
  if (transaction.isCreation()) {
    ret.type = "creation";
    ret.code = toHex(transaction.data());
  } else {
    ret.type = "message";
    ret.to = boost::lexical_cast<std::string>(transaction.to());
    ret.data = (transaction.data().empty() ? "" : toHex(transaction.data()));
  }
  try {
    auto s = transaction.sender();
    if (transaction.isCreation()) {
      ret.creates = boost::lexical_cast<std::string>(toAddress(s, transaction.nonce()));
    }
    ret.from = boost::lexical_cast<std::string>(s);
  } catch (...) {
    ret.from = "<unsigned>";
  }

  // Value, nonce, gas limit, gas price, hash and v/r/s signature keys
  ret.value = weiToFixedPoint(boost::lexical_cast<std::string>(transaction.value()), 18) + " AVAX";
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

  // Timestamps (epoch and human-readable) and confirmed
  const auto p1 = std::chrono::system_clock::now();
  auto t = std::time(nullptr);
  auto tm = *std::localtime(&t);
  std::stringstream timestream;
  timestream << std::put_time(&tm, "%d-%m-%Y %H-%M-%S");
  ret.humanDate = timestream.str();
  ret.confirmed = false;
  ret.unixDate = std::chrono::duration_cast<std::chrono::seconds>(p1.time_since_epoch()).count();
  ret.invalid = false;
  return ret;
}

std::string Utils::weiToFixedPoint(std::string amount, size_t digits) {
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

  if (result == "") result = "0";
  return result;
}

std::string Utils::fixedPointToWei(std::string amount, int decimals) {
  std::string digitPadding = "";
  std::string valuestr = "";

  // Check if input is valid
  if (amount.find_first_not_of("0123456789.") != std::string::npos) {
    return "";
  }

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

  if (valuestr == "") valuestr = "0";
  return valuestr;
}

std::string Utils::uintToHex(std::string input) {
  // Padding is 32 bytes
  std::string padding = "0000000000000000000000000000000000000000000000000000000000000000";
  std::stringstream ss;
  std::string valueHex;
  u256 value;

  // Convert value to Hex and lower case all letters
  value = boost::lexical_cast<u256>(input);
  ss << std::hex << value;
  valueHex = ss.str();
  for (auto& c : valueHex) {
    if (std::isupper(c)) {
      c = std::tolower(c);
    }
  }

  // Insert value into padding from right to left
  for (size_t i = (valueHex.size() - 1), x = (padding.size() - 1),
    counter = 0; counter < valueHex.size(); --i, --x, ++counter) {
    padding[x] = valueHex[i];
  }
  return padding;
}

std::string Utils::addressToHex(std::string input) {
  // Padding is 32 bytes
  std::string padding = "0000000000000000000000000000000000000000000000000000000000000000";

  // Get rid of the "0x" before converting and lowercase all letters
  input = (input.substr(0, 2) == "0x") ? input.substr(2) : input;
  for (auto& c : input) {
    if (std::isupper(c)) {
      c = std::tolower(c);
    }
  }

  // Address is already in Hex so we just insert it into padding from right to left
  for (size_t i = (input.size() - 1), x = (padding.size() - 1),
    counter = 0; counter < input.size(); --i, --x, ++counter) {
    padding[x] = input[i];
  }
  return padding;
}

std::string Utils::uintFromHex(std::string hex) {
  std::string ret;
  if (hex.substr(0, 2) == "0x") { hex = hex.substr(2); } // Remove the "0x"
  unsigned int number = boost::lexical_cast<HexTo<unsigned int>>(hex);
  ret = boost::lexical_cast<std::string>(number);
  return ret;
}

std::string Utils::addressFromHex(std::string hex) {
  // Hex is 32 bytes (64 chars), address is 20 bytes (40 chars), so just remove
  // the first 12 bytes (24 chars) of padding after "0x" and return.
  std::string ret = hex;
  ret.erase(2, 24);
  return ret;
}

std::string Utils::stringFromHex(std::string hex) {
  std::string ret, offset, len, hexStr;
  if (hex.substr(0, 2) == "0x") { hex = hex.substr(2); } // Remove the "0x"

  // Split the hex string in several 64-char/32-byte pieces (2 chars = 1 byte)
  for (int i = 0; i < hex.length(); i += 64) {
    // Hex strings always come in this order: offset, length and the actual string
    if (i == 0) {
      offset = hex.substr(i, 64);
    } else if (i == 64) {
      len = hex.substr(i, 64);
    } else {
      hexStr += hex.substr(i, 64);
    }
  }
  // Parse the hex string byte by byte (every two chars)
  uint64_t offsetU256 = boost::lexical_cast<HexTo<uint64_t>>("0x" + offset) * 2;
  uint64_t lengthU256 = boost::lexical_cast<HexTo<uint64_t>>("0x" + len) * 2;
  for (uint64_t i = 0; i < lengthU256; i += 2) {
    unsigned int hexInt = boost::lexical_cast<HexTo<unsigned int>>("0x" + hexStr.substr(i, 2));
    unsigned char hexChar = hexInt;
    ret += hexChar;
  }
  return ret;
}


std::string Utils::bytesToHex(std::string input, bool isUint) {
  std::string ret;
  if (!isUint) {
    ret += uintToHex(boost::lexical_cast<std::string>(input.size()));
  }
  std::stringstream ss;
  for (auto c : input) {
    ss << std::hex << int(c);
  }
  ret += ss.str();
  // Bytes are left padded
  while ((ret.size() % 64) != 0)
    ret += "0";
  
  return ret;
}

int Utils::roundUp(int numToRound, int multiple) {
  if (multiple == 0)
    return numToRound;
  int remainder = abs(numToRound) % multiple;
  if (remainder == 0)
    return numToRound;
  if (numToRound < 0)
    return -(abs(numToRound) - remainder);
  else
    return numToRound + multiple - remainder;
}

#ifdef __MINGW32__
boost::filesystem::path Utils::GetSpecialFolderPath(int nFolder, bool fCreate) {
  WCHAR pszPath[MAX_PATH] = L"";
  if (SHGetSpecialFolderPathW(nullptr, pszPath, nFolder, fCreate)) {
    return boost::filesystem::path(pszPath);
  }
  return boost::filesystem::path("");
}
#endif

boost::filesystem::path Utils::getDefaultDataDir() {
  namespace fs = boost::filesystem;
  #ifdef __MINGW32__
    // Windows: C:\Users\Username\AppData\Roaming\AVME
    return GetSpecialFolderPath(CSIDL_APPDATA) / "AVME";
  #else
    // Unix: ~/.avme
    fs::path pathRet;
    char* pszHome = getenv("HOME");
    if (pszHome == NULL || strlen(pszHome) == 0)
      pathRet = fs::path("/");
    else
      pathRet = fs::path(pszHome);
  #ifdef __APPLE__
    return pathRet / "Library/Application Support/AVME";
  #else
    return pathRet / ".avme";
  #endif
  #endif
}

boost::filesystem::path Utils::getDataDir() {
  boost::filesystem::path dataPath = getDefaultDataDir();
  try {
    if (!boost::filesystem::exists(dataPath))
      boost::filesystem::create_directory(dataPath);
    } catch (...) {}
  return dataPath;
}

std::string Utils::readJSONFile(boost::filesystem::path filePath) {
  json returnData;
  storageThreadLock.lock();

  if (!boost::filesystem::exists(filePath)) {
    json errorData;
    errorData["ERROR"] = "FILE DOES NOT EXIST";
    storageThreadLock.unlock();
    return errorData.dump();
  }
  try {
    std::ifstream jsonFile(filePath.c_str());
    jsonFile >> returnData;
  } catch (std::exception &e) {
    json errorData;
    errorData["ERROR"] = e.what();
    storageThreadLock.unlock();
    return errorData.dump();
  }

  storageThreadLock.unlock();
  return returnData.dump();
}

std::string Utils::writeJSONFile(json obj, boost::filesystem::path filePath) {
  json returnData;
  storageThreadLock.lock();

  try {
    std::ofstream os(filePath.c_str());
    os << std::setw(2) << obj << std::endl;
    os.close();
  } catch (std::exception &e) {
    returnData["ERROR"] = e.what();
    storageThreadLock.unlock();
    return returnData.dump();
  }

  storageThreadLock.unlock();
  return "";
}

std::string Utils::jsonToStr(json& obj) {
  std::string ret;

  if (obj.type() == json::value_t::null) {
    ret = "null";
  } else if (obj.type() == json::value_t::boolean) {
    ret = boost::lexical_cast<std::string>(obj.get<bool>());
  } else if (obj.type() == json::value_t::number_integer) {
    ret = boost::lexical_cast<std::string>(obj.get<int64_t>());
  } else if (obj.type() == json::value_t::number_unsigned) {
    ret = boost::lexical_cast<std::string>(obj.get<uint64_t>());
  } else if (obj.type() == json::value_t::number_float) {
    ret = boost::lexical_cast<std::string>(obj.get<float>());
  } else if (obj.type() == json::value_t::object) {
    throw std::runtime_error("Invalid JSON conversion json::object -> std::string");
  } else if (obj.type() == json::value_t::array) {
    throw std::runtime_error("Invalid JSON conversion json::array -> std::string");
  } else if (obj.type() == json::value_t::string) {
    ret = obj.get<std::string>();
  }
  return ret;
}
