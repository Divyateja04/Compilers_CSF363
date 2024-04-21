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
      if doors[i] and not doors[i] then begin
	 write("open");
    end
      else begin
	 write("closed"); end;
   end;
   if a + v + x - d = 1 then begin
	 write("open");
    end;
   if not doors[i] or not doors[i] then begin
	 write("open");
    end;

   if not doors[i] or not doors[i] and 3 then begin
	 write("open");
    end;
   while i < 3 do begin
      write('hello');
   end;
   write('inside single quore');
   

end.
