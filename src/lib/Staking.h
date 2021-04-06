#ifndef STAKING_H
#define STAKING_H

#include "Pangolin.h"

/**
 * Class for staking-related functions (e.g. stake/unstake LP, harvest, etc.).
 * Functions will have the following labels commented:
 * - LOCAL: the function does stuff locally, no ABI/transaction calls
 * - ABI: the function calls the ABI via an eth_call query in an HTTP GET request
 * - TX: the function builds a data hex for use in buildTransaction()
 * See https://uniswap.org/docs/v2/smart-contracts/router02 and
 * https://github.com/pangolindex/exchange-contracts/blob/main/contracts/pangolin-periphery/PangolinRouter.sol
 * for more info.
 */
class Staking {
  public:
    // Array for the supported IDs for ABI functions.
    static std::map<std::string, std::string> funcs;

    /**
     * (ABI) Check the LP and reward balances for a given Account.
     * Returns the amounts in Wei.
     */
    static std::string balanceOf(std::string address);
    static std::string earned(std::string address);

    /**
     * (TX) Stake/unstake a given amount of LP, respectively.
     * Returns the data hex string.
     */
    static std::string stake(std::string amount);
    static std::string withdraw(std::string amount);

    /**
     * (TX) Harvest available rewards from the pool.
     * Returns the data hex string.
     */
    static std::string getReward();

    /**
     * (TX) Exit the pool (harvest all + unstake all).
     * This would be the equivalent of calling harvest() then unstake()
     * with a max amount.
     * Returns the data hex string.
     */
    static std::string exit();
};

#endif  // STAKING_H
