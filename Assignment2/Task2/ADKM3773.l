%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
extern int yylval;
int lineNumber = 1;
int printToken = 0;
%}

%x READ_STRING_INPUT
%x COMMENT

%%
"//" { 
    BEGIN(COMMENT);
}
<COMMENT>[\n] { BEGIN(INITIAL); }

[p|P][r|R][o|O][g|G][r|R][a|A][m|M] { if(printToken) printf("\n::> | %s |", yytext); return PROGRAM; }
[i|I][n|N][t|T][e|E][g|G][e|E][r|R] { if(printToken) printf("\n::> | %s |", yytext); return INTEGER; }
[r|R][e|E][a|A][l|L] { if(printToken) printf("\n::> | %s |", yytext); return REAL; }
[b|B][o|O][o|O][l|L][e|E][a|A][n|N] { if(printToken) printf("\n::> | %s |", yytext); return BOOLEAN; }
[c|C][h|H][a|A][r|R] { if(printToken) printf("\n::> | %s |", yytext); return CHAR; }
[v|V][a|A][r|R] { if(printToken) printf("\n::> | %s |", yytext); return VAR; }
[f|F][o|O][r|R] { if(printToken) printf("\n::> | %s |", yytext); return FOR; }
[t|T][o|O] { if(printToken) printf("\n::> | %s |", yytext); return TO; }
[d|D][o|O][w|W][n|N][t|T][o|O] { if(printToken) printf("\n::> | %s |", yytext); return DOWNTO; }
[i|I][f|F] { if(printToken) printf("\n::> | %s |", yytext); return IF; }
[e|E][l|L][s|S][e|E] { if(printToken) printf("\n::> | %s |", yytext); return ELSE; }
[d|D][o|O] { if(printToken) printf("\n::> | %s |", yytext); return DO; }
[w|W][h|H][i|I][l|L][e|E] { if(printToken) printf("\n::> | %s |", yytext); return WHILE; }
[a|A][r|R][r|R][a|A][y|Y] { if(printToken) printf("\n::> | %s |", yytext); return ARRAY; }
[a|A][n|N][d|D] { if(printToken) printf("\n::> | %s |", yytext); return AND; }
[o|O][r|R] { if(printToken) printf("\n::> | %s |", yytext); return OR; }
[n|N][o|O][t|T] { if(printToken) printf("\n::> | %s |", yytext); return NOT; }
[b|B][e|E][g|G][i|I][n|N] { if(printToken) printf("\n::> | %s |", yytext); return BEGINK; }
[e|E][n|N][d|D] { if(printToken) printf("\n::> | %s |", yytext); return END; }
[r|R][e|E][a|A][d|D] { if(printToken) printf("\n::> | %s |", yytext); return READ;}
[w|W][r|R][i|I][t|T][e|E] { if(printToken) printf("\n::> | %s |", yytext); return WRITE; }
[t|T][h|H][e|E][n|N] { if(printToken) printf("\n::> | %s |", yytext); return THEN; }
[o|O][f|F] {if(printToken) printf("\n::> | %s |", yytext); return OF;}

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

[\"] { BEGIN(READ_STRING_INPUT); }
<READ_STRING_INPUT>[^\n^\"]* { if(printToken) printf("\n::> | %s |", yytext); return STRING; }
<READ_STRING_INPUT>[\"] { BEGIN(INITIAL); }

[0-9]+ { if(printToken) printf("\n::> | %s |", yytext); return NUMBER; }

[a-zA-Z][a-zA-Z0-9_]* {  if(printToken) printf("\n::> | %s |", yytext); return IDENTIFIER; }

[\n] {}
[\t] {}
[ ] {}

. { }

%%