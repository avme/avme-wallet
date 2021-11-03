// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

QRegExp QmlSystem::createTxRegExp(int decimals) {
  QRegExp rx;
  rx.setPattern("(?:[0-9]{1,})?(?:\\.[0-9]{1," + QString::number(decimals) + "})?");
  return rx;
}

QString QmlSystem::getRealMaxAVAXAmount(
  QString totalBalance, QString gasLimit, QString gasPrice
) {
  // Gas limit is in Wei, gas price is in Gwei (10^9 Wei)
  std::string gasLimitStr = gasLimit.toStdString();
  std::string gasPriceStr = Utils::fixedPointToWei(gasPrice.toStdString(), 9);
  u256 gasLimitU256 = u256(gasLimitStr);
  u256 gasPriceU256 = u256(gasPriceStr);

  u256 totalU256 = u256(Utils::fixedPointToWei(totalBalance.toStdString(), 18));
  if ((gasLimitU256 * gasPriceU256) > totalU256) {
    return QString::fromStdString(Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(u256(0)), 18
    ));
  }
  totalU256 -= (gasLimitU256 * gasPriceU256);
  std::string totalStr = Utils::weiToFixedPoint(
    boost::lexical_cast<std::string>(totalU256), 18
  );
  return QString::fromStdString(totalStr);
}

Q_INVOKABLE QString QmlSystem::calculateTransactionCost(
  QString amount, QString gasLimit, QString gasPrice
) {
  // Amount is in fixed point (10^18 Wei), gas limit is in Wei, gas price is in Gwei (10^9 Wei)
  std::string amountStr = Utils::fixedPointToWei(amount.toStdString(), 18);
  std::string gasLimitStr = gasLimit.toStdString();
  std::string gasPriceStr = Utils::fixedPointToWei(gasPrice.toStdString(), 9);
  u256 amountU256 = u256(amountStr);
  u256 gasLimitU256 = u256(gasLimitStr);
  u256 gasPriceU256 = u256(gasPriceStr);
  u256 totalU256 = amountU256 + (gasLimitU256 * gasPriceU256);
  // Uncomment to see the values in Wei
  //std::cout << "Total: " << totalU256 << std::endl;
  //std::cout << "Amount: " << amountU256 << std::endl;
  //std::cout << "Gas Limit: " << gasLimitU256 << std::endl;
  //std::cout << "Gas Price: " << gasPriceU256 << std::endl;
  std::string totalStr = Utils::weiToFixedPoint(
    boost::lexical_cast<std::string>(totalU256), 18
  );
  return QString::fromStdString(totalStr);
}

bool QmlSystem::hasInsufficientFunds(
  QString senderAmount, QString receiverAmount, int decimals
) {
  std::string senderStr, receiverStr;
  u256 senderU256, receiverU256;
  senderStr = Utils::fixedPointToWei(senderAmount.toStdString(), decimals);
  receiverStr = Utils::fixedPointToWei(receiverAmount.toStdString(), decimals);
  senderU256 = u256(senderStr);
  receiverU256 = u256(receiverStr);
  return (receiverU256 > senderU256);
}

void QmlSystem::updateAccountNonce(QString from) {
  QtConcurrent::run([=](){
    std::string ret;
    std::string nonce = API::getNonce(from.toStdString());
    auto nonceParsed = Pangolin::parseHex(nonce, {"uint"});
    ret = nonceParsed[0];
    emit this->accountNonceUpdate(QString::fromStdString(ret));
  });
}

void QmlSystem::makeTransaction(
    QString operation, QString from, QString to,
    QString value, QString txData, QString gas,
    QString gasPrice, QString pass, QString txNonce, QString randomID
) {
  QtConcurrent::run([=](){
    // Convert everything to std::string for easier handling
    std::string operationStr = operation.toStdString();
    std::string fromStr = from.toStdString();
    std::string toStr = to.toStdString();
    std::string valueStr = value.toStdString();
    std::string txDataStr = txData.toStdString();
    std::string gasStr = gas.toStdString();
    std::string gasPriceStr = gasPrice.toStdString();
    std::string passStr = pass.toStdString();
    std::string txNonceStr = txNonce.toStdString();

    // Convert the values required for a transaction to their Wei formats.
    // Gas price is in Gwei (10^9 Wei) and amounts are in fixed point.
    // Gas limit is already in Wei so we skip that.
    valueStr = Utils::fixedPointToWei(valueStr, 18);
    gasPriceStr = boost::lexical_cast<std::string>(
      boost::lexical_cast<u256>(gasPriceStr) * raiseToPow(10, 9)
    );

    // Build the transaction and data hex according to the operation
    TransactionSkeleton txSkel;
    txSkel = w.buildTransaction(fromStr, toStr, valueStr, gasStr, gasPriceStr, txDataStr, txNonceStr);
    emit txBuilt(txSkel.nonce != Utils::MAX_U256_VALUE(), randomID);

    // Sign the transaction
    bool signSuccess;
    std::string msg;
    std::string signedTx;
    if (QmlSystem::getLedgerFlag()) {
      std::pair<bool, std::string> signStatus;
      emit ledgerRequired(randomID);
      signStatus = this->ledgerDevice.signTransaction(
        txSkel, this->getCurrentHardwareAccountPath().toStdString()
      );
      emit ledgerDone(randomID);
      signSuccess = signStatus.first;
      signedTx = (signSuccess) ? signStatus.second : "";
      msg = (signSuccess) ? "Transaction signed!" : signStatus.second;
    } else {
      signedTx = this->w.signTransaction(txSkel, passStr);
      signSuccess = !signedTx.empty();
      msg = (signSuccess) ? "Transaction signed!" : "Error on signing transaction.";
    }
    emit txSigned(signSuccess, QString::fromStdString(msg), randomID);

    // Send the transaction
    json transactionResult = this->w.sendTransaction(signedTx, operationStr);
    msg = "";
    if (!transactionResult.contains("result")) {
      // Error when trying to transmit a transaction
      msg = transactionResult["error"]["message"] .get<std::string>();
      emit txSent(false, "", "", QString::fromStdString(msg), randomID);
    } else {
      std::string txLink = std::string("https://snowtrace.io/tx/") + transactionResult["result"].get<std::string>();
      emit txSent(true, QString::fromStdString(txLink), QString::fromStdString(transactionResult["result"]), QString::fromStdString(msg), randomID);
    }
    // Confirming the transaction should happen OUTSIDE this function!
  });
}

void QmlSystem::checkTransactionFor15s(QString txid, QString randomID) {
  QtConcurrent::run([=](){
    // Request current block and current transaction status for around 15 seconds
    auto t_start = std::chrono::high_resolution_clock::now();
    // Build the request data outside of the loop to avoid unecessary computing
    Request transactionReceipt({1, "2.0", "eth_getTransactionReceipt", {txid.toStdString()}});
    while (true) { // Use "break" to exit the function
      auto t_end = std::chrono::high_resolution_clock::now();
      double elapsed_time_ms = std::chrono::duration<double, std::milli>(t_end-t_start).count();
      if (elapsed_time_ms > 15000) {
        emit txConfirmed(false, txid, randomID);
        break;
      }

      json result = json::parse(API::httpGetRequest(API::buildRequest(transactionReceipt)));
      //std::cout << result.dump(2) << std::endl;
      std::string status = "";

      // Check if transaction was included in a block, a.k.a confirmed
      if (result.contains("result")) {
        if (result["result"].contains("status")) {
          status = result["result"]["status"];
        }
      }
      if (status != "") {
        emit txConfirmed(true, txid, randomID);
        break;
      }
    }
  });
}
