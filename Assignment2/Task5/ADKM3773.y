%{
#include <cstdlib>
#include <cstring>
#include <cctype>
#include <iostream>
#include <unordered_map>
#include <variant>
#include <vector>
#include <queue>
#include <stack>
#include <fstream>

int yylex(void);
int yyerror(const char* s);
extern FILE *yyin;
extern int yylineno;

int printLogs = 0;
int yydebug = 1;

int count=0;
int quadrupleIndex=0;
int tos=-1;
int temp_char=0;

struct quadruple{
    char op[100];
    char operand1[100];
    char operand2[100];
    char result[100];
} quad[1000];

struct stack {
    char c[100]; 
} stac[1000];

template <typename T>
struct Array {
    std::vector<T> array;
    int offset;
};

void addQuadruple(char op1[], char op[], char op2[], char result[]) {
    strcpy(quad[quadrupleIndex].op, op);
    strcpy(quad[quadrupleIndex].operand1, op1);
    strcpy(quad[quadrupleIndex].operand2, op2);
    strcpy(quad[quadrupleIndex].result, result);
    quadrupleIndex++;
}

using VariantType = std::variant<int, float, char, bool>;
using ArrayType = struct Array<VariantType>;

std::unordered_map<std::string, std::variant<int, float, char, bool, ArrayType>> interpreterSymbolTable;

void updateIST(std::string symbol, std::variant<int, float, char, bool, ArrayType> value) {
    interpreterSymbolTable[symbol] = value;
}

template<class... Ts> struct overloaded : Ts... { using Ts::operator()...; };
template<class... Ts> overloaded(Ts...) -> overloaded<Ts...>;

std::variant<int, float, char, bool, ArrayType> getIST(std::string symbol) {
    char array_name[100];
    char array_index[100];
    if (sscanf(symbol.c_str(), "%[^[][%[^]]]", array_name, array_index) == 2) {
        ArrayType array = std::get<ArrayType>(getIST(array_name));

        int index = 0;
        if (interpreterSymbolTable.find(array_index) != interpreterSymbolTable.end()) {
            index = std::get<int>(interpreterSymbolTable[array_index]);
        } else {
            index = std::stoi(array_index);
        }

        return std::visit(overloaded {
            [](const int& i) { return std::variant<int, float, char, bool, ArrayType>(i); },
            [](const float& f) { return std::variant<int, float, char, bool, ArrayType>(f); },
            [](const char& c) { return std::variant<int, float, char, bool, ArrayType>(c); },
            [](const bool& b) { return std::variant<int, float, char, bool, ArrayType>(b); },
            [](const ArrayType& a) { return std::variant<int, float, char, bool, ArrayType>(a); }
        }, array.array[index - array.offset]);
    }

    if (symbol == "NA") {
        return 0; // TODO: deal with float case
    }

    // Check if symbol can be converted to an integer
    char* end;
    long int_value = std::strtol(symbol.c_str(), &end, 10);
    if (end != symbol.c_str() && *end == '\0') {
        return static_cast<int>(int_value);
    }

    // Check if symbol can be converted to a float
    char* end2;
    float float_value = std::strtof(symbol.c_str(), &end2);
    if (end2 != symbol.c_str() && *end2 == '\0') {
        return static_cast<float>(float_value);
    }

    if (interpreterSymbolTable.find(symbol) != interpreterSymbolTable.end()) {
        return interpreterSymbolTable[symbol];
    } else {
        std::string error_message = "Symbol '" + symbol + "' not found in symbol table";
        yyerror(error_message.c_str());
        return 0;
    }
}

void printArray(const ArrayType& arr) {
    std::cout << "[";
    for (size_t i = 0; i < arr.array.size(); i++) {
        const auto& elem = arr.array[i];
        std::visit(overloaded {
            [](const int& j) { std::cout << j; },
            [](const float& f) { std::cout << f; },
            [](const char& c) { std::cout << c; },
            [](const bool& b) { std::cout << std::boolalpha << b; },
            [](const ArrayType& a) { printArray(a); }
        }, elem);
        if (i != arr.array.size() - 1) {
            std::cout << ", ";
        }
    }
    std::cout << "]";
}


void printIST() {
    int max_length = 7;
    for (auto& it: interpreterSymbolTable) {
        if (it.first.length() > max_length) {
            max_length = it.first.length();
        }
    }

    std::cout << std::endl;
    std::cout << "\033[1;37m" << "ID Name" << std::string(max_length - 7, ' ') << "  Data Type      Value" << "\033[0m\n";

    for (auto& it: interpreterSymbolTable) {
        std::cout << it.first << std::string(max_length - it.first.length(), ' ') << " | ";
        std::visit(overloaded {
            [](const int& i) { std::cout << "integer   | " << i; },
            [](const float& f) { std::cout << "real      | " << f; },
            [](const char& c) { std::cout << "char      | " << c; },
            [](const bool& b) { std::cout << "boolean   | " << std::boolalpha << b; },
            [](const ArrayType& a) { std::cout << "array     | "; printArray(a); }
        }, it.second);
        std::cout << " \n";
    }
}

template <typename T>
T performOperation(char op, T operand1, T operand2) {
    switch (op) {
        case '+': return operand1 + operand2;
        case '-': return operand1 - operand2;
        case '*': return operand1 * operand2;
        case '/': return operand1 / operand2;
        case '%': 
            if constexpr (std::is_same_v<T, int>) {
                return operand1 % operand2;
            } // TODO: Is fmod needed here?
            break;
        case '<': return operand1 < operand2;
        case '>': return operand1 > operand2;
        case '=': return operand1 == operand2;
        case '&': return operand1 && operand2;
        case '|': return operand1 || operand2;
    }

    return T();
}

std::vector<std::string> temporaryVariablesVector;

void interpreter() {
    int current_line = -1;
    while(current_line++ < quadrupleIndex) {
        std::cerr << "Result:" << quad[current_line].result 
          << " Operand1:" << quad[current_line].operand1 
          << " Operator:" << quad[current_line].op 
          << " Operand2:" << quad[current_line].operand2 
          << std::endl;
        // printIST();
        
        if (
            strcmp(quad[current_line].result, "write") == 0 || 
            strcmp(quad[current_line].result, "writeln") == 0
            ) {
                char array_name[100];
                char array_index[100];
                if (sscanf(quad[current_line].operand1, "%[^[][%[^]]]", array_name, array_index) == 2) {
                    ArrayType array = std::get<ArrayType>(getIST(array_name));

                    int index = 0;
                    if (interpreterSymbolTable.find(array_index) != interpreterSymbolTable.end()) {
                        index = std::get<int>(interpreterSymbolTable[array_index]);
                    } else {
                        index = std::stoi(array_index);
                    }

                    std::visit(overloaded {
                        [](const int& i) { std::cout << i; },
                        [](const float& f) { std::cout << f; },
                        [](const char& c) { std::cout << c; },
                        [](const bool& b) { std::cout << std::boolalpha << b; },
                        [](const ArrayType& a) { printArray(a); }
                    }, array.array[index - array.offset]);
                } else if (interpreterSymbolTable.find(quad[current_line].operand1) != interpreterSymbolTable.end()) {
                    std::visit(overloaded {
                        [](int i) { std::cout << i; },
                        [](float f) { std::cout << f; },
                        [](char c) { std::cout << c; },
                        [](bool b) { std::cout << std::boolalpha << b; },
                        [](ArrayType a) { printArray(a); }
                    }, interpreterSymbolTable[quad[current_line].operand1]);
                } else {
                    std::cout << quad[current_line].operand1;
                }

            if (strcmp(quad[current_line].result, "writeln") == 0) {
                std::cout << std::endl;
            }

            continue;
        }

        if (strcmp(quad[current_line].result, "read") == 0) {
            char array_name[100];
            char array_index[100];
            if (sscanf(quad[current_line].operand1, "%[^[][%[^]]]", array_name, array_index) == 2) {
                ArrayType array = std::get<ArrayType>(getIST(array_name));

                int index = 0;
                if (interpreterSymbolTable.find(array_index) != interpreterSymbolTable.end()) {
                    index = std::get<int>(interpreterSymbolTable[array_index]);
                } else {
                    index = std::stoi(array_index);
                }

                std::visit(overloaded {
                    [](int& i) { std::cin >> i; },
                    [](float& f) { std::cin >> f; },
                    [](char& c) { std::cin >> c; },
                    [](bool& b) { std::cin >> std::boolalpha >> b; },
                    [](ArrayType& a) { /* handle array input */ }
                }, array.array[index - array.offset]);

                updateIST(array_name, array);
            } else {
                std::visit(overloaded {
                    [](int& i) { std::cin >> i; },
                    [](float& f) { std::cin >> f; },
                    [](char& c) { std::cin >> c; },
                    [](bool& b) { std::cin >> std::boolalpha >> b; },
                    [](ArrayType& a) { /* handle array input */ }
                }, interpreterSymbolTable[quad[current_line].operand1]);
            }

            std::cout << std::endl;
            continue;
        }


        // Operator is NA
        // simple assignment operation e.g. s = 6
        if (strcmp(quad[current_line].op, "NA") == 0) {
            if (strcmp(quad[current_line].operand1, "NA") == 0 && strcmp(quad[current_line].operand2, "NA") == 0) {
                // Keywords
                continue;
            } else if (strcmp(quad[current_line].operand1, "NA") == 0) {
                char char_result;
                char array_name[100];
                char array_index[100];
                if (sscanf(quad[current_line].result, "%[^[][%[^]]]", array_name, array_index) == 2) {
                    ArrayType array = std::get<ArrayType>(getIST(array_name));

                    int index = 0;
                    if (interpreterSymbolTable.find(array_index) != interpreterSymbolTable.end()) {
                        index = std::get<int>(interpreterSymbolTable[array_index]);
                    } else {
                        index = std::stoi(array_index);
                    }

                    if (interpreterSymbolTable.find(quad[current_line].operand2) != interpreterSymbolTable.end()) {
                        auto temp = interpreterSymbolTable[quad[current_line].operand2];

                        std::variant<int, float, char, bool> downcasted_temp;
                        if (std::holds_alternative<int>(temp)) {
                            downcasted_temp = std::get<int>(temp);
                        } else if (std::holds_alternative<float>(temp)) {
                            downcasted_temp = std::get<float>(temp);
                        } else if (std::holds_alternative<char>(temp)) {
                            downcasted_temp = std::get<char>(temp);
                        } else if (std::holds_alternative<bool>(temp)) {
                            downcasted_temp = std::get<bool>(temp);
                        } else {
                            std::cerr << "Error: Cannot assign array type to array element" << std::endl;
                            continue;
                        }

                        array.array[index - array.offset] = downcasted_temp;
                    } else {
                        array.array[index - array.offset] = std::stoi(quad[current_line].operand2);
                    }

                    updateIST(array_name, array);
                } else if (sscanf(quad[current_line].operand2, "'%c'", &char_result) == 1) {
                    updateIST(quad[current_line].result, char_result);
                } else {
                    updateIST(quad[current_line].result, getIST(quad[current_line].operand2));
                }
            } else if (strcmp(quad[current_line].operand2, "NA") == 0) {
                char char_result;
                if (sscanf(quad[current_line].operand1, "'%c'", &char_result) == 1) {
                    updateIST(quad[current_line].result, char_result);
                } else {
                    updateIST(quad[current_line].result, getIST(quad[current_line].operand1));
                }
            }
            continue;
        }

        // For loop
        if (
            strcmp(quad[current_line].result, "for_cond_end") == 0 || 
            strcmp(quad[current_line].result, "while_cond_end") == 0
            ) {
            int true_line, false_line;
            if (sscanf(quad[current_line].op, "true: goto %d", &true_line) == 1 &&
                sscanf(quad[current_line].operand2, "false: goto %d", &false_line) == 1) {
                if (std::holds_alternative<bool>(getIST(quad[current_line].operand1))) {
                    if (std::get<bool>(getIST(quad[current_line].operand1))) {
                        current_line = true_line - 1;
                        std::cerr << "Going to line " << current_line + 1 << std::endl;
                    } else {
                        current_line = false_line - 1;
                        std::cerr << "Going to line " << current_line + 1 << std::endl;
                    }
                }
            }
            continue;
        }

        // If condition
        if (
            strcmp(quad[current_line].result, "if_cond_end") == 0
            ) {
            int true_line, false_line;
            if (sscanf(quad[current_line].op, "true: goto %d", &true_line) == 1 &&
                sscanf(quad[current_line].operand2, "false: goto %d", &false_line) == 1) {
                if (std::holds_alternative<bool>(getIST(quad[current_line].operand1))) {
                    if (std::get<bool>(getIST(quad[current_line].operand1))) {
                        current_line = true_line - 1;
                        std::cerr << "Going to line " << current_line + 1 << std::endl;
                    } else {
                        current_line = false_line - 1;
                        std::cerr << "Going to line " << current_line + 1 << std::endl;
                    }
                }
            }
            continue;
        }
        
        if (
            strcmp(quad[current_line].result, "for_body_end") == 0 || 
            strcmp(quad[current_line].result, "while_body_end") == 0 || 
            strcmp(quad[current_line].result, "ifthen_body_end") == 0
            ) {
            int end_line;
            if (sscanf(quad[current_line].op, "goto %d", &end_line) == 1) {
                current_line = end_line - 1;
                std::cerr << "Going to line " << current_line + 1 << std::endl;
            }
            continue;
        }

        // For single character trivial operators (op != NA)
        if (strlen(quad[current_line].op) == 1) {
            switch (quad[current_line].op[0]) {
                case '+':
                case '-':
                case '*':
                case '/':
                    if (std::holds_alternative<int>(getIST(quad[current_line].operand1)) && std::holds_alternative<int>(getIST(quad[current_line].operand2))) {
                        // Both int
                        int result = performOperation(quad[current_line].op[0], std::get<int>(getIST(quad[current_line].operand1)), std::get<int>(getIST(quad[current_line].operand2)));
                        updateIST(quad[current_line].result, result);
                    } else if (std::holds_alternative<float>(getIST(quad[current_line].operand1)) || std::holds_alternative<float>(getIST(quad[current_line].operand2))) {
                        // Both float or can be converted to float
                        float operand1 = std::holds_alternative<int>(getIST(quad[current_line].operand1)) ? static_cast<float>(std::get<int>(getIST(quad[current_line].operand1))) : std::get<float>(getIST(quad[current_line].operand1));
                        float operand2 = std::holds_alternative<int>(getIST(quad[current_line].operand2)) ? static_cast<float>(std::get<int>(getIST(quad[current_line].operand2))) : std::get<float>(getIST(quad[current_line].operand2));
                        float result = performOperation(quad[current_line].op[0], operand1, operand2);
                        updateIST(quad[current_line].result, result);
                    } else {
                        // address adding
                        
                    }
                    break;
                case '%':
                    if (std::holds_alternative<int>(getIST(quad[current_line].operand1)) && std::holds_alternative<int>(getIST(quad[current_line].operand2))) {
                        int result = performOperation(quad[current_line].op[0], std::get<int>(getIST(quad[current_line].operand1)), std::get<int>(getIST(quad[current_line].operand2)));
                        updateIST(quad[current_line].result, result);
                    }
                    break;
                case '<':
                case '>':
                case '=':
                    if (std::holds_alternative<int>(getIST(quad[current_line].operand1)) && std::holds_alternative<int>(getIST(quad[current_line].operand2))) {
                        bool result = performOperation(quad[current_line].op[0], std::get<int>(getIST(quad[current_line].operand1)), std::get<int>(getIST(quad[current_line].operand2)));
                        updateIST(quad[current_line].result, result);
                    }
                    break;
                case '&':
                case '|':
                    if (std::holds_alternative<bool>(getIST(quad[current_line].operand1)) && std::holds_alternative<bool>(getIST(quad[current_line].operand2))) {
                        bool result = performOperation(quad[current_line].op[0], std::get<bool>(getIST(quad[current_line].operand1)), std::get<bool>(getIST(quad[current_line].operand2)));
                        updateIST(quad[current_line].result, result);
                    }
                    break;
            }
            continue;
        }
        
        // For multicharacter op (op != NA)
        if (strcmp(quad[current_line].op, "<>") == 0 || strcmp(quad[current_line].op, "!=") == 0) {
            if (std::holds_alternative<int>(getIST(quad[current_line].operand1)) && std::holds_alternative<int>(getIST(quad[current_line].operand2))) {
                updateIST(quad[current_line].result, std::get<int>(getIST(quad[current_line].operand1)) != std::get<int>(getIST(quad[current_line].operand2)));
            } else if (std::holds_alternative<float>(getIST(quad[current_line].operand1)) && std::holds_alternative<float>(getIST(quad[current_line].operand2))) {
                updateIST(quad[current_line].result, std::get<float>(getIST(quad[current_line].operand1)) != std::get<float>(getIST(quad[current_line].operand2)));
            }
            continue;
        } else if (strcmp(quad[current_line].op, "<=") == 0) {
            if (std::holds_alternative<int>(getIST(quad[current_line].operand1)) && std::holds_alternative<int>(getIST(quad[current_line].operand2))) {
                updateIST(quad[current_line].result, std::get<int>(getIST(quad[current_line].operand1)) <= std::get<int>(getIST(quad[current_line].operand2)));
            } else if (std::holds_alternative<float>(getIST(quad[current_line].operand1)) && std::holds_alternative<float>(getIST(quad[current_line].operand2))) {
                updateIST(quad[current_line].result, std::get<float>(getIST(quad[current_line].operand1)) <= std::get<float>(getIST(quad[current_line].operand2)));
            }
            continue;
        } else if (strcmp(quad[current_line].op, ">=") == 0) {
            if (std::holds_alternative<int>(getIST(quad[current_line].operand1)) && std::holds_alternative<int>(getIST(quad[current_line].operand2))) {
                updateIST(quad[current_line].result, std::get<int>(getIST(quad[current_line].operand1)) >= std::get<int>(getIST(quad[current_line].operand2)));
            } else if (std::holds_alternative<float>(getIST(quad[current_line].operand1)) && std::holds_alternative<float>(getIST(quad[current_line].operand2))) {
                updateIST(quad[current_line].result, std::get<float>(getIST(quad[current_line].operand1)) >= std::get<float>(getIST(quad[current_line].operand2)));
            }
            continue;
        }
    }
    printIST();
}

void displayQuadruple()
{
    // This is the part where processing takes place
    for(int i=0; i<quadrupleIndex; i++){
        // Check if the current quadruple starts a if condition
        if(strcmp(quad[i].result, "if_cond_end") == 0){
            int j = i+1;
            while(strcmp(quad[j].result, "ifthen_body_end") != 0){
                // we need to go until the end of if body and 
                // replace the goto with the actual line number
                j++;
            }
            sprintf(quad[i].op, "true: goto %03d", i+1);
            sprintf(quad[i].operand2, "false: goto %03d", j+1);
            // Add go to if_end when you reach ifthen_body_end
            int k = j;
            while(strcmp(quad[k].result, "if_end") != 0 && k > 0){
                k++;
            }
            sprintf(quad[j].op, "goto %03d", k);
        }
        // Check if the current quadruple starts a while condition
        if(strcmp(quad[i].result, "while_cond_end") == 0){
            int j = i+1;
            while(strcmp(quad[j].result, "while_body_end") != 0){
                // we need to go until the end of while body and 
                // replace the goto with the actual line number
                j++;
            }
            sprintf(quad[i].op, "true: goto %03d", i+1);
            sprintf(quad[i].operand2, "false: goto %03d", j+1);
            // Add go to while_cond_start when you reach while_body_end
            int k = j;
            while(strcmp(quad[k].result, "while_cond_start") != 0 && k > 0){
                k--;
            }
            sprintf(quad[j].op, "goto %03d", k);
        }
        // Check if the current quadruple starts a for condition
        if(strcmp(quad[i].result, "for_cond_end") == 0){
            // First we put the condition in the previous line
            int j = i-1;
            strcpy(quad[j].operand1, quad[i].operand1);
            strcpy(quad[j].operand2, quad[i].operand2);
            strcpy(quad[j].op, quad[i].op);
            
            // Then we put the condition in the next line
            strcpy(quad[i].operand1, quad[j].result);

            j = i+1;
            while(strcmp(quad[j].result, "for_body_end") != 0){
                // we need to go until the end of for body and 
                // replace the goto with the actual line number
                j++;
            }
            sprintf(quad[i].op, "true: goto %03d", i+1);
            sprintf(quad[i].operand2, "false: goto %03d", j+1);
            // Add go to for_cond_start when you reach for_body_end
            int k = j;
            while(strcmp(quad[k].result, "for_cond_start") != 0 && k > 0){
                k--;
            }
            sprintf(quad[j].op, "goto %03d", k);
            // Also replace the for_var with the actual name 
            // of the variable in the for loop
            int l = i-1;
            while(strncmp(quad[l].result, "for_var_", 8) != 0 && l > 0){
                l--;
            }
            // we just found the for_var actual name
            // now we need to replace it with the actual name
            int m = k;
            char actual_name[100];
            sscanf(quad[l].result, "for_var_%s", actual_name);
            strcpy(quad[l].result, actual_name);
            while(m <= j){
                if(strcmp(quad[m].operand1, "for_var") == 0){
                    strcpy(quad[m].operand1, actual_name);
                }
                if(strcmp(quad[m].result, "for_var") == 0){
                    strcpy(quad[m].result, actual_name);
                }
                if(strcmp(quad[m].operand2, "for_var") == 0){
                    strcpy(quad[m].operand2, actual_name);
                }
                m++;
            }
        }
    }
    // =====================================================================================
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
        || strcmp(quad[i].op, "NA") != 0
        || strcmp(quad[i].operand2, "NA") != 0
        ) printf(" = ");

        if(strcmp(quad[i].operand1, "NA") != 0) printf(" %s ", quad[i].operand1);
        if(strcmp(quad[i].op, "NA") != 0) printf(" %s ", quad[i].op);
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

%define parse.error verbose

%token NL
%token PROGRAM INTEGER REAL BEGINK END BOOLEAN CHAR IF ELSE TO DOWNTO VAR ARRAY FOR WHILE DO NOT AND OR READ WRITE WRITE_LN ARRAY_DOT
%token PLUS MINUS MULTIPLY DIVIDE MOD 
%token EQUAL LESS GREATER LESSEQUAL GREATEREQUAL NOTEQUAL
%token <data> INT_NUMBER DECIMAL_NUMBER
%token <data> IDENTIFIER
%token SEMICOLON COMMA COLON DOT LPAREN RPAREN LBRACKET RBRACKET THEN OF INVALID_TOKEN
%token <data> STRING CHARACTER

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
    sprintf(c, "[%s]", $<data>2);
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

SINGLE_VARIABLE: IDENTIFIER COLON DATATYPE SEMICOLON { 
    if (strcmp($<data>3, "integer") == 0) {
        updateIST($<data>1, 0);
    } else if (strcmp($<data>3, "real") == 0) {
        updateIST($<data>1, 0.0f);
    } else if (strcmp($<data>3, "char") == 0) {
        updateIST($<data>1, '\0');
    } else if (strcmp($<data>3, "boolean") == 0) {
        updateIST($<data>1, false);
    }
 }
;

MULTIPLE_VARIABLE: IDENTIFIER MORE_IDENTIFIERS COLON DATATYPE SEMICOLON { 
    if (strcmp($<data>4, "integer") == 0) {
        updateIST($<data>1, 0);
    } else if (strcmp($<data>4, "real") == 0) {
        updateIST($<data>1, 0.0f);
    } else if (strcmp($<data>4, "char") == 0) {
        updateIST($<data>1, '\0');
    } else if (strcmp($<data>4, "boolean") == 0) {
        updateIST($<data>1, false);
    }

    for (auto i : temporaryVariablesVector) {
        if (strcmp($<data>4, "integer") == 0) {
            updateIST(i, 0);
        } else if (strcmp($<data>4, "real") == 0) {
            updateIST(i, 0.0f);
        } else if (strcmp($<data>4, "char") == 0) {
            updateIST(i, '\0');
        } else if (strcmp($<data>4, "boolean") == 0) {
            updateIST(i, false);
        }
    }

    temporaryVariablesVector.clear();
 }
;

MORE_IDENTIFIERS: COMMA IDENTIFIER MORE_IDENTIFIERS { 
    temporaryVariablesVector.push_back($<data>2);
 }
| COMMA IDENTIFIER { 
    temporaryVariablesVector.push_back($<data>2);
 }
;

ARRAY_DECLARATION: IDENTIFIER COLON ARRAY LBRACKET INT_NUMBER ARRAY_DOT INT_NUMBER RBRACKET OF DATATYPE SEMICOLON {
    Array<VariantType> newArray;
    newArray.offset = std::stoi($<data>7) - std::stoi($<data>5) + 1; // Storing the size of array
    if (strcmp($<data>10, "integer") == 0) {
        newArray.array = std::vector<VariantType>(newArray.offset, VariantType(0));
    } else if (strcmp($<data>10, "real") == 0) {
        newArray.array = std::vector<VariantType>(newArray.offset, VariantType(0.0f));
    } else if (strcmp($<data>10, "char") == 0) {
        newArray.array = std::vector<VariantType>(newArray.offset, VariantType('\0'));
    } else if (strcmp($<data>10, "boolean") == 0) {
        newArray.array = std::vector<VariantType>(newArray.offset, VariantType(false));
    }
    newArray.offset = std::stoi($<data>5); // Setting actual offset
    updateIST($<data>1, newArray);
}
;

/* MAIN BODY OF THE PROGRAM */
BODY_OF_PROGRAM: BEGINK STATEMENTS END DOT {
    printf("\n============================\n");
    displayQuadruple();
    printf("\n============================\n");
    interpreter();
    printf("\n============================\n");
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
READ_STATEMENT: READ LPAREN IDENTIFIER RPAREN SEMICOLON { addQuadruple($3, "NA", "NA", "read"); }
| READ LPAREN IDENTIFIER ARRAY_ADD_ON_ID RPAREN SEMICOLON {char temp[100]; sprintf(temp, "%s%s", $<data>3, $<data>4); addQuadruple(temp, "NA", "NA", "read"); }
;

/* WRITE STATEMENT */
WRITE_STATEMENT: WRITE LPAREN WRITE_IDENTIFIER_LIST RPAREN SEMICOLON
| WRITE_LN LPAREN WRITE_IDENTIFIER_LIST RPAREN SEMICOLON { addQuadruple("", "NA", "NA", "writeln"); }
;

WRITE_IDENTIFIER_LIST: WRITE_IDENTIFIER
| WRITE_IDENTIFIER COMMA WRITE_IDENTIFIER_LIST
;

WRITE_IDENTIFIER: IDENTIFIER { addQuadruple($<data>1, "NA", "NA", "write"); }
| IDENTIFIER ARRAY_ADD_ON_ID { char temp[100]; sprintf(temp, "%s%s", $<data>1, $<data>2); addQuadruple(temp, "NA", "NA", "write"); }
| STRING { addQuadruple($<data>1, "NA", "NA", "write"); }
| INT_NUMBER { addQuadruple($<data>1, "NA", "NA", "write"); }
| DECIMAL_NUMBER { addQuadruple($<data>1, "NA", "NA", "write"); }
| CHARACTER { addQuadruple($<data>1, "NA", "NA", "write"); }
;

/* ASSIGNMENT */
ASSIGNMENT_STATEMENT: IDENTIFIER COLON EQUAL ANY_EXPRESSION SEMICOLON {
    addQuadruple("NA", "NA", $<data>4, $<data>1);
}
| IDENTIFIER ARRAY_ADD_ON_ID COLON EQUAL ANY_EXPRESSION SEMICOLON {
    char c[100];
    sprintf(c,"%s%s",$<data>1, $<data>2); 
    addQuadruple("NA", "NA", $<data>5, c);
}
| IDENTIFIER COLON EQUAL CHARACTER SEMICOLON {
    char temp[100];
    sprintf(temp, "'%s'", $<data>4);
    addQuadruple(temp, "NA", "NA", $<data>1);
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
    strcpy($<data>$, c);
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
} IDENTIFIER COLON EQUAL EXPRESSION_SEQUENCE {
    // Convert for i := 0 into quadruple where it says
    // for_i = 0
    char temp[100];
    sprintf(temp, "for_var_%s", $<data>3);
    addQuadruple(popFromStack(), "NA", "NA", temp);
    addQuadruple("NA", "NA", "NA", "for_cond_start");
} AFTER_FOR_CONDITION
;

AFTER_FOR_CONDITION: TO EXPRESSION_SEQUENCE {
    // Add a condition which says for_var <= $<data>1
    char str[100];
    char str1[100]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple("NA", "NA", "NA", str1);
    addQuadruple("for_var", "<=", $<data>2, "for_cond_end");
} DO {
    addQuadruple("NA", "NA", "NA", "for_body_start");
} BODY_OF_LOOP {
    addQuadruple("for_var", "+", "1", "for_var");
    addQuadruple("NA", "NA", "NA", "for_body_end");
} SEMICOLON {
    addQuadruple("NA", "NA", "NA", "for_end");
}
| DOWNTO EXPRESSION_SEQUENCE {
    char str[100];
    char str1[100]="t"; 
    sprintf(str,"%d", temp_char++);
    strcat(str1, str); 
    addQuadruple("NA", "NA", "NA", str1);
    addQuadruple("for_var", ">=", $<data>2, "for_cond_end");
} DO {
    addQuadruple("NA", "NA", "NA", "for_body_start");
} BODY_OF_LOOP {
    addQuadruple("for_var", "-", "1", "for_var");
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
int main(int argc, char *argv[])
{
    std::ofstream file("temp.out");
    auto* oldCerrBuffer = std::cerr.rdbuf();
    std::cerr.rdbuf(file.rdbuf());

    char* filename;
    filename=argv[1];
    printf("\n");
    yyin = fopen(filename, "r");
    yyparse();

    std::cerr.rdbuf(oldCerrBuffer);

    return 0;
}

int yyerror(const char* s){
    std::cerr << "Error[Line " << yylineno << "]: " << s << std::endl;
    exit(1);
}