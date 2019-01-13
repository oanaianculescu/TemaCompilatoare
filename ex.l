%{
	#include "y.tab.h"
	int lineNo = 1;
	int colNo = 1;

%}

%option yylineno

%%
";"				{ colNo++; return ';'; }
":"				{ colNo++; return ':'; }
","				{ colNo++; return ','; }
"."				{ colNo++; return '.'; }
":="				{ colNo++; return TOK_EQUALS; }
"+"				{ colNo++; return TOK_PLUS; }
"-"				{ colNo++; return TOK_MINUS; }
"*"				{ colNo++; return TOK_MULTIPLY; }
"("				{ colNo++; return TOK_LEFT; }
")"				{ colNo++; return TOK_RIGHT; }
"PROGRAM"			{ colNo+=7; return TOK_PROGRAM; }
"VAR"				{ colNo+=3; return TOK_VAR; }
"BEGIN"				{ colNo+=5; return TOK_BEGIN; }
"END"				{ colNo+=3; return TOK_END; }
"INTEGER"			{ colNo+=7; return TOK_INTEGER; }
"READ"				{ colNo+=4; return TOK_READ; }
"WRITE"				{ colNo+=5; return TOK_WRITE; }
"FOR"				{ colNo+=3; return TOK_FOR; }
"DO"				{ colNo+=2; return TOK_DO; }
"TO"				{ colNo+=2; return TOK_TO; }
"DIV"				{ colNo+=3; return TOK_DIV; }
0|[1-9][0-9]*			{ colNo+=strlen(yytext); yylval.val = atoi(yytext); return TOK_INT; }
[a-zA-Z][a-zA-Z0-9_]* 		{ colNo+=strlen(yytext); yylval.sir = new char[strlen(yytext)+1]; strcpy(yylval.sir,yytext); return TOK_ID;}
[ ]				{ colNo++; }
\r\n			        { lineNo++; colNo=1; }
\n				{ lineNo++; colNo=1; }
.				{ throw "EROARE LEXICALA"; }
%%