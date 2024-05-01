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

struct Treenode
{
  	char *name;
    struct Treenode * child[30];
    int child_index;
}; 

struct Treenode* initNode(char *);
void addNodetoTree(struct Treenode *,struct Treenode *);
void printTree(struct Treenode *);

struct Treenode *head;

// %union { 
// 	struct var_name { 
// 		char name[100]; 
// 		Treenode* nd;
// 	} node_obj; 
// }

int symbol_table_index = 0;

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


char TreeInString[400000];
int TreeInStringIndex = 0;

Symbol* symbol_table[100];
void addVar(Symbol** symbol_table, int symbol_table_index, char new_id_name[], char new_data_type[], char new_varorarray[]);
void addVarName(Symbol** symbol_table, int symbol_table_index, char new_id_name[], char new_varorarray[]);
bool check(Symbol** symbol_table, char new_id_name[], int symbol_table_index);
void enterDataTypeIntoSymbolTable(Symbol** symbol_table, char data_type[], int symbol_table_index);
Symbol* findSymbol(Symbol** symbol_table, char id_name[], int symbol_table_index);
bool checkIsVarSet(Symbol** symbol_table, char id_name[], int symbol_table_index);
bool checkIsArraySet(Symbol** symbol_table, char id_name[], int arr_ind, int symbol_table_index);
void printSymbolTable();
void CustomError1(int lineNumber, char* message);
void CustomError2(int lineNumber, char* id_name, char* message);
void CustomError3(int lineNumber, char* id_name, char* index,char* message);

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
    int lineNumber;
    struct Treenode * nd;
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
stmt: { if(printLogs) printf("\nParsing started");  } PROGRAM_DECLARATION VARIABLE_DECLARATION BODY_OF_PROGRAM { printf("\n\n\nParsing completed successfully"); 
$<t.nd>$= initNode("root"); 
addNodetoTree($<t.nd>$,$<t.nd>2); 
addNodetoTree($<t.nd>$,$<t.nd>3); 
addNodetoTree($<t.nd>$,$<t.nd>4); head=$<t.nd>$; }
;

/* TYPE DECLARATIONS */
DATATYPE: INTEGER { strcpy($<t.data_type>$, $<t.data_type>1); $<t.lineNumber>$ = $<t.lineNumber>1; 
$<t.nd>$ =initNode("Datatype"); $<t.nd>1 = initNode("Integer"); addNodetoTree($<t.nd>$,$<t.nd>1);}
| REAL { strcpy($<t.data_type>$, $<t.data_type>1); $<t.lineNumber>$ = $<t.lineNumber>1;
$<t.nd>$ = initNode("Datatype"); $<t.nd>1 = initNode("Real"); addNodetoTree($<t.nd>$,$<t.nd>1);}
| BOOLEAN { strcpy($<t.data_type>$, $<t.data_type>1); $<t.lineNumber>$ = $<t.lineNumber>1; 
$<t.nd>$ =initNode("Datatype"); $<t.nd>1 =  initNode("Boolean");addNodetoTree($<t.nd>$,$<t.nd>1);}
| CHAR { strcpy($<t.data_type>$, $<t.data_type>1); $<t.lineNumber>$ = $<t.lineNumber>1;
$<t.nd>$ =initNode("Datatype"); $<t.nd>1 = initNode("Char"); addNodetoTree($<t.nd>$,$<t.nd>1);} 
;

RELOP: EQUAL { strcpy($<t.operator>$, "="); $<t.lineNumber>$ = $<t.lineNumber>1; strcpy($<t.data_type>$, "boolean"); 
$<t.nd>$ =initNode("Relop"); $<t.nd>1 = initNode("EQUALS"); addNodetoTree($<t.nd>$,$<t.nd>1);}
| NOTEQUAL { strcpy($<t.operator>$, "<>"); $<t.lineNumber>$ = $<t.lineNumber>1; strcpy($<t.data_type>$, "boolean"); 
$<t.nd>$ =initNode("Relop"); $<t.nd>1 =  initNode("NOTEQUALS"); addNodetoTree($<t.nd>$,$<t.nd>1);}
| LESS { strcpy($<t.operator>$, "<"); $<t.lineNumber>$ = $<t.lineNumber>1; strcpy($<t.data_type>$, "boolean"); 
$<t.nd>$ =initNode("Relop");  $<t.nd>1 = initNode("LESS"); addNodetoTree($<t.nd>$,$<t.nd>1);}
| LESSEQUAL { strcpy($<t.operator>$, "<="); $<t.lineNumber>$ = $<t.lineNumber>1; strcpy($<t.data_type>$, "boolean"); 
$<t.nd>$ =initNode("Relop"); $<t.nd>1 =  initNode("LESSEQUAL"); addNodetoTree($<t.nd>$,$<t.nd>1);}
| GREATER { strcpy($<t.operator>$, ">"); $<t.lineNumber>$ = $<t.lineNumber>1; strcpy($<t.data_type>$, "boolean"); 
$<t.nd>$ =initNode("Relop"); $<t.nd>1 = initNode("GREATER"); addNodetoTree($<t.nd>$,$<t.nd>1);}
| GREATEREQUAL { strcpy($<t.operator>$, ">="); $<t.lineNumber>$ = $<t.lineNumber>1; strcpy($<t.data_type>$, "boolean"); 
$<t.nd>$ =initNode("Relop"); $<t.nd>1 = initNode("GREATEREQUAL"); addNodetoTree($<t.nd>$,$<t.nd>1);}
;

/* ARRAY ADD ON FOR EVERY ID */
ARRAY_ADD_ON_ID: LBRACKET BETWEEN_BRACKETS RBRACKET { 
    $<t.lineNumber>$ = $<t.lineNumber>2; 
    if(strcmp($<t.data_type>2, "int") == 0){
        strcpy($<t.val>$, $<t.val>2);
    }
    else{
        CustomError1($<t.lineNumber>1, "Array index must be integer");
    } 
    $<t.nd>$ = initNode("ArrayAddOn");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>1 = initNode("[");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("]");
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
;

BETWEEN_BRACKETS: INT_NUMBER { 
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(strcmp($<t.data_type>1, "int") == 0){
        strcpy($<t.val>$, $<t.val>1);
    } 
    else{
        CustomError1($<t.lineNumber>1, "Array index must be integer");
    }
    $<t.nd>$ = initNode("BetweenBrackets");
    $<t.nd>1 = initNode("INT_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| IDENTIFIER { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index); 
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(symbol != NULL){    
        if((strcmp($<t.data_type>1, "int") == 0) && (symbol->isVarSet == 1)){
        strcpy($<t.val>$, symbol->val);
        } 
        else{
            CustomError2($<t.lineNumber>1, $<t.id_name>1, "Variable must be integer and must be set before it's accessed");
        }
    }
    else{
        CustomError2($<t.lineNumber>1, $<t.id_name>1, "Variable not declared");
    }    
    $<t.nd>$ = initNode("BetweenBrackets");
    $<t.nd>1 = initNode("IDENTIFIER"); 
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| IDENTIFIER ARRAY_ADD_ON_ID { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index); 
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "2") == 0){
            if(checkIsArraySet(symbol_table, $<t.id_name>1, atoi($<t.val>2), symbol_table_index)){
                strcpy($<t.val>$, symbol->array[atoi($<t.val>2)]);
            }
            else{
                CustomError3($<t.lineNumber>1, $<t.id_name>1, $<t.val>2, "Array index not set");
            }
        }
        else if(strcmp(symbol->varorarray, "1") == 0){
            CustomError2($<t.lineNumber>1, $<t.id_name>1, "Identifier not an array");
        }
    }
    else{
        CustomError2($<t.lineNumber>1, $<t.id_name>1, "Array not declared");    
    }
    $<t.nd>$ = initNode("BetweenBrackets");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}

/* HEAD OF THE PROGRAM - PARSING */
PROGRAM_DECLARATION: PROGRAM IDENTIFIER SEMICOLON {
    if (!check(symbol_table, $<t.id_name>2, symbol_table_index))
    {
        strcpy(symbol_table[symbol_table_index]->id_name, $<t.id_name>2);
        strcpy(symbol_table[symbol_table_index]->data_type, "Program Name");
        strcpy(symbol_table[symbol_table_index]->varorarray, "0"); 
        $<t.lineNumber>$ = $<t.lineNumber>2;
        symbol_table_index++;
    }
    $<t.nd>$ = initNode("ProgramDeclaration");
    $<t.nd>1 = initNode("PROGRAM");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
;

VARIABLE_DECLARATION: VAR DECLARATION_LISTS {
    $<t.nd>$ = initNode("VariableDeclaration");
    $<t.nd>1 = initNode("VAR");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| VAR {
    $<t.nd>$ = initNode("VariableDeclaration");
    $<t.nd>1 = initNode("VAR");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
;

DECLARATION_LISTS: DECLARATION_LIST DECLARATION_LISTS {
    $<t.nd>$=initNode("DeclarationLists");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| DECLARATION_LIST {
    $<t.nd>$=initNode("DeclarationLists");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
;

DECLARATION_LIST: SINGLE_VARIABLE {
    $<t.nd>$=initNode("DeclarationList");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| MULTIPLE_VARIABLE {
    $<t.nd>$=initNode("DeclarationList");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| ARRAY_DECLARATION{
    $<t.nd>$=initNode("DeclarationList");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
;

SINGLE_VARIABLE: IDENTIFIER COLON DATATYPE SEMICOLON { 
    addVar(symbol_table, symbol_table_index, $<t.id_name>1, $<t.data_type>3, "1");
    $<t.lineNumber>$ = $<t.lineNumber>1;
    symbol_table_index++;
    $<t.nd>$ = initNode("SingleVariable");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("COLON");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
    $<t.nd>4 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>4);
}
;

MULTIPLE_VARIABLE: IDENTIFIER MORE_IDENTIFIERS COLON DATATYPE SEMICOLON { 
    addVarName(symbol_table, symbol_table_index, $<t.id_name>1, "1");
    $<t.lineNumber>$ = $<t.lineNumber>1;
    symbol_table_index++;
    enterDataTypeIntoSymbolTable(symbol_table, $<t.data_type>4, symbol_table_index); 
    $<t.nd>$ = initNode("MultipleVariable");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("COLON");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    addNodetoTree($<t.nd>$,$<t.nd>4);
    $<t.nd>5 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>5);
}
;

MORE_IDENTIFIERS: COMMA IDENTIFIER MORE_IDENTIFIERS {     
    addVarName(symbol_table, symbol_table_index,  $<t.id_name>2, "1");
    $<t.lineNumber>$ = $<t.lineNumber>2;
    symbol_table_index++;
    $<t.nd>$ = initNode("MoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
| COMMA IDENTIFIER { 
    addVarName(symbol_table, symbol_table_index, $<t.id_name>2, "1");
    $<t.lineNumber>$ = $<t.lineNumber>2;
    symbol_table_index++;
    $<t.nd>$ = initNode("MoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
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
        $<t.lineNumber>$ = $<t.lineNumber>1;
        symbol_table_index++;
    }

    $<t.nd>$ = initNode("ArrayDeclaration");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("COLON");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("ARRAY");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    $<t.nd>4 = initNode("[");
    addNodetoTree($<t.nd>$,$<t.nd>4);
    $<t.nd>5 = initNode("INT_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>5);
    $<t.nd>6 = initNode("DOTDOT");
    addNodetoTree($<t.nd>$,$<t.nd>6);
    $<t.nd>7 = initNode("INT_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>7);
    $<t.nd>8 = initNode("]");
    addNodetoTree($<t.nd>$,$<t.nd>8);
    $<t.nd>9 = initNode("OF");
    addNodetoTree($<t.nd>$,$<t.nd>9);
    addNodetoTree($<t.nd>$,$<t.nd>10);
    $<t.nd>11 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>11);
}
; 

/* MAIN BODY OF THE PROGRAM */
BODY_OF_PROGRAM: BEGINK STATEMENTS END DOT {
    $<t.nd>$ = initNode("BodyOfProgram");
    $<t.nd>1 = initNode("BEGIN");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("END");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    $<t.nd>4 = initNode("DOT");
    addNodetoTree($<t.nd>$,$<t.nd>4);
}
;

/* ANY STATEMENTS INSIDE THE PROGRAM */
STATEMENTS: STATEMENT STATEMENTS {
    $<t.nd>$ = initNode("Statements");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| STATEMENT {
    $<t.nd>$ = initNode("Statements");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
;

/* STATEMENT THAT CAN BE READ, WRITE, ASSIGNMENT, CONDITIONAL AND LOOPING */
STATEMENT: READ_STATEMENT {
    $<t.nd>$ = initNode("Statement");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| WRITE_STATEMENT {
    $<t.nd>$ = initNode("Statement");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| ASSIGNMENT_STATEMENT {
    $<t.nd>$ = initNode("Statement");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| CONDITIONAL_STATEMENT {
    $<t.nd>$ = initNode("Statement");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| LOOPING_STATEMENT {
    $<t.nd>$ = initNode("Statement");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
;

/* READ STATEMENT */
READ_STATEMENT: READ LPAREN IDENTIFIER RPAREN SEMICOLON { 
    Symbol* symbol = findSymbol(symbol_table, $<t.id_name>3, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>3;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") != 0){
            CustomError2($<t.lineNumber>3, $<t.id_name>3, "Identifier not a variable");
        }
    }
    else{
        CustomError2($<t.lineNumber>3, $<t.id_name>3, "Variable not declared");
    }
    $<t.nd>$ = initNode("ReadStatement");
    $<t.nd>1 = initNode("READ");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("LPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    $<t.nd>4 = initNode("RPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>4);
    $<t.nd>5 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>5);
}
| READ LPAREN IDENTIFIER ARRAY_ADD_ON_ID RPAREN SEMICOLON { 
    Symbol* symbol = findSymbol(symbol_table, $<t.id_name>3, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>3;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "2") != 0){
            CustomError2($<t.lineNumber>3, $<t.id_name>3, "Identifier not an array");
        }
    }
    else{
        CustomError2($<t.lineNumber>3, $<t.id_name>3, "Array not declared");
    }
    $<t.nd>$ = initNode("ReadStatement");
    $<t.nd>1 = initNode("READ");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("LPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    addNodetoTree($<t.nd>$,$<t.nd>4);
    $<t.nd>5 = initNode("RPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>5);
    $<t.nd>6 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>6);
}
;

/* WRITE STATEMENT */
WRITE_STATEMENT: WRITE LPAREN WRITE_IDENTIFIER_LIST RPAREN SEMICOLON { $<t.lineNumber>$ = $<t.lineNumber>3; 
    $<t.nd>$ = initNode("WriteStatement");
    $<t.nd>1 = initNode("WRITE");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("LPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
    $<t.nd>4 = initNode("RPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>4);
    $<t.nd>5 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>5);
}
| WRITE_LN LPAREN WRITE_IDENTIFIER_LIST RPAREN SEMICOLON { $<t.lineNumber>$ = $<t.lineNumber>3; 
    $<t.nd>$ = initNode("WriteStatement");
    $<t.nd>1 = initNode("WRITE_LN");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("LPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
    $<t.nd>4 = initNode("RPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>4);
    $<t.nd>5 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>5);
}
;

WRITE_IDENTIFIER_LIST: IDENTIFIER {
    Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") != 0){
            CustomError2($<t.lineNumber>1, $<t.id_name>1, "Identifier not a variable");
        }
    }
    else{
        CustomError2($<t.lineNumber>1, $<t.id_name>1, "Variable not declared");
    }
    $<t.nd>$ = initNode("WriteIdentifierList");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| IDENTIFIER WRITE_MORE_IDENTIFIERS {
    Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") != 0){
            CustomError2($<t.lineNumber>1, $<t.id_name>1, "Identifier not a variable");
        }
    }
    else{
        CustomError2($<t.lineNumber>1, $<t.id_name>1, "Variable not declared");
    }
    $<t.nd>$ = initNode("WriteIdentifierList");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| IDENTIFIER ARRAY_ADD_ON_ID { 
    Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "2") == 0){
            if(checkIsArraySet(symbol_table, $<t.id_name>1, atoi($<t.val>2), symbol_table_index)){
                // printf("\n%s", symbol->array[atoi($<t.val>2)]);
            }
            else{
                CustomError3($<t.lineNumber>1, $<t.id_name>1, $<t.val>2, "Array index not set");
            }
        }
        else if(strcmp(symbol->varorarray, "1") == 0){
            CustomError2($<t.lineNumber>1, $<t.id_name>1, "Identifier not an array");
        }
    }
    else{
        CustomError2($<t.lineNumber>1, $<t.id_name>1, "Array not declared");
    }
    $<t.nd>$ = initNode("WriteIdentifierList");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| IDENTIFIER ARRAY_ADD_ON_ID WRITE_MORE_IDENTIFIERS { 
    Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "2") == 0){
            if(checkIsArraySet(symbol_table, $<t.id_name>1, atoi($<t.val>2), symbol_table_index)){
                // printf("\n%s", symbol->array[atoi($<t.val>2)]);
            }
            else{
                CustomError3($<t.lineNumber>1, $<t.id_name>1, $<t.val>2, "Array index not set");
            }
        }
        else if(strcmp(symbol->varorarray, "1") == 0){
            CustomError2($<t.lineNumber>1, $<t.id_name>1, "Identifier not an array");
        }
    }
    else{
        CustomError2($<t.lineNumber>1, $<t.id_name>1, "Array not declared");
    }
    $<t.nd>$ = initNode("WriteIdentifierList");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| STRING {
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(strcmp($<t.data_type>1, "string") != 0){
        CustomError1($<t.lineNumber>1, "Invalid data type for string");
    }    
    $<t.nd>$ = initNode("WriteIdentifierList");
    $<t.nd>1 = initNode("STRING");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| STRING WRITE_MORE_IDENTIFIERS {
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(strcmp($<t.data_type>1, "string") != 0){
        CustomError1($<t.lineNumber>1, "Invalid data type for string");
    } 
    $<t.nd>$ = initNode("WriteIdentifierList");
    $<t.nd>1 = initNode("STRING");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);   
}
| INT_NUMBER {
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(strcmp($<t.data_type>1, "int") != 0){
        CustomError1($<t.lineNumber>1, "Invalid data type for integer");
    }  
    $<t.nd>$ = initNode("WriteIdentifierList");
    $<t.nd>1 = initNode("INT_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>1);  
}
| INT_NUMBER WRITE_MORE_IDENTIFIERS {
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(strcmp($<t.data_type>1, "int") != 0){
        CustomError1($<t.lineNumber>1, "Invalid data type for integer");
    }    
    $<t.nd>$ = initNode("WriteIdentifierList");
    $<t.nd>1 = initNode("INT_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| DECIMAL_NUMBER {
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(strcmp($<t.data_type>1, "real") != 0){
        CustomError1($<t.lineNumber>1, "Invalid data type for real number");
    }  
    $<t.nd>$ = initNode("WriteIdentifierList");
    $<t.nd>1 = initNode("DECIMAL_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>1);  
}
| DECIMAL_NUMBER WRITE_MORE_IDENTIFIERS {
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(strcmp($<t.data_type>1, "real") != 0){
        CustomError1($<t.lineNumber>1, "Invalid data type for real number");
    } 
    $<t.nd>$ = initNode("WriteIdentifierList");
    $<t.nd>1 = initNode("DECIMAL_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);   
}
| CHARACTER {
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(strcmp($<t.data_type>1, "char") != 0){
        CustomError1($<t.lineNumber>1, "Invalid data type for character");
    } 
    $<t.nd>$ = initNode("WriteIdentifierList");
    $<t.nd>1 = initNode("CHARACTER");
    addNodetoTree($<t.nd>$,$<t.nd>1);   
}
| CHARACTER WRITE_MORE_IDENTIFIERS {
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(strcmp($<t.data_type>1, "char") != 0){
        CustomError1($<t.lineNumber>1, "Invalid data type for character");
    }  
    $<t.nd>$ = initNode("WriteIdentifierList");
    $<t.nd>1 = initNode("CHARACTER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);  
}
;

WRITE_MORE_IDENTIFIERS: COMMA IDENTIFIER { 
    Symbol* symbol = findSymbol(symbol_table, $<t.id_name>2, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") != 0){
            CustomError2($<t.lineNumber>2, $<t.id_name>2, "Identifier not a variable");
        }
    }
    else{
        CustomError2($<t.lineNumber>2, $<t.id_name>2, "Variable not declared");
    }
    $<t.nd>$ = initNode("WriteMoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| COMMA IDENTIFIER WRITE_MORE_IDENTIFIERS { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>2, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") != 0){
            CustomError2($<t.lineNumber>2, $<t.id_name>2, "Identifier not a variable");
        }
    }
    else{
        CustomError2($<t.lineNumber>2, $<t.id_name>2, "Variable not declared");
    }
    $<t.nd>$ = initNode("WriteMoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
| COMMA IDENTIFIER ARRAY_ADD_ON_ID { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>2, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "2") == 0){
            if(checkIsArraySet(symbol_table, $<t.id_name>2, atoi($<t.val>3), symbol_table_index)){
                // printf("\n%s", symbol->array[atoi($<t.val>2)]);
            }
            else{
                CustomError3($<t.lineNumber>1, $<t.id_name>2, $<t.val>3, "Array index not set");
            }
        }
        else if(strcmp(symbol->varorarray, "1") == 0){
            CustomError2($<t.lineNumber>1, $<t.id_name>2, "Identifier not an array");
        }
    }
    else{
        CustomError2($<t.lineNumber>2, $<t.id_name>2, "Array not declared");
    }
    $<t.nd>$ = initNode("WriteMoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
| COMMA IDENTIFIER ARRAY_ADD_ON_ID WRITE_MORE_IDENTIFIERS { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>2, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "2") == 0){
            if(checkIsArraySet(symbol_table, $<t.id_name>2, atoi($<t.val>3), symbol_table_index)){
                // printf("\n%s", symbol->array[atoi($<t.val>2)]);
            }
            else{
                CustomError3($<t.lineNumber>1, $<t.id_name>2, $<t.val>3, "Array index not set");
            }
        }
        else if(strcmp(symbol->varorarray, "1") == 0){
            CustomError2($<t.lineNumber>1, $<t.id_name>2, "Identifier not an array");
        }
    }
    else{
        CustomError2($<t.lineNumber>2, $<t.id_name>2, "Array not declared");
    }
    $<t.nd>$ = initNode("WriteMoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
    addNodetoTree($<t.nd>$,$<t.nd>4);
}
| COMMA STRING {
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(strcmp($<t.data_type>2, "string") != 0){
        CustomError1($<t.lineNumber>2, "Invalid data type for string");
    }   
    $<t.nd>$ = initNode("WriteMoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("STRING");
    addNodetoTree($<t.nd>$,$<t.nd>2); 
}
| COMMA STRING WRITE_MORE_IDENTIFIERS {
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(strcmp($<t.data_type>2, "string") != 0){
        CustomError1($<t.lineNumber>2, "Invalid data type for string");
    }   
    $<t.nd>$ = initNode("WriteMoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("STRING"); 
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
| COMMA INT_NUMBER {
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(strcmp($<t.data_type>2, "int") != 0){
        CustomError1($<t.lineNumber>2, "Invalid data type for integer");
    }  
    $<t.nd>$ = initNode("WriteMoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("INT_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| COMMA INT_NUMBER WRITE_MORE_IDENTIFIERS {
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(strcmp($<t.data_type>2, "int") != 0){
        CustomError1($<t.lineNumber>2, "Invalid data type for integer");
    }   
    $<t.nd>$ = initNode("WriteMoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("INT_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3); 
}
| COMMA DECIMAL_NUMBER {
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(strcmp($<t.data_type>2, "real") != 0){
        CustomError1($<t.lineNumber>2, "Invalid data type for real number");
    }  
    $<t.nd>$ = initNode("WriteMoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("DECIMAL_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>2);  
}
| COMMA DECIMAL_NUMBER WRITE_MORE_IDENTIFIERS {
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(strcmp($<t.data_type>2, "real") != 0){
        CustomError1($<t.lineNumber>2, "Invalid data type for real number");
    } 
    $<t.nd>$ = initNode("WriteMoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("DECIMAL_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);   
}
| COMMA CHARACTER {
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(strcmp($<t.data_type>2, "char") != 0){
        CustomError1($<t.lineNumber>2, "Invalid data type for character");
    }  
    $<t.nd>$ = initNode("WriteMoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("CHARACTER");
    addNodetoTree($<t.nd>$,$<t.nd>2);  
}
| COMMA CHARACTER WRITE_MORE_IDENTIFIERS {
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(strcmp($<t.data_type>2, "char") != 0){
        CustomError1($<t.lineNumber>2, "Invalid data type for character");
    }  
    $<t.nd>$ = initNode("WriteMoreIdentifiers");
    $<t.nd>1 = initNode("COMMA");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("CHARACTER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);  
}
;

/* ASSIGNMENT */
ASSIGNMENT_STATEMENT: IDENTIFIER COLON EQUAL ANY_EXPRESSION SEMICOLON { 
    Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") == 0){
            symbol->isVarSet = 1;
            if(strcmp(symbol->data_type, $<t.data_type>4) == 0){
                // strcpy(symbol->val, $<t.val>4);
            }
            else{
                CustomError2($<t.lineNumber>1, $<t.id_name>1, "Invalid data type for assignment");
            }
        }
        else if(strcmp(symbol->varorarray, "2") == 0){
            CustomError2($<t.lineNumber>1, $<t.id_name>1, "Identifier not a variable");
        }
    }
    else{
        CustomError2($<t.lineNumber>1, $<t.id_name>1, "Variable not declared");
    }
    $<t.nd>$ = initNode("AssignmentStatement");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("COLON");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("EQUAL");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    $<t.nd>4 = initNode("ANY_EXPRESSION");
    addNodetoTree($<t.nd>$,$<t.nd>4);
    $<t.nd>5 = initNode("SEMICOLON");
}
| IDENTIFIER ARRAY_ADD_ON_ID COLON EQUAL ANY_EXPRESSION SEMICOLON { 
    Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "2") == 0){
            if(strcmp($<t.data_type>2, "int") == 0){
                if(strcmp(symbol->data_type, $<t.data_type>5) == 0){
                    symbol->isArraySet[atoi($<t.val>2)] = 1;
                }
                else{
                    CustomError2($<t.lineNumber>1, $<t.id_name>1, "Invalid data type for assignment");
                }
            }
            else{
                CustomError1($<t.lineNumber>1, "Array index must be integer");
            }
        }
        else if(strcmp(symbol->varorarray, "1") == 0){
            CustomError2($<t.lineNumber>1, $<t.id_name>1, "Identifier not an array");
        }
    }
    else{
        CustomError2($<t.lineNumber>1, $<t.id_name>1, "Array not declared");
    }
    $<t.nd>$ = initNode("AssignmentStatement");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("COLON");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    $<t.nd>4 = initNode("EQUAL");
    addNodetoTree($<t.nd>$,$<t.nd>4);
    addNodetoTree($<t.nd>$,$<t.nd>5);
    $<t.nd>6 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>6);
}
| IDENTIFIER COLON EQUAL CHARACTER SEMICOLON { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") == 0){
            symbol->isVarSet = 1;
            if(strcmp(symbol->data_type, "char") == 0){
                // strcpy(symbol->val, $<t.val>4);
            }
            else{
                CustomError2($<t.lineNumber>1, $<t.id_name>1, "Invalid data type for assignment");
            }
        }
        else if(strcmp(symbol->varorarray, "2") == 0){
            CustomError2($<t.lineNumber>1, $<t.id_name>1, "Identifier not a variable");
        }
    }
    else{
        CustomError2($<t.lineNumber>1, $<t.id_name>1, "Variable not declared");
    }
    $<t.nd>$ = initNode("AssignmentStatement");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("COLON");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("EQUAL");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    $<t.nd>4 = initNode("CHARACTER");
    addNodetoTree($<t.nd>$,$<t.nd>4);
    $<t.nd>5 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>5);
}
;

/* CONDITIONAL STATEMENT */
CONDITIONAL_STATEMENT: IF ANY_EXPRESSION THEN BODY_OF_CONDITIONAL ELSE BODY_OF_CONDITIONAL SEMICOLON {
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(strcmp($<t.data_type>2, "boolean") != 0){
        CustomError1($<t.lineNumber>2, "Invalid data type for if-else condition");
    }
    $<t.nd>$ = initNode("ConditionalStatement");
    $<t.nd>1 = initNode("IF");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("THEN");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    addNodetoTree($<t.nd>$,$<t.nd>4);
    $<t.nd>5 = initNode("ELSE");
    addNodetoTree($<t.nd>$,$<t.nd>5);
    addNodetoTree($<t.nd>$,$<t.nd>6);
    $<t.nd>7 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>7);
}
| IF ANY_EXPRESSION THEN BODY_OF_CONDITIONAL SEMICOLON {
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(strcmp($<t.data_type>2, "boolean") != 0){
        CustomError1($<t.lineNumber>2, "Invalid data type for if condition");
    }
    $<t.nd>$ = initNode("ConditionalStatement");
    $<t.nd>1 = initNode("IF");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("THEN");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    addNodetoTree($<t.nd>$,$<t.nd>4);
    $<t.nd>5 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>5);
}
;

BODY_OF_CONDITIONAL: BEGINK STATEMENTS_INSIDE_CONDITIONAL END {
    $<t.nd>$ = initNode("BodyOfConditional");
    $<t.nd>1 = initNode("BEGINK");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("END");
}
;

STATEMENTS_INSIDE_CONDITIONAL: STATEMENT_INSIDE_CONDITIONAL STATEMENTS_INSIDE_CONDITIONAL {
    $<t.nd>$ = initNode("StatementsInsideConditional");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| STATEMENT_INSIDE_CONDITIONAL {
    $<t.nd>$ = initNode("StatementsInsideConditional");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
;

/* EXPRESSION FORMULATION */
ANY_EXPRESSION: EXPRESSION_SEQUENCE { strcpy($<t.data_type>$, $<t.data_type>1); $<t.lineNumber>$ = $<t.lineNumber>1; 
$<t.nd>$ = initNode("AnyExpression"); addNodetoTree($<t.nd>$,$<t.nd>1); }
| EXPRESSION_SEQUENCE RELOP EXPRESSION_SEQUENCE {
    $<t.lineNumber>$ = $<t.lineNumber>1;
    strcpy($<t.data_type>$, "boolean");
    if(((strcmp($<t.data_type>1, "int") == 0) || (strcmp($<t.data_type>1, "real") == 0)) && 
    ((strcmp($<t.data_type>3, "int") == 0) || (strcmp($<t.data_type>3, "real") == 0))){}
    else if((($<t.data_type>1 == "char") || ($<t.data_type>1 == "string")) && 
    (($<t.data_type>3 == "char") || ($<t.data_type>3 == "string"))){}       
    else{
        CustomError1($<t.lineNumber>1, "Invalid data type for relational expressions");
        printf("\n%s %s", $<t.data_type>1, $<t.data_type>3);
    }
    $<t.nd>$ = initNode("AnyExpression");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
 }
| LPAREN EXPRESSION_SEQUENCE RELOP EXPRESSION_SEQUENCE RPAREN {
    $<t.lineNumber>$ = $<t.lineNumber>1;
    strcpy($<t.data_type>$, "boolean");
    if(((strcmp($<t.data_type>2, "int") == 0) || 
        (strcmp($<t.data_type>2, "real") == 0)) 
        && 
        ((strcmp($<t.data_type>4, "int") == 0) || 
        (strcmp($<t.data_type>4, "real") == 0))){}
    else if((($<t.data_type>2 == "char") || 
        ($<t.data_type>2 == "string")) 
        && 
        (($<t.data_type>4 == "char") || 
        ($<t.data_type>4 == "string"))){}       
    else{
        CustomError1($<t.lineNumber>1, "Invalid data type for relational expressions");
        printf("\n%s %s", $<t.data_type>1, $<t.data_type>3);
    }
    $<t.nd>$ = initNode("AnyExpression");
    $<t.nd>1 = initNode("LPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
    addNodetoTree($<t.nd>$,$<t.nd>4);
    $<t.nd>5 = initNode("RPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>5);
 }
| BOOLEAN_EXPRESSION_SEQUENCE { $<t.lineNumber>$ = $<t.lineNumber>1; strcpy($<t.data_type>$, $<t.data_type>1);
$<t.nd>$ = initNode("AnyExpression"); addNodetoTree($<t.nd>$,$<t.nd>1); }
; 

EXPRESSION_SEQUENCE: TERM { 
    strcpy($<t.data_type>$, $<t.data_type>1); $<t.lineNumber>$ = $<t.lineNumber>1; 
    $<t.nd>$ = initNode("ExpressionSequence"); 
    addNodetoTree($<t.nd>$,$<t.nd>1);
    }
| EXPRESSION_SEQUENCE PLUS EXPRESSION_SEQUENCE { 
    // printf("\n%s + %s", $<t.data_type>1, $<t.data_type>3);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>3, "int") == 0)){
        strcpy($<t.data_type>$, "int");    
    } 
    else if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>3, "real") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "real") == 0) && (strcmp($<t.data_type>3, "int") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "char") == 0) || 
            (strcmp($<t.data_type>3, "char")  == 0) || 
            (strcmp($<t.data_type>1, "string")  == 0) || 
            (strcmp($<t.data_type>3, "string")  == 0)){
        // printf("%s %s", $<t.data_type>1, $<t.data_type>3);
        CustomError1($<t.lineNumber>1, "Invalid data type for addition");
    }
    else{
        CustomError1($<t.lineNumber>1, "Invalid data type for addition");
    }
    $<t.nd>$ = initNode("ExpressionSequence");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("PLUS");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
| EXPRESSION_SEQUENCE MINUS EXPRESSION_SEQUENCE { 
    // printf("\n%s - %s", $<t.data_type>1, $<t.data_type>3);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>3, "int") == 0)){
        strcpy($<t.data_type>$, "int");    
    } 
    else if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>3, "real") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "real") == 0) && (strcmp($<t.data_type>3, "int") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if(
        (strcmp($<t.data_type>1, "char") == 0) ||
        (strcmp($<t.data_type>3, "char")  == 0) ||
        (strcmp($<t.data_type>1, "string")  == 0) ||
        (strcmp($<t.data_type>3, "string")  == 0)
    ){
        CustomError1($<t.lineNumber>1, "Invalid data type for subtraction, found character");
    }
    else{
        CustomError1($<t.lineNumber>1, "Invalid data type for subtraction");
    }
    $<t.nd>$ = initNode("ExpressionSequence");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("MINUS");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
| EXPRESSION_SEQUENCE MULTIPLY EXPRESSION_SEQUENCE { 
    // printf("\n%s * %s", $<t.data_type>1, $<t.data_type>3);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>3, "int") == 0)){
        strcpy($<t.data_type>$, "int");    
    } 
    else if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>3, "real") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "real") == 0) && (strcmp($<t.data_type>3, "int") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "char") == 0) || 
            (strcmp($<t.data_type>3, "char")  == 0) || 
            (strcmp($<t.data_type>1, "string")  == 0) || 
            (strcmp($<t.data_type>3, "string")  == 0)){
        CustomError1($<t.lineNumber>1, "Invalid data type for multiplication");
    }
    else{
        CustomError1($<t.lineNumber>1, "Invalid data type for multiplication");
    }
    $<t.nd>$ = initNode("ExpressionSequence");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("MULTIPLY");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
| EXPRESSION_SEQUENCE DIVIDE EXPRESSION_SEQUENCE { 
    // printf("\n%s / %s", $<t.data_type>1, $<t.data_type>3);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>3, "int") == 0)){
        strcpy($<t.data_type>$, "real");    
    } 
    else if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>3, "real") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "real") == 0) && (strcmp($<t.data_type>3, "int") == 0)){
        strcpy($<t.data_type>$, "real");
    }
    else if((strcmp($<t.data_type>1, "char") == 0) || 
            (strcmp($<t.data_type>3, "char")  == 0) || 
            (strcmp($<t.data_type>1, "string")  == 0) || 
            (strcmp($<t.data_type>3, "string")  == 0)){
        CustomError1($<t.lineNumber>1, "Invalid data type for division");
    }
    else{
        CustomError1($<t.lineNumber>1, "Invalid data type for division");
    }
    $<t.nd>$ = initNode("ExpressionSequence");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("DIVIDE");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
| EXPRESSION_SEQUENCE MOD EXPRESSION_SEQUENCE { 
    // printf("\n%s %s", $<t.data_type>1, $<t.data_type>3);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>3, "int") == 0)){
        strcpy($<t.data_type>$, "int");    
    } 
    else if((strcmp($<t.data_type>1, "int") == 0) && (strcmp($<t.data_type>3, "real") == 0)){
        CustomError1($<t.lineNumber>1, "Invalid data type for mod");
    }
    else if((strcmp($<t.data_type>1, "real") == 0) && (strcmp($<t.data_type>3, "int") == 0)){
        CustomError1($<t.lineNumber>1, "Invalid data type for mod");
    }
    else if((strcmp($<t.data_type>1, "char") == 0) || 
            (strcmp($<t.data_type>3, "char")  == 0) || 
            (strcmp($<t.data_type>1, "string")  == 0) || 
            (strcmp($<t.data_type>3, "string")  == 0)){
        CustomError1($<t.lineNumber>1, "Invalid data type for mod");
    }
    else{
        CustomError1($<t.lineNumber>1, "Invalid data type for mod");
    }
    $<t.nd>$ = initNode("ExpressionSequence");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("MOD");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
| MINUS EXPRESSION_SEQUENCE { 
    // printf("\n- %s", $<t.data_type>2);
    $<t.lineNumber>$ = $<t.lineNumber>2; 
    if(strcmp($<t.data_type>2, "boolean") == 0){
        CustomError1($<t.lineNumber>2, "Invalid data type for -ve expression");
    }
    strcpy($<t.data_type>$, $<t.data_type>2); 
    $<t.nd>$ = initNode("ExpressionSequence");
    $<t.nd>1 = initNode("MINUS");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| LPAREN EXPRESSION_SEQUENCE RPAREN { 
    strcpy($<t.data_type>$, $<t.data_type>2); 
    $<t.lineNumber>$ = $<t.lineNumber>2; 
    $<t.nd>$ = initNode("ExpressionSequence");
    $<t.nd>1 = initNode("LPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("RPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
;

BOOLEAN_EXPRESSION_SEQUENCE: NOT ANY_EXPRESSION { 
    $<t.lineNumber>$ = $<t.lineNumber>2;
    strcpy($<t.data_type>$, "boolean");
    if(strcmp($<t.data_type>2, "boolean") != 0){
        CustomError1($<t.lineNumber>1, "Invalid data type for boolean expressions");
    }
    $<t.nd>$ = initNode("BooleanExpressionSequence");
    $<t.nd>1 = initNode("NOT");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| ANY_EXPRESSION AND ANY_EXPRESSION {
    $<t.lineNumber>$ = $<t.lineNumber>1;
    strcpy($<t.data_type>$, "boolean");
    if((strcmp($<t.data_type>1, "boolean") != 0) || (strcmp($<t.data_type>3, "boolean") != 0)){
        CustomError1($<t.lineNumber>1, "Invalid data type for boolean expressions");
    }
    $<t.nd>$ = initNode("BooleanExpressionSequence");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("AND");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
| ANY_EXPRESSION OR ANY_EXPRESSION {
    $<t.lineNumber>$ = $<t.lineNumber>2;
    strcpy($<t.data_type>$, "boolean");
    if((strcmp($<t.data_type>1, "boolean") != 0) || (strcmp($<t.data_type>3, "boolean") != 0)){
        CustomError1($<t.lineNumber>1, "Invalid data type for boolean expressions");
    }
    $<t.nd>$ = initNode("BooleanExpressionSequence");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("OR");
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| LPAREN BOOLEAN_EXPRESSION_SEQUENCE RPAREN {
    $<t.lineNumber>$ = $<t.lineNumber>2;
    strcpy($<t.data_type>$, "boolean");
    if(strcmp($<t.data_type>2, "boolean") != 0){
        CustomError1($<t.lineNumber>1, "Invalid data type for boolean expressions");
    }
    $<t.nd>$ = initNode("BooleanExpressionSequence");
    $<t.nd>1 = initNode("LPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("RPAREN");
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
;

TERM: IDENTIFIER { 
    Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index); 
    strcpy($<t.id_name>$, $<t.id_name>1);
    $<t.lineNumber>$ = $<t.lineNumber>1;
    strcpy($<t.data_type>$, symbol->data_type);
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") == 0){
            if(checkIsVarSet(symbol_table, $<t.id_name>1, symbol_table_index)){
                strcpy($<t.val>$, symbol->val);
                strcpy($<t.data_type>$, symbol->data_type);
            }
            else{
                strcpy($<t.data_type>$, symbol->data_type);
                strcpy($<t.data_type>1, symbol->data_type);
                CustomError2($<t.lineNumber>1, $<t.id_name>1, "Variable not set");
            }
        }
        else if(strcmp(symbol->varorarray, "2") == 0){
            // printf("\nArray < %s > found", $<t.id_name>1);
            CustomError2($<t.lineNumber>1, $<t.id_name>1, "Array found in expression instead of Variable");
        }
    }
    else{
        // printf("\nIdentifier < %s > not found", $<t.id_name>1);
        CustomError2($<t.lineNumber>1, $<t.id_name>1, "Variable not declared");
    }
    $<t.nd>$ = initNode("Term");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}

| IDENTIFIER ARRAY_ADD_ON_ID { Symbol* symbol = findSymbol(symbol_table, $<t.id_name>1, symbol_table_index); 
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(symbol != NULL){
        if(strcmp(symbol->varorarray, "1") == 0){
            // printf("\nVariable < %s > found", $<t.id_name>1);
            CustomError2($<t.lineNumber>1, $<t.id_name>1, "Variable found in expression instead of array");
        }
        else if(strcmp(symbol->varorarray, "2") == 0){
            // printf("\nArray < %s > found", $<t.id_name>1);
            if(checkIsArraySet(symbol_table, $<t.id_name>1, atoi($<t.val>2), symbol_table_index)){
                strcpy($<t.val>$, symbol->array[atoi($<t.val>2)]);
                strcpy($<t.data_type>$, symbol->data_type);
            }
            else{
                // printf("\nArray index not set for < %s >", $<t.id_name>1);
                CustomError3($<t.lineNumber>1, $<t.id_name>1, $<t.val>2, "Array index not set");
            }
        }
    }
    else{
        // printf("\nIdentifier < %s > not found", $<t.id_name>1);
        CustomError1($<t.lineNumber>1, "Array not declared");
    
    }
    $<t.nd>$ = initNode("Term");
    $<t.nd>1 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| INT_NUMBER { 
    strcpy($<t.val>$, $<t.val>1); 
    strcpy($<t.data_type>$, $<t.data_type>1); 
    $<t.lineNumber>$ = $<t.lineNumber>1; 
    $<t.nd>$ = initNode("Term");
    $<t.nd>1 = initNode("INT_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| DECIMAL_NUMBER { 
    strcpy($<t.val>$, $<t.val>1);
    strcpy($<t.data_type>$, $<t.data_type>1); 
    $<t.lineNumber>$ = $<t.lineNumber>1; 
    $<t.nd>$ = initNode("Term");
    $<t.nd>1 = initNode("DECIMAL_NUMBER");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
;

STATEMENT_INSIDE_CONDITIONAL: READ_STATEMENT {
    $<t.nd>$ = initNode("StatementInsideConditional");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| WRITE_STATEMENT {
    $<t.nd>$ = initNode("StatementInsideConditional");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| ASSIGNMENT_STATEMENT {
    $<t.nd>$ = initNode("StatementInsideConditional");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| LOOPING_STATEMENT {
    $<t.nd>$ = initNode("StatementInsideConditional");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
;

/* LOOPING STATEMENT */
LOOPING_STATEMENT: WHILE_LOOP {
    $<t.nd>$ = initNode("LoopingStatement");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| FOR_LOOP_TO {
    $<t.nd>$ = initNode("LoopingStatement");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| FOR_LOOP_DOWNTO {
    $<t.nd>$ = initNode("LoopingStatement");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
;

WHILE_LOOP: WHILE ANY_EXPRESSION DO BODY_OF_LOOP SEMICOLON { 
    $<t.lineNumber>$ = $<t.lineNumber>1;
    if(strcmp($<t.data_type>2, "boolean") != 0){
        CustomError1($<t.lineNumber>1, "Invalid data type for while condition");
    }
    $<t.nd>$ = initNode("WhileLoop");
    $<t.nd>1 = initNode("WHILE");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("DO");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    addNodetoTree($<t.nd>$,$<t.nd>4);
    $<t.nd>5 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>5);
}
;

FOR_LOOP_TO: FOR IDENTIFIER COLON EQUAL EXPRESSION_SEQUENCE TO EXPRESSION_SEQUENCE DO BODY_OF_LOOP SEMICOLON {
    Symbol* symbol = findSymbol(symbol_table, $<t.id_name>2, symbol_table_index); 
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(symbol != NULL){
        if(strcmp($<t.data_type>5, $<t.data_type>7) == 0){
            {
                if(strcmp(symbol->data_type, $<t.data_type>5) == 0){
                    symbol->isVarSet = 1;
                    strcpy(symbol->val, $<t.val>5);
                }
                else{
                    CustomError2($<t.lineNumber>2, $<t.id_name>2, "Invalid data type for forloop initialization");
                }
            }
        }
        else{
            CustomError1($<t.lineNumber>2, "Limits of for loop aren't of the same data type");
        }
    }
    else{
        CustomError2($<t.lineNumber>2, $<t.id_name>2, "Array not declared");
    }
    $<t.nd>$ = initNode("ForLoopTo");
    $<t.nd>1 = initNode("FOR");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("COLON");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    $<t.nd>4 = initNode("EQUAL");
    addNodetoTree($<t.nd>$,$<t.nd>4);
    addNodetoTree($<t.nd>$,$<t.nd>5);
    $<t.nd>6 = initNode("TO");
    addNodetoTree($<t.nd>$,$<t.nd>6);
    addNodetoTree($<t.nd>$,$<t.nd>7);
    $<t.nd>8 = initNode("DO");
    addNodetoTree($<t.nd>$,$<t.nd>8);
    addNodetoTree($<t.nd>$,$<t.nd>9);
    $<t.nd>10 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>10);
}
;

FOR_LOOP_DOWNTO: FOR IDENTIFIER COLON EQUAL EXPRESSION_SEQUENCE DOWNTO EXPRESSION_SEQUENCE DO BODY_OF_LOOP SEMICOLON {
    Symbol* symbol = findSymbol(symbol_table, $<t.id_name>2, symbol_table_index); 
    $<t.lineNumber>$ = $<t.lineNumber>2;
    if(symbol != NULL){
        if(strcmp($<t.data_type>5, $<t.data_type>7) == 0){
            {
                if(strcmp(symbol->data_type, $<t.data_type>5) == 0){
                    symbol->isVarSet = 1;
                    strcpy(symbol->val, $<t.val>5);
                }
                else{
                    CustomError2($<t.lineNumber>2, $<t.id_name>2, "Invalid data type for forloop initialization");
                }
            }
        }
        else{
            CustomError1($<t.lineNumber>2, "Limits of for loop aren't of the same data type");
        }
    }
    else{
        CustomError2($<t.lineNumber>2, $<t.id_name>2, "Array not declared");
    }
    $<t.nd>$ = initNode("ForLoopDownTo");
    $<t.nd>1 = initNode("FOR");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    $<t.nd>2 = initNode("IDENTIFIER");
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("COLON");
    addNodetoTree($<t.nd>$,$<t.nd>3);
    $<t.nd>4 = initNode("EQUAL");
    addNodetoTree($<t.nd>$,$<t.nd>4);
    addNodetoTree($<t.nd>$,$<t.nd>5);
    $<t.nd>6 = initNode("DOWNTO");
    addNodetoTree($<t.nd>$,$<t.nd>6);
    addNodetoTree($<t.nd>$,$<t.nd>7);
    $<t.nd>8 = initNode("DO");
    addNodetoTree($<t.nd>$,$<t.nd>8);
    addNodetoTree($<t.nd>$,$<t.nd>9);
    $<t.nd>10 = initNode("SEMICOLON");
    addNodetoTree($<t.nd>$,$<t.nd>10);
}
;

BODY_OF_LOOP: BEGINK STATEMENTS_INSIDE_LOOP END {
    $<t.nd>$ = initNode("BodyOfLoop");
    $<t.nd>1 = initNode("BEGINK");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
    $<t.nd>3 = initNode("END");
    addNodetoTree($<t.nd>$,$<t.nd>3);
}
;

STATEMENTS_INSIDE_LOOP: STATEMENT_INSIDE_LOOP STATEMENTS_INSIDE_LOOP {
    $<t.nd>$ = initNode("StatementsInsideLoop");
    addNodetoTree($<t.nd>$,$<t.nd>1);
    addNodetoTree($<t.nd>$,$<t.nd>2);
}
| STATEMENT_INSIDE_LOOP {
    $<t.nd>$ = initNode("StatementsInsideLoop");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
;

STATEMENT_INSIDE_LOOP: READ_STATEMENT {
    $<t.nd>$ = initNode("StatementInsideLoop");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| WRITE_STATEMENT {
    $<t.nd>$ = initNode("StatementInsideLoop");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| ASSIGNMENT_STATEMENT {
    $<t.nd>$ = initNode("StatementInsideLoop");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
| CONDITIONAL_STATEMENT {
    $<t.nd>$ = initNode("StatementInsideLoop");
    addNodetoTree($<t.nd>$,$<t.nd>1);
}
;

%%

void addVar(Symbol** symbol_table, int symbol_table_index, char new_id_name[], char new_data_type[], char new_varorarray[]){
    if (!check(symbol_table, new_id_name, symbol_table_index))
    {
        strcpy(symbol_table[symbol_table_index]->id_name, new_id_name);
        strcpy(symbol_table[symbol_table_index]->data_type, new_data_type);
        strcpy(symbol_table[symbol_table_index]->varorarray, new_varorarray); 
    }
}

void addVarName(Symbol** symbol_table, int symbol_table_index, char new_id_name[], char new_varorarray[]){
    if(!check(symbol_table, new_id_name, symbol_table_index))
    {
        strcpy(symbol_table[symbol_table_index]->id_name, new_id_name);
        strcpy(symbol_table[symbol_table_index]->varorarray, new_varorarray);     
    }
}

bool check(Symbol** symbol_table, char new_id_name[], int symbol_table_index){
    for(int i = 0; i < symbol_table_index; i++){
        if(strcmp(symbol_table[i]->id_name, new_id_name) == 0){        
            /* printf("\nVariable < %s > already declared", new_id_name); */
            /* printf("Exiting..."); */
            printf("\n\nVariable < %s > already declared", new_id_name);
        }
    }
    return false;
}

void enterDataTypeIntoSymbolTable(Symbol** symbol_table, char data_type[10], int symbol_table_index){
    /* printf("enter called"); */
    for(int i = 0; i < symbol_table_index; i++){
        /* printf("\n%s", symbol_table[i]->data_type); */
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

void printSymbolTable(){
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
        /* if(printLogs) printf("\nFile not found"); */
        exit(1);
    }
    else{
        /* if(printLogs) printf("\nInput file found, Parsing...."); */
        yyparse();
    }
    printSymbolTable();
    printTree(head);

    FILE *file_ptr;
    file_ptr = fopen("syntaxtree.txt", "w");
    if (file_ptr == NULL) {
        printf("Error opening the file.\n");
    }
    fprintf(file_ptr, "%s", TreeInString);
    fclose(file_ptr);
    printf("\n\n\n%s", TreeInString);
}

struct Treenode* initNode(char *label)
{
	struct Treenode *new = (struct Treenode*)malloc(sizeof(struct Treenode));
	char *newstr = (char *)malloc(strlen(label)+1);
	strcpy(newstr,label);
	new->name=newstr;
    
    for(int i=0;i<30;i++)
    {
        new->child[i]=NULL;
    }
    new->child_index=0;
	return (new);
}

void addNodetoTree(struct Treenode *parent, struct Treenode *child)
{
    parent->child[parent->child_index]=child;
    parent->child_index++;
}

void printTree(struct Treenode *tree)
{
	if(tree==NULL)
    {
        return;
    }

    TreeInString[TreeInStringIndex] = '[';
    TreeInStringIndex++;

    for(int i=TreeInStringIndex; i<TreeInStringIndex+strlen(tree->name); i++)
    {
        TreeInString[i] = tree->name[i-TreeInStringIndex];
    }
    TreeInStringIndex += strlen(tree->name);

    for(int i=0;i<tree->child_index;i++)
    {
        printTree(tree->child[i]);
    }

    TreeInString[TreeInStringIndex] = ']';
    TreeInStringIndex++;
}

int yyerror(){
    printf("\n\n\nSyntax error found");
    return 0;
}

void CustomError1(int lineNumber, char* message){
    printf("\n\nLine: %d ::> %s", lineNumber, message);
    /* printSymbolTable(); */
}

void CustomError2(int lineNumber, char* id_name, char* message){
    printf("\n\nLine: %d ::> %s -> %s", lineNumber, id_name, message);
    /* printSymbolTable(); */
}

void CustomError3(int lineNumber, char* id_name, char* index, char* message){
    printf("\n\nLine: %d ::> %s[%s] -> %s", lineNumber, id_name, index, message);
    /* printSymbolTable(); */
}