// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef QMLSEND_H
#define QMLSEND_H

/**
 * Wrappers for the Send screen.
 */
class QmlSend : public QObject {
  Q_OBJECT

  signals:
    void operationOverride(
      QString op, QString amountCoin, QString amountToken, QString amountLP
    );
    void txStart(
      QString operation, QString to,
      QString coinAmount, QString tokenAmount, QString lpAmount,
      QString gasLimit, QString gasPrice, QString pass
    );
    void txBuilt(bool b);
    void txSigned(bool b, QString msg);
    void txSent(bool b, QString linkUrl);
    void txRetry();

  public:
    // Get gas price from network
    Q_INVOKABLE QString getAutomaticFee() {
      return QString::fromStdString(API::getAutomaticFee());
    }

    // Create a RegExp for coin and token transaction amount input, respectively
    Q_INVOKABLE QRegExp createCoinRegExp() {
      QRegExp rx;
      rx.setPattern("[0-9]{0,99}(?:\\.[0-9]{1," + QString::number(this->currentCoinDecimals) + "})?");
      return rx;
    }

    Q_INVOKABLE QRegExp createTokenRegExp() {
      QRegExp rx;
      rx.setPattern("[0-9]{0,99}(?:\\.[0-9]{1," + QString::number(this->currentTokenDecimals) + "})?");
      return rx;
    }

    // Calculate the real amount of a max AVAX transaction (minus gas costs)
    Q_INVOKABLE QString getRealMaxAVAXAmount(QString gasLimit, QString gasPrice) {
      std::string gasLimitStr = gasLimit.toStdString(); // Already in Wei
      std::string gasPriceStr = Utils::fixedPointToWei(gasPrice.toStdString(), 9); // Gwei, so 10^9 Wei
      u256 gasLimitU256 = u256(gasLimitStr);
      u256 gasPriceU256 = u256(gasPriceStr);

      // TODO: check this later
      std::string balanceAVAXStr;
      //balanceAVAXStr = this->currentAccount.balanceAVAX;
      u256 totalU256 = u256(Utils::fixedPointToWei(balanceAVAXStr, this->currentCoinDecimals));
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

    /**
     * Calculate the total cost of a transaction.
     * Calculation is done with values converted to Wei, while the result
     * is converted back to fixed point.
     */
    Q_INVOKABLE QString calculateTransactionCost(
      QString amount, QString gasLimit, QString gasPrice
    ) {
      std::string amountStr = Utils::fixedPointToWei(amount.toStdString(), 18);  // Fixed point, so 10^18 Wei
      std::string gasLimitStr = gasLimit.toStdString(); // Already in Wei
      std::string gasPriceStr = Utils::fixedPointToWei(gasPrice.toStdString(), 9); // Gwei, so 10^9 Wei
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

    /**
     * Check for insufficient funds in a transaction.
     * Types are "Coin", "Token" and "LP", respectively.
     */
    Q_INVOKABLE bool hasInsufficientFunds(
      QString type, QString senderAmount, QString receiverAmount
    ) {
      std::string senderStr, receiverStr;
      u256 senderU256, receiverU256;
      int decimals;
      if (type == "Coin") decimals = this->currentCoinDecimals;
      else if (type == "Token") decimals = this->currentTokenDecimals;
      else if (type == "LP") decimals = 18;
      senderStr = Utils::fixedPointToWei(senderAmount.toStdString(), decimals);
      receiverStr = Utils::fixedPointToWei(receiverAmount.toStdString(), decimals);
      senderU256 = u256(senderStr);
      receiverU256 = u256(receiverStr);
      return (receiverU256 > senderU256);
    }

    // Make a transaction with the collected data
    Q_INVOKABLE void makeTransaction(
      QString operation, QString to,
      QString coinAmount, QString tokenAmount, QString lpAmount,
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
        coinAmountStr = Utils::fixedPointToWei(coinAmountStr, this->currentCoinDecimals);
        tokenAmountStr = Utils::fixedPointToWei(tokenAmountStr, this->currentTokenDecimals);
        lpAmountStr = Utils::fixedPointToWei(lpAmountStr, 18);
        gasPriceStr = boost::lexical_cast<std::string>(
          boost::lexical_cast<u256>(gasPriceStr) * raiseToPow(10, 9)
        );

        // Build the transaction and data hex according to the operation
        std::string dataHex;
        TransactionSkeleton txSkel;
        if (operationStr == "Send AVAX") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, toStr, coinAmountStr, gasLimitStr, gasPriceStr
          );
        } else if (operationStr == "Send AVME") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::tokenContracts[this->currentToken],
            "0", gasLimitStr, gasPriceStr, Pangolin::transfer(toStr, tokenAmountStr)
          );
        } else if (operationStr == "Approve Exchange") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::tokenContracts["AVME"],
            "0", gasLimitStr, gasPriceStr, Pangolin::approve(Pangolin::routerContract)
          );
        } else if (operationStr == "Approve Liquidity") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::getPair(this->currentCoin, this->currentToken),
            "0", gasLimitStr, gasPriceStr, Pangolin::approve(Pangolin::routerContract)
          );
        } else if (operationStr == "Approve Staking") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::getPair(this->currentCoin, this->currentToken),
            "0", gasLimitStr, gasPriceStr, Pangolin::approve(Pangolin::stakingContract)
          );
        } else if (operationStr == "Approve Compound") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::getPair(this->currentCoin, this->currentToken),
            "0", gasLimitStr, gasPriceStr, Pangolin::approve(Pangolin::compoundContract)
          );
        } else if (operationStr == "Swap AVAX -> AVME") {
          u256 amountOutMin = boost::lexical_cast<u256>(tokenAmountStr);
          amountOutMin -= (amountOutMin / 200); // 0.5% Slippage
          dataHex = Pangolin::swapExactAVAXForTokens(
            // amountOutMin, path, to, deadline
            boost::lexical_cast<std::string>(amountOutMin),
            { Pangolin::tokenContracts["WAVAX"], Pangolin::tokenContracts["AVME"] },
            this->currentAccount,
            boost::lexical_cast<std::string>(
              std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
              ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
            )
          );
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::routerContract,
            coinAmountStr, gasLimitStr, gasPriceStr, dataHex
          );
        } else if (operationStr == "Swap AVME -> AVAX") {
          u256 amountOutMin = boost::lexical_cast<u256>(coinAmountStr);
          amountOutMin -= (amountOutMin / 200); // 0.5% Slippage
          dataHex = Pangolin::swapExactTokensForAVAX(
            // amountIn, amountOutMin, path, to, deadline
            tokenAmountStr,
            boost::lexical_cast<std::string>(amountOutMin),
            { Pangolin::tokenContracts["AVME"], Pangolin::tokenContracts["WAVAX"] },
            this->currentAccount,
            boost::lexical_cast<std::string>(
              std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
              ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
            )
          );
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::routerContract,
            "0", gasLimitStr, gasPriceStr, dataHex
          );
        } else if (operationStr == "Add Liquidity") {
          u256 amountAVAXMin = boost::lexical_cast<u256>(coinAmountStr);
          u256 amountTokenMin = boost::lexical_cast<u256>(tokenAmountStr);
          amountAVAXMin -= (amountAVAXMin / 200); // 0.5%
          amountTokenMin -= (amountTokenMin / 200); // 0.5%
          dataHex = Pangolin::addLiquidityAVAX(
            // tokenAddress, amountTokenDesired, amountTokenMin, amountAVAXMin, to, deadline
            Pangolin::tokenContracts[this->currentToken],
            tokenAmountStr,
            boost::lexical_cast<std::string>(amountTokenMin),
            boost::lexical_cast<std::string>(amountAVAXMin),
            this->currentAccount,
            boost::lexical_cast<std::string>(
              std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
              ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
            )
          );
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::routerContract,
            coinAmountStr, gasLimitStr, gasPriceStr, dataHex
          );
        } else if (operationStr == "Remove Liquidity") {
          u256 amountAVAXMin = boost::lexical_cast<u256>(coinAmountStr);
          u256 amountTokenMin = boost::lexical_cast<u256>(tokenAmountStr);
          amountAVAXMin -= (amountAVAXMin / 200); // 0.5%
          amountTokenMin -= (amountTokenMin / 200); // 0.5%
          dataHex = Pangolin::removeLiquidityAVAX(
            // tokenAddress, liquidity, amountTokenMin, amountAVAXMin, to, deadline
            Pangolin::tokenContracts[this->currentToken],
            lpAmountStr,
            boost::lexical_cast<std::string>(amountTokenMin),
            boost::lexical_cast<std::string>(amountAVAXMin),
            this->currentAccount,
            boost::lexical_cast<std::string>(
              std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()
              ).count() + 300000 // + 5 minutes (300 seconds), in milliseconds
            )
          );
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::routerContract,
            "0", gasLimitStr, gasPriceStr, dataHex
          );
        } else if (operationStr == "Stake LP") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::stakingContract,
            "0", gasLimitStr, gasPriceStr, Staking::stake(lpAmountStr)
          );
        } else if (operationStr == "Stake Compound LP") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::compoundContract,
            "0", gasLimitStr, gasPriceStr, Staking::stakeCompound(lpAmountStr)
          );
        } else if (operationStr == "Unstake LP") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::stakingContract,
            "0", gasLimitStr, gasPriceStr, Staking::withdraw(lpAmountStr)
          );
        } else if (operationStr == "Unstake Compound LP") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::compoundContract,
            "0", gasLimitStr, gasPriceStr, Staking::compoundWithdraw(lpAmountStr)
          );
        } else if (operationStr == "Harvest AVME") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::stakingContract,
            "0", gasLimitStr, gasPriceStr, Staking::getReward()
          );
        } else if (operationStr == "Reinvest AVME") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::compoundContract,
            "0", "500000", gasPriceStr, Staking::reinvest()
          );
        } else if (operationStr == "Exit Staking") {
          txSkel = QmlSystem::getWallet()->buildTransaction(
            this->currentAccount, Pangolin::stakingContract,
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
          signStatus = QmlSystem::getLedgerDevice()->signTransaction(txSkel, this->currentAccountPath);
          signSuccess = signStatus.first;
          signedTx = (signSuccess) ? signStatus.second : "";
          msg = (signSuccess) ? "Transaction signed!" : signStatus.second;
        } else {
          signedTx = QmlSystem::getWallet()->signTransaction(txSkel, passStr);
          signSuccess = !signedTx.empty();
          msg = (signSuccess) ? "Transaction signed!" : "Error on signing transaction.";
        }
        emit txSigned(signSuccess, QString::fromStdString(msg));

        // Send the transaction
        std::string txLink = QmlSystem::getWallet()->sendTransaction(signedTx, operationStr);
        if (txLink.empty()) { emit txSent(false, ""); }
        while (
          txLink.find("Transaction nonce is too low") != std::string::npos ||
          txLink.find("Transaction with the same hash was already imported") != std::string::npos
        ) {
          emit txRetry();
          txSkel.nonce++;
          if (QmlSystem::getLedgerFlag()) {
            std::pair<bool, std::string> signStatus;
            signStatus = QmlSystem::getLedgerDevice()->signTransaction(txSkel, this->currentAccountPath);
            signSuccess = signStatus.first;
            signedTx = (signSuccess) ? signStatus.second : "";
          } else {
            signedTx = QmlSystem::getWallet()->signTransaction(txSkel, passStr);
          }
          txLink = QmlSystem::getWallet()->sendTransaction(signedTx, operationStr);
        }
        emit txSent(true, QString::fromStdString(txLink));
      });
    }
};

#endif  // QMLSEND_H

