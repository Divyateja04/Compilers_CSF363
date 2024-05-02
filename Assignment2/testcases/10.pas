program forif;
var
  i, j, a, b, x: Integer;
  arr: array[1..20] of Integer;
begin
  x := 1;
  for i := 1 to 20 do
  begin
    if i % 3 = 0 then 
    begin
      j := i + 2; 
      write(j);
      arr[1] := i;
      arr[x] := i;
      arr[1] := i;

      write(a, " ", b, " ", arr[i]);
    end;
  end;

  if i % 3 = 0 then
  begin
    for i := 3 downto 0 do
    begin
      write(i, " ", 5);
    end;
  end
  else
  begin
    for i := 3 downto 0 do
    begin
      write(i, " ", 5);
    end;
  end;
end.