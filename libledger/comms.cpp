#include "comms.h"

namespace ledger {
	
	bool communication::isLedgerConnected() {
		if (hid_init()) {
			return false;
		}
		auto ledger_devices = communicationSpecs::ledger_devices_ids;
		struct hid_device_info *devs;
		devs = hid_enumerate(0x0, 0x0);
		while (devs) { 
			if (devs->vendor_id == ledger_devices[0].vendor_id ||
				devs->vendor_id == ledger_devices[1].vendor_id ) {
				this->ledgerVID = devs->vendor_id;
				hid_free_enumeration(devs);
				hid_exit();
				return true;
			}
			devs = devs->next;
		}
		hid_free_enumeration(devs);
		hid_exit();
		return false;
	}
	
	bool communication::isAppOpen() {
		if (!this->isLedgerConnected()) {
			return false;
		}
		if (hid_init()) {
			return false;
		}
		auto ledger_devices = communicationSpecs::ledger_devices_ids;
		struct hid_device_info *devs;
		devs = hid_enumerate(this->ledgerVID, 0x0);
		while (devs) { 
			if (devs->product_id == ledger_devices[0].product_id ||
				devs->product_id == ledger_devices[1].product_id ) {
				this->ledgerPID = devs->product_id;
				hid_free_enumeration(devs);
				hid_exit();
				return true;
			}
			devs = devs->next;
		}
		hid_free_enumeration(devs);
		hid_exit();
		return false;
	}
}
