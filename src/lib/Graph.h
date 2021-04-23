// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef GRAPH_H
#define GRAPH_H

#include <cstdlib>
#include <iostream>
#include <string>

#include <boost/asio.hpp>
#include <boost/asio/ssl.hpp>
#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/beast/version.hpp>

#include "JSON.h"
#include "Utils.h"
#include "root_certificates.hpp"

/**
 * Class for Pangolin's Graph-related functions (e.g. market data, fiat balances, etc.).
 * Only usable with mainnet. See https://uniswap.org/docs/v2/API/queries for more info.
 */
class Graph {
  private:
    // Strings for the API's host, port and target endpoint, respectively.
    static std::string host;
    static std::string port;
    static std::string target;

  public:
    /**
     * Send an HTTP GET Request to the blockchain API.
     * Returns the requested pure JSON data, or an empty string at connection failure.
     * All other functions have to call this one and treat the data that returns from it.
     */
    static std::string httpGetRequest(std::string reqBody);

    // TODO: move hardcoded addresses to Pangolin.cpp when changing to mainnet
    // Those are all mainnet addresses:
    // WAVAX-USDT Pair: 0x9ee0a4e21bd333a6bb2ab298194320b8daa26516
    // AVME: 0x1ecd47ff4d9598f89721a2866bfeb99505a413ed
    static std::string getAVAXPriceUSD();
    static std::string getAVMEPriceUSD(std::string AVAXUnitPriceUSD);
};

#endif // GRAPH_H

