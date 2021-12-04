// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

#include <qmlwrap/QmlSystem.h>

QString QmlSystem::getCurrentAccount() {
  if (!this->ledgerFlag) {
    return QString::fromStdString(this->w.getCurrentAccount().first);
  } else {
    return this->getCurrentHardwareAccount();
  }
}

void QmlSystem::setCurrentAccount(QString address) {
  this->w.setCurrentAccount(address.toStdString());
}

void QmlSystem::loadAccounts() {
  this->w.loadAccounts();
}

QVariantList QmlSystem::listAccounts() {
  QVariantList ret;
  for (std::pair<std::string, std::string> a : this->w.getAccounts()) {
    json obj;
    obj["address"] = a.first;
    obj["name"] = a.second;
    obj["isLedger"] = false;
    obj["isFav"] = false;
    obj["derivationPath"] = "";
    ret << QString::fromStdString(obj.dump());
  }

  auto ledgerAccounts = this->w.getAllLedgerAccounts();
  for (auto ledgerAccount : ledgerAccounts) {
    json obj;
    obj["address"] = ledgerAccount.address;
    // Name for Ledger accounts??
    obj["name"] = "";
    obj["isLedger"] = true;
    obj["isFav"] = false;
    obj["derivationPath"] = ledgerAccount.index;
    ret << QString::fromStdString(obj.dump());
  }
  return ret;
}

void QmlSystem::generateAccounts(QString seed, int idx) {
  QtConcurrent::run([=](){
    QVariantList ret;
    std::vector<std::string> list = BIP39::generateAccountsFromSeed(seed.toStdString(), idx);
    for (std::string s : list) {
      QVariantMap obj;
      std::stringstream listss(s);
      std::string item;
      int ct = 0;
      while (std::getline(listss, item, ' ')) {
        QString itemStr = QString::fromStdString(item);
        switch (ct) {
          case 0: obj["idx"] = QVariant(itemStr); break;
          case 1: obj["account"] = QVariant(itemStr); break;
        }
        ct++;
      }
      obj["balance"] = "Loading...";
      emit accountGenerated(obj);
    }
  });
}

void QmlSystem::generateLedgerAccounts(QString path, int idx) {
  QtConcurrent::run([=](){
    json ret = json::array();
    std::vector<Request> requestsVec;
    for (int i = idx; i < idx + 10; i++) {
      std::string fullPath = path.toStdString() + boost::lexical_cast<std::string>(i);
      this->ledgerDevice.generateBip32Account(fullPath);
    }
    std::map<int,std::string> addressIDs;
    int addressID = 1;
    auto ledgerAccountList = this->ledgerDevice.getAccountList();
    for (int i = 0; i < ledgerAccountList.size(); ++i) {
      Request req{i + size_t(1), "2.0", "eth_getBalance", {ledgerAccountList[i].address, "latest"}};
      requestsVec.push_back(req);
      addressIDs[addressID] = ledgerAccountList[i].address;
      ++addressID;
    }

    // Make the request and get the AVAX price in USD
    std::string query = API::buildMultiRequest(requestsVec);
    std::string resp = API::httpGetRequest(query);
    json resultArr = json::parse(resp);

    for (auto arrItem : resultArr) {
      for (auto id : addressIDs)
        if (arrItem["id"].get<int>() == id.first) {
            json obj;
            std::string idxStr = ledgerAccountList[id.first - 1].index.substr(ledgerAccountList[id.first - 1].index.find_last_of("/") + 1);
            u256 AVAXbalance = boost::lexical_cast<HexTo<u256>>(arrItem["result"].get<std::string>());
            obj["idx"] = idxStr;
            obj["account"] = id.second;
            obj["balance"] = Utils::weiToFixedPoint(boost::lexical_cast<std::string>(AVAXbalance), 18);
            ret.push_back(obj);
        }
      }
    emit ledgerAccountGenerated(QString::fromStdString(ret.dump()));
  });
}

void QmlSystem::cleanLedgerAccounts() {
  this->ledgerDevice.cleanAccountList();
}

void QmlSystem::createAccount(QString seed, int index, QString name, QString pass) {
  QtConcurrent::run([=](){
    QVariantMap obj;
    std::string seedStr = seed.toStdString();
    std::string nameStr = name.toStdString();
    std::string passStr = pass.toStdString();
    std::pair<std::string, std::string> a;
    a = this->w.createAccount(seedStr, index, nameStr, passStr);
    if (!a.first.empty()) {
      obj.insert("accAddress", "0x" + QString::fromStdString(a.first));
      obj.insert("accName", QString::fromStdString(a.second));
      emit accountCreated(true, obj);
    } else {
      emit accountCreated(false, obj);
    }
  });
}

void QmlSystem::createAccount(QString privKey, QString name, QString pass) {
  QtConcurrent::run([=](){
    QVariantMap obj;
    std::string privKeyStr = privKey.toStdString();
    std::string nameStr = name.toStdString();
    std::string passStr = pass.toStdString();
    std::pair<std::string, std::string> a;
    a = this->w.createAccount(privKeyStr, nameStr, passStr);
    if (!a.first.empty()) {
      obj.insert("accAddress", "0x" + QString::fromStdString(a.first));
      obj.insert("accName", QString::fromStdString(a.second));
      emit accountCreated(true, obj);
    } else {
      emit accountCreated(false, obj);
    }
  });
}

bool QmlSystem::isPrivateKey(QString privKey) {
  return this->w.isPrivKey(privKey.toStdString());
}

void QmlSystem::importLedgerAccount(QString address, QString path) {
  QVariantMap obj;
  bool success = this->w.importLedgerAccount(address.toStdString(), path.toStdString());
  if (!success) {
    emit accountCreated(false, obj);
  } else {
    emit accountCreated(true, obj);
  }
}

bool QmlSystem::deleteLedgerAccount(QString address) {
  bool success = this->w.deleteLedgerAccount(address.toStdString());
  return success;
}

bool QmlSystem::eraseAccount(QString account) {
  return this->w.eraseAccount(account.toStdString());
}

bool QmlSystem::accountExists(QString account) {
  return this->w.accountExists(account.toStdString());
}

bool QmlSystem::privateKeyExists(QString privateKey) {
  return this->w.privateKeyExists(privateKey.toStdString());
}

bool QmlSystem::ledgerAccountExists(QString account) {
  return this->w.ledgerAccountExists(account.toStdString());
}

QString QmlSystem::getPrivateKeys(QString account, QString pass) {
  Secret s = this->w.getSecret(account.toStdString(), pass.toStdString());
  std::string key = toHex(s.ref());
  return QString::fromStdString(key);
}

void QmlSystem::getAccountAVAXBalances(QString address) {
  QtConcurrent::run([=](){
    // Get the AVAX balance in Hex, convert it to Wei and fixed point
    Request req{1, "2.0", "eth_getBalance", {address.toStdString(), "latest"}};
    std::string query = API::buildRequest(req);
    std::string resp = API::httpGetRequest(query);
    json respJson = json::parse(resp);
    std::string hexBal = respJson["result"].get<std::string>();
    u256 avaxWeiBal = boost::lexical_cast<HexTo<u256>>(hexBal);
    bigfloat avaxBal = bigfloat(Utils::weiToFixedPoint(
      boost::lexical_cast<std::string>(avaxWeiBal), 18
    ));
    std::string avaxBalStr = boost::lexical_cast<std::string>(avaxBal);

    // Get the AVAX USD price and calculate the balance in fiat
    auto avaxUSDData = Graph::avaxUSDData(31);
    std::string avaxUSDPriceStr = Graph::parseAVAXPriceUSD(avaxUSDData);
    bigfloat avaxUSDPrice = boost::lexical_cast<bigfloat>(avaxUSDPriceStr);

    bigfloat avaxUSDValueFloat = avaxUSDPrice * avaxBal;
    std::stringstream ss;
    ss << std::setprecision(2) << std::fixed << avaxUSDValueFloat;
    std::string avaxUSDValueStr = ss.str();

    // Return the values
    emit accountAVAXBalancesUpdated(
      address, QString::fromStdString(avaxBalStr),
      QString::fromStdString(avaxUSDValueStr),
      QString::fromStdString(avaxUSDPriceStr),
      QString::fromStdString(avaxUSDData["data"]["AVAXUSDCHART"].dump())
    );
  });
}

void QmlSystem::getAllAVAXBalances(QStringList addresses) {
  QtConcurrent::run([=](){
    std::vector<std::string> addressesVec, balancesVec;
    std::vector<Request> requestsVec;

    // Build the balance request for each address
    for (int i = 0; i < addresses.size(); i++) {
      std::string addressStr = addresses.at(i).toStdString();
      Request req{i + size_t(1), "2.0", "eth_getBalance", {addressStr, "latest"}};
      addressesVec.push_back(addressStr);
      requestsVec.push_back(req);
    }

    // Make the request and get the AVAX price in USD
    std::string query = API::buildMultiRequest(requestsVec);
    std::string resp = API::httpGetRequest(query);
    json resultArr = json::parse(resp);
    std::string avaxUSDValueStr = Graph::getAVAXPriceUSD();
    bigfloat avaxUSDPrice = boost::lexical_cast<bigfloat>(avaxUSDValueStr);

    // Get each AVAX fixed point amount and calculate the fiat value
    int ct = 0;
    for (auto value : resultArr) {
      std::string hexBal = value["result"].get<std::string>();
      u256 avaxWeiBal = boost::lexical_cast<HexTo<u256>>(hexBal);
      bigfloat avaxBal = bigfloat(Utils::weiToFixedPoint(
        boost::lexical_cast<std::string>(avaxWeiBal), 18
      ));
      bigfloat avaxUSDValueFloat = avaxUSDPrice * avaxBal;
      std::stringstream ss;
      ss << std::setprecision(2) << std::fixed << avaxUSDValueFloat;
      std::string avaxUSDValue = ss.str();
      std::string avaxBalStr = boost::lexical_cast<std::string>(avaxBal);
      emit accountAVAXBalancesUpdated(
        QString::fromStdString(addressesVec[ct++]),
        QString::fromStdString(avaxBalStr),
        QString::fromStdString(avaxUSDValue),
        QString::fromStdString(avaxUSDValueStr),
        QString::fromStdString("")
      );
    }
  });
}

void QmlSystem::signMessage(QString address, QString data, QString password, bool webServer, int requestSignType) {
  QtConcurrent::run([=](){
    if (!QmlSystem::getLedgerFlag()) {
      std::string signature = w.signMessage(address.toStdString(), data.toStdString(), password.toStdString(), requestSignType);
      emit messageSigned(QString::fromStdString(signature), webServer);
    } else {
      auto signStatus = this->ledgerDevice.signPersonalMessage(
        data.toStdString(), this->getCurrentHardwareAccountPath().toStdString()
      );
      dev::h520 signature(signStatus.second);
      SignatureStruct sigStruct = *(SignatureStruct const*)&signature;
      sigStruct.v = sigStruct.v + 27;
      emit messageSigned(QString::fromStdString(std::string("0x") + dev::toHex(dev::Signature(sigStruct))), webServer);
    }
  });
  return;
}

void QmlSystem::getAccountAllBalances(QString address) {
  QtConcurrent::run([=](){
    this->updateAccountNonce(address);
    try {
      json tokensInformation = json::array();
      json coinInformation;
      std::string gasPrice;
      std::vector<Request> reqs;
      std::string addressStr = address.toStdString();
      if (addressStr.substr(0,2) == "0x") { addressStr = addressStr.substr(2); }
      // Add AVAX balance as request [1]
      reqs.push_back({1, "2.0", "eth_getBalance", {address.toStdString(), "latest"}});
      // Add gasPrice as request [2]
      reqs.push_back({2, "2.0", "eth_baseFee", {}});
      // Build the balance request for every registered token in the Wallet
      std::vector<ARC20Token> tokenList = QmlSystem::w.getARC20Tokens();
      // The API can eventually return unordered ID's, we need to properly treat it
      std::map<uint64_t, std::string> idList;
      for (ARC20Token token : tokenList) {
        json params;
        json array = json::array();
        params["to"] = token.address;
        params["data"] = "0x70a08231000000000000000000000000" + addressStr;
        array.push_back(params);
        array.push_back("latest");
        Request req{reqs.size() + size_t(1), "2.0", "eth_call", array};
        // Due to GraphQL limitations, we need to add "token_" as prefix
        idList[reqs.size() + size_t(1)] = std::string("token_") + token.address;
        reqs.push_back(req);
      }
      // Make the request and get the AVAX price in USD
      std::string query = API::buildMultiRequest(reqs);
      std::string resp = API::httpGetRequest(query);
      json resultArr = json::parse(resp);
      // Request the prices of all the tokens to the GraphQL API
      auto tokensPrices = Graph::getAccountPrices(tokenList);
      bigfloat avaxUSDPrice = boost::lexical_cast<bigfloat>(Graph::parseAVAXPriceUSD(tokensPrices));
      // Calculate the fiat value for each token
      for (auto id : idList) {
        for (auto balance : resultArr) {
          if (balance["id"].get<int>() == id.first) {
            // Get token position in the tokenList
            int pos = 0;
            for (auto token : tokenList) {
              if (id.second.find(token.address) != std::string::npos)
                break;
              ++pos;
            }
            // Due to GraphQL limitations, we need convert everything to lowercase
            id.second = Utils::toLowerCaseAddress(id.second);
            std::string tokenDerivedPriceStr;
            if (tokensPrices["data"][id.second].type() != json::value_t::null) {
              tokenDerivedPriceStr = tokensPrices["data"][id.second]["derivedETH"].get<std::string>();
            } else {
              tokenDerivedPriceStr = "0";
            }
            bigfloat tokenDerivedPrice = boost::lexical_cast<bigfloat>(tokenDerivedPriceStr);
            std::string hexBal = balance["result"].get<std::string>();
            u256 tokenWeiBal = boost::lexical_cast<HexTo<u256>>(hexBal);
            bigfloat tokenBal = bigfloat(Utils::weiToFixedPoint(
              boost::lexical_cast<std::string>(tokenWeiBal), tokenList[pos].decimals
            ));
            bigfloat tokenUSDPrice = tokenDerivedPrice * avaxUSDPrice;
            bigfloat tokenUSDValueFloat = (tokenDerivedPrice * avaxUSDPrice) * tokenBal;
            std::stringstream ss;
            ss << std::setprecision(2) << std::fixed << tokenUSDValueFloat;
            std::string tokenUSDValue = ss.str();
            std::string tokenBalStr = Utils::weiToFixedPoint(
              boost::lexical_cast<std::string>(tokenWeiBal), tokenList[pos].decimals
            );
            std::string chartAddress = "chart_" + tokenList[pos].address;

            // Again, we need to convert to lowercase and append chart_ as prefix
            chartAddress = Utils::toLowerCaseAddress(chartAddress);
            std::string tokenChartData = tokensPrices["data"][chartAddress].dump();
            json tokenInformation;
            tokenInformation["tokenAddress"] = tokenList[pos].address;
            tokenInformation["tokenSymbol"] = tokenList[pos].symbol;
            tokenInformation["tokenDecimals"] = tokenList[pos].decimals;
            tokenInformation["tokenName"] = tokenList[pos].name;
            tokenInformation["tokenRawBalance"] = tokenBalStr;
            tokenInformation["tokenFiatValue"] = tokenUSDValue;
            tokenInformation["tokenDerivedValue"] = tokenDerivedPriceStr;
            tokenInformation["tokenChartData"] = tokenChartData;
            tokenInformation["tokenUSDPrice"] = boost::lexical_cast<std::string>(tokenUSDPrice);
            tokensInformation.push_back(tokenInformation);
          }
        }
      }
      // Parse AVAX information, using the ID 1 from the API as enforced previously
      for (auto arrItem : resultArr) {
        // As mentioned previously, the array might return unordered from the API, we need to loop it.
        if (arrItem["id"].get<int>() == 1) {
          std::string hexBal = arrItem["result"].get<std::string>();
          u256 avaxWeiBal = boost::lexical_cast<HexTo<u256>>(hexBal);
          bigfloat avaxBal = bigfloat(Utils::weiToFixedPoint(
            boost::lexical_cast<std::string>(avaxWeiBal), 18
          ));
          bigfloat avaxUSDBal = avaxUSDPrice * avaxBal;
          std::stringstream avaxUSDBalPrec2;
          avaxUSDBalPrec2 << std::setprecision(2) << std::fixed << avaxUSDBal;
          std::stringstream avaxUSDPricePrec2;
          avaxUSDPricePrec2 << std::setprecision(2) << std::fixed << avaxUSDPrice;

          coinInformation["coinBalance"] = Utils::weiToFixedPoint(
            boost::lexical_cast<std::string>(avaxWeiBal), 18
          );
          coinInformation["coinFiatBalance"] = avaxUSDBalPrec2.str();
          coinInformation["coinFiatPrice"] = avaxUSDPricePrec2.str();
          coinInformation["coinPriceChart"] = tokensPrices["data"]["AVAXUSDCHART"].dump();
        }
        if (arrItem["id"].get<int>() == 2) {
          // Parse gas Price as GWEI, located in request ID 2
          u256 gasPriceWeiU256 = boost::lexical_cast<HexTo<u256>>(Utils::jsonToStr(arrItem["result"]));
          gasPrice = Utils::weiToFixedPoint(boost::lexical_cast<std::string>(gasPriceWeiU256), 9);
        }
      }

      emit accountAllBalancesUpdated(
        address,
        QString::fromStdString(tokensInformation.dump()),
        QString::fromStdString(coinInformation.dump()),
        QString::fromStdString(gasPrice)
      );
    } catch (std::exception &e) {
      Utils::logToDebug(std::string("ERROR GETTING ACCOUNT BALANCES") + e.what());
    }
  });
}

bool QmlSystem::loadTokenDB() { return this->w.loadTokenDB(); }
bool QmlSystem::loadHistoryDB(QString address) {
  return this->w.loadHistoryDB(address.toStdString());
}
bool QmlSystem::loadLedgerDB() { return this->w.loadLedgerDB(); }
bool QmlSystem::loadAppDB() { return this->w.loadAppDB(); }
bool QmlSystem::loadAddressDB() { return this->w.loadAddressDB(); }

