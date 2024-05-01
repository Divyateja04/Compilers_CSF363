# Pascal Compiler 

## Contributors
- Divyateja Pasupuleti - 2021A7PS0075H
- Kumarasamy Chelliah - 2021A7PS0096H
- Adarsh Das - 2021A7PS1511H
- Manan Gupta - 2021A7PS2091H

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
```pas
for i := 1 to 5 do
  begin
    sum := sum + 6 * 7 + numbers[i];
  end;
```
becomes
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