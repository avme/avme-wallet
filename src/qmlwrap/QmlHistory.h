// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef QMLHISTORY_H
#define QMLHISTORY_H

#include <QtConcurrent/qtconcurrentrun.h>
#include <QtCore/QString>
#include <QtCore/QVariant>

#include <qmlwrap/QmlSystem.h>

/**
 * Wrappers for the History screen.
 */
class QmlHistory : public QObject {
  Q_OBJECT

  signals:
    void historyLoaded(QVariantList data);

  public:
    // List the Account's transactions, updating their statuses on the spot if required
    Q_INVOKABLE void listAccountTransactions(QString address) {
      QtConcurrent::run([=](){
        QVariantList ret;
        QmlSystem::getWallet()->updateAllTxStatus();
        QmlSystem::getWallet()->loadTxHistory();
        for (TxData tx : QmlSystem::getWallet()->getCurrentAccountHistory()) {
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

    // Update the statuses of all transactions in the list
    Q_INVOKABLE void updateTransactionStatus() {
      QmlSystem::getWallet()->updateAllTxStatus();
    }
};

#endif  //QMLHISTORY_H
