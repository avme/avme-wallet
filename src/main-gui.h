// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef MAIN_GUI_H
#define MAIN_GUI_H

#include <QtWidgets/QApplication>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtCore/QFile>
#include <QtCore/QString>
#include <QtCore/QVariant>
#include <QtCore/qplugin.h>
#include <QtGui/QClipboard>
#include <QtGui/QFont>
#include <QtGui/QFontDatabase>
#include <QtGui/QIcon>
#include <QtGui/QScreen>
#include <QtCore/QThread>
#include <QtCore/QDateTime>
#include <QtConcurrent/qtconcurrentrun.h>

#ifdef __MINGW32__
Q_IMPORT_PLUGIN(QWindowsIntegrationPlugin)
// Redefine the WINNT version for MinGW to use Windows 7 instead of XP
#undef _WIN32_WINNT
#define _WIN32_WINNT 0x0601
#define WINVER 0x0601
#else
#ifdef __APPLE__
Q_IMPORT_PLUGIN(QCocoaIntegrationPlugin)
#else
Q_IMPORT_PLUGIN(QXcbIntegrationPlugin)
#endif
#undef FONTCONFIG_PATH
#define FONTCONFIG_PATH "/etc/fonts" // Redefine fontconfig path for the program.
#endif
Q_IMPORT_PLUGIN(QtQuick2Plugin)
Q_IMPORT_PLUGIN(QtQuick2WindowPlugin)
Q_IMPORT_PLUGIN(QtQuickTemplates2Plugin)
Q_IMPORT_PLUGIN(QtQuickControls2Plugin)
Q_IMPORT_PLUGIN(QtLabsPlatformPlugin)
Q_IMPORT_PLUGIN(QtChartsQml2Plugin)

#include <lib/ledger/ledger.h>

#include <core/BIP39.h>
#include <core/Utils.h>
#include <core/Wallet.h>
#include <network/API.h>
#include <network/Graph.h>
#include <network/Pangolin.h>
#include <network/Staking.h>

#include <qmlwrap/QmlSystem.h>
#include <qmlwrap/QmlWallet.h>
#include <qmlwrap/QmlAccount.h>
#include <qmlwrap/QmlOverview.h>
#include <qmlwrap/QmlHistory.h>
#include <qmlwrap/QmlSend.h>
#include <qmlwrap/QmlExchange.h>
#include <qmlwrap/QmlStaking.h>

#include "version.h"

// QObject/wrapper for interfacing between C++ (wallet) and QML (gui)
class System : public QObject {
  Q_OBJECT
};

#endif // MAIN_GUI_H
