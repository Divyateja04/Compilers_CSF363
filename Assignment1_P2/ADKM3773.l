%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>

int toPrint = 1;

char id[100];
int k1 = 0; // Total no:of valid records
int k2 = 0; // Total no:of comments
int k3 = 0; // No:of distinct courses

typedef struct course {
    char course_id[100];
    int units;
    char grade[100];
    bool course_flag;  // If Course overall is valid or not (unit and grade both are not missing)
} course;

typedef struct student {
    char student_id[100];
    int no_of_courses;
    course* courses[100];
    bool stud_flag; // If student overall is valid or not (student_id and no_of_courses are not missing)
} student;

typedef struct our_student_data{
    course* courses[100];
} our_student_data;

struct student* records[30];

int stu_itr = -1;
int course_itr=0;
int all_student_itr=0;
int our_student_itr=99;
char our_student_id[100];
char all_student_id[30][100];
%}

%x READ_STUDENT_ID
%x COMMENT

%x RECORDS

%x STUDENT_RECORD
%x STUDENT_RECORD_END
%x STUDENT_RECORD_COURSEID
%x STUDENT_RECORD_UNITS
%x STUDENT_RECORD_GRADE
%x RECORD_TUPLE

%%

"//" { 
    BEGIN(COMMENT);
}
<COMMENT>[^\n]* { } /* eat up comments */
<COMMENT>[\n] { 
    k2++;
    BEGIN(INITIAL);
}

<READ_STUDENT_ID>[A-Z]+[0-9]+ {
    sprintf(our_student_id, "%s", yytext); 
    // printf("%s", our_student);
    BEGIN(INITIAL);
    return 0;
}


<RECORD_TUPLE>[" "]*"//" {
    BEGIN(COMMENT);      
} 
<RECORD_TUPLE>"$//" {
    BEGIN(COMMENT);
} 
<RECORD_TUPLE>"<//" {
    BEGIN(COMMENT);
}
<RECORD_TUPLE>"$"[" "]* { 
    stu_itr++;
    course_itr = 0; 
    BEGIN(RECORDS); 
    }
<RECORD_TUPLE>"<"[" "]* { 
    BEGIN(STUDENT_RECORD_COURSEID);
}


"$"[" "]* { 
    stu_itr++;
    course_itr = 0; 
    BEGIN(RECORDS); 
}


<RECORDS>[" "]*"//" {
    BEGIN(COMMENT);
}
<RECORDS>[A-Z0-9]*"//" {
    BEGIN(COMMENT);
}
<RECORDS>[A-Z]+[0-9]+ {
    sprintf(records[stu_itr]->student_id,"%s",yytext);
    if(toPrint) printf("\n\nNew Student: %s", records[stu_itr]->student_id);
    BEGIN(STUDENT_RECORD);
}


<STUDENT_RECORD>[" "]*"//" {
    BEGIN(COMMENT);
}
<STUDENT_RECORD>[" "]*"<//"[" "]* {
    BEGIN(COMMENT);
}

<STUDENT_RECORD>[" "]*"<"[" "]* {
    BEGIN(STUDENT_RECORD_COURSEID);
}


<STUDENT_RECORD_COURSEID>[" "]*"//" {
    BEGIN(COMMENT);
}
<STUDENT_RECORD_COURSEID>[A-Z0-9]*"//" {
    BEGIN(COMMENT);
}
<STUDENT_RECORD_COURSEID>[A-Z]+[0-9]+ { 
    sprintf(records[stu_itr]->courses[course_itr]->course_id,"%s",yytext);    
    if(toPrint) printf("\nCourse ID: %s ", records[stu_itr]->courses[course_itr]->course_id); 
    course_itr++;
} 
<STUDENT_RECORD_COURSEID>[" "]+ {
    BEGIN(STUDENT_RECORD_UNITS);
}


<STUDENT_RECORD_UNITS>[" "]*"//" {
    BEGIN(COMMENT);
}
<STUDENT_RECORD_UNITS>[234]"//" {
    BEGIN(COMMENT);
} 
<STUDENT_RECORD_UNITS>[234] { 
    records[stu_itr]->courses[course_itr-1]->units = yytext[0]-'0';
    // sprintf(records[stu_itr]->courses[course_itr-1]->units,"%s",yytext);
    if(toPrint) printf("\nUnits: %d ", records[stu_itr]->courses[course_itr-1]->units); 
}

<STUDENT_RECORD_UNITS>[" "]+ {
    BEGIN(STUDENT_RECORD_GRADE);
}


<STUDENT_RECORD_GRADE>[" "]*"//" {
    BEGIN(COMMENT);
}
<STUDENT_RECORD_GRADE>"A-//" {
    BEGIN(COMMENT);
} 
<STUDENT_RECORD_GRADE>"B-//" {
    BEGIN(COMMENT);
}  
<STUDENT_RECORD_GRADE>["A"|"B"|"C"]"//" {
    BEGIN(COMMENT);
}   
<STUDENT_RECORD_GRADE>"A-" { 
    sprintf(records[stu_itr]->courses[course_itr-1]->grade,"%s",yytext);
    records[stu_itr]->courses[course_itr-1]->course_flag=true;
    records[stu_itr]->stud_flag=true;
    if(toPrint) printf("\nGrade: %s", records[stu_itr]->courses[course_itr-1]->grade); 
    BEGIN(STUDENT_RECORD_END);
}
<STUDENT_RECORD_GRADE>"B-" { 
    sprintf(records[stu_itr]->courses[course_itr-1]->grade,"%s",yytext);
    records[stu_itr]->courses[course_itr-1]->course_flag=true;
    records[stu_itr]->stud_flag=true;
    if(toPrint) printf("\nGrade: %s", records[stu_itr]->courses[course_itr-1]->grade); 
    BEGIN(STUDENT_RECORD_END);
}
<STUDENT_RECORD_GRADE>["A"|"B"|"C"] { 
    sprintf(records[stu_itr]->courses[course_itr-1]->grade,"%s",yytext);
    records[stu_itr]->courses[course_itr-1]->course_flag=true;
    records[stu_itr]->stud_flag=true;
    if(toPrint) printf("\nGrade: %s", records[stu_itr]->courses[course_itr-1]->grade); 
    BEGIN(STUDENT_RECORD_END);
}


<STUDENT_RECORD_END>[" "]*"//" {
    BEGIN(COMMENT);
} 
<STUDENT_RECORD_END>[" "]*">//"[" "]* {
    BEGIN(COMMENT);
} 
<STUDENT_RECORD_END>[" "]*">"[" "]* {
    BEGIN(RECORD_TUPLE);
}


%%
int check(struct course* c, struct our_student_data* our_student)
{
    for(int i=0;i<100;i++)
    {
        if(strcmp(c->course_id,our_student->courses[i]->course_id)==0)
        {
            sprintf(our_student->courses[i]->grade,"%s", c->grade);
            our_student->courses[i]->units = c->units;
            // sprintf(our_student->courses[i]->units,"%s", c->units);
            if(c->course_flag==false)
            our_student->courses[i]->course_flag=false;
            else
            our_student->courses[i]->course_flag=true;

            return 1;
        }
    }

    sprintf(our_student->courses[our_student_itr]->course_id,"%s", c->course_id);
    sprintf(our_student->courses[our_student_itr]->grade,"%s", c->grade);
    our_student->courses[our_student_itr]->units = c->units;
    // sprintf(our_student->courses[our_student_itr]->units,"%s", c->units);
    // printf("\n%s %s %d", c->course_id, c->grade, c->units);
    // printf("\n%s %s %d", our_student->courses[our_student_itr]->course_id, our_student->courses[our_student_itr]->grade, our_student->courses[our_student_itr]->units);
    our_student->courses[our_student_itr]->course_flag=c->course_flag;
    our_student_itr--;
    return 0;
}

int check_student(struct student* s)
{
    for(int i=0;i<30;i++)
    {
        if(strcmp(s->student_id,all_student_id[i])==0)
        return 0;
    }

    sprintf(all_student_id[all_student_itr],"%s", s->student_id);
    all_student_itr++;
    return 1;
}

int main() {
    // First we open input.txt and read the student id
    for (int i = 0; i < 30; i++) 
    {
        records[i] = (struct student*)malloc(sizeof(student));
        records[i]->stud_flag = false;
        records[i]->no_of_courses = 0;

        for (int j = 0; j < 100; j++) 
        {
            records[i]->courses[j] = (struct course*)malloc(sizeof(struct course));
            records[i]->courses[j]->course_flag = false;
            // printf("%ld", &(records[i]->courses[j]->course_id));
        }    
    }
    yyin = fopen("input.txt", "r");
    if (!yyin) 
    {
        if(toPrint) printf("Error opening input.txt\n");
        return 1;
    }
    BEGIN(READ_STUDENT_ID);
    yylex();
    // if(toPrint) printf("Student ID: %s\n",student_id);

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
    double cgpa=0;
    // Print the results

    for(int i=0;i<30;i++)
    {
        if(records[i]->stud_flag)
        {
            if(check_student(records[i])==1)
            k1++;
        }    
    }

    struct our_student_data* our_student  = (struct our_student_data*)malloc(sizeof(struct our_student_data));
    for(int i=0;i<100;i++)
    {
        our_student->courses[i] = (struct course*)malloc(sizeof(struct course));
        our_student->courses[i]->course_flag = false;
    }


    for(int i=0;i<30;i++)
    {   
        // printf("\n%s\n", records[i]->student_id);
        if(strcmp(records[i]->student_id,our_student_id)==0)
        {
            for(int j=0;j<100;j++)
            {
                if(records[i]->courses[j]->course_flag)
                {
                    // printf("\n%s", records[i]->courses[j]->units);
                    if(check(records[i]->courses[j],our_student)==0)
                    k3++;
                }

            }
        }
    }
    int points=0;
    int total_unit = 0;

    for(int i=0;i<100;i++)
    {   
        if(our_student->courses[i]->course_flag)
        {
            if(strcmp(our_student->courses[i]->grade,"A")==0)
            {
                // printf("\nA grade");
                if(our_student->courses[i]->units==2)
                {
                    points+= 20;
                    total_unit+=2;
                }
                else if(our_student->courses[i]->units==3)
                {
                    points+= 30;
                    total_unit+=3;
                }
                else if(our_student->courses[i]->units==4)
                {
                    points+= 40;
                    total_unit+=4;
                }
            }
            else if(strcmp(our_student->courses[i]->grade,"A-")==0)
            {
                if(our_student->courses[i]->units==2)
                {
                    points+= 16;
                    total_unit+=2;
                }
                else if(our_student->courses[i]->units==3)
                {
                    points+= 24;
                    total_unit+=3;
                }
                else if(our_student->courses[i]->units==4)
                {
                    points+= 32;
                    total_unit+=4;
                }
            }
            else if(strcmp(our_student->courses[i]->grade,"B")==0)
            {
                if(our_student->courses[i]->units==2)
                {
                    points+= 12;
                    total_unit+=2;
                }
                else if(our_student->courses[i]->units==3)
                {
                    points+= 18;
                    total_unit+=3;
                }
                else if(our_student->courses[i]->units==4)
                {
                    points+= 24;
                    total_unit+=4;
                }
            }
            else if(strcmp(our_student->courses[i]->grade,"B-")==0)
            {
                if(our_student->courses[i]->units==2)
                {
                    points+= 8;
                    total_unit+=2;
                }
                else if(our_student->courses[i]->units==3)
                {
                    points+= 12;
                    total_unit+=3;
                }
                else if(our_student->courses[i]->units==4)
                {
                    points+= 16;
                    total_unit+=4;
                }
            }
            else if(strcmp(our_student->courses[i]->grade,"C")==0)
            {
                if(our_student->courses[i]->units==2)
                {
                    points+= 4;
                    total_unit+=2;
                }
                else if(our_student->courses[i]->units==3)
                {
                    points+= 6;
                    total_unit+=3;
                }
                else if(our_student->courses[i]->units==4)
                {
                    points+= 8;
                    total_unit+=4;
                }
            }
        }
    }
    // printf("\n%d\n", points);
    // printf("%d\n", total_unit);
    cgpa = (double)points/total_unit;

    // for(int i=0;i<100;i++)
    // {
    //     if(our_student->courses[i]->course_flag)
    //     {
    //         // printf("\n%s %s %s", our_student->courses[i]->course_id, our_student->courses[i]->grade, our_student->courses[i]->units);
    //     }
    // }
    
    if(toPrint) printf("\n\nTotal no:of valid records: %d\n", k1);
    if(toPrint) printf("Total no:of comments: %d\n", k2);
    if(toPrint) printf("No:of distinct courses: %d\n", k3);

    int rounded_cgpa = round(cgpa*100);
    if(toPrint) printf("CGPA: %d\n", rounded_cgpa);

    // Close the files
    fclose(yyin);
    fclose(yyout);

    return 0;
}