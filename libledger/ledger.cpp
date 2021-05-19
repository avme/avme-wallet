#include "ledger.h"


namespace ledger {
	
	std::pair<bool,std::string> device::checkForDevice() {
		std::pair<bool, std::string> ret;
		if (!this->ledgerDevice.isLedgerConnected()) { 
			ret.first = false;
			ret.second = "Ledger not Connected";
			return ret;
		}
		if (!this->ledgerDevice.isAppOpen()) {
			ret.first = false;
			ret.second = "App not open";
			return ret;
		}
		if (!this->ledgerDevice.isAvaxOpen()) {
			ret.first = false;
			ret.second = "Wrong app open";
			return ret;
		}
		ret.first = true;
		ret.second = "Connected";
		return ret;
	}
	std::pair<bool,std::string> device::generateBip32Account(std::string path) {
		std::pair<bool, std::string> ret;
		auto deviceStatus = this->checkForDevice();
		if (!deviceStatus.first) {
			ret.first = false;
			ret.second = deviceStatus.second;
			return ret;
		}
		
		auto address = encoding::decodeBip32Message(this->ledgerDevice.exchangeMessage(encoding::encodeBip32Message(path)));
		
		if (address.size() != 42) {
			ret.first = false;
			ret.second = "Error when getting address";
			return ret;
		}
		
		account myAccount;
		myAccount.address = address;
		myAccount.index = path;
		this->ledgerAccounts.push_back(myAccount);
		
		ret.first = true;
		ret.second = "";
		return ret;
	}
	std::pair<bool,std::string> device::signTransaction(dev::eth::TransactionSkeleton transactionSkl, std::string path) {
		std::pair<bool, std::string> ret;
		auto deviceStatus = this->checkForDevice();
		if (!deviceStatus.first) {
			ret.first = false;
			ret.second = deviceStatus.second;
			return ret;
		}
		// Check if address exists inside ledger.
		auto address = encoding::decodeBip32Message(this->ledgerDevice.exchangeMessage(encoding::encodeBip32Message(path)));
		if (address.size() != 42) {
			ret.first = false;
			ret.second = "Error when getting address";
			return ret;
		}
		if (dev::eth::toAddress(address) != transactionSkl.from) {
			ret.first = false;
			ret.second = "Address doesn't exists in the desired path";
			return ret;
		}
		dev::eth::TransactionBase transaction(transactionSkl);
		auto signature = ledger::encoding::decodeSignEthMessage(this->ledgerDevice.exchangeMessage(ledger::encoding::encodeSignEthMessage(transaction, path)));
		if (!signature.isValid()) {
			ret.first = false;
			ret.second  = "Invalid signature";
			return ret;
		}
		transaction.signFromSigStruct(signature);
		ret.first = true;
		ret.second = dev::toHex(transaction.rlp());
		
		return ret;
	}
}