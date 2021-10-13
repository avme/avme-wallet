// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

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


void  QmlSystem::getParaSwapTokenPrices(QString srcToken, 
                             QString srcDecimals, 
                             QString destToken,
                             QString destDecimals,
                             QString weiAmount,
                             QString chainID,
                             QString side,
                             QString id) {
  QtConcurrent::run([=](){
    json request;

    request["srcToken"] = srcToken.toStdString();
    request["srcDecimals"] = srcDecimals.toStdString();
    request["destToken"] = destToken.toStdString();
    request["destDecimals"] = destDecimals.toStdString();
    request["weiAmount"] = weiAmount.toStdString();
    request["side"] = side.toStdString();
    request["chainID"] = chainID.toStdString();

    std::string ret = ParaSwap::getTokenPrices(srcToken.toStdString(), 
                             srcDecimals.toStdString(), 
                             destToken.toStdString(),
                             destDecimals.toStdString(),
                             weiAmount.toStdString(),
                             side.toStdString(),
                             chainID.toStdString());

    emit gotParaSwapTokenPrices(QString::fromStdString(ret), id, QString::fromStdString(request.dump()));
  });   
}
                          
void QmlSystem::getParaSwapTransactionData(QString priceRouteStr, 
                                                QString slippage, 
                                                QString userAddress, 
                                                QString fee,
                                                QString id) {
  QtConcurrent::run([=](){
    json request;

    request["priceRouteStr"] = priceRouteStr.toStdString();
    request["slippage"] = slippage.toStdString();
    request["userAddress"] = userAddress.toStdString();
    request["fee"] = fee.toStdString();

    std::string ret = ParaSwap::getTransactionData(priceRouteStr.toStdString(),
                                                   slippage.toStdString(),
                                                   userAddress.toStdString(),
                                                   fee.toStdString());

    emit gotParaSwapTransactionData(QString::fromStdString(ret), id, QString::fromStdString(request.dump()));
  });                                         
}