#include "abi.h"

// TODO: error handling on everything

// TODO: change all addresses to mainnet once deployed

// Pangolin's router contract. See https://github.com/pangolindex/exchange-contracts
std::string ABI::routerContract = "0x2D99ABD9008Dc933ff5c0CD271B88309593aB921";

// Array with the supported token contracts
std::map<std::string, std::string> ABI::tokenContracts = {
  {"WAVAX", "0xd00ae08403B9bbb9124bB305C09058E32C39A48c"},
  {"AVME", "0x3b37F754afC9B3626b7d545dB73F4F4fb2D10890"},
};

// Array with the supported token pair contracts
std::map<std::string, std::string> ABI::pairContracts = {
  {"WAVAX-AVME", "0x27C287Bc2550e271aB763AE08Be54919B1BF88A1"},
};

// Array with the IDs for calling ERC20 ABI functions
std::map<std::string, std::string> ABI::ERC20Funcs = {
  {"approve", "0x095ea7b3"},  // approve(address,uint256)
  {"allowance", "0xdd62ed3e"}, // allowance(address,address)
};

// Array with the IDs for calling token pair ABI functions
std::map<std::string, std::string> ABI::pairFuncs = {
  {"getReserves", "0x0902f1ac"},  // getReserves()
};

// Array with the IDs for calling Pangolin's router contract ABI functions
std::map<std::string, std::string> ABI::routerFuncs = {
  {"addLiquidityAVAX", "0xf91b3f72"},  // addLiquidityAVAX(address,uint256,uint256,uint256,address,uint256)
  {"removeLiquidityAVAX", "0x33c6b725"},  // removeLiquidityAVAX(address,uint256,uint256,uint256,address,uint256)
  {"swapExactAVAXForTokens", "0xee731187"},  // swapExactAVAXForTokens(uint256,address[] calldata,address,uint256)
  {"swapExactTokensForAVAX", "0xb6da5f42"},  // swapExactTokensForAVAX(uint256,uint256,address[] calldata,address,uint256)
};

std::string ABI::uintToHex(std::string input) {
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

std::string ABI::addressToHex(std::string input) {
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

std::vector<std::string> ABI::parseHex(std::string hexStr, std::vector<std::string> types) {
  std::vector<std::string> ret;

  // Get rid of the "0x" before converting and lowercase all letters
  hexStr = (hexStr.substr(0, 2) == "0x") ? hexStr.substr(2) : hexStr;

  // Parse each type and erase it from the hex string until it is empty
  for (std::string type : types) {
    if (type == "uint" || type == "bool") {
      // All uints are 32 bytes and each hex char is half a byte, so 32 bytes = 64 chars.
      u256 value = boost::lexical_cast<HexTo<u256>>(hexStr.substr(0, 64));
      ret.push_back(boost::lexical_cast<std::string>(value));
    } else if (type == "bool") {
      // Bools are treated as uints, so the same logic applies, but returning a proper bool.
      bool value = boost::lexical_cast<HexTo<bool>>(hexStr.substr(0, 64));
      ret.push_back(boost::lexical_cast<std::string>(value));
    } else if (type == "address") {
      // Addresses are always 20 bytes (40 chars) but are treated as uints, so we
      // take all 64 chars, get rid of the first 24 chars and add "0x" at the start
      std::string value = hexStr.substr(0, 64);
      value.erase(0, 24);
      ret.push_back("0x" + value);
    }
    hexStr.erase(0, 64);
  }

  return ret;
}

std::vector<std::string> ABI::getReserves(std::string tokenNameA, std::string tokenNameB) {
  std::string result;
  std::stringstream query;
  std::string pairName = tokenNameA + "-" + tokenNameB;

  // Query and get the result, returning if empty
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\", \"params\": "
        << "[{\"to\": \"" << pairContracts[pairName]
        << "\",\"data\": \"" << pairFuncs["getReserves"]
        << "\"},\"latest\"]}";
  std::string str = Network::httpGetRequest(query.str());
  result = JSON::getValue(str, "result").get_str();
  if (result == "0x") { return {}; }
  result = result.substr(2); // Remove the "0x"

  // Parse the result back into normal values
  return parseHex(result, {"uint", "uint", "uint"});
}

std::string ABI::calcAmountOut(std::string amountIn, std::string reserveIn, std::string reserveOut) {
  u256 amountInU256 = boost::lexical_cast<u256>(amountIn);
  u256 reserveInU256 = boost::lexical_cast<u256>(reserveIn);
  u256 reserveOutU256 = boost::lexical_cast<u256>(reserveOut);

  u256 amountInWithFee = amountInU256 * 997;
  if ((amountInWithFee / 997) != amountInU256) { return ""; }  // Mul overflow

  u256 numerator = amountInWithFee * reserveOutU256;
  if ((numerator / reserveOutU256) != amountInWithFee) { return ""; }  // Mul overflow

  u256 denominator = reserveInU256 * 1000;
  if ((denominator / 1000) != reserveInU256) { return ""; }  // Mul overflow
  if ((denominator + amountInWithFee) < denominator) { return ""; }  // Add overflow
  denominator += amountInWithFee;

  return boost::lexical_cast<std::string>(numerator / denominator);
}

