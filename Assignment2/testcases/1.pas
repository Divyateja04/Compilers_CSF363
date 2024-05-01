program ArrayAverage;
var
  numbers: array[1..5] of Integer;
  i, a, b: Integer;
  average : real;
  c: char;
begin
  i := 4;
  i := i + 1;
  average := 0.5;
  c := 'c';

  numbers[1] := 1;

  writeln("Test output: ", i, " ", i, " ", average, " ", c);
  writeln("Test output: ", i, " ", i, " ", average, " ", c);
  // read(a);
  writeln("Input: ", a);
end.