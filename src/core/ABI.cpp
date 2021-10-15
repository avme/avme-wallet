// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include "ABI.h"

std::string ABI::encodeABI(std::string type, std::vector<std::string> arguments, bool isArray) {
  std::string ret;
  if (isArray) {
    // Add the size of the array to the ABI
    ret += Utils::uintToHex(boost::lexical_cast<std::string>(arguments.size()));
  }
  for (auto argument : arguments) {
    if (type == "uint*") {
      ret += Utils::uintToHex(argument);
    } else if (type == "address") {
      ret += Utils::addressToHex(argument);
    } else if (type == "bytes") {
      ret += Utils::bytesToHex(argument, false);
    } else if (type == "bytes*") {
      ret += Utils::bytesToHex(argument, true);
    } else if (type == "string") { // bytes and strings are encoded in the same way
      ret += Utils::bytesToHex(argument, false);
    } else if (type == "bool") {
      ret += Utils::uintToHex(argument);
    }
  }
  return ret;
}

std::string ABI::encodeABIfromJson(std::string jsonStr) {
  json abiJson;
  std::string ret = "0x";
  std::string arrays;

  try {
    // Read types and arguments from JSON
    abiJson = json::parse(jsonStr);
    json json_arguments = abiJson["args"];
    json json_types = abiJson["types"];
    std::string functionNameABI = dev::toHex(dev::sha3(abiJson["function"].get<std::string>())).substr(0,8);
    ret += functionNameABI;

    // Parse type and arguments read from JSON
    int array_start = 32 * json_arguments.size();
    for (int i = 0; i < json_arguments.size(); ++i) {
      std::vector<std::string> arguments;
      bool isArray = false;
      std::string type = json_types[i].get<std::string>();

      if (json_arguments[i].is_array()) {
        isArray = true;
        // [] needs to be removed from type string.
        boost::replace_all(type, "]", "");
        boost::replace_all(type, "[", "");
        for (auto element : json_arguments[i]) {
          arguments.push_back(Utils::jsonToStr(element));
        }
      } else {
        arguments.push_back(Utils::jsonToStr(json_arguments[i]));
      }

      /**
       * Arrays, strings and bytes need specific treatment,
       * even though they're different from each other.
       * Bytes only need treatment if they're not bytes[].
       */
      if (isArray) {
        ret += Utils::uintToHex(boost::lexical_cast<std::string>(array_start));
        arrays += encodeABI(type, arguments, isArray);
        array_start += (arguments.size() * 32) + 32;
      }
      if (type == "string" || (type == "bytes" && !isArray)){
        ret += Utils::uintToHex(boost::lexical_cast<std::string>(array_start));
        arrays += encodeABI(type, arguments, isArray);
        array_start += Utils::roundUp(boost::lexical_cast<int>(encodeABI(type, arguments, isArray).size()), 32);
      } else if (!isArray) {
        ret += encodeABI(type, arguments, isArray);
      }
    }
  } catch (std::exception &e) {
    //std::cout << e.what() << std::endl;
    Utils::logToDebug(std::string(e.what()));
  }
  ret += arrays;
  return ret;
}
