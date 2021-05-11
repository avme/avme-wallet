#pragma once
#include <string>
#include <iostream>
#include <vector>
#include <array>
#include <boost/lexical_cast.hpp>



namespace ledger {
	namespace encoding {
		
       /** HID class base. Commands are formated as follow:
        *
        * |----------------------------------------------------------|
        * |  2 bytes  |  1 byte  |  2 bytes  | 2 bytes  |  len bytes |
        * |-----------|----------|-----------|----------|------------|
        * |  channel  |    tag   |  sequence |   len    |  payload   |
        * |----------------------------------------------------------|
        */
		
		// Usage of std::arrays for having access to .begin() and .end()
		struct HIDencoding {
			std::array<unsigned char, 2> channelID = {0x01, 0x01}; 	// Channel ID for USB communication, fixed to HEX 0101.
			unsigned char commandTag = 0x05; 						// Command tag, 0x05 to send command, 0x02 to send a ping report, fixed.
			std::array<unsigned char, 2> index = {0x00, 0x00}; 		// Index of the message, always starts at HEX 0000.
			std::array<unsigned char, 2> lenght = {0x00, 0x00}; 	// lenght of intire payload, including future messages. That means future messages does not including lenght on headers.
																	// As ledger only accepts 255 bytes message at a time, only the [1] index of this array will be used
			size_t firstMessage = 7;								// First HID messages always have 7 bytes in it.
			size_t subsequenceMessages = 5;							// Subsequence HID messages always have 5 bytes in it.
			std::vector<unsigned char> payload;
		};
		
		
		// See: https://github.com/LedgerHQ/app-ethereum/blob/master/doc/ethapp.asc
		// See: https://pt.wikipedia.org/wiki/Application_protocol_data_unit
		
		struct APDUencoding {
			unsigned char CLA = 0xE0; 					// Message CLA, Fixed to 0xE0 according to ledger documentation.
			unsigned char INSbip32 = 0x02;				// Message command, 0x02 for get BIP32 address, 0x04 for signing transaction
			unsigned char INSsign32 = 0x04;				// Message command, 0x02 for get BIP32 address, 0x04 for signing transaction.
			unsigned char P1 = 0x00;					// BIP32: 0x00 Return address, 0x01 Return address and ask user to confirm.
														// SIGNING: 0x00 for first message, 0x80 for subsequence messages. fixed to 0x00 for convenience.
			unsigned char P2 = 0x00;					// BIP32: 0x00 Do not return chain code, 0x01 Return chain code, SIGNING: Fixed to 0x00
			unsigned char LC = 0x00;					// Payload size, standard defines it between 0, 1 and 3 bytes in size, but ledger only allows communication up to 255 bytes, fixed to 1 byte.
			std::vector<unsigned char> payload;			// Payload.
		};
		
		using sendBuf = std::array<unsigned char, 65>;
		using receiveBuf = std::array<unsigned char, 64>;
		const uint32_t hardened = 2147483648;
		
		std::vector<unsigned char> parsePath(std::string unparsedPath);		// Parse a string path into encoded input data.
		std::vector<sendBuf> encodeBip32Message(std::string unparsedPath);
	
	}
}