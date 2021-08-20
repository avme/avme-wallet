// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

QString QmlSystem::getFirstFromPair(QString assetAddressA, QString assetAddressB) {
  return QString::fromStdString(
    Pangolin::getFirstFromPair(assetAddressA.toStdString(), assetAddressB.toStdString())
  );
}

bool QmlSystem::isApproved(QString amount, QString allowed) {
  if (amount.isEmpty()) { amount = QString("0"); }
  if (allowed.isEmpty()) { allowed = QString("0"); }
  u256 amountU256 = boost::lexical_cast<u256>(
    Utils::fixedPointToWei(amount.toStdString(), 18)
  );
  u256 allowedU256 = boost::lexical_cast<u256>(allowed.toStdString());
  return ((allowedU256 > 0) && (allowedU256 >= amountU256));
}

void QmlSystem::updateExchangeData(QString tokenNameA, QString tokenNameB) {
  QtConcurrent::run([=](){
    QVariantMap ret;
    std::string strA = tokenNameA.toStdString();
    std::string strB = tokenNameB.toStdString();
    if (strA == "AVAX") { strA = "WAVAX"; }
    if (strB == "AVAX") { strB = "WAVAX"; }

    std::vector<std::string> reserves = Pangolin::getReserves(strA, strB);
    std::string first = Pangolin::getFirstFromPair(strA, strB);
    if (strA == first) {
      emit exchangeDataUpdated(
        tokenNameA, QString::fromStdString(reserves[0]),
        tokenNameB, QString::fromStdString(reserves[1])
      );
    } else if (strB == first) {
      emit exchangeDataUpdated(
        tokenNameA, QString::fromStdString(reserves[1]),
        tokenNameB, QString::fromStdString(reserves[0])
      );
    }
  });
}

void QmlSystem::updateLiquidityData(QString tokenNameA, QString tokenNameB) {
  QtConcurrent::run([=](){
    QVariantMap ret;
    std::string strA = tokenNameA.toStdString();
    std::string strB = tokenNameB.toStdString();
    if (strA == "AVAX") { strA = "WAVAX"; }
    if (strB == "AVAX") { strB = "WAVAX"; }
    std::vector<std::string> reserves = Pangolin::getReserves(strA, strB);
    std::string liquidity = Pangolin::totalSupply(strA, strB);
    std::string first = Pangolin::getFirstFromPair(strA, strB);
    if (strA == first) {
      emit liquidityDataUpdated(
        tokenNameA, QString::fromStdString(reserves[0]),
        tokenNameB, QString::fromStdString(reserves[1]),
        QString::fromStdString(liquidity)
      );
    } else if (strB == first) {
      emit liquidityDataUpdated(
        tokenNameA, QString::fromStdString(reserves[1]),
        tokenNameB, QString::fromStdString(reserves[0]),
        QString::fromStdString(liquidity)
      );
    }
  });
}

QString QmlSystem::calculateExchangeAmount(
  QString amountIn, QString reservesIn, QString reservesOut, int inDecimals, int outDecimals
) {
  std::string amountInWei = Utils::fixedPointToWei(amountIn.toStdString(), inDecimals);
  std::string amountOut = Pangolin::calcExchangeAmountOut(
    amountInWei, reservesIn.toStdString(), reservesOut.toStdString()
  );
  amountOut = Utils::weiToFixedPoint(amountOut, outDecimals);
  return QString::fromStdString(amountOut);
}

double QmlSystem::calculateExchangePriceImpact(
  QString tokenAmount, QString tokenInput, int tokenDecimals
) {
  // Convert amounts to bigfloat and Wei for calculation
  bigfloat tokenAmountFloat = bigfloat(tokenAmount.toStdString());
  bigfloat tokenInputFloat = bigfloat(Utils::fixedPointToWei(
    tokenInput.toStdString(), tokenDecimals
  ));

  /**
   * Price impact is calculated as follows:
   * A = tokenAmount, B = tokenInput
   * Price impact = (1 - (A / (A + B))) * 100
   */
  bigfloat priceImpactFloat = (
    1 - tokenAmountFloat / (tokenAmountFloat + tokenInputFloat)
  ) * 100;

  // Round the percentage to two decimals and return it
  std::stringstream priceImpactss;
  priceImpactss << std::setprecision(2) << std::fixed << priceImpactFloat;
  double priceImpact = boost::lexical_cast<double>(priceImpactss.str());
  return priceImpact;
}

QString QmlSystem::calculateAddLiquidityAmount(
  QString amountIn, QString reservesIn, QString reservesOut
) {
  std::string amountInWei = Utils::fixedPointToWei(amountIn.toStdString(), 18);
  std::string amountOut = Pangolin::calcLiquidityAmountOut(
    amountInWei, reservesIn.toStdString(), reservesOut.toStdString()
  );
  amountOut = Utils::weiToFixedPoint(amountOut, 18);
  return QString::fromStdString(amountOut);
}

QVariantMap QmlSystem::calculateRemoveLiquidityAmount(
  QString asset1Reserves, QString asset2Reserves, QString percentage, QString pairBalance
) {
  QVariantMap ret;
  if (asset1Reserves.isEmpty()) { asset1Reserves = QString("0"); }
  if (asset2Reserves.isEmpty()) { asset2Reserves = QString("0"); }
  u256 asset1ReservesU256 = boost::lexical_cast<u256>(asset1Reserves.toStdString());
  u256 asset2ReservesU256 = boost::lexical_cast<u256>(asset2Reserves.toStdString());
  u256 userLPWei = boost::lexical_cast<u256>(
    Utils::fixedPointToWei(pairBalance.toStdString(), 18));

  bigfloat pc = bigfloat(boost::lexical_cast<double>(percentage.toStdString()) / 100);

  u256 userAsset1ReservesU256 = u256(bigfloat(asset1ReservesU256) * bigfloat(pc));
  u256 userAsset2ReservesU256 = u256(bigfloat(asset2ReservesU256) * bigfloat(pc));
  u256 userLPReservesU256 = u256(bigfloat(userLPWei) * bigfloat(pc));

  std::string lower = boost::lexical_cast<std::string>(userAsset1ReservesU256);
  std::string higher = boost::lexical_cast<std::string>(userAsset2ReservesU256);
  std::string lp = Utils::weiToFixedPoint(
    boost::lexical_cast<std::string>(userLPReservesU256), 18
  );

  ret.insert("lower", QString::fromStdString(lower));
  ret.insert("higher", QString::fromStdString(higher));
  ret.insert("lp", QString::fromStdString(lp));
  return ret;
}

QString QmlSystem::queryExchangeAmount(QString amount, QString fromName, QString toName) {
  // Convert QStrings to std::strings
  std::string amountStr = amount.toStdString();
  std::string fromStr = fromName.toStdString();
  std::string toStr = toName.toStdString();
  if (fromStr == "AVAX") { fromStr = "WAVAX"; }
  if (toStr == "AVAX") { toStr = "WAVAX"; }

  // reserves[0] = first/lower token, reserves[1] = second/higher token
  std::vector<std::string> reserves = Pangolin::getReserves(fromStr, toStr);
  std::string first = Pangolin::getFirstFromPair(fromStr, toStr);
  std::string input = Utils::fixedPointToWei(amountStr, 18);
  std::string output;
  if (fromStr == first) {
    output = Pangolin::calcExchangeAmountOut(input, reserves[0], reserves[1]);
  } else if (toStr == first) {
    output = Pangolin::calcExchangeAmountOut(input, reserves[1], reserves[0]);
  }
  output = Utils::weiToFixedPoint(output, 18);
  return QString::fromStdString(output);
}

QVariantMap QmlSystem::calculatePoolShares(
  QString asset1Reserves, QString asset2Reserves,
  QString userLiquidity, QString totalLiquidity
) {
  QVariantMap ret;
  u256 asset1ReservesU256 = boost::lexical_cast<u256>(asset1Reserves.toStdString());
  u256 asset2ReservesU256 = boost::lexical_cast<u256>(asset2Reserves.toStdString());
  u256 totalLiquidityU256 = boost::lexical_cast<u256>(totalLiquidity.toStdString());
  u256 userLiquidityU256 = boost::lexical_cast<u256>(
    Utils::fixedPointToWei(userLiquidity.toStdString(), 18)
  );

  bigfloat userLPPercentage = (
    bigfloat(userLiquidityU256) / bigfloat(totalLiquidityU256)
  );
  u256 userAsset1ReservesU256 = u256(bigfloat(asset1ReservesU256) * userLPPercentage);
  u256 userAsset2ReservesU256 = u256(bigfloat(asset2ReservesU256) * userLPPercentage);

  std::string asset1 = boost::lexical_cast<std::string>(userAsset1ReservesU256);
  std::string asset2 = boost::lexical_cast<std::string>(userAsset2ReservesU256);
  std::string liquidity = boost::lexical_cast<std::string>(userLPPercentage * 100);

  ret.insert("asset1", QString::fromStdString(asset1));
  ret.insert("asset2", QString::fromStdString(asset2));
  ret.insert("liquidity", QString::fromStdString(liquidity));
  return ret;
}

QVariantMap QmlSystem::calculatePoolSharesForTokenValue(
  QString lowerReserves, QString higherReserves, QString totalLiquidity, QString LPTokenValue
) {
  QVariantMap ret;
  u256 lowerReservesU256 = boost::lexical_cast<u256>(lowerReserves.toStdString());
  u256 higherReservesU256 = boost::lexical_cast<u256>(higherReserves.toStdString());
  u256 totalLiquidityU256 = boost::lexical_cast<u256>(totalLiquidity.toStdString());
  u256 userLiquidityU256 = boost::lexical_cast<u256>(
    Utils::fixedPointToWei(LPTokenValue.toStdString(), 18)
  );

  bigfloat userLPPercentage = (
    bigfloat(userLiquidityU256) / bigfloat(totalLiquidityU256)
  );
  u256 userLowerReservesU256 = u256(bigfloat(lowerReservesU256) * userLPPercentage);
  u256 userHigherReservesU256 = u256(bigfloat(higherReservesU256) * userLPPercentage);

  std::string lower = boost::lexical_cast<std::string>(userLowerReservesU256);
  std::string higher = boost::lexical_cast<std::string>(userHigherReservesU256);
  std::string liquidity = boost::lexical_cast<std::string>(userLPPercentage * 100);

  ret.insert("lower", QString::fromStdString(lower));
  ret.insert("higher", QString::fromStdString(higher));
  ret.insert("liquidity", QString::fromStdString(liquidity));
  return ret;
}
