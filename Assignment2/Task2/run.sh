rm -f ADKM3773.out
yacc -d ADKM3773.y
lex ADKM3773.l
gcc y.tab.c lex.yy.c -ll -o ADKM3773.out