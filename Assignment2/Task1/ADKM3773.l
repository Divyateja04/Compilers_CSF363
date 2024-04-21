%{
#include <stdio.h>
#include <stdlib.h>
int lineNumber = 1;
%}

%x READ_DQ_STRING_INPUT
%x READ_SQ_STRING_INPUT
%x COMMENT

%%
"//" { 
    BEGIN(COMMENT);
    fprintf(yyout, "\n%d | %s | COMMENT_START", lineNumber, yytext);
}
<COMMENT>[^\n^\"]* { fprintf(yyout, "\n%d | %s | COMMENT_STRING", lineNumber, yytext); }
<COMMENT>[\n] { lineNumber++; BEGIN(INITIAL); }

[p|P][r|R][o|O][g|G][r|R][a|A][m|M] { fprintf(yyout, "\n%d | %s | KEYWORD_PROGRAM", lineNumber, yytext); }
[i|I][n|N][t|T][e|E][g|G][e|E][r|R] { fprintf(yyout, "\n%d | %s | KEYWORD_INTEGER", lineNumber, yytext); }
[r|R][e|E][a|A][l|L] { fprintf(yyout, "\n%d | %s | KEYWORD_REAL", lineNumber, yytext); }
[b|B][o|O][o|O][l|L][e|E][a|A][n|N] { fprintf(yyout, "\n%d | %s | KEYWORD_BOOLEAN", lineNumber, yytext); }
[c|C][h|H][a|A][r|R] { fprintf(yyout, "\n%d | %s | KEYWORD_CHAR", lineNumber, yytext); }
[v|V][a|A][r|R] { fprintf(yyout, "\n%d | %s | KEYWORD_VAR", lineNumber, yytext); }
[f|F][o|O][r|R] { fprintf(yyout, "\n%d | %s | KEYWORD_FOR", lineNumber, yytext); }
[t|T][o|O] { fprintf(yyout, "\n%d | %s | KEYWORD_TO", lineNumber, yytext); }
[d|D][o|O][w|W][n|N][t|T][o|O] { fprintf(yyout, "\n%d | %s | KEYWORD_DOWNTO", lineNumber, yytext); }
[i|I][f|F] { fprintf(yyout, "\n%d | %s | KEYWORD_IF", lineNumber, yytext); }
[e|E][l|L][s|S][e|E] { fprintf(yyout, "\n%d | %s | KEYWORD_ELSE", lineNumber, yytext); }
[d|D][o|O] { fprintf(yyout, "\n%d | %s | KEYWORD_DO", lineNumber, yytext);}
[w|W][h|H][i|I][l|L][e|E] { fprintf(yyout, "\n%d | %s | KEYWORD_WHILE", lineNumber, yytext); }
[a|A][r|R][r|R][a|A][y|Y] { fprintf(yyout, "\n%d | %s | KEYWORD_ARRAY", lineNumber, yytext); }
[a|A][n|N][d|D] { fprintf(yyout, "\n%d | %s | KEYWORD_AND", lineNumber, yytext); }
[o|O][r|R] { fprintf(yyout, "\n%d | %s | KEYWORD_OR", lineNumber, yytext);}
[n|N][o|O][t|T] { fprintf(yyout, "\n%d | %s | KEYWORD_NOT", lineNumber, yytext); }
[b|B][e|E][g|G][i|I][n|N] { fprintf(yyout, "\n%d | %s | KEYWORD_BEGINK", lineNumber, yytext); }
[e|E][n|N][d|D] { fprintf(yyout, "\n%d | %s | KEYWORD_END", lineNumber, yytext); }
[r|R][e|E][a|A][d|D] { fprintf(yyout, "\n%d | %s | KEYWORD_READ", lineNumber, yytext); }
[w|W][r|R][i|I][t|T][e|E] { fprintf(yyout, "\n%d | %s | KEYWORD_WRITE", lineNumber, yytext); }
[t|T][h|H][e|E][n|N] { fprintf(yyout, "\n%d | %s | KEYWORD_THEN", lineNumber, yytext); }

[+] { fprintf(yyout, "\n%d | %s | AROP_PLUS", lineNumber, yytext); }
[-] { fprintf(yyout, "\n%d | %s | AROP_MINUS", lineNumber, yytext); }
[*] { fprintf(yyout, "\n%d | %s | AROP_MULTIPLY", lineNumber, yytext); }
[/] { fprintf(yyout, "\n%d | %s | AROP_DIVIDE", lineNumber, yytext); }
[%] { fprintf(yyout, "\n%d | %s | AROP_MOD", lineNumber, yytext); }

[=] { fprintf(yyout, "\n%d | %s | RELOP_EQUAL", lineNumber, yytext); }
\< { fprintf(yyout, "\n%d | %s | RELOP_LESS", lineNumber, yytext); }
\> { fprintf(yyout, "\n%d | %s | RELOP_GREATER", lineNumber, yytext); }
\<\= { fprintf(yyout, "\n%d | %s | RELOP_LESSEQUAL", lineNumber, yytext); }
\>\= { fprintf(yyout, "\n%d | %s | RELOP_GREATEREQUAL", lineNumber, yytext); }
\<\> { fprintf(yyout, "\n%d | %s | RELOP_NOTEQUAL", lineNumber, yytext); }

[;] { fprintf(yyout, "\n%d | %s | SYMBOL_SEMICOLON", lineNumber, yytext); }
[,] { fprintf(yyout, "\n%d | %s | SYMBOL_COMMA", lineNumber, yytext); }
[:] { fprintf(yyout, "\n%d | %s | SYMBOL_COLON", lineNumber, yytext); }
[.] { fprintf(yyout, "\n%d | %s | SYMBOL_DOT", lineNumber, yytext); }
[(] { fprintf(yyout, "\n%d | %s | SYMBOL_LPAREN", lineNumber, yytext); }
[)] { fprintf(yyout, "\n%d | %s | SYMBOL_RPAREN", lineNumber, yytext); }
[[] { fprintf(yyout, "\n%d | %s | SYMBOL_LBRACKET", lineNumber, yytext); }
[]] { fprintf(yyout, "\n%d | %s | SYMBOL_RBRACKET", lineNumber, yytext); }

[\"] { BEGIN(READ_DQ_STRING_INPUT); fprintf(yyout, "\n%d | %s | SYMBOL_DQUOTE", lineNumber, yytext); }
<READ_DQ_STRING_INPUT>[^\n^\"]* { fprintf(yyout, "\n%d | %s | STRING", lineNumber, yytext); }
<READ_DQ_STRING_INPUT>[\"] { fprintf(yyout, "\n%d | %s | SYMBOL_DQUOTE", lineNumber, yytext); BEGIN(INITIAL); }

[\'] { BEGIN(READ_SQ_STRING_INPUT); fprintf(yyout, "\n%d | %s | SYMBOL_SQUOTE", lineNumber, yytext); }
<READ_SQ_STRING_INPUT>[^\n^\']* { fprintf(yyout, "\n%d | %s | STRING", lineNumber, yytext); }
<READ_SQ_STRING_INPUT>[\'] { fprintf(yyout, "\n%d | %s | SYMBOL_SQUOTE", lineNumber, yytext); BEGIN(INITIAL); }

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