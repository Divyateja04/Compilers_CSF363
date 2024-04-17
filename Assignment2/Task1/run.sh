rm -f ADKM3773.out
lex ADKM3773.l
gcc lex.yy.c -ll -o ADKM3773.out
./ADKM3773.out