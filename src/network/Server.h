// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#ifndef SERVER_H
#define SERVER_H

#include <boost/beast/core.hpp>
#include <boost/beast/websocket.hpp>
#include <boost/asio/dispatch.hpp>
#include <boost/asio/strand.hpp>
#include <algorithm>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <memory>
#include <string>
#include <thread>
#include <vector>

class QmlSystem;  // https://stackoverflow.com/a/4964508

namespace beast = boost::beast;
namespace http = beast::http;
namespace websocket = beast::websocket;
namespace net = boost::asio;
using tcp = boost::asio::ip::tcp;

// Websocket async server, adapted from Boost docs:
// https://www.boost.org/doc/libs/1_76_0/libs/beast/example/websocket/server/async/websocket_server_async.cpp
// TODO: rework comments

class Server {
  // Handles all received WebSocket messages.
  class session : public std::enable_shared_from_this<session> {
    websocket::stream<beast::tcp_stream> ws_;
    beast::flat_buffer buffer_;

    public:
      // Take ownership of the socket.
      explicit session(tcp::socket&& socket) : ws_(std::move(socket)) {}

      // Get on the correct executor.
      // We need to be executing within a strand to perform async operations
      // on the I/O objects in this session. Although not strictly necessary
      // for single-threaded contexts, this example code is written to be
      // thread-safe by default.
      void run();

      // Start the asynchronous operation.
      void on_run();

      // Read a message.
      void on_accept(beast::error_code ec);

      // Read a message into the buffer.
      void do_read();

      // Echo the message.
      void on_read(beast::error_code ec, std::size_t bytes_transferred);

      // Clear the buffer and do another read.
      void on_write(beast::error_code ec, std::size_t bytes_transferred);
  };

  // Accepts incoming connections and launches the sessions.
  class listener : public std::enable_shared_from_this<listener> {
    net::io_context& ioc_;
    tcp::acceptor acceptor_;

    public:
      // Constructor.
      listener(net::io_context& ioc, tcp::endpoint endpoint) : ioc_(ioc), acceptor_(ioc) {
        beast::error_code ec;
        acceptor_.open(endpoint.protocol(), ec);  // Open the acceptor
        if (ec) { fail(ec, "open"); return; }
        acceptor_.set_option(net::socket_base::reuse_address(true), ec); // Allow address reuse
        if (ec) { fail(ec, "set_option"); return; }
        acceptor_.bind(endpoint, ec); // Bind to the server address
        if (ec) { fail(ec, "bind"); return; }
        acceptor_.listen(net::socket_base::max_listen_connections, ec); // Start listening
        if (ec) { fail(ec, "listen"); return; }
      }

      // Start/stop accepting incoming connections/ respectively.
      void run();
      void stop();

    private:
      // Handle connection acception.
      void do_accept();

      // Create and run the session, then accept another connection
      void on_accept(beast::error_code ec, tcp::socket socket);
  };

  private:
    std::shared_ptr<listener> ls;
    QmlSystem* sys;

  public:
    // Create and launch a listening port, and run the I/O service.
    // The io_context is required for all I/O.
    void start();

    // Stop the listening port and the I/O device.
    void stop();

    // Set a pointer to the QmlSystem object.
    void setQmlSystem(QmlSystem* sys);

    // Report a failure.
    static void fail(beast::error_code ec, char const* what);
};

#endif  // SERVER_H

