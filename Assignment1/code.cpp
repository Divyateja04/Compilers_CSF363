#include <bits/stdc++.h>
using namespace std;

// GLOBAL VARIABLES
int stateCounter = 0;
int startStateInNFA;
set<int> finalStateInNFA;

bool shouldPrintLogs = false;

class State
{
public:
    int number;
    vector<State *> a;
    vector<State *> b;
    vector<State *> e;

    State()
    {
        number = stateCounter++;
        a = {};
        b = {};
        e = {};
    }
};

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

    void ZEROORONE(StateSet *top)
    {
        // Start -> top.start
        this->start->e.push_back(top->start);
        // top.end -> end
        top->end->e.push_back(this->end);
        // start -> end
        this->start->e.push_back(this->end);
    }

    void POSITIVECLOSURE(StateSet *top)
    {
        // Start -> top.start
        this->start->e.push_back(top->start);
        // top.end -> end
        top->end->e.push_back(this->end);
        // start -> end
        this->end->e.push_back(this->start);
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

        if (shouldPrintLogs)
            cout << "::> Start State: " << this->start->number << endl;
        startStateInNFA = this->start->number;
        // We add the final state to ends
        if (shouldPrintLogs)
            cout << "::> End State: " << this->end->number << endl;
        finalStateInNFA.clear();
        finalStateInNFA.insert(this->end->number);
        // We also have to check if start state has an epsilon transition to the final state, which
        // basically means empty string is accepted
        bool startStateIsFinal = false;
        for (auto x : this->start->e)
        {
            if (x->number == this->end->number)
            {
                startStateIsFinal = true;
            }
        }
        if (startStateIsFinal)
            finalStateInNFA.insert(startStateInNFA);

        while (!q.empty())
        {
            State *curr = q.front();
            q.pop();

            mp[curr->number] = 1;

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

// Function to return precedence of operators
int prec(char c)
{
    if (c == '*' || c == '?' || c == '+')
        return 3;
    else if (c == '.')
        return 2;
    else if (c == '|')
        return 1;
    else
        return -1;
}

// Function to convert infix to Post fix
string infixToPostfix(string input)
{
    if (shouldPrintLogs)
        cout << "::> Converting infix to postfix" << endl;
    string postfix;

    stack<char> s;
    for (auto x : input)
    {
        // If character is operator print
        if (x == 'a' || x == 'b')
        {
            postfix += x;
        }
        else if (x == '(')
            s.push(x);
        else if (x == ')')
        {
            while (s.top() != '(')
            {
                postfix += s.top();
                s.pop();
            }
            s.pop();
        }
        else
        {
            while (!s.empty() && prec(x) < prec(s.top()) || !s.empty() && prec(x) == prec(s.top()))
            {
                postfix += s.top();
                s.pop();
            }
            s.push(x);
        }
    }

    // Pop all the remaining elements from the stack
    while (!s.empty())
    {
        postfix += s.top();
        s.pop();
    }
    if (shouldPrintLogs)
        cout << "::> Converted infix to prefix" << endl;
    // Return the postfix expression
    return postfix;
}

StateSet *createNFA(string postfix)
{
    stack<StateSet *> s;
    for (auto x : postfix)
    {
        if (x == 'a' || x == 'b')
            s.push(new StateSet(x));
        else if (x == '|')
        {
            if (shouldPrintLogs)
                cout << "::> Found an OR" << endl;
            StateSet *first = s.top();
            s.pop();
            StateSet *second = s.top();
            s.pop();
            StateSet *final = new StateSet();
            final->OR(first, second);
            s.push(final);
        }
        else if (x == '.')
        {
            if (shouldPrintLogs)
                cout << "::> Found a CONCAT" << endl;
            StateSet *first = s.top();
            s.pop();
            StateSet *second = s.top();
            s.pop();
            StateSet *final = new StateSet();
            final->CONCAT(second, first);
            s.push(final);
        }
        else if (x == '*')
        {
            if (shouldPrintLogs)
                cout << "::> Found a KLEENE STAR" << endl;
            StateSet *top = s.top();
            s.pop();
            StateSet *final = new StateSet();
            final->KLEENESTAR(top);
            s.push(final);
        }
        else if (x == '?')
        {
            if (shouldPrintLogs)
                cout << "::> Found a ZERO OR ONE" << endl;
            StateSet *top = s.top();
            s.pop();
            StateSet *final = new StateSet();
            final->ZEROORONE(top);
            s.push(final);
        }
        else if (x == '+')
        {
            if (shouldPrintLogs)
                cout << "::> Found a POSITIVE CLOSURE" << endl;
            StateSet *top = s.top();
            s.pop();
            StateSet *final = new StateSet();
            final->POSITIVECLOSURE(top);
            s.push(final);
        }
    }

    if (s.empty() || s.size() > 1)
    {
        if (shouldPrintLogs)
            cout << "ERROR OCCURRED: Found " << s.size() << " elements." << endl;
        return nullptr;
    }
    else
    {
        return s.top();
    }
}

void printSet(set<int> currentSet)
{
    if (shouldPrintLogs)
        cout << "[ ";
    for (auto x : currentSet)
    {
        if (shouldPrintLogs)
            cout << x << ' ';
    }
    if (shouldPrintLogs)
        cout << "]";
}

map<char, vector<char>> convertNFAtoDFA(map<char, int> &finalStates, map<int, vector<vector<int>>> stateTransitions)
{
    // We need to somehow get all epsilon closures
    if (shouldPrintLogs)
        cout << endl
             << "::> Epsilon Closures: " << endl;

    vector<vector<int>> epsilonClosures;
    for (int i = 0; i < stateTransitions.size(); i++)
    {
        vector<int> perState;
        if (shouldPrintLogs)
            cout << "::> State: " << i << " ";
        // Map to keep track of visited states
        map<int, int> mp;
        // Queue for all possible states
        queue<int> tq;
        for (auto x : stateTransitions[i][2])
        {
            tq.push(x);
        }
        while (!tq.empty())
        {
            int currState = tq.front();
            tq.pop();
            mp[currState] = 1;

            for (auto x : stateTransitions[currState][2])
            {
                if (!mp[x])
                {
                    tq.push(x);
                }
            }
        }

        if (shouldPrintLogs)
            cout << "{ ";
        for (auto x : mp)
        {
            if (shouldPrintLogs)
                cout << x.first << ' ';
            perState.push_back(x.first);
        }
        if (shouldPrintLogs)
            cout << "} ";
        if (shouldPrintLogs)
            cout << endl;
        epsilonClosures.push_back(perState);
    }

    queue<set<int>> q;
    map<set<int>, int> mapOfStatesVisited;

    char stateLetter = 'A';
    q.push({startStateInNFA});
    mapOfStatesVisited[{startStateInNFA}] = stateLetter++;

    map<char, vector<char>> theResultantDFA;
    if (shouldPrintLogs)
        cout << endl
             << "::> Printing the RAW DFA: " << endl;

    while (!q.empty())
    {
        set<int> currentSet = q.front();
        q.pop();

        set<int>
            nextSet0, nextSet1;
        for (auto x : currentSet)
        {
            // Here we add all transitions of a and then their epsilon transitions
            for (auto y : stateTransitions[x][0])
            {
                nextSet0.insert(y);
                for (auto z : epsilonClosures[y])
                {
                    nextSet0.insert(z);
                }
            }
            // Here we add all transitions of b and then their epsilon transitions
            for (auto y : stateTransitions[x][1])
            {
                nextSet1.insert(y);
                for (auto z : epsilonClosures[y])
                {
                    nextSet1.insert(z);
                }
            }
            // We should also add all epsilon first then letter wala transitions
            for (auto y : epsilonClosures[x])
            {
                for (auto z : stateTransitions[y][0])
                {
                    nextSet0.insert(z);
                }
                for (auto z : stateTransitions[y][1])
                {
                    nextSet1.insert(z);
                }
            }
        }

        for (auto x : nextSet0)
        {
            for (auto y : epsilonClosures[x])
            {
                nextSet0.insert(y);
            }
        }
        for (auto x : nextSet1)
        {
            for (auto y : epsilonClosures[x])
            {
                nextSet1.insert(y);
            }
        }

        if (mapOfStatesVisited.find(nextSet0) == mapOfStatesVisited.end())
        {
            q.push(nextSet0);
            mapOfStatesVisited[nextSet0] = stateLetter++;
        }
        if (mapOfStatesVisited.find(nextSet1) == mapOfStatesVisited.end())
        {
            q.push(nextSet1);
            mapOfStatesVisited[nextSet1] = stateLetter++;
        }

        // Printing the DFA
        printSet(currentSet);
        if (shouldPrintLogs)
            cout << " ";
        printSet(nextSet0);
        if (shouldPrintLogs)
            cout << " ";
        printSet(nextSet1);
        if (shouldPrintLogs)
            cout << endl;

        theResultantDFA[(char)mapOfStatesVisited[currentSet]] = {
            (char)mapOfStatesVisited[nextSet0],
            (char)mapOfStatesVisited[nextSet1]};
    }

    // Print all final states
    if (shouldPrintLogs)
        cout << "::> Final States in the NFA: " << endl;
    for (auto x : finalStateInNFA)
    {
        if (shouldPrintLogs)
            cout << x << " ";
    }
    if (shouldPrintLogs)
        cout << endl;

    for (auto x : mapOfStatesVisited)
    {
        int isFinalState = 0;
        for (auto v : x.first)
        {
            for (auto finalState : finalStateInNFA)
            {
                if (v == finalState)
                {
                    isFinalState = 1;
                }
            }
        }

        if (isFinalState)
        {
            finalStates[(char)mapOfStatesVisited[x.first]] = 1;
        }
    }

    return theResultantDFA;
}

bool runStringOnDFA(string input, map<char, int> &finalStates, map<char, vector<char>> theResultantDFA)
{

    // Print the DFA
    if (shouldPrintLogs)
        cout << endl
             << "::> Found the following DFA:" << endl;
    for (auto x : theResultantDFA)
    {
        if (shouldPrintLogs)
            cout << x.first << ' ';
        for (auto y : theResultantDFA[x.first])
        {
            if (shouldPrintLogs)
                cout << y << ' ';
        }
        if (shouldPrintLogs)
            cout << endl;
    }
    if (shouldPrintLogs)
        cout << endl;

    // Print final States
    if (shouldPrintLogs)
        cout << "Final States: ";
    for (auto x : finalStates)
    {
        if (shouldPrintLogs)
            cout << x.first << ' ';
    }
    if (shouldPrintLogs)
        cout << endl
             << endl;

    char currentState = 'A';
    if (shouldPrintLogs)
        cout << "::> Flow: ";
    for (int i = 0; i < input.length(); i++)
    {
        if (shouldPrintLogs)
            cout << "->" << currentState;
        int currentChar = input[i] - 'a';
        currentState = theResultantDFA[currentState][currentChar];
    }
    if (shouldPrintLogs)
        cout << "->" << currentState;
    if (shouldPrintLogs)
        cout << endl;

    if (finalStates[currentState])
    {
        return true;
    }
    else
    {
        return false;
    }
}

bool runTheModel(string regexp, string testcase)
{
    if (shouldPrintLogs)
        cout << "Reg Exp. " << regexp << endl;
    if (shouldPrintLogs)
        cout << "Testcase: " << testcase << endl;

    // Step 1: Convert infix to Postfix
    string postfix = infixToPostfix(regexp);
    if (shouldPrintLogs)
        cout << "Postfix: " << postfix << endl;

    // Step 2: Generate the State Set Structure
    StateSet *output = createNFA(postfix);
    if (shouldPrintLogs)
        cout << "::> Generated NFA successfully" << endl;

    // Step 3: Perform BFS on this structure
    map<int, vector<vector<int>>> stateTransitions = output->performBFS();

    // Step 4: Print the NFA with e transitions
    if (shouldPrintLogs)
        cout << "::> Found the following NFA with e Transitions: " << endl;
    for (int i = 0; i < stateTransitions.size(); i++)
    {
        if (shouldPrintLogs)
            cout << "::> State: " << i << " ";
        for (auto x : stateTransitions[i])
        {
            if (shouldPrintLogs)
                cout << "{ ";
            for (auto y : x)
            {
                if (shouldPrintLogs)
                    cout << y << ' ';
            }
            if (shouldPrintLogs)
                cout << "} ";
        }
        if (shouldPrintLogs)
            cout << endl;
    }

    // Step 5: Convert NFA to DFA
    map<char, int> finalStates;
    map<char, vector<char>>
        theResultantDFA = convertNFAtoDFA(finalStates, stateTransitions);

    // Step 6: Run string on DFA
    bool res = runStringOnDFA(testcase, finalStates, theResultantDFA);

    if (shouldPrintLogs)
        cout << "::> Resetting State numbers" << endl;
    stateCounter = 0;

    return res;
}

int main()
{
    freopen("input2.txt", "r", stdin);
    freopen("output2.txt", "w", stdout);

    // Input parameters
    string input;
    cin >> input;
    if (shouldPrintLogs)
        cout << "Input: " << input << endl;

    vector<string> regex;
    string temp;

    while (cin >> temp)
    {
        regex.push_back(temp);
    }

    for (int i = 0; i < regex.size(); i++)
    {
        string temp = regex[i];

        for (int j = 1; j < temp.size(); j++)
        {
            if (temp[j] == '(' && temp[j - 1] == ')')
            {
                temp = temp.substr(0, j) + "." + temp.substr(j, temp.size() - j);
            }
        }
        regex[i] = temp;
    }

    if (shouldPrintLogs)
        cout << "Printing Regex:  " << endl;
    for (auto c : regex)
    {
        if (shouldPrintLogs)
            cout << c << endl;
    }
    if (shouldPrintLogs)
        cout << endl;

    size_t len = input.size();

    map<string, int> lastaccpeted;
    vector<pair<string, int>> finaloutput;

    int start = 0;
    int end = len - 1;

    while (start <= end)
    {
        string temp = input.substr(start, end - start + 1);
        bool flag = false;

        for (size_t k = 0; k < regex.size(); k++)
        {
            if (runTheModel(regex[k], temp))
            {
                // lastaccpeted[temp] = k;
                pair<string, int> p = {temp, k + 1};
                finaloutput.push_back(p);
                start = end + 1;
                end = len - 1;
                flag = true;
                break;
            }
        }

        if (start == end && flag == false)
        {
            pair<string, int> p = {temp, 0};
            finaloutput.push_back(p);
            start++;
            end = len - 1;
        }
        else if (!flag)
        {
            end--;
        }
    }

    for (auto p : finaloutput)
    {
        cout << "<" << p.first << "," << p.second << ">";
    }
    cout << endl;

    if (shouldPrintLogs)
        cout << "--------------------- END TEST CASE "
             << " ---------------------" << endl
             << endl;
}