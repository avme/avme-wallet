// Aleth: Ethereum C++ client, tools and libraries.
// Copyright 2014-2019 Aleth Authors.
// Licensed under the GNU General Public License, Version 3.

#pragma once

#include <algebra/curves/alt_bn128/alt_bn128_g1.hpp>
#include <algebra/curves/alt_bn128/alt_bn128_g2.hpp>
#include <algebra/curves/alt_bn128/alt_bn128_pairing.hpp>
#include <algebra/curves/alt_bn128/alt_bn128_pp.hpp>
#include <common/profiling.hpp>
#include <lib/devcore/Common.h>
#include <lib/devcore/Exceptions.h>
#include <lib/devcore/Log.h>

namespace dev
{
namespace crypto
{

std::pair<bool, bytes> alt_bn128_pairing_product(bytesConstRef _in);
std::pair<bool, bytes> alt_bn128_G1_add(bytesConstRef _in);
std::pair<bool, bytes> alt_bn128_G1_mul(bytesConstRef _in);

}
}
