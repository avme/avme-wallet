// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

QString QmlSystem::getAutomaticFee() {
  return QString::fromStdString(API::getAutomaticFee());
}

QRegExp QmlSystem::createTxRegExp(int decimals) {
  QRegExp rx;
  rx.setPattern("[0-9]{0,99}(?:\\.[0-9]{1," + QString::number(decimals) + "})?");
  return rx;
}

QString QmlSystem::getRealMaxAVAXAmount(QString gasLimit, QString gasPrice) {
  // Gas limit is in Wei, gas price is in Gwei (10^9 Wei)
  std::string gasLimitStr = gasLimit.toStdString();
  std::string gasPriceStr = Utils::fixedPointToWei(gasPrice.toStdString(), 9);
  u256 gasLimitU256 = u256(gasLimitStr);
  u256 gasPriceU256 = u256(gasPriceStr);

  // TODO: check this later
  std::string balanceAVAXStr;
  //balanceAVAXStr = this->w.getCurrentAccount().first.balanceAVAX;
  u256 totalU256 = u256(Utils::fixedPointToWei(balanceAVAXStr, 18));
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
  QString operation, QString to,
  QString coinAmount, int coinDecimals,
  QString tokenAmount, int tokenDecimals,
  QString lpAmount, int lpDecimals,
  QString gasLimit, QString gasPrice, QString pass
) {
  QtConcurrent::run([=](){
    // Convert everything to std::string for easier handling
    std::string operationStr = operation.toStdString();
    std::string toStr = to.toStdString();
    std::string coinAmountStr = coinAmount.toStdString();
    std::string tokenAmountStr = tokenAmount.toStdString();
    std::string lpAmountStr = lpAmount.toStdString();
    std::string gasLimitStr = gasLimit.toStdString();
    std::string gasPriceStr = gasPrice.toStdString();
    std::string passStr = pass.toStdString();

    // Convert the values required for a transaction to their Wei formats.
    // Gas price is in Gwei (10^9 Wei) and amounts are in fixed point.
    // Gas limit is already in Wei so we skip that.
    coinAmountStr = Utils::fixedPointToWei(coinAmountStr, coinDecimals);
    tokenAmountStr = Utils::fixedPointToWei(tokenAmountStr, tokenDecimals);
    lpAmountStr = Utils::fixedPointToWei(lpAmountStr, lpDecimals);
    gasPriceStr = boost::lexical_cast<std::string>(
      boost::lexical_cast<u256>(gasPriceStr) * raiseToPow(10, 9)
    );

    // Build the transaction and data hex according to the operation
    std::string dataHex;
    TransactionSkeleton txSkel;
    if (operationStr == "Send AVAX") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, toStr, coinAmountStr, gasLimitStr, gasPriceStr
      );
    } else if (operationStr == "Send AVME") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["AVME"],
        "0", gasLimitStr, gasPriceStr, Pangolin::transfer(toStr, tokenAmountStr)
      );
    } else if (operationStr == "Approve Exchange") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["AVME"],
        "0", gasLimitStr, gasPriceStr, Pangolin::approve(Pangolin::contracts["router"])
      );
    } else if (operationStr == "Approve Liquidity") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["AVAX-AVME"],
        "0", gasLimitStr, gasPriceStr, Pangolin::approve(Pangolin::contracts["router"])
      );
    } else if (operationStr == "Approve Staking") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["AVAX-AVME"],
        "0", gasLimitStr, gasPriceStr, Pangolin::approve(Pangolin::contracts["staking"])
      );
    } else if (operationStr == "Approve Compound") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["AVAX-AVME"],
        "0", gasLimitStr, gasPriceStr, Pangolin::approve(Pangolin::contracts["compound"])
      );
    } else if (operationStr == "Swap AVAX -> AVME") {
      u256 amountOutMin = boost::lexical_cast<u256>(tokenAmountStr);
      amountOutMin -= (amountOutMin / 200); // 0.5% Slippage
      dataHex = Pangolin::swapExactAVAXForTokens(
        // amountOutMin, path, to, deadline
        boost::lexical_cast<std::string>(amountOutMin),
        { Pangolin::contracts["AVAX"], Pangolin::contracts["AVME"] },
        this->w.getCurrentAccount().first,
        boost::lexical_cast<std::string>(
          std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::system_clock::now().time_since_epoch()
          ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
        )
      );
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["router"],
        coinAmountStr, gasLimitStr, gasPriceStr, dataHex
      );
    } else if (operationStr == "Swap AVME -> AVAX") {
      u256 amountOutMin = boost::lexical_cast<u256>(coinAmountStr);
      amountOutMin -= (amountOutMin / 200); // 0.5% Slippage
      dataHex = Pangolin::swapExactTokensForAVAX(
        // amountIn, amountOutMin, path, to, deadline
        tokenAmountStr,
        boost::lexical_cast<std::string>(amountOutMin),
        { Pangolin::contracts["AVME"], Pangolin::contracts["AVAX"] },
        this->w.getCurrentAccount().first,
        boost::lexical_cast<std::string>(
          std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::system_clock::now().time_since_epoch()
          ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
        )
      );
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["router"],
        "0", gasLimitStr, gasPriceStr, dataHex
      );
    } else if (operationStr == "Add Liquidity") {
      u256 amountAVAXMin = boost::lexical_cast<u256>(coinAmountStr);
      u256 amountTokenMin = boost::lexical_cast<u256>(tokenAmountStr);
      amountAVAXMin -= (amountAVAXMin / 200); // 0.5%
      amountTokenMin -= (amountTokenMin / 200); // 0.5%
      dataHex = Pangolin::addLiquidityAVAX(
        // tokenAddress, amountTokenDesired, amountTokenMin, amountAVAXMin, to, deadline
        Pangolin::contracts["AVME"],
        tokenAmountStr,
        boost::lexical_cast<std::string>(amountTokenMin),
        boost::lexical_cast<std::string>(amountAVAXMin),
        this->w.getCurrentAccount().first,
        boost::lexical_cast<std::string>(
          std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::system_clock::now().time_since_epoch()
          ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
        )
      );
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["router"],
        coinAmountStr, gasLimitStr, gasPriceStr, dataHex
      );
    } else if (operationStr == "Remove Liquidity") {
      u256 amountAVAXMin = boost::lexical_cast<u256>(coinAmountStr);
      u256 amountTokenMin = boost::lexical_cast<u256>(tokenAmountStr);
      amountAVAXMin -= (amountAVAXMin / 200); // 0.5%
      amountTokenMin -= (amountTokenMin / 200); // 0.5%
      dataHex = Pangolin::removeLiquidityAVAX(
        // tokenAddress, liquidity, amountTokenMin, amountAVAXMin, to, deadline
        Pangolin::contracts["AVME"],
        lpAmountStr,
        boost::lexical_cast<std::string>(amountTokenMin),
        boost::lexical_cast<std::string>(amountAVAXMin),
        this->w.getCurrentAccount().first,
        boost::lexical_cast<std::string>(
          std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::system_clock::now().time_since_epoch()
          ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
        )
      );
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["router"],
        "0", gasLimitStr, gasPriceStr, dataHex
      );
    } else if (operationStr == "Stake LP") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["staking"],
        "0", gasLimitStr, gasPriceStr, Staking::stake(lpAmountStr)
      );
    } else if (operationStr == "Stake Compound LP") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["compound"],
        "0", gasLimitStr, gasPriceStr, Staking::stakeCompound(lpAmountStr)
      );
    } else if (operationStr == "Unstake LP") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["staking"],
        "0", gasLimitStr, gasPriceStr, Staking::withdraw(lpAmountStr)
      );
    } else if (operationStr == "Unstake Compound LP") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["compound"],
        "0", gasLimitStr, gasPriceStr, Staking::compoundWithdraw(lpAmountStr)
      );
    } else if (operationStr == "Harvest AVME") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["staking"],
        "0", gasLimitStr, gasPriceStr, Staking::getReward()
      );
    } else if (operationStr == "Reinvest AVME") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["compound"],
        "0", "500000", gasPriceStr, Staking::reinvest()
      );
    } else if (operationStr == "Exit Staking") {
      txSkel = this->w.buildTransaction(
        this->w.getCurrentAccount().first, Pangolin::contracts["staking"],
        "0", gasLimitStr, gasPriceStr, Staking::exit()
      );
    }
    emit txBuilt(txSkel.nonce != Utils::MAX_U256_VALUE());

    // Sign the transaction
    bool signSuccess;
    std::string msg;
    std::string signedTx;
    if (QmlSystem::getLedgerFlag()) {
      std::pair<bool, std::string> signStatus;
      signStatus = this->ledgerDevice.signTransaction(
        txSkel, this->w.getCurrentAccount().first
      );
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
