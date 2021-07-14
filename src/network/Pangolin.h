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
     * (ABI) Get the address for a given Token-Token or AVAX-Token pair, respectively.
     * Returns the address, or an empty string if no pair is found.
     */
    static std::string getPair(std::string tokenAddressA, std::string tokenAddressB);
    static std::string getAVAXPair(std::string tokenAddress);

    /**
     * (LOCAL) Calculate the first (lower) address from a given token pair.
     * Returns the first (lower) token address.
     */
    static std::string getFirstFromPair(std::string tokenAddressA, std::string tokenAddressB);

    /**
     * (ABI) Get the total supply of liquidity tokens in a coin/token pair.
     * Returns the total supply in Wei.
     */
    static std::string totalSupply(std::string tokenNameA, std::string tokenNameB);

    /**
     * (ABI) Get a coin/token pair's reserves, respectively.
     * Returns a vector with reserves A and B (in Wei), and the UNIX timestamp
     * of the last time the pair was interacted with.
     */
    static std::vector<std::string> getReserves(std::string tokenNameA, std::string tokenNameB);

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

    /**
     * (TX) Give MAX_U256_VALUE spending approval to the spender Account.
     * Returns the data hex string.
     */
    static std::string approve(std::string spender);

    /**
     * (ABI) Check the allowance between owner and spender Accounts.
     * Returns the amount in Wei allowed for spending.
     */
    static std::string allowance(std::string receiver, std::string owner, std::string spender);

    /**
     * (TX) Transfer a token amount directly to the given Account.
     * Returns the data hex string.
     */
    static std::string transfer(std::string to, std::string value);

    /**
     * (TX) Add liquidity to an AVAX<->ERC20 pool.
     * Amounts are always in Wei, deadline is a UNIX timestamp after which the
     * operation will be reverted.
     * Returns the data hex string.
     */
    static std::string addLiquidityAVAX(
      std::string tokenAddress, std::string amountTokenDesired,
      std::string amountTokenMin, std::string amountAVAXMin,
      std::string to, std::string deadline
    );

    /**
     * (TX) Remove liquidity from an AVAX<->ERC20 pool.
     * Amounts are always in Wei, deadline is a UNIX timestamp after which the
     * operation will be reverted.
     * Returns the data hex string.
     */
    static std::string removeLiquidityAVAX(
      std::string tokenAddress, std::string liquidity,
      std::string amountTokenMin, std::string amountAVAXMin,
      std::string to, std::string deadline
    );

    /**
     * (TX) Swap an exact AVAX amount for as many ERC20 tokens as possible.
     * Amounts are always in Wei, deadline is a UNIX timestamp after which the
     * operation will be reverted.
     * Returns the data hex string.
     */
    static std::string swapExactAVAXForTokens(
      std::string amountOutMin, std::vector<std::string> path,
      std::string to, std::string deadline
    );

    /**
     * (TX) Swap an exact ERC20 token amount for as many AVAX as possible.
     * Amounts are always in Wei, deadline is a UNIX timestamp after which the
     * operation will be reverted.
     * Returns the data hex string.
     */
    static std::string swapExactTokensForAVAX(
      std::string amountIn, std::string amountOutMin, std::vector<std::string> path,
      std::string to, std::string deadline
    );
};

#endif  // PANGOLIN_H
