program forif;
var
  i, j, a, b, x: Integer;
  arr: array[1..20] of Integer;
begin
  for i := 1 to 20 do
  begin
    if i mod 3 = 0 then 
    begin
      j := i + 2; 
      writeln(j);
      arr[1] := i;
      arr[x] := i;
      arr[1] := i;

      write(a, ' ', b, ' ', arr[i]);
    end;
  end;

  if i mod 3 = 0 then
    for i := 3 downto 0 do
    begin
      write(i, ' ', 5);
    end
  else
    for i := 3 downto 0 do
    begin
      write(i, ' ', 5);
    end;
end.