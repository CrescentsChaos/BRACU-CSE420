#ifndef SYMBOL_INFO_H
#define SYMBOL_INFO_H

#include <string>
using namespace std;

class symbol_info {
    string name;
    string type;

public:
    symbol_info(const string &n = "", const string &t = "")
        : name(n), type(t) {}

    string getname() const { return name; }
    string gettype() const { return type; }
};

#endif // SYMBOL_INFO_H
