// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#ifndef ENCODING_H
#define ENCODING_H

#include <array>
#include <iomanip>
#include <iostream>
#include <vector>
#include <sstream>
#include <string>

#include <boost/lexical_cast.hpp>

#include <lib/devcore/CommonData.h>
#include <lib/ethcore/TransactionBase.h>
#include <lib/devcrypto/Common.h>

namespace ledger {
  namespace encoding {
    /**
     * HID class base. Commands are formatted as follows:
     *
     * |----------------------------------------------------------|
     * |  2 bytes  |  1 byte  |  2 bytes  | 2 bytes  |  len bytes |
     * |-----------|----------|-----------|----------|------------|
     * |  channel  |    tag   |  sequence |   len    |  payload   |
     * |----------------------------------------------------------|
     */

    // Usage of std::arrays for having access to .begin() and .end()
    struct HIDencoding {
      // Channel ID for USB communication. Fixed to HEX 0101.
      std::array<unsigned char, 2> channelID = {0x01, 0x01};

      // Command tag. 0x05 to send command, 0x02 to send a ping report. Fixed.
      unsigned char commandTag = 0x05;

      // Index of the message. Always starts at HEX 0000.
      std::array<unsigned char, 2> index = {0x00, 0x00};

      /**
       * Length of the entire payload, including future messages.
       * That means future messages do not include the length on headers.
       * As Ledger only accepts 255 bytes at a time, only the [1] index of this
       * array will be used.
       */
      std::array<unsigned char, 2> length = {0x00, 0x00};

      /**
       * First HID message always has 7 bytes in it.
       * Subsequent HID messages always have 5 bytes in it.
       */
      size_t firstMessage = 7;
      size_t subsequenceMessages = 5;

      // The proper payload/message.
      std::vector<unsigned char> payload;
    };

    // See: https://github.com/LedgerHQ/app-ethereum/blob/master/doc/ethapp.asc
    // See: https://pt.wikipedia.org/wiki/Application_protocol_data_unit
    struct APDUencoding {
      // Message CLA. Fixed to 0xE0 according to Ledger documentation.
      unsigned char CLA = 0xE0;

      // Message command. 0x02 for getting BIP32 address, 0x04 for signing transaction.
      unsigned char INSbip32 = 0x02;
      unsigned char INSsign32 = 0x04;
      unsigned char INSsignPersonal32 = 0x08;

      // BIP32: 0x00 Return address, 0x01 Return address and ask user to confirm.
      // SIGNING: 0x00 for first message, 0x80 for subsequence messages. Fixed to 0x00 for convenience.
      unsigned char P1 = 0x00;

      // BIP32: 0x00 Do not return chain code, 0x01 Return chain code.
      // SIGNING: Fixed to 0x00.
      unsigned char P2 = 0x00;

      /**
       * Payload size. Standard defines it between 0, 1 and 3 bytes in size,
       * but ledger only allows communication up to 255 bytes. Fixed to 1 byte.
       */
      unsigned char LC = 0x00;

      // The proper payload/message.
      std::vector<unsigned char> payload;
    };

    // Payloads can contain a max of 150 bytes.
    struct transactionPayload {
      size_t payloadSize = 0;
      bool isHIDFirstMessage = true;
      bool isFirstMessageEmpty = true;
      bool isSecondMessageEmpty = true;
      bool isThirdMessageEmpty = true;

      // Always contains max 52 bytes (64 - HIDencoding - APDUencoding)
      std::array<unsigned char, 52> firstMessage = {0};

      // Always contains max 59 bytes (64 - HIDencoding)
      std::array<unsigned char, 59> secondMessage = {0};

      // Always contains max 39 bytes (150 - firstMessage.size() - secondMessage.size())
      std::array<unsigned char, 39> thirdMessage = {0};
    };

    using sendBuf = std::array<unsigned char, 65>;
    using receiveBuf = std::array<unsigned char, 64>;
    const uint32_t hardened = 2147483648;

    // Parse a string path into encoded input data.
    std::vector<unsigned char> parsePath(std::string unparsedPath);

    // Encode a derivation string into an USB Message for ledger.
    std::vector<sendBuf> encodeBip32Message(std::string unparsedPath);

    // Decode the bip32 message from ledger, returning the address string or "" in failure.
    std::string decodeBip32Message(std::vector<receiveBuf> receiveBuffer);

    // Encode a personal_sign message
    std::vector<sendBuf> encodePersonalSignMessage(std::string message, std::string addressPath);

    std::vector<sendBuf> encodeSignEthMessage(dev::eth::TransactionBase& tb, std::string addressPath);
    dev::SignatureStruct decodeSignEthMessage(std::vector<receiveBuf> receiveBuffer);
  }
}

#endif  // ENCODING_H
