#include <bits/stdc++.h>
#define endl "\n"
using namespace std;

// GLOBAL VARIABLES
int stateCounter = 0;
int startStateInNFA;
vector<int> finalStateInNFA;

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

    map<int, vector<vector<int>>> performBFS()
    {
        // Map to keep track of all transitions
        map<int, vector<vector<int>>> stateTransitions;
        // Used to perform BFS and keep track of repetitive states
        queue<State *> q;
        map<int, int> mp;

        q.push(this->start);
        mp[this->start->number] = 1;

        cout << "::> Start State: " << this->start->number << endl;
        startStateInNFA = this->start->number;
        // We add the final state to ends
        cout << "::> End State: " << this->end->number << endl;
        finalStateInNFA.push_back(this->end->number);
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
            finalStateInNFA.push_back(startStateInNFA);

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
    if (c == '*')
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
    string postfix;

    stack<char> s;
    for (auto x : input)
    {
        // If character is operator print
        if (('a' <= x && x <= 'z') || (x >= 'A' && x <= 'Z') || (x >= '0' && x <= '9'))
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
            cout << "::> Found a KLEENE STAR" << endl;
            StateSet *top = s.top();
            s.pop();
            StateSet *final = new StateSet();
            final->KLEENESTAR(top);
            s.push(final);
        }
    }

    if (s.empty() || s.size() > 1)
    {
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
    cout << "[ ";
    for (auto x : currentSet)
    {
        cout << x << ' ';
    }
    cout << "]";
}

map<char, vector<char>> convertNFAtoDFA(map<char, int> &finalStates, map<int, vector<vector<int>>> stateTransitions)
{
    // We need to somehow get all epsilon closures
    cout << endl
         << "::> Epsilon Closures: " << endl;

    vector<vector<int>> epsilonClosures;
    for (int i = 0; i < stateTransitions.size(); i++)
    {
        vector<int> perState;
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

        cout << "{ ";
        for (auto x : mp)
        {
            cout << x.first << ' ';
            perState.push_back(x.first);
        }
        cout << "} ";
        cout << endl;
        epsilonClosures.push_back(perState);
    }

    queue<set<int>> q;
    map<set<int>, int> mapOfStatesVisited;

    char stateLetter = 'A';
    q.push({startStateInNFA});
    mapOfStatesVisited[{startStateInNFA}] = stateLetter++;

    map<char, vector<char>> theResultantDFA;
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
        cout << " ";
        printSet(nextSet0);
        cout << " ";
        printSet(nextSet1);
        cout << endl;

        theResultantDFA[(char)mapOfStatesVisited[currentSet]] = {
            (char)mapOfStatesVisited[nextSet0],
            (char)mapOfStatesVisited[nextSet1]};
    }

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

bool runStringOnDFA(string input, map<char, int> finalStates, map<char, vector<char>> theResultantDFA)
{

    // Print the DFA
    cout << endl
         << "::> Found the following DFA:" << endl;
    for (auto x : theResultantDFA)
    {
        cout << x.first << ' ';
        for (auto y : theResultantDFA[x.first])
        {
            cout << y << ' ';
        }
        cout << endl;
    }
    cout << endl;

    // Print final States
    cout << "Final States: ";
    for (auto x : finalStates)
    {
        cout << x.first << ' ';
    }
    cout << endl
         << endl;

    char currentState = 'A';
    cout << "::> Flow: ";
    for (int i = 0; i < input.length(); i++)
    {
        cout << "->" << currentState;
        int currentChar = input[i] - 'a';
        currentState = theResultantDFA[currentState][currentChar];
    }
    cout << "->" << currentState;
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
    cout << "Reg Exp. " << regexp << endl;
    cout << "Testcase: " << testcase << endl;

    // Step 1: Convert infix to Postfix
    string postfix = infixToPostfix(regexp);
    cout << "Postfix: " << postfix << endl;

    // Step 2: Generate the State Set Structure
    StateSet *output = createNFA(postfix);

    // Step 3: Perform BFS on this structure
    map<int, vector<vector<int>>> stateTransitions = output->performBFS();

    // Step 4: Print the NFA with e transitions
    cout << "::> Found the following NFA with e Transitions: " << endl;
    for (int i = 0; i < stateTransitions.size(); i++)
    {
        cout << "::> State: " << i << " ";
        for (auto x : stateTransitions[i])
        {
            cout << "{ ";
            for (auto y : x)
            {
                cout << y << ' ';
            }
            cout << "} ";
        }
        cout << endl;
    }

    // Step 5: Convert NFA to DFA
    map<char, int> finalStates;
    map<char, vector<char>>
        theResultantDFA = convertNFAtoDFA(finalStates, stateTransitions);

    // Step 6: Run string on DFA
    bool res = runStringOnDFA(testcase, finalStates, theResultantDFA);

    cout << "::> Resetting State numbers" << endl;
    stateCounter = 0;

    return res;
}

int main()
{
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);

    // Input parameters
    string input;
    cin >> input;
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

    for (auto c : regex)
    {
        cout << c << endl;
    }

    if (runTheModel(regex[0], input))
    {
        cout << "Output: YES" << endl;
    }
    else
    {
        cout << "Output: NO" << endl;
    }

    cout << "--------------------- END TEST CASE "
         << " ---------------------" << endl
         << endl;
}