// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

QRegExp QmlSystem::createTxRegExp(int decimals) {
  QRegExp rx;
  rx.setPattern("[0-9]{1,99}(?:\\.[0-9]{1," + QString::number(decimals) + "})?");
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
    QString gasPrice, QString pass, QString txNonce
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
    emit txBuilt(txSkel.nonce != Utils::MAX_U256_VALUE());

    // Sign the transaction
    bool signSuccess;
    std::string msg;
    std::string signedTx;
    if (QmlSystem::getLedgerFlag()) {
      std::pair<bool, std::string> signStatus;
      emit ledgerRequired();
      signStatus = this->ledgerDevice.signTransaction(
        txSkel, this->getCurrentHardwareAccountPath().toStdString()
      );
      emit ledgerDone();
      signSuccess = signStatus.first;
      signedTx = (signSuccess) ? signStatus.second : "";
      msg = (signSuccess) ? "Transaction signed!" : signStatus.second;
    } else {
      signedTx = this->w.signTransaction(txSkel, passStr);
      signSuccess = !signedTx.empty();
      msg = (signSuccess) ? "Transaction signed!" : "Error on signing transaction.";
    }
    emit txSigned(signSuccess, QString::fromStdString(msg));

    // Send the transaction
    std::cout << "Signed tx: " << signedTx << std::endl;
    json transactionResult = json::parse(this->w.sendTransaction(signedTx, operationStr));
    std::cout << "Dump from answer" << transactionResult.dump() << std::endl;
    msg = "";
    if (!transactionResult.contains("result")) {
      // Error when trying to transmit a transaction
      msg = transactionResult["error"]["message"];
      emit txSent(false, "", "", QString::fromStdString(msg));
    } else {
      std::string txLink = std::string("https://cchain.explorer.avax.network/tx/") + transactionResult["result"].get<std::string>();
      emit txSent(true, QString::fromStdString(txLink), QString::fromStdString(transactionResult["result"]), QString::fromStdString(msg));
    }
    // Confirming the transaction should happen OUTSIDE this function!
  });
}

void QmlSystem::checkTransactionFor15s(QString txid) {
  QtConcurrent::run([=](){
    // Request current block and current transaction status for around 15 seconds
    const auto p1 = std::chrono::system_clock::now();
    uint64_t startTime = std::chrono::duration_cast<std::chrono::seconds>(p1.time_since_epoch()).count();
    // Build the request data outside of the loop to avoid unecessary computing
    std::vector<Request> reqs;
    // Current block
    reqs.push_back({1, "2.0", "eth_blockNumber", {}});
    // Transaction Data.
    reqs.push_back({2, "2.0", "eth_getTransactionReceipt", {txid.toStdString()}});
    while (true) { // Use "break" to exit the function
      const auto p2 = std::chrono::system_clock::now();
      uint64_t currentTime =  std::chrono::duration_cast<std::chrono::seconds>(p1.time_since_epoch()).count();
      if ((startTime + 15) > currentTime) {
        emit txConfirmed(false, txid);
        break;
      }

      std::string query = API::buildMultiRequest(reqs);
      json resultArr = json::parse(API::httpGetRequest(query));
      std::string currentBlockStr;
      std::string txidBlockStr;
      // Loop around the result as the RPC can answer unorganized.
      for (auto result : resultArr) {
        if (result["id"] == 1) {
          currentBlockStr = result["result"];
        } else if (result["id"] == 2) {
          // Avoid erroring out due to no transaction found on mempool
          if (result.contains("result")) {
            if (result.contains("blockNumber")) {
              txidBlockStr = result["result"]["blockNumber"];
            }
          }
        }
      }
      // Check if transaction was included in a block, a.k.a confirmed
      u256 txidBlock = boost::lexical_cast<HexTo<u256>>(txidBlockStr);
      u256 currentBlock = boost::lexical_cast<HexTo<u256>>(currentBlockStr);
      if (txidBlock > currentBlock) {
        emit txConfirmed(true, txid);
      }  
    }
  });
}
