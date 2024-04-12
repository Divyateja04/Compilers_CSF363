rm -f ADMK3773.out
yacc -d ADMK3773.y
lex ADMK3773.l
gcc y.tab.c lex.yy.c -ll -o ADMK3773.out
./ADMK3773.out