#include "storage.h"

namespace storage {
  boost::filesystem::path GetDefaultDataDir() {
    namespace fs = boost::filesystem;
    // Windows: C:\Users\Username\AppData\Roaming\AVME
    // Unix: ~/.avme
    #ifdef WIN32
      // Windows
      return GetSpecialFolderPath(CSIDL_APPDATA) / "AVME";
    #else
      // Unix
      fs::path pathRet;
      char* pszHome = getenv("HOME");
      if (pszHome == NULL || strlen(pszHome) == 0)
        pathRet = fs::path("/");
      else
        pathRet = fs::path(pszHome);
      return pathRet / ".avme";
    #endif
  }

  boost::filesystem::path GetDataDir() {
    boost::filesystem::path dataPath = GetDefaultDataDir();
    if (!boost::filesystem::exists(dataPath))
      boost::filesystem::create_directory(dataPath);
    return dataPath;
  }

  json_spirit::mValue readJsonFile(boost::filesystem::path filePath) {
    json_spirit::mValue returnData;
    storageThreadLock.lock();

    boost::filesystem::path finalPath = GetDataDir() / filePath;
    if (!boost::filesystem::exists(finalPath)) {
      json_spirit::mObject errorData;
      errorData["ERROR"] = "FILE DOES NOT EXIST";
      storageThreadLock.unlock();
      return json_spirit::mValue(errorData);
    }
    std::ifstream jsonFile(finalPath.c_str());
    json_spirit::read_stream(jsonFile, returnData);

    storageThreadLock.unlock();
    return json_spirit::mValue(returnData);
  }

  json_spirit::mValue writeJsonFile(json_spirit::mObject jsonObject, boost::filesystem::path filePath) {
    json_spirit::mObject returnData;
    storageThreadLock.lock();

    boost::filesystem::path finalPath = GetDataDir() / filePath;
    try {
      std::ofstream os(finalPath.c_str());
      json_spirit::write_stream(json_spirit::mValue(jsonObject), os, true);
      os.close();
    } catch (std::exception &e) {
      returnData["ERROR"] = e.what();
      storageThreadLock.unlock();
      return json_spirit::mValue(returnData);
    }

    storageThreadLock.unlock();
    return json_spirit::mValue(returnData);
  }
}

