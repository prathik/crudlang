%{
#include <cstdio>
#include <iostream>
#include <map>
#include <fstream>
#include <boost/filesystem.hpp>
#include "makers.hpp"
#include "hibernate.hpp"
#include "help.hpp"
#include "classwriter.hpp"

using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);
string hibernate;
string hibtype;
string directory;
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
    writeClass("./"+directory+"/src/main/java/" + cname + ".java", classFile);
    createMappingFile("./"+directory+"/src/main/resource/" +
            cname + ".hbm.xml", cname, hibtype);
    hibernate += "        <mapping resource=\""+cname+".hbm.xml\"/>\n";

}
     ;

types: type types
     | type
    ;
type: STRING COLON STRING { 
        string dataType = $3;
        string name = $1;
        hibtype += "<property type=\""+hibernateDatatype(dataType)
                        +"\" name=\""+name+"\"/>\n";
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
    string inputfile;
    if(argc != 3) {
        cout << "Invalid usage" << endl;
        cout << getUsage() << endl;
        return -1;
    } else {
        directory = argv[2];
        inputfile = argv[1];
    }
    initPaths(directory);
        // open a file handle to a particular file:
    FILE *myfile = fopen(inputfile.c_str(), "r");
    // make sure it is valid:
    if (!myfile) {
        cout << "Error reading input file" << endl;
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
}

void yyerror(const char *s) {
    cout << "EEK, parse error!  Message: " << s << endl;
    // might as well halt now:
    exit(-1);
}

