#include "Utils.h"

boost::filesystem::path Utils::walletFolderPath;

u256 Utils::MAX_U256_VALUE() {
  return (raiseToPow(2, 256) - 1);
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

  // Timestamps (epoch and human-readable) and confirmed
  const auto p1 = std::chrono::system_clock::now();
  auto t = std::time(nullptr);
  auto tm = *std::localtime(&t);
  std::stringstream timestream;
  timestream << std::put_time(&tm, "%d-%m-%Y %H-%M-%S");
  ret.humanDate = timestream.str();
  ret.confirmed = false;
  ret.unixDate = std::chrono::duration_cast<std::chrono::seconds>(p1.time_since_epoch()).count();
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
  std::string padding = "0000000000000000000000000000000000000000000000000000000000000000"; // 32 bytes
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
  std::string padding = "0000000000000000000000000000000000000000000000000000000000000000"; // 32 bytes

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

