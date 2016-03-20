CC = g++

LDFLAGS = -I/usr/local/Cellar/boost/1.60.0_1/include 

LLIBFLAGS = -L/usr/local/Cellar/boost/1.60.0_1/

LINKFLAGS = -lboost_filesystem -lboost_system

FLAGS =  $(LLIBFLAGS) $(LDFLAGS) $(LINKFLAGS)

lang.tab.c lang.tab.h: lang.y makers.hpp hibernate.hpp help.hpp
	bison -d lang.y

lex.yy.c: lang.l lang.tab.h
	flex lang.l

cl: lex.yy.c lang.tab.c lang.tab.h makers.cpp hibernate.cpp
	$(CC) $(FLAGS) lang.tab.c lex.yy.c makers.cpp hibernate.cpp help.cpp -ll -o cl
