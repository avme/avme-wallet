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

#include "version.h"

/**
 * Wrappers for common stuff that is shared across the whole program.
 */
class QmlSystem : public QObject {
  Q_OBJECT

  public:
    Wallet w;
    ledger::device ledgerDevice;
    bool firstLoad;
    bool ledgerFlag;

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
}

#endif  //QTSYSTEM_H
