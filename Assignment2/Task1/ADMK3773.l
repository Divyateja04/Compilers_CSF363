%{
#include <stdio.h>
#include <stdlib.h>
int lineNumber = 1;
%}

%%
[p|P][r|R][o|O][g|G][r|R][a|A][m|M] { fprintf(yyout, "\n%d, KEYWORD, PROGRAM", lineNumber); }
[i|I][n|N][t|T][e|E][g|G][e|E][r|R] { fprintf(yyout, "\n%d, KEYWORD, INTEGER", lineNumber); }
[r|R][e|E][a|A][l|L] { fprintf(yyout, "\n%d, KEYWORD, REAL", lineNumber); }
[b|B][o|O][o|O][l|L][e|E][a|A][n|N] { fprintf(yyout, "\n%d, KEYWORD, BOOLEAN", lineNumber); }
[c|C][h|H][a|A][r|R] { fprintf(yyout, "\n%d, KEYWORD, CHAR", lineNumber); }
[v|V][a|A][r|R] { fprintf(yyout, "\n%d, KEYWORD, VAR", lineNumber); }
[f|F][o|O][r|R] { fprintf(yyout, "\n%d, KEYWORD, FOR", lineNumber); }
[t|T][o|O] { fprintf(yyout, "\n%d, KEYWORD, TO", lineNumber); }
[d|D][o|O][w|W][n|N][t|T][o|O] { fprintf(yyout, "\n%d, KEYWORD, DOWNTO", lineNumber); }
[i|I][f|F] { fprintf(yyout, "\n%d, KEYWORD, IF", lineNumber); }
[e|E][l|L][s|S][e|E] { fprintf(yyout, "\n%d, KEYWORD, ELSE", lineNumber); }
[d|D][o|O] { fprintf(yyout, "\n%d, KEYWORD, DO", lineNumber);}
[w|W][h|H][i|I][l|L][e|E] { fprintf(yyout, "\n%d, KEYWORD, WHILE", lineNumber); }
[a|A][r|R][r|R][a|A][y|Y] { fprintf(yyout, "\n%d, KEYWORD, ARRAY", lineNumber); }
[a|A][n|N][d|D] { fprintf(yyout, "\n%d, KEYWORD, AND", lineNumber); }
[o|O][r|R] { fprintf(yyout, "\n%d, KEYWORD, OR", lineNumber);}
[n|N][o|O][t|T] { fprintf(yyout, "\n%d, KEYWORD, NOT", lineNumber); }
[b|B][e|E][g|G][i|I][n|N] { fprintf(yyout, "\n%d, KEYWORD, BEGINK", lineNumber); }
[e|E][n|N][d|D] { fprintf(yyout, "\n%d, KEYWORD, END", lineNumber); }
[r|R][e|E][a|A][d|D] { fprintf(yyout, "\n%d, KEYWORD, READ", lineNumber); }
[w|W][r|R][i|I][t|T][e|E] { fprintf(yyout, "\n%d, KEYWORD, WRITE", lineNumber); }

[+] { fprintf(yyout, "\n%d, ARITHOP, PLUS", lineNumber); }
[-] { fprintf(yyout, "\n%d, ARITHOP, MINUS", lineNumber); }
[*] { fprintf(yyout, "\n%d, ARITHOP, MULTIPLY", lineNumber); }
[/] { fprintf(yyout, "\n%d, ARITHOP, DIVIDE", lineNumber); }
[%] { fprintf(yyout, "\n%d, ARITHOP, MOD", lineNumber); }

[=] { fprintf(yyout, "\n%d, RELOP, EQUAL", lineNumber); }
\< { fprintf(yyout, "\n%d, RELOP, LESS", lineNumber); }
\> { fprintf(yyout, "\n%d, RELOP, GREATER", lineNumber); }
\<\= { fprintf(yyout, "\n%d, RELOP, LESSEQUAL", lineNumber); }
\>\= { fprintf(yyout, "\n%d, RELOP, GREATEREQUAL", lineNumber); }
\<\> { fprintf(yyout, "\n%d, RELOP, NOTEQUAL", lineNumber); }

[;] { fprintf(yyout, "\n%d, SYMBOL, SEMICOLON", lineNumber); }
[,] { fprintf(yyout, "\n%d, SYMBOL, COMMA", lineNumber); }
[:] { fprintf(yyout, "\n%d, SYMBOL, COLON", lineNumber); }
[.] { fprintf(yyout, "\n%d, SYMBOL, DOT", lineNumber); }
[(] { fprintf(yyout, "\n%d, SYMBOL, LPAREN", lineNumber); }
[)] { fprintf(yyout, "\n%d, SYMBOL, RPAREN", lineNumber); }
[[] { fprintf(yyout, "\n%d, SYMBOL, LBRACKET", lineNumber); }
[]] { fprintf(yyout, "\n%d, SYMBOL, RBRACKET", lineNumber); }
[\'] { fprintf(yyout, "\n%d, SYMBOL, QUOTE", lineNumber); }
[\"] { fprintf(yyout, "\n%d, SYMBOL, DQUOTE", lineNumber); }

[0-9]+ { fprintf(yyout, "\n%d, NUMBER, NUMBER", lineNumber); }

[a-zA-Z][a-zA-Z0-9]* { fprintf(yyout, "\n%d, IDENTIFIER, IDENTIFIER", lineNumber); }

[\n] { fprintf(yyout, "\n%d, OTHER, NL", lineNumber); lineNumber++;  }
[\t] {}
[ ] {}

. {}

%%

void main(){
    yyin = fopen("sample.txt", "r");
    yyout = fopen("output.txt", "w");
    yylex();
}