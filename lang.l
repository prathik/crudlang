%{
#include <cstdio>
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()

#include "lang.tab.h"  // to get the token types that we return

%}
%%
[ \t]           ;
[;]     {
        return SCOLON;
        }

[:]     {
        return COLON;
        }
[a-zA-Z0-9]+      {
    yylval.sval = strdup(yytext);
    return STRING;
}
.                ;
%%
