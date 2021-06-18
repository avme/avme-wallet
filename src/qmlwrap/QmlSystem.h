// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef QMLSYSTEM_H
#define QMLSYSTEM_H

#include <QtCore/QString>
#include <QtGui/QClipboard>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtWidgets/QApplication>

#include <core/JSON.h>
#include <core/Utils.h>

#include "version.h"

/**
 * Wrappers for common stuff that is shared across the whole program.
 */
class QmlSystem : public QObject {
  Q_OBJECT

  signals:
    void hideMenu();
    void goToOverview();

  public slots:
    void cleanAndClose() {
      // TODO: Clean database, threads, etc before closing the program
      return;
    }

  private:
    static Wallet* w;
    static ledger::device* ledgerDevice;
    static bool firstLoad;
    static bool ledgerFlag;

  public:
    // Getters/Setters for private vars
    static Wallet* getWallet() { return w; }
    static ledger::device* getLedgerDevice() { return ledgerDevice; }
    static bool getFirstLoad() { return firstLoad; }
    static void setFirstLoad(bool b) { firstLoad = b; }
    static bool getLedgerFlag() { return ledgerDevice; }
    static void setLedgerFlag(bool b) { ledgerFlag = b; }

    // Get the project's version
    Q_INVOKABLE QString getProjectVersion() {
      return QString::fromStdString(PROJECT_VERSION);
    }

    // Open the "About Qt" window
    Q_INVOKABLE void openQtAbout() {
      QApplication::aboutQt();
    }

    // Change the current loaded screen
    Q_INVOKABLE void setScreen(QObject* loader, QString qmlFile) {
      loader->setProperty("source", "qrc:/" + qmlFile);
    }

    // Copy a string to the system clipboard
    Q_INVOKABLE void copyToClipboard(QString str) {
      QApplication::clipboard()->setText(str);
    }

    // Get the default path for a Wallet
    Q_INVOKABLE QString getDefaultWalletPath() {
      return QString::fromStdString(JSON::getDataDir().string());
    }

    // Remove the "file://" prefix from a folder path
    Q_INVOKABLE QString cleanPath(QString path) {
      #ifdef __MINGW32__
        return path.remove("file:///");
      #else
        return path.remove("file://");
      #endif
    }

    // Convert fixed point to Wei and vice-versa
    Q_INVOKABLE QString fixedPointToWei(QString amount, int decimals) {
      return QString::fromStdString(
        Utils::fixedPointToWei(amount.toStdString(), decimals)
      );
    }

    Q_INVOKABLE QString weiToFixedPoint(QString amount, int digits) {
      return QString::fromStdString(
        Utils::weiToFixedPoint(amount.toStdString(), digits)
      );
    }

    // Check if a balance is zero
    Q_INVOKABLE bool balanceIsZero(QString amount, int decimals) {
      u256 amountU256 = u256(Utils::fixedPointToWei(amount.toStdString(), decimals));
      return (amountU256 == 0);
    }

    // Check if a balance is higher than another
    Q_INVOKABLE bool firstHigherThanSecond(QString first, QString second) {
      bigfloat firstFloat = boost::lexical_cast<bigfloat>(first.toStdString());
      bigfloat secondFloat = boost::lexical_cast<bigfloat>(second.toStdString());
      return (firstFloat > secondFloat);
    }
};

#endif  //QTSYSTEM_H
