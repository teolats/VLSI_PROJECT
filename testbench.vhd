library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture sim of testbench is

    constant N : positive := 8;

    component Top_Adder is
        generic (
            N : positive := 8
        );
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            A_in     : in  std_logic_vector(N-1 downto 0);
            B_in     : in  std_logic_vector(N-1 downto 0);
            Cin_in   : in  std_logic;
            S_out    : out std_logic_vector(N-1 downto 0);
            Cout_out : out std_logic
        );
    end component;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal A_in     : std_logic_vector(N-1 downto 0) := (others => '0');
    signal B_in     : std_logic_vector(N-1 downto 0) := (others => '0');
    signal Cin_in   : std_logic := '0';
    signal S_out    : std_logic_vector(N-1 downto 0);
    signal Cout_out : std_logic;

begin

    clk <= not clk after 5 ns;

    DUT : Top_Adder
        generic map (N => N)
        port map (
            clk      => clk,
            rst      => rst,
            A_in     => A_in,
            B_in     => B_in,
            Cin_in   => Cin_in,
            S_out    => S_out,
            Cout_out => Cout_out
        );

    STIMULUS : process
        variable expected : unsigned(N downto 0);

        procedure apply_and_check(
            constant ai : in natural;
            constant bi : in natural;
            constant ci : in std_logic
        ) is
        begin
            A_in   <= std_logic_vector(to_unsigned(ai, N));
            B_in   <= std_logic_vector(to_unsigned(bi, N));
            Cin_in <= ci;

            -- Two clock edges are needed:
            -- edge 1 loads the input registers,
            -- edge 2 loads the output registers.
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait for 1 ns;

            expected := resize(to_unsigned(ai, N), N+1) +
                        resize(to_unsigned(bi, N), N+1);

            if ci = '1' then
                expected := expected + 1;
            end if;

            assert S_out = std_logic_vector(expected(N-1 downto 0))
                report "Wrong SUM for A=" & integer'image(ai) &
                       " B=" & integer'image(bi) &
                       " Cin=" & std_logic'image(ci)
                severity error;

            assert Cout_out = expected(N)
                report "Wrong COUT for A=" & integer'image(ai) &
                       " B=" & integer'image(bi) &
                       " Cin=" & std_logic'image(ci)
                severity error;
        end procedure;

    begin
        rst <= '1';
        wait for 20 ns;
        wait until rising_edge(clk);
        rst <= '0';

        apply_and_check(0,   0,   '0');
        apply_and_check(1,   1,   '0');
        apply_and_check(15,  1,   '1');
        apply_and_check(85,  42,  '0');
        apply_and_check(127, 1,   '1');
        apply_and_check(255, 0,   '1');
        apply_and_check(255, 255, '0');
        apply_and_check(255, 255, '1');

        report "Simulation finished successfully." severity note;
        wait;
    end process;

end sim;
