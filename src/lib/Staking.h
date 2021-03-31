#ifndef STAKING_H
#define STAKING_H

#include <string>

/**
 * Class for staking-related functions (e.g. stake/unstake LP, harvest, etc.).
 */
// TODO: all of the below
class Staking {
  /**
   * Stake/unstake a given amount of LP tokens in the pool, respectively.
   * Returns true on success, false on failure.
   */
  bool stake(std::string account, std::string lpAmount);
  bool unstake(std::string account, std::string lpAmount);

  /**
   * Harvest available farmed tokens in the pool for the given Account.
   * Returns true on sucess, false on failure.
   */
  bool harvest(std::string account);

  /**
   * Exit the LP pool (harvest all + unstake all).
   * This would be the equivalent of calling harvest() then unstake()
   * with a max amount.
   * Returns true on success, false on failure.
   */
  bool exitPool(std::string account);
};

#endif  // STAKING_H
