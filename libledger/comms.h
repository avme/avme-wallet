#pragma once
#include <iostream>
#include <vector>
#include <hidapi/hidapi.h>
#include "encoding.h"



namespace ledger {
	namespace communicationSpecs {
        struct usb_device_params {
                unsigned short vendor_id;
                unsigned short product_id;
        };
        const std::vector<usb_device_params> ledger_devices_ids {
			{usb_device_params{0x2c97, 0x0001}}, // Ledger S
			{usb_device_params{0x2c97, 0x0004}}  // Ledger X
        };

	}
	
	
	
	class communication {
		private:
		unsigned short ledgerVID = 0x0000;
		unsigned short ledgerPID = 0x0000;
		hid_device *device_handle;
		
		public:
		
		bool isLedgerConnected();																				// Check if ledger is connected via USB.
		bool isAppOpen();																						// Check if ledger is opened in App.
		std::vector<encoding::receiveBuf> exchangeMessage(std::vector<encoding::sendBuf> sendBufferVector);		// Exchange messages with the device.
		
		
	};
	
	
	
}