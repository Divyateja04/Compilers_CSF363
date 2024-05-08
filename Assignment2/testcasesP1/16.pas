program ArrayAverage;
var
  grade : char ;
  isready : boolean ;
  numbers : array [1..10] of Integer ;
  number, i, sum : Integer;
  maxValue : real;
  // the programs starts here
begin
  number := 10;
  while number <> 0 do
  begin
   write(number, " | ");
   number := number - 1;
  end;
  // the program ends here
end.
