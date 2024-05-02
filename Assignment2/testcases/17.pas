program PrimeNumberChecker;
var
  num, i: integer;
  isPrime: boolean;
begin
  write("Enter a number:");
  read(num);
  isPrime := true;
  if num <= 1 then
  begin
    isPrime := false;
  end
  else
  begin
    for i := 2 to num / 2 do
    begin
      if num % i = 0 then
      begin
        isPrime := false;
      end;
    end;
  end;

  if isPrime then
  begin
    writeln(num, " is a prime number");
  end
  else
  begin
    writeln(num, " is not a prime number");
  end;
end.
