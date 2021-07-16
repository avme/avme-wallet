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

#include <core/JSON.h>
#include <core/Utils.h>
#include <network/Pangolin.h>
#include <network/root_certificates.hpp>

// Struct for a JSON request.
typedef struct Request {
  int id;
  std::string jsonrpc;
  std::string method;
  std::vector<std::string> params;
} Request;

/**
 * Class for API/ethcall-related functions (e.g. getting current balances, fees,
 * block and nonce, broadcasting a transaction, etc).
 */
class API {
  private:
    // Strings for the API's host and port, respectively.
    static std::string host;
    static std::string port;

  public:
    /**
     * Send an HTTP GET Request to the API.
     * Returns the requested pure JSON data, or an empty string at connection failure.
     */
    static std::string httpGetRequest(std::string reqBody);

    /**
     * Downloads a file from a given host URL and a given path (e.g. "/file.txt")
     * to a given target path in the filesystem.
     */
    static void httpGetFile(std::string host, std::string get, std::string target);

    /**
     * Build one or multiple JSON requests to be sent to the API, respectively.
     * Returns the streamlined JSON string.
     */
    static std::string buildRequest(Request req);
    static std::string buildMultiRequest(std::vector<Request> reqs);

    /**
     * Get coin/token balances from one or multiple addresses in the API, respectively.
     * Returns balances in fixed point, or empty strings on failure.
     * TODO: maybe rename to getCoinBalance / getTokenBalance?
     */
    static std::string getAVAXBalance(std::string address);
    static std::vector<std::string> getAVAXBalances(std::vector<std::string> addresses);
    static std::string getAVMEBalance(std::string address, std::string contractAddress);

    /**
     * Get Locked LP Balance inside YY Contract
     */
    static std::string getCompoundLPBalance(std::string address, std::string contractAddress);

    /**
     * Check if a given address is an ARC20 token.
     */
    static bool isARC20Token(std::string address);

    /**
     * Get an ARC20 token's data.
     */
    static ARC20Token getARC20TokenData(std::string address);

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

