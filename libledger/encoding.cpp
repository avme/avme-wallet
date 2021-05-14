#include "encoding.h"



namespace ledger {
	namespace encoding {
	
       /** bip32 input data
        *
        * |------------------------------------------------------------------------------|
        * |  Description                              |  len  							 |
        * |-------------------------------------------|----------------------------------|
        * |  Number of BIP 32 derivations to perform  |  1 bytes						 |
        * |------------------------------------------------------------------------------|
        * |  First derivation index                   |  4 bytes	(big endian)		 |
        * |------------------------------------------------------------------------------|
        * |  ... 		                              |  4 bytes	(big endian)		 |
        * |------------------------------------------------------------------------------|
        * |  Last derivation index                    |  4 bytes	(big endian)		 |
        * |------------------------------------------------------------------------------|
        */
		
		// EXAMPLE
		// m/44'/60'/0'/0
		//             --- ' means Hardened, which sums the value up to 
		// 04          --- Number of BIP 32 derivations to perform, how many / are in the desired BIP32
		// 80 00 00 2C --- 44' -- 2^31 + 44 = 80 00 00 2C
		// 80 00 00 3C --- 60' -- 2^31 + 60 = 80 00 00 3C
		// 80 00 00 00 --- 0'  -- 2^31      = 80 00 00 00
		// 00 00 00 00 --- 0   -- 0 itself  = 00 00 00 00
		std::vector<unsigned char> parsePath(std::string unparsedPath) {
			std::vector<unsigned char> ret;
			unsigned char nDerivations = 0;
			std::vector<uint32_t> derivationIndexes;
			std::string tmpIndex = "";
			bool isHardened;
			
			// Remove unecessary characters.
			if (unparsedPath[0] == 'm' && unparsedPath[1] == '/') 
				unparsedPath.erase(0,2);

			// Encode each derivation as a 4 bytes size (uint32_t
			for (size_t i = 0; i <= unparsedPath.size(); ++i) {
				if (unparsedPath[i] == '/' || i == unparsedPath.size()) {
					++nDerivations;
					//std::cout << tmpIndex << std::endl;
					uint32_t index = boost::lexical_cast<uint32_t>(tmpIndex);
					if (isHardened)
						index += hardened;
					derivationIndexes.push_back(index);
					isHardened = false;
					tmpIndex = "";
					continue;
				}
				if (std::isdigit(unparsedPath[i]))
					tmpIndex += unparsedPath[i];
				if(unparsedPath[i] == '\'')
					isHardened = true;
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
			// bip32 getAddress does not require any extra params than what is already preset on the struct.
			// Encode APDU to HID payload.
			
			HIDencoding HIDstructure;
			HIDstructure.payload.push_back(APDUstructure.CLA);
			HIDstructure.payload.push_back(APDUstructure.INSbip32);
			HIDstructure.payload.push_back(APDUstructure.P1);
			HIDstructure.payload.push_back(APDUstructure.P2);
			HIDstructure.payload.push_back(APDUstructure.LC);
			HIDstructure.payload.insert(HIDstructure.payload.end(), APDUstructure.payload.begin(), APDUstructure.payload.end());
			// Encode HID message
			// As we are using the default structure, only the payload size needs to be encoded.
			
			HIDstructure.lenght[1] = HIDstructure.payload.size();
			
			// Encode the intire message to the buffer.
			// The first byte (Report ID) of the message should always be 0x00, it is ignored by ledger and used by the Operating System.
			
			bufferVector.push_back(0x00);
			bufferVector.insert(bufferVector.end(), HIDstructure.channelID.begin(), HIDstructure.channelID.end()); // ChannelID
			bufferVector.push_back(HIDstructure.commandTag);
			bufferVector.insert(bufferVector.end(), HIDstructure.index.begin(), HIDstructure.index.end());
			bufferVector.insert(bufferVector.end(), HIDstructure.lenght.begin(), HIDstructure.lenght.end());
			bufferVector.insert(bufferVector.end(), HIDstructure.payload.begin(), HIDstructure.payload.end());
			
			// Encode bufferVector inside the buffer.
			
			for (size_t i = 0; i <= bufferVector.size(); ++i)
				buffer[i] = bufferVector[i];
			
			// Push_back and return.
			ret.push_back(buffer);
			return ret;
		}
       /** bip32 output data (Taken from Ledger documentation, seems incorred!!!)
        *
        * |------------------------------------------------------------------------------|
        * |  Description                              |  len  							 |
        * |-------------------------------------------|----------------------------------|
        * |  Public Key length						  |  1 bytes						 |
        * |------------------------------------------------------------------------------|
        * |  Uncompressed Public Key                  |  Var							 |
        * |------------------------------------------------------------------------------|
        * |  Ethereum address length                  |  1 bytes						 |
        * |------------------------------------------------------------------------------|
        * |  Ethereum address        	              |  Var							 |
        * |------------------------------------------------------------------------------|
        * |  Chain code if requested  	              |  32 Bytes						 |
        * |------------------------------------------------------------------------------|
        */
		
		// Normally, bip32 messages are encoded in 3 vectors.
		// If the vector size is only 1, it means a error happened.
		std::string decodeBip32Message(std::vector<receiveBuf> receiveBuffer) {
			std::string ret = "0x";
			std::vector<unsigned char> message;
			if (receiveBuffer.size() == 1)
				return "";
			// Read the address from the message
			// Address is always on the second vector, starting at index 15 and ending at index 15 + 40
			// Where 40 is number of characters in a given address
			for (size_t i = 15; i < (15+40); ++i) {
				std::stringstream ss;
				ss << std::hex << std::setfill('0');
				ss << std::hex << std::setw(1) << receiveBuffer[1][i];
				ret += ss.str();
			}
			return ret;
		}
	}
}