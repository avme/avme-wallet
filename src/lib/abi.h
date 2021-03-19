#ifndef ABI_H
#define ABI_H

#include <iostream>
#include <string>
#include <vector>

#include <boost/lexical_cast.hpp>

#include <libdevcore/CommonIO.h>

#include "network.h"

/**
 * Collection of ABI/smart contract-related functions
 * (e.g. encoding/decoding/converting hex values for calls and responses).
 * See https://uniswap.org/docs/v2/smart-contracts/router02 and
 * https://github.com/pangolindex/exchange-contracts/blob/main/contracts/pangolin-periphery/PangolinRouter.sol
 * for more info.
 */

using namespace dev;  // u256

class ABI {
  public:
    static std::string routerContract;
    static std::map<std::string, std::string> tokenContracts;
    static std::map<std::string, std::string> pairContracts;
    static std::map<std::string, std::string> ERC20Funcs;
    static std::map<std::string, std::string> pairFuncs;
    static std::map<std::string, std::string> routerFuncs;

    /**
     * Converts input to the correspondent 32-byte hex value (with padding).
     * uintToHex should work with uint<M>, bytes and bool.
     * addressToHex is solely for address.
     * Returns the hex string.
     */
    static std::string uintToHex(std::string input);
    static std::string addressToHex(std::string input);

    /**
     * Parse a given hex string according to the values given.
     * Accepted values are: uint, bool, address.
     * Returns a string vector with the converted values.
     */
    static std::vector<std::string> parseHex(std::string hexStr, std::vector<std::string> types);

    /**
     * Get a coin/token pair's reserves, respectively.
     * Returns a vector with reserves A and B (in Wei), and the UNIX timestamp
     * of the last time the pair was interacted with.
     */
    static std::vector<std::string> getReserves(std::string tokenNameA, std::string tokenNameB);

    /**
     * Calculate locally the maximum output from a given asset.
     * Amount and reserves are always in Wei.
     * Returns the output in Wei, or empty if there's an under/overflow.
     */
    static std::string calcAmountOut(std::string amountIn, std::string reserveIn, std::string reserveOut);
};

#endif // ABI_H

