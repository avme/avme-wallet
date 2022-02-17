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

Q_IMPORT_PLUGIN(QGifPlugin)
Q_IMPORT_PLUGIN(QSvgPlugin)
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
#endif
Q_IMPORT_PLUGIN(QtQuick2Plugin)
Q_IMPORT_PLUGIN(QtQuick2WindowPlugin)
Q_IMPORT_PLUGIN(QtQuickTemplates2Plugin)
Q_IMPORT_PLUGIN(QtQuickControls2Plugin)
Q_IMPORT_PLUGIN(QtLabsPlatformPlugin)
Q_IMPORT_PLUGIN(QtChartsQml2Plugin)

#include <lib/ledger/ledger.h>

#include <network/API.h>
#include <core/BIP39.h>
#include <core/Utils.h>
#include <core/Wallet.h>
#include <network/Graph.h>
#include <network/Pangolin.h>
#include <network/Staking.h>
#include <network/ParaSwap.h>

#include <qmlwrap/QmlSystem.h>
#include <qmlwrap/QmlApi.h>

#include <hidapi/hidapi.h>

#include <boost/interprocess/sync/named_mutex.hpp>

#include <csignal>

#include "version.h"

#endif // MAIN_GUI_H
