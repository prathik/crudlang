#include <cstdio>
#include <iostream>
#include <boost/filesystem.hpp>

using namespace std;

string makeGetter(string type, string name) {
    string firstCharUpper = name;
    firstCharUpper[0] = toupper(name[0]);
    string result = "    " + type + " " + "get" + firstCharUpper;
    result += "() { \n";
    result += "        return this."+name+"; \n    }";
    return result;
}

string makeSetter(string type, string name) {
    string firstCharUpper = name;
    firstCharUpper[0] = toupper(name[0]);
    string result = "    void set" + firstCharUpper;
    result += "("+type+" "+name+ ") { \n";
    result += "        this."+name+"="+name+"; \n    }";
    return result;
}

void initPaths(string directory) {
    boost::filesystem::path p = "./"+directory+"/";
    boost::filesystem::path pom_create = "./"+directory+"/pom.xml";
    boost::filesystem::path pom_resource = "./resources/pom.xml";
    boost::filesystem::path r = "./"+directory+"/src/main/resource/";
    boost::filesystem::path src = "./"+directory+"/src/main/java/";
    boost::filesystem::remove_all(p);

    boost::filesystem::create_directory(p);
    boost::filesystem::create_directories(r);
    boost::filesystem::create_directories(src);
    boost::filesystem::copy_file(pom_resource, pom_create, 
            boost::filesystem::copy_option::overwrite_if_exists);


}
