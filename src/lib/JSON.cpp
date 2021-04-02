#include "JSON.h"

json_spirit::mValue JSON::objectItem(
  const json_spirit::mValue element, const std::string name
) {
  return element.get_obj().at(name);
}

json_spirit::mValue JSON::arrayItem(
  const json_spirit::mValue element, size_t index
) {
  return element.get_array().at(index);
}

json_spirit::mValue JSON::getValue(
  std::string jsonStr, std::string value, std::string delim
) {
  json_spirit::mValue ret;

  /**
   * Check if JSON string is valid, and if it is, get the value.
   * For nested values (w/ delim), tokenize and iterate until we get
   * to the last value (which is the one we want).
   * For non-nested values (w/o delim), simply get the value directly.
   */
  if (json_spirit::read_string(jsonStr, ret)) {
    try {
      if (!delim.empty()) {
        size_t pos = 0;
        while ((pos = value.find(delim)) != std::string::npos) {
          ret = objectItem(ret, value.substr(0, pos));
          value.erase(0, pos + delim.length());
        }
      }
      ret = objectItem(ret, value);
    } catch (std::exception &e) {
      std::cout << "Error when reading json for \"" << value << "\": " << e.what() << std::endl;
      std::cout << "Message: " << objectItem(objectItem(ret, "error"), "message").get_str() << std::endl;
    }
  } else {
    std::cout << "Error reading json, check value: " << jsonStr << std::endl;
  }

  return ret;
}

boost::filesystem::path JSON::getDefaultDataDir() {
  namespace fs = boost::filesystem;
  #ifdef WIN32
    // Windows: C:\Users\Username\AppData\Roaming\AVME
    return GetSpecialFolderPath(CSIDL_APPDATA) / "AVME";
  #else
    // Unix: ~/.avme
    fs::path pathRet;
    char* pszHome = getenv("HOME");
    if (pszHome == NULL || strlen(pszHome) == 0)
      pathRet = fs::path("/");
    else
      pathRet = fs::path(pszHome);
    return pathRet / ".avme";
  #endif
}

boost::filesystem::path JSON::getDataDir() {
  boost::filesystem::path dataPath = getDefaultDataDir();
  if (!boost::filesystem::exists(dataPath))
    boost::filesystem::create_directory(dataPath);
  return dataPath;
}

json_spirit::mValue JSON::readFile(boost::filesystem::path filePath) {
  json_spirit::mValue returnData;
  storageThreadLock.lock();

  boost::filesystem::path finalPath = getDataDir() / filePath;
  if (!boost::filesystem::exists(finalPath)) {
    json_spirit::mObject errorData;
    errorData["ERROR"] = "FILE DOES NOT EXIST";
    storageThreadLock.unlock();
    return json_spirit::mValue(errorData);
  }
  
  try {
    std::ifstream jsonFile(finalPath.c_str());
    json_spirit::read_stream(jsonFile, returnData);
  } catch (std::exception &e) {
    returnData["ERROR"] = e.what();
	storageThreadLock.unlock();
	return json_spirit::mValue(returnData);
  }

  storageThreadLock.unlock();
  return json_spirit::mValue(returnData);
}

json_spirit::mValue JSON::writeFile(json_spirit::mObject jsonObject, boost::filesystem::path filePath) {
  json_spirit::mObject returnData;
  storageThreadLock.lock();

  boost::filesystem::path finalPath = getDataDir() / filePath;
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

