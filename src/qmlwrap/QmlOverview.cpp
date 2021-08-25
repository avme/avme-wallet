// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

qreal QmlSystem::getQRCodeSize(QString address) {
  qreal width = 0;
  QRcode *qrcode = QRcode_encodeString(
    address.toStdString().c_str(), 0, QR_ECLEVEL_L, QR_MODE_8, 1
  );
  width = qrcode->width;
  return width;
}

QVariantList QmlSystem::getQRCodeFromAddress(QString address) {
  QVariantList ret;
  QRcode *qrcode = QRcode_encodeString(
    address.toStdString().c_str(), 0, QR_ECLEVEL_L, QR_MODE_8, 1
  );
  size_t qrCodeSize = strlen((char*)qrcode->data);
  for (int i = 0; i < qrCodeSize; i++) {
    std::string obj;
    std::string color = (qrcode->data[i] & 1) ? "true" : "false";
    obj += "{\"squareColor\": " + color;
    obj += "}";
    ret << QString::fromStdString(obj);
  }
  return ret;
}

