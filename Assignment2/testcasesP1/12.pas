program Mean;
var
  i, n, sum: integer;
  mean: real;
begin
  n := -20;
  sum := 0;

  a := (-12) + 6;
  
  for i := 1 to n do
  begin
    sum := sum + i;
  end;
  
  mean := sum / n;
  
  write("The mean of the numbers from 1 to 20 is ", mean);
end.