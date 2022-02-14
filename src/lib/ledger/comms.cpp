// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "comms.h"

namespace ledger {
  bool communication::messageHasError(encoding::receiveBuf message) {
    // Check if payload size is 2, which is defined as an error.
    // 90 00 is the code which is defined as "no error happened".
    if (message[6] == 2) {
      if (message[7] != 0x90 && message[8] != 0x90) {
        return true;
      }
    }
    return false;
  }

  bool communication::isLedgerConnected() {
    if (hid_init()) { return false;	}
    auto ledger_devices = communicationSpecs::ledger_devices_ids;
    struct hid_device_info *devs;
    devs = hid_enumerate(0x0, 0x0);
    while (devs) {
      for (auto ledger_device : ledger_devices) {
	    if (devs->vendor_id == ledger_device.vendor_id) {
          this->ledgerVID = devs->vendor_id;
          hid_free_enumeration(devs);
          hid_exit();
          return true;
	    }
      }
      devs = devs->next;
    }
    hid_free_enumeration(devs);
    hid_exit();
    return false;
  }

  bool communication::isAppOpen() {
    if (!this->isLedgerConnected()) { return false; }
    if (hid_init()) { return false; }
    auto ledger_devices = communicationSpecs::ledger_devices_ids;
    struct hid_device_info *devs;
    devs = hid_enumerate(this->ledgerVID, 0x0);
    while (devs) {
      for (auto ledger_device : ledger_devices) {
		if (devs->product_id == ledger_device.product_id) {
		  this->ledgerPID = devs->product_id;
		  hid_free_enumeration(devs);
		  hid_exit();
		  return true;
		}
      }
      devs = devs->next;
    }
    hid_free_enumeration(devs);
    hid_exit();
    return false;
  }

  bool communication::isAvaxOpen() {
    if (!this->isLedgerConnected()) { return false; }
    if (!this->isAppOpen()) { return false; }
    auto address = encoding::decodeBip32Message(
      this->exchangeMessage(encoding::encodeBip32Message("m/44'/60'/0'/0"))
    );
    if (address.size() == 42) { return true; }
    return false;
  }

  std::vector<encoding::receiveBuf> communication::exchangeMessage(
    std::vector<encoding::sendBuf> sendBufferVector
  ) {
    std::vector<encoding::receiveBuf> ret;
    unsigned int res = 0;
    unsigned char sendBuffer[65];
    unsigned char receiveBuffer[64];

    // Open connection with the device.
    if (hid_init()) { return {}; }
    this->device_handle = hid_open(this->ledgerVID, this->ledgerPID, NULL);
    if (!this->device_handle) { return {}; }

    // Create packages of 3 buffers.
    // Ledger accepts up to 3 send messages (192 Bytes) before returning an answer.
    // Trying to send more than 255 bytes will crash the device.
    std::vector<std::vector<encoding::sendBuf>> sendBufferPackages;
    unsigned int messageSize = 3;
    sendBufferPackages.reserve((sendBufferVector.size() + 1) / messageSize);

    for(size_t i = 0; i < sendBufferVector.size(); i += messageSize) {
      auto last = std::min(sendBufferVector.size(), i + messageSize);
      sendBufferPackages.emplace_back(sendBufferVector.begin() + i, sendBufferVector.begin() + last);
    }

    // Read and write
    for (auto vec : sendBufferPackages) {
      // Write
      for (auto vec2 : vec) {
        memset(sendBuffer, 0, sizeof(sendBuffer));
        // Load message into buffer array.
        for (size_t i = 0; i < 65; ++i) { sendBuffer[i] = vec2[i]; }
        res = hid_write(this->device_handle, sendBuffer, 65);
        if (res < 0) {
          std::cout << "Unable to write" << std::endl;
          hid_close(this->device_handle);
          hid_exit();
          return {};
        }
      }

      // Read
      // Get first answer
      memset(receiveBuffer, 0, sizeof(receiveBuffer));
      res = hid_read(this->device_handle, receiveBuffer, sizeof(receiveBuffer));
      encoding::receiveBuf tmpRet;
      for (size_t i = 0; i < 64; ++i) { tmpRet[i] = receiveBuffer[i]; }
      ret.push_back(tmpRet);
      // If input was wrong, the first message will always have the error code.
      if (this->messageHasError(tmpRet)) { hid_close(this->device_handle); hid_exit(); return ret; }

      // Read more messages, if there is any.
      for (;;) {
        memset(receiveBuffer, 0, sizeof(receiveBuffer));
        res = hid_read_timeout(this->device_handle, receiveBuffer, sizeof(receiveBuffer), 100);
        if (res == 0) { break; }
        for (size_t i = 0; i < 64; ++i) { tmpRet[i] = receiveBuffer[i]; }
        ret.push_back(tmpRet);
      }
    }
    hid_close(this->device_handle);
    hid_exit();
    return ret;
  }
}
