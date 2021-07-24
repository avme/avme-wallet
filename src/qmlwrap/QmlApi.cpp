#include "QmlApi.h"

Q_INVOKABLE QString QmlApi::doAPIRequests() {
    std::string requests = API::buildMultiRequest(this->requestList);
    return QString::fromStdString(API::httpGetRequest(requests));
}

Q_INVOKABLE void QmlApi::buildBlockNumberReq() {
    Request req{this->requestList.size() + size_t(1), "2.0", "eth_blockNumber", {}};
    this->requestList.push_back(req);
    return;
}

Q_INVOKABLE void QmlApi::buildCustomEthCallReq(QString contract, QString ABI) {
    Request req{this->requestList.size() + size_t(1), "2.0", "eth_getBalance", {std::string("\"to:\"") + contract.toStdString(),
     std::string("\",\"data\":") + ABI.toStdString() + "\""}};
    this->requestList.push_back(req);
    return;
}

Q_INVOKABLE void QmlApi::buildGetTokenBalanceReq(QString contract, QString address) {
    Request req{this->requestList.size() + size_t(1), "2.0", "eth_getBalance", {std::string("\"to:\"") + contract.toStdString(), 
    std::string("\",\"data\": \"0x70a08231000000000000000000000000") + address.toStdString() + "\""}};
    this->requestList.push_back(req);
}

Q_INVOKABLE QString QmlApi::buildCustomABI(QString input) {
    return QString::fromStdString(ABI::encodeABIfromJson(input.toStdString()));
}