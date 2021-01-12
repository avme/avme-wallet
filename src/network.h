#include <iostream>
#include <string>

#include <boost/asio.hpp>

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
     * Returns the requested data, or an empty string at failure.
     * All functions below return whatever this one returns.
     */
    static std::string httpGetRequest(std::string httpquery);

    // Get ETH and token balances from an address in the blockchain API.
    static std::string getETHBalance(std::string address);
    static std::string getTAEXBalance(std::string address);

    // Get recommended fees at the moment from the blockchain API.
    static std::string getTxFees();

    // Get the highest available nonce for an address from the blockchain API.
    static std::string getTxNonce(std::string address);

    // Broadcast a signed transaction to the blockchain.
    static std::string broadcastTransaction(std::string txidHex);
};

