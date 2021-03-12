#include <fstream>
#include <string>
#include <boost/filesystem.hpp>
#include "json.h"

// Storage for sent transactions

// TODO: error handling on everything

namespace storage {
  // Avoid two threads trying to read/write, even if it is different files.
  // Better safe than sorry!
  static std::mutex storageThreadLock;

  // Get the storage directory
  boost::filesystem::path GetDefaultDataDir();
  boost::filesystem::path GetDataDir();

  // Read/write JSON files
  json_spirit::mValue readJsonFile(boost::filesystem::path filePath);
  json_spirit::mValue writeJsonFile(json_spirit::mObject jsonObject, boost::filesystem::path filePath);
}
