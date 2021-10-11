// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef PANGOLIN_H
#define PANGOLIN_H

#include <iostream>
#include <string>
#include <vector>

#include <boost/lexical_cast.hpp>

#include <lib/devcore/CommonIO.h>

#include <network/API.h>
#include <core/Utils.h>

/**
 * Class for ABI/smart contract-related functions on Pangolin (e.g. liquidity, exchanging, etc.).
 * Functions will have the following labels commented:
 * - LOCAL: the function does stuff locally, no ABI/transaction calls
 * - ABI: the function calls the ABI via an eth_call query in an HTTP GET request
 * - TX: the function builds a data hex for use in buildTransaction()
 * See https://uniswap.org/docs/v2/smart-contracts/router02 and
 * https://github.com/pangolindex/exchange-contracts/blob/main/contracts/pangolin-periphery/PangolinRouter.sol
 * for more info.
 */
class Pangolin {
  public:
    // Map with hardcoded Pangolin and token contracts.
    // See https://github.com/pangolindex/exchange-contracts
    static std::map<std::string, std::string> contracts;

    // Maps for the supported ABI function IDs.
    static std::map<std::string, std::string> ERC20Funcs;
    static std::map<std::string, std::string> factoryFuncs;
    static std::map<std::string, std::string> pairFuncs;
    static std::map<std::string, std::string> routerFuncs;

    /**
     * (LOCAL) Parse a given hex string according to the values given.
     * Accepted values are: uint, bool, address.
     * Returns a string vector with the converted values.
     */
    static std::vector<std::string> parseHex(std::string hexStr, std::vector<std::string> types);

    /**
     * (LOCAL) Calculate the first (lower) address from a given token pair.
     * Returns the first (lower) token address.
     */
    static std::string getFirstFromPair(std::string tokenAddressA, std::string tokenAddressB);

    /**
     * (LOCAL) Calculate the maximum output for exchange and liquidity screens, respectively.
     * Amount and reserves are always in Wei.
     * Returns the output in Wei, or empty if there's an under/overflow.
     */
    static std::string calcExchangeAmountOut(
      std::string amountIn, std::string reserveIn, std::string reserveOut
    );
    static std::string calcLiquidityAmountOut(
      std::string amountIn, std::string reserveIn, std::string reserveOut
    );
};

#endif  // PANGOLIN_H
