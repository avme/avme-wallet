// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

qreal QmlSystem::getQRCodeSize(QString address) {
  qreal width = 0;
  QRcode *qrcode = QRcode_encodeString(
    address.toStdString().c_str(), 0, QR_ECLEVEL_L, QR_MODE_8, 1
  );
  width = qrcode->width;
  return width;
}

QVariantList QmlSystem::getQRCodeFromAddress(QString address) {
  QVariantList ret;
  QRcode *qrcode = QRcode_encodeString(
    address.toStdString().c_str(), 0, QR_ECLEVEL_L, QR_MODE_8, 1
  );
  size_t qrCodeSize = strlen((char*)qrcode->data);
  for (int i = 0; i < qrCodeSize; i++) {
    std::string obj;
    std::string color = (qrcode->data[i] & 1) ? "true" : "false";
    obj += "{\"squareColor\": " + color;
    obj += "}";
    ret << QString::fromStdString(obj);
  }
  return ret;
}

/*
void QmlSystem::getAccountBalancesOverview(QString address) {
  QtConcurrent::run([=](){
    QVariantMap ret;
    for (std::pair<std::string, std::string> a : this->w->getAccounts()) {
      if (a.first == address.toStdString()) {
        // Whole balances
        std::string balanceAVAXStr, balanceAVMEStr, balanceLPFreeStr, balanceLPLockedStr, balanceLockedCompoundLP, balanceTotalLPLocked;
        a.balancesThreadLock.lock();
        balanceAVAXStr = a.balanceAVAX;
        balanceAVMEStr = a.balanceAVME;
        balanceLPFreeStr = a.balanceLPFree;
        balanceLPLockedStr = a.balanceLPLocked;
        balanceLockedCompoundLP = a.balanceLockedCompoundLP;
        balanceTotalLPLocked = a.balanceTotalLPLocked;
        a.balancesThreadLock.unlock();

        ret.insert("balanceAVAX", QString::fromStdString(balanceAVAXStr));
        ret.insert("balanceAVME", QString::fromStdString(balanceAVMEStr));
        ret.insert("balanceLPFree", QString::fromStdString(balanceLPFreeStr));
        ret.insert("balanceLPLocked", QString::fromStdString(balanceLPLockedStr));
        ret.insert("balanceLockedCompoundLP", QString::fromStdString(balanceLockedCompoundLP));
        ret.insert("balanceTotalLPLocked", QString::fromStdString(balanceTotalLPLocked));
        break;
      }
    }
    emit accountBalancesUpdated(ret);
  });
}

void QmlSystem::getAccountFiatBalancesOverview(QString address) {
  QtConcurrent::run([=](){
    QVariantMap ret;
    for (Account &a : QmlSystem.w.accounts) {
      if (a.address == address.toStdString()) {
        // Whole balances (for calculating fiat balances)
        std::string balanceAVAXStr, balanceAVMEStr, balanceLPFreeStr, balanceLPLockedStr;
        a.balancesThreadLock.lock();
        balanceAVAXStr = a.balanceAVAX;
        balanceAVMEStr = a.balanceAVME;
        balanceLPFreeStr = a.balanceLPFree;
        balanceLPLockedStr = a.balanceLPLocked;
        a.balancesThreadLock.unlock();

        // Fiat balances
        std::string AVAXUnitPrice = Graph::getAVAXPriceUSD();
        std::string AVMEUnitPrice = Graph::getAVMEPriceUSD(AVAXUnitPrice);
        bigfloat AVAXPriceFloat =
          boost::lexical_cast<double>(balanceAVAXStr) * boost::lexical_cast<double>(AVAXUnitPrice);
        bigfloat AVMEPriceFloat =
          boost::lexical_cast<double>(balanceAVMEStr) * boost::lexical_cast<double>(AVMEUnitPrice);
        std::string AVAXPrice = boost::lexical_cast<std::string>(AVAXPriceFloat);
        std::string AVMEPrice = boost::lexical_cast<std::string>(AVMEPriceFloat);

        // Round the fiat balances to two decimals
        std::stringstream AVAXPricess, AVMEPricess;
        AVAXPricess << std::setprecision(2) << std::fixed << bigfloat(AVAXPrice);
        AVMEPricess << std::setprecision(2) << std::fixed << bigfloat(AVMEPrice);
        AVAXPrice = AVAXPricess.str();
        AVMEPrice = AVMEPricess.str();

        // Fiat percentages (for the chart)
        bigfloat totalUSD, AVAXPercentageFloat, AVMEPercentageFloat;
        totalUSD = boost::lexical_cast<double>(AVAXPrice) + boost::lexical_cast<double>(AVMEPrice);
        if (totalUSD == 0) {
          AVAXPercentageFloat = AVMEPercentageFloat = 0;
        } else {
          AVAXPercentageFloat = (boost::lexical_cast<double>(AVAXPrice) / totalUSD) * 100;
          AVMEPercentageFloat = (boost::lexical_cast<double>(AVMEPrice) / totalUSD) * 100;
        }

        // Round the percentages to two decimals
        std::stringstream AVAXPercentagess, AVMEPercentagess;
        AVAXPercentagess << std::setprecision(2) << std::fixed << bigfloat(AVAXPercentageFloat);
        AVMEPercentagess << std::setprecision(2) << std::fixed << bigfloat(AVMEPercentageFloat);
        std::string AVAXPercentage = AVAXPercentagess.str();
        std::string AVMEPercentage = AVMEPercentagess.str();

        // Pack up fiat balances and send back to GUI
        ret.insert("balanceAVAXUSD", QString::fromStdString(AVAXPrice));
        ret.insert("balanceAVMEUSD", QString::fromStdString(AVMEPrice));
        ret.insert("percentageAVAXUSD", QString::fromStdString(AVAXPercentage));
        ret.insert("percentageAVMEUSD", QString::fromStdString(AVMEPercentage));
        break;
      }
    }
    emit accountFiatBalancesUpdated(ret);
  });
}

void QmlSystem::getAllAccountBalancesOverview() {
  QtConcurrent::run([=](){
    QVariantMap ret;
    u256 totalAVAX = 0, totalAVME = 0, totalLPFree = 0, totalLPLocked = 0;
    std::string totalAVAXStr = "", totalAVMEStr = "", totalLPFreeStr = "", totalLPLockedStr = "";

    // Whole balances
    for (std::pair<std::string, std::string> a : this->w->getAccounts()) {
      a.balancesThreadLock.lock();
      totalAVAX += boost::lexical_cast<u256>(
        Utils::fixedPointToWei(a.balanceAVAX, 18)
      );
      totalAVME += boost::lexical_cast<u256>(
        Utils::fixedPointToWei(a.balanceAVME, this->currentTokenDecimals)
      );
      totalLPFree += boost::lexical_cast<u256>(
        Utils::fixedPointToWei(a.balanceLPFree, 18)
      );
      totalLPLocked += boost::lexical_cast<u256>(
        Utils::fixedPointToWei(a.balanceTotalLPLocked, 18)
      );
      a.balancesThreadLock.unlock();
    }
    totalAVAXStr = Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(totalAVAX), 18
    );
    totalAVMEStr = Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(totalAVME), this->currentTokenDecimals
    );
    totalLPFreeStr = Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(totalLPFree), 18
    );
    totalLPLockedStr = Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(totalLPLocked), 18
    );

    // Pack up and send back to GUI
    ret.insert("balanceAVAX", QString::fromStdString(totalAVAXStr));
    ret.insert("balanceAVME", QString::fromStdString(totalAVMEStr));
    ret.insert("balanceLPFree", QString::fromStdString(totalLPFreeStr));
    ret.insert("balanceLPLocked", QString::fromStdString(totalLPLockedStr));
    emit walletBalancesUpdated(ret);
  });
}

void QmlSystem::getAllAccountFiatBalancesOverview() {
  QtConcurrent::run([=](){
    QVariantMap ret;
    u256 totalAVAX = 0, totalAVME = 0, totalLPFree = 0, totalLPLocked = 0;
    std::string totalAVAXStr = "", totalAVMEStr = "", totalLPFreeStr = "", totalLPLockedStr = "";

    // Whole balances
    for (std::pair<std::string, std::string> a : this->w->getAccounts()) {
      a.balancesThreadLock.lock();
      totalAVAX += boost::lexical_cast<u256>(
        Utils::fixedPointToWei(a.balanceAVAX, 18)
      );
      totalAVME += boost::lexical_cast<u256>(
        Utils::fixedPointToWei(a.balanceAVME, this->currentTokenDecimals)
      );
      totalLPFree += boost::lexical_cast<u256>(
        Utils::fixedPointToWei(a.balanceLPFree, 18)
      );
      totalLPLocked += boost::lexical_cast<u256>(
        Utils::fixedPointToWei(a.balanceLPLocked, 18)
      );
      a.balancesThreadLock.unlock();
    }
    totalAVAXStr = Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(totalAVAX), 18
    );
    totalAVMEStr = Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(totalAVME), this->currentTokenDecimals
    );
    totalLPFreeStr = Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(totalLPFree), 18
    );
    totalLPLockedStr = Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(totalLPLocked), 18
    );

    // Fiat balances
    std::string AVAXUnitPrice = Graph::getAVAXPriceUSD();
    std::string AVMEUnitPrice = Graph::getAVMEPriceUSD(AVAXUnitPrice);
    bigfloat AVAXPriceFloat =
      boost::lexical_cast<double>(totalAVAXStr) * boost::lexical_cast<double>(AVAXUnitPrice);
    bigfloat AVMEPriceFloat =
      boost::lexical_cast<double>(totalAVMEStr) * boost::lexical_cast<double>(AVMEUnitPrice);
    std::string AVAXPrice = boost::lexical_cast<std::string>(AVAXPriceFloat);
    std::string AVMEPrice = boost::lexical_cast<std::string>(AVMEPriceFloat);

    // Round the fiat balances to two decimals
    std::stringstream AVAXPricess, AVMEPricess;
    AVAXPricess << std::setprecision(2) << std::fixed << bigfloat(AVAXPrice);
    AVMEPricess << std::setprecision(2) << std::fixed << bigfloat(AVMEPrice);
    AVAXPrice = AVAXPricess.str();
    AVMEPrice = AVMEPricess.str();

    // Fiat percentages (for the chart)
    bigfloat totalUSD, AVAXPercentageFloat, AVMEPercentageFloat;
    totalUSD = boost::lexical_cast<double>(AVAXPrice) + boost::lexical_cast<double>(AVMEPrice);
    if (totalUSD == 0) {
      AVAXPercentageFloat = AVMEPercentageFloat = 0;
    } else {
      AVAXPercentageFloat = (boost::lexical_cast<double>(AVAXPrice) / totalUSD) * 100;
      AVMEPercentageFloat = (boost::lexical_cast<double>(AVMEPrice) / totalUSD) * 100;
    }

    // Round the percentages to two decimals
    std::stringstream AVAXPercentagess, AVMEPercentagess;
    AVAXPercentagess << std::setprecision(2) << std::fixed << bigfloat(AVAXPercentageFloat);
    AVMEPercentagess << std::setprecision(2) << std::fixed << bigfloat(AVMEPercentageFloat);
    std::string AVAXPercentage = AVAXPercentagess.str();
    std::string AVMEPercentage = AVMEPercentagess.str();

    // Pack up and send back to GUI
    ret.insert("balanceAVAXUSD", QString::fromStdString(AVAXPrice));
    ret.insert("balanceAVMEUSD", QString::fromStdString(AVMEPrice));
    ret.insert("percentageAVAXUSD", QString::fromStdString(AVAXPercentage));
    ret.insert("percentageAVMEUSD", QString::fromStdString(AVMEPercentage));
    emit walletFiatBalancesUpdated(ret);
  });
}
*/

/*
void QmlSystem::calculateRewardCurrentROI() {
  QtConcurrent::run([=](){
    // Get the prices in USD for both AVAX and AVME
    std::string AVAXPrice = Graph::getAVAXPriceUSD();
    std::string AVMEPrice = Graph::getAVMEPriceUSD(AVAXPrice);
    bigfloat AVAXUnitPrice = boost::lexical_cast<double>(AVAXPrice);
    bigfloat AVMEUnitPrice = boost::lexical_cast<double>(AVMEPrice);

    // From 1 AVAX, calculate the optimal amount of AVME that would go to the pool
    std::vector<std::string> reserves = Pangolin::getReserves("WAVAX", "AVME");
    std::string first = Pangolin::getFirstFromPair("WAVAX", "AVME");
    bigfloat AVAXreserves = ("WAVAX" == first)
      ? boost::lexical_cast<bigfloat>(u256(reserves[0]))
      : boost::lexical_cast<bigfloat>(u256(reserves[1]));
    bigfloat AVMEreserves = ("AVME" == first)
      ? boost::lexical_cast<bigfloat>(u256(reserves[0]))
      : boost::lexical_cast<bigfloat>(u256(reserves[1]));
    bigfloat AVAXamount = bigfloat(Utils::fixedPointToWei("1", 18));
    // Amount and reserves are converted back to a non-scientific notation number
    bigfloat AVMEamount = bigfloat(Pangolin::calcLiquidityAmountOut(
      boost::lexical_cast<std::string>(u256(AVAXamount)),
      boost::lexical_cast<std::string>(u256(AVAXreserves)),
      boost::lexical_cast<std::string>(u256(AVMEreserves))
    ));

    // Use both values in Wei amounts to calculate the amount of LP that would be received
    bigfloat LPsupply = bigfloat(Utils::weiToFixedPoint(Staking::totalSupply(), 18));
    bigfloat LPamount = std::min(
      (AVAXamount * bigfloat(Utils::fixedPointToWei(
        boost::lexical_cast<std::string>(LPsupply), 18)
      )) / AVAXreserves,
      (AVMEamount * bigfloat(Utils::fixedPointToWei(
        boost::lexical_cast<std::string>(LPsupply), 18)
      )) / AVMEreserves
    );
    // Amount is converted back to a non-scientific notation number
    LPamount = bigfloat(Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(u256(LPamount)), 18)
    );

    // Get the reward value and duration from the staking contract
    bigfloat reward = bigfloat(Staking::getRewardForDuration());
    bigfloat duration = bigfloat(Staking::rewardsDuration()) / 86400;
    bigfloat rewardPerDuration = reward / duration; // 86400 seconds = 1 day
    rewardPerDuration = bigfloat(Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(u256(rewardPerDuration)), 18)
    );

    // Calculate the ROI, based on the following formula:
    // A = AVAXUnitPrice, B = AVMEUnitPrice, C = LPamount, D = rewardPerDuration, E = LPsupply
    // ROI = ((((C / E) * D) * 365) * B) / (A * 2) * 100
    bigfloat ROI = (
      ((((LPamount / LPsupply) * rewardPerDuration) * 365) * AVMEUnitPrice) / (AVAXUnitPrice * 2)
    ) * 100;

    // Round the percentage to two decimals and return it
    std::stringstream ROIss;
    ROIss << std::setprecision(2) << std::fixed << ROI;
    emit roiCalculated(QString::fromStdString(ROIss.str()));
  });
}
*/

/*
void QmlSystem::getMarketData(int days) {
  QtConcurrent::run([=](){
    std::string AVAXUnitPrice, AVMEUnitPrice;
    std::vector<std::map<std::string, std::string>> listUSDT, listAVME;
    QVariantList graphRet;

    // Get the current AVAX price in fiat (USD) and round it to two decimals
    AVAXUnitPrice = Graph::getAVAXPriceUSD();
    AVMEUnitPrice = Graph::getAVMEPriceUSD(AVAXUnitPrice);
    std::stringstream AVAXss;
    AVAXss << std::setprecision(2) << std::fixed << bigfloat(AVAXUnitPrice);
    AVAXUnitPrice = AVAXss.str();

    // Get the historical AVME prices in fiat (USD) and send back
    listUSDT = Graph::getUSDTPriceHistory(days);
    listAVME = Graph::getAVMEPriceHistory(days);
    for (std::map<std::string, std::string> mapUSDT : listUSDT) {
      for (std::map<std::string, std::string> mapAVME : listAVME) {
        if (mapUSDT["date"] == mapAVME["date"]) {
          std::string obj;
          bigfloat realAVMEValue = (
            (1 / bigfloat(mapUSDT["priceUSD"])) * bigfloat(mapAVME["priceUSD"])
          );
          obj += "{\"unixdate\": " + mapAVME["date"];
          obj += ", \"priceUSD\": " + boost::lexical_cast<std::string>(realAVMEValue);
          obj += "}";
          graphRet << QString::fromStdString(obj);
        }
      }
    }
    emit marketDataUpdated(
      days,
      QString::fromStdString(AVAXUnitPrice),
      QString::fromStdString(AVMEUnitPrice),
      graphRet
    );
  });
}
*/

