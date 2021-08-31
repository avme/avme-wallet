// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

void QmlSystem::listAccountTransactions(QString address) {
  QtConcurrent::run([=](){
    json ret = json::array();
    this->w.updateAllTxStatus();
    this->w.loadTxHistory();
    
    for (TxData tx : this->w.getCurrentAccountHistory()) {
      json obj;
      obj["txlink"] = tx.txlink;
      obj["operation"] = tx.operation;
      obj["txdata"] = tx.data;
      obj["from"] = tx.from;
      obj["to"] = tx.to;
      obj["value"] = tx.value;
      obj["gas"] = tx.gas;
      obj["price"] = tx.price;
      obj["datetime"] = tx.humanDate;
      obj["unixtime"] = std::to_string(tx.unixDate);
      obj["confirmed"] = tx.confirmed;
      obj["invalid"] = tx.invalid;
      ret.push_back(obj);
    }
    emit historyLoaded(QString::fromStdString(ret.dump()));
  });
}

