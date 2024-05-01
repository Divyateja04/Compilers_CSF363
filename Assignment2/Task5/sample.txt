program ArrayAverage;
var
  numbers: array[1..5] of char; // TODO: size matters
  i, a, b: Integer;
  average : real;
  c: char;
begin
  i := 4;
  i := i + 1;
  average := 0.5;
  c := 'c';

  numbers[1] := c;
  numbers[2] := 5;

  writeln("Test output: ", i, " ", i, " ", average, " ", c);
  writeln(numbers[1], " ", numbers[2]);
  // writeln("Test output: ", i, " ", i, " ", average, " ", c);
  // // read(a);
  // writeln("Input: ", a);

  // a := 0;
  // b := 0;
  // for i := 1 to 5 do
  // begin
  //   a := a + 1;
  //   b := b + a;
  // end;
  // writeln("Sum: ", b);

  // a := 5;

  // while a > 0 do
  // begin
  //   a := a - 1;
  //   writeln("a: ", a);
  // end;
end.