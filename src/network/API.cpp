// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "API.h"

std::string API::host = "api.avme.io";
std::string API::port = "443";

std::string API::httpGetRequest(std::string reqBody, bool usePublic) {
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

  if (usePublic) {
    host = "api.avax.network";
    port = "443";
    target = "/ext/bc/C/rpc";
  } else {
    host = API::host;
    port = "443";
    target = "/";
  }

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

void API::httpGetFile(std::string host, std::string get, std::string target) {
  using boost::asio::ip::tcp;
  namespace ssl = boost::asio::ssl;
  typedef ssl::stream<tcp::socket> ssl_socket;
  boost::system::error_code error;

  // Create a context that uses the default paths for finding CA certificates.
  ssl::context ctx(ssl::context::sslv23);
  ctx.set_default_verify_paths();

  // Open a socket and connect it to the remote host.
  boost::asio::io_context io_context;
  ssl_socket socket(io_context, ctx);
  tcp::resolver resolver(io_context);
  tcp::resolver::query query(host, API::port);
  boost::asio::connect(socket.lowest_layer(), resolver.resolve(query));
  socket.lowest_layer().set_option(tcp::no_delay(true));

  // Perform SSL handshake and verify the remote host's certificate.
  socket.set_verify_mode(ssl::verify_none);
  socket.handshake(ssl_socket::client);

  // Make and send the request.
  boost::asio::streambuf request;
  std::ostream request_stream(&request);
  request_stream << "GET " << get << " HTTP/1.0\r\n";
  request_stream << "Host: " << host << "\r\n";
  request_stream << "Accept: */*\r\n";
  request_stream << "Connection: close\r\n\r\n";
  //std::string out {buffers_begin(request.data()), buffers_end(request.data())};
  //std::cout << out << std::endl;
  boost::asio::write(socket, request);

  // Read the response status line.
  boost::asio::streambuf response;
  boost::asio::read_until(socket, response, "\r\n");
  //std::string out2 {buffers_begin(response.data()), buffers_end(response.data())};
  //std::cout << out2 << std::endl;

  // Check that response is OK.
  std::istream response_stream(&response);
  std::string http_version;
  response_stream >> http_version;
  unsigned int status_code;
  response_stream >> status_code;
  if (status_code == 404) { return; } // Abort if file is not found
  std::string status_message;
  std::getline(response_stream, status_message);
  //std::cout << host << get << std::endl;
  //std::cout << status_code << status_message << std::endl;

  // Read and process the response headers, which are terminated by a blank line.
  boost::asio::read_until(socket, response, "\r\n\r\n");
  std::string header;
  while (std::getline(response_stream, header) && header != "\r") {}

  // Write whatever content we already have to output, and read until EOF,
  // writing data to output as we go.
  boost::nowide::ofstream outFile(target, std::ofstream::out | std::ofstream::binary);
  if (response.size() > 0) {
    outFile << &response;
  }
  while (boost::asio::read(socket, response, boost::asio::transfer_at_least(1), error)) {
    outFile << &response;
  }
  outFile.close();
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
  std::cout << query << std::endl;
  std::string resp = httpGetRequest(query);
  std::cout << resp << std::endl;
  json respJson = json::parse(resp);
  return respJson["result"].dump(); 
}

std::string API::getTxBlock(std::string txidHex) {
  Request req{1, "2.0", "eth_getTransactionReceipt", {"0x" + txidHex}};
  std::string query = buildRequest(req);
  std::string resp = httpGetRequest(query);
  return resp;
}

