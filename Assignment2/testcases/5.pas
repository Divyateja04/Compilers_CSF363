program NumberOfDigits;
var
  number, count: Integer;
begin
  write("Enter a number:");
  read(number);
  count := 0;
  while number <> 0 do
  begin
    number := number / 10;
    count := count + 1;
  end;
  write("The number of digits is: ");
  write(count);
end.
