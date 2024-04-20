import os

# all test cases
test_cases = [
'''
program ArrayAverage;
var
  numbers: array[1..5] of Integer;
  i, sum : Integer;
  average : real;
begin
  write("Enter 5 integer values:");
  for i := 1 to 5 do
  begin
    read(numbers[i]);
  end;
  sum := 0;
  for i := 1 to 5 do
  begin
    sum := sum + numbers[i];
  end;
  average := sum / 5;
  write("The sum and average are: "); 
  write(sum, average);
end
''',
'''
program MaxValueArray;
var
  numbers: array[1..10] of Integer;
  i, maxValue: Integer;
begin
  write("Enter 10 integer values:");
  for i := 1 to 10 do
  begin
    read(numbers[i]);
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
end.
'''
,
'''program ReverseNumber;
var
  number, reversedNumber, remainder: Integer;
begin
  write("Enter a number to reverse:");
  read(number);
  reversedNumber := 0;
  while number <> 0 do
  begin
    remainder := number % 10;
    reversedNumber := reversedNumber * 10 + remainder;
    number := number div 10;
  end;
  write("The reversed number is: ");
  write(reversedNumber);
end.

'''
,
'''program NumberOfDigits;
var
  number, count, digit: Integer;
begin
  write("Enter a number:");
  read(number);
  count := 0;
  while number <> 0 do
  begin
    digit := number - (number div 10) * 10;
    
    if digit <> 0 then
      begin
      count:=count+1;
      end;
    number := number / 10;
  end;
  write("The number of digits is: ");
  write(count);
end.'''
,
'''program NumberOfDigits;
var
  number, count: Integer;
begin
  write("Enter a number:");
  read(number);
  count := 0;
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
  write("The number of digits is: ");
  write(count);
end.
'''
,
'''program FactorialCalculation;
var
  number, factorial, i: Integer;
begin
  write("Enter a number to calculate its factorial:");
  read(number);
  factorial := 1;
  for i := number downto 1 do
  begin
    factorial := factorial * i;
  end;
  write("The factorial is: ");
  write(factorial);
end.

'''
,
'''program SumOfSquares;
var
  number, sum, i: Integer;
begin
  write("Enter a number to calculate the sum of squares up to that number:");
  read(number);
  sum := 0;
  for i := 1 to number do
  begin
    sum := sum + (i * i);
  end;
  write("The sum of squares up is");
  write(sum);
end.'''
,
'''
program forif;
var
  i, j: Integer;
begin
  for i := 1 to 20 do
   begin
     if i % 3 = 0 then 
      begin
        j := i + 2; 
        write(j);
      end;
    end;

end.'''
,
'''
program Example9;
var
  i: Integer;
begin
  i := 10;
  if i > 10 then
  begin
    i := 10;
    i := i - 1;
    write(i);
  end
  else
  begin
    i := 20;
    write(i);
  end;
end.
'''
]

# echo "Deleting old files"
# rm -f ADKM3773.out
# echo "Compiling yacc program"
# yacc -d ADKM3773.y -Wconflicts-rr -Wconflicts-sr -Wcounterexamples
# echo "Compiling lex program"
# lex ADKM3773.l
# echo "Compiling the program in gcc"
# gcc y.tab.c lex.yy.c -ll -o ADKM3773.out
# ./ADKM3773.out

for i, test_case in enumerate(test_cases):
    # with open(f'testcases/{i + 1}.txt', 'w') as f:
    #     f.write(test_case)
    #     f.flush()
        
    # print("Writing done for test case", i+1)    
        
    os.system('echo "======================================="')
    os.system(f'echo "Test Case {i+1}"')
    os.system(f'echo "Deleting old files"')
    os.system(f'rm -f ADKM3773.out')
    os.system(f'rm -f y.tab.c')
    os.system(f'rm -f lex.yy.c')
    os.system(f'echo "Compiling yacc program"')
    os.system(f'yacc -d ADKM3773.y -Wconflicts-rr -Wconflicts-sr -Wcounterexamples')
    os.system(f'echo "Compiling lex program"')
    os.system(f'lex ADKM3773.l')
    os.system(f'echo "Compiling the program in gcc"')
    os.system(f'gcc y.tab.c lex.yy.c -ll -o ADKM3773.out')
    os.system(f'./ADKM3773.out')
    