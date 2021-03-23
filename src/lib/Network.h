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

#include "JSON.h"
#include "root_certificates.hpp"

/**
 * Class for network/API-related functions (e.g. requesting data from
 * a blockchain API online, an RPC endpoint or general HTTP operations).
 * Data is requested from a specified blockchain API host and its port,
 * along with its API key. Those are implementation-defined.
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

    /**
     * Get the recommended gas price for a transaction.
     * Returns the gas price in Gwei, which has to be converted to Wei
     * when building a transaction (1 Gwei = 10^9 Wei).
     */
    static std::string getAutomaticFee();

    // Get the highest available nonce for an address from the blockchain API.
    static std::string getNonce(std::string address);

    // Broadcast a signed transaction to the blockchain.
    static std::string broadcastTx(std::string txidHex);

    // Get the transaction receipt from the API to check if it has been confirmed.
    static std::string getTxReceipt(std::string txidHex);

    /**
     * Send an HTTP GET Request to the blockchain API.
     * Returns the requested pure JSON data, or an empty string at connection failure.
     * All other functions return whatever this one does.
     */
    static std::string httpGetRequest(std::string reqBody);
};

#endif // NETWORK_H

