%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>  
#include <string.h>
#include "y.tab.h"
int lineNumber = 1;
int printToken = 0;
%}

%x READ_DQ_STRING_INPUT
%x READ_CHAR_INPUT
%x COMMENT

%%
"//" { 
    BEGIN(COMMENT);
}
<COMMENT>[\n] { BEGIN(INITIAL); }

(?i:program) { if(printToken) printf("\n::> | %s |", yytext); return PROGRAM; }
(?i:integer) { if(printToken) printf("\n::> | %s |", yytext); sprintf(yylval.t.data_type, "%s", "int"); return INTEGER; }
(?i:real) { if(printToken) printf("\n::> | %s |", yytext); sprintf(yylval.t.data_type, "%s", "real"); return REAL; }
(?i:boolean) { if(printToken) printf("\n::> | %s |", yytext); sprintf(yylval.t.data_type, "%s", "boolean"); return BOOLEAN; }
(?i:char) { if(printToken) printf("\n::> | %s |", yytext); sprintf(yylval.t.data_type, "%s", "char"); return CHAR; }
(?i:var) { if(printToken) printf("\n::> | %s |", yytext); return VAR; }
(?i:to) { if(printToken) printf("\n::> | %s |", yytext); return TO; }
(?i:downto) { if(printToken) printf("\n::> | %s |", yytext); return DOWNTO; }
(?i:if) { if(printToken) printf("\n::> | %s |", yytext); return IF; }
(?i:else) { if(printToken) printf("\n::> | %s |", yytext); return ELSE; }
(?i:while) { if(printToken) printf("\n::> | %s |", yytext); return WHILE; }
(?i:for) { if(printToken) printf("\n::> | %s |", yytext); return FOR; }
(?i:do) { if(printToken) printf("\n::> | %s |", yytext); return DO; }
(?i:array) { if(printToken) printf("\n::> | %s |", yytext); return ARRAY; }
(?i:and) { if(printToken) printf("\n::> | %s |", yytext); return AND; }
(?i:or) { if(printToken) printf("\n::> | %s |", yytext); return OR; }
(?i:not) { if(printToken) printf("\n::> | %s |", yytext); return NOT; }
(?i:begin) { if(printToken) printf("\n::> | %s |", yytext); return BEGINK; }
(?i:end) { if(printToken) printf("\n::> | %s |", yytext); return END; }
(?i:read) { if(printToken) printf("\n::> | %s |", yytext); return READ;}
(?i:write) { if(printToken) printf("\n::> | %s |", yytext); return WRITE; }
(?i:writeln) { if(printToken) printf("\n::> | %s |", yytext); return WRITE_LN; }
(?i:then) { if(printToken) printf("\n::> | %s |", yytext); return THEN; }
(?i:of) {if(printToken) printf("\n::> | %s |", yytext); return OF;}

[+] { if(printToken) printf("\n::> | %s |", yytext); return PLUS; }
[-] { if(printToken) printf("\n::> | %s |", yytext); return MINUS; }
[*] { if(printToken) printf("\n::> | %s |", yytext); return MULTIPLY; }
[/] { if(printToken) printf("\n::> | %s |", yytext); return DIVIDE; }
[%] { if(printToken) printf("\n::> | %s |", yytext); return MOD; }

[=] { if(printToken) printf("\n::> | %s |", yytext); return EQUAL; }
\< { if(printToken) printf("\n::> | %s |", yytext); return LESS; }
\> { if(printToken) printf("\n::> | %s |", yytext); return GREATER; }
\<\= { if(printToken) printf("\n::> | %s |", yytext); return LESSEQUAL; }
\>\= { if(printToken) printf("\n::> | %s |", yytext); return GREATEREQUAL; }
\<\> { if(printToken) printf("\n::> | %s |", yytext); return NOTEQUAL; }

[;] { if(printToken) printf("\n::> | %s |", yytext); return SEMICOLON; }
[,] { if(printToken) printf("\n::> | %s |", yytext); return COMMA; }
[:] { if(printToken) printf("\n::> | %s |", yytext); return COLON; }
[.][.] { if(printToken) printf("\n::> | %s |", yytext); return ARRAY_DOT; }
[.] { if(printToken) printf("\n::> | %s |", yytext); return DOT; }
[(] { if(printToken) printf("\n::> | %s |", yytext); return LPAREN; }
[)] { if(printToken) printf("\n::> | %s |", yytext); return RPAREN;}
[[] { if(printToken) printf("\n::> | %s |", yytext); return LBRACKET; }
[]] { if(printToken) printf("\n::> | %s |", yytext); return RBRACKET; }

[\"] { BEGIN(READ_DQ_STRING_INPUT); }
<READ_DQ_STRING_INPUT>[^\n^\"]* { if(printToken) printf("\n::> | %s |", yytext); sprintf(yylval.t.val, "%s", yytext); sprintf(yylval.t.data_type, "%s", "string"); return STRING; }
<READ_DQ_STRING_INPUT>[\"] { BEGIN(INITIAL); }

[\'] { BEGIN(READ_CHAR_INPUT); }
<READ_CHAR_INPUT>[^\n^\'] { if(printToken) printf("\n::> | %s |", yytext); sprintf(yylval.t.val, "%s", yytext); return CHARACTER; }
<READ_CHAR_INPUT>[\'] { BEGIN(INITIAL); }

[0-9]+ { if(printToken) printf("\n::> | %s |", yytext); sprintf(yylval.t.val, "%s", yytext); sprintf(yylval.t.data_type, "%s", "int"); return INT_NUMBER; }
[0-9]+[.][0-9]+ { if(printToken) printf("\n::> | %s |", yytext); sprintf(yylval.t.data_type, "%s", "real"); return DECIMAL_NUMBER; }

[a-zA-Z][a-zA-Z0-9_]* {  if(printToken) printf("\n::> | %s |", yytext);  sprintf(yylval.t.id_name, "%s", yytext); return IDENTIFIER; }

[[:space:]]+ {}

.  { if(printToken) printf("\n::> | %s |", yytext); return INVALID_TOKEN;}

%%