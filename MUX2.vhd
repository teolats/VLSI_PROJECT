library ieee;
use ieee.std_logic_1164.all;

entity MUX2 is
    generic (
        N : positive := 1
    );
    port (
        d0  : in  std_logic_vector(N-1 downto 0);
        d1  : in  std_logic_vector(N-1 downto 0);
        sel : in  std_logic;
        y   : out std_logic_vector(N-1 downto 0)
    );
end MUX2;

architecture Structural of MUX2 is
begin
    GEN_MUX_BITS : for i in 0 to N-1 generate
    begin
        y(i) <= (d0(i) and (not sel)) or (d1(i) and sel);
    end generate;
end Structural;
