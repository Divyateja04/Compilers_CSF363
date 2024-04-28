%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int yyerror();
extern FILE *yyin;

int printLogs = 0;
int yydebug = 1;

int count=0;
int qind=0;
int tos=-1;
int temp_char=0;

struct quadruple{
    char operator[5];
    char operand1[100];
    char operand2[100];
    char result[100];
} quad[25];

struct stack {
    char c[100]; 
} stac[25];

void addQuadruple(char op1[], char op[], char op2[], char result[])
{
    strcpy(quad[qind].operator, op);
    strcpy(quad[qind].operand1, op1);
    strcpy(quad[qind].operand2, op2);
    strcpy(quad[qind].result, result);
    qind++;
}

void displayQuadruple()
{
    printf("%s ", quad[qind-1].result);
    printf("=");
    printf("%s ", quad[qind-1].operand1);
    printf("%s ", quad[qind-1].operator);
    printf("%s\n", quad[qind-1].operand2);
}

void pushToStack(char *c){
    strcpy(stac[++tos].c, c);
}

char* popFromStack()
{
    char* c = stac[tos].c;
    tos=tos-1;
    return c;
}
%}
%union {
    char data[100];
}

%token NL
%token PROGRAM INTEGER REAL BEGINK END BOOLEAN CHAR IF ELSE TO DOWNTO VAR ARRAY FOR WHILE DO NOT AND OR READ WRITE WRITE_LN ARRAY_DOT
%token PLUS MINUS MULTIPLY DIVIDE MOD 
%token EQUAL LESS GREATER LESSEQUAL GREATEREQUAL NOTEQUAL
%token INT_NUMBER DECIMAL_NUMBER
%token IDENTIFIER
%token SEMICOLON COMMA COLON DOT LPAREN RPAREN LBRACKET RBRACKET STRING THEN OF INVALID_TOKEN CHARACTER

%left PLUS MINUS 
%left MULTIPLY DIVIDE MOD
%left AND OR
%left NOT
%left EQUAL 
%left LESS GREATER LESSEQUAL GREATEREQUAL NOTEQUAL
%left LPAREN RPAREN
%%
stmt: { if(printLogs) printf("\nParsing started"); } PROGRAM_DECLARATION VARIABLE_DECLARATION BODY_OF_PROGRAM { printf("\n\n\nParsing completed successfully"); }
;

/* TYPE DECLARATIONS */
DATATYPE:  { if(printLogs) printf("\nDATATYPE found - INTEGER"); } INTEGER 
| { if(printLogs) printf("\nDATATYPE found - REAL"); } REAL 
| { if(printLogs) printf("\nDATATYPE found - BOOLEAN"); } BOOLEAN 
| { if(printLogs) printf("\nDATATYPE found - CHAR"); } CHAR 
;

RELOP: EQUAL
| NOTEQUAL
| LESS
| LESSEQUAL
| GREATER
| GREATEREQUAL
;

/* ARRAY ADD ON FOR EVERY ID */
ARRAY_ADD_ON_ID: LBRACKET BETWEEN_BRACKETS RBRACKET { 
    char c[100];
    sprintf(c,"[%s]", $<data>2);
    strcpy($<data>$, c);
 } 
;

BETWEEN_BRACKETS: INT_NUMBER
| IDENTIFIER
| IDENTIFIER ARRAY_ADD_ON_ID

/* HEAD OF THE PROGRAM - PARSING */
PROGRAM_DECLARATION: PROGRAM IDENTIFIER SEMICOLON
;

VARIABLE_DECLARATION: VAR DECLARATION_LISTS 
| VAR
;

DECLARATION_LISTS: DECLARATION_LIST DECLARATION_LISTS {  }
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
;

/* ANY STATEMENTS INSIDE THE PROGRAM */
STATEMENTS: STATEMENT STATEMENTS
| STATEMENT
;

/* STATEMENT THAT CAN BE READ, WRITE, ASSIGNMENT, CONDITIONAL AND LOOPING */
STATEMENT: READ_STATEMENT 
| WRITE_STATEMENT 
| ASSIGNMENT_STATEMENT 
| CONDITIONAL_STATEMENT 
| LOOPING_STATEMENT
;

/* READ STATEMENT */
READ_STATEMENT: READ LPAREN IDENTIFIER RPAREN SEMICOLON
| READ LPAREN IDENTIFIER ARRAY_ADD_ON_ID RPAREN SEMICOLON
;

/* WRITE STATEMENT */
WRITE_STATEMENT: WRITE LPAREN WRITE_IDENTIFIER_LIST RPAREN SEMICOLON
| WRITE_LN LPAREN WRITE_IDENTIFIER_LIST RPAREN SEMICOLON
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
| CHARACTER
| CHARACTER WRITE_MORE_IDENTIFIERS
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
| COMMA CHARACTER
| COMMA CHARACTER WRITE_MORE_IDENTIFIERS
;

/* ASSIGNMENT */
ASSIGNMENT_STATEMENT: IDENTIFIER COLON EQUAL ANY_EXPRESSION SEMICOLON
| IDENTIFIER ARRAY_ADD_ON_ID COLON EQUAL ANY_EXPRESSION SEMICOLON
| IDENTIFIER COLON EQUAL CHARACTER SEMICOLON
;

/* CONDITIONAL STATEMENT */
CONDITIONAL_STATEMENT: IF ANY_EXPRESSION THEN BODY_OF_CONDITIONAL ELSE BODY_OF_CONDITIONAL SEMICOLON
| IF ANY_EXPRESSION THEN BODY_OF_CONDITIONAL SEMICOLON
;

BODY_OF_CONDITIONAL: BEGINK STATEMENTS_INSIDE_CONDITIONAL END
;

STATEMENTS_INSIDE_CONDITIONAL: STATEMENT_INSIDE_CONDITIONAL STATEMENTS_INSIDE_CONDITIONAL
| STATEMENT_INSIDE_CONDITIONAL
;

/* EXPRESSION FORMULATION */
ANY_EXPRESSION: EXPRESSION_SEQUENCE 
| EXPRESSION_SEQUENCE RELOP EXPRESSION_SEQUENCE { if(printLogs) printf("\nCondition - Expr"); } /* Relational operators */
| LPAREN EXPRESSION_SEQUENCE RELOP EXPRESSION_SEQUENCE RPAREN { if(printLogs) printf("\nCondition - Expr with paren"); } /* Relational operators */
| BOOLEAN_EXPRESSION_SEQUENCE
; 

EXPRESSION_SEQUENCE: TERM 
| EXPRESSION_SEQUENCE PLUS EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), "+", popFromStack(), str1);
    displayQuadruple(); 
    pushToStack(str1);
}
| EXPRESSION_SEQUENCE MINUS EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), "-", popFromStack(), str1);
    displayQuadruple(); 
    pushToStack(str1);
}
| EXPRESSION_SEQUENCE MULTIPLY EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), "*", popFromStack(), str1);
    displayQuadruple(); 
    pushToStack(str1);
}
| EXPRESSION_SEQUENCE DIVIDE EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), "/", popFromStack(), str1);
    displayQuadruple(); 
    pushToStack(str1);
}
| EXPRESSION_SEQUENCE MOD EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), "%", popFromStack(), str1);
    displayQuadruple(); 
    pushToStack(str1);
}
| MINUS EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple("0", "-", popFromStack(), str1);
    displayQuadruple(); 
    pushToStack(str1);
}
| LPAREN EXPRESSION_SEQUENCE RPAREN { if(printLogs) printf("\nCondition - Closing Paren with paren"); }
;

BOOLEAN_EXPRESSION_SEQUENCE: NOT ANY_EXPRESSION /* NOT a */ { if(printLogs) printf("\nCondition - NOT"); }
| ANY_EXPRESSION AND ANY_EXPRESSION /* a AND b */ { if(printLogs) printf("\nCondition - AND"); }
| ANY_EXPRESSION OR ANY_EXPRESSION /* a OR b */ { if(printLogs) printf("\nCondition - OR"); }
| LPAREN BOOLEAN_EXPRESSION_SEQUENCE RPAREN
;

TERM: IDENTIFIER {
    char c[100]; 
    sprintf(c,"%s",$<data>1); 
    pushToStack(c);
}
| IDENTIFIER ARRAY_ADD_ON_ID {
    char c[100]; 
    sprintf(c,"%s%s",$<data>1, $<data>2); 
    pushToStack(c);
}
| INT_NUMBER {
    char c[100]; 
    sprintf(c,"%d", atoi($<data>1)); 
    pushToStack(c);
}
| DECIMAL_NUMBER {
    char c[100]; 
    sprintf(c,"%f", atof($<data>1)); 
    pushToStack(c);
}
;

STATEMENT_INSIDE_CONDITIONAL: READ_STATEMENT
| WRITE_STATEMENT
| ASSIGNMENT_STATEMENT
| LOOPING_STATEMENT
| CONDITIONAL_STATEMENT
;

/* LOOPING STATEMENT */
LOOPING_STATEMENT: WHILE_LOOP
| FOR_LOOP_TO
| FOR_LOOP_DOWNTO
;

WHILE_LOOP: WHILE ANY_EXPRESSION DO BODY_OF_LOOP SEMICOLON
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
        if(printLogs) printf("\nFile not found");
        exit(1);
    }
    else{
        if(printLogs) printf("\nInput file found, Parsing....");
        yyparse();
    }
}

int yyerror(){
    printf("\n\n\nSyntax error found");
    return 0;
}