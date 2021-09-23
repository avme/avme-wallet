// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

QVariantList QmlSystem::listWalletContacts() {
  QVariantList ret;
  std::map<std::string, std::string> contacts = this->w.getContacts();
  for (std::pair<std::string, std::string> contact : contacts) {
    QVariantMap contactObj;
    contactObj["address"] = QString::fromStdString(contact.first);
    contactObj["name"] = QString::fromStdString(contact.second);
    ret << contactObj;
  }
  return ret;
}

bool QmlSystem::addContact(QString address, QString name) {
  return this->w.addContact(address.toStdString(), name.toStdString());
}

bool QmlSystem::removeContact(QString address) {
  return this->w.removeContact(address.toStdString());
}

int QmlSystem::importContacts(QString file) {
  return this->w.importContacts(cleanPath(file).toStdString());
}

int QmlSystem::exportContacts(QString file) {
  return this->w.exportContacts(cleanPath(file).toStdString());
}

