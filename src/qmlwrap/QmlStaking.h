// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef QMLSTAKING_H
#define QMLSTAKING_H

#include <QtConcurrent/qtconcurrentrun.h>
#include <QtCore/QString>

#include <core/Utils.h>
#include <network/Staking.h>

#include <qmlwrap/QmlSystem.h>

/**
 * Wrappers for the Staking screen.
 */
class QmlStaking : public QObject {
  Q_OBJECT

  signals:
    // TODO: change to stakingAllowancesUpdated(staking, compound)
    void allowancesUpdated(
      QString exchangeAllowance, QString liquidityAllowance, QString stakingAllowance, QString compoundAllowance
    );
    void rewardUpdated(QString poolReward);
    void compoundUpdated(QString reinvestReward);

  public:
    // Get the staking and compound rewards for a given Account, respectively.
    Q_INVOKABLE void getPoolReward() {
      QtConcurrent::run([=](){
        std::string poolRewardWei = Staking::earned(this->currentAccount);
        std::string poolReward = Utils::weiToFixedPoint(poolRewardWei, this->currentCoinDecimals);
        emit rewardUpdated(QString::fromStdString(poolReward));
      });
    }

    Q_INVOKABLE void getCompoundReward() {
      QtConcurrent::run([=](){
        std::string poolRewardWei = Staking::getCompoundReward();
        std::string poolReward = Utils::weiToFixedPoint(poolRewardWei, this->currentCoinDecimals);
        emit compoundUpdated(QString::fromStdString(poolReward));
      });
    }
}

#endif // QMLSTAKING_H
