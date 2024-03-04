<STUDENT_RECORD_GRADE>["A""-"|"B""-"] { 
    printf("-:%s", yytext);
    sprintf(records[stu_itr]->courses[course_itr-1]->grade,"%s-",yytext);
    records[stu_itr]->courses[course_itr-1]->course_flag=true;
    records[stu_itr]->stud_flag=true;
    if(toPrint) printf("\nGrade-: %s", records[stu_itr]->courses[course_itr-1]->grade); 
    BEGIN(STUDENT_RECORD_END);
}