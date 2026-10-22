library ieee;
use ieee.std_logic_1164.all;

entity CS_Combine is
    generic (
        W : positive := 1
    );
    port (
        lo_s0  : in  std_logic_vector(W-1 downto 0);
        lo_s1  : in  std_logic_vector(W-1 downto 0);
        lo_c0  : in  std_logic;
        lo_c1  : in  std_logic;

        hi_s0  : in  std_logic_vector(W-1 downto 0);
        hi_s1  : in  std_logic_vector(W-1 downto 0);
        hi_c0  : in  std_logic;
        hi_c1  : in  std_logic;

        s0     : out std_logic_vector(2*W-1 downto 0);
        s1     : out std_logic_vector(2*W-1 downto 0);
        cout0  : out std_logic;
        cout1  : out std_logic
    );
end CS_Combine;

architecture Structural of CS_Combine is

    component MUX2 is
        generic (
            N : positive := 1
        );
        port (
            d0  : in  std_logic_vector(N-1 downto 0);
            d1  : in  std_logic_vector(N-1 downto 0);
            sel : in  std_logic;
            y   : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal upper_s0 : std_logic_vector(W-1 downto 0);
    signal upper_s1 : std_logic_vector(W-1 downto 0);

    signal hi_c0_vec   : std_logic_vector(0 downto 0);
    signal hi_c1_vec   : std_logic_vector(0 downto 0);
    signal cout0_vec   : std_logic_vector(0 downto 0);
    signal cout1_vec   : std_logic_vector(0 downto 0);

begin

    -- The lower half is already known for each assumed carry-in.
    s0(W-1 downto 0) <= lo_s0;
    s1(W-1 downto 0) <= lo_s1;

    -- Convert 1-bit carry signals to 1-bit vectors, because MUX2 is generic.
    hi_c0_vec(0) <= hi_c0;
    hi_c1_vec(0) <= hi_c1;

    -- Whole block result if the carry entering the lower block is 0:
    -- lo_c0 selects which precomputed upper-half result is correct.
    MUX_UPPER_SUM_FOR_CIN0 : MUX2
        generic map (N => W)
        port map (
            d0  => hi_s0,
            d1  => hi_s1,
            sel => lo_c0,
            y   => upper_s0
        );

    MUX_UPPER_CARRY_FOR_CIN0 : MUX2
        generic map (N => 1)
        port map (
            d0  => hi_c0_vec,
            d1  => hi_c1_vec,
            sel => lo_c0,
            y   => cout0_vec
        );

    -- Whole block result if the carry entering the lower block is 1:
    -- lo_c1 selects which precomputed upper-half result is correct.
    MUX_UPPER_SUM_FOR_CIN1 : MUX2
        generic map (N => W)
        port map (
            d0  => hi_s0,
            d1  => hi_s1,
            sel => lo_c1,
            y   => upper_s1
        );

    MUX_UPPER_CARRY_FOR_CIN1 : MUX2
        generic map (N => 1)
        port map (
            d0  => hi_c0_vec,
            d1  => hi_c1_vec,
            sel => lo_c1,
            y   => cout1_vec
        );

    s0(2*W-1 downto W) <= upper_s0;
    s1(2*W-1 downto W) <= upper_s1;

    cout0 <= cout0_vec(0);
    cout1 <= cout1_vec(0);

end Structural;
