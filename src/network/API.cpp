// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "API.h"

#ifdef TESTNET
std::string API::host = "testnet-api.avme.io";
std::string API::port = "443";
#else
std::string API::host = "api.avme.io";
std::string API::port = "443";
#endif

std::string API::httpGetRequest(std::string reqBody) {
  std::string result = "";
  using tcp = boost::asio::ip::tcp;       // from <boost/asio/ip/tcp.hpp>
  namespace ssl = boost::asio::ssl;       // from <boost/asio/ssl.hpp>
  namespace http = boost::beast::http;    // from <boost/beast/http.hpp>

  std::string RequestID = Utils::randomHexBytes();
  //std::cout << "REQUEST BODY: \n" << reqBody << std::endl;  // Uncomment for debugging
  Utils::logToDebug("API Request ID " + RequestID + " : " + reqBody);

  try {
    // Create context and load certificates into it
    boost::asio::io_context ioc;
    ssl::context ctx{ssl::context::sslv23_client};
    load_root_certificates(ctx);

    tcp::resolver resolver{ioc};
    ssl::stream<tcp::socket> stream{ioc, ctx};

    // Set SNI Hostname (many hosts need this to handshake successfully)
    if (!SSL_set_tlsext_host_name(stream.native_handle(), API::host.c_str())) {
      boost::system::error_code ec{static_cast<int>(::ERR_get_error()), boost::asio::error::get_ssl_category()};
      throw boost::system::system_error{ec};
    }
    auto const results = resolver.resolve(API::host, API::port);

    // Connect and Handshake
    boost::asio::connect(stream.next_layer(), results.begin(), results.end());
    stream.handshake(ssl::stream_base::client);

    // Set up an HTTP GET request message
    http::request<http::string_body> req{http::verb::post, "/", 11};
    req.set(http::field::host, API::host);
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
    Utils::logToDebug("API Result ID " + RequestID + " : " + result);
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
    Utils::logToDebug("API ID " + RequestID + " ERROR:" + e.what());
    return "";
  }

  return result;
}

std::string API::buildRequest(Request req) {
  json_spirit::mObject reqObj;
  json_spirit::mArray paramsArr;
  for (std::string param : req.params) { paramsArr.push_back(param); }
  reqObj["id"] = req.id;
  reqObj["jsonrpc"] = req.jsonrpc;
  reqObj["method"] = req.method;
  reqObj["params"] = paramsArr;
  std::string reqStr = json_spirit::write_string(json_spirit::mValue(reqObj), false);
  int pos;
  while ((pos = reqStr.find("\\")) != std::string::npos) { reqStr.erase(pos, 1); }
  while ((pos = reqStr.find("\"{")) != std::string::npos) { reqStr.erase(pos, 1); }
  while ((pos = reqStr.find("}\"")) != std::string::npos) { reqStr.erase(pos+1, 1); }
  return reqStr;
}

std::string API::buildMultiRequest(std::vector<Request> reqs) {
  json_spirit::mArray reqArr;
  for (Request req : reqs) {
    json_spirit::mObject reqObj;
    json_spirit::mArray paramsArr;
    for (std::string param : req.params) { paramsArr.push_back(param); }
    reqObj["id"] = req.id;
    reqObj["jsonrpc"] = req.jsonrpc;
    reqObj["method"] = req.method;
    reqObj["params"] = paramsArr;
    reqArr.push_back(reqObj);
  }
  std::string reqStr = json_spirit::write_string(json_spirit::mValue(reqArr), false);
  int pos;
  while ((pos = reqStr.find("\\")) != std::string::npos) { reqStr.erase(pos, 1); }
  while ((pos = reqStr.find("\"{")) != std::string::npos) { reqStr.erase(pos, 1); }
  while ((pos = reqStr.find("}\"")) != std::string::npos) { reqStr.erase(pos+1, 1); }
  return reqStr;
}

std::string API::getAVAXBalance(std::string address) {
  Request req{1, "2.0", "eth_getBalance", {address, "latest"}};
  std::string query = buildRequest(req);
  std::string resp = httpGetRequest(query);
  std::string hexBal = JSON::getString(resp, "result");
  u256 avaxWeiBal = boost::lexical_cast<HexTo<u256>>(hexBal);
  bigfloat avaxPointBalFloat = bigfloat(Utils::weiToFixedPoint(
    boost::lexical_cast<std::string>(avaxWeiBal), 18
  ));
  std::stringstream ss;
  ss << avaxPointBalFloat;
  std::string avaxPointBal = ss.str();
  return avaxPointBal;
}

std::vector<std::string> API::getAVAXBalances(std::vector<std::string> addresses) {
  std::vector<Request> reqs;
  std::vector<std::string> ret;
  for (int i = 0; i < addresses.size(); i++) {
    Request req{i+1, "2.0", "eth_getBalance", {addresses[i], "latest"}};
    reqs.push_back(req);
  }
  std::string query = buildMultiRequest(reqs);
  std::string resp = httpGetRequest(query);
  json_spirit::mValue resultArr;
  json_spirit::read_string(resp, resultArr);
  for (auto value : resultArr.get_array()) {
    std::string hexBal = JSON::objectItem(value, "result").get_str();
    u256 avaxWeiBal = boost::lexical_cast<HexTo<u256>>(hexBal);
    bigfloat avaxPointBalFloat = bigfloat(Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(avaxWeiBal), 18
    ));
    std::stringstream ss;
    ss << avaxPointBalFloat;
    std::string avaxPointBal = ss.str();
    ret.push_back(avaxPointBal);
  }
  return ret;
}

std::string API::getAVMEBalance(std::string address, std::string contractAddress) {
  std::stringstream query;
  std::string add = (address.substr(0,2) == "0x") ? address.substr(2) : address;
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\",\"params\": [{\"to\": \""
        << contractAddress
        << "\",\"data\": \"0x70a08231000000000000000000000000" << add
        << "\"},\"latest\"]}";
  std::string resp = httpGetRequest(query.str());
  return JSON::getString(resp, "result");
}

std::string API::getCompoundLPBalance(std::string address, std::string contractAddress) {
  std::stringstream query;
  std::string add = (address.substr(0,2) == "0x") ? address.substr(2) : address;
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\",\"params\": [{\"to\": \""
        << contractAddress
        << "\",\"data\": \"0x70a08231000000000000000000000000" << add
        << "\"},\"latest\"]}";
  std::string resp = httpGetRequest(query.str());
  u256 contractBalance = boost::lexical_cast<HexTo<u256>>(JSON::getString(resp, "result"));
  std::string contractBalanceStr = boost::lexical_cast<std::string>(contractBalance);
  std::stringstream secondQuery;
  secondQuery << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\",\"params\": [{\"to\": \""
        << contractAddress
        << "\",\"data\": \"0xeab89a5a" << Utils::uintToHex(contractBalanceStr)
        << "\"},\"latest\"]}";
  resp = httpGetRequest(secondQuery.str());
  return JSON::getString(resp, "result");
}

// TODO: convert to multi request
bool API::isARC20Token(std::string address) {
  json_spirit::mObject supplyJson, balanceJson;
  supplyJson["to"] = balanceJson["to"] = address;
  supplyJson["data"] = Pangolin::ERC20Funcs["totalSupply"];
  balanceJson["data"] = Pangolin::ERC20Funcs["balanceOf"] + Utils::addressToHex(address);
  Request supplyReq{1, "2.0", "eth_call", {
    json_spirit::write_string(json_spirit::mValue(supplyJson), false), "latest"
  }};
  Request balanceReq{1, "2.0", "eth_call", {
    json_spirit::write_string(json_spirit::mValue(balanceJson), false), "latest"
  }};
  std::string supplyQuery, supplyResp, supplyHex, balanceQuery, balanceResp, balanceHex;
  supplyQuery = buildRequest(supplyReq);
  balanceQuery = buildRequest(balanceReq);
  supplyResp = httpGetRequest(supplyQuery);
  balanceResp = httpGetRequest(balanceQuery);
  supplyHex = JSON::getString(supplyResp, "result");
  balanceHex = JSON::getString(balanceResp, "result");
  if (supplyHex == "0x" || supplyHex == "") { return false; }
  if (balanceHex == "0x" || balanceHex == "") { return false; }
  return true;
}

// TODO: convert to multi request
ARC20Token API::getARC20TokenData(std::string address) {
  json_spirit::mObject nameJson, symbolJson, decimalsJson;
  nameJson["to"] = symbolJson["to"] = decimalsJson["to"] = address;
  nameJson["data"] = Pangolin::ERC20Funcs["name"];
  symbolJson["data"] = Pangolin::ERC20Funcs["symbol"];
  decimalsJson["data"] = Pangolin::ERC20Funcs["decimals"];
  Request nameReq{1, "2.0", "eth_call", {
    json_spirit::write_string(json_spirit::mValue(nameJson), false), "latest"
  }};
  Request symbolReq{1, "2.0", "eth_call", {
    json_spirit::write_string(json_spirit::mValue(symbolJson), false), "latest"
  }};
  Request decimalsReq{1, "2.0", "eth_call", {
    json_spirit::write_string(json_spirit::mValue(decimalsJson), false), "latest"
  }};
  std::string nameQuery, nameResp, nameHex, symbolQuery, symbolResp, symbolHex,
    decimalsQuery, decimalsResp, decimalsHex;
  nameQuery = buildRequest(nameReq);
  symbolQuery = buildRequest(symbolReq);
  decimalsQuery = buildRequest(decimalsReq);
  nameResp = httpGetRequest(nameQuery);
  symbolResp = httpGetRequest(symbolQuery);
  decimalsResp = httpGetRequest(decimalsQuery);
  nameHex = JSON::getString(nameResp, "result");
  symbolHex = JSON::getString(symbolResp, "result");
  decimalsHex = JSON::getString(decimalsResp, "result");
  ARC20Token ret;
  ret.address = address;
  ret.name = Utils::stringFromHex(nameHex);
  ret.symbol = Utils::stringFromHex(symbolHex);
  ret.decimals = boost::lexical_cast<int>(Utils::uintFromHex(decimalsHex));
  ret.avaxPairContract = "";  // TODO
  return ret;
}

std::string API::getAutomaticFee() {
  return "225"; // AVAX fees are fixed
}

std::string API::getNonce(std::string address) {
  std::stringstream query;
  query << "{\"jsonrpc\": \"2.0\",\"method\": \"eth_getTransactionCount\",\"params\": [\""
        << address
        << "\",\"latest\"],\"id\": 1}";
  std::string resp = httpGetRequest(query.str());
  return JSON::getString(resp, "result");
}

std::string API::broadcastTx(std::string txidHex) {
  std::stringstream query;
  std::string ApitxidHex = "0x";
  ApitxidHex += txidHex;
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_sendRawTransaction\",\"params\": [\""
        << ApitxidHex
        << "\"]}";
  std::string resp = httpGetRequest(query.str());
  return JSON::getString(resp, "result");
}

std::string API::getCurrentBlock() {
  std::stringstream query;
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_blockNumber\",\"params\": []}";
  std::string resp = httpGetRequest(query.str());
  return JSON::getString(resp, "result");
}


std::string API::getTxStatus(std::string txidHex) {
  std::stringstream query;
  std::string ApitxidHex = "0x";
  ApitxidHex += txidHex;
  query << "{\"jsonrpc\": \"2.0\",\"method\": \"eth_getTransactionReceipt\",\"params\": [\""
        << ApitxidHex
        << "\"],\"id\": 1}";
  std::string resp = httpGetRequest(query.str());
  return JSON::getString(resp, "result/status", "/");
}

std::string API::getTxBlock(std::string txidHex) {
  std::stringstream query;
  std::string ApitxidHex = "0x";
  ApitxidHex += txidHex;
  query << "{\"jsonrpc\": \"2.0\",\"method\": \"eth_getTransactionReceipt\",\"params\": [\""
        << ApitxidHex
        << "\"],\"id\": 1}";
  std::string resp = httpGetRequest(query.str());
  return JSON::getString(resp, "result/blockNumber", "/");
}
