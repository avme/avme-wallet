#ifndef MAIN_GUI_H
#define MAIN_GUI_H

#include <QtGui/QGuiApplication>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlApplicationEngine>
#include <QtCore/QString>
#include <QtCore/qplugin.h>

Q_IMPORT_PLUGIN(QXcbIntegrationPlugin)
Q_IMPORT_PLUGIN(QtQuick2Plugin)
Q_IMPORT_PLUGIN(QtQuick2WindowPlugin)
Q_IMPORT_PLUGIN(QtQuickTemplates2Plugin)
Q_IMPORT_PLUGIN(QtQuickControls2Plugin)

#include "lib/wallet.h"

// QObject for interfacing between C++ and QML
class System : public QObject {
  Q_OBJECT

  public:
    // Change the current loaded screen
    Q_INVOKABLE void setScreen(QObject* loader, QString qmlFile) {
      //loader->setProperty("source", "qrc:/" + qmlFile);
      loader->setProperty("source", "qml/" + qmlFile); // TODO: revert this when qrc compiling is fixed
    }
};

#endif // MAIN_GUI_H
