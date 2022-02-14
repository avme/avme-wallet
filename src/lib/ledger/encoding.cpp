// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "encoding.h"

namespace ledger {
  namespace encoding {
    /** BIP32 input data:
     *
     * |----------------------------------------------------------------|
     * | Description                             | len  							  |
     * |----------------------------------------------------------------|
     * | Number of BIP 32 derivations to perform | 1 bytes						  |
     * |----------------------------------------------------------------|
     * | First derivation index                  | 4 bytes (big endian) |
     * |----------------------------------------------------------------|
     * | ... 		                                 | 4 bytes (big endian) |
     * |----------------------------------------------------------------|
     * | Last derivation index                   | 4 bytes (big endian) |
     * |----------------------------------------------------------------|
     */

    /**
     * Example:
     *
     * m/44'/60'/0'/0 --- ' means Hardened, which sums the value up to
     * 04             --- Number of BIP 32 derivations to perform,
     *                    how many "/" are in the desired BIP32
     * 80 00 00 2C    --- 44' -- 2^31 + 44 = 80 00 00 2C
     * 80 00 00 3C    --- 60' -- 2^31 + 60 = 80 00 00 3C
     * 80 00 00 00    --- 0'  -- 2^31      = 80 00 00 00
     * 00 00 00 00    --- 0   -- 0 itself  = 00 00 00 00
     */
    std::vector<unsigned char> parsePath(std::string unparsedPath) {
      std::vector<unsigned char> ret;
      unsigned char nDerivations = 0;
      std::vector<uint32_t> derivationIndexes;
      std::string tmpIndex = "";
      bool isHardened;

      // Remove unecessary characters.
      if (unparsedPath[0] == 'm' && unparsedPath[1] == '/') { unparsedPath.erase(0,2); }

      // Encode each derivation as a 4 bytes size (uint32_t)
      for (size_t i = 0; i < unparsedPath.size(); ++i) {
        if (std::isdigit(unparsedPath[i])) { tmpIndex += unparsedPath[i]; }
        if (unparsedPath[i] == '\'') {	isHardened = true; }
        if (unparsedPath[i] == '/' || i == (unparsedPath.size() - 1)) {
          ++nDerivations;
          //std::cout << tmpIndex << std::endl;
          uint32_t index = boost::lexical_cast<uint32_t>(tmpIndex);
          if (isHardened) { index += hardened; }
          derivationIndexes.push_back(index);
          isHardened = false;
          tmpIndex = "";
          continue;
        }
      }

      // Encode the uint32_t vector and number of derivations into unsigned char vector.
      ret.push_back(nDerivations);
      for (auto vec : derivationIndexes) {
        ret.push_back(vec >> 24);
        ret.push_back(vec >> 16);
        ret.push_back(vec >> 8);
        ret.push_back(vec);
      }
      return ret;
    }

    std::vector<sendBuf> encodeBip32Message(std::string unparsedPath) {
      std::vector<sendBuf> ret;
      sendBuf buffer = {};
      std::vector<unsigned char> bufferVector; // Buffer vector to easily handle the message encoding.

      // Encode APDU message.
      APDUencoding APDUstructure;
      APDUstructure.payload = parsePath(unparsedPath);
      APDUstructure.LC = parsePath(unparsedPath).size();

      /**
       * Encode APDU to HID payload.
       * BIP32 getAddress does not require any extra params other than
       * what is already preset on the struct.
       */
      HIDencoding HIDstructure;
      HIDstructure.payload.push_back(APDUstructure.CLA);
      HIDstructure.payload.push_back(APDUstructure.INSbip32);
      HIDstructure.payload.push_back(APDUstructure.P1);
      HIDstructure.payload.push_back(APDUstructure.P2);
      HIDstructure.payload.push_back(APDUstructure.LC);
      HIDstructure.payload.insert(HIDstructure.payload.end(), APDUstructure.payload.begin(), APDUstructure.payload.end());

      /**
       * Encode the HID message.
       * As we are using the default structure, only the payload size
       * needs to be encoded.
       */
      HIDstructure.length[1] = HIDstructure.payload.size();

      /**
       * Encode the entire message to the buffer.
       * The first byte (Report ID) of the message should always be 0x00,
       * it is ignored by Ledger and used by the operating system.
       */
      bufferVector.push_back(0x00);
      bufferVector.insert(bufferVector.end(), HIDstructure.channelID.begin(), HIDstructure.channelID.end()); // ChannelID
      bufferVector.push_back(HIDstructure.commandTag);
      bufferVector.insert(bufferVector.end(), HIDstructure.index.begin(), HIDstructure.index.end());
      bufferVector.insert(bufferVector.end(), HIDstructure.length.begin(), HIDstructure.length.end());
      bufferVector.insert(bufferVector.end(), HIDstructure.payload.begin(), HIDstructure.payload.end());

      // Encode bufferVector inside the buffer.
      for (size_t i = 0; i <= bufferVector.size(); ++i) { buffer[i] = bufferVector[i]; }
      ret.push_back(buffer);
      return ret;
    }

    /**
     * BIP32 output data (taken from Ledger documentation, seems incorrect!!!):
     *
     * |-------------------------------------|
     * | Description              | len  		 |
     * |-------------------------------------|
     * | Public Key length			  | 1 bytes	 |
     * |-------------------------------------|
     * | Uncompressed Public Key  | Var			 |
     * |-------------------------------------|
     * | Ethereum address length  | 1 bytes	 |
     * |-------------------------------------|
     * | Ethereum address       	| Var			 |
     * |-------------------------------------|
     * | Chain code if requested  | 32 Bytes |
     * |-------------------------------------|
     */

    /**
     * Normally, BIP32 messages are encoded in 3 vectors.
     * If the vector size is only 1, it means an error happened.
     */
    std::string decodeBip32Message(std::vector<receiveBuf> receiveBuffer) {
      std::string ret = "0x";
      std::vector<unsigned char> message;

      /**
       * Read the address from the message.
       * Address is always on the second vector, starting at index 15 and ending
       * at index 15 + 40, where 40 is number of characters in a given address.
       */
      if (receiveBuffer.size() <= 1) { return ""; }
      for (size_t i = 15; i < (15+40); ++i) {
        std::stringstream ss;
        ss << std::hex << std::setfill('0');
        ss << std::hex << std::setw(1) << receiveBuffer[1][i];
        ret += ss.str();
      }
      return ret;
    }

    /** personal sign input data:
     *
     * |----------------------------------------------------------------|
     * | Description                             | len  							  |
     * |----------------------------------------------------------------|
     * | Number of BIP 32 derivations to perform | 1 bytes						  |
     * |----------------------------------------------------------------|
     * | First derivation index                  | 4 bytes (big endian) |
     * |----------------------------------------------------------------|
     * | ... 		                                 | 4 bytes (big endian) |
     * |----------------------------------------------------------------|
     * | Last derivation index                   | 4 bytes (big endian) |
     * |----------------------------------------------------------------|
     * | Message length                          | 4 bytes (big endian) |
     * |----------------------------------------------------------------|
     * | Message chunk                           | 32 bytes (keccak256) |
     * |----------------------------------------------------------------|
     */
    std::vector<sendBuf> encodePersonalSignMessage(std::string message, std::string addressPath) {
      std::vector<sendBuf> ret;
      sendBuf buffer = {0};
      std::vector<unsigned char> bip32 = parsePath(addressPath);
      std::vector<unsigned char> RLP;
      std::vector<transactionPayload> txPayload;
      bool firstMessage = true;
      size_t messageIndex = 0;
      auto messageBytes = dev::fromHex(dev::toHex(message));
      unsigned char messageSize[4];
      uint32_t messageSizeUint32_t = messageBytes.size();
      std::memcpy(&messageSize, &messageSizeUint32_t, sizeof(messageSize));

      while (messageIndex < messageBytes.size()) {
        transactionPayload tmpTxPayload;
        if ((messageIndex + bip32.size()) >= 150) {
          tmpTxPayload.isHIDFirstMessage = false;
        }

        for (size_t i = 0; i < tmpTxPayload.firstMessage.size() && messageIndex < messageBytes.size(); ++i) {
          tmpTxPayload.isFirstMessageEmpty = false;
          if (tmpTxPayload.isHIDFirstMessage && i < bip32.size()) {
            tmpTxPayload.firstMessage[i] = bip32[i];
            ++tmpTxPayload.payloadSize;
            continue;
          }
          if (tmpTxPayload.isHIDFirstMessage && i < (bip32.size() + 4)) {
            tmpTxPayload.firstMessage[i] = messageSize[3 - (i - bip32.size())];
            ++tmpTxPayload.payloadSize;
            continue;
          }
          tmpTxPayload.firstMessage[i] = messageBytes[messageIndex];
          ++messageIndex;
          ++tmpTxPayload.payloadSize;
        }
        for (size_t i = 0; i < tmpTxPayload.secondMessage.size() && messageIndex < messageBytes.size(); ++i) {
          tmpTxPayload.isSecondMessageEmpty = false;
          tmpTxPayload.secondMessage[i] = messageBytes[messageIndex];
          ++messageIndex;
          ++tmpTxPayload.payloadSize;
        }
        for (size_t i = 0; i < tmpTxPayload.thirdMessage.size() && messageIndex < messageBytes.size(); ++i) {
          tmpTxPayload.isThirdMessageEmpty = false;
          tmpTxPayload.thirdMessage[i] = messageBytes[messageIndex];
          ++messageIndex;
          ++tmpTxPayload.payloadSize;
        }
        txPayload.push_back(tmpTxPayload);

      }

      for (auto txPayloadStruct : txPayload) {
        buffer = {0};
        if (!txPayloadStruct.isFirstMessageEmpty) {
          std::vector<unsigned char> bufferVector;
          APDUencoding APDUstructure;
          APDUstructure.P1 = (txPayloadStruct.isHIDFirstMessage) ? 0x00 : 0x80;
          APDUstructure.payload.insert(APDUstructure.payload.end(), txPayloadStruct.firstMessage.begin(), txPayloadStruct.firstMessage.end());
          APDUstructure.LC = txPayloadStruct.payloadSize;

          HIDencoding HIDstructure;
          HIDstructure.payload.push_back(APDUstructure.CLA);
          HIDstructure.payload.push_back(APDUstructure.INSsignPersonal32);
          HIDstructure.payload.push_back(APDUstructure.P1);
          HIDstructure.payload.push_back(APDUstructure.P2);
          HIDstructure.payload.push_back(APDUstructure.LC);
          HIDstructure.payload.insert(HIDstructure.payload.end(), APDUstructure.payload.begin(), APDUstructure.payload.end());

          HIDstructure.length[1] = 5 + txPayloadStruct.payloadSize;

          bufferVector.push_back(0x00);
          bufferVector.insert(bufferVector.end(), HIDstructure.channelID.begin(), HIDstructure.channelID.end()); // ChannelID
          bufferVector.push_back(HIDstructure.commandTag);
          bufferVector.insert(bufferVector.end(), HIDstructure.index.begin(), HIDstructure.index.end());
          bufferVector.insert(bufferVector.end(), HIDstructure.length.begin(), HIDstructure.length.end());
          bufferVector.insert(bufferVector.end(), HIDstructure.payload.begin(), HIDstructure.payload.end());

          for (size_t i = 0; i < bufferVector.size(); ++i) { buffer[i] = bufferVector[i]; }
          ret.push_back(buffer);
        }

        /**
         * Second and third messages only need a small HID structure containing
         * Channel ID, Command and Index.
         */
        buffer = {0};
        if (!txPayloadStruct.isSecondMessageEmpty) {
          std::vector<unsigned char> bufferVector;
          HIDencoding HIDstructure;
          HIDstructure.index[1] = 0x01;
          HIDstructure.payload.insert(HIDstructure.payload.end(), txPayloadStruct.secondMessage.begin(), txPayloadStruct.secondMessage.end());

          bufferVector.push_back(0x00);
          bufferVector.insert(bufferVector.end(), HIDstructure.channelID.begin(), HIDstructure.channelID.end()); // ChannelID
          bufferVector.push_back(HIDstructure.commandTag);
          bufferVector.insert(bufferVector.end(), HIDstructure.index.begin(), HIDstructure.index.end());
          bufferVector.insert(bufferVector.end(), HIDstructure.payload.begin(), HIDstructure.payload.end());

          for (size_t i = 0; i < bufferVector.size(); ++i) { buffer[i] = bufferVector[i]; }
          ret.push_back(buffer);
        }

        buffer = {0};
        if (!txPayloadStruct.isThirdMessageEmpty) {
          std::vector<unsigned char> bufferVector;
          HIDencoding HIDstructure;
          HIDstructure.index[1] = 0x02;
          HIDstructure.payload.insert(HIDstructure.payload.end(), txPayloadStruct.thirdMessage.begin(), txPayloadStruct.thirdMessage.end());

          bufferVector.push_back(0x00);
          bufferVector.insert(bufferVector.end(), HIDstructure.channelID.begin(), HIDstructure.channelID.end()); // ChannelID
          bufferVector.push_back(HIDstructure.commandTag);
          bufferVector.insert(bufferVector.end(), HIDstructure.index.begin(), HIDstructure.index.end());
          bufferVector.insert(bufferVector.end(), HIDstructure.payload.begin(), HIDstructure.payload.end());
          for (size_t i = 0; i < bufferVector.size(); ++i) { buffer[i] = bufferVector[i]; }
          ret.push_back(buffer);
        }
      }
      return ret;
    }

    std::vector<sendBuf> encodeSignEthMessage(dev::eth::TransactionBase& tb, std::string addressPath) {
      std::vector<sendBuf> ret;
      sendBuf buffer = {0};
      std::vector<unsigned char> bip32 = parsePath(addressPath);
      std::vector<unsigned char> RLP;
      std::vector<transactionPayload> txPayload;
      bool firstMessage = true;
      size_t RLPindex = 0;
      auto tbRLP = tb.rlp(dev::eth::WithoutSignature);

      // Encode the RLP in transactionMessage structures.
      for (auto c : tbRLP) { RLP.push_back(c); }
      while (RLPindex < RLP.size()) {
        transactionPayload tmpTxPayload;
        if ((RLPindex + bip32.size()) >= 150) {
          tmpTxPayload.isHIDFirstMessage = false;
        }

        for (size_t i = 0; i < tmpTxPayload.firstMessage.size() && RLPindex < RLP.size(); ++i) {
          tmpTxPayload.isFirstMessageEmpty = false;
          if (tmpTxPayload.isHIDFirstMessage && i < bip32.size()) {
            tmpTxPayload.firstMessage[i] = bip32[i];
            ++tmpTxPayload.payloadSize;
            continue;
          }
          tmpTxPayload.firstMessage[i] = RLP[RLPindex];
          ++RLPindex;
          ++tmpTxPayload.payloadSize;
        }
        for (size_t i = 0; i < tmpTxPayload.secondMessage.size() && RLPindex < RLP.size(); ++i) {
          tmpTxPayload.isSecondMessageEmpty = false;
          tmpTxPayload.secondMessage[i] = RLP[RLPindex];
          ++RLPindex;
          ++tmpTxPayload.payloadSize;
        }
        for (size_t i = 0; i < tmpTxPayload.thirdMessage.size() && RLPindex < RLP.size(); ++i) {
          tmpTxPayload.isThirdMessageEmpty = false;
          tmpTxPayload.thirdMessage[i] = RLP[RLPindex];
          ++RLPindex;
          ++tmpTxPayload.payloadSize;
        }
        txPayload.push_back(tmpTxPayload);

      }

      for (auto txPayloadStruct : txPayload) {
        buffer = {0};
        if (!txPayloadStruct.isFirstMessageEmpty) {
          std::vector<unsigned char> bufferVector;
          APDUencoding APDUstructure;
          APDUstructure.P1 = (txPayloadStruct.isHIDFirstMessage) ? 0x00 : 0x80;
          APDUstructure.payload.insert(APDUstructure.payload.end(), txPayloadStruct.firstMessage.begin(), txPayloadStruct.firstMessage.end());
          APDUstructure.LC = txPayloadStruct.payloadSize;

          HIDencoding HIDstructure;
          HIDstructure.payload.push_back(APDUstructure.CLA);
          HIDstructure.payload.push_back(APDUstructure.INSsign32);
          HIDstructure.payload.push_back(APDUstructure.P1);
          HIDstructure.payload.push_back(APDUstructure.P2);
          HIDstructure.payload.push_back(APDUstructure.LC);
          HIDstructure.payload.insert(HIDstructure.payload.end(), APDUstructure.payload.begin(), APDUstructure.payload.end());

          HIDstructure.length[1] = 5 + txPayloadStruct.payloadSize;

          bufferVector.push_back(0x00);
          bufferVector.insert(bufferVector.end(), HIDstructure.channelID.begin(), HIDstructure.channelID.end()); // ChannelID
          bufferVector.push_back(HIDstructure.commandTag);
          bufferVector.insert(bufferVector.end(), HIDstructure.index.begin(), HIDstructure.index.end());
          bufferVector.insert(bufferVector.end(), HIDstructure.length.begin(), HIDstructure.length.end());
          bufferVector.insert(bufferVector.end(), HIDstructure.payload.begin(), HIDstructure.payload.end());

          for (size_t i = 0; i < bufferVector.size(); ++i) { buffer[i] = bufferVector[i]; }
          ret.push_back(buffer);
        }

        /**
         * Second and third messages only need a small HID structure containing
         * Channel ID, Command and Index.
         */
        buffer = {0};
        if (!txPayloadStruct.isSecondMessageEmpty) {
          std::vector<unsigned char> bufferVector;
          HIDencoding HIDstructure;
          HIDstructure.index[1] = 0x01;
          HIDstructure.payload.insert(HIDstructure.payload.end(), txPayloadStruct.secondMessage.begin(), txPayloadStruct.secondMessage.end());

          bufferVector.push_back(0x00);
          bufferVector.insert(bufferVector.end(), HIDstructure.channelID.begin(), HIDstructure.channelID.end()); // ChannelID
          bufferVector.push_back(HIDstructure.commandTag);
          bufferVector.insert(bufferVector.end(), HIDstructure.index.begin(), HIDstructure.index.end());
          bufferVector.insert(bufferVector.end(), HIDstructure.payload.begin(), HIDstructure.payload.end());

          for (size_t i = 0; i < bufferVector.size(); ++i) { buffer[i] = bufferVector[i]; }
          ret.push_back(buffer);
        }

        buffer = {0};
        if (!txPayloadStruct.isThirdMessageEmpty) {
          std::vector<unsigned char> bufferVector;
          HIDencoding HIDstructure;
          HIDstructure.index[1] = 0x02;
          HIDstructure.payload.insert(HIDstructure.payload.end(), txPayloadStruct.thirdMessage.begin(), txPayloadStruct.thirdMessage.end());

          bufferVector.push_back(0x00);
          bufferVector.insert(bufferVector.end(), HIDstructure.channelID.begin(), HIDstructure.channelID.end()); // ChannelID
          bufferVector.push_back(HIDstructure.commandTag);
          bufferVector.insert(bufferVector.end(), HIDstructure.index.begin(), HIDstructure.index.end());
          bufferVector.insert(bufferVector.end(), HIDstructure.payload.begin(), HIDstructure.payload.end());
          for (size_t i = 0; i < bufferVector.size(); ++i) { buffer[i] = bufferVector[i]; }
          ret.push_back(buffer);
        }
      }
      return ret;
    }

    /**
     * SignEthMessage output data:
     *
     * |-------------------------|
     * | Description  | len  		 |
     * |-------------------------|
     * | v					  | 1 bytes	 |
     * |-------------------------|
     * | r            | 32 Bytes |
     * |-------------------------|
     * | s            | 32 Bytes |
     * |-------------------------|
     */

    /**
     * Following the structure above, the signature produced by the Ledger
     * will always be located in the last 2 vectors of the receiveBuffer.
     */
    dev::SignatureStruct decodeSignEthMessage(std::vector<receiveBuf> receiveBuffer) {
      size_t bufferIndex = receiveBuffer.size() - 2;
      std::vector<unsigned char> signature;
      unsigned char v;
      std::vector<unsigned char> r;
      std::vector<unsigned char> s;

      // Skip the HID/APDU Encoding, as it is not used.
      for (size_t i = 7; i < receiveBuffer[bufferIndex].size(); ++i) {
        signature.push_back(receiveBuffer[bufferIndex][i]);
      }
      for (size_t i = 5; i < receiveBuffer[bufferIndex+1].size(); ++i) {
        signature.push_back(receiveBuffer[bufferIndex+1][i]);
      }
      v = (signature[0] % 2 == 0) ? 0x01 : 0x00;
      r.insert(r.end(), signature.begin()+1, signature.begin() + 33);
      s.insert(s.end(), signature.begin()+33, signature.begin()+65);

      dev::h256 _s(s);
      dev::h256 _r(r);

      dev::SignatureStruct sigStruct(_r,_s,v);
      return sigStruct;
    }
  }
}
