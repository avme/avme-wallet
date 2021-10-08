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


    /**
     * Same as above, but for custom requests made by the DAPP developer to their own API
     */

    void customApiRequestAnswered(QString answer, QString requestID);

    // The same goes for graph requests.
    void tokenPriceHistoryAnswered(QString answer, QString requestID, int days);

  public:
    // ======================================================================
    // REQUEST BUILDERS
    // ======================================================================

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
     * Build requests for getting the AVAX and a given token's balance, respectively.
     */
    Q_INVOKABLE void buildGetBalanceReq(QString address, QString requestID);
    Q_INVOKABLE void buildGetTokenBalanceReq(QString tokenContract, QString address, QString requestID);

    /**
     * Build request for getting the total LP supply of a pair.
     */
    Q_INVOKABLE void buildGetTotalSupplyReq(QString pairAddress, QString requestID);

    /**
     * Build request for getting the current block number.
     */
    Q_INVOKABLE void buildGetCurrentBlockNumberReq(QString requestID);

    /**
     * Build request for getting the receipt (details) of a transaction.
     * e.g. blockNumber, status, etc.
     */
    Q_INVOKABLE void buildGetTxReceiptReq(QString txidHex, QString requestID);

    /**
     * Build request for getting the estimated gas limit.
     * Requires a JSON string formatted like this:
     * {
     *   from: ADDRESS
     *   to: ADDRESS
     *   gas: HEX_INT
     *   gasPrice: HEX_INT
     *   value: HEX_INT
     *   data: ETH_CALL
     * }
     */
    Q_INVOKABLE void buildGetEstimateGasLimitReq(QString jsonStr, QString requestID);

    /**
     * Build request for querying if an ARC20 token exists.
     */
    Q_INVOKABLE void buildARC20TokenExistsReq(QString address, QString requestID);

    /**
     * Build request for getting an ARC20 token's data.
     */
    Q_INVOKABLE void buildGetARC20TokenDataReq(QString address, QString requestID);

    /**
     * Build request for getting the allowance amount between owner and spender
     * addresses in the given receiver address.
     */
    Q_INVOKABLE void buildGetAllowanceReq(QString receiver, QString owner, QString spender, QString requestID);

    /**
     * Build request for getting the pair address for two given assets.
     */
    Q_INVOKABLE void buildGetPairReq(QString assetAddress1, QString assetAddress2, QString factoryContract, QString requestID);

    /**
     * Build request for getting the reserves for the given pair address.
     */
    Q_INVOKABLE void buildGetReservesReq(QString pairAddress, QString requestID);

    /**
     * Build custom eth_call request.
     */
    Q_INVOKABLE void buildCustomEthCallReq(QString contract, QString ABI, QString requestID);

    /**
     * Do a custom API request towards *any* API
     * reqBody      : the body of the HTTP request
     * host         : IP or DNS name of the target
     * port         : target Port
     * target       : target
     * requestType  : type of the HTTP request, AVAILABLE: "POST" OR "GET"
     * contentType  : body content type, normally "application/json"
     * requestID    : ID of the request which will be emitted later with the answer
     */
    Q_INVOKABLE void doCustomHttpRequest(QString reqBody, 
      QString host, QString port, QString target, 
      QString requestType, QString contentType, QString requestID
      );

    // ======================================================================
    // HELPER FUNCTIONS
    // ======================================================================

    /**
     * Parse a given ABI hex string according to the values given.
     * Accepted values from the ABI are:
     * * uint
     * * bool
     * * address
     */
    Q_INVOKABLE QStringList parseHex(QString hexStr, QStringList types);

    // Create a QRegExp based on the QString input

    Q_INVOKABLE QRegExp createRegExp(QString desiredRegex);

    // Get the first (lower) address from a pair.
    Q_INVOKABLE QString getFirstFromPair(QString assetAddressA, QString assetAddressB);

    // Get the fiat price history of the last X days for a given ARC20 token.
    Q_INVOKABLE void getTokenPriceHistory(QString address, int days, QString requestID);

    // Get image path for ARC20 token

    Q_INVOKABLE QString getARC20TokenImage(QString address);

    /**
     * Convert `input` to a custom ABI bytecode.
     * Returns the encoded ABI bytecode as a string.
     */
    Q_INVOKABLE QString buildCustomABI(QString input);

    // Wrappers for Utils functions.
    Q_INVOKABLE QString weiToFixedPoint(QString amount, int decimals);
    Q_INVOKABLE QString fixedPointToWei(QString amount, int decimals);
    Q_INVOKABLE QString uintToHex(QString input, bool isPadded = true);
    Q_INVOKABLE QString uintFromHex(QString hex);
    Q_INVOKABLE QString addressToHex(QString input);
    Q_INVOKABLE QString addressFromHex(QString hex);
    Q_INVOKABLE QString bytesToHex(QString input, bool isUint);
    Q_INVOKABLE QString bytesFromHex(QString hex);
    Q_INVOKABLE QString MAX_U256_VALUE();
    Q_INVOKABLE QString getCurrentUnixTime();
    Q_INVOKABLE void logToDebug(QString log) { Utils::logToDebug(log.toStdString()); };
    // Timers that are changeable by a user, in order to avoid
    // conflits when changing asset, requires a randomID
    Q_INVOKABLE QString getRandomID();

    /**
     * Math functions to avoid scientific notation using QML/JS.
     * Logic done using strings and bigfloat.
     */
    Q_INVOKABLE QString sum(QString a, QString b);
    Q_INVOKABLE QString sub(QString a, QString b);
    Q_INVOKABLE QString mul(QString a, QString b);
    Q_INVOKABLE QString div(QString a, QString b);
    Q_INVOKABLE QString round(QString a);
    Q_INVOKABLE QString floor(QString a);
    Q_INVOKABLE QString ceil(QString a);
};

#endif // QMLAPI_H
