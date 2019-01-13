build: inTest
	clear	
	yacc -d ex.y
	flex ex.l
	g++ lex.yy.c y.tab.c -lfl
	./a.out < inTest
