// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef PARASWAP_H
#define PARASWAP_H

#include <iostream>
#include <string>
#include <vector>

#include <boost/lexical_cast.hpp>

#include <network/API.h>
#include <core/Utils.h>

namespace ParaSwap {

  std::string getTokenPrices(std::string srcToken, 
                             std::string srcDecimal, 
                             std::string destToken,
                             std::string destDecimals,
                             std::string weiAmount,
                             std::string side,
                             std::string chainID = "43114");

  std::string getTransactionData(std::string priceRouteStr, 
                                 std::string slippage, 
                                 std::string userAddress, 
                                 std::string fee);

}


#endif  // PARASWAP_H