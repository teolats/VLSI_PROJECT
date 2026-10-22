library ieee;
use ieee.std_logic_1164.all;

entity QD is
    generic (
        n : positive := 8
    );
    port (
        clk : in  std_logic;
        rst : in  std_logic;
        d   : in  std_logic_vector(n-1 downto 0);
        q   : out std_logic_vector(n-1 downto 0)
    );
end QD;

architecture Behavioral of QD is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            q <= (others => '0');
        elsif rising_edge(clk) then
            q <= d;
        end if;
    end process;
end Behavioral;
