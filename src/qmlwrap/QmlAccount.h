// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef QMLACCOUNT_H
#define QMLACCOUNT_H

#include <QtConcurrent/qtconcurrentrun.h>
#include <QtCore/QString>
#include <QtCore/QVariant>

#include <qmlwrap/QmlSystem.h>

/**
 * Wrappers for the Account screen.
 */
class QmlAccount : public QObject {
  Q_OBJECT

  signals:
    void accountGenerated(QVariantMap data);
    void ledgerAccountGenerated(QVariantMap data);
    void accountCreated(QVariantMap data);
    void accountCreationFailed();

  public:
    // Load the Accounts into the Wallet
    Q_INVOKABLE void loadAccounts() {
      QmlSystem::getWallet()->loadAccounts();
    }

    // List the Wallet's Accounts
    Q_INVOKABLE QVariantList listAccounts() {
      QVariantList ret;
      for (std::pair<std::string, std::string> a : QmlSystem::getWallet()->getAccounts()) {
        std::string obj;
        obj += "{\"account\": \"" + a.first;
        obj += "\", \"name\": \"" + a.second;
        ret << QString::fromStdString(obj);
      }
      return ret;
    }

    // Check if an Account has loaded the balances
    // TODO: check this later
    /*
    Q_INVOKABLE bool accountHasBalances(QString address) {
      bool hasBalances = false;
      for (Account &a : QmlSystem::getWallet()->accounts) {
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

    // Generate an Account list from a given seed, starting from a given index
    Q_INVOKABLE void generateAccounts(QString seed, int idx) {
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

    // Same as above but for Ledger devices
    Q_INVOKABLE void generateLedgerAccounts(QString path, int idx) {
      QtConcurrent::run([=](){
        QVariantList ret;
        for (int i = idx; i < idx + 10; i++) {
          std::string fullPath = path.toStdString() + boost::lexical_cast<std::string>(i);
          QmlSystem::getLedgerDevice()->generateBip32Account(fullPath);
        }
        for (ledger::account acc : QmlSystem::getLedgerDevice()->getAccountList()) {
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

    // Clean up the Ledger account vector
    Q_INVOKABLE void cleanLedgerAccounts() {
      QmlSystem::getLedgerDevice()->cleanAccountList();
    }

    // Create a new Account
    Q_INVOKABLE void createAccount(QString seed, int index, QString name, QString pass) {
      QtConcurrent::run([=](){
        QVariantMap obj;
        std::string seedStr = seed.toStdString();
        std::string nameStr = name.toStdString();
        std::string passStr = pass.toStdString();
        std::pair<std::string, std::string> a;
        a = QmlSystem::getWallet()->createAccount(seedStr, index, nameStr, passStr);
        if (!a.first.empty()) {
          obj.insert("accAddress", "0x" + QString::fromStdString(a.first));
          obj.insert("accName", QString::fromStdString(a.second));
          emit accountCreated(obj);
        } else {
          emit accountCreationFailed();
        }
      });
    }

    // Import a Ledger account to the Wallet
    Q_INVOKABLE void importLedgerAccount(QString address, QString path) {
      QmlSystem::getWallet()->importLedgerAccount(address.toStdString(), path.toStdString());
    }

    // Erase an Account
    Q_INVOKABLE bool eraseAccount(QString account) {
      return QmlSystem::getWallet()->eraseAccount(account.toStdString());
    }

    // Check if Account exists
    Q_INVOKABLE bool accountExists(QString account) {
      return QmlSystem::getWallet()->accountExists(account.toStdString());
    }

    // Get an Account's private keys
    Q_INVOKABLE QString getPrivateKeys(QString account, QString pass) {
      Secret s = QmlSystem::getWallet()->getSecret(account.toStdString(), pass.toStdString());
      std::string key = toHex(s.ref());
      return QString::fromStdString(key);
    }

    // Get an Account's balances
    // TODO: check this later
    /*
    Q_INVOKABLE QVariantMap getAccountBalances(QString address) {
      QVariantMap ret;
      for (std::pair<std::string, std::string> a : QmlSystem::getWallet()->getAccounts()) {
        if (a.first == address.toStdString()) {
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
      return ret;
    }
    */
};

#endif  // QMLACCOUNT_H
