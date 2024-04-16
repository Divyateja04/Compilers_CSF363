%{
#include <stdio.h>
#include <stdlib.h>
extern FILE *yyin;
%}
%token PROGRAM INTEGER REAL BEGINK END NL BOOLEAN CHAR IF ELSE TO DOWNTO VAR ARRAY FOR WHILE DO NOT AND OR READ WRITE
%token PLUS MINUS MULTIPLY DIVIDE MOD 
%token EQUAL LESS GREATER LESSEQUAL GREATEREQUAL NOTEQUAL
%token NUMBER 
%token IDENTIFIER 
%token COMMENT_START COMMENT_END 
%token SEMICOLON COMMA COLON DOT LPAREN RPAREN LBRACKET RBRACKET STRING

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