// Aleth: Ethereum C++ client, tools and libraries.
// Copyright 2017-2019 Aleth Authors.
// Licensed under the GNU General Public License, Version 3.
#include <lib/devcrypto/LibSnark.h>

// #include <common/profiling.hpp>

#include <lib/devcore/Exceptions.h>

using namespace std;
using namespace dev;
using namespace dev::crypto;

pair<bool, bytes> dev::crypto::alt_bn128_pairing_product(dev::bytesConstRef _in)
{
	// Input: list of pairs of G1 and G2 points
	// Output: 1 if pairing evaluates to 1, 0 otherwise (left-padded to 32 bytes)
    return {false, bytes{}};
}

pair<bool, bytes> dev::crypto::alt_bn128_G1_add(dev::bytesConstRef _in)
{
		return {false, bytes{}};
}

pair<bool, bytes> dev::crypto::alt_bn128_G1_mul(dev::bytesConstRef _in)
{
    return {false, bytes{}};
}
