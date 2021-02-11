// Aleth: Ethereum C++ client, tools and libraries.
// Copyright 2015-2019 Aleth Authors.
// Licensed under the GNU General Public License, Version 3.
/// @file
/// CLI module for key management.
#include "wallet.h"

u256 WalletManager::MAX_U256_VALUE() {
  return (raiseToPow(2, 256) - 1);
}

bool WalletManager::loadWallet(path walletFile, path secretsPath, std::string walletPass) {
  KeyManager w(walletFile, secretsPath);
  if (w.load(walletPass)) {
    this->wallet = w;
    return true;
  } else {
    return false;
  }
}

bool WalletManager::createNewWallet(path walletFile, path secretsPath, std::string walletPass) {
  // Create the paths if they don't exist yet.
  // Remember walletFile points to a *file*, and secretsPath points to a *dir*.
  if (!exists(walletFile.parent_path())) {
    create_directories(walletFile.parent_path());
  }
  if (!exists(secretsPath)) {
    create_directories(secretsPath);
  }

  // Initialize the new wallet
  KeyManager w(walletFile, secretsPath);
  try {
    w.create(walletPass);
    return true;
  } catch (Exception const& _e) {
    std::cerr << "Unable to create wallet" << std::endl << boost::diagnostic_information(_e);
    return false;
  }
}

WalletAccount WalletManager::createNewAccount(
    std::string name, std::string pass, std::string hint, bool usesMasterPass
    ) {
  KeyPair k = makeKey();
  h128 u = this->wallet.import(k.secret(), name, pass, hint);
  WalletAccount ret;

  ret.id = toUUID(u);
  ret.name = name;
  ret.address = k.address().hex();
  ret.hint = (usesMasterPass) ? "Uses master passphrase" : hint;

  return ret;
}

KeyPair WalletManager::makeKey(std::string phrase) {
  if (!phrase.empty()) {
    // Create key based on phrase
    std::string shahash = dev::sha3(phrase, false);
    for (auto i = 0; i < 1048577; ++i) {
      shahash = dev::sha3(shahash, false);
    }
    KeyPair k(Secret::fromString(shahash));
    k = KeyPair(Secret(sha3(k.secret().ref())));
    return k;
  } else {
    // Create a random key
    KeyPair k(Secret::random());
    k = KeyPair(Secret(sha3(k.secret().ref())));
    return k;
  }
}

bool WalletManager::eraseAccount(std::string account) {
  if (Address a = userToAddress(account)) {
    this->wallet.kill(a);
    return true;
  }
  return false; // Account was not found
}

bool WalletManager::accountIsEmpty(std::string account) {
  if (account.find("0x") == std::string::npos) {
    account = "0x" + boost::lexical_cast<std::string>(userToAddress(account));
  }

  /**
   * To convert a hex string to an int value, we need to pass through an int variable.
   * So we convert the hex string into u256 and then u256 back to int string.
   */
  u256 requestAVAX = boost::lexical_cast<u256>(
    JSON::getValue(Network::getAVAXBalance(account), "result").get_str()
  );
  u256 requestTAEX = boost::lexical_cast<u256>(
    JSON::getValue(Network::getTAEXBalance(account, "0xA687A9cff994973314c6e2cb313F82D6d78Cd232"), "result").get_str()
  );

  std::string amountAVAX = boost::lexical_cast<std::string>(requestAVAX);
  std::string amountTAEX = boost::lexical_cast<std::string>(requestTAEX);
  return (amountAVAX == "0" && amountTAEX == "0");
}

Address WalletManager::userToAddress(std::string const& input) {
  if (h128 u = fromUUID(input)) { return this->wallet.address(u); }
  DEV_IGNORE_EXCEPTIONS(return toAddress(input));
  for (Address const& a: this->wallet.accounts()) {
    if (this->wallet.accountName(a) == input) { return a; }
  }
  return Address();
}

// TODO: make the program not abort on failure but do something else
Secret WalletManager::getSecret(std::string const& address, std::string pass) {
  if (h128 u = fromUUID(address)) {
    return Secret(this->wallet.store().secret(u, [&](){ return pass; }));
  }

  Address a;
  try {
    a = toAddress(address);
  } catch (...) {
    for (Address const& aa: this->wallet.accounts()) {
      if (this->wallet.accountName(aa) == address) {
        a = aa;
        break;
      }
    }
  }

  if (a) {
    return this->wallet.secret(a, [&](){ return pass; });
  } else {
    std::cerr << "Bad file, UUID or address: " << address << std::endl;
    exit(-1);
  }
}

std::string WalletManager::convertWeiToFixedPoint(std::string amount, size_t digits) {
  std::string result;

  if (amount.size() <= digits) {
    size_t ValueToPoint = digits - amount.size();
    result += "0.";
    for (size_t i = 0; i < ValueToPoint; ++i) {
      result += "0";
    }
    result += amount;
  } else {
    result = amount;
    size_t pointToPlace = result.size() - digits;
    result.insert(pointToPlace, ".");
  }

  return result;
}

std::string WalletManager::convertFixedPointToWei(std::string amount, int decimals) {
  std::string digitPadding = "";
  std::string valuestr = "";

  // Check if input is valid
  if (amount.find_first_not_of("0123456789.") != std::string::npos) {
    return "";
  }

  // Read value from input string
  size_t index = 0;
  while (index < amount.size() && amount[index] != '.') {
    valuestr += amount[index];
    ++index;
  }

  // Jump fixed point.
  ++index;

  // Check if fixed point exists
  if (amount[index-1] == '.' && (amount.size() - (index)) > decimals)
    return "";

  // Check if input precision matches digit precision
  if (index < amount.size()) {
    // Read precision point into digitPadding
    while (index < amount.size()) {
      digitPadding += amount[index];
      ++index;
    }
  }

  // Create padding if there are missing decimals
  while(digitPadding.size() < decimals)
    digitPadding += '0';
  valuestr += digitPadding;
  while(valuestr[0] == '0')
    valuestr.erase(0,1);

  return valuestr;
}

std::string WalletManager::getAutomaticFee() {
  return "470"; // AVAX fees are fixed
}

std::string WalletManager::buildTxData(std::string txValue, std::string destWallet) {
  std::string txdata;
  // Hex and padding that will call the "send" function of the address
  std::string sendpadding = "a9059cbb000000000000000000000000";
  // Padding for the value variable of the "send" function
  std::string valuepadding = "0000000000000000000000000000000000000000000000000000000000000000";

  txdata += sendpadding;
  if (destWallet[0] == '0' && destWallet[1] == 'x') {
    destWallet.erase(0,2);
  }
  txdata += destWallet;

  // Convert to HEX
  u256 intValue = boost::lexical_cast<u256>(txValue);
  std::stringstream ss;
  ss << std::hex << intValue;
  std::string amountStrHex = ss.str();

  for (auto& c : amountStrHex) {
    if (std::isupper(c)) {
      c = std::tolower(c);
    }
  }

  for (size_t i = (amountStrHex.size() - 1), x = (valuepadding.size() - 1),
      counter = 0; counter < amountStrHex.size(); --i, --x, ++counter) {
    valuepadding[x] = amountStrHex[i];
  }

  txdata += valuepadding;
  return txdata;
}

TransactionSkeleton WalletManager::buildAVAXTransaction(
  std::string srcAddress, std::string destAddress,
  std::string txValue, std::string txGas, std::string txGasPrice
) {
  TransactionSkeleton txSkel;
  int txNonce;

  std::string nonceApiRequest = Network::getTxNonce(srcAddress);
  std::string txNonceStr = JSON::getValue(nonceApiRequest, "result").get_str();
  // Check if nonce is valid (not an error message)
  if (txNonceStr == "") {
    txSkel.nonce = MAX_U256_VALUE();
    return txSkel;
  }

  std::stringstream nonceStrm;
  nonceStrm << std::hex << txNonceStr;
  nonceStrm >> txNonce;

  // Building the transaction structure
  txSkel.creation = false;
  txSkel.to = toAddress(destAddress);
  txSkel.value = u256(txValue);
  txSkel.nonce = txNonce;
  txSkel.gas = u256(txGas);
  txSkel.gasPrice = u256(txGasPrice);

  return txSkel;
}

TransactionSkeleton WalletManager::buildTAEXTransaction(
    std::string srcAddress, std::string destAddress,
    std::string txValue, std::string txGas, std::string txGasPrice
    ) {
  TransactionSkeleton txSkel;
  int txNonce;
  std::string contractWallet = "a687a9cff994973314c6e2cb313f82d6d78cd232";

  std::string nonceApiRequest = Network::getTxNonce(srcAddress);
  std::string txNonceStr = JSON::getValue(nonceApiRequest, "result").get_str();
  // Check if nonce is valid (not an error message)
  if (txNonceStr == "") {
    txSkel.nonce = MAX_U256_VALUE();
    return txSkel;
  }
  std::stringstream nonceStrm;
  nonceStrm << std::hex << txNonceStr;
  nonceStrm >> txNonce;

  // Building the transaction structure
  txSkel.creation = false;
  txSkel.to = toAddress(contractWallet);
  txSkel.value = u256(0);
  txSkel.data = fromHex(buildTxData(txValue, destAddress));
  txSkel.nonce = txNonce;
  txSkel.gas = u256(txGas);
  txSkel.gasPrice = u256(txGasPrice);

  return txSkel;
}

std::string WalletManager::signTransaction(
    TransactionSkeleton txSkel, std::string pass, std::string address
    ) {
  Secret s = getSecret(address, pass);
  std::stringstream txHexBuffer;

  try {
    TransactionBase t = TransactionBase(txSkel);
    t.setNonce(txSkel.nonce);
    t.sign(s);
    txHexBuffer << toHex(t.rlp());
  } catch (Exception& ex) {
    std::cerr << "Invalid transaction: " << ex.what() << std::endl;
  }

  return txHexBuffer.str();
}

// TODO: change the hardcoded link when switching between mainnet and testnet
std::string WalletManager::sendTransaction(std::string txidHex) {
  std::string txidApiRequest = Network::broadcastTransaction(txidHex);
  std::string txid = JSON::getValue(txidApiRequest, "result").get_str();
  std::string txLink = "https://cchain.explorer.avax-test.network/tx/" + txid;
  return txLink;
}

WalletTxData WalletManager::decodeRawTransaction(std::string rawTxHex) {
  TransactionBase transaction = TransactionBase(fromHex(rawTxHex), CheckTransaction::None);
  WalletTxData ret;

  ret.hex = transaction.sha3().hex();
  if (transaction.isCreation()) {
    ret.type = "creation";
    ret.code = toHex(transaction.data());
  } else {
    ret.type = "message";
    ret.to = boost::lexical_cast<std::string>(transaction.to());
    ret.data = (transaction.data().empty() ? "none" : toHex(transaction.data()));
  }
  try {
    auto s = transaction.sender();
    if (transaction.isCreation()) {
      ret.creates = boost::lexical_cast<std::string>(toAddress(s, transaction.nonce()));
    }
    ret.from = boost::lexical_cast<std::string>(s);
  } catch(...) {
    ret.from = "<unsigned>";
  }
  ret.value = formatBalance(transaction.value()) + " (" +
    boost::lexical_cast<std::string>(transaction.value()) + " wei)";
  ret.nonce = boost::lexical_cast<std::string>(transaction.nonce());
  ret.gas = boost::lexical_cast<std::string>(transaction.gas());
  ret.price = formatBalance(transaction.gasPrice()) + " (" +
    boost::lexical_cast<std::string>(transaction.gasPrice()) + " wei)";
  ret.hash = transaction.sha3(WithoutSignature).hex();
  if (transaction.safeSender()) {
    ret.v = boost::lexical_cast<std::string>(transaction.signature().v);
    ret.r = boost::lexical_cast<std::string>(transaction.signature().r);
    ret.s = boost::lexical_cast<std::string>(transaction.signature().s);
  }

  return ret;
}

std::vector<WalletAccount> WalletManager::ReadWriteWalletVector(bool write, bool changeVector, std::vector<WalletAccount> accountToWrite) {
	std::mutex m;
	m.lock();
	static std::vector<WalletAccount> WalletAccounts;
	if (write) {
		json_spirit::mValue jsonBal;
		if(changeVector) {
			WalletAccounts = {};
			for (auto &accountToRead : accountToWrite)
				WalletAccounts.push_back(accountToRead);
		}
		
		std::string balanceStr;
		for(auto &accountToRead : WalletAccounts) {
			jsonBal = JSON::getValue(Network::getAVAXBalance(accountToRead.address), "result");
			u256 AVAXbalance = boost::lexical_cast<HexTo<u256>>(jsonBal.get_str());
			balanceStr = boost::lexical_cast<std::string>(AVAXbalance);
			// Don't write to vector if an error occurs while reading the JSON
			if (balanceStr == "" || balanceStr.find_first_not_of("0123456789.") != std::string::npos) {
				m.unlock();
				return {};
			}
			accountToRead.balanceAVAX = convertWeiToFixedPoint(balanceStr, 18);
			
			std::string TAEXAddress = accountToRead.address.substr(0, 2) == "0x" ? accountToRead.address.substr(2) : accountToRead.address;
		    jsonBal = JSON::getValue(Network::getTAEXBalance(TAEXAddress, "0xA687A9cff994973314c6e2cb313F82D6d78Cd232"), "result");
            u256 TAEXbalance = boost::lexical_cast<HexTo<u256>>(jsonBal.get_str());
			balanceStr = boost::lexical_cast<std::string>(TAEXbalance);
			if (balanceStr == "" || balanceStr.find_first_not_of("0123456789.") != std::string::npos) {
				m.unlock();
				return {};
			}
	        accountToRead.balanceTAEX = convertWeiToFixedPoint(balanceStr, 18);
		}
		m.unlock();
		return {};
	}
	
	std::vector<WalletAccount> safeWalletAcccounts = WalletAccounts;
	m.unlock();
	return safeWalletAcccounts;
}
void WalletManager::reloadAccountsBalancesThread() {
	while(true) {
		boost::this_thread::sleep_for(boost::chrono::seconds(10));
		ReadWriteWalletVector(true, false, {});
	}
	return;
}

void WalletManager::reloadAccountsBalances() {
	ReadWriteWalletVector(true, false, {});
	return;
}

void WalletManager::loadWalletAccounts(bool start) {
	if (this->wallet.store().keys().empty()) { return; }
	std::vector<WalletAccount> AccountsToLoad;
	AddressHash got;
	
	std::vector<h128> keys = this->wallet.store().keys();
	for (auto const& u : keys) {
    if (Address a = this->wallet.address(u)) {  // Normal accounts
      WalletAccount wa;
      got.insert(a);
      wa.id = toUUID(u);
      wa.privKey = a.abridged();
      wa.name = this->wallet.accountName(a);
      wa.address = "0x" + boost::lexical_cast<std::string>(a);
	  AccountsToLoad.push_back(wa);
    } else {  // Bare accounts
      WalletAccount wa;
      wa.address = "0x" + boost::lexical_cast<std::string>(a) + " (Bare)";
      AccountsToLoad.push_back(wa);
    }
  }
  if (start) {
	boost::thread t(&WalletManager::reloadAccountsBalancesThread, this);
	t.detach();
  }
  
  ReadWriteWalletVector(true, true, AccountsToLoad);
  return;
}

