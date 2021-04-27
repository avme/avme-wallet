// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
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

std::string JSON::getString(std::string jsonStr, std::string value, std::string delim) {
  json_spirit::mValue val = getValue(jsonStr, value, delim);
  try {
    return val.get_str();
  } catch (std::exception &e) {
    return "";
  }
}

std::vector<std::map<std::string, std::string>> JSON::getObjectArray(
  std::string jsonStr, std::string value, std::string delim
) {
  json_spirit::mValue val = getValue(jsonStr, value, delim);
  std::vector<std::map<std::string, std::string>> ret;
  try {
    json_spirit::mArray arr = val.get_array();
    for (int i = 0; i < arr.size(); i++) {
      json_spirit::mObject obj = arr[i].get_obj();
      std::map<std::string, std::string> pairs;
      for (auto a : obj) {
        std::string key = a.first;
        std::string value;
        switch (a.second.type()) {
          case json_spirit::str_type:
            value = a.second.get_str();
            break;
          case json_spirit::int_type:
            value = boost::lexical_cast<std::string>(a.second.get_int());
            break;
          default:
            throw std::runtime_error("Error: json_spirit type not supported");
            break;
        }
        pairs.insert(std::pair<std::string, std::string>(key, value));
      }
      ret.push_back(pairs);
    }
    return ret;
  } catch (std::exception &e) {
    std::cout << e.what() << std::endl;
    return {};
  }
}

#ifdef __MINGW32__
boost::filesystem::path JSON::GetSpecialFolderPath(int nFolder, bool fCreate) {
  WCHAR pszPath[MAX_PATH] = L"";
  if (SHGetSpecialFolderPathW(nullptr, pszPath, nFolder, fCreate)) {
    return boost::filesystem::path(pszPath);
  }
  return boost::filesystem::path("");
}
#endif

boost::filesystem::path JSON::getDefaultDataDir() {
  namespace fs = boost::filesystem;
  #ifdef __MINGW32__
    // Windows: C:\Users\Username\AppData\Roaming\AVME
    return JSON::GetSpecialFolderPath(CSIDL_APPDATA) / "AVME";
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

  if (!boost::filesystem::exists(filePath)) {
    json_spirit::mObject errorData;
    errorData["ERROR"] = "FILE DOES NOT EXIST";
    storageThreadLock.unlock();
    return json_spirit::mValue(errorData);
  }

  try {
    std::ifstream jsonFile(filePath.c_str());
    json_spirit::read_stream(jsonFile, returnData);
  } catch (std::exception &e) {
    json_spirit::mObject errorData;
    errorData["ERROR"] = e.what();
    storageThreadLock.unlock();
    return json_spirit::mValue(errorData);
  }

  storageThreadLock.unlock();
  return json_spirit::mValue(returnData);
}

json_spirit::mValue JSON::writeFile(json_spirit::mObject jsonObject, boost::filesystem::path filePath) {
  json_spirit::mObject returnData;
  storageThreadLock.lock();

  try {
    std::ofstream os(filePath.c_str());
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

