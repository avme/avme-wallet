// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "Graph.h"

std::string Graph::host = "graph-node.avax.network";
std::string Graph::port = "443";
std::string Graph::target = "/subgraphs/name/dasconnor/pangolindex";

std::string Graph::httpGetRequest(std::string reqBody) {
  std::string result = "";
  using tcp = boost::asio::ip::tcp;       // from <boost/asio/ip/tcp.hpp>
  namespace ssl = boost::asio::ssl;       // from <boost/asio/ssl.hpp>
  namespace http = boost::beast::http;    // from <boost/beast/http.hpp>

  //std::cout << "REQUEST BODY: \n" << reqBody << std::endl;  // Uncomment for debugging

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

/**
 * Prices are inverted, taking the WAVAX-USDT pair as an example:
 * - If token0 is WAVAX, token1Price is 1 WAVAX price in USDT
 * - If token0 is USDT, token1Price is 1 USDT price in WAVAX
 */
std::string Graph::getAVAXPriceUSD() {
  std::stringstream query;
  query << "{\"query\": \"{"
        << "pair(id: \\\"0x9ee0a4e21bd333a6bb2ab298194320b8daa26516\\\")"
        << "{token0 {symbol} token1 {symbol} token0Price token1Price}"
        << "}\"}";
  std::string resp = httpGetRequest(query.str());
  std::string token0Label = JSON::getString(resp, "data/pair/token0/symbol", "/");
  std::string token1Label = JSON::getString(resp, "data/pair/token1/symbol", "/");
  std::string token0Price = JSON::getString(resp, "data/pair/token0Price", "/");
  std::string token1Price = JSON::getString(resp, "data/pair/token1Price", "/");
  return (token0Label == "WAVAX") ? token1Price : token0Price;
}

std::string Graph::getAVMEPriceUSD(std::string AVAXUnitPriceUSD) {
  std::stringstream query;
  query << "{\"query\": \"{"
        << "token(id: \\\"0x1ecd47ff4d9598f89721a2866bfeb99505a413ed\\\")"
        << "{symbol derivedETH}"
        << "}\"}";
  std::string resp = httpGetRequest(query.str());
  std::string derivedETH = JSON::getString(resp, "data/token/derivedETH", "/");
  bigfloat AVAXPriceFloat = boost::lexical_cast<double>(AVAXUnitPriceUSD);
  bigfloat derivedETHFloat = boost::lexical_cast<double>(derivedETH);
  bigfloat AVMEPriceFloat = derivedETHFloat * AVAXPriceFloat;
  std::string AVMEPriceUSD = boost::lexical_cast<std::string>(AVMEPriceFloat);
  return AVMEPriceUSD;
}

std::vector<std::map<std::string, std::string>> Graph::getAVMEPriceHistory(int days) {
  std::string AVAXUnitPriceUSD = getAVAXPriceUSD();
  bigfloat AVAXPriceFloat = bigfloat(AVAXUnitPriceUSD);
  std::stringstream query;
  query << "{\"query\": \"{"
        << "tokenDayDatas(first: " << days << ", orderBy: date, orderDirection: desc, where: {"
        << "token: \\\"0x1ecd47ff4d9598f89721a2866bfeb99505a413ed\\\""
        << "} ) { date priceUSD } }\"}";
  std::string resp = httpGetRequest(query.str());
  std::vector<std::map<std::string, std::string>> arr = JSON::getObjectArray(
    resp, "data/tokenDayDatas", "/"
  );
  for (std::map<std::string, std::string> &pair : arr) {
    pair["priceUSD"] = boost::lexical_cast<std::string>(
      boost::lexical_cast<double>(pair["priceUSD"]) * AVAXPriceFloat
    );
  }
  return arr;
}
