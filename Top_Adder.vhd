library ieee;
use ieee.std_logic_1164.all;

entity Top_Adder is
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
end Top_Adder;

architecture Structural of Top_Adder is

    component QD is
        generic (
            n : positive := 8
        );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            d   : in  std_logic_vector(n-1 downto 0);
            q   : out std_logic_vector(n-1 downto 0)
        );
    end component;

    component CSA_8bit is
        port (
            a    : in  std_logic_vector(7 downto 0);
            b    : in  std_logic_vector(7 downto 0);
            cin  : in  std_logic;
            s    : out std_logic_vector(7 downto 0);
            cout : out std_logic
        );
    end component;

    signal A_reg      : std_logic_vector(N-1 downto 0);
    signal B_reg      : std_logic_vector(N-1 downto 0);
    signal Cin_d      : std_logic_vector(0 downto 0);
    signal Cin_reg    : std_logic_vector(0 downto 0);

    signal S_comb     : std_logic_vector(N-1 downto 0);
    signal Cout_comb  : std_logic;
    signal Cout_d     : std_logic_vector(0 downto 0);
    signal Cout_reg   : std_logic_vector(0 downto 0);

begin

    assert N = 8
        report "This Top_Adder uses the fixed 8-bit CSA_8bit core, so N must be 8."
        severity failure;

    Cin_d(0)  <= Cin_in;
    Cout_d(0) <= Cout_comb;

    -- Input registers
    REG_A : QD
        generic map (n => N)
        port map (
            clk => clk,
            rst => rst,
            d   => A_in,
            q   => A_reg
        );

    REG_B : QD
        generic map (n => N)
        port map (
            clk => clk,
            rst => rst,
            d   => B_in,
            q   => B_reg
        );

    REG_CIN : QD
        generic map (n => 1)
        port map (
            clk => clk,
            rst => rst,
            d   => Cin_d,
            q   => Cin_reg
        );

    -- Combinational Conditional-Sum Adder core
    ADDER_CORE : CSA_8bit
        port map (
            a    => A_reg,
            b    => B_reg,
            cin  => Cin_reg(0),
            s    => S_comb,
            cout => Cout_comb
        );

    -- Output registers
    REG_SUM : QD
        generic map (n => N)
        port map (
            clk => clk,
            rst => rst,
            d   => S_comb,
            q   => S_out
        );

    REG_COUT : QD
        generic map (n => 1)
        port map (
            clk => clk,
            rst => rst,
            d   => Cout_d,
            q   => Cout_reg
        );

    Cout_out <= Cout_reg(0);

end Structural;
