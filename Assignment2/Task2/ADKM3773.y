%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
int yyerror();
extern FILE *yyin;

int printLogs = 1;
int yydebug = 1;
%}

%token PROGRAM INTEGER REAL BEGINK END BOOLEAN CHAR IF ELSE TO DOWNTO VAR ARRAY FOR WHILE DO NOT AND OR READ WRITE ARRAY_DOT
%token PLUS MINUS MULTIPLY DIVIDE MOD 
%token EQUAL LESS GREATER LESSEQUAL GREATEREQUAL NOTEQUAL
%token INT_NUMBER DECIMAL_NUMBER
%token IDENTIFIER
%token SEMICOLON COMMA COLON DOT LPAREN RPAREN LBRACKET RBRACKET STRING THEN OF

%left PLUS MINUS 
%left MULTIPLY DIVIDE MOD
%left AND OR
%left NOT
%left EQUAL 
%left LESS GREATER LESSEQUAL GREATEREQUAL NOTEQUAL
%left IDENTIFIER LPAREN RPAREN
%%
stmt: { if(printLogs) printf("Parsing started"); } PROGRAM_DECLARATION VARIABLE_DECLARATION BODY_OF_PROGRAM { printf("\n\nParsing completed successfully"); }
;

/* TYPE DECLARATIONS */
DATATYPE:  { if(printLogs) printf("DATATYPE found - INTEGER"); } INTEGER 
| { if(printLogs) printf("DATATYPE found - REAL"); } REAL 
| { if(printLogs) printf("DATATYPE found - BOOLEAN"); } BOOLEAN 
| { if(printLogs) printf("DATATYPE found - CHAR"); } CHAR 
;

RELOP: EQUAL
| NOTEQUAL
| LESS
| LESSEQUAL
| GREATER
| GREATEREQUAL
;

/* ARRAY ADD ON FOR EVERY ID */
ARRAY_ADD_ON_ID: { if(printLogs) printf("ARRAY_ADD_ON_ID found"); } LBRACKET BETWEEN_BRACKETS RBRACKET { if(printLogs) printf("ARRAY_ADD_ON_ID closed"); } 
;

BETWEEN_BRACKETS: { if(printLogs) printf("BETWEEN_BRACKETS found - INT_NUMBER"); } INT_NUMBER
| { if(printLogs) printf("BETWEEN_BRACKETS found - IDENTIFIER"); } IDENTIFIER

/* HEAD OF THE PROGRAM - PARSING */
PROGRAM_DECLARATION: PROGRAM IDENTIFIER SEMICOLON
;

VARIABLE_DECLARATION: VAR DECLARATION_LISTS
| VAR
;

DECLARATION_LISTS: DECLARATION_LIST DECLARATION_LISTS
| DECLARATION_LIST
;

DECLARATION_LIST: SINGLE_VARIABLE
| MULTIPLE_VARIABLE
| ARRAY_DECLARATION
;

SINGLE_VARIABLE: IDENTIFIER COLON DATATYPE SEMICOLON
;

MULTIPLE_VARIABLE: IDENTIFIER MORE_IDENTIFIERS COLON DATATYPE SEMICOLON
;

MORE_IDENTIFIERS: COMMA IDENTIFIER MORE_IDENTIFIERS 
| COMMA IDENTIFIER
;

ARRAY_DECLARATION: IDENTIFIER COLON ARRAY LBRACKET INT_NUMBER ARRAY_DOT INT_NUMBER RBRACKET OF DATATYPE SEMICOLON
; 

/* MAIN BODY OF THE PROGRAM */
BODY_OF_PROGRAM: BEGINK STATEMENTS END DOT
| BEGINK END DOT
;

STATEMENTS: STATEMENT STATEMENTS
| STATEMENT
;

STATEMENT: { if(printLogs) printf("STATEMENTLIST found - READ"); } READ_STATEMENT 
| { if(printLogs) printf("STATEMENTLIST found - WRITE"); } WRITE_STATEMENT 
| { if(printLogs) printf("STATEMENTLIST found - ASSIGNMENT"); } ASSIGNMENT_STATEMENT 
| { if(printLogs) printf("STATEMENTLIST found - CONDITIONAL"); } CONDITIONAL_STATEMENT 
| { if(printLogs) printf("STATEMENTLIST found - LOOPING"); } LOOPING_STATEMENT
;

READ_STATEMENT: READ LPAREN IDENTIFIER RPAREN SEMICOLON
| READ LPAREN IDENTIFIER ARRAY_ADD_ON_ID RPAREN SEMICOLON
;

WRITE_STATEMENT:WRITE LPAREN WRITE_IDENTIFIER_LIST RPAREN SEMICOLON
;

WRITE_IDENTIFIER_LIST: IDENTIFIER
| IDENTIFIER WRITE_MORE_IDENTIFIERS
| IDENTIFIER ARRAY_ADD_ON_ID
| IDENTIFIER ARRAY_ADD_ON_ID WRITE_MORE_IDENTIFIERS
| STRING
| STRING WRITE_MORE_IDENTIFIERS
| INT_NUMBER
| INT_NUMBER WRITE_MORE_IDENTIFIERS
| DECIMAL_NUMBER
| DECIMAL_NUMBER WRITE_MORE_IDENTIFIERS
;

WRITE_MORE_IDENTIFIERS: COMMA IDENTIFIER
| COMMA IDENTIFIER WRITE_MORE_IDENTIFIERS
| COMMA IDENTIFIER ARRAY_ADD_ON_ID
| COMMA IDENTIFIER ARRAY_ADD_ON_ID WRITE_MORE_IDENTIFIERS 
| COMMA STRING
| COMMA STRING WRITE_MORE_IDENTIFIERS
| COMMA INT_NUMBER
| COMMA INT_NUMBER WRITE_MORE_IDENTIFIERS
| COMMA DECIMAL_NUMBER
| COMMA DECIMAL_NUMBER WRITE_MORE_IDENTIFIERS
;

/* ASSIGNMENT */
ASSIGNMENT_STATEMENT: IDENTIFIER COLON EQUAL EXPRESSION_SEQUENCE SEMICOLON
| IDENTIFIER ARRAY_ADD_ON_ID COLON EQUAL EXPRESSION_SEQUENCE SEMICOLON
;

/* CONDITIONAL STATEMENT */
CONDITIONAL_STATEMENT: IF CONDITION THEN BODY_OF_CONDITIONAL ELSE BODY_OF_CONDITIONAL SEMICOLON
| IF CONDITION THEN BODY_OF_CONDITIONAL SEMICOLON
;

BODY_OF_CONDITIONAL: BEGINK STATEMENTS_INSIDE_CONDITIONAL END
| BEGINK END /* empty body */
;

STATEMENTS_INSIDE_CONDITIONAL: STATEMENT_INSIDE_CONDITIONAL STATEMENTS_INSIDE_CONDITIONAL
| STATEMENT_INSIDE_CONDITIONAL
;

CONDITION: IDENTIFIER { if(printLogs) printf("Condition - Took ID"); }
| IDENTIFIER ARRAY_ADD_ON_ID { if(printLogs) printf("Condition - Took Array"); }
| EXPRESSION_SEQUENCE RELOP EXPRESSION_SEQUENCE { if(printLogs) printf("Condition - Expr"); }
| NOT CONDITION /* NOT a */ { if(printLogs) printf("Condition - NOT"); }
| CONDITION AND CONDITION /* a AND b */ { if(printLogs) printf("Condition - AND"); }
| CONDITION OR CONDITION /* a OR b */ { if(printLogs) printf("Condition - OR"); }
/* | LPAREN CONDITION RPAREN { if(printLogs) printf("Condition - Closing Paren"); } */
; 

/* EXPRESSION SEQUENCE USING FACTOR METHOD FROM CLASS */
EXPRESSION_SEQUENCE: TERM
| EXPRESSION_SEQUENCE PLUS EXPRESSION_SEQUENCE
| EXPRESSION_SEQUENCE MINUS EXPRESSION_SEQUENCE
| EXPRESSION_SEQUENCE MULTIPLY EXPRESSION_SEQUENCE
| EXPRESSION_SEQUENCE DIVIDE EXPRESSION_SEQUENCE
| EXPRESSION_SEQUENCE MOD EXPRESSION_SEQUENCE
| LPAREN EXPRESSION_SEQUENCE RPAREN
;

TERM: 
| IDENTIFIER
| IDENTIFIER ARRAY_ADD_ON_ID
| INT_NUMBER
| DECIMAL_NUMBER
;

STATEMENT_INSIDE_CONDITIONAL: READ_STATEMENT
| WRITE_STATEMENT
| ASSIGNMENT_STATEMENT
| LOOPING_STATEMENT
;

/* LOOPING STATEMENT */
LOOPING_STATEMENT: WHILE_LOOP
| FOR_LOOP_TO
| FOR_LOOP_DOWNTO
;

WHILE_LOOP: WHILE CONDITION DO BODY_OF_LOOP SEMICOLON
;

FOR_LOOP_TO: FOR IDENTIFIER COLON EQUAL EXPRESSION_SEQUENCE TO EXPRESSION_SEQUENCE DO BODY_OF_LOOP SEMICOLON
;

FOR_LOOP_DOWNTO: FOR IDENTIFIER COLON EQUAL EXPRESSION_SEQUENCE DOWNTO EXPRESSION_SEQUENCE DO BODY_OF_LOOP SEMICOLON
;

BODY_OF_LOOP: BEGINK STATEMENTS_INSIDE_LOOP END
;

STATEMENTS_INSIDE_LOOP: STATEMENT_INSIDE_LOOP STATEMENTS_INSIDE_LOOP
| STATEMENT_INSIDE_LOOP
;

STATEMENT_INSIDE_LOOP: READ_STATEMENT
| WRITE_STATEMENT
| ASSIGNMENT_STATEMENT
| CONDITIONAL_STATEMENT
;


%%

void main()
{
    yyin = fopen("sample.txt", "r");
    if(yyin == NULL){
        if(printLogs) printf("File not found");
        exit(1);
    }
    else{
        if(printLogs) printf("Input file found, Parsing....");
        yyparse();
    }
}

int yyerror(){
    printf("\n\nSyntax error found");
    return 0;
}