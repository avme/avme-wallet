// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "Network.h"

// TODO: find a way to toggle between testnet and mainnet later
std::string Network::hostName = "api.avax-test.network";
std::string Network::hostPort = "443";

std::string Network::getAVAXBalance(std::string address) {
  std::stringstream query;
  query << "{\"jsonrpc\": \"2.0\",\"method\": \"eth_getBalance\",\"params\": [\""
        << address
        << "\",\"latest\"],\"id\": 1}";
  return httpGetRequest(query.str());
}

std::string Network::getAVMEBalance(std::string address, std::string contractAddress) {
  std::stringstream query;
  std::string add = (address.substr(0,2) == "0x") ? address.substr(2) : address;
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\",\"params\": [{\"to\": \""
        << contractAddress
        << "\",\"data\": \"0x70a08231000000000000000000000000" << add
        << "\"},\"latest\"]}";
  return httpGetRequest(query.str());
}

// TODO: change this when more coins/tokens are added
std::string Network::getAutomaticFee() {
  //return "470"; // AVAX fees are fixed
  return "225"; // AVAX fees are fixed
}

std::string Network::getNonce(std::string address) {
  std::stringstream query;
  query << "{\"jsonrpc\": \"2.0\",\"method\": \"eth_getTransactionCount\",\"params\": [\""
        << address
        << "\",\"latest\"],\"id\": 1}";
  return httpGetRequest(query.str());
}

std::string Network::broadcastTx(std::string txidHex) {
  std::stringstream query;
  std::string ApitxidHex = "0x";
  ApitxidHex += txidHex;
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_sendRawTransaction\",\"params\": [\""
        << ApitxidHex
        << "\"]}";
  return httpGetRequest(query.str());
}

std::string Network::getTxReceipt(std::string txidHex) {
  std::stringstream query;
  std::string ApitxidHex = "0x";
  ApitxidHex += txidHex;
  query << "{\"jsonrpc\": \"2.0\",\"method\": \"eth_getTransactionReceipt\",\"params\": [\""
        << ApitxidHex
        << "\"],\"id\": 1}";
  return httpGetRequest(query.str());
}

std::string Network::httpGetRequest(std::string reqBody) {
  std::string result = "";
  using tcp = boost::asio::ip::tcp;       // from <boost/asio/ip/tcp.hpp>
  namespace ssl = boost::asio::ssl;       // from <boost/asio/ssl.hpp>
  namespace http = boost::beast::http;    // from <boost/beast/http.hpp>

  //std::cout << "REQUEST BODY: \n" << reqBody << std::endl;  // Uncomment for debugging

  try {
    std::string host = Network::hostName;
    std::string port = Network::hostPort;
    std::string target = "/ext/bc/C/rpc"; // RPC Endpoint target

    boost::asio::io_context ioc;

    // Load certificates into context
    ssl::context ctx{ssl::context::sslv23_client};
    load_root_certificates(ctx);

    tcp::resolver resolver{ioc};
    ssl::stream<tcp::socket> stream{ioc, ctx};

    // Set SNI Hostname (many hosts need this to handshake successfully)
    if (!SSL_set_tlsext_host_name(stream.native_handle(), host.c_str())) {
      boost::system::error_code ec{static_cast<int>(::ERR_get_error()), boost::asio::error::get_ssl_category()};
      throw boost::system::system_error{ec};
    }
    auto const results = resolver.resolve(host, port);

    // Connect and Handshake
    boost::asio::connect(stream.next_layer(), results.begin(), results.end());
    stream.handshake(ssl::stream_base::client);

    // Set up an HTTP GET request message
    http::request<http::string_body> req{http::verb::post, target, 11};
    req.set(http::field::host, host);
    req.set(http::field::user_agent, BOOST_BEAST_VERSION_STRING);
    req.set(http::field::content_type, "application/json");
    req.body() = reqBody;
    req.prepare_payload();

    // Send the HTTP request to the remote host
    http::write(stream, req);
    boost::beast::flat_buffer buffer;

    // Declare a container to hold the response
    http::response<http::dynamic_body> res;

    // Receive the HTTP response
    http::read(stream, buffer, res);

    // Write only the body answer to output
    std::string body { boost::asio::buffers_begin(res.body().data()),boost::asio::buffers_end(res.body().data()) };
    result = body;

    //std::cout << "REQUEST RESULT: \n" << result << std::endl; // Uncomment for debugging

    boost::system::error_code ec;
    stream.shutdown(ec);

    // SSL Connections return stream_truncated when closed.
    // For that reason, we need to treat this as an error.
    if (ec == boost::asio::error::eof || boost::asio::ssl::error::stream_truncated)
      ec.assign(0, ec.category());
    if (ec)
      throw boost::system::system_error{ec};
  } catch (std::exception const& e) {
    std::cerr << "Error: " << e.what() << std::endl;
    return "";
  }

  return result;
}

