// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "ParaSwap.h"

namespace ParaSwap {


  std::string getTokenPrices(std::string srcToken, 
                             std::string srcDecimal, 
                             std::string destToken,
                             std::string destDecimals,
                             std::string weiAmount,
                             std::string side,
                             std::string chainID) {
    std::stringstream request;

    request << "srcToken=" << srcToken << "&";
    request << "destToken=" << destToken << "&";
    request << "amount=" << weiAmount << "&";
    request << "srcDecimals=" << srcDecimal << "&";
    request << "destDecimals=" << destDecimals << "&";
    request << side << "&";
    request << "network=" << chainID << "&";
    request << "otherExchangePrices=true" << "&";
    request << "partner=paraswap.io";

    std::cout << request.str() << std::endl;
    std::string ret = API::customHttpRequest("",
                                            "apiv5.paraswap.io",
                                            "443",
                                            "/prices/?" + request.str(),
                                            "GET",
                                            "application/json");

    return ret;
  }

  std::string getTransactionData(std::string priceRouteStr, 
                                 std::string slippage, 
                                 std::string userAddress, 
                                 std::string fee) {
    nlohmann::ordered_json request;
    nlohmann::ordered_json priceRoute = nlohmann::ordered_json::parse(priceRouteStr);
    request["srcToken"] = priceRoute["priceRoute"]["srcToken"];
    request["destToken"] = priceRoute["priceRoute"]["destToken"];
    request["srcAmount"] = priceRoute["priceRoute"]["srcAmount"];
    bigfloat destAmount = boost::multiprecision::floor(
        boost::lexical_cast<bigfloat>(priceRoute["priceRoute"]["destAmount"].get<std::string>()) * boost::lexical_cast<bigfloat>(slippage)
      );
    request["destAmount"] = destAmount.str(256);
    request["priceRoute"] = priceRoute["priceRoute"];
    request["userAddress"] = userAddress;
    request["srcDecimals"] = priceRoute["priceRoute"]["srcDecimals"];
    request["destDecimals"] = priceRoute["priceRoute"]["destDecimals"];
    request["partnerAddress"] = "0x1ECd47FF4d9598f89721A2866BFEb99505a413Ed";
    request["partnerFeeBps"] = fee;

    std::string ret = API::customHttpRequest(request.dump(),
                                            "apiv5.paraswap.io",
                                            "443",
                                            "/transactions/" + Utils::jsonToStr(json::parse(priceRouteStr)["priceRoute"]["network"]) + "?ignoreChecks=true",
                                            "POST",
                                            "application/json");

    return ret;
  }
}