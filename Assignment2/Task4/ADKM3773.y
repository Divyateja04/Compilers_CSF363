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
int quadrupleIndex=0;
int tos=-1;
int temp_char=0;

struct quadruple{
    char operator[50];
    char operand1[100];
    char operand2[100];
    char result[100];
} quad[1000];

struct stack {
    char c[100]; 
} stac[1000];

void addQuadruple(char op1[], char op[], char op2[], char result[])
{
    strcpy(quad[quadrupleIndex].operator, op);
    strcpy(quad[quadrupleIndex].operand1, op1);
    strcpy(quad[quadrupleIndex].operand2, op2);
    strcpy(quad[quadrupleIndex].result, result);
    quadrupleIndex++;
}

void displayQuadruple()
{
    // This is the part where processing for loops takes place
    for(int i=0; i<quadrupleIndex; i++){
        // Check if the current quadruple starts a if condition
        if(strcmp(quad[i].result, "if_cond_end") == 0){
            int j = i+1;
            while(strcmp(quad[j].result, "ifthen_body_end") != 0){
                // we need to go until the end of if body and 
                // replace the goto with the actual line number
                j++;
            }
            sprintf(quad[i].operator, "true: goto %03d", i+1);
            sprintf(quad[i].operand2, "false: goto %03d", j+1);
        }
        if(strcmp(quad[i].result, "while_cond_end") == 0){
            int j = i+1;
            while(strcmp(quad[j].result, "while_body_end") != 0){
                // we need to go until the end of while body and 
                // replace the goto with the actual line number
                j++;
            }
            sprintf(quad[i].operator, "true: goto %03d", i+1);
            sprintf(quad[i].operand2, "false: goto %03d", j+1);
            // Add go to while_cond_start when you reach while_body_end
            int k = j;
            while(strcmp(quad[k].result, "while_cond_start") != 0 && k > 0){
                k--;
            }
            sprintf(quad[j].operator, "goto %03d", k);
        }
    }
    // This is the part where it's printed
    for(int i=0; i<quadrupleIndex; i++){
        if(strncmp(quad[i].result, "if_start", 8) == 0
        || strncmp(quad[i].result, "while_start", 11) == 0
        || strncmp(quad[i].result, "for_start", 9) == 0
        ){
            printf("\n");
        };

        printf(":%03d:> ", i);
        printf(" %s ", quad[i].result);

        // Print = only if there's something after that
        if(strcmp(quad[i].operand1, "NA") != 0
        || strcmp(quad[i].operator, "NA") != 0
        || strcmp(quad[i].operand2, "NA") != 0
        ) printf(" = ");

        if(strcmp(quad[i].operand1, "NA") != 0) printf(" %s ", quad[i].operand1);
        if(strcmp(quad[i].operator, "NA") != 0) printf(" %s ", quad[i].operator);
        if(strcmp(quad[i].operand2, "NA") != 0) printf(" %s ", quad[i].operand2);
        printf(";\n");

        if(strncmp(quad[i].result, "if_end", 11) == 0
        || strncmp(quad[i].result, "while_end", 9) == 0
        || strncmp(quad[i].result, "for_end", 7) == 0
        ){
            printf("\n");
        };
    }
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
stmt: PROGRAM_DECLARATION VARIABLE_DECLARATION BODY_OF_PROGRAM { printf("\n\n\nParsing completed successfully"); }
;

/* TYPE DECLARATIONS */
DATATYPE: INTEGER 
| REAL 
| BOOLEAN 
| CHAR 
;

RELOP: EQUAL { strcpy($<data>$, "="); }
| NOTEQUAL { strcpy($<data>$, "!="); }
| LESS { strcpy($<data>$, "<"); }
| LESSEQUAL { strcpy($<data>$, "<="); }
| GREATER { strcpy($<data>$, ">"); }
| GREATEREQUAL { strcpy($<data>$, ">="); }
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
BODY_OF_PROGRAM: BEGINK STATEMENTS END DOT {
    printf("============================\n");
    displayQuadruple();
    printf("============================\n");
}
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
ASSIGNMENT_STATEMENT: IDENTIFIER COLON EQUAL ANY_EXPRESSION SEMICOLON {
    addQuadruple("NA", "NA", $<data>4, $<data>1);
}
| IDENTIFIER ARRAY_ADD_ON_ID COLON EQUAL ANY_EXPRESSION SEMICOLON {
    addQuadruple("NA", "NA", $<data>4, $<data>1);
}
| IDENTIFIER COLON EQUAL CHARACTER SEMICOLON {
    addQuadruple("NA", "NA", $<data>4, $<data>1);
}
;

/* CONDITIONAL STATEMENT */
CONDITIONAL_STATEMENT: IF {
    addQuadruple("NA", "NA", "NA", "if_start"); 
} ANY_EXPRESSION {
    addQuadruple(popFromStack(), "NA", "NA", "if_cond_end");
} AFTER_IF_ANY_EXPR 
;

AFTER_IF_ANY_EXPR: THEN {
    addQuadruple("NA", "NA", "NA", "ifthen_body_start"); 
} BODY_OF_CONDITIONAL {
    addQuadruple("NA", "NA", "NA", "ifthen_body_end"); 
} AFTER_IF_THEN_BODY 
;

AFTER_IF_THEN_BODY: ELSE {
    addQuadruple("NA", "NA", "NA", "else_body_start"); 
} BODY_OF_CONDITIONAL {
    addQuadruple("NA", "NA", "NA", "else_body_end"); 
} SEMICOLON {
    addQuadruple("NA", "NA", "NA", "if_end"); 
}
| SEMICOLON {
    addQuadruple("NA", "NA", "NA", "if_end"); 
}
;

BODY_OF_CONDITIONAL: BEGINK STATEMENTS_INSIDE_CONDITIONAL END
;

STATEMENTS_INSIDE_CONDITIONAL: STATEMENT_INSIDE_CONDITIONAL STATEMENTS_INSIDE_CONDITIONAL
| STATEMENT_INSIDE_CONDITIONAL
;

/* EXPRESSION FORMULATION */
ANY_EXPRESSION: EXPRESSION_SEQUENCE  /* I think we can ignore this because it will anyways call the other one */
| EXPRESSION_SEQUENCE RELOP EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), $<data>2, popFromStack(), str1);
    pushToStack(str1);
    strcpy($<data>$, str1);
} 
| LPAREN EXPRESSION_SEQUENCE RELOP EXPRESSION_SEQUENCE RPAREN {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), $<data>3, popFromStack(), str1);
    pushToStack(str1);
    strcpy($<data>$, str1);
}
| BOOLEAN_EXPRESSION_SEQUENCE /* I think we can ignore this because it will anyways call the other one */
; 

EXPRESSION_SEQUENCE: TERM /* I think we can ignore this because these are being pushed onto stack anyways */
| EXPRESSION_SEQUENCE PLUS EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), "+", popFromStack(), str1);
    pushToStack(str1);
    strcpy($<data>$, str1);
}
| EXPRESSION_SEQUENCE MINUS EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), "-", popFromStack(), str1);
    pushToStack(str1);
    strcpy($<data>$, str1);
}
| EXPRESSION_SEQUENCE MULTIPLY EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), "*", popFromStack(), str1);
    pushToStack(str1);
    strcpy($<data>$, str1);
}
| EXPRESSION_SEQUENCE DIVIDE EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), "/", popFromStack(), str1);
    pushToStack(str1);
    strcpy($<data>$, str1);
}
| EXPRESSION_SEQUENCE MOD EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), "%", popFromStack(), str1);
    pushToStack(str1);
    strcpy($<data>$, str1);
}
| MINUS EXPRESSION_SEQUENCE {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple("NA", "-", popFromStack(), str1);
    pushToStack(str1);
    strcpy($<data>$, str1);
}
| LPAREN EXPRESSION_SEQUENCE RPAREN /* I think we can ignore this because it will anyways call the other one */
;

BOOLEAN_EXPRESSION_SEQUENCE: NOT ANY_EXPRESSION /* NOT a */ {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple("NA", "!", popFromStack(), str1);
    pushToStack(str1);
    strcpy($<data>$, str1);
}
| ANY_EXPRESSION AND ANY_EXPRESSION /* a AND b */ {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), "&", popFromStack(), str1);
    pushToStack(str1);
    strcpy($<data>$, str1);
}
| ANY_EXPRESSION OR ANY_EXPRESSION /* a OR b */ {
    char str[5];
    char str1[5]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple(popFromStack(), "|", popFromStack(), str1);
    pushToStack(str1);
    strcpy($<data>$, str1);
}
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
;

/* LOOPING STATEMENT */
LOOPING_STATEMENT: WHILE_LOOP
| FOR_LOOP
;

WHILE_LOOP: WHILE {
    addQuadruple("NA", "NA", "NA", "while_start");
    addQuadruple("NA", "NA", "NA", "while_cond_start");
} ANY_EXPRESSION DO {
    addQuadruple(popFromStack(), "NA", "NA", "while_cond_end");
    addQuadruple("NA", "NA", "NA", "while_body_start");
} BODY_OF_LOOP {
    addQuadruple("NA", "NA", "NA", "while_body_end");
} SEMICOLON {
    addQuadruple("NA", "NA", "NA", "while_end");
}
;

FOR_LOOP: FOR {
    addQuadruple("NA", "NA", "NA", "for_start");
} IDENTIFIER COLON EQUAL {
    addQuadruple("NA", "NA", "NA", "for_assn_start");
} EXPRESSION_SEQUENCE {
    addQuadruple(popFromStack(), "NA", "NA", $<data>3);
} AFTER_FOR_CONDITION
;

AFTER_FOR_CONDITION: TO EXPRESSION_SEQUENCE {
    addQuadruple(popFromStack(), "NA", "NA", $<data>1);
    addQuadruple("NA", "NA", "NA", "for_assn_end");
} DO {
    addQuadruple("NA", "NA", "NA", "for_body_start");
} BODY_OF_LOOP {
    addQuadruple("NA", "NA", "NA", "for_body_end");
} SEMICOLON {
    addQuadruple("NA", "NA", "NA", "for_end");
}
| DOWNTO EXPRESSION_SEQUENCE {
    addQuadruple(popFromStack(), "NA", "NA", $<data>1);
    addQuadruple("NA", "NA", "NA", "for_assn_end");
} DO {
    addQuadruple("NA", "NA", "NA", "for_body_start");
} BODY_OF_LOOP {
    addQuadruple("NA", "NA", "NA", "for_body_end");
} SEMICOLON {
    addQuadruple("NA", "NA", "NA", "for_end");
}

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