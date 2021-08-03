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
#include <network/Graph.h>
#include <core/BIP39.h>
#include <core/ABI.h>
#include <core/Utils.h>
#include <core/Wallet.h>
#include <lib/nlohmann_json/json.hpp>

class QmlApi : public QObject {
  Q_OBJECT

  private:
    std::vector<Request> requestList;

  public:
    /**
     * Call every request under requestList in a single connection.
     * Automatically clears the requestList when done.
     */
    Q_INVOKABLE QString doAPIRequests();

    /**
     * Manually clear the requestList if necessary.
     */
    Q_INVOKABLE void clearAPIRequests();

    /**
     * Parse a given hex string according to the values given.
     * Accepted values are: uint, bool, address.
     */
    Q_INVOKABLE QStringList parseHex(QString hexStr, QStringList types);

    /**
     * Build requests for getting the AVAX and a given token's balance, respectively.
     */
    Q_INVOKABLE void buildGetBalanceReq(QString address);
    Q_INVOKABLE void buildGetTokenBalanceReq(QString contract, QString address);

    /**
     * Build request for getting the current block number.
     */
    Q_INVOKABLE void buildGetCurrentBlockNumberReq();

    /**
     * Build request for getting the receipt (details) of a transaction.
     * e.g. blockNumber, status, etc.
     */
    Q_INVOKABLE void buildGetTxReceiptReq(std::string txidHex);

    /**
     * Build request for getting the estimated gas limit.
     */
    Q_INVOKABLE void buildGetEstimateGasLimitReq();

    /**
     * Build request for querying if an ARC20 token exists.
     */
    Q_INVOKABLE void buildARC20TokenExistsReq(std::string address);

    /**
     * Get an ARC20 token's data.
     */
    Q_INVOKABLE void buildGetARC20TokenDataReq(std::string address);

    /**
     * Get the fiat price history of the last X days for a given ARC20 token.
     */
    Q_INVOKABLE QString getTokenPriceHistory(QString address, int days);

    /**
     * Get the allowance amount between owner and spender addresses
     * in the given receiver address.
     */
    Q_INVOKABLE void buildGetAllowanceReq(QString receiver, QString owner, QString spender);

    /**
     * Functions for appending custom ABI calls.
     */
    Q_INVOKABLE void buildCustomEthCallReq(QString contract, QString ABI);
    Q_INVOKABLE QString buildCustomABI(QString input);
};

#endif // QMLAPI_H
