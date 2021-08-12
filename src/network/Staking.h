// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
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
    // Arrays for the supported IDs for ABI functions (classic and YY Compound, respectively).
    static std::map<std::string, std::string> funcs;
    static std::map<std::string, std::string> YYfuncs;

    /**
     * (ABI) Get the total LP supply in the staking contract.
     * Returns the amount in Wei.
     */
    static std::string totalSupply();

    /**
     * (ABI) Get the total reward amount for the duration of the staking contract.
     * Returns the amount in Wei.
     */
    static std::string getRewardForDuration();

    /**
     * (ABI) Get the duration of the staking reward in the staking contract.
     * Returns the duration in seconds.
     */
    static std::string rewardsDuration();

    /**
     * (ABI) Get the LP and reward balances for a given Account.
     * Returns the amounts in Wei.
     */
    static std::string balanceOf(std::string address);
    static std::string earned(std::string address);
	static std::string getCompoundReward();

    /**
     * (TX) Stake/unstake a given amount of LP, respectively.
     * Returns the data hex string.
     */
    static std::string stake(std::string amount);
	static std::string stakeCompound(std::string amount);
    static std::string withdraw(std::string amount);
	static std::string compoundWithdraw(std::string amount);

    /**
     * (TX) Harvest available rewards from the pool.
     * Returns the data hex string.
     */
    static std::string getReward();
	static std::string reinvest();

    /**
     * (TX) Exit the pool (harvest all + unstake all).
     * This would be the equivalent of calling harvest() then unstake()
     * with a max amount.
     * Returns the data hex string.
     */
    static std::string exit();
};

#endif  // STAKING_H
