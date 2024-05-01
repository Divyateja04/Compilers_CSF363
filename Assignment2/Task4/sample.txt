program ArrayAverage;
var
  numbers: array[1..5] of Integer;
  i, a, b, d, sum, digit, number, count : Integer;
  average : real;
  x: boolean;
  c: char;
begin
  i := 100;
  i := i + i * (i - i) + (i - i) * d;
  x := (7 < 5) and (6 > 5);
  a := -3;
  count := 0;
  number := 0;
  digit := 0.0;

  numbers[3] := 7;

  write("Enter 5 integer values:");

  c := 'c';
  write(c);

  for i := 1 to 5 do
  begin
    read(numbers[i]);
  end;

  for i := 1 to 5 do
  begin
    write(numbers[i]);
  end;

  sum := 0;
  for i := 1 to 5 do
  begin
    sum := sum + 6 * 7 + numbers[i];
  end;

  if x then
  begin
    write("x is true");
  end
  else
  begin
    write("x is false");
  end;


  while number <> 0 do
  begin
    digit := number - (number / 10) * 10;
    
    if digit <> 0 then
    begin
      count:=count+1;
    end;

    number := number / 10;
  end;

  average := sum / 5;
  write("The sum and average are: "); 
  write(sum, average);
end.