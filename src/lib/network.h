#ifndef NETWORK_H
#define NETWORK_H

#include <cstdlib>
#include <iostream>
#include <string>

#include <boost/asio.hpp>
#include <boost/asio/ssl.hpp>
#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/beast/version.hpp>

#include "json.h"
#include "root_certificates.hpp"

/**
 * Collection of network/API-related functions (e.g. requesting data from
 * a blockchain API online, an RPC endpoint or general HTTP operations).
 * Data is requested from a specified blockchain API host and its port,
 * along with its API key. Those are implementation-defined.
 * Check https://uniswap.org/docs/v2/smart-contracts for info on contracts
 * and functions related to those.
 */

class Network {
  private:
    static std::string hostName;
    static std::string hostPort;

  public:
    // TODO: build JSON queries with json_spirit instead of stringstream

    /**
     * Get coin/token balances from a given address in the blockchain API.
     * For a list of addresses, make one call per address in the list.
     */
    static std::string getAVAXBalance(std::string address);
    static std::string getAVMEBalance(std::string address, std::string contractAddress);

    // Get the highest available nonce for an address from the blockchain API.
    static std::string getTxNonce(std::string address);

    // Broadcast a signed transaction to the blockchain.
    static std::string broadcastTransaction(std::string txidHex);

    // Get the transaction receipt from the API to check if it has been confirmed.
    static std::string getTransactionReceipt(std::string txidHex);

    /**
     * Send an HTTP GET Request to the blockchain API.
     * Returns the requested pure JSON data, or an empty string at connection failure.
     * All other functions return whatever this one does.
     */
    static std::string httpGetRequest(std::string reqBody);
};

#endif // NETWORK_H

