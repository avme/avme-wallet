#include "main-gui.h"

// Implementation of AVME Wallet as a GUI (Qt) program.

int main(int argc, char *argv[]) {
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QGuiApplication app(argc, argv);
  QQmlApplicationEngine engine;
  System sys;
  engine.rootContext()->setContextProperty("System", &sys);
  engine.load(QUrl(QStringLiteral("qrc:/screens/main.qml")));
  if (engine.rootObjects().isEmpty()) return -1;
  return app.exec();
}
