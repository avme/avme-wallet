#ifndef ABI_H
#define ABI_H

#include <iostream>
#include <vector>
#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>
#include <lib/json_spirit/JsonSpiritHeaders.h>
#include <lib/devcore/SHA3.h>

#include "JSON.h"
#include "Utils.h"

namespace ABI {
  
  /** Encode a single ABI
   * Example:
   * encodeABI(uint*, {32}, false)
   * will return
   * 0000000000000000000000000000000000000000000000000000000000000020
   */

  std::string encodeABI(std::string type, std::vector<std::string> arguments, bool isArray);

  /**
   * Encode the whole ABI from a single JSON
   * Example:
   * {
   *  "function": "GithubWikiTest(uint256,uint256[],bytes10[],bytes)",
   *  "args": [
   *    291,
   *    [1110,1929],
   *    [1234567890,1234567890],
   *    "Hello, world!"
   *    ], 
   *    "types": [
   *      "uint*",
   *      "uint*[]",
   *      "bytes*[]",
   *      "bytes"
   *      ]
   *  }
   * Will return
   *
   * 8f008840 // Function Name
   * 0000000000000000000000000000000000000000000000000000000000000123 // uint*
   * 0000000000000000000000000000000000000000000000000000000000000080 // uint*[]    start
   * 00000000000000000000000000000000000000000000000000000000000000e0 // bytes*[]   start
   * 0000000000000000000000000000000000000000000000000000000000000140 // bytes      start
   * 0000000000000000000000000000000000000000000000000000000000000002 // uint*[]    size
   * 0000000000000000000000000000000000000000000000000000000000000456 // uint*[0]   content
   * 0000000000000000000000000000000000000000000000000000000000000789 // uint*[1]   content
   * 0000000000000000000000000000000000000000000000000000000000000002 // bytes*[]   size
   * 3132333435363738393000000000000000000000000000000000000000000000 // bytes*[0]  content
   * 3132333435363738393000000000000000000000000000000000000000000000 // bytes*[1]  content
   * 000000000000000000000000000000000000000000000000000000000000000d // bytes      size
   * 48656c6c6f2c20776f726c642100000000000000000000000000000000000000 // bytes      content
   * 
   */
  std::string encodeABIfromJson(std::string jsonStr);

};

#endif // ABI_H