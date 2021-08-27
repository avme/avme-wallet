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

void QmlSystem::makeTransaction(
    QString operation, QString from, QString to,
    QString value, QString txData, QString gas,
    QString gasPrice, QString pass
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

    // Convert the values required for a transaction to their Wei formats.
    // Gas price is in Gwei (10^9 Wei) and amounts are in fixed point.
    // Gas limit is already in Wei so we skip that.
    valueStr = Utils::fixedPointToWei(valueStr, 18);
    gasPriceStr = boost::lexical_cast<std::string>(
      boost::lexical_cast<u256>(gasPriceStr) * raiseToPow(10, 9)
    );

    // Build the transaction and data hex according to the operation
    TransactionSkeleton txSkel;
    txSkel = w.buildTransaction(fromStr, toStr, valueStr, gasStr, gasPriceStr, txDataStr);
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
    std::string txLink = this->w.sendTransaction(signedTx, operationStr);
    if (txLink.empty()) { emit txSent(false, ""); }
    while (
      txLink.find("Transaction nonce is too low") != std::string::npos ||
      txLink.find("Transaction with the same hash was already imported") != std::string::npos
    ) {
      emit txRetry();
      txSkel.nonce++;
      if (QmlSystem::getLedgerFlag()) {
        std::pair<bool, std::string> signStatus;
        signStatus = this->ledgerDevice.signTransaction(
          txSkel, this->w.getCurrentAccount().first
        );
        signSuccess = signStatus.first;
        signedTx = (signSuccess) ? signStatus.second : "";
      } else {
        signedTx = this->w.signTransaction(txSkel, passStr);
      }
      txLink = this->w.sendTransaction(signedTx, operationStr);
    }
    emit txSent(true, QString::fromStdString(txLink));
  });
}
