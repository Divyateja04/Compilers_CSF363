%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char student_id[100];
char id[100];
int k1 = 0; // Total no:of valid records
int k2 = 0; // Total no:of comments
int k3 = 0; // No:of distinct courses
double cgpa = 0.0; // CGPA
double k4 = 0.0; // CGPA * 100
%}

%x READ_STUDENT_ID
%x COMMENT
%s RECORDS
%s STUDENT_RECORD
%s STUDENT_RECORD_COURSEID
%s STUDENT_RECORD_UNITS
%s STUDENT_RECORD_GRADE

%%

<READ_STUDENT_ID>[A-Z]+[0-9]+ { 
    sprintf(student_id, "%s", yytext); 
    BEGIN(INITIAL);
    return 0;
}

"//" { 
    BEGIN(COMMENT);
}
<COMMENT>[^\n]* { } /* eat up comments */
<COMMENT>[\n] { 
    k2++;
    BEGIN(INITIAL);
}

"$" { BEGIN(RECORDS); }
<RECORDS>[A-Z]+[0-9]+ {
    sprintf(id, "%s", yytext);
    if(id == student_id){
        BEGIN(STUDENT_RECORD);
    }
    else{
        BEGIN(READ_RECORD);
    }
}

"<" BEGIN(STUDENT_RECORD_COURSEID);
<STUDENT_RECORD_COURSEID>[A-Z]+[0-9]+ { 
    ... 
} 

" "+ BEGIN(STUDENT_RECORD_UNITS);
<STUDENT_RECORD_UNITS>[234] { 
    ... 
}

" "+ BEGIN(STUDENT_RECORD_GRADE);
<STUDENT_RECORD_GRADE>{A, A-, B, B-, C} { 
    ... ;
    k1++
}

">"" "* BEGIN(INITIAL);

. { ECHO; }

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