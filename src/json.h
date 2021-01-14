#ifndef JSON_H
#define JSON_H

#include <iostream>
#include <string>

#include <json_spirit/JsonSpiritHeaders.h>

// Collection of JSON-related functions (e.g. parsing, handling, etc.).

class JSON {
  public:
    // Get object item from a JSON element.
    static json_spirit::mValue objectItem(
      const json_spirit::mValue element, const std::string name
    );

    // Get array item from a JSON element.
    static json_spirit::mValue arrayItem(
      const json_spirit::mValue element, size_t index
    );

    /**
     * Get a specific value from a JSON element.
     * Specify a delimiter to search nested values, e.g. "foo/bar" searches
     * for "bar" inside of "foo".
     * Returns the value in JSON format (which should call json_spirit's
     * get_str() or similar to properly get the data), or nothing on failure.
     */
    static json_spirit::mValue getValue(
      std::string jsonStr, std::string value, std::string delim = ""
    );
};

#endif // JSON_H

