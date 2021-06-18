// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "main-gui.h"
#include <hidapi/hidapi.h>

// Implementation of AVME Wallet as a GUI (Qt) program.

int main(int argc, char *argv[]) {
  // Get the system's DPI scale using a dummy temp QApplication
  QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  #if !defined(__APPLE__)
    QApplication* temp = new QApplication(argc, argv);
    double scaleFactor = temp->screens()[0]->logicalDotsPerInch() / 96.0;
    delete temp;
    qputenv("QT_SCALE_FACTOR", QByteArray::number(scaleFactor));
  #endif

  // Create the actual application and register our custom classes into it
  QApplication app(argc, argv);
  QQmlApplicationEngine engine;
  System sys;
  QmlSystem qmlsystem;
  QmlWallet qmlwallet;
  QmlAccount qmlaccount;
  QmlOverview qmloverview;
  QmlHistory qmlhistory;
  QmlSend qmlsend;
  QmlExchange qmlexchange;
  QmlStaking qmlstaking;
  engine.rootContext()->setContextProperty("System", &sys);
  engine.rootContext()->setContextProperty("QmlSystem", &qmlsystem);
  engine.rootContext()->setContextProperty("QmlWallet", &qmlwallet);
  engine.rootContext()->setContextProperty("QmlAccount", &qmlaccount);
  engine.rootContext()->setContextProperty("QmlOverview", &qmloverview);
  engine.rootContext()->setContextProperty("QmlHistory", &qmlhistory);
  engine.rootContext()->setContextProperty("QmlSend", &qmlsend);
  engine.rootContext()->setContextProperty("QmlExchange", &qmlexchange);
  engine.rootContext()->setContextProperty("QmlStaking", &qmlstaking);

  // Set the app's text font and icon
  QFontDatabase::addApplicationFont(":/fonts/RobotoMono-Bold.ttf");
  QFontDatabase::addApplicationFont(":/fonts/RobotoMono-Italic.ttf");
  QFontDatabase::addApplicationFont(":/fonts/RobotoMono-Regular.ttf");
  QFont font("Roboto Mono");
  font.setStyleHint(QFont::Monospace);
  QApplication::setFont(font);
  app.setWindowIcon(QIcon(":/img/avme_logo.png"));

  // Load the main screen and start the app
  engine.load(QUrl(QStringLiteral("qrc:/qml/screens/main.qml")));
  if (engine.rootObjects().isEmpty()) return -1;
  QObject::connect(&app, SIGNAL(aboutToQuit()), &sys, SLOT(cleanAndClose()));
  return app.exec();
}

