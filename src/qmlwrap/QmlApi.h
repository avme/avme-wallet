// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef QMLAPI
#define QMLAPI

#include <QtConcurrent/qtconcurrentrun.h>
#include <QtCore/QFile>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QVariant>
#include <QtGui/QClipboard>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtWidgets/QApplication>

#include <network/API.h>
#include <core/BIP39.h>
#include <core/ABI.h>
#include <core/Utils.h>
#include <core/Wallet.h>
#include <lib/nlohmann_json/json.hpp>

// TODO: maybe a function that clears the requestList if something goes wrong?

class QmlApi : public QObject {
  Q_OBJECT

  private:
    std::vector<Request> requestList;

  public:
    /**
     * Call every request under requestList in a single connection.
     */
    Q_INVOKABLE QString doAPIRequests();

    /**
     * Functions that will append the respective call to the requestList vector.
     */
    Q_INVOKABLE void buildGetBalanceReq(QString address);
    Q_INVOKABLE void buildBlockNumberReq();
    Q_INVOKABLE void buildCustomEthCallReq(QString contract, QString ABI);
    Q_INVOKABLE void buildGetTokenBalanceReq(QString contract, QString address);
    Q_INVOKABLE QString buildCustomABI(QString input);
};

#endif // QMLAPI_H
