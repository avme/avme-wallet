// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "Staking.h"

std::map<std::string, std::string> Staking::funcs = {
  {"earned", "0x008cc262"}, // earned(address)
  {"stake", "0xa694fc3a"}, // stake(uint256)
  {"withdraw", "0x2e1a7d4d"}, // withdraw(uint256)
  {"getReward", "0x3d18b912"}, // getReward()
  {"exit", "0xe9fad8ee"}, // exit()
};

std::string Staking::balanceOf(std::string address) {
  std::string result;
  std::stringstream query;

  // Query and get the result, returning if empty
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\", \"params\": "
        << "[{\"to\": \"" << Pangolin::stakingContract
        << "\",\"data\": \"" << Pangolin::ERC20Funcs["balanceOf"]
                             << Utils::addressToHex(address)
        << "\"},\"latest\"]}";
  std::string str = Network::httpGetRequest(query.str());
  result = JSON::getValue(str, "result").get_str();
  if (result == "0x") { return {}; }
  result = result.substr(2); // Remove the "0x"

  // Parse the result back into normal values
  return Pangolin::parseHex(result, {"uint"})[0];
}

std::string Staking::earned(std::string address) {
  std::string result;
  std::stringstream query;

  // Query and get the result, returning if empty
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\", \"params\": "
        << "[{\"to\": \"" << Pangolin::stakingContract
        << "\",\"data\": \"" << Staking::funcs["earned"]
                             << Utils::addressToHex(address)
        << "\"},\"latest\"]}";
  std::string str = Network::httpGetRequest(query.str());
  result = JSON::getValue(str, "result").get_str();
  if (result == "0x") { return {}; }
  result = result.substr(2); // Remove the "0x"

  // Parse the result back into normal values
  return Pangolin::parseHex(result, {"uint"})[0];
}

std::string Staking::stake(std::string amount) {
  std::string dataHex = Staking::funcs["stake"] + Utils::uintToHex(amount);
  return dataHex;
}

std::string Staking::withdraw(std::string amount) {
  std::string dataHex = Staking::funcs["withdraw"] + Utils::uintToHex(amount);
  return dataHex;
}

std::string Staking::getReward() {
  std::string dataHex = Staking::funcs["getReward"];
  return dataHex;
}

std::string Staking::exit() {
  std::string dataHex = Staking::funcs["exit"];
  return dataHex;
}

