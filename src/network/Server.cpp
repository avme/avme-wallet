// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include "Server.h"

void Server::session::run() {
  net::dispatch(ws_.get_executor(), beast::bind_front_handler(
    &session::on_run, shared_from_this()
  ));
}

void Server::session::on_run() {
  // Set suggested timeout settings for the websocket
  ws_.set_option(websocket::stream_base::timeout::suggested(beast::role_type::server));

  // Set a decorator to change the Server of the handshake
  ws_.set_option(websocket::stream_base::decorator([](websocket::response_type& res){
    res.set(http::field::server, std::string(BOOST_BEAST_VERSION_STRING) + " websocket-server-async");
  }));

  // Accept the websocket handshake
  ws_.async_accept(beast::bind_front_handler(&session::on_accept, shared_from_this()));
}

void Server::session::on_accept(beast::error_code ec) {
  if (ec) { return fail(ec, "accept"); }
  do_read();
}

void Server::session::do_read() {
  ws_.async_read(buffer_, beast::bind_front_handler(&session::on_read, shared_from_this()));
}

void Server::session::on_read(beast::error_code ec, std::size_t bytes_transferred) {
  boost::ignore_unused(bytes_transferred);
  if (ec == websocket::error::closed) { return; } // This indicates the session was closed
  if (ec) { fail(ec, "read"); }
  ws_.text(ws_.got_text()); // TODO: handle user input with QmlSystem::handleServer() here
  ws_.async_write(buffer_.data(), beast::bind_front_handler(
    &session::on_write, shared_from_this()
  ));
}

void Server::session::on_write(beast::error_code ec, std::size_t bytes_transferred) {
  boost::ignore_unused(bytes_transferred);
  if (ec) { return fail(ec, "write"); }
  buffer_.consume(buffer_.size());
  do_read();
}

void Server::listener::run() { do_accept(); }
void Server::listener::stop() { ioc_.stop(); }

void Server::listener::do_accept() {
  // The new connection gets its own strand
  acceptor_.async_accept(net::make_strand(ioc_), beast::bind_front_handler(
    &listener::on_accept, shared_from_this()
  ));
}

void Server::listener::on_accept(beast::error_code ec, tcp::socket socket) {
  if (ec) {
    fail(ec, "accept");
  } else {
    std::make_shared<session>(std::move(socket))->run();
  }
  do_accept();
}

void Server::start() {
  auto const address = boost::asio::ip::make_address("127.0.0.1");
  auto const port = static_cast<unsigned short>(std::atoi("1248"));
  auto const threads = 1;
  net::io_context ioc{threads};
  ls = std::make_shared<listener>(ioc, tcp::endpoint{address, port});
  ls->run();
  std::vector<std::thread> v;
  v.reserve(threads - 1);
  for (auto i = threads - 1; i > 0; --i) { v.emplace_back([&ioc]{ ioc.run(); }); }
  ioc.run();
}

void Server::stop() { ls->stop(); }

void Server::setQmlSystem(QmlSystem* sys) { this->sys = sys; }

void Server::fail(beast::error_code ec, char const* what) {
  std::cerr << what << ": " << ec.message() << "\n";
}

