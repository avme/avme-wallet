// Aleth: Ethereum C++ client, tools and libraries.
// Copyright 2014-2019 Aleth Authors.
// Licensed under the GNU General Public License, Version 3.

#pragma once

#include <string>
#if defined(_WIN32)
  #include <shlobj.h>
#else
  #include <stdlib.h>
  #include <stdio.h>
  #include <pwd.h>
  #include <unistd.h>
#endif

#include <boost/filesystem.hpp>

#include "Common.h"
#include "Log.h"

namespace dev
{

/// Sets the data dir for the default ("ethereum") prefix.
void setDataDir(boost::filesystem::path const& _dir);
/// @returns the path for user data.
boost::filesystem::path getDataDir(std::string _prefix = "ethereum");
/// @returns the default path for user data, ignoring the one set by `setDataDir`.
boost::filesystem::path getDefaultDataDir(std::string _prefix = "ethereum");
/// Sets the ipc socket dir
void setIpcPath(boost::filesystem::path const& _ipcPath);
/// @returns the ipc path (default is DataDir)
boost::filesystem::path getIpcPath();

/// @returns a new path whose file name is suffixed with the given suffix.
boost::filesystem::path appendToFilename(boost::filesystem::path const& _orig, std::string const& _suffix);

}
