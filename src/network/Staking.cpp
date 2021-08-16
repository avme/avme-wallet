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
  json params;
  json array = json::array();
  params["to"] = Pangolin::contracts["staking"];
  params["data"] = Staking::funcs["totalSupply"];
  array.push_back(params);
  array.push_back("latest");
  Request req{1, "2.0", "eth_call", array};
  std::string query = API::buildRequest(req);
  std::string resp = API::httpGetRequest(query);
  json respJson = json::parse(resp);
  std::string result = respJson["result"].get<std::string>();
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"
  return Pangolin::parseHex(result, {"uint"})[0];
}

std::string Staking::getRewardForDuration() {
  json params;
  json array = json::array();
  params["to"] = Pangolin::contracts["staking"];
  params["data"] = Staking::funcs["getRewardForDuration"];
  array.push_back(params);
  array.push_back("latest");
  Request req{1, "2.0", "eth_call", array};
  std::string query = API::buildRequest(req);
  std::string resp = API::httpGetRequest(query);
  json respJson = json::parse(resp);
  std::string result = respJson["result"].get<std::string>();
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"
  return Pangolin::parseHex(result, {"uint"})[0];
}

std::string Staking::rewardsDuration() {
  json params;
  json array = json::array();
  params["to"] = Pangolin::contracts["staking"];
  params["data"] = Staking::funcs["rewardsDuration"];
  array.push_back(params);
  array.push_back("latest");
  Request req{1, "2.0", "eth_call", array};
  std::string query = API::buildRequest(req);
  std::string resp = API::httpGetRequest(query);
  json respJson = json::parse(resp);
  std::string result = respJson["result"].get<std::string>();
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"
  return Pangolin::parseHex(result, {"uint"})[0];
}

std::string Staking::balanceOf(std::string address) {
  json params;
  json array = json::array();
  params["to"] = Pangolin::contracts["staking"];
  params["data"] = Pangolin::ERC20Funcs["balanceOf"] + Utils::addressToHex(address);
  array.push_back(params);
  array.push_back("latest");
  Request req{1, "2.0", "eth_call", array};
  std::string query = API::buildRequest(req);
  std::string resp = API::httpGetRequest(query);
  json respJson = json::parse(resp);
  std::string result = respJson["result"].get<std::string>();
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"
  return Pangolin::parseHex(result, {"uint"})[0];
}

std::string Staking::earned(std::string address) {
  json params;
  json array = json::array();
  params["to"] = Pangolin::contracts["staking"];
  params["data"] = Staking::funcs["earned"] + Utils::addressToHex(address);
  array.push_back(params);
  array.push_back("latest");
  Request req{1, "2.0", "eth_call", array};
  std::string query = API::buildRequest(req);
  std::string resp = API::httpGetRequest(query);
  json respJson = json::parse(resp);
  std::string result = respJson["result"].get<std::string>();
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"
  return Pangolin::parseHex(result, {"uint"})[0];
}

std::string Staking::getCompoundReward() {
  json params;
  json array = json::array();
  params["to"] = Pangolin::contracts["compound"];
  params["data"] = Staking::YYfuncs["checkReward"];
  array.push_back(params);
  array.push_back("latest");
  Request req{1, "2.0", "eth_call", array};
  std::string query = API::buildRequest(req);
  std::string resp = API::httpGetRequest(query);
  json respJson = json::parse(resp);
  std::string result = respJson["result"].get<std::string>();
  if (result == "0x" || result == "") { return {}; }
  result = result.substr(2); // Remove the "0x"
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
  json params;
  json array = json::array();
  params["to"] = Pangolin::contracts["compound"];
  params["data"] = Staking::YYfuncs["getSharesForDepositTokens"] + Utils::uintToHex(amount);
  array.push_back(params);
  array.push_back("latest");
  Request req{1, "2.0", "eth_call", array};
  std::string query = API::buildRequest(req);
  std::string resp = API::httpGetRequest(query);
  json respJson = json::parse(resp);
  std::string result = respJson["result"].get<std::string>();
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

