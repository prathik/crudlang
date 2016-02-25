%{
#include <cstdio>
#include <iostream>
#include <map>
#include <fstream>
#include <boost/filesystem.hpp>
#include "makers.hpp"
#include "hibernate.hpp"

using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);
std::map<string, string> classMap;
   std::map<string, string> hibFiles;
string hibernate;
string hibtype;
%}
%union {
    char *sval;
}

%token <sval> STRING
%token COLON
%token SCOLON
%token PACKAGE
%right SCOLON
%type<sval> cname type types
%%
clang: class SCOLON clang 
     | class SCOLON 
     ;

class: cname types { 
     string cname = $1;
    string types = $2;
    string classFile = "class " + cname + " { \n" + types + "}";
    classMap[cname] = classFile;
    hibFiles[cname] = hibtype;
    hibernate += "        <mapping resource=\""+cname+".hbm.xml\"/>\n";

}
     ;

types: type types
     | type
    ;
type: STRING COLON STRING { 
    string dataType = $3;
    string name = $1;
    hibtype += "<property name=\""+name+"\"/>\n";
    string final = "    " + dataType + " " + name + ";\n";
    final += makeGetter($3, $1) + "\n";
    final += makeSetter($3, $1) + "\n";
    delete $$;
    $$ = new char[final.length()];
    strcpy($$, final.c_str());
    }
    ;
cname:
     STRING   { hibtype = ""; }       
    ;
%%

int main(int argc, char** argv) {
    //Complete rest crud for all the models without any coding
    string directory;
    if(argc == 1) {
        directory = "out";
    } else {
        directory = argv[1];
    }
    initPaths(directory);
        // open a file handle to a particular file:
    FILE *myfile = fopen("a.snazzle.file", "r");
    // make sure it is valid:
    if (!myfile) {
        cout << "I can't open a.snazzle.file!" << endl;
        return -1;
    }
    // set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;
    hibernate = "";

// parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));

    createHibernateConfig(hibernate, directory);
    for(auto elem: classMap) {
        ofstream mf;
        string fileName = elem.first;
        mf.open ("./"+directory+"/src/main/java/" + fileName + ".java");
        mf << elem.second;
        mf.close();
    }
 for(auto elem: hibFiles) {
        ofstream mf;
        string fileName = elem.first;
        mf.open ("./"+directory+"/src/main/resource/" + fileName + ".hbm.xml");
        mf << elem.second;
        mf.close();
    }
}

void yyerror(const char *s) {
    cout << "EEK, parse error!  Message: " << s << endl;
    // might as well halt now:
    exit(-1);
}

