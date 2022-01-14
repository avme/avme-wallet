// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "API.h"

std::string API::httpGetRequest(std::string reqBody, bool isWebSocket) {
  std::string result = "";
  using tcp = boost::asio::ip::tcp;       // from <boost/asio/ip/tcp.hpp>
  namespace ssl = boost::asio::ssl;       // from <boost/asio/ssl.hpp>
  namespace http = boost::beast::http;    // from <boost/beast/http.hpp>

  std::string RequestID = Utils::randomHexBytes();
  //std::cout << "REQUEST BODY: \n" << reqBody << std::endl;  // Uncomment for debugging
  //Utils::logToDebug("API Request ID " + RequestID + " : " + reqBody);

  std::string host;
  std::string port;
  std::string target;

  apiMutex.lock();
  if (isWebSocket) {
    host = webSocketHost;
    port = webSocketPort;
    target = webSocketTarget;
  } else {
    host = apiHost;
    port = apiPort;
    target = apiTarget;
  }
  apiMutex.unlock();

  try {
    // Create context and load certificates into it
    boost::asio::io_context ioc;
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
    //std::cout << res.base().result() << std::endl;

    // Write only the body answer to output
    std::string body { boost::asio::buffers_begin(res.body().data()),boost::asio::buffers_end(res.body().data()) };
    result = body;
    //Utils::logToDebug("API Result ID " + RequestID + " : " + result);
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
    //std::cout << "Error: " << e.what() << std::endl;
    Utils::logToDebug("API ID " + RequestID + " ERROR:" + e.what());
    return "";
  }

  return result;
}

void API::httpGetFile(std::string host, std::string get, std::string target) {
  using tcp = boost::asio::ip::tcp;       // from <boost/asio/ip/tcp.hpp>
  namespace ssl = boost::asio::ssl;       // from <boost/asio/ssl.hpp>
  namespace http = boost::beast::http;    // from <boost/beast/http.hpp>
  typedef ssl::stream<tcp::socket> ssl_socket;
  boost::system::error_code error;

  try {
    // Create context and load certificates into it
    boost::asio::io_context ioc;
    ssl::context ctx{ssl::context::sslv23_client};
    load_root_certificates(ctx);

    tcp::resolver resolver{ioc};
    ssl::stream<tcp::socket> stream{ioc, ctx};

    // Set SNI Hostname (many hosts need this to handshake successfully)
    if (!SSL_set_tlsext_host_name(stream.native_handle(), host.c_str())) {
      boost::system::error_code ec{static_cast<int>(::ERR_get_error()), boost::asio::error::get_ssl_category()};
      throw boost::system::system_error{ec};
    }
    auto const results = resolver.resolve(host, "443"); // Always HTTPS

    // Connect and Handshake
    boost::asio::connect(stream.next_layer(), results.begin(), results.end());
    stream.handshake(ssl::stream_base::client);

    // Set up an HTTP GET request message
    http::request<http::string_body> req{http::verb::get, get, 11};
    req.set(http::field::host, host);
    req.set(http::field::user_agent, BOOST_BEAST_VERSION_STRING);
    req.set(http::field::content_type, "application/octet-stream");
    req.prepare_payload();

    // Send the HTTP request to the remote host
    http::write(stream, req);
    boost::beast::flat_buffer buffer;

    // Declare a container to hold the response
    http::response<http::dynamic_body> res;

    // Receive the HTTP response
    http::read(stream, buffer, res);

    // Write only the body answer to output.
    // SSL Connections return stream_truncated when closed.
    // For that reason, we need to treat this as an error.
    std::string body { boost::asio::buffers_begin(res.body().data()),boost::asio::buffers_end(res.body().data()) };
    boost::system::error_code ec;
    stream.shutdown(ec);
    if (ec == boost::asio::error::eof || boost::asio::ssl::error::stream_truncated)
      ec.assign(0, ec.category());
    if (ec) throw boost::system::system_error{ec};
    if (res.result_int() == 200) {
      boost::nowide::ofstream outFile(target, std::ofstream::out | std::ofstream::binary);
      outFile << body;
      outFile.close();
    }
  } catch (std::exception const& e) {
    //std::cout << "ERROR downloading file: " << e.what() << std::endl;
    Utils::logToDebug(std::string("ERROR downloading file: ") + e.what());
  }
}

std::string API::customHttpRequest(std::string reqBody, std::string host, std::string port, std::string target, std::string requestType, std::string contentType) {
  std::string result = "";
  using tcp = boost::asio::ip::tcp;       // from <boost/asio/ip/tcp.hpp>
  namespace ssl = boost::asio::ssl;       // from <boost/asio/ssl.hpp>
  namespace http = boost::beast::http;    // from <boost/beast/http.hpp>

  std::string RequestID = Utils::randomHexBytes();
  //std::cout << "REQUEST BODY: \n" << reqBody << std::endl;  // Uncomment for debugging
  //Utils::logToDebug("API Request ID " + RequestID + " : " + reqBody);

  try {
    // Create context and load certificates into it
    boost::asio::io_context ioc;
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

    // Set up an HTTP POST/GET request message
    http::request<http::string_body> req{(requestType == "POST") ? http::verb::post : http::verb::get, target, 11};
    if (requestType == "GET") {
      req.set(http::field::host, host);
      req.set(http::field::user_agent, BOOST_BEAST_VERSION_STRING);
      req.set(http::field::content_type, contentType);
      req.body() = reqBody;
      req.prepare_payload();
    } else if (requestType == "POST") {
      req.set(http::field::host, host);
      req.set(http::field::user_agent, BOOST_BEAST_VERSION_STRING);
      req.set(http::field::accept, "application/json");
      req.set(http::field::content_type, contentType);
      req.body() = reqBody;
      req.prepare_payload();
    }

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
    //Utils::logToDebug("API Result ID " + RequestID + " : " + result);
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
    //Utils::logToDebug("API ID " + RequestID + " ERROR:" + e.what());
    return "";
  }

  return result;
}

std::string API::buildRequest(Request req) {
  json request;
  request["id"] = req.id;
  request["jsonrpc"] = req.jsonrpc;
  request["method"] = req.method;
  request["params"] = req.params;
  std::string reqStr = request.dump();
  int pos;
  while ((pos = reqStr.find("\\")) != std::string::npos) { reqStr.erase(pos, 1); }
  while ((pos = reqStr.find("\"{")) != std::string::npos) { reqStr.erase(pos, 1); }
  while ((pos = reqStr.find("}\"")) != std::string::npos) { reqStr.erase(pos+1, 1); }
  return reqStr;
}

std::string API::buildMultiRequest(std::vector<Request> reqs) {
  json reqArr;
  for (Request req : reqs) {
    json request;
    request["id"] = req.id;
    request["jsonrpc"] = req.jsonrpc;
    request["method"] = req.method;
    request["params"] = req.params;
    reqArr.push_back(request);
  }
  std::string reqStr = reqArr.dump();
  return reqStr;
}

std::string API::broadcastTx(std::string txidHex) {
  Request req{1, "2.0", "eth_sendRawTransaction", {"0x" + txidHex}};
  std::string query = buildRequest(req);
  std::string resp = httpGetRequest(query);
  return resp;
}

std::string API::getNonce(std::string address) {
  Request req{1, "2.0", "eth_getTransactionCount", {address, "latest"}};
  std::string query = buildRequest(req);
  std::string resp = httpGetRequest(query);
  json respJson = json::parse(resp);
  return respJson["result"].get<std::string>();
}

std::string API::getCurrentBlock() {
  Request req{1, "2.0", "eth_blockNumber", {}};
  std::string query = buildRequest(req);
  std::string resp = httpGetRequest(query);
  json respJson = json::parse(resp);
  return respJson["result"].get<std::string>();
}

std::string API::getTxStatus(std::string txidHex) {
  Request req{1, "2.0", "eth_getTransactionReceipt", {"0x" + txidHex}};
  std::string query = buildRequest(req);
  //std::cout << query << std::endl;
  std::string resp = httpGetRequest(query);
  //std::cout << resp << std::endl;
  json respJson = json::parse(resp);
  return respJson["result"].dump();
}

std::string API::getTxBlock(std::string txidHex) {
  Request req{1, "2.0", "eth_getTransactionReceipt", {"0x" + txidHex}};
  std::string query = buildRequest(req);
  std::string resp = httpGetRequest(query);
  return resp;
}

void API::setDefaultAPI(std::string desiredHost, std::string desiredPort, std::string desiredTarget) {
  apiMutex.lock();
  apiHost = desiredHost;
  apiPort = desiredPort;
  apiTarget = desiredTarget;
  apiMutex.unlock();
}

void API::setWebSocketAPI(std::string desiredHost, std::string desiredPort, std::string desiredTarget) {
  apiMutex.lock();
  webSocketHost = desiredHost;
  webSocketPort = desiredPort;
  webSocketTarget = desiredTarget;
  apiMutex.unlock();
}
