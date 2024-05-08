program MaxValueArray;
var
  numbers: array[1..10] of Integer;
  i, maxValue: Integer;
  number:integer;
  i:char;
begin
  write("Enter 10 integer values:",i);
  maxValue := numbers[12];
  for i := 1 to 10 do
  begin
    read(numbers[i]);
    write(numbers[i]);
  end;
  maxValue := numbers[1];
  for i := 2 to 10 do
  begin
    if numbers[i] > maxValue then
    begin
      maxValue := numbers[i];
    end;
  end;
  write("The maximum value is: ");  
  write(maxValue);
  while number <> 0 do
  begin
    if number <> 0 then
    begin
      count:=count+1;
    end
    else 
    begin
     count :=count;
    end; 
    number := number / 10;
  end;
end.
