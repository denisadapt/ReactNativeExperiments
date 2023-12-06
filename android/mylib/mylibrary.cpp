#include "mylibrary.h"
#include <string>
#include <fstream>
#include <sstream>

std::string greet(const std::string& name) {
  return "Hello " + name + "!";
}

int32_t add(int32_t a, int32_t b) {
  return a + b;
}

std::string readFileContent(const char* filename) {
  std::ifstream file(filename);
  if (!file.is_open()) {
    return "COULD_NOT_OPEN_FILE";
  }
  std::stringstream buffer;
  buffer << file.rdbuf();
  return buffer.str();
}


