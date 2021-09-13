// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>
#include <network/Server.h> // https://stackoverflow.com/a/4964508


void QmlSystem::handleServer(std::string input, session *session_) {
  // Run answer in another thread to allow the Server to take more inputs
  QtConcurrent::run([=](){
    // TODO: treat input here
    session_->do_write(input);
  });
  return;
}

void QmlSystem::setWSServer() {
  this->s.setQmlSystem(this);
  return;
}

// Should run *inside* another thread, to avoid getting stuck at .run()
Q_INVOKABLE void QmlSystem::startWSServer() {
  QtConcurrent::run([=](){
    this->s.start();
  });
}


Q_INVOKABLE void QmlSystem::stopWSServer() {
  this->s.stop();
}