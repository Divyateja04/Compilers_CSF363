program FibonacciSeries;
var
  limit, i, num1, num2, nextTerm: integer;
begin
  write("Enter the limit for Fibonacci series:");
  read(limit);
  num1 := 0;
  num2 := 1;
  writeln("Fibonacci Series:");
  write(num1, " ");
  write(num2, " ");
  for i := 3 to limit do
  begin
    nextTerm := num1 + num2;
    write(nextTerm, " ");
    num1 := num2;
    num2 := nextTerm;
  end;
end.
