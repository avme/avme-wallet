#include "network.h"

// TODO: find a way to toggle between testnet and mainnet later
std::string Network::hostName = "api-ropsten.etherscan.io";
std::string Network::hostPort = "80";
std::string Network::apiKey = "6342MIVP4CD1ZFDN3HEZZG4QB66NGFZ6RZ";

std::string Network::httpGetRequest(std::string httpquery) {
  using boost::asio::ip::tcp;
  std::string server_answer;

  try {
    // Initialize the ASIO service.
    boost::asio::io_service io_service;
    std::string hostAddress = Network::hostName;
    if (Network::hostPort.compare("80") != 0) {
      // Add ":port" if port number is something other than 80
      hostAddress += (":" + Network::hostPort);
    }

    // Get a list of endpoints corresponding to the server name.
    tcp::resolver resolver(io_service);
    tcp::resolver::query query(Network::hostName, Network::hostPort);
    tcp::resolver::iterator endpoint_iterator = resolver.resolve(query);

    // Try each endpoint until we successfully establish a connection.
    tcp::socket socket(io_service);
    boost::asio::connect(socket, endpoint_iterator);

    /**
     * Form the request. We specify the "Connection: close" header so that the
     * server will close the socket after transmitting the response.
     * This allows to treat all data up until the EOF as the content.
     */
    boost::asio::streambuf request;
    std::ostream request_stream(&request);
    request_stream << "GET " << httpquery << " HTTP/1.1\r\n";
    request_stream << "Host: " << hostAddress << "\r\n";
    request_stream << "Accept: */*\r\n";
    request_stream << "Connection: close\r\n\r\n";

    // Send the request.
    boost::asio::write(socket, request);

    /**
     * Read the response status line. The response streambuf will automatically
     * grow to accommodate the entire line. The growth may be limited by passing
     * a maximum size to the streambuf constructor.
     */
    boost::asio::streambuf response;
    boost::asio::read_until(socket, response, "\r\n");

    // Check that response is OK.
    std::istream response_stream(&response);
    std::string http_version;
    response_stream >> http_version;
    unsigned int status_code;
    response_stream >> status_code;
    std::string status_message;
    std::getline(response_stream, status_message);
    if (!response_stream || http_version.substr(0, 5) != "HTTP/") {
      std::cout << "Invalid response\n";
      return "";
    }
    if (status_code != 200) {
      std::cout << "Response returned with status code " << status_code << "\n";
      return "";
    }

    // Read the response headers, which are terminated by a blank line.
    boost::asio::read_until(socket, response, "\r\n\r\n");

    // Process the response headers.
    std::string header;
    while (std::getline(response_stream, header) && header != "\r") {}

    // Write whatever content we already have to output.
    if (response.size() > 0) {
      std::stringstream answer_buffer;
      answer_buffer << &response;
      server_answer = answer_buffer.str();
    }

    // Read until EOF, writing data to output as we go.
    boost::system::error_code error;
    while (boost::asio::read(socket, response,boost::asio::transfer_at_least(1), error)) {
      std::cout << &response;
    }
    if (error != boost::asio::error::eof) {
      throw boost::system::system_error(error);
    }
  } catch (std::exception& e) {
    std::cout << "Exception: " << e.what() << "\n";
    return "";
  }

  return server_answer;
}

std::string Network::getETHBalance(std::string address) {
  std::stringstream query;
  query << "/api?module=account&action=balance"
        << "&address=" << address
        << "&tag=latest&apikey=" << apiKey;
  return Network::httpGetRequest(query.str());
}

std::string Network::getTAEXBalance(std::string address) {
  std::stringstream query;
  query << "/api?module=account&action=tokenbalance"
        << "&contractaddress=0x9c19d746472978750778f334b262de532d9a85f9"
        << "&address=" << address
        << "&tag=latest&apikey=" << apiKey;
  return Network::httpGetRequest(query.str());
}

std::string Network::getTxFees() {
  std::stringstream query;
  query << "/api?module=gastracker&action=gasoracle&apikey=" << apiKey;
  return Network::httpGetRequest(query.str());
}

std::string Network::getTxNonce(std::string address) {
  std::stringstream query;
  query << "/api?module=proxy&action=eth_getTransactionCount"
        << "&address=" << address
        << "&tag=latest&apikey=" << apiKey;
  return Network::httpGetRequest(query.str());
}

std::string Network::broadcastTransaction(std::string txidHex) {
  std::stringstream query;
  query << "/api?module=proxy&action=eth_sendRawTransaction"
        << "&hex=" << txidHex
        << "&apikey=" << apiKey;
  return Network::httpGetRequest(query.str());
}

