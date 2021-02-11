#include "network.h"

// TODO: find a way to toggle between testnet and mainnet later
std::string Network::hostName = "api-ropsten.etherscan.io";
std::string Network::hostPort = "443";
std::string Network::apiKey = "6342MIVP4CD1ZFDN3HEZZG4QB66NGFZ6RZ";

std::string Network::httpGetRequest(std::string target)
{
	std::string result = "";
	using tcp = boost::asio::ip::tcp;       // from <boost/asio/ip/tcp.hpp>
	namespace ssl = boost::asio::ssl;       // from <boost/asio/ssl.hpp>
	namespace http = boost::beast::http;    // from <boost/beast/http.hpp>
    try
    {
        std::string host = Network::hostName;
        std::string port = Network::hostPort;

        boost::asio::io_context ioc;

        // Load certificates into context
        ssl::context ctx{ssl::context::sslv23_client};
        load_root_certificates(ctx);

        tcp::resolver resolver{ioc};
        ssl::stream<tcp::socket> stream{ioc, ctx};

        // Set SNI Hostname (many hosts need this to handshake successfully)
        if(! SSL_set_tlsext_host_name(stream.native_handle(), host.c_str()))
        {
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
		/*
		req.set(http::field::content_type, "application/json");
		req.body() = "{\"jsonrpc\": \"2.0\",\"method\": \"eth_getBalance\",\"params\": [\"0x8cB085C40D8342A30F1005bC79D1C08D2D09a976\",\"latest\"],\"id\": 1}";*/
		req.prepare_payload();
		
        // Send the HTTP request to the remote host
        http::write(stream, req);
        boost::beast::flat_buffer buffer;

        // Declare a container to hold the response
        http::response<http::dynamic_body> res;

        // Receive the HTTP response
        http::read(stream, buffer, res);

	// Write to output only body answer
		std::string body { boost::asio::buffers_begin(res.body().data()),boost::asio::buffers_end(res.body().data()) };
		result = body;

        boost::system::error_code ec;
        stream.shutdown(ec);
		
		// SSL Connections return stream_truncated when closed
		// For that reason, we need to exclude this issue as an error.
        if(ec == boost::asio::error::eof || boost::asio::ssl::error::stream_truncated)
        {
            ec.assign(0, ec.category());
        }
        if(ec) 
            throw boost::system::system_error{ec};
    }
    catch(std::exception const& e)
    {
        std::cerr << "Error: " << e.what() << std::endl;
        return "";
    }
    return result;
}

std::string Network::getETHBalance(std::string address) {
  std::stringstream query;
  query << "/api?module=account&action=balance"
        << "&address=" << address
        << "&tag=latest&apikey=" << apiKey;
  return httpGetRequest(query.str());
}

std::string Network::getETHBalances(std::vector<std::string> addresses) {
  std::stringstream query;
  std::vector<std::string> ret;
  int ct = 0;

  for (std::string address : addresses) {
    // Start a new query
    if (ct == 0) {
      query << "/api?module=account&action=balancemulti&address=";
    }

    // Add the address and count it towards the batch limit
    query << address;
    ct++;

    // When we reach the batch limit, wrap it up and send the request
    if (ct == 20 || address == addresses.back()) {
      query << "&tag=latest&apikey=" << apiKey;
    } else {
      query << ","; // Separate addresses with a comma
    }
  }

  return httpGetRequest(query.str());
}

std::string Network::getTAEXBalance(std::string address) {
  std::stringstream query;
  query << "/api?module=account&action=tokenbalance"
        << "&contractaddress=0x9c19d746472978750778f334b262de532d9a85f9"
        << "&address=" << address
        << "&tag=latest&apikey=" << apiKey;
  return httpGetRequest(query.str());
}

std::string Network::getTxFees() {
  std::stringstream query;
  query << "/api?module=gastracker&action=gasoracle&apikey=" << apiKey;
  return httpGetRequest(query.str());
}

std::string Network::getTxNonce(std::string address) {
  std::stringstream query;
  query << "/api?module=proxy&action=eth_getTransactionCount"
        << "&address=" << address
        << "&tag=latest&apikey=" << apiKey;
  return httpGetRequest(query.str());
}

std::string Network::broadcastTransaction(std::string txidHex) {
  std::stringstream query;
  query << "/api?module=proxy&action=eth_sendRawTransaction"
        << "&hex=" << txidHex
        << "&apikey=" << apiKey;
  return httpGetRequest(query.str());
}

