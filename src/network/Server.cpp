// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include "Server.h"

#include <qmlwrap/QmlSystem.h> // https://stackoverflow.com/a/4964508


void session::run() {
  net::dispatch(ws_.get_executor(), beast::bind_front_handler(
    &session::on_run, shared_from_this()
  ));
}

void session::close() {
  m_lock.lock();
  if (ws_.is_open()) { // Check if it is even open before closing
    ws_.async_close(websocket::close_code::normal,beast::bind_front_handler(&session::on_closed, shared_from_this()));
  }
  m_lock.unlock();
}

void session::on_closed(beast::error_code ec) {
  if (ec) { return Server::fail(ec, "close"); }
  m_lock.unlock();
}

void session::on_run() {
  // Set suggested timeout settings for the websocket
  ws_.set_option(websocket::stream_base::timeout::suggested(beast::role_type::server));

  // Set a decorator to change the Server of the handshake
  ws_.set_option(websocket::stream_base::decorator([](websocket::response_type& res){
    res.set(http::field::server, std::string(BOOST_BEAST_VERSION_STRING) + " websocket-server-async");
  }));

  // Insert the session to the list of sessions.
  sessions_->insert(shared_from_this());
  // Accept the websocket handshake
  ws_.async_accept(beast::bind_front_handler(&session::on_accept, shared_from_this()));
}

void session::on_accept(beast::error_code ec) {
  if (ec) { return Server::fail(ec, "accept"); }
  do_read();
}

void session::do_read() {
  ws_.async_read(buffer_, beast::bind_front_handler(&session::on_read, shared_from_this()));
}

void session::on_read(beast::error_code ec, std::size_t bytes_transferred) {
  boost::ignore_unused(bytes_transferred);
  if (ec == websocket::error::closed) { return; } // This indicates the session was closed
  if (ec.value() == 125) { return; } // Operation cancelled
  if (ec) { Server::fail(ec, "read"); }
  ws_.text(ws_.got_text()); // TODO: handle user input with QmlSystem::handleServer() here
  // Send the message for another thread to parse it.
  sys_->handleServer(boost::beast::buffers_to_string(buffer_.data()), shared_from_this());
  buffer_.consume(buffer_.size());
  do_read();
}

void session::do_write(std::string response) {
  m_lock.lock();
  if (ws_.is_open()) { // Check if the stream is open, before commiting to it.
    beast::flat_buffer answerBuffer_;
    // Copy string to buffer
    answerBuffer_.consume(answerBuffer_.size());
    size_t n = boost::asio::buffer_copy(answerBuffer_.prepare(response.size()), boost::asio::buffer(response));
    answerBuffer_.commit(n);
    // Write to the socket
    ws_.async_write(answerBuffer_.data(), beast::bind_front_handler(
      &session::on_write, shared_from_this()
    ));
  }
  m_lock.unlock();
}

void session::on_write(beast::error_code ec, std::size_t bytes_transferred) {
  boost::ignore_unused(bytes_transferred);
  if (ec) { return Server::fail(ec, "write"); }
}

void Server::listener::run() { 
  // Insert itself on the list
  listeners_->insert(shared_from_this());
  do_accept(); 
}

void Server::listener::do_accept() {
  // The new connection gets its own strand
  acceptor_.async_accept(net::make_strand(ioc_), beast::bind_front_handler(
    &listener::on_accept, shared_from_this()
  ));
}

void Server::listener::on_accept(beast::error_code ec, tcp::socket socket) {
  m_lock.lock();
  if (ec) {
    if (ec.value() == 125) { return; } // Operation cancelled
    fail(ec, "accept");
  } else {
    std::make_shared<session>(std::move(socket),sessions_,sys_)->run();
  }
  m_lock.unlock();
  do_accept();
}

void Server::listener::stop() {
  m_lock.lock();
  acceptor_.cancel(); // Cancel the acceptor.
  acceptor_.close(); // Close the acceptor.
  m_lock.unlock();
}

void Server::start() {
  auto const address = boost::asio::ip::make_address("127.0.0.1");
  auto const port = static_cast<unsigned short>(std::atoi("1248"));
  auto const threads = 1;
  // Restart is needed in order to .run() the ioc again. otherwise .run() will return instantly.
  ioc.restart();
  std::make_shared<listener>(ioc, tcp::endpoint{address, port}, &sessions_, &listeners_, sys_)->run();
  std::vector<std::thread> v;
  v.reserve(threads - 1);
  for (auto i = threads - 1; i > 0; --i) { v.emplace_back([this]{ ioc.run(); }); }
  ioc.run();
}

void Server::stop() { 
  for (auto session_ : sessions_) {
    // Send a post message to the thread running the session.
    // Telling it to close
    // We need to bind_front_handler to the actual object running inside the thread.
    net::post(
          session_->ws_.get_executor(),
          beast::bind_front_handler(
              &session::close,
              session_));
  }
  // Clear session list
  sessions_.clear();
  // After closing the sessions, you can succesfully close the listeners
  for (auto listener_ : listeners_) {
    // Same as above, but for the listener
    net::post(
          listener_->acceptor_.get_executor(),
          beast::bind_front_handler(
            &listener::stop,
            listener_));
  }
  // Clear listener list
  listeners_.clear();
  // Restart is needed in order to .run() the ioc again in the future.
  ioc.stop();
  ioc.restart();
}

void Server::setQmlSystem(QmlSystem* sys) { this->sys_ = sys; }

void Server::fail(beast::error_code ec, char const* what) {
  std::cerr << what << ": " << ec.message() << ec.value() << "\n";
}
