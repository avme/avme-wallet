// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "main-gui.h"

// Implementation of AVME Wallet as a GUI (Qt) program.

int main(int argc, char *argv[]) {
  // Setup boost::filesystem environment
  boost::nowide::nowide_filesystem();

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

  QmlSystem qmlsystem;
  qmlsystem.setEngine(&engine);

  engine.rootContext()->setContextProperty("qmlSystem", &qmlsystem);
  qmlRegisterType<QmlApi>("QmlApi", 1, 0, "QmlApi");

  // Set the app's text font and icon
  QFontDatabase::addApplicationFont(":/fonts/IBMPlexMono-Bold.ttf");
  QFontDatabase::addApplicationFont(":/fonts/IBMPlexMono-Italic.ttf");
  QFontDatabase::addApplicationFont(":/fonts/IBMPlexMono-Regular.ttf");
  QFont font("IBM Plex Mono");
  font.setStyleHint(QFont::Monospace);
  QApplication::setFont(font);
  app.setWindowIcon(QIcon(":/img/avme_logo.png"));

  // Load the main screen, link the required signals/slots and start the app
  engine.load(QUrl(QStringLiteral("qrc:/qml/screens/main.qml")));
  if (engine.rootObjects().isEmpty()) return -1;

  // Create Websocket server object.
  qmlsystem.setWSServer();

  // Create 
  QObject::connect(&app, SIGNAL(aboutToQuit()), &qmlsystem, SLOT(cleanAndClose()));
  return app.exec();
}

