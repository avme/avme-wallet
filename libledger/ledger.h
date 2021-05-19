#pragma once
#include "encoding.h"
#include "comms.h"
#include <libethcore/Common.h>
#include <libethcore/TransactionBase.h>
#include <vector>



namespace ledger {
	struct account {
		std::string address;
		std::string index;
	};
	class device {
		private:
			communication ledgerDevice;
			std::vector<account>ledgerAccounts;	
		public:
		
		std::vector<account> getAccountList() { return ledgerAccounts; }		
		std::pair<bool,std::string> checkForDevice();
		std::pair<bool,std::string> generateBip32Account(std::string path);
		std::pair<bool,std::string> signTransaction(dev::eth::TransactionSkeleton transactionSkl, std::string path);
		
		
	};
}