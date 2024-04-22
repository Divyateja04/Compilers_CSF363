# Pascal Compiler 

## Contributors
- Divyateja Pasupuleti - 2021A7PS0075H
- Kumarasamy Chelliah - 2021A7PS0096H
- Adarsh Das - 2021A7PS1511H
- Manan Gupta - 2021A7PS2091H

## Running the code
- You would need yacc and lex pre installed

### Task 1
- You can use the `run.sh` in the Task 1 folder or just use the following:
```sh
lex ADKM3773.l
gcc lex.yy.c -ll -o ADKM3773.out
./ADKM3773.out
```

### Task 2
- For this task the test cases are stored in the `testcases` folder
- You can run `python all.py`. It has multiple arguments
  - `-a` runs all the test cases in the folder 
  - For convenience you can run `python all.py -a > output.txt` so that the outputs go into the output folder
  - `-tc NUMBER` runs the testcase corresponding to `testcases/NUMBER.pas`
  - Other flags are there for debugging