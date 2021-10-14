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

#include <core/Utils.h>
#include <network/Pangolin.h>
#include <network/root_certificates.hpp>
#include <lib/nlohmann_json/json.hpp>

// For convenience.
using json = nlohmann::json;

// Struct for a JSON request.
typedef struct Request {
  uint64_t id;
  std::string jsonrpc;
  std::string method;
  json params;
} Request;

/**
 * Namespace for API/ethcall-related functions (e.g. getting current balances, fees,
 * block and nonce, broadcasting a transaction, etc).
 */
namespace API {
    // Strings for the API's host and port, respectively.
    static std::string apiHost;
    static std::string apiPort;
    static std::string apiTarget;
    static std::string webSocketHost;
    static std::string webSocketPort;
    static std::string webSocketTarget;
    // Mutex to prevent concurrent threads to access the static members above at the same time.
    static std::mutex apiMutex;
    /**
     * Send an HTTP GET Request to the API.
     * Returns the requested pure JSON data, or an empty string at connection failure.
     */
    std::string httpGetRequest(std::string reqBody, bool isWebSocket = false);

    /**
     * Sends a HTTP GET/POST request to host/port/target filled by the caller
     * this function serves as a easy-to-access method for developers building their own applications inside the wallet
     * but require to use their own API servers.
     */

    std::string customHttpRequest(std::string reqBody, std::string host, std::string port, std::string target, std::string requestType, std::string contentType);

    /**
     * Downloads a file from a given host URL and a given path (e.g. "/file.txt")
     * to a given target path in the filesystem.
     */
    void httpGetFile(std::string host, std::string get, std::string target);

    /**
     * Build one or multiple JSON requests to be sent to the API, respectively.
     * Returns the streamlined JSON string.
     */
    std::string buildRequest(Request req);
    std::string buildMultiRequest(std::vector<Request> reqs);

    /**
     * Broadcast a signed transaction to the blockchain.
     * Returns a link to the successful transaction, or an empty string on failure.
     */
    std::string broadcastTx(std::string txidHex);

    /**
     * Get the highest available nonce for an address from the blockchain API.
     * Returns the nonce, or an empty string on failure.
     */
    std::string getNonce(std::string address);

    /**
     * Get the current block number in the blockchain.
     * Returns the number.
     */
    std::string getCurrentBlock();

    /**
     * Get the transaction status from the API to check if it has been confirmed.
     * Returns the confirmation status in Hex ("0x1 true, 0x0 false"),
     * or an empty string on failure.
     */
    std::string getTxStatus(std::string txidHex);

    /**
     * Get the block number for the given transaction.
     * Returns the number.
     */
    std::string getTxBlock(std::string txidHex);

    void setDefaultAPI(std::string desiredHost, std::string desiredPort, std::string desiredTarget);
    
    void setWebSocketAPI(std::string desiredHost, std::string desiredPort, std::string desiredTarget); 
};

#endif // API_H

