Program OneHundredDoors;
var
   doors : Array[1..100] of Boolean;
   i, j	 : Integer;
begin
   for i := 1 to 100 do begin
      j := i;
      while j <= 100 do begin
	 doors[j] := not doors[j];
	 j := j + i
      end
   end;
   for i := 1 to 100 do begin
      write(i, " ");
      if doors[i] then
	 write("open")
      else
	 write("closed");
   end
end.