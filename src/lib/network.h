#ifndef NETWORK_H
#define NETWORK_H

#include <iostream>
#include <string>

#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/beast/version.hpp>
#include <boost/asio/ssl.hpp>
#include <boost/asio.hpp>
#include <cstdlib>
#include <iostream>
#include <string>

#include "json.h"
#include "root_certificates.hpp"

/**
 * Collection of network/API-related functions (e.g. requesting data from
 * a blockchain API online, or general HTTP operations).
 * Data is requested from a specified blockchain API host and its port,
 * along with its API key. Those are implementation-defined.
 */

class Network {
  private:
    static std::string hostName;
    static std::string hostPort;
    static std::string apiKey;

  public:
    /**
     * Send an HTTP GET Request to the blockchain API.
     * Returns the requested pure JSON data, or an empty string at failure.
     * All other functions return whatever this one does.
     */
    static std::string httpGetRequest(std::string httpquery);

    /**
     * Get ETH/token balances from one or more addresses in the blockchain API.
     * Due to API lmitations, the following restraints apply:
     * - Only up to 20 ETH accounts can be batch requested at once.
     *   If a list has more than that, it's suggested to split it in smaller
     *   batches of 20 and make multiple requests.
     * - Tokens unfortunately can't be batched, so only one address at a time
     *   can be requested.
     */
    static std::string getETHBalance(std::string address);
    static std::string getETHBalances(std::vector<std::string> addresses);
    static std::string getTAEXBalance(std::string address);

    // Get recommended fees at the moment from the blockchain API.
    static std::string getTxFees();

    // Get the highest available nonce for an address from the blockchain API.
    static std::string getTxNonce(std::string address);

    // Broadcast a signed transaction to the blockchain.
    static std::string broadcastTransaction(std::string txidHex);
};

#endif // NETWORK_H

