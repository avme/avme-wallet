// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

void QmlSystem::listAccountTransactions(QString address) {
  QtConcurrent::run([=](){
    QVariantList ret;
    this->w.updateAllTxStatus();
    this->w.loadTxHistory();
    for (TxData tx : this->w.getCurrentAccountHistory()) {
      std::string obj;
      obj += "{\"txlink\": \"" + tx.txlink;
      obj += "\", \"operation\": \"" + tx.operation;
      obj += "\", \"txdata\": \"" + tx.data;
      obj += "\", \"from\": \"" + tx.from;
      obj += "\", \"to\": \"" + tx.to;
      obj += "\", \"value\": \"" + tx.value;
      obj += "\", \"gas\": \"" + tx.gas;
      obj += "\", \"price\": \"" + tx.price;
      obj += "\", \"datetime\": \"" + tx.humanDate;
      obj += "\", \"unixtime\": " + std::to_string(tx.unixDate);
      obj += ", \"confirmed\": " + QVariant(tx.confirmed).toString().toStdString();
      obj += ", \"invalid\": " + QVariant(tx.invalid).toString().toStdString();
      obj += "}";
      ret << QString::fromStdString(obj);
    }
    emit historyLoaded(ret);
  });
}

void QmlSystem::updateTransactionStatus() {
  this->w.updateAllTxStatus();
}
