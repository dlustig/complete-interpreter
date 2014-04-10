
calc: lex.yy.c interpreter.tab.c
	gcc lex.yy.c interpreter.tab.c -o calc

lex.yy.c: lexer.l interpreter.tab.h
	flex lexer.l

interpreter.tab.h: interpreter.tab.c
interpreter.tab.c: interpreter.y
	bison -d interpreter.y

clean:
	rm -f calc lex.yy.c interpreter.tab.h interpreter.tab.c
