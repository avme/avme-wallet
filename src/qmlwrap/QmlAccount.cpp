// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

QString QmlSystem::getCurrentAccount() {
  return QString::fromStdString(this->w.getCurrentAccount().first);
}

void QmlSystem::setCurrentAccount(QString address) {
  this->w.setCurrentAccount(address.toStdString());
}

void QmlSystem::loadAccounts() {
  this->w.loadAccounts();
}

QVariantList QmlSystem::listAccounts() {
  QVariantList ret;
  for (std::pair<std::string, std::string> a : this->w.getAccounts()) {
    std::string obj;
    // TODO: Use nlohmann/json
    obj += "{\"address\": \"" + a.first;
    obj += "\", \"name\": \"" + a.second;
    obj += "\"}";
    ret << QString::fromStdString(obj);
  }
  return ret;
}

/*
bool QmlSystem::accountHasBalances(QString address) {
  bool hasBalances = false;
  for (Account &a : this->w.accounts) {
    if (a.address == address.toStdString()) {
      a.balancesThreadLock.lock();
      hasBalances = (
        a.balanceAVAX != "" && a.balanceAVME != "" &&
        a.balanceLPFree != "" && a.balanceLPLocked != "" &&
        a.balanceLockedCompoundLP != ""
      );
      a.balancesThreadLock.unlock();
      break;
    }
  }
  return hasBalances;
}
*/

void QmlSystem::generateAccounts(QString seed, int idx) {
  QtConcurrent::run([=](){
    QVariantList ret;
    std::vector<std::string> list = BIP39::generateAccountsFromSeed(seed.toStdString(), idx);
    for (std::string s : list) {
      QVariantMap obj;
      std::stringstream listss(s);
      std::string item;
      int ct = 0;
      while (std::getline(listss, item, ' ')) {
        QString itemStr = QString::fromStdString(item);
        switch (ct) {
          case 0: obj["idx"] = QVariant(itemStr); break;
          case 1: obj["account"] = QVariant(itemStr); break;
          case 2: obj["balance"] = QVariant(itemStr); break;
        }
        ct++;
      }
      emit accountGenerated(obj);
    }
  });
}

void QmlSystem::generateLedgerAccounts(QString path, int idx) {
  QtConcurrent::run([=](){
    QVariantList ret;
    for (int i = idx; i < idx + 10; i++) {
      std::string fullPath = path.toStdString() + boost::lexical_cast<std::string>(i);
      this->ledgerDevice.generateBip32Account(fullPath);
    }
    for (ledger::account acc : this->ledgerDevice.getAccountList()) {
      QVariantMap obj;
      std::string idxStr = acc.index.substr(acc.index.find_last_of("/") + 1);
      std::string bal = API::getAVAXBalance(acc.address);
      u256 AVAXbalance = boost::lexical_cast<HexTo<u256>>(bal);
      obj["idx"] = QVariant(QString::fromStdString(idxStr));
      obj["account"] = QVariant(QString::fromStdString(acc.address));
      obj["balance"] = QVariant(QString::fromStdString(Utils::weiToFixedPoint(
        boost::lexical_cast<std::string>(AVAXbalance), 18
      )));
      emit ledgerAccountGenerated(obj);
    }
  });
}

void QmlSystem::cleanLedgerAccounts() {
  this->ledgerDevice.cleanAccountList();
}

void QmlSystem::createAccount(QString seed, int index, QString name, QString pass) {
  QtConcurrent::run([=](){
    QVariantMap obj;
    std::string seedStr = seed.toStdString();
    std::string nameStr = name.toStdString();
    std::string passStr = pass.toStdString();
    std::pair<std::string, std::string> a;
    a = this->w.createAccount(seedStr, index, nameStr, passStr);
    if (!a.first.empty()) {
      obj.insert("accAddress", "0x" + QString::fromStdString(a.first));
      obj.insert("accName", QString::fromStdString(a.second));
      emit accountCreated(obj);
    } else {
      emit accountCreationFailed();
    }
  });
}

void QmlSystem::importLedgerAccount(QString address, QString path) {
  this->w.importLedgerAccount(address.toStdString(), path.toStdString());
}

bool QmlSystem::eraseAccount(QString account) {
  return this->w.eraseAccount(account.toStdString());
}

bool QmlSystem::accountExists(QString account) {
  return this->w.accountExists(account.toStdString());
}

QString QmlSystem::getPrivateKeys(QString account, QString pass) {
  Secret s = this->w.getSecret(account.toStdString(), pass.toStdString());
  std::string key = toHex(s.ref());
  return QString::fromStdString(key);
}

void QmlSystem::getAccountAVAXBalances(QString address) {
  QtConcurrent::run([=](){
    std::string avaxBal = API::getAVAXBalance(address.toStdString());
    bigfloat avaxUSDPrice = boost::lexical_cast<bigfloat>(Graph::getAVAXPriceUSD());
    bigfloat avaxBalFloat = boost::lexical_cast<bigfloat>(avaxBal);
    bigfloat avaxUSDValueFloat = avaxUSDPrice * avaxBalFloat;
    std::stringstream ss;
    ss << std::setprecision(2) << std::fixed << avaxUSDValueFloat;
    std::string avaxUSDValue = ss.str();
    emit accountAVAXBalancesUpdated(
      address, QString::fromStdString(avaxBal), QString::fromStdString(avaxUSDValue)
    );
  });
}

void QmlSystem::getAllAVAXBalances(QStringList addresses) {
  QtConcurrent::run([=](){
    std::vector<std::string> addressesVec, balancesVec;
    for (int i = 0; i < addresses.size(); i++) {
      addressesVec.push_back(addresses.at(i).toStdString());
    }
    balancesVec = API::getAVAXBalances(addressesVec);
    bigfloat avaxUSDPrice = boost::lexical_cast<bigfloat>(Graph::getAVAXPriceUSD());
    for (int i = 0; i < balancesVec.size(); i++) {
      bigfloat avaxBalFloat = boost::lexical_cast<bigfloat>(balancesVec[i]);
      bigfloat avaxUSDValueFloat = avaxUSDPrice * avaxBalFloat;
      std::stringstream ss;
      ss << std::setprecision(2) << std::fixed << avaxUSDValueFloat;
      std::string avaxUSDValue = ss.str();
      emit accountAVAXBalancesUpdated(
        QString::fromStdString(addressesVec[i]),
        QString::fromStdString(balancesVec[i]),
        QString::fromStdString(avaxUSDValue)
      );
    }
  });
}

bool QmlSystem::loadTokenDB() {
  return this->w.loadTokenDB();
}

bool QmlSystem::loadHistoryDB(QString address) {
  return this->w.loadHistoryDB(address.toStdString());
}
