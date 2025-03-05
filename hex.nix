let
  export = {
    digit =
      x:
      assert 0 <= x && x < 16;
      builtins.substring x 1 "0123456789abcdef";
  };
in

assert export.digit 0 == "0";
assert export.digit 1 == "1";
assert export.digit 10 == "a";
assert export.digit 15 == "f";
export
