library ieee;
use ieee.std_logic_1164.all;

entity Full_Adder is
    port (
        a    : in  std_logic;
        b    : in  std_logic;
        cin  : in  std_logic;
        sum  : out std_logic;
        cout : out std_logic
    );
end Full_Adder;

architecture Dataflow of Full_Adder is
begin
    sum  <= a xor b xor cin;
    cout <= (a and b) or (a and cin) or (b and cin);
end Dataflow;
