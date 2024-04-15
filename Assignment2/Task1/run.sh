rm -f ADMK3773.out
lex ADMK3773.l
gcc lex.yy.c -ll -o ADMK3773.out
./ADMK3773.out