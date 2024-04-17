%{
#include <stdio.h>
#include <stdlib.h>
int lineNumber = 1;
%}

%x READ_STRING_INPUT
%x COMMENT

%%
"//" { 
    BEGIN(COMMENT);
    fprintf(yyout, "\n%d | %s | COMMENT_START", lineNumber, yytext);
}
<COMMENT>[^\n^\"]* { fprintf(yyout, "\n%d | %s | COMMENT_STRING", lineNumber, yytext); }
<COMMENT>[\n] { lineNumber++; BEGIN(INITIAL); }

[p|P][r|R][o|O][g|G][r|R][a|A][m|M] { fprintf(yyout, "\n%d | %s | PROGRAM", lineNumber, yytext); }
[i|I][n|N][t|T][e|E][g|G][e|E][r|R] { fprintf(yyout, "\n%d | %s | INTEGER", lineNumber, yytext); }
[r|R][e|E][a|A][l|L] { fprintf(yyout, "\n%d | %s | REAL", lineNumber, yytext); }
[b|B][o|O][o|O][l|L][e|E][a|A][n|N] { fprintf(yyout, "\n%d | %s | BOOLEAN", lineNumber, yytext); }
[c|C][h|H][a|A][r|R] { fprintf(yyout, "\n%d | %s | CHAR", lineNumber, yytext); }
[v|V][a|A][r|R] { fprintf(yyout, "\n%d | %s | VAR", lineNumber, yytext); }
[f|F][o|O][r|R] { fprintf(yyout, "\n%d | %s | FOR", lineNumber, yytext); }
[t|T][o|O] { fprintf(yyout, "\n%d | %s | TO", lineNumber, yytext); }
[d|D][o|O][w|W][n|N][t|T][o|O] { fprintf(yyout, "\n%d | %s | DOWNTO", lineNumber, yytext); }
[i|I][f|F] { fprintf(yyout, "\n%d | %s | IF", lineNumber, yytext); }
[e|E][l|L][s|S][e|E] { fprintf(yyout, "\n%d | %s | ELSE", lineNumber, yytext); }
[d|D][o|O] { fprintf(yyout, "\n%d | %s | DO", lineNumber, yytext);}
[w|W][h|H][i|I][l|L][e|E] { fprintf(yyout, "\n%d | %s | WHILE", lineNumber, yytext); }
[a|A][r|R][r|R][a|A][y|Y] { fprintf(yyout, "\n%d | %s | ARRAY", lineNumber, yytext); }
[a|A][n|N][d|D] { fprintf(yyout, "\n%d | %s | AND", lineNumber, yytext); }
[o|O][r|R] { fprintf(yyout, "\n%d | %s | OR", lineNumber, yytext);}
[n|N][o|O][t|T] { fprintf(yyout, "\n%d | %s | NOT", lineNumber, yytext); }
[b|B][e|E][g|G][i|I][n|N] { fprintf(yyout, "\n%d | %s | BEGINK", lineNumber, yytext); }
[e|E][n|N][d|D] { fprintf(yyout, "\n%d | %s | END", lineNumber, yytext); }
[r|R][e|E][a|A][d|D] { fprintf(yyout, "\n%d | %s | READ", lineNumber, yytext); }
[w|W][r|R][i|I][t|T][e|E] { fprintf(yyout, "\n%d | %s | WRITE", lineNumber, yytext); }

[+] { fprintf(yyout, "\n%d | %s | PLUS", lineNumber, yytext); }
[-] { fprintf(yyout, "\n%d | %s | MINUS", lineNumber, yytext); }
[*] { fprintf(yyout, "\n%d | %s | MULTIPLY", lineNumber, yytext); }
[/] { fprintf(yyout, "\n%d | %s | DIVIDE", lineNumber, yytext); }
[%] { fprintf(yyout, "\n%d | %s | MOD", lineNumber, yytext); }

[=] { fprintf(yyout, "\n%d | %s | EQUAL", lineNumber, yytext); }
\< { fprintf(yyout, "\n%d | %s | LESS", lineNumber, yytext); }
\> { fprintf(yyout, "\n%d | %s | GREATER", lineNumber, yytext); }
\<\= { fprintf(yyout, "\n%d | %s | LESSEQUAL", lineNumber, yytext); }
\>\= { fprintf(yyout, "\n%d | %s | GREATEREQUAL", lineNumber, yytext); }
\<\> { fprintf(yyout, "\n%d | %s | NOTEQUAL", lineNumber, yytext); }

[;] { fprintf(yyout, "\n%d | %s | SEMICOLON", lineNumber, yytext); }
[,] { fprintf(yyout, "\n%d | %s | COMMA", lineNumber, yytext); }
[:] { fprintf(yyout, "\n%d | %s | COLON", lineNumber, yytext); }
[.] { fprintf(yyout, "\n%d | %s | DOT", lineNumber, yytext); }
[(] { fprintf(yyout, "\n%d | %s | LPAREN", lineNumber, yytext); }
[)] { fprintf(yyout, "\n%d | %s | RPAREN", lineNumber, yytext); }
[[] { fprintf(yyout, "\n%d | %s | LBRACKET", lineNumber, yytext); }
[]] { fprintf(yyout, "\n%d | %s | RBRACKET", lineNumber, yytext); }

[\"] { BEGIN(READ_STRING_INPUT); fprintf(yyout, "\n%d | %s | DQUOTE", lineNumber, yytext); }
<READ_STRING_INPUT>[^\n^\"]* { fprintf(yyout, "\n%d | %s | STRING", lineNumber, yytext); }
<READ_STRING_INPUT>[\"] { fprintf(yyout, "\n%d | %s | DQUOTE", lineNumber, yytext); BEGIN(INITIAL); }

[0-9]+ { fprintf(yyout, "\n%d | %s | NUMBER", lineNumber, yytext); }

[a-zA-Z][a-zA-Z0-9]* { fprintf(yyout, "\n%d | %s | IDENTIFIER", lineNumber, yytext); }

[\n] { fprintf(yyout, "\n%d | OTHER | NL", lineNumber); lineNumber++; }
[\t] {}
[ ] {}

. {}

%%

void main(){
    yyin = fopen("sample.txt", "r");
    yyout = fopen("output.txt", "w");
    yylex();
}