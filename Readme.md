# Pascal Compiler 

## Contributors
| Name                 |       ID      |
|:-------------------- |:-------------:|
| Divyateja Pasupuleti | 2021A7PS0075H |
| Kumarasamy Chelliah  | 2021A7PS0096H |
| Adarsh Das           | 2021A7PS1511H |
| Manan Gupta          | 2021A7PS2091H |

## Guide
- You would need yacc and lex pre installed

### Task 1 - Lexical Analysis
- You can use the `run.sh` in the Task 1 folder or just use the following:
```sh
lex ADKM3773.l
gcc lex.yy.c -ll -o ADKM3773.out
./ADKM3773.out
```
- Input for this file is taken from sample.txt and output is sent to output.txt

### Task 2 - Syntactical Analysis
- In this part of the task, we generate a grammer in yacc and test it against test cases to tell whether it's syntactically valid or not.
- For this task the test cases are stored in the `testcases` folder
- You can run `python run.py`. It has multiple arguments
  - `-a` runs all the test cases in the folder 
  - For convenience you can run `python run.py -a > output.txt` so that the outputs go into the output folder
  - `-tc NUMBER` runs the testcase corresponding to `testcases/NUMBER.pas`, as in you can create a testcase 13.pas and then use `python run.py -tc 13`
  - Other flags are there for debugging
  
### Task 3 - Semantical Analysis
- In this part, we have to generate AST as well as check the semantics of the program
- You can run `python run.py`. It has multiple arguments
  - `-a` runs all the test cases in the folder 
  - For convenience you can run `python run.py -a > output.txt` so that the outputs go into the output folder
  - `-tc NUMBER` runs the testcase corresponding to `testcases/NUMBER.pas`, as in you can create a testcase 13.pas and then use `python run.py -tc 13`
  - Other flags are there for debugging
- We print tree to syntaxtree.txt and show it using nltk
  
### Task 4 - Intermediate Code Generation
- In this part of the assignment, we generate Three Address Code for the program
- We use the following convention for the same:
#### For loop
```pas
for i := 1 to 5 do
  begin
    sum := sum + 6 * 7 + numbers[i];
  end;
```
```
:020:>  for_start ;
:021:>  i  =  1 ;
:022:>  for_cond_start ;
:023:>  t11  =  i  <=  5 ;
:024:>  for_cond_end  =  t11  true: goto 025  false: goto 029 ;
:025:>  for_body_start ;
:026:>  t12  =  i  * ;
:027:>  i  =  i  +  1 ;
:028:>  for_body_end  =  goto 022 ;
:029:>  for_end ;
```

#### While loop
```pas
while number <> 0 do
  begin
    digit := number - (number / 10) * 10;
    
    if digit <> 0 then
    begin
      count:=count+1;
    end;

    number := number / 10;
  end;
```
```
:064:>  while_start ;
:065:>  while_cond_start ;
:066:>  t22  =  number  <>  0 ;
:067:>  while_cond_end  =  t22  true: goto 068  false: goto 084 ;
:068:>  while_body_start ;
:069:>  t23  =  number  /  10 ;
:070:>  t24  =  t23  *  10 ;
:071:>  t25  =  number  -  t24 ;
:072:>  digit  =  t25 ;

:073:>  if_start ;
:074:>  t26  =  digit  <>  0 ;
:075:>  if_cond_end  =  t26  true: goto 076  false: goto 080 ;
:076:>  ifthen_body_start ;
:077:>  t27  =  count  +  1 ;
:078:>  count  =  t27 ;
:079:>  ifthen_body_end  =  goto 080 ;
:080:>  if_end ;

:081:>  t28  =  number  /  10 ;
:082:>  number  =  t28 ;
:083:>  while_body_end  =  goto 065 ;
:084:>  while_end ;
```

#### If-else
```pas
if x then
  begin
    a := numbers[i] + 9;
    write("x is true");
  end
  else
  begin
    write("x is false");
    a := numbers[i] - 9;
  end;
```
```
:057:>  if_start ;
:058:>  if_cond_end  =  x  true: goto 059  false: goto 066 ;
:059:>  ifthen_body_start ;
:060:>  t22  =  i  *  Integer ;
:061:>  t23  =  t22  +  &numbers ;
:062:>  t24  =  *t23 ;
:063:>  t25  =  t24  +  9 ;
:064:>  a  =  t25 ;
:065:>  ifthen_body_end  =  goto 073 ;
:066:>  else_body_start ;
:067:>  t26  =  i  *  Integer ;
:068:>  t27  =  t26  +  &numbers ;
:069:>  t28  =  *t27 ;
:070:>  t29  =  t28  -  9 ;
:071:>  a  =  t29 ;
:072:>  else_body_end ;
:073:>  if_end ;

```

### Task 5 - Interpreting the Intermediate code
In this task, we interpret the Three Address Code (3AC) generated in the previous task. The 3AC is a type of intermediate representation (IR) that has at most three operands for each instruction, making it suitable for typical machine instructions.

The interpretation process involves the following steps:

1. **Reading the 3AC**: The interpreter reads the 3AC line by line. Each line represents an instruction to be executed.

2. **Decoding the Instructions**: Each instruction is decoded to understand the operation to be performed. The operation could be arithmetic (like addition, subtraction, multiplication, division), relational (like less than, greater than, equal to), logical (like AND, OR, NOT), or control flow (like goto, if-else, loops).

3. **Executing the Instructions**: After decoding, the instruction is executed. If it's an arithmetic, relational, or logical operation, the result is stored in a temporary variable. If it's a control flow operation, the flow of the program is altered accordingly.

4. **Maintaining the Symbol Table**: A symbol table is maintained to keep track of all variables and their current values. When a variable is updated, the symbol table is updated as well.

5. **Handling Control Flow**: For control flow operations, the interpreter keeps track of the line number to execute next. For example, in case of a 'goto' operation, the interpreter will jump to the specified line number.

This process continues until all lines of the 3AC have been read and executed. The final state of the symbol table represents the result of the program.

For example when we run the following code:
```pas
program MaxValueArray;
var
  numbers: array[1..10] of Integer;
  i, maxValue: Integer;
  number:integer;
  i:char;
begin
  write("Enter 10 integer values:",i);
  maxValue := numbers[12];
  for i := 1 to 10 do
  begin
    read(numbers[i]);
    write(numbers[i]);
  end;
  maxValue := numbers[1];
  for i := 2 to 10 do
  begin
    if numbers[i] > maxValue then
    begin
      maxValue := numbers[i];
    end;
  end;
  write("The maximum value is: ");  
  write(maxValue);
  while number <> 0 do
  begin
    if number <> 0 then
    begin
      count:=count+1;
    end
    else 
    begin
     count :=count;
    end; 
    number := number / 10;
  end;
end.
```

it prints the output

```
The maximum value is: 9
```

and the symbol table

| Variable |   Type  | Value                          |
|:-------- |:-------:|:------------------------------ |
| t3       | boolean | false                          |
| t2       | boolean | false                          |
| t0       | boolean | false                          |
| t1       | boolean | false                          |
| number   | integer | 0                              |
| maxvalue | integer | 9                              |
| i        | integer | 11                             |
| numbers  |  array  | [4, 3, 2, 5, 6, 7, 1, 8, 9, 1] |

 
## Pre Cursors
### Assignment 1 - Part 1
- We have to convert a given regular expression to an eNFA/NFA and run it on a given set of strings
- The main classes which deal with the State itself.

```c++
class State
{
public:
int number;
vector<State _> a;
vector<State _> b;
vector<State \*> e;

    State()
    {
        number = stateCounter++;
        a = {};
        b = {};
        e = {};
    }

};
```

```c++
class StateSet
{
public:
State *start;
State *end;

    StateSet()
    {
        this->start = new State();
        this->end = new State();
    }

    StateSet(char x)
    {
        this->start = new State();
        this->end = new State();
        if (x == 'a')
            this->start->a.push_back(this->end);
        if (x == 'b')
            this->start->b.push_back(this->end);
    }

    void OR(StateSet *first, StateSet *second)
    {
        // Make the Start -> first -> end loop
        this->start->e.push_back(first->start);
        first->end->e.push_back(this->end);

        // Make the Start -> second -> end loop
        this->start->e.push_back(second->start);
        second->end->e.push_back(this->end);
    }

    void CONCAT(StateSet *first, StateSet *second)
    {
        // Make the Start -> first
        this->start->e.push_back(first->start);
        // first -> second
        first->end->e.push_back(second->start);
        // second -> end
        second->end->e.push_back(this->end);
    }

    void KLEENESTAR(StateSet *top)
    {
        // Start -> top.start
        this->start->e.push_back(top->start);
        // top.end -> start
        top->end->e.push_back(this->start);
        // start -> end
        this->start->e.push_back(this->end);
    }

    map<int, vector<vector<int>>> performBFS()
    {
        // Map to keep track of all transitions
        map<int, vector<vector<int>>> stateTransitions;
        // Used to perform BFS and keep track of repetitive states
        queue<State *> q;
        map<int, int> mp;

        q.push(this->start);
        mp[this->start->number] = 1;

        while (!q.empty())
        {
            State *curr = q.front();
            q.pop();

            mp[curr->number] = 1;

            // cout << "::> State Number: " << curr->number << endl;
            // Initialize, corresponding to a | b | e
            stateTransitions[curr->number] = {{}, {}, {}};

            for (auto x : curr->a)
            {
                stateTransitions[curr->number][0].push_back(x->number);
                if (!mp[x->number])
                    q.push(x);
            }
            for (auto x : curr->b)
            {
                stateTransitions[curr->number][1].push_back(x->number);
                if (!mp[x->number])
                    q.push(x);
            }
            for (auto x : curr->e)
            {
                stateTransitions[curr->number][2].push_back(x->number);
                if (!mp[x->number])
                    q.push(x);
            }
        }

        return stateTransitions;
    }

};
```

### Assignment 1 - Part 2
- Basic Task using lex