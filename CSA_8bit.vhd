library ieee;
use ieee.std_logic_1164.all;

entity CSA_8bit is
    port (
        a    : in  std_logic_vector(7 downto 0);
        b    : in  std_logic_vector(7 downto 0);
        cin  : in  std_logic;
        s    : out std_logic_vector(7 downto 0);
        cout : out std_logic
    );
end CSA_8bit;

architecture Structural of CSA_8bit is

    component Full_Adder is
        port (
            a    : in  std_logic;
            b    : in  std_logic;
            cin  : in  std_logic;
            sum  : out std_logic;
            cout : out std_logic
        );
    end component;

    component CS_Combine is
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
    end component;

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

    -- Level 0: one-bit results from the two Full Adders of every bit.
    signal bit_s0 : std_logic_vector(7 downto 0);
    signal bit_s1 : std_logic_vector(7 downto 0);
    signal bit_c0 : std_logic_vector(7 downto 0);
    signal bit_c1 : std_logic_vector(7 downto 0);

    -- Level 1: four 2-bit conditional-sum blocks.
    signal l1_s0 : std_logic_vector(7 downto 0);
    signal l1_s1 : std_logic_vector(7 downto 0);
    signal l1_c0 : std_logic_vector(3 downto 0);
    signal l1_c1 : std_logic_vector(3 downto 0);

    -- Level 2: two 4-bit conditional-sum blocks.
    signal l2_s0 : std_logic_vector(7 downto 0);
    signal l2_s1 : std_logic_vector(7 downto 0);
    signal l2_c0 : std_logic_vector(1 downto 0);
    signal l2_c1 : std_logic_vector(1 downto 0);

    -- Level 3: one 8-bit conditional-sum block.
    signal l3_s0 : std_logic_vector(7 downto 0);
    signal l3_s1 : std_logic_vector(7 downto 0);
    signal l3_c0 : std_logic;
    signal l3_c1 : std_logic;

    signal l3_c0_vec : std_logic_vector(0 downto 0);
    signal l3_c1_vec : std_logic_vector(0 downto 0);
    signal cout_vec  : std_logic_vector(0 downto 0);

begin

    --------------------------------------------------------------------
    -- Level 0:
    -- For every bit, calculate the result twice:
    -- once for carry-in = 0 and once for carry-in = 1.
    --------------------------------------------------------------------
    GEN_FULL_ADDERS : for i in 0 to 7 generate
    begin
        FA_FOR_CIN0 : Full_Adder
            port map (
                a    => a(i),
                b    => b(i),
                cin  => '0',
                sum  => bit_s0(i),
                cout => bit_c0(i)
            );

        FA_FOR_CIN1 : Full_Adder
            port map (
                a    => a(i),
                b    => b(i),
                cin  => '1',
                sum  => bit_s1(i),
                cout => bit_c1(i)
            );
    end generate;

    --------------------------------------------------------------------
    -- Level 1:
    -- Combine two 1-bit blocks into one 2-bit block.
    -- Blocks created: [1:0], [3:2], [5:4], [7:6]
    --------------------------------------------------------------------
    GEN_2BIT_BLOCKS : for g in 0 to 3 generate
    begin
        COMBINE_TO_2BIT : CS_Combine
            generic map (W => 1)
            port map (
                lo_s0 => bit_s0(2*g downto 2*g),
                lo_s1 => bit_s1(2*g downto 2*g),
                lo_c0 => bit_c0(2*g),
                lo_c1 => bit_c1(2*g),

                hi_s0 => bit_s0(2*g+1 downto 2*g+1),
                hi_s1 => bit_s1(2*g+1 downto 2*g+1),
                hi_c0 => bit_c0(2*g+1),
                hi_c1 => bit_c1(2*g+1),

                s0    => l1_s0(2*g+1 downto 2*g),
                s1    => l1_s1(2*g+1 downto 2*g),
                cout0 => l1_c0(g),
                cout1 => l1_c1(g)
            );
    end generate;

    --------------------------------------------------------------------
    -- Level 2:
    -- Combine two 2-bit blocks into one 4-bit block.
    -- Blocks created: [3:0], [7:4]
    --------------------------------------------------------------------
    GEN_4BIT_BLOCKS : for g in 0 to 1 generate
    begin
        COMBINE_TO_4BIT : CS_Combine
            generic map (W => 2)
            port map (
                lo_s0 => l1_s0(4*g+1 downto 4*g),
                lo_s1 => l1_s1(4*g+1 downto 4*g),
                lo_c0 => l1_c0(2*g),
                lo_c1 => l1_c1(2*g),

                hi_s0 => l1_s0(4*g+3 downto 4*g+2),
                hi_s1 => l1_s1(4*g+3 downto 4*g+2),
                hi_c0 => l1_c0(2*g+1),
                hi_c1 => l1_c1(2*g+1),

                s0    => l2_s0(4*g+3 downto 4*g),
                s1    => l2_s1(4*g+3 downto 4*g),
                cout0 => l2_c0(g),
                cout1 => l2_c1(g)
            );
    end generate;

    --------------------------------------------------------------------
    -- Level 3:
    -- Combine two 4-bit blocks into one 8-bit block.
    -- Block created: [7:0]
    --------------------------------------------------------------------
    COMBINE_TO_8BIT : CS_Combine
        generic map (W => 4)
        port map (
            lo_s0 => l2_s0(3 downto 0),
            lo_s1 => l2_s1(3 downto 0),
            lo_c0 => l2_c0(0),
            lo_c1 => l2_c1(0),

            hi_s0 => l2_s0(7 downto 4),
            hi_s1 => l2_s1(7 downto 4),
            hi_c0 => l2_c0(1),
            hi_c1 => l2_c1(1),

            s0    => l3_s0,
            s1    => l3_s1,
            cout0 => l3_c0,
            cout1 => l3_c1
        );

    --------------------------------------------------------------------
    -- Final selection with the real external cin.
    --------------------------------------------------------------------
    l3_c0_vec(0) <= l3_c0;
    l3_c1_vec(0) <= l3_c1;

    FINAL_SUM_MUX : MUX2
        generic map (N => 8)
        port map (
            d0  => l3_s0,
            d1  => l3_s1,
            sel => cin,
            y   => s
        );

    FINAL_CARRY_MUX : MUX2
        generic map (N => 1)
        port map (
            d0  => l3_c0_vec,
            d1  => l3_c1_vec,
            sel => cin,
            y   => cout_vec
        );

    cout <= cout_vec(0);

end Structural;
