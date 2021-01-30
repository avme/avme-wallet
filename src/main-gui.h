#ifndef MAIN_GUI_H
#define MAIN_GUI_H

#include <QtGui/QGuiApplication>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtCore/QString>

#include "lib/wallet.h"

// QObject for interfacing between C++ and QML
class System : public QObject {
  Q_OBJECT

  public:
    // Change the current loaded screen
    Q_INVOKABLE void setScreen(QObject* loader, QString qmlFile) {
      loader->setProperty("source", "qrc:/" + qmlFile);
    }
};

#endif // MAIN_GUI_H
