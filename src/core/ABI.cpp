// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include "ABI.h"


namespace ABI {
  std::string encodeABI(std::string type, std::vector<std::string> arguments, bool isArray) {
    std::string ret;
    // Add the size of the array to the ABI.
    if (isArray)
      ret += Utils::uintToHex(boost::lexical_cast<std::string>(arguments.size()));
    for (auto argument : arguments) {
      if (type == "uint*") {
        ret += Utils::uintToHex(argument);
      }
      if (type == "address") {
        ret += Utils::addressToHex(argument);
      }
      if (type == "bytes") {
        ret += Utils::bytesToHex(argument, false);
      }
      if (type == "bytes*") {
        ret += Utils::bytesToHex(argument, true);
      }
      if (type == "string") {
       // bytes and strings are encoded in the same way.
       ret += Utils::bytesToHex(argument, false);
      }
      if (type == "bool") {
       if (argument == "true") {
          ret += Utils::uintToHex("1");
        } else {
          ret += Utils::uintToHex("0");
        }
      }
    }
    return ret;
  }
  std::string encodeABIfromJson(std::string jsonStr) {
    json abiJson;
    std::string ret;
    std::string arrays;
  
    try {
        abiJson = json::parse(jsonStr);
        // Read types and arguments from JSON.
        json json_arguments = abiJson["args"];
        json json_types = abiJson["types"];
        std::string functionNameABI = dev::toHex(dev::sha3(abiJson["function"].get<std::string>())).substr(0,8);
        ret += functionNameABI;

        int array_start = 32 * json_arguments.size();
        for (int i = 0; i < json_arguments.size(); ++i) {
          std::vector<std::string> arguments;
          bool isArray = false;
          std::string type = json_types[i].get<std::string>();
          // Remove any remainings quote marks
          if (json_arguments[i].is_array()) {
            isArray = true;
            for (auto element : json_arguments[i])
              arguments.push_back(element.get<std::string>());
          } else {
            arguments.push_back(json_arguments[i].get<std::string>());
          }
          
          // Arrays need proper treatment.
          if (isArray) {
            ret += Utils::uintToHex(boost::lexical_cast<std::string>(array_start));
            arrays += encodeABI(type, arguments, isArray);
            array_start += (arguments.size() * 32) + 32;
          } 
          
          if (type == "string" || type == "bytes" && !isArray){
            // Also string and bytes, they are different from arrays, but also needs different treatment
            // Bytes only need treatment if they are not a bytes[]
            ret += Utils::uintToHex(boost::lexical_cast<std::string>(array_start));
            arrays += encodeABI(type, arguments, isArray);
            array_start += Utils::roundUp(boost::lexical_cast<int>(encodeABI(type, arguments, isArray).size()), 32);
          } else if (!isArray) {
            ret += encodeABI(type, arguments, isArray);
          }
        }
    } catch (std::exception &e) {
      std::cout << e.what() << std::endl;
      Utils::logToDebug(std::string(e.what()));
    }
    ret += arrays;
    return ret;
  }
}