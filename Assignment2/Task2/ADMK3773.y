%{
#include <stdio.h>
#include <stdlib.h>
extern FILE *yyin;
%}
%token PROGRAM INT REAL BEGINK END NL BOOLEAN CHAR VAR ARRAY FOR WHILE DO NOT AND OR READ WRITE
%token PLUS MINUS MULTIPLY DIVIDE MOD 
%token EQUAL LESS GREATER LESSEQUAL GREATEREQUAL NOTEQUAL
%token NUMBER 
%token IDENTIFIER 
%token SEMICOLON COMMA COLON DOT LPAREN RPAREN LBRACKET RBRACKET DOUBLEQUOTES

%%
stmt: PROGRAM NL
;
%%

void main()
{
    yyin = fopen("sample.txt", "r");
    if(yyin == NULL){
        printf("File not found\n");
        exit(1);
    }
    else{
        printf("File found\n");
        yyparse();
    }
}

void yyerror(){
    printf("\n\nSyntax error\n");
}