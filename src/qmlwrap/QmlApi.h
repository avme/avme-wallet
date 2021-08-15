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
    std::map<QString, std::vector<Request>> requestList;
    std::mutex requestListLock;

  signals:
    /**
     * When calling a function on Qt without a signal or other multithreading
     * teechnique, it causes the GUI interface to freeze.
     * So we have to use signals to prevent that and filter the requests
     * appropriately through QML to avoid writing in the wrong places.
     */
    void apiRequestAnswered(QString answer, QString requestID);

    // The same goes for graph requests.
    void tokenPriceHistoryAnswered(QString answer, QString requestID, int days);

  public:
    /**
     * Call every request under requestList in a single connection.
     * Automatically clears the requestList when done.
     */
    Q_INVOKABLE void doAPIRequests(QString requestID);

    /**
     * Manually clear the requestList if necessary.
     */
    Q_INVOKABLE void clearAPIRequests(QString requestID);

    /**
     * Parse a given hex string according to the values given.
     * Accepted values are: uint, bool, address.
     */
    Q_INVOKABLE QStringList parseHex(QString hexStr, QStringList types);

    /**
     * Build requests for getting the AVAX and a given token's balance, respectively.
     */
    Q_INVOKABLE void buildGetBalanceReq(QString address, QString requestID);
    Q_INVOKABLE void buildGetTokenBalanceReq(QString contract, QString address, QString requestID);

    /**
     * Build request for getting the current block number.
     */
    Q_INVOKABLE void buildGetCurrentBlockNumberReq(QString requestID);

    /**
     * Build request for getting the receipt (details) of a transaction.
     * e.g. blockNumber, status, etc.
     */
    Q_INVOKABLE void buildGetTxReceiptReq(std::string txidHex, QString requestID);

    /**
     * Build request for getting the estimated gas limit.
     * requires JSON:
     * {
     *  from: ADDRESS
     *  to: ADDRESS
     *  gas: HEX_INT
     *  gasPrice: HEX_INT
     *  value: HEX_INT
     *  data: ETH_CALL
     * }
     */

    Q_INVOKABLE void buildGetEstimateGasLimitReq(QString jsonStr, QString requestID);

    /**
     * Build request for querying if an ARC20 token exists.
     */
    Q_INVOKABLE void buildARC20TokenExistsReq(std::string address, QString requestID);

    /**
     * Get an ARC20 token's data.
     */
    Q_INVOKABLE void buildGetARC20TokenDataReq(std::string address, QString requestID);

    /**
     * Get the fiat price history of the last X days for a given ARC20 token.
     */
    Q_INVOKABLE void getTokenPriceHistory(QString address, int days, QString requestID);

    /**
     * Build request for getting the allowance amount between owner and spender
     * addresses in the given receiver address.
     */
    Q_INVOKABLE void buildGetAllowanceReq(QString receiver, QString owner, QString spender, QString requestID);

    /**
     * Build request for getting the pair address for two given assets.
     */
    Q_INVOKABLE void buildGetPairReq(QString assetAddress1, QString assetAddress2, QString requestID);

    /**
     * Build request for getting the reserves for the given pair address.
     */
    Q_INVOKABLE void buildGetReservesReq(QString pairAddress, QString requestID);

    /**
     * Functions for appending custom ABI calls.
     */
    Q_INVOKABLE void buildCustomEthCallReq(QString contract, QString ABI, QString requestID);
    Q_INVOKABLE QString buildCustomABI(QString input);

    /**
     * Wrappers for utils functions
     */
    Q_INVOKABLE QString weiToFixedPoint(QString amount, int digits);
    Q_INVOKABLE QString fixedPointToWei(QString amount, int decimals);
    Q_INVOKABLE QString uintToHex(QString input);
    Q_INVOKABLE QString uintFromHex(QString hex);
    Q_INVOKABLE QString MAX_U256_VALUE();
    Q_INVOKABLE QString getCurrentUnixTime();
};

#endif // QMLAPI_H
