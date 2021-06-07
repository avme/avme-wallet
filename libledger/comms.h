// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef COMMS_H
#define COMMS_H

#include <iostream>
#include <vector>

#include <hidapi/hidapi.h>

#include "encoding.h"

namespace ledger {
  namespace communicationSpecs {
    // Struct for abstracting device specs.
    struct usb_device_params {
      unsigned short vendor_id;
      unsigned short product_id;
    };

    // Array of supported Ledger devices.
    const std::vector<usb_device_params> ledger_devices_ids {
      {usb_device_params{0x2c97, 0x0001}},  // Ledger Nano S
      {usb_device_params{0x2c97, 0x0004}},  // Ledger Nano X
      {usb_device_params{0x2c97, 0x1015}},  // Ledger Nano S Ethereum App
    };
  }

  class communication {
    private:
      unsigned short ledgerVID = 0x0000;
      unsigned short ledgerPID = 0x0000;
      hid_device *device_handle;
      bool messageHasError(encoding::receiveBuf message);

    public:
      bool isLedgerConnected(); // Check if Ledger is connected via USB.
      bool isAppOpen();         // Check if Ledger is opened in App.
      bool isAvaxOpen();        // Check if the correct App is open on the Ledger by getting a BIP32 address.
      std::vector<encoding::receiveBuf> exchangeMessage(
        std::vector<encoding::sendBuf> sendBufferVector
      );  // Exchange messages with the device.
  };
}

#endif  // COMMS_H
