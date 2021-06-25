// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

void QmlSystem::getPoolReward() {
  QtConcurrent::run([=](){
    std::string poolRewardWei = Staking::earned(
      this->w.getCurrentAccount().first
    );
    std::string poolReward = Utils::weiToFixedPoint(poolRewardWei, 18);
    emit rewardUpdated(QString::fromStdString(poolReward));
  });
}

void QmlSystem::getCompoundReward() {
  QtConcurrent::run([=](){
    std::string poolRewardWei = Staking::getCompoundReward();
    std::string poolReward = Utils::weiToFixedPoint(poolRewardWei, 18);
    emit compoundUpdated(QString::fromStdString(poolReward));
  });
}
