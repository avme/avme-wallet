// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "Pangolin.h"

// TODO: change all addresses to mainnet once deployed

std::string Pangolin::routerContract = "0x2D99ABD9008Dc933ff5c0CD271B88309593aB921";
std::string Pangolin::stakingContract = "0xF051b6ADa0bF873a52eDBDC92c1245fdC4D3C8f8";

std::map<std::string, std::string> Pangolin::tokenContracts = {
  {"WAVAX", "0xd00ae08403B9bbb9124bB305C09058E32C39A48c"},
  {"AVME", "0x522AAA2408dC68142428983BD66e6BAe5406eF65"},
};

std::map<std::string, std::string> Pangolin::pairContracts = {
  {"WAVAX-AVME", "0x5e81035fd278c5491AADC786BaBD0464d4707b10"},
};

std::map<std::string, std::string> Pangolin::ERC20Funcs = {
  {"balanceOf", "0x70a08231"},  // balanceOf(address)
  {"approve", "0x095ea7b3"},  // approve(address,uint256)
  {"allowance", "0xdd62ed3e"}, // allowance(address,address)
  {"transfer", "0xa9059cbb"}, // transfer(address,uint256)
};

std::map<std::string, std::string> Pangolin::pairFuncs = {
  {"totalSupply", "0x18160ddd"}, // totalSupply()
  {"getReserves", "0x0902f1ac"},  // getReserves()
};

std::map<std::string, std::string> Pangolin::routerFuncs = {
  {"addLiquidityAVAX", "0xf91b3f72"},  // addLiquidityAVAX(address,uint256,uint256,uint256,address,uint256)
  {"removeLiquidityAVAX", "0x33c6b725"},  // removeLiquidityAVAX(address,uint256,uint256,uint256,address,uint256)
  {"swapExactAVAXForTokens", "0xa2a1623d"},  // swapExactAVAXForTokens(uint256,address[],address,uint256)
  {"swapExactTokensForAVAX", "0x676528d1"},  // swapExactTokensForAVAX(uint256,uint256,address[],address,uint256)
};

std::vector<std::string> Pangolin::parseHex(std::string hexStr, std::vector<std::string> types) {
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

std::string Pangolin::getPair(std::string tokenNameA, std::string tokenNameB) {
  std::string pairName;
  if (tokenNameA == "AVAX") { tokenNameA = "WAVAX"; }
  if (tokenNameB == "AVAX") { tokenNameB = "WAVAX"; }
  if (pairContracts.find(tokenNameA + "-" + tokenNameB) != pairContracts.end()) {
    pairName = tokenNameA + "-" + tokenNameB;
  } else if (pairContracts.find(tokenNameB + "-" + tokenNameA) != pairContracts.end()) {
    pairName = tokenNameB + "-" + tokenNameA;
  } else {
    pairName = "";  // Not found
  }
  return (!pairName.empty()) ? pairContracts[pairName] : "";
}

std::string Pangolin::getFirstFromPair(std::string tokenNameA, std::string tokenNameB) {
  if (tokenNameA == "AVAX") { tokenNameA = "WAVAX"; }
  if (tokenNameB == "AVAX") { tokenNameB = "WAVAX"; }
  std::string addressA = Pangolin::tokenContracts[tokenNameA];
  std::string addressB = Pangolin::tokenContracts[tokenNameB];
  u256 valueA = boost::lexical_cast<HexTo<u256>>(addressA);
  u256 valueB = boost::lexical_cast<HexTo<u256>>(addressB);
  return (valueA < valueB) ? tokenNameA : tokenNameB;
}

std::string Pangolin::totalSupply(std::string tokenNameA, std::string tokenNameB) {
  std::string result;
  std::stringstream query;

  // Query and get the result, returning if empty
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\", \"params\": "
        << "[{\"to\": \"" << Pangolin::getPair(tokenNameA, tokenNameB)
        << "\",\"data\": \"" << pairFuncs["totalSupply"]
        << "\"},\"latest\"]}";
  std::string str = API::httpGetRequest(query.str());
  result = JSON::getString(str, "result");
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"

  // Parse the result back into normal values
  return parseHex(result, {"uint"})[0];
}

std::vector<std::string> Pangolin::getReserves(std::string tokenNameA, std::string tokenNameB) {
  std::string result;
  std::stringstream query;

  // Query and get the result, returning if empty
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\", \"params\": "
        << "[{\"to\": \"" << Pangolin::getPair(tokenNameA, tokenNameB)
        << "\",\"data\": \"" << pairFuncs["getReserves"]
        << "\"},\"latest\"]}";
  std::string str = API::httpGetRequest(query.str());
  result = JSON::getString(str, "result");
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"

  // Parse the result back into normal values
  return parseHex(result, {"uint", "uint", "uint"});
}

std::string Pangolin::calcExchangeAmountOut(
  std::string amountIn, std::string reserveIn, std::string reserveOut
) {
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

std::string Pangolin::calcLiquidityAmountOut(
  std::string amountIn, std::string reserveIn, std::string reserveOut
) {
  u256 amountInU256 = boost::lexical_cast<u256>(amountIn);
  u256 reserveInU256 = boost::lexical_cast<u256>(reserveIn);
  u256 reserveOutU256 = boost::lexical_cast<u256>(reserveOut);

  u256 numerator = amountInU256 * 1000 * reserveOutU256;
  if ((numerator / reserveOutU256 / 1000) != amountInU256) { return ""; }  // Mul overflow

  u256 denominator = reserveInU256 * 1000;
  if ((denominator / 1000) != reserveInU256) { return ""; }  // Mul overflow

  return boost::lexical_cast<std::string>(numerator / denominator);
}

std::string Pangolin::approve(std::string spender) {
  std::string dataHex = Pangolin::ERC20Funcs["approve"] + Utils::addressToHex(spender)
    + Utils::uintToHex(boost::lexical_cast<std::string>(Utils::MAX_U256_VALUE()));
  return dataHex;
}

std::string Pangolin::allowance(
  std::string receiver, std::string owner, std::string spender
) {
  std::string result;
  std::stringstream query;

  // Query and get the result, returning if empty
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\", \"params\": "
        << "[{\"to\": \"" << receiver
        << "\",\"data\": \"" << Pangolin::ERC20Funcs["allowance"]
                             << Utils::addressToHex(owner)
                             << Utils::addressToHex(spender)
        << "\"},\"latest\"]}";
  std::string str = API::httpGetRequest(query.str());
  result = JSON::getString(str, "result");
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"

  // Parse the result back into normal values
  u256 resultValue = boost::lexical_cast<u256>(Pangolin::parseHex(result, {"uint"})[0]);
  std::string resultStr = boost::lexical_cast<std::string>(resultValue);
  return resultStr;
}

std::string Pangolin::transfer(std::string to, std::string value) {
  std::string dataHex = Pangolin::ERC20Funcs["transfer"]
    + Utils::addressToHex(to) + Utils::uintToHex(value);
  return dataHex;
}

std::string Pangolin::addLiquidityAVAX(
  std::string tokenAddress, std::string amountTokenDesired,
  std::string amountTokenMin, std::string amountAVAXMin,
  std::string to, std::string deadline
) {
  std::string dataHex = Pangolin::routerFuncs["addLiquidityAVAX"]
    + Utils::addressToHex(tokenAddress) + Utils::uintToHex(amountTokenDesired)
    + Utils::uintToHex(amountTokenMin) + Utils::uintToHex(amountAVAXMin)
    + Utils::addressToHex(to) + Utils::uintToHex(deadline);
  return dataHex;
}

std::string Pangolin::removeLiquidityAVAX(
  std::string tokenAddress, std::string liquidity,
  std::string amountTokenMin, std::string amountAVAXMin,
  std::string to, std::string deadline
) {
  std::string dataHex = Pangolin::routerFuncs["removeLiquidityAVAX"]
    + Utils::addressToHex(tokenAddress) + Utils::uintToHex(liquidity)
    + Utils::uintToHex(amountTokenMin) + Utils::uintToHex(amountAVAXMin)
    + Utils::addressToHex(to) + Utils::uintToHex(deadline);
  return dataHex;
}

std::string Pangolin::swapExactAVAXForTokens(
  std::string amountOutMin, std::vector<std::string> path,
  std::string to, std::string deadline
) {
  std::string pathStr = "";
  int pathCt = 0;
  for (std::string p : path) {
    pathStr += Utils::addressToHex(p);
    pathCt++;
  }
  std::string dataHex = Pangolin::routerFuncs["swapExactAVAXForTokens"]
    + Utils::uintToHex(amountOutMin) + Utils::uintToHex("128")
    + Utils::addressToHex(to) + Utils::uintToHex(deadline)
    + Utils::uintToHex(boost::lexical_cast<std::string>(pathCt)) + pathStr;
  return dataHex;
}

std::string Pangolin::swapExactTokensForAVAX(
  std::string amountIn, std::string amountOutMin, std::vector<std::string> path,
  std::string to, std::string deadline
) {
  std::string pathStr = "";
  int pathCt = 0;
  for (std::string p : path) {
    pathStr += Utils::addressToHex(p);
    pathCt++;
  }
  std::string dataHex = Pangolin::routerFuncs["swapExactTokensForAVAX"]
    + Utils::uintToHex(amountIn) + Utils::uintToHex(amountOutMin)
    + Utils::uintToHex("160") + Utils::addressToHex(to) + Utils::uintToHex(deadline)
    + Utils::uintToHex(boost::lexical_cast<std::string>(pathCt)) + pathStr;
  return dataHex;
}

