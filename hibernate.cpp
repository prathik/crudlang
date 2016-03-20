#include <cstdio>
#include <iostream>
#include <map>
#include <fstream>

using namespace std;

string hibernateDatatype(string datatype) {
    if(datatype == "Date")
    {
        return "date";
    }

    return datatype;
}

void createHibernateConfig(string hibernateMapping, string directory) {
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
    hibInit +="            jdbc:mysql://localhost:3306/crudlang\n";
    hibInit +="        </property>\n";
    hibInit +="        <property name=\"hibernate.connection.username\">\n";
    hibInit +="            root\n";
    hibInit +="        </property>\n";
    hibInit +="        <property name=\"hibernate.connection.password\">\n";
    hibInit +="            password\n";
    hibInit +="        </property>\n";
    hibInit +="        <property name=\"show_sql\">true</property>\n";
    ofstream mf;
    mf.open ("./"+directory+"/src/main/resource/hibernate.cfg.xml");
    mf << hibInit;
    mf << hibernateMapping;
    mf << "    </session-factory>\n";
    mf << "</hibernate-configuration>";
    mf.close();
}

void createMappingFile(string path, string classname, string mapping) {
    ofstream mf;
    mf.open(path);
    mf << "<hibernate-mapping>" << endl;
    mf << "<class name=\""+classname+"\" table=\""+classname+"\">" << endl;
    mf << mapping;
    mf << "</class>" << endl;
    mf << "</hibernate-mapping>" << endl;
    mf.close();
}
