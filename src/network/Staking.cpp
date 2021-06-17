// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "Staking.h"

std::map<std::string, std::string> Staking::funcs = {
  {"totalSupply", "0x18160ddd"}, // totalSupply()
  {"getRewardForDuration", "0x1c1f78eb"}, // getRewardForDuration()
  {"rewardsDuration", "0x386a9525"}, // rewardsDuration()
  {"earned", "0x008cc262"}, // earned(address)
  {"stake", "0xa694fc3a"}, // stake(uint256)
  {"withdraw", "0x2e1a7d4d"}, // withdraw(uint256)
  {"getReward", "0x3d18b912"}, // getReward()
  {"exit", "0xe9fad8ee"}, // exit()
};

std::map<std::string, std::string> Staking::YYfuncs = {
  {"balanceOf", "0x70a08231"}, // balanceOf(uint256)
  {"getDepositTokensForShares", "0xeab89a5a"}, // getDepositTokensForShares(uint256)
  {"deposit", "0xb6b55f25"}, // deposit(uint256)
  {"reinvest", "0xfdb5a03e"}, // reinvest(uint256)
  {"checkReward","0xc4b24a46"}, // checkReward()
  {"withdraw", "0x2e1a7d4d"}, // withdraw(uint256)
  {"getSharesForDepositTokens", "0xdd8ce4d6"}, // getSharesForDepositTokens(uint256)
};


std::string Staking::totalSupply() {
  std::string result;
  std::stringstream query;

  // Query and get the result, returning if empty
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\", \"params\": "
        << "[{\"to\": \"" << Pangolin::stakingContract
        << "\",\"data\": \"" << Staking::funcs["totalSupply"]
        << "\"},\"latest\"]}";
  std::string str = API::httpGetRequest(query.str());
  result = JSON::getString(str, "result");
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"

  // Parse the result back into normal values
  return Pangolin::parseHex(result, {"uint"})[0];
}

std::string Staking::getRewardForDuration() {
  std::string result;
  std::stringstream query;

  // Query and get the result, returning if empty
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\", \"params\": "
        << "[{\"to\": \"" << Pangolin::stakingContract
        << "\",\"data\": \"" << Staking::funcs["getRewardForDuration"]
        << "\"},\"latest\"]}";
  std::string str = API::httpGetRequest(query.str());
  result = JSON::getString(str, "result");
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"

  // Parse the result back into normal values
  return Pangolin::parseHex(result, {"uint"})[0];
}

std::string Staking::rewardsDuration() {
  std::string result;
  std::stringstream query;

  // Query and get the result, returning if empty
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\", \"params\": "
        << "[{\"to\": \"" << Pangolin::stakingContract
        << "\",\"data\": \"" << Staking::funcs["rewardsDuration"]
        << "\"},\"latest\"]}";
  std::string str = API::httpGetRequest(query.str());
  result = JSON::getString(str, "result");
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"

  // Parse the result back into normal values
  return Pangolin::parseHex(result, {"uint"})[0];
}

std::string Staking::balanceOf(std::string address) {
  std::string result;
  std::stringstream query;

  // Query and get the result, returning if empty
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\", \"params\": "
        << "[{\"to\": \"" << Pangolin::stakingContract
        << "\",\"data\": \"" << Pangolin::ERC20Funcs["balanceOf"]
                             << Utils::addressToHex(address)
        << "\"},\"latest\"]}";
  std::string str = API::httpGetRequest(query.str());
  result = JSON::getString(str, "result");
  if (result == "0x" || result == "") { return {}; }
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
  std::string str = API::httpGetRequest(query.str());
  result = JSON::getString(str, "result");
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"

  // Parse the result back into normal values
  return Pangolin::parseHex(result, {"uint"})[0];
}

std::string Staking::getCompoundReward() {
  std::string result;
  std::stringstream query;

  // Query and get the result, returning if empty
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\", \"params\": "
        << "[{\"to\": \"" << Pangolin::compoundContract
        << "\",\"data\": \"" << Staking::YYfuncs["checkReward"]
        << "\"},\"latest\"]}";
  std::string str = API::httpGetRequest(query.str());
  result = JSON::getString(str, "result");
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"

  // Parse the result back into normal values
  return Pangolin::parseHex(result, {"uint"})[0];
}

std::string Staking::stake(std::string amount) {
  std::string dataHex = Staking::funcs["stake"] + Utils::uintToHex(amount);
  return dataHex;
}

std::string Staking::stakeCompound(std::string amount) {
  std::string dataHex = Staking::YYfuncs["deposit"] + Utils::uintToHex(amount);
  return dataHex;
}

std::string Staking::withdraw(std::string amount) {
  std::string dataHex = Staking::funcs["withdraw"] + Utils::uintToHex(amount);
  return dataHex;
}

std::string Staking::compoundWithdraw(std::string amount) {
  std::string result;
  std::stringstream query;

  // Query and get the result, returning if empty
  query << "{\"id\": 1,\"jsonrpc\": \"2.0\",\"method\": \"eth_call\", \"params\": "
        << "[{\"to\": \"" << Pangolin::compoundContract
        << "\",\"data\": \"" << Staking::YYfuncs["getSharesForDepositTokens"] << Utils::uintToHex(amount)
        << "\"},\"latest\"]}";
  std::string str = API::httpGetRequest(query.str());
  result = JSON::getString(str, "result");
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"
  std::string dataHex = Staking::YYfuncs["withdraw"] + result;
  return dataHex;
}

std::string Staking::getReward() {
  std::string dataHex = Staking::funcs["getReward"];
  return dataHex;
}

std::string Staking::reinvest() {
  std::string dataHex = Staking::YYfuncs["reinvest"];
  return dataHex;
}

std::string Staking::exit() {
  std::string dataHex = Staking::funcs["exit"];
  return dataHex;
}

