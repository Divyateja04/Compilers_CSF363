%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
extern int yylval;
int lineNumber = 1;
%}

%%
[p|P][r|R][o|O][g|G][r|R][a|A][m|M] { fprintf(yyout, "\n%d, KEYWORD, PROGRAM", lineNumber); return PROGRAM; }
[i|I][n|N][t|T] { fprintf(yyout, "\n%d, KEYWORD, INT", lineNumber); return INT; }
[r|R][e|E][a|A][l|L] { fprintf(yyout, "\n%d, KEYWORD, REAL", lineNumber); return REAL; }
[b|B][o|O][o|O][l|L][e|E][a|A][n|N] { fprintf(yyout, "\n%d, KEYWORD, BOOLEAN", lineNumber); return BOOLEAN; }
[c|C][h|H][a|A][r|R] { fprintf(yyout, "\n%d, KEYWORD, CHAR", lineNumber); return CHAR; }
[v|V][a|A][r|R] { fprintf(yyout, "\n%d, KEYWORD, VAR", lineNumber); return VAR; }
[f|F][o|O][r|R] { fprintf(yyout, "\n%d, KEYWORD, FOR", lineNumber); return FOR; }
[d|D][o|O] { fprintf(yyout, "\n%d, KEYWORD, DO", lineNumber); return DO; }
[w|W][h|H][i|I][l|L][e|E] { fprintf(yyout, "\n%d, KEYWORD, WHILE", lineNumber); return WHILE; }
[a|A][r|R][r|R][a|A][y|Y] { fprintf(yyout, "\n%d, KEYWORD, ARRAY", lineNumber); return ARRAY; }
[a|A][n|N][d|D] { fprintf(yyout, "\n%d, KEYWORD, AND", lineNumber); return AND; }
[o|O][r|R] { fprintf(yyout, "\n%d, KEYWORD, OR", lineNumber); return OR; }
[n|N][o|O][t|T] { fprintf(yyout, "\n%d, KEYWORD, NOT", lineNumber); return NOT; }
[b|B][e|E][g|G][i|I][n|N] { fprintf(yyout, "\n%d, KEYWORD, BEGINK", lineNumber); return BEGINK; }
[e|E][n|N][d|D] { fprintf(yyout, "\n%d, KEYWORD, END", lineNumber); return END; }
[r|R][e|E][a|A][d|D] { fprintf(yyout, "\n%d, KEYWORD, READ", lineNumber); return READ;}
[w|W][r|R][i|I][t|T][e|E] { fprintf(yyout, "\n%d, KEYWORD, WRITE", lineNumber); return WRITE; }

[+] { fprintf(yyout, "\n%d, ARITHOP, PLUS", lineNumber); return PLUS; }
[-] { fprintf(yyout, "\n%d, ARITHOP, MINUS", lineNumber); return MINUS; }
[*] { fprintf(yyout, "\n%d, ARITHOP, MULTIPLY", lineNumber); return MULTIPLY; }
[/] { fprintf(yyout, "\n%d, ARITHOP, DIVIDE", lineNumber); return DIVIDE; }
[%] { fprintf(yyout, "\n%d, ARITHOP, MOD", lineNumber); return MOD; }

[=] { fprintf(yyout, "\n%d, RELOP, EQUAL", lineNumber); return EQUAL; }
\< { fprintf(yyout, "\n%d, RELOP, LESS", lineNumber); return LESS; }
\> { fprintf(yyout, "\n%d, RELOP, GREATER", lineNumber); return GREATER; }
\<\= { fprintf(yyout, "\n%d, RELOP, LESSEQUAL", lineNumber); return LESSEQUAL; }
\>\= { fprintf(yyout, "\n%d, RELOP, GREATEREQUAL", lineNumber); return GREATEREQUAL; }
\<\> { fprintf(yyout, "\n%d, RELOP, NOTEQUAL", lineNumber); return NOTEQUAL; }

[;] { fprintf(yyout, "\n%d, SYMBOL, SEMICOLON", lineNumber); return SEMICOLON; }
[,] { fprintf(yyout, "\n%d, SYMBOL, COMMA", lineNumber); return COMMA; }
[:] { fprintf(yyout, "\n%d, SYMBOL, COLON", lineNumber); return COLON; }
[.] { fprintf(yyout, "\n%d, SYMBOL, DOT", lineNumber); return DOT; }
[(] { fprintf(yyout, "\n%d, SYMBOL, LPAREN", lineNumber); return LPAREN; }
[)] { fprintf(yyout, "\n%d, SYMBOL, RPAREN", lineNumber); return RPAREN;}
[[] { fprintf(yyout, "\n%d, SYMBOL, LBRACKET", lineNumber); return LBRACKET; }
[]] { fprintf(yyout, "\n%d, SYMBOL, RBRACKET", lineNumber); return RBRACKET; }

[0-9]+ { fprintf(yyout, "\n%d, NUMBER, NUMBER", lineNumber); return NUMBER; }

[a-zA-Z][a-zA-Z0-9]* { fprintf(yyout, "\n%d, IDENTIFIER, IDENTIFIER", lineNumber); return IDENTIFIER; }

[\n] { lineNumber++; fprintf(yyout, "\n%d, OTHER, NL", lineNumber); }
[\t] {}
[ ] {}

\n { lineNumber++; fprintf(yyout, "\n%d, OTHER, NL", lineNumber); }
. {}

%%