#include <string>
#include <boost/filesystem.hpp>
#include "json.h"

namespace storage {
	
	// Avoid two threads trying to read/write, even if it is different files 
	// Better safe than sorry!
	static std::mutex storageThreadLock;
	
	boost::filesystem::path GetDefaultDataDir();
	boost::filesystem::path GetDataDir();
	
	json_spirit::mValue readJsonFile(boost::filesystem::path filePath);
	json_spirit::mValue writeJsonFile(json_spirit::mObject jsonObject, boost::filesystem::path filePath);
	
}