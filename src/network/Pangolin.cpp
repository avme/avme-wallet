// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "Pangolin.h"

std::map<std::string, std::string> Pangolin::contracts = {
  {"factory", "0xefa94DE7a4656D787667C749f7E1223D71E9FD88"},
  {"router", "0xE54Ca86531e17Ef3616d22Ca28b0D458b6C89106"},
  {"staking", "0xCc39b8c253f33BEa6E8326f0E5029Aa8627df757"},
  {"compound", "0xb34fE8A87DFEbD5Ab0a03DB73F2d49b903E63DB6"},
  {"AVAX", "0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7"},
  {"AVME", "0x1ECd47FF4d9598f89721A2866BFEb99505a413Ed"},
  {"AVAX-AVME", "0x381cc7bcba0afd3aeb0eaec3cb05d7796ddfd860"},
};

std::map<std::string, std::string> Pangolin::ERC20Funcs = {
  {"name", "0x06fdde03"}, // name()
  {"symbol", "0x95d89b41"}, // symbol()
  {"decimals", "0x313ce567"}, // decimals()
  {"totalSupply", "0x18160ddd"}, // totalSupply()
  {"balanceOf", "0x70a08231"},  // balanceOf(address)
  {"approve", "0x095ea7b3"},  // approve(address,uint256)
  {"allowance", "0xdd62ed3e"}, // allowance(address,address)
  {"transfer", "0xa9059cbb"}, // transfer(address,uint256)
};

std::map<std::string, std::string> Pangolin::factoryFuncs = {
  {"getPair", "0xe6a43905"}, // getPair(address,address)
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

  try {

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

  } catch (std::exception &e) {
    Utils::logToDebug(std::string("parseHex error: ") + e.what() + " value: " + hexStr);
  }

  return ret;
}

std::string Pangolin::getFirstFromPair(std::string tokenAddressA, std::string tokenAddressB) {
  u256 valueA = boost::lexical_cast<HexTo<u256>>(tokenAddressA);
  u256 valueB = boost::lexical_cast<HexTo<u256>>(tokenAddressB);
  return (valueA < valueB) ? tokenAddressA : tokenAddressB;
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
