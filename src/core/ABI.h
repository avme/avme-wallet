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
  

  std::string encodeABI(std::string type, std::vector<std::string> arguments, bool isArray);
  std::string encodeABIfromJson(std::string jsonStr);

};

#endif // ABI_H