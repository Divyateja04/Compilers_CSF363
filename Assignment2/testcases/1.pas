program ArrayAverage;
var
  numbers: array[1..5] of Integer;
  i, a, b: Integer;
  average : real;
  c: char;
begin
  i := 100;
  average := 0.5;
  c := 'c';

  writeln("Test output: ", i, " ", i, " ", average, " ", c);
  writeln("Test output: ", i, " ", i, " ", average, " ", c);
  read(a);
  writeln("Input: ", a);

  if i > 0 then
  begin
    a := 0;
  end;

  for i := 1 to 5 do
  begin
    a := a + i;
    average := average / 2;
  end;
  writeln("Average: ", average);

  while a > 0 do
  begin
    a := a - 1;
    average := average * 2;
  end;
  writeln("Average: ", average);

  a := -1;
  if a < 0 then
  begin
    a := 0;
  end;
end.