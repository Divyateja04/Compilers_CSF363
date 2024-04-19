clear
echo "Deleting old files"
rm -f ADKM3773.out
echo "Compiling yacc program"
yacc -d ADKM3773.y -Wconflicts-rr -Wconflicts-sr -Wcounterexamples
echo "Compiling lex program"
lex ADKM3773.l
echo "Compiling the program in gcc"
gcc y.tab.c lex.yy.c -ll -o ADKM3773.out
./ADKM3773.out