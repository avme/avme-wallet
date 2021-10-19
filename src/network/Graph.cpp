// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "Graph.h"

std::string Graph::host = "api.thegraph.com";
std::string Graph::port = "443";
std::string Graph::target = "/subgraphs/name/dasconnor/pangolin-dex";

std::string Graph::httpGetRequest(std::string reqBody) {
  std::string result = "";
  using tcp = boost::asio::ip::tcp;       // from <boost/asio/ip/tcp.hpp>
  namespace ssl = boost::asio::ssl;       // from <boost/asio/ssl.hpp>
  namespace http = boost::beast::http;    // from <boost/beast/http.hpp>

  std::string RequestID = Utils::randomHexBytes();
  //std::cout << "REQUEST BODY: \n" << reqBody << std::endl;  // Uncomment for debugging
  //Utils::logToDebug("GRAPH Request ID " + RequestID + " : " + reqBody);

  try {
    // Create context and load certificates into it
    boost::asio::io_context ioc;
    ssl::context ctx{ssl::context::sslv23_client};
    load_root_certificates(ctx);

    tcp::resolver resolver{ioc};
    ssl::stream<tcp::socket> stream{ioc, ctx};

    // Set SNI Hostname (many hosts need this to handshake successfully)
    if (!SSL_set_tlsext_host_name(stream.native_handle(), Graph::host.c_str())) {
      boost::system::error_code ec{static_cast<int>(::ERR_get_error()), boost::asio::error::get_ssl_category()};
      throw boost::system::system_error{ec};
    }
    auto const results = resolver.resolve(Graph::host, Graph::port);

    // Connect and Handshake
    boost::asio::connect(stream.next_layer(), results.begin(), results.end());
    stream.handshake(ssl::stream_base::client);

    // Set up an HTTP GET request message
    http::request<http::string_body> req{http::verb::post, Graph::target, 11};
    req.set(http::field::host, Graph::host);
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

    //Utils::logToDebug("GRAPH Result ID " + RequestID + " : " + result);
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
    //Utils::logToDebug("GRAPH ID " + RequestID + " ERROR:" + e.what());
    return "";
  }

  return result;
}

/**
 * Prices are inverted, taking the WAVAX-USDT pair as an example:
 * - If token0 is WAVAX, token1Price is 1 WAVAX price in USDT
 * - If token0 is USDT, token1Price is 1 USDT price in WAVAX
 */
std::string Graph::getAVAXPriceUSD() {
  std::stringstream query;
  query << "{\"query\": \"{"
        << "pair(id: \\\"0xe28984e1ee8d431346d32bec9ec800efb643eef4\\\")"
        << "{token0 {symbol} token1 {symbol} token0Price token1Price}"
        << "}\"}";
  std::string resp = httpGetRequest(query.str());
  json respJson = json::parse(resp);
  std::string token0Label, token1Label, token0Price, token1Price;
  token0Label = respJson["data"]["pair"]["token0"]["symbol"].get<std::string>();
  token1Label = respJson["data"]["pair"]["token1"]["symbol"].get<std::string>();
  token0Price = respJson["data"]["pair"]["token0Price"].get<std::string>();
  token1Price = respJson["data"]["pair"]["token1Price"].get<std::string>();
  return (token0Label == "WAVAX") ? token1Price : token0Price;
}

std::string Graph::parseAVAXPriceUSD(json input) {
  std::string token0Label, token1Label, token0Price, token1Price;
  token0Label = input["data"]["USDAVAX"]["token0"]["symbol"].get<std::string>();
  token1Label = input["data"]["USDAVAX"]["token1"]["symbol"].get<std::string>();
  token0Price = input["data"]["USDAVAX"]["token0Price"].get<std::string>();
  token1Price = input["data"]["USDAVAX"]["token1Price"].get<std::string>();
  return (token0Label == "WAVAX") ? token1Price : token0Price;
}

json Graph::avaxUSDData(int days) {
  std::stringstream query;
  // Get USD AVAX price with ID USDAVAX.
  query << "{\"query\": \"{"
      << "USDAVAX: pair(id: \\\"0xe28984e1ee8d431346d32bec9ec800efb643eef4\\\")"
      << "{token0 {symbol} token1 {symbol} token0Price token1Price}"
  // Put the chart data into AVAXUSDCHART:
      << "AVAXUSDCHART: tokenDayDatas(first: " << days << ", orderBy: date, orderDirection: desc, where: {"
      << "token: \\\"0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7\\\""
      << "} ) { date priceUSD } }\"}";
  std::string resp = httpGetRequest(query.str());
  json respJson = json::parse(resp);
  return respJson;
}

std::string Graph::getTokenPriceDerived(std::string address) {
  std::stringstream query;
  address = Utils::toLowerCaseAddress(address);
  query << "{\"query\": \"{"
        << "token(id: \\\"" + address + "\\\")"
        << "{symbol derivedETH}"
        << "}\"}";
  std::string resp = httpGetRequest(query.str());
  json respJson = json::parse(resp);
  std::string derivedETH = respJson["data"]["token"]["derivedETH"].get<std::string>();
  return derivedETH;
}

json Graph::getTokenPriceHistory(std::string address, int days) {
  std::stringstream query;
  address = Utils::toLowerCaseAddress(address);
  query << "{\"query\": \"{"
        << "tokenDayDatas(first: " << days << ", orderBy: date, orderDirection: desc, where: {"
        << "token: \\\"" << address << "\\\""
        << "} ) { date priceUSD } }\"}";
  std::string resp = httpGetRequest(query.str());
  json respJson = json::parse(resp);
  json arr = respJson["data"]["tokenDayDatas"];
  return arr;
}

json Graph::getAccountPrices(std::vector<ARC20Token> tokenList) {
  std::stringstream query;
  json ret;

  // Get USD AVAX price with ID USDAVAX.
  query << "{\"query\": \"{"
        << "USDAVAX: pair(id: \\\"0xe28984e1ee8d431346d32bec9ec800efb643eef4\\\")"
        << "{token0 {symbol} token1 {symbol} token0Price token1Price}";

  // Request USD Price for each token. Using token_contract as ID
  for (auto token : tokenList) {
    token.address = Utils::toLowerCaseAddress(token.address);
    query << "token_" << token.address << ": token(id: \\\"" << token.address << "\\\")"
    << "{symbol derivedETH}";
    query << "chart_" << token.address << ": tokenDayDatas(first: 31, orderBy: date, orderDirection: desc, where: {";
    query << "token: \\\"" << token.address << "\\\"" << "} ) { date priceUSD id }";
  }

  // Add AVAX Price chart to the query
  query << "AVAXUSDCHART: tokenDayDatas(first: 31, orderBy: date, orderDirection: desc, where: {"
        << "token: \\\"0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7\\\""
        << "} ) { date priceUSD }";

  // Close the query
  query << "}\"}";
  std::string resp = httpGetRequest(query.str());
  ret = json::parse(resp);
  return ret;
}

