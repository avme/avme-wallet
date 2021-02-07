#include "main-gui.h"

// Implementation of AVME Wallet as a GUI (Qt) program.

int main(int argc, char *argv[]) {
  // Set logging options to default to suppress debug strings (e.g. when reading key files).
  dev::LoggingOptions loggingOptions;
  dev::setupLogging(loggingOptions);

  // Create the application and register our custom class into it
  QApplication app(argc, argv);
  QQmlApplicationEngine engine;
  System sys;
  engine.rootContext()->setContextProperty("System", &sys);

  // Force a monospaced font for the app
  QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QFont font("Monospace");
  font.setStyleHint(QFont::Monospace);
  QApplication::setFont(font);

  // Load the main screen and start the app
  engine.load(QUrl(QStringLiteral("qrc:/qml/screens/main.qml")));
  if (engine.rootObjects().isEmpty()) return -1;
  return app.exec();
}

