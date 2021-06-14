// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef API_H
#define API_H

#include <cstdlib>
#include <iostream>
#include <string>

#include <boost/asio.hpp>
#include <boost/asio/ssl.hpp>
#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/beast/version.hpp>

#include "JSON.h"
#include "root_certificates.hpp"

// Class for API/ethcall-related functions (e.g. requesting data from the blockchain API).
class API {
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

    /**
     * Get coin/token balances from a given address in the blockchain API.
     * For a list of addresses, make one call per address in the list.
     * Returns balances in Hex, which have to be converted later, or empty strings on failure.
     * TODO: maybe rename to getCoinBalance / getTokenBalance?
     */
    static std::string getAVAXBalance(std::string address);
    static std::string getAVMEBalance(std::string address, std::string contractAddress);


    /** 
	 * Get Locked LP Balance inside YY Contract
	 */
	static std::string getCompoundLPBalance(std::string address, std::string contractAddress);
	
    /**
     * Get the recommended gas price for a transaction.
     * Returns the gas price in Gwei, which has to be converted to Wei
     * when building a transaction (1 Gwei = 10^9 Wei).
     */
    static std::string getAutomaticFee();

    /**
     * Get the highest available nonce for an address from the blockchain API.
     * Returns the nonce, or an empty string on failure.
     */
    static std::string getNonce(std::string address);

    /**
     * Broadcast a signed transaction to the blockchain.
     * Returns a link to the successful transaction, or an empty string on failure.
     */
    static std::string broadcastTx(std::string txidHex);
	
	static std::string getCurrentBlock();

    /**
     * Get the transaction status from the API to check if it has been confirmed.
     * Returns the confirmation status in Hex ("0x1 true, 0x0 false"),
     * or an empty string on failure.
     */
    static std::string getTxStatus(std::string txidHex);
	
	static std::string getTxBlock(std::string txidHex);
};

#endif // API_H

