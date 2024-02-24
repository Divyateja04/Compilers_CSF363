%x READ_STUDENT_ID
%x COMMENT
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char student_id[100];
%}

%%

. { ECHO; }

<READ_STUDENT_ID>[A-Z0-9]+ { 
    sprintf(student_id, "%s", yytext); 
    BEGIN(INITIAL);
    return 0;
}

"//" { 
    BEGIN(COMMENT); 
}
<COMMENT>[^\n]* { } /* eat up comments */

%%

int main() {
    // First we open input.txt and read the student id
    yyin = fopen("input.txt", "r");
    if (!yyin) {
        printf("Error opening input.txt\n");
        return 1;
    }
    BEGIN(READ_STUDENT_ID);
    yylex();
    printf("Student ID: %s\n", student_id);

    // Then we open data.txt and read the data but this time 
    // we write the output to output.txt
    yyin = fopen("data.txt", "r");
    if(!yyin) {
        printf("Error opening data.txt\n");
        return 1;
    } 
    yyout = fopen("output.txt", "w");
    if(!yyout) {
        printf("Error opening output.txt\n");
        return 1;
    }
    yyrestart(yyin);
    yylex();

    // Close the files
    fclose(yyin);
    fclose(yyout);

    return 0;
}