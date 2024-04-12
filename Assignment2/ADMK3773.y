%{
#include <stdio.h>
%}
%token PROGRAM INT REAL BEGINK END NL BOOLEAN CHAR VAR ARRAY FOR WHILE DO NOT AND OR READ WRITE
%token PLUS MINUS MULTIPLY DIVIDE MOD 
%token EQUAL LESS GREATER LESSEQUAL GREATEREQUAL NOTEQUAL
%token NUMBER 
%token SEMICOLON COMMA COLON DOT LPAREN RPAREN LBRACKET RBRACKET

%%
stmt: PROGRAM NL
;
%%

void main()
{
    /* yyin = fopen("sample.txt", "r"); */
    yyparse();
}

void yyerror(){
    printf("Syntax error\n");
}