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
   end;

   if a then begin
	   write("only identifier without brackets");
   end;

   if arr[i] then begin
	   write("only array without brackets");
   end;

   if arr[i] and a then begin
	   write("array with boolean 1");
   end;

   if not doors[i] or not doors[i] then begin
	   write("array with boolean 2");
   end;

   while i < 3 do begin
      write('hello');
   end;

   while i < 3 do begin
      write('hello');
   end;

   if (a + v + x) - d = 1 and a = 1 then begin
	   write("expression");
   end;

   if (a +( v + x) - d) = 1 and a = 1 then begin
	   write("expression");
   end;


   if (a + v + (x) - d) = 1 then begin
	   write("expression");
   end;

   if not doors[i] or not doors[i] then begin
	   write("array with boolean and bracket");
   end;

   if not doors[i] or not doors[i] then begin
	   write("array with boolean and bracket");
   end;
   write('inside single quore');
end.
