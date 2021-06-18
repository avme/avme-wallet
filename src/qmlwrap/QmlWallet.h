// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef QMLWALLET_H
#define QMLWALLET_H

#include <QtCore/QFile>
#include <QtCore/QString>
#include <QtCore/QVariant>

#include <lib/ledger/ledger.h>

#include <core/BIP39.h>
#include <core/Wallet.h>

#include <qmlwrap/QmlSystem.h>

/**
 * Wrappers for the Start screen (where the Wallet is created/imported/loaded).
 */
class QmlWallet : public QObject {
  Q_OBJECT

  public:
    // Check if a Wallet exists in a given folder
    Q_INVOKABLE bool checkFolderForWallet(QString folder) {
      QString walletFile = QString(folder + "/wallet/c-avax/wallet.info");
      QString secretsFolder = QString(folder + "/wallet/c-avax/accounts/secrets");
      return (QFile::exists(walletFile) && QFile::exists(secretsFolder));
    }

    // Create, import, load and close a Wallet, respectively
    // TODO: join this and import with 'QString seed = ""' as a parameter
    Q_INVOKABLE bool createWallet(QString folder, QString pass) {
      std::string passStr = pass.toStdString();
      bool createSuccess = QmlSystem::getWallet()->create(folder.toStdString(), passStr);
      bip3x::Bip39Mnemonic::MnemonicResult mnemonic = BIP39::createNewMnemonic();
      std::pair<bool,std::string> seedSuccess = BIP39::saveEncryptedMnemonic(mnemonic, passStr);
      return (createSuccess && seedSuccess.first);
    }

    Q_INVOKABLE bool importWallet(QString seed, QString folder, QString pass) {
      std::string passStr = pass.toStdString();
      bool createSuccess = QmlSystem::getWallet()->create(folder.toStdString(), passStr);
      bip3x::Bip39Mnemonic::MnemonicResult mnemonic;
      mnemonic.raw = seed.toStdString();
      std::pair<bool,std::string> seedSuccess = BIP39::saveEncryptedMnemonic(mnemonic, passStr);
      return (createSuccess && seedSuccess.first);
    }

    Q_INVOKABLE bool loadWallet(QString folder, QString pass) {
      std::string passStr = pass.toStdString();
      bool loadSuccess = QmlSystem::getWallet()->load(folder.toStdString(), passStr);
      return loadSuccess;
    }

    Q_INVOKABLE void closeWallet() {
      QmlSystem::getWallet()->close();
    }

    // Check if the Wallet is loaded
    Q_INVOKABLE bool isWalletLoaded() {
      return QmlSystem::getWallet()->isLoaded();
    }

    // Check if given passphrase equals the Wallet's
    Q_INVOKABLE bool checkWalletPass(QString pass) {
      return QmlSystem::getWallet()->auth(pass.toStdString());
    }

    // Get the seed for the Wallet
    Q_INVOKABLE QString getWalletSeed(QString pass) {
      std::string passStr = pass.toStdString();
      bip3x::Bip39Mnemonic::MnemonicResult mnemonic;
      std::pair<bool,std::string> seedSuccess = BIP39::loadEncryptedMnemonic(mnemonic, passStr);
      return (seedSuccess.first) ? QString::fromStdString(mnemonic.raw) : "";
    }

    // Check if Ledger device is connected
    Q_INVOKABLE QVariantMap checkForLedger() {
      QVariantMap ret;
      std::pair<bool, std::string> check = QmlSystem::getLedgerDevice()->checkForDevice();
      ret.insert("state", check.first);
      ret.insert("message", QString::fromStdString(check.second));
      return ret;
    }

    // Check if a BIP39 seed is valid
    Q_INVOKABLE bool seedIsValid(QString seed) {
      std::stringstream ss(seed.toStdString());
      std::string word;
      int ct = 0;
      while (std::getline(ss, word, ' ')) {
        if (!BIP39::wordExists(word)) { return false; }
        ct++;
      }
      if (ct != 12) { return false; }
      return true;
    }
};

#endif  // QTWALLET_H
