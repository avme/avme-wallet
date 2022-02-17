// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "main-gui.h"

// Handler for clean exit on system signals
void handleExit(int sig) {
  std::string sigName;
  switch (sig) {
    case SIGABRT: sigName = "SIGABRT"; break;
    case SIGINT: sigName = "SIGINT"; break;
    case SIGSEGV: sigName = "SIGSEGV"; break;
    case SIGTERM: sigName = "SIGTERM"; break;
  }
  boost::interprocess::named_mutex::remove("AVMEWallet");
  std::cout << "Received " << sigName << ", exiting" << std::endl;
  exit(sig);
}

// Implementation of AVME Wallet as a GUI (Qt) program.
int main(int argc, char *argv[]) {
  // Set up system signal handlers
  signal(SIGABRT, handleExit);
  signal(SIGINT, handleExit);
  signal(SIGSEGV, handleExit);
  signal(SIGTERM, handleExit);

  // Prevent multiple instances of the program
  try {
    boost::interprocess::named_mutex progLock(
      boost::interprocess::create_only, "AVMEWallet"
    );
  } catch (boost::interprocess::interprocess_exception &ex) {
    std::cout << "Program is already running" << std::endl;
    return 1;
  }

  // Setup boost::filesystem environment, Qt's <APPNAME> for QStandardPaths
  // and Linux's fontconfig path
  boost::nowide::nowide_filesystem();
  QApplication::setApplicationName("AVME");
  #ifdef __linux__
  putenv((char*)("FONTCONFIG_PATH=/etc/fonts"));
  #endif

  // Get the system's DPI scale using a dummy temp QApplication
  QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  #if !defined(__APPLE__)
    QApplication* temp = new QApplication(argc, argv);
    double scaleFactor = temp->screens()[0]->logicalDotsPerInch() / 96.0;
    delete temp;
    qputenv("QT_SCALE_FACTOR", QByteArray::number(scaleFactor));
  #endif

  // Create the actual application, register our custom classes into it and
  // initialize the global thread pool.
  // A high enough max thread count should avoid taking too long to answer
  // towards the websocket server.
  QApplication app(argc, argv);
  QQmlApplicationEngine engine;
  QmlSystem qmlsystem;
  qmlsystem.setEngine(&engine);
  qmlsystem.setApp(&app);
  engine.rootContext()->setContextProperty("qmlSystem", &qmlsystem);
  qmlRegisterType<QmlApi>("QmlApi", 1, 0, "QmlApi");
  #ifdef __APPLE__
    QThreadPool::globalInstance()->setMaxThreadCount(16);
  #else
    QThreadPool::globalInstance()->setMaxThreadCount(32);
  #endif

  // Set the app's text font and icon
  QFontDatabase::addApplicationFont(":/fonts/IBMPlexMono-Bold.ttf");
  QFontDatabase::addApplicationFont(":/fonts/IBMPlexMono-Italic.ttf");
  QFontDatabase::addApplicationFont(":/fonts/IBMPlexMono-Regular.ttf");
  QFont font("IBM Plex Mono");
  font.setStyleHint(QFont::Monospace);
  QApplication::setFont(font);
  app.setWindowIcon(QIcon(":/img/avme_logo.png"));

  // Start the app and websocket server
  engine.load(QUrl(QStringLiteral("qrc:/qml/screens/main.qml")));
  if (engine.rootObjects().isEmpty()) return -1;
  qmlsystem.setWSServer();
  auto returnStatus = app.exec();

  // Properly close the app
  qmlsystem.cleanAndCloseWallet();
  boost::interprocess::named_mutex::remove("AVMEWallet");
  return returnStatus;
}

