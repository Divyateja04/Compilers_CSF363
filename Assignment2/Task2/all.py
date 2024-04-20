import os

# Open testcases directory
test_cases = os.listdir('./testcases')
COUNT = len(test_cases)

for i in range(COUNT):
    os.system('echo "======================================="')
    os.system(f'echo "Test Case {i+1}"')
    
    os.system(f'cat ./testcases/{i + 1}.txt > sample.txt')
    os.system(f'cat sample.txt')
    
    os.system(f'echo "Deleting old files"')
    os.system(f'rm -f ADKM3773.out')
    os.system(f'rm -f y.tab.c')
    os.system(f'rm -f y.tab.h')
    os.system(f'rm -f lex.yy.c')
    os.system(f'echo "Compiling yacc program"')
    os.system(f'yacc -d ADKM3773.y -Wconflicts-rr -Wconflicts-sr -Wcounterexamples')
    os.system(f'echo "Compiling lex program"')
    os.system(f'lex ADKM3773.l')
    os.system(f'echo "Compiling the program in gcc"')
    os.system(f'gcc y.tab.c lex.yy.c -ll -o ADKM3773.out')
    os.system(f'./ADKM3773.out')

os.system(f'echo ""')
os.system(f'rm -f ADKM3773.out')
os.system(f'rm -f y.tab.c')
os.system(f'rm -f y.tab.h')
os.system(f'rm -f lex.yy.c')
    
