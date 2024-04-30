%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>  


int yylex(void);
int yyerror();
extern FILE *yyin;

int printLogs = 0;
int yydebug = 1;

typedef struct Node{
    char type[10];
    float val;
    struct Nodee* child[10];
    int num_children;
}Node;

int symbol_table_index = 0;
int line_number = 0;

typedef struct Symbol{
    char id_name[50];
    char data_type[10];
    char val[10];
    char array[100][100];
    int isVarSet;
    int isArraySet[100];
    char varorarray[2];
    char min_index[5];
    char max_index[5];
}Symbol;

Symbol* symbol_table[100];
void addVar(Symbol** symbol_table, int symbol_table_index, char new_id_name[], char new_data_type[], char new_varorarray[]);
void addVarName(Symbol** symbol_table, int symbol_table_index, char new_id_name[], char new_varorarray[]);
bool check(Symbol** symbol_table, char new_id_name[], int symbol_table_index);
void enterDataTypeIntoSymbolTable(Symbol** symbol_table, char data_type[], int symbol_table_index);
Symbol* findSymbol(Symbol** symbol_table, char id_name[], int symbol_table_index);
void updateVal(Symbol* symbol, char val[], char varorarray[]);
void CustomError(char* message);


%}

%union {
    struct t{
    char id_name[50];
    char data_type[10];
    char val[10];
    char varorarray[2];
    char min_index[5];
    char max_index[5];
    char operator[3];
}t;
}

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
DATATYPE:  { if(printLogs) printf("\nDATATYPE found - INTEGER"); } INTEGER { strcpy($<t.data_type>$, $<t.data_type>2); }
| { if(printLogs) printf("\nDATATYPE found - REAL"); } REAL { strcpy($<t.data_type>$, $<t.data_type>2); }
| { if(printLogs) printf("\nDATATYPE found - BOOLEAN"); } BOOLEAN { strcpy($<t.data_type>$, $<t.data_type>2); }
| { if(printLogs) printf("\nDATATYPE found - CHAR"); } CHAR { strcpy($<t.data_type>$, $<t.data_type>2); }
;

RELOP: EQUAL { strcpy($<t.operator>$, "="); }
| NOTEQUAL { strcpy($<t.operator>$, "<>"); }
| LESS { strcpy($<t.operator>$, "<"); }
| LESSEQUAL { strcpy($<t.operator>$, "<="); }
| GREATER { strcpy($<t.operator>$, ">"); }
| GREATEREQUAL { strcpy($<t.operator>$, ">="); }
;

/* ARRAY ADD ON FOR EVERY ID */
ARRAY_ADD_ON_ID: LBRACKET BETWEEN_BRACKETS RBRACKET { strcpy($<t.val>$, $<t.val>1); } 
;

BETWEEN_BRACKETS: INT_NUMBER { if(strcmp($<t.data_type>1, "int") == 0){
        strcpy($<t.val>$, $<t.val>1);
    } 
    else{
        CustomError("Array index must be integer");
    } 
}
| IDENTIFIER { if((strcpm($<t.data_type>1, "int") == 0) && (checkIsVarSet(symbol_table, $<t.id_name>1, symbol_table_index))){
        strcpy($<t.val>$, $<t.val>1);
    } 
    else{
        CustomError("Array index must be integer and must be set");
    } 
}
| IDENTIFIER ARRAY_ADD_ON_ID { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index); 
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") == 0){
            printf("\nVariable < %s > found", $<t.id_name>1);
            CustomError("Variable found in expression instead of array");
        }
        else if(strcmp(symbol->varorarray, "2") == 0){
            printf("\nArray < %s > found", $<t.id_name>1);
            if(checkIsArraySet(symbol_table, $<t.id_name>1, atoi($<t.val>2), symbol_table_index)){
                strcpy($<t.val>$, symbol->array[atoi($<t.val>2)]);
                strcpy($<t.data_type>$, symbol->data_type);
            }
            else{
                printf("\nArray index not set for < %s >", $<t.id_name>1);
                CustomError("Array index not set");
            }
        }
    }
    else{
        printf("\nIdentifier < %s > not found", $<t.id_name>1);
        CustomError("Identifier not found");
    
    }
}

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

SINGLE_VARIABLE: IDENTIFIER COLON DATATYPE SEMICOLON { addVar(symbol_table, symbol_table_index, $<t.id_name>1, $<t.     data_type>3, "1");
symbol_table_index++;
}
;

MULTIPLE_VARIABLE: IDENTIFIER MORE_IDENTIFIERS COLON DATATYPE SEMICOLON { addVarName(symbol_table, symbol_table_index, $<t.id_name>1, "1");
    symbol_table_index++;
enterDataTypeIntoSymbolTable(symbol_table, $<t.data_type>4, symbol_table_index); }
;

MORE_IDENTIFIERS: COMMA IDENTIFIER MORE_IDENTIFIERS {     
        addVarName(symbol_table, symbol_table_index,  $<t.id_name>2, "1");
    symbol_table_index++;
    
}
| COMMA IDENTIFIER { addVarName(symbol_table, symbol_table_index,  $<t.id_name>2, "1");
    symbol_table_index++;
}
;

ARRAY_DECLARATION: IDENTIFIER COLON ARRAY LBRACKET INT_NUMBER ARRAY_DOT INT_NUMBER RBRACKET OF DATATYPE SEMICOLON {
    if (!check(symbol_table, $<t.id_name>1, symbol_table_index))
    {
        strcpy(symbol_table[symbol_table_index]->id_name, $<t.id_name>1);
        strcpy(symbol_table[symbol_table_index]->data_type, $<t.data_type>10);
        strcpy(symbol_table[symbol_table_index]->varorarray, "2"); 
        strcpy(symbol_table[symbol_table_index]->min_index, $<t.val>5); 
        strcpy(symbol_table[symbol_table_index]->max_index, $<t.val>7); 
        symbol_table_index++;
    }
}
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
READ_STATEMENT: READ LPAREN IDENTIFIER RPAREN SEMICOLON { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>3, symbol_table_index);
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") == 0){
            printf("\nVariable < %s > found", $<t.id_name>3);
        }
        else if(strcmp(symbol->varorarray, "2") == 0){
            printf("\nArray < %s > found", $<t.id_name>3);
        }
    }
    else{
        printf("\nVariable < %s > not found", $<t.id_name>3);
        CustomError("Variable Not Found");
    }
}
| READ LPAREN IDENTIFIER ARRAY_ADD_ON_ID RPAREN SEMICOLON { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>3, symbol_table_index);
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") == 0){
            printf("\nVariable < %s > found", $<t.id_name>3);
        }
        else if(strcmp(symbol->varorarray, "2") == 0){
            printf("\nArray < %s > found", $<t.id_name>3);
        }
    }
    else{
        printf("\nVariable < %s > not found", $<t.id_name>3);
        CustomError("Variable Not Found");
    }
}
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
| IDENTIFIER COLON EQUAL CHARACTER SEMICOLON { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index);
    updateVal(symbol, $<t.val>4, "1");
}
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
    if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>2, "int") == 0)){
        strcpy($<t.data_type>$, "int");    
    } 
    else if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>2, "real") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "real") == 0) && (strcmp($<t.data_type>2, "int") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "char") == 0) || (strcmp($<t.data_type>2, "char")  == 0) || (strcmp($<t.data_type>2, "string")  == 0) || (strcmp($<t.data_type>2, "string")  == 0)){
        CustomError("Invalid data type for addition");
    }
    else{
        CustomError("Invalid data type for addition");
    }
}
| EXPRESSION_SEQUENCE MINUS EXPRESSION_SEQUENCE { 
    if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>2, "int") == 0)){
        strcpy($<t.data_type>$, "int");    
    } 
    else if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>2, "real") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "real") == 0) && (strcmp($<t.data_type>2, "int") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "char") == 0) || (strcmp($<t.data_type>2, "char")  == 0) || (strcmp($<t.data_type>2, "string")  == 0) || (strcmp($<t.data_type>2, "string")  == 0)){
        CustomError("Invalid data type for subtraction");
    }
    else{
        CustomError("Invalid data type for subtraction");
    }
}
| EXPRESSION_SEQUENCE MULTIPLY EXPRESSION_SEQUENCE { 
    if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>2, "int") == 0)){
        strcpy($<t.data_type>$, "int");    
    } 
    else if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>2, "real") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "real") == 0) && (strcmp($<t.data_type>2, "int") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "char") == 0) || (strcmp($<t.data_type>2, "char")  == 0) || (strcmp($<t.data_type>2, "string")  == 0) || (strcmp($<t.data_type>2, "string")  == 0)){
        CustomError("Invalid data type for multiplication");
    }
    else{
        CustomError("Invalid data type for multiplication");
    }
}
| EXPRESSION_SEQUENCE DIVIDE EXPRESSION_SEQUENCE { 
    if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>2, "int") == 0)){
        strcpy($<t.data_type>$, "int");    
    } 
    else if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>2, "real") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "real") == 0) && (strcmp($<t.data_type>2, "int") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "char") == 0) || (strcmp($<t.data_type>2, "char")  == 0) || (strcmp($<t.data_type>2, "string")  == 0) || (strcmp($<t.data_type>2, "string")  == 0)){
        CustomError("Invalid data type for division");
    }
    else{
        CustomError("Invalid data type for division");
    }
}
| EXPRESSION_SEQUENCE MOD EXPRESSION_SEQUENCE { 
    if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>2, "int") == 0)){
        strcpy($<t.data_type>$, "int");    
    } 
    else if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>2, "real") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "real") == 0) && (strcmp($<t.data_type>2, "int") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "char") == 0) || (strcmp($<t.data_type>2, "char")  == 0) || (strcmp($<t.data_type>2, "string")  == 0) || (strcmp($<t.data_type>2, "string")  == 0)){
        CustomError("Invalid data type for mod");
    }
    else{
        CustomError("Invalid data type for mod");
    }
}
| MINUS EXPRESSION_SEQUENCE
| LPAREN EXPRESSION_SEQUENCE RPAREN { if(printLogs) printf("\nCondition - Closing Paren with paren"); }
;

BOOLEAN_EXPRESSION_SEQUENCE: NOT ANY_EXPRESSION /* NOT a */ { if(printLogs) printf("\nCondition - NOT"); }
| ANY_EXPRESSION AND ANY_EXPRESSION /* a AND b */ { if(printLogs) printf("\nCondition - AND"); }
| ANY_EXPRESSION OR ANY_EXPRESSION /* a OR b */ { if(printLogs) printf("\nCondition - OR"); }
| LPAREN BOOLEAN_EXPRESSION_SEQUENCE RPAREN
;

TERM: IDENTIFIER { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index); 
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") == 0){
            printf("\nVariable < %s > found", $<t.id_name>1);
            if(checkIsVarSet(symbol_table, $<t.id_name>1, symbol_table_index)){
                strcpy($<t.val>$, symbol->val);
                strcpy($<t.data_type>$, symbol->data_type);
            }
            else{
                printf("\nVariable < %s > not set", $<t.id_name>1);
                CustomError("Variable not set");
            }
        }
        else if(strcmp(symbol->varorarray, "2") == 0){
            printf("\nArray < %s > found", $<t.id_name>1);
            CustomError("Array found in expression instead of Variable");
        }
    }
    else{
        printf("\nIdentifier < %s > not found", $<t.id_name>1);
        CustomError("Identifier not found");
    }
}

| IDENTIFIER ARRAY_ADD_ON_ID { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index); 
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") == 0){
            printf("\nVariable < %s > found", $<t.id_name>1);
            CustomError("Variable found in expression instead of array");
        }
        else if(strcmp(symbol->varorarray, "2") == 0){
            printf("\nArray < %s > found", $<t.id_name>1);
            if(checkIsArraySet(symbol_table, $<t.id_name>1, atoi($<t.val>2), symbol_table_index)){
                strcpy($<t.val>$, symbol->array[atoi($<t.val>2)]);
                strcpy($<t.data_type>$, symbol->data_type);
            }
            else{
                printf("\nArray index not set for < %s >", $<t.id_name>1);
                CustomError("Array index not set");
            }
        }
    }
    else{
        printf("\nIdentifier < %s > not found", $<t.id_name>1);
        CustomError("Identifier not found");
    
    }
}
| INT_NUMBER { strcpy($<t.val>$, $<t.val>1); strcpy($<t.data_type>$, $<t.data_type>1); }
| DECIMAL_NUMBER { strcpy($<t.val>$, $<t.val>1); strcpy($<t.data_type>$, $<t.data_type>1); }
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

void addVar(Symbol** symbol_table, int symbol_table_index, char new_id_name[], char new_data_type[], char new_varorarray[]){
    if (!check(symbol_table, new_id_name, symbol_table_index))
    {
        strcpy(symbol_table[symbol_table_index]->id_name, new_id_name);
        strcpy(symbol_table[symbol_table_index]->data_type, new_data_type);
        strcpy(symbol_table[symbol_table_index]->varorarray, new_varorarray); 
        symbol_table_index++;
    }
}

void addVarName(Symbol** symbol_table, int symbol_table_index, char new_id_name[], char new_varorarray[]){
    if(!check(symbol_table, new_id_name, symbol_table_index))
    {
        strcpy(symbol_table[symbol_table_index]->id_name, new_id_name);
        strcpy(symbol_table[symbol_table_index]->varorarray, new_varorarray);     
        symbol_table_index++;
    }
}

bool check(Symbol** symbol_table, char new_id_name[], int symbol_table_index){
    for(int i = 0; i < symbol_table_index; i++){
        if(strcmp(symbol_table[i]->id_name, new_id_name) == 0){        
            printf("\nVariable < %s > already declared", new_id_name);
            printf("Exiting...");
            exit(1);
        }
    }
    return false;
}

void enterDataTypeIntoSymbolTable(Symbol** symbol_table, char data_type[10], int symbol_table_index){
    printf("enter called");
    for(int i = 0; i < symbol_table_index; i++){
        printf("\n%s", symbol_table[i]->data_type);
        if(strcmp(symbol_table[i]->data_type, "null") == 0){
            strcpy(symbol_table[i]->data_type, data_type);
        }
    }
}

Symbol* findSymbol(Symbol** symbol_table, char id_name[], int symbol_table_index){
    for(int i = 0; i < symbol_table_index; i++){
        if(strcmp(symbol_table[i]->id_name, id_name) == 0){
            return symbol_table[i];
        }
    }
    return NULL;
}

void updateVal(Symbol* symbol, char val[], char varorarray[]){
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, varorarray) == 0){
            printf("\n%s < %s > found", varorarray, symbol->id_name);
            strcpy(symbol->val, val);
        }
        else{
            printf("\n%s < %s > found", varorarray, symbol->id_name);
        }
    }
    else{
        printf("\nVariable < %s > not found", symbol->id_name);
        exit(1);
    }
}

char* performOperation(char op[], Symbol* operand1, Symbol* operand2){
    if((strcmp(operand1->data_type, "int") == 0) && (strcmp(operand2->data_type, "int") == 0)){
    if(strcmp(op, "+") == 0){
        return itoa((atoi(operand1->val) + atoi(operand2->val)));
    }
    else if(strcmp(op, "-") == 0){
        return itoa((atoi(operand1->val) - atoi(operand2->val)));
    }
    else if(strcmp(op, "*") == 0){
        return itoa((atoi(operand1->val) * atoi(operand2->val)));
    }
    else if(strcmp(op, "/") == 0){
        return itoa((atoi(operand1->val) / atoi(operand2->val)));
    }
    else if(strcmp(op, "%") == 0){
        return itoa((atoi(operand1->val) % atoi(operand2->val)));
    }}
}

bool checkIsVarSet(Symbol** symbol_table, char id_name[], int symbol_table_index){
    for(int i = 0; i < symbol_table_index; i++){
        if(strcmp(symbol_table[i]->id_name, id_name) == 0){
            if(symbol_table[i]->isVarSet == 1){
                return true;
            }
            else{
                return false;
            }
        }
    }
    return false;
}

bool checkIsArraySet(Symbol** symbol_table, char id_name[], int arr_ind, int symbol_table_index){
    for(int i = 0; i < symbol_table_index; i++){
        if(strcmp(symbol_table[i]->id_name, id_name) == 0){
            if(symbol_table[i]->isArraySet[arr_ind] == 1){
                return true;
            }
            else{
                return false;
            }
        }
    }
    return false;
}

void main()
{
    for(int i = 0; i < 100; i++){
        symbol_table[i] = (Symbol *)malloc(sizeof(Symbol));
        strcpy(symbol_table[i]->id_name, "");
        strcpy(symbol_table[i]->data_type, "null");
        strcpy(symbol_table[i]->val, "0");
        strcpy(symbol_table[i]->varorarray, "0");
        strcpy(symbol_table[i]->min_index, "null");
        strcpy(symbol_table[i]->max_index, "null");
        symbol_table[i]->isVarSet = 0;
        memset(symbol_table[i]->isArraySet, 0, 100*sizeof(int));
        for(int j = 0; j < 100; j++){
            strcpy(symbol_table[i]->array[j], "null");
        }
        
    }

    yyin = fopen("sample.txt", "r");
    if(yyin == NULL){
        if(printLogs) printf("\nFile not found");
        exit(1);
    }
    else{
        if(printLogs) printf("\nInput file found, Parsing....");
        yyparse();
    }

    printf("\n========\nSymbol Table:\n========");
    for(int i = 0; i < symbol_table_index; i++){
        if(strcmp(symbol_table[i]->varorarray, "1") == 0){
        printf("\nID Name: %s", symbol_table[i]->id_name);
        printf(", Data Type: %s", symbol_table[i]->data_type);
        printf(", Value: %s", symbol_table[i]->val);
        }
        else if(strcmp(symbol_table[i]->varorarray, "2") == 0){
            printf("\nArray Name: %s", symbol_table[i]->id_name);
            printf(", Data Type: %s", symbol_table[i]->data_type);
            printf(", Min Index: %s", symbol_table[i]->min_index);
            printf(", Max Index: %s", symbol_table[i]->max_index);
        }
    }
}

int yyerror(){
    printf("\n\n\nSyntax error found");
    return 0;
}

void CustomError(char* message){
    printf("\n\n\n%s", message);
    exit(1);
}