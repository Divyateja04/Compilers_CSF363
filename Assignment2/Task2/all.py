import os
import argparse

parser = argparse.ArgumentParser(prog='Compilers Assignment 2 Runner')
parser.add_argument('-tc', type=int, help="Run one of the test cases, input being file number")
parser.add_argument('-a', help="Run all of the test cases", action='store_true')
parser.add_argument('-c', help="Print counterexamples", action='store_true')
parser.add_argument('-d', help="Enable debug mode", action='store_true')


args = parser.parse_args()

if args.all:
    # Open testcases directory
    test_cases = os.listdir('./testcases')
    COUNT = len(test_cases)

    for i in range(COUNT):
        os.system('echo "======================================="')
        os.system(f'echo "Test Case {i+1}"')
        
        os.system(f'cat ./testcases/{i + 1}.pas > sample.txt')
        os.system(f'cat sample.txt')
        
        os.system(f'echo "Deleting old files"')
        os.system(f'rm -f ADKM3773.out')
        os.system(f'rm -f y.tab.c')
        os.system(f'rm -f y.tab.h')
        os.system(f'rm -f lex.yy.c')
        os.system(f'echo "Compiling yacc program"')
        os.system(f'yacc -d ADKM3773.y {"" if not args.d else "-t"} -Wconflicts-rr -Wconflicts-sr {"" if not args.c else "-Wcounterexamples"}')
        os.system(f'echo "Compiling lex program"')
        os.system(f'lex ADKM3773.l')
        os.system(f'echo "Compiling the program in gcc"')
        os.system(f'gcc y.tab.c lex.yy.c -ll -o ADKM3773.out')
        os.system(f'./ADKM3773.out')
elif args.testcase:
    test_case_num = int(args.testcase)
    os.system('clear')
    os.system('echo "======================================="')
    os.system(f'echo "Test Case {test_case_num}"')
    
    os.system(f'cat ./testcases/{test_case_num}.pas > sample.txt')
    
    os.system(f'echo "Deleting old files"')
    os.system(f'rm -f ADKM3773.out')
    os.system(f'rm -f y.tab.c')
    os.system(f'rm -f y.tab.h')
    os.system(f'rm -f lex.yy.c')
    os.system(f'echo "Compiling yacc program"')
    os.system(f'yacc -d ADKM3773.y {"" if not args.d else "-t"} -Wconflicts-rr -Wconflicts-sr {"" if not args.c else "-Wcounterexamples"}')
    os.system(f'echo "Compiling lex program"')
    os.system(f'lex ADKM3773.l')
    os.system(f'echo "Compiling the program in gcc"')
    os.system(f'gcc y.tab.c lex.yy.c -ll -o ADKM3773.out')
    os.system(f'./ADKM3773.out')
else: 
    parser.print_help()
    
os.system(f'echo ""')
os.system(f'rm -f ADKM3773.out')
os.system(f'rm -f y.tab.c')
os.system(f'rm -f y.tab.h')
os.system(f'rm -f lex.yy.c')