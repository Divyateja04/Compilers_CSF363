Program OneHundredDoors;
var
   doors : Array[1..100] of Boolean;
   i, j	 : Integer;
begin
   for i := 1 to 100 do begin
      j := i;
	 j := j + i;
   end;
   for i := 1 to 100 do begin
      write(i, " ");
      if doors[i] then begin
	 write("open");
    end
      else begin
	 write("closed"); end;
   end;
end.