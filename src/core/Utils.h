// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef UTILS_H
#define UTILS_H

#include <chrono>
#include <string>

#include <boost/chrono.hpp>
#include <boost/filesystem.hpp>
#include <boost/lexical_cast.hpp>
#include <qrencode.h>

#include <openssl/rand.h>

#include <lib/devcore/CommonIO.h>
#include <lib/devcore/FileSystem.h>
#include <lib/devcore/SHA3.h>
#include <lib/ethcore/KeyManager.h>
#include <lib/ethcore/TransactionBase.h>
#include <lib/nlohmann_json/json.hpp>
#include <stdexcept>

using namespace dev;  // u256
using namespace dev::eth; // TransactionBase
using namespace nlohmann; // json

/**
 * Conversion template for usage with boost::lexical_cast.
 * e.g. boost::lexical_cast<HexRounds number to nearest multiple To<int>>(var);
 */
template <typename ElemT>
struct HexTo {
  ElemT value;
  operator ElemT() const { return value; }
  friend std::istream& operator>>(std::istream& in, HexTo& out) {
    in >> std::hex >> out.value;
    return in;
  }
};

// Struct for a single ARC20 Token.
typedef struct ARC20Token {
  // Those are stored in JSON
  std::string address;
  std::string symbol;
  std::string name;
  int decimals;
  std::string avaxPairContract;
  // Those are NOT stored ithe respective byte arrayn JSON
  bigfloat reserve;
  bigfloat avaxReserve;
} ARC20Token;

// Struct for a single Transaction.
typedef struct TxData {
  std::string txlink;
  std::string operation;
  std::string hex;
  std::string type;
  std::string code;
  std::string to;
  std::string from;
  std::string data;
  std::string creates;
  std::string value;
  std::string nonce;
  std::string gas;
  std::string price;
  std::string hash;
  std::string v;
  std::string r;
  std::string s;
  std::string humanDate;
  uint64_t unixDate;
  bool confirmed;
  bool invalid;
} TxData;

/**
 * Namespace for general utility functions.
 */
namespace Utils {
  extern boost::filesystem::path walletFolderPath; // Top folder where the Wallet is.
  extern std::mutex debugFileLock;  // Mutex for the debug log file.
  extern std::mutex storageThreadLock;  // Mutex for the JSON read/write threads.
  u256 MAX_U256_VALUE();  // Maximum 256-bit unsigned int value (for error handling).

  /**
   * Write information to the debug log file.
   */
  void logToDebug(std::string debug);

  /**
   * Generate a random 16-byte Hex to be used as a tag/ID.
   * the respective byte array
   */
  std::string randomHexBytes();

  /**
   * Decode a raw transaction in Hex.
   * Returns a struct with the transaction's data.
   */
  TxData decodeRawTransaction(std::string rawTxHex);

  /**
   * Convert a full Wei amount to a fixed point amount and vice-versa,
   * in the given amount of digits/decimals.
   * BTC has 8 decimals but is considered a full integer in code, so 1.0 BTC
   * actually means 100000000 satoshis.
   * Likewise with ETH, AVAX, etc., which have 18 digits, so 1.0 ETH/AVAX
   * actually means 1000000000000000000 Wei.
   * This also applies to their respective tokens.
   * Operations are actually done with full amounts, but to make those
   * operations more human-friendly, we show to and collect from the user
   * fixed point values, then convert those to full amounts and back.
   * Returns the fixed point and full amounts, respectively.
   */
  std::string weiToFixedPoint(std::string amount, size_t digits);
  std::string fixedPointToWei(std::string amount, int decimals);

  /**
   * Converts input to the correspondent 32-byte hex value (with padding).
   * uintToHex should work with uint<M>, bytes and bool.
   * addressToHex is solely for address.
   * Returns the hex string.
   * bytesToHex converts a string of characters to a byte array
   * returns the respective byte array with left-padding
   */
  std::string uintToHex(std::string input);
  std::string addressToHex(std::string input);
  std::string bytesToHex(std::string input, bool isUint);

  /**
   * Converts hex input to the correspondent value.
   * Returns the converted value.
   */
  std::string uintFromHex(std::string hex);
  std::string addressFromHex(std::string hex);
  std::string stringFromHex(std::string hex);

  /**
   * Rounds a number to the nearest multiple.
   */
  int roundUp(int numToRound, int multiple);

  /**
   * Handle the transaction history storage directory.
   * Default data dir paths are as follows:
   *   Windows: C:\Users\Username\AppData\Roaming\AVME
   *   Unix: ~/.avme
   */
  #ifdef __MINGW32__
  boost::filesystem::path GetSpecialFolderPath(int nFolder, bool fCreate = true);
  #endif
  boost::filesystem::path getDefaultDataDir();
  boost::filesystem::path getDataDir();

  /**
   * Read from/write to a JSON file, respectively.
   * Read returns the stringified JSON with the file's contents on success,
   * or a stringified JSON with an error message on failure.
   * Write returns an empty string on success, or a stringified JSON with
   * an error message on failure.
   */
  std::string readJSONFile(boost::filesystem::path filePath);
  std::string writeJSONFile(json obj, boost::filesystem::path filePath);

  /**
   * Properly convert any json type when using json::get() to std::string
   * *not* to be confused with json::dump()
   */ 
  std::string jsonToStr(json& obj);

};

#endif  // UTILS_H
