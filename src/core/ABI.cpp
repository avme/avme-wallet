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
    json_spirit::mValue json;
    std::string ret;
    std::string arrays;
  
    try {
      if(json_spirit::read_string(jsonStr, json)) {
        // Read types and arguments from JSON.
        json_spirit::mValue json_arguments = JSON::objectItem(json, "args");
        json_spirit::mValue json_types = JSON::objectItem(json, "types");
        std::string functionNameABI = dev::toHex(dev::sha3(JSON::objectItem(json, "function").get_str(), false)).substr(0,8);
        ret += functionNameABI;

        int array_start = 32 * json_arguments.get_array().size();
        for (int i = 0; i < json_arguments.get_array().size(); ++i) {
          std::vector<std::string> arguments;
          bool isArray = false;
          std::string type = json_spirit::write_string(JSON::arrayItem(json_types, i), false);
          std::string argument = json_spirit::write_string(JSON::arrayItem(json_arguments, i), false);
          // Remove any remainings quote marks
          boost::replace_all(type, "\"", "");
          boost::replace_all(argument, "\"", "");
          if (type.find("[]") != std::string::npos) {
            isArray = true;
            // Remove any [] from the type string
            boost::replace_all(type, "[", "");
            boost::replace_all(type, "]", "");
            // Remove any [] from the argument string
            boost::replace_all(argument, "]", "");
            boost::replace_all(argument, "[", "");
            boost::split(arguments, argument, boost::is_any_of(","));
          } else {
            arguments.push_back(argument);
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
      }
    } catch (std::exception &e) {
      Utils::logToDebug(std::string(e.what()));
    }
    ret += arrays;
    return ret;
  }
}