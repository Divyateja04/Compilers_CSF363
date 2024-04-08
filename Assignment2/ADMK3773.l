%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
extern int yylval;
int lineNumber = 1;
%}

%%
[p|P][r|R][o|O][g|G][r|R][a|A][m|M] { printf("\n%d, KEYWORD, PROGRAM", lineNumber); }
[i|I][n|N][t|T] { printf("\n%d, KEYWORD, INT", lineNumber); }
[r|R][e|E][a|A][l|L] { printf("\n%d, KEYWORD, REAL", lineNumber); }
[b|B][o|O][o|O][l|L][e|E][a|A][n|N] { printf("\n%d, KEYWORD, BOOLEAN", lineNumber); }
[c|C][h|H][a|A][r|R] { printf("\n%d, KEYWORD, CHAR", lineNumber); }
[v|V][a|A][r|R] { printf("\n%d, KEYWORD, VAR", lineNumber); }
[f|F][o|O][r|R] { printf("\n%d, KEYWORD, FOR", lineNumber); }
[d|D][o|O] { printf("\n%d, KEYWORD, DO", lineNumber); }
[w|W][h|H][i|I][l|L][e|E] { printf("\n%d, KEYWORD, WHILE", lineNumber); }
[a|A][r|R][r|R][a|A][y|Y] { printf("\n%d, KEYWORD, ARRAY", lineNumber); }
[a|A][n|N][d|D] { printf("\n%d, KEYWORD, AND", lineNumber); }
[o|O][r|R] { printf("\n%d, KEYWORD, OR", lineNumber); }
[n|N][o|O][t|T] { printf("\n%d, KEYWORD, NOT", lineNumber); }
[b|B][e|E][g|G][i|I][n|N] { printf("\n%d, KEYWORD, BEGINK", lineNumber); }
[e|E][n|N][d|D] { printf("\n%d, KEYWORD, END", lineNumber); }
[r|R][e|E][a|A][d|D] { printf("\n%d, KEYWORD, READ", lineNumber); }
[w|W][r|R][i|I][t|T][e|E] { printf("\n%d, KEYWORD, WRITE", lineNumber); }

[+] { printf("\n%d, ARITHOP, PLUS", lineNumber); }
[-] { printf("\n%d, ARITHOP, MINUS", lineNumber); }
[*] { printf("\n%d, ARITHOP, MULTIPLY", lineNumber); }
[/] { printf("\n%d, ARITHOP, DIVIDE", lineNumber); }
[%] { printf("\n%d, ARITHOP, MOD", lineNumber); }

[=] { printf("\n%d, RELOP, EQUAL", lineNumber); }
\< { printf("\n%d, RELOP, LESS", lineNumber); }
\> { printf("\n%d, RELOP, GREATER", lineNumber); }
\<\= { printf("\n%d, RELOP, LESSEQUAL", lineNumber); }
\>\= { printf("\n%d, RELOP, GREATEREQUAL", lineNumber); }
\<\> { printf("\n%d, RELOP, NOTEQUAL", lineNumber); }

[;] { printf("\n%d, SYMBOL, SEMICOLON", lineNumber); }
[,] { printf("\n%d, SYMBOL, COMMA", lineNumber); }
[:] { printf("\n%d, SYMBOL, COLON", lineNumber); }
[.] { printf("\n%d, SYMBOL, DOT", lineNumber); }
[(] { printf("\n%d, SYMBOL, LPAREN", lineNumber); }
[)] { printf("\n%d, SYMBOL, RPAREN", lineNumber); }
[[] { printf("\n%d, SYMBOL, LBRACKET", lineNumber); }
[]] { printf("\n%d, SYMBOL, RBRACKET", lineNumber); }

[0-9]+ { printf("\n%d, NUMBER, NUMBER", lineNumber); }

\n { lineNumber++; printf("\n%d, OTHER, NL", lineNumber); }
. {}
%%

void main(){
    yyin = fopen("sample.txt", "r");
    yylex();
}