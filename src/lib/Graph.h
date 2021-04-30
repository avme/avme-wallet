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
    // WAVAX: 0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7
    // USDT: 0xde3a24028580884448a5397872046a019649b084
    // AVME: 0x1ecd47ff4d9598f89721a2866bfeb99505a413ed

    /**
     * Get the CURRENT price in fiat (USD) for 1 AVAX and 1 AVME, respectively.
     * Returns a string with the price in fixed point (e.g. "12.34").
     */
    static std::string getAVAXPriceUSD();
    static std::string getAVMEPriceUSD(std::string AVAXUnitPriceUSD);

    /**
     * Get the HISTORICAL token prices in fiat (USD), from the last X days (starting from today).
     * Data might span more than X days (e.g. skipping days w/ no price action),
     * so "days" is really just the number of registered dates in history.
     * Returns a string/string map vector with the UNIX timestamps and
     * prices in fixed point (e.g. "12.34").
     * TODO: do this for AVAX when Pangolin fixes their priceUSD logic in graph
     */
    static std::vector<std::map<std::string, std::string>> getUSDTPriceHistory(int days);
    static std::vector<std::map<std::string, std::string>> getAVMEPriceHistory(int days);
};

#endif // GRAPH_H

