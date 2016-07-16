#include <cstdio>
#include <iostream>
#include <map>
#include <fstream>

using namespace std;

void writeClass(string path, string classFile) {
    ofstream mf;
    mf.open(path);
    mf << classFile;
    mf.close();
}
