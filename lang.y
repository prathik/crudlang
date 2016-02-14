%{
#include <cstdio>
#include <iostream>
#include <map>
#include <fstream>
#include <boost/filesystem.hpp>

using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);
string makeGetter(string, string);
string makeSetter(string, string);
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

void createHibernateConfig(string hibernateMapping) {
    string hibInit = "";
    hibInit = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
    hibInit += "<!DOCTYPE hibernate-configuration SYSTEM\n";
    hibInit += "        \"http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd\">\n";
    
    hibInit +="<hibernate-configuration>\n";
    hibInit +="    <session-factory>\n";
    hibInit +="        <property name=\"hbm2ddl.auto\">update</property>\n";
    hibInit +="        <property name=\"hibernate.dialect\">\n";
    hibInit +="            org.hibernate.dialect.MySQLDialect\n";
    hibInit +="        </property>\n";
    hibInit +="        <property name=\"hibernate.connection.driver_class\">\n";
    hibInit +="            com.mysql.jdbc.Driver\n";
    hibInit +="        </property>\n";
    hibInit +="        <!-- Assume test is the database name -->\n";
    hibInit +="        <property name=\"hibernate.connection.url\">\n";
    hibInit +="            jdbc:mysql://localhost:3306/tasks\n";
    hibInit +="        </property>\n";
    hibInit +="        <property name=\"hibernate.connection.username\">\n";
    hibInit +="            root\n";
    hibInit +="        </property>\n";
    hibInit +="        <property name=\"hibernate.connection.password\">\n";
    hibInit +="            password\n";
    hibInit +="        </property>\n";
    hibInit +="        <property name=\"show_sql\">true</property>\n";
    ofstream mf;
    mf.open ("./out/main/resource/hibernate.cfg.xml");
    mf << hibInit;
    mf << hibernate;
    mf << "    </session-factory>\n";
    mf << "</hibernate-configuration>";
    mf.close();
    
}

int main(int, char**) {
    boost::filesystem::path p = "./out/";
    boost::filesystem::path r = "./out/main/resource/";
    boost::filesystem::path src = "./out/main/src/java/";
    boost::filesystem::remove_all(p);

    boost::filesystem::create_directory(p);
    boost::filesystem::create_directories(r);
    boost::filesystem::create_directories(src);
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

    createHibernateConfig(hibernate);
    for(auto elem: classMap) {
        ofstream mf;
        string fileName = elem.first;
        mf.open ("./out/main/src/java/" + fileName + ".java");
        mf << elem.second;
        mf.close();
    }
 for(auto elem: hibFiles) {
        ofstream mf;
        string fileName = elem.first;
        mf.open ("./out/main/resource/" + fileName + ".hbm.xml");
        mf << elem.second;
        mf.close();
    }
}

void yyerror(const char *s) {
    cout << "EEK, parse error!  Message: " << s << endl;
    // might as well halt now:
    exit(-1);
}

