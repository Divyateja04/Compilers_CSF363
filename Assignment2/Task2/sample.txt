program AllTypes;

var
  i1, i2, i3, i4: Integer;
  r1, r2, r3, r4: Real;
  c1, c2: Char;
  b1: Boolean;
  s1, s2: String;

begin
  i1 := 2147483647; // Maximum positive integer value (for overflow)
  i2 := -2147483648; // Maximum negative integer value (for underflow)
  i3 := 5; // Normal integer assn
  i4 := -5; // Normal integer assn but negative
  r1 := 1.79769E308; // Maximum positive real value (for overflow)
  r2 := -1.79769E308; // Maximum negative real value (for underflow)
  r3 := 5.0; // Normal floating point assignment
  r4 := -5.0; // Normal floating point assignment, but negative
  c1 := '\''; // Character with escape sequence: \'
  c2 := 'c';
  b1 := True; // Boolean value
  s1 := ''; // Empty string
  s2 := '"Hello" World'
end.
