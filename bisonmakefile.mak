
calc: lex.yy.c parser.tab.c
	gcc -g lex.yy.c parser.tab.c -o calc

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

parser.tab.h: parser.tab.c
parser.tab.c: parser.y
	bison -d parser.y

clean:
	rm -f calc lex.yy.c parser.tab.h parser.tab.c
