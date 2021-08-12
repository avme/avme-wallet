// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef LEDGER_H
#define LEDGER_H

#include <vector>

#include <lib/ethcore/Common.h>
#include <lib/ethcore/TransactionBase.h>

#include "comms.h"
#include "encoding.h"

/**
 * Namespace for Ledger-related functions.
 */
namespace ledger {
  struct account {
    std::string address;  // e.g. 0x123456789ABCDEF...
    std::string index;    // Derivation path (e.g. "m/60'/40'/0'/0")
  };

  class device {
    private:
      communication ledgerDevice;
      std::vector<account> ledgerAccounts;

    public:
      // Get the list of accounts inside the Ledger device.
      std::vector<account> getAccountList() { return ledgerAccounts; }

      // Clean the account vector
      void cleanAccountList() { ledgerAccounts.clear(); }

      // Check if Ledger device is connected.
      std::pair<bool, std::string> checkForDevice();

      // Generate a BIP32 account in the Ledger device.
      std::pair<bool, std::string> generateBip32Account(std::string path);

      // Sign a transaction using the Ledger device.
      std::pair<bool, std::string> signTransaction(
        dev::eth::TransactionSkeleton transactionSkl, std::string path
      );
  };
}

#endif  // LEDGER_H
