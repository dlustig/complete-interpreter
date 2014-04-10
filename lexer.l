%{
#include <stdio.h>
#include <string.h>
#include "interpreter.tab.h"






%}
%option noyywrap
%%


[0-9]*\.[0-9]+	{yylval.value = atof(yytext); return VAL;}
[0-9]+          {yylval.value = atoi(yytext); return VAL;}
"+"		{return PLUS;}
"-"		{return MINUS;}
"/"		{return DIVIDE;}
"*"		{return TIMES;}
"<"		{return LESS;}
">"		{return GREATER;}
"<="		{return LESSEQ;}
">="		{return GREATEREQ;}
"=="		{return EQUALS;}
"!="		{return NEQUALS;}
"&&"		{return AND;}
"||"		{return OR;}
"!"		{return NOT;}
";"		{return SEMICOLON;}
":="		{return ASSIGN;}
"("		{return LEFT;}
")"		{return RIGHT;}
"begin"		{return Kbegin;}
"end"		{return END;}
"if"		{return IF;}
"then"		{return THEN;}
"else"		{return ELSE;}
"while"		{return WHILE;}
"do"		{return DO;}
"print"		{return PRINT;}
"input"		{return INPUT;}
"%".*$		{}
[ \t\n] 	{}
[a-zA-Z]+	{strcpy(yylval.Id,(yytext)); return Identifier;}
\n
.

%%

