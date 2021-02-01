#include "json.h"

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

