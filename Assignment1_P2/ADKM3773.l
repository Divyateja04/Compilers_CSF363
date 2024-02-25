%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int toPrint = 1;

char id[100];
int k1 = 0; // Total no:of valid records
int k2 = 0; // Total no:of comments
int k3 = 0; // No:of distinct courses
double cgpa = 0.0; // CGPA
double k4 = 0.0; // CGPA * 100

typedef struct student {
    char student_id[100];
    int no_of_courses;
    course* courses[100];
} student;

typedef struct course {
    char course_id[100];
    int units;
    char grade[100];
} course;

student* neededStudent = (student*) malloc(sizeof(student));

%}

%x READ_STUDENT_ID
%x COMMENT

%s RECORDS

%s STUDENT_RECORD
%s STUDENT_RECORD_END
%x STUDENT_RECORD_COURSEID
%x STUDENT_RECORD_UNITS
%x STUDENT_RECORD_GRADE

%%
<READ_STUDENT_ID>[A-Z]+[0-9]+ { 
    sprintf(neededStudent->student_id, "%s", yytext); 
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
    if(id == neededStudent->student_id){
        BEGIN(STUDENT_RECORD);
    }
    else{
        // Not the student we want
        // we can ignore
    }
}

<STUDENT_RECORD>"<" BEGIN(STUDENT_RECORD_COURSEID);
<STUDENT_RECORD_COURSEID>[A-Z]+[0-9]+ { 
    if(toPrint) printf("\nCourse ID: %s ", yytext); 
} 
<STUDENT_RECORD_COURSEID>[" "]+ BEGIN(STUDENT_RECORD_UNITS);


<STUDENT_RECORD_UNITS>[234] { 
    if(toPrint) printf("\nUnits: %s ", yytext); 
}
<STUDENT_RECORD_UNITS>[" "]+ BEGIN(STUDENT_RECORD_GRADE);


<STUDENT_RECORD_GRADE>["A/\-"|"B/\-"] { 
    if(toPrint) printf("\nGrade: %s- ", yytext); 
    k1++;
    BEGIN(STUDENT_RECORD_END);
}
<STUDENT_RECORD_GRADE>["A"|"B"|"C"] { 
    if(toPrint) printf("\nGrade: %s ", yytext); 
    k1++;
    BEGIN(STUDENT_RECORD_END);
}


<STUDENT_RECORD_END>">"" "* BEGIN(INITIAL);

. { ECHO; }

%%

int main() {
    // First we open input.txt and read the student id
    yyin = fopen("input.txt", "r");
    if (!yyin) {
        if(toPrint) printf("Error opening input.txt\n");
        return 1;
    }
    BEGIN(READ_STUDENT_ID);
    yylex();
    if(toPrint) printf("Student ID: %s\n", neededStudent->student_id);

    // Then we open data.txt and read the data but this time 
    // we write the output to output.txt
    yyin = fopen("data.txt", "r");
    if(!yyin) {
        if(toPrint) printf("Error opening data.txt\n");
        return 1;
    } 
    yyout = fopen("output.txt", "w");
    if(!yyout) {
        if(toPrint) printf("Error opening output.txt\n");
        return 1;
    }
    yyrestart(yyin);
    yylex();

    // Print the results
    if(toPrint) printf("\n\nTotal no:of valid records: %d\n", k1);
    if(toPrint) printf("Total no:of comments: %d\n", k2);
    if(toPrint) printf("No:of distinct courses: %d\n", k3);
    if(toPrint) printf("CGPA: %.2f\n", cgpa);

    // Close the files
    fclose(yyin);
    fclose(yyout);

    return 0;
}