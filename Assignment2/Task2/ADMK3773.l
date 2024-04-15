%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
extern int yylval;
int lineNumber = 1;
%}

%%
[p|P][r|R][o|O][g|G][r|R][a|A][m|M] { return PROGRAM; }
[i|I][n|N][t|T][e|E][g|G][e|E][r|R] { return INTEGER; }
[r|R][e|E][a|A][l|L] { return REAL; }
[b|B][o|O][o|O][l|L][e|E][a|A][n|N] { return BOOLEAN; }
[c|C][h|H][a|A][r|R] { return CHAR; }
[v|V][a|A][r|R] { return VAR; }
[f|F][o|O][r|R] { return FOR; }
[t|T][o|O] { return TO; }
[d|D][o|O][w|W][n|N][t|T][o|O] { return DOWNTO; }
[i|I][f|F] { return IF; }
[e|E][l|L][s|S][e|E] { return ELSE; }
[d|D][o|O] { return DO; }
[w|W][h|H][i|I][l|L][e|E] { return WHILE; }
[a|A][r|R][r|R][a|A][y|Y] { return ARRAY; }
[a|A][n|N][d|D] { return AND; }
[o|O][r|R] { return OR; }
[n|N][o|O][t|T] { return NOT; }
[b|B][e|E][g|G][i|I][n|N] { return BEGINK; }
[e|E][n|N][d|D] { return END; }
[r|R][e|E][a|A][d|D] { return READ;}
[w|W][r|R][i|I][t|T][e|E] { return WRITE; }

[+] { return PLUS; }
[-] { return MINUS; }
[*] { return MULTIPLY; }
[/] { return DIVIDE; }
[%] { return MOD; }

[=] { return EQUAL; }
\< { return LESS; }
\> { return GREATER; }
\<\= { return LESSEQUAL; }
\>\= { return GREATEREQUAL; }
\<\> { return NOTEQUAL; }

[;] { return SEMICOLON; }
[,] { return COMMA; }
[:] { return COLON; }
[.] { return DOT; }
[(] { return LPAREN; }
[)] { return RPAREN;}
[[] { return LBRACKET; }
[]] { return RBRACKET; }

[0-9]+ { return NUMBER; }

[a-zA-Z][a-zA-Z0-9]* {  return IDENTIFIER; }

[\n] { return NL; }
[\t] {}
[ ] {}

. {}

%%