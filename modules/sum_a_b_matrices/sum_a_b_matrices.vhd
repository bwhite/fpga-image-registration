library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity sum_a_b_matrices is
  generic (
    FRAC_BITS_IN   : integer := 26;
    FRAC_BITS_OUT  : integer := 19;
    WHOLE_BITS_OUT : integer := 8);
  port (CLK : in std_logic;
        RST : in std_logic;

        INPUT_VALID : in std_logic;
        DONE : in std_logic;
        -- 1:0:26
        A_0_0        : in  std_logic_vector(FRAC_BITS_IN downto 0);
        A_0_1        : in  std_logic_vector(FRAC_BITS_IN downto 0);
        A_0_2        : in  std_logic_vector(FRAC_BITS_IN downto 0);
        A_0_3        : in  std_logic_vector(FRAC_BITS_IN downto 0);
        A_0_4        : in  std_logic_vector(FRAC_BITS_IN downto 0);
        A_0_5        : in  std_logic_vector(FRAC_BITS_IN downto 0);

        A_1_0 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_1_1 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_1_2 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_1_3 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_1_4 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_1_5 : in std_logic_vector(FRAC_BITS_IN downto 0);

        A_2_0 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_2_1 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_2_2 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_2_3 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_2_4 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_2_5 : in std_logic_vector(FRAC_BITS_IN downto 0);

        A_3_0 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_3_1 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_3_2 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_3_3 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_3_4 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_3_5 : in std_logic_vector(FRAC_BITS_IN downto 0);

        A_4_0 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_4_1 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_4_2 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_4_3 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_4_4 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_4_5 : in std_logic_vector(FRAC_BITS_IN downto 0);

        A_5_0 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_5_1 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_5_2 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_5_3 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_5_4 : in std_logic_vector(FRAC_BITS_IN downto 0);
        A_5_5 : in std_logic_vector(FRAC_BITS_IN downto 0);

        B_0 : in std_logic_vector(FRAC_BITS_IN downto 0);
        B_1 : in std_logic_vector(FRAC_BITS_IN downto 0);
        B_2 : in std_logic_vector(FRAC_BITS_IN downto 0);
        B_3 : in std_logic_vector(FRAC_BITS_IN downto 0);
        B_4 : in std_logic_vector(FRAC_BITS_IN downto 0);
        B_5 : in std_logic_vector(FRAC_BITS_IN downto 0);


        DONE_BUF : out std_logic;
        OUTPUT_VALID : out std_logic;
        -- A Matrix Outputs (6x6)
        -- 1:WHOLE_BITS_OUT-1:FRAC_BITS_OUT
        A_0_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_0_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_0_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_0_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_0_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_0_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);

        A_1_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_1_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_1_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_1_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_1_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_1_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);

        A_2_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_2_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_2_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_2_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_2_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_2_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);

        A_3_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_3_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_3_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_3_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_3_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_3_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);

        A_4_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_4_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_4_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_4_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_4_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_4_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);

        A_5_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_5_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_5_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_5_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_5_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        A_5_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);

        -- b Vector Outputs (6x1)
        B_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        B_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        B_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        B_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        B_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
        B_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0)
        );
end sum_a_b_matrices;


architecture Behavioral of sum_a_b_matrices is
-- 1:WHOLE_BITS_OUT-1:FRAC_BITS_IN
  signal a_0_0_reg, a_0_1_reg, a_0_2_reg, a_0_3_reg, a_0_4_reg, a_0_5_reg, a_1_0_reg, a_1_1_reg, a_1_2_reg, a_1_3_reg, a_1_4_reg, a_1_5_reg, a_2_0_reg, a_2_1_reg, a_2_2_reg, a_2_3_reg, a_2_4_reg, a_2_5_reg, a_3_0_reg, a_3_1_reg, a_3_2_reg, a_3_3_reg, a_3_4_reg, a_3_5_reg, a_4_0_reg, a_4_1_reg, a_4_2_reg, a_4_3_reg, a_4_4_reg, a_4_5_reg, a_5_0_reg, a_5_1_reg, a_5_2_reg, a_5_3_reg, a_5_4_reg, a_5_5_reg : signed(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 0) := (others => '0');

  signal b_0_reg, b_1_reg, b_2_reg, b_3_reg, b_4_reg, b_5_reg : signed(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 0) := (others => '0');
  signal valid_reg                                            : std_logic                                      := '0';
  signal done_reg                                            : std_logic                                      := '0';
begin
  process (CLK)
  begin  -- process
    if CLK'event and CLK = '1' then     -- rising clock edge
      if RST = '1' then                 -- synchronous reset (active high)
        a_0_0_reg <= (others => '0');
        a_0_1_reg <= (others => '0');
        a_0_2_reg <= (others => '0');
        a_0_3_reg <= (others => '0');
        a_0_4_reg <= (others => '0');
        a_0_5_reg <= (others => '0');

        a_1_0_reg <= (others => '0');
        a_1_1_reg <= (others => '0');
        a_1_2_reg <= (others => '0');
        a_1_3_reg <= (others => '0');
        a_1_4_reg <= (others => '0');
        a_1_5_reg <= (others => '0');

        a_2_0_reg <= (others => '0');
        a_2_1_reg <= (others => '0');
        a_2_2_reg <= (others => '0');
        a_2_3_reg <= (others => '0');
        a_2_4_reg <= (others => '0');
        a_2_5_reg <= (others => '0');

        a_3_0_reg <= (others => '0');
        a_3_1_reg <= (others => '0');
        a_3_2_reg <= (others => '0');
        a_3_3_reg <= (others => '0');
        a_3_4_reg <= (others => '0');
        a_3_5_reg <= (others => '0');

        a_4_0_reg <= (others => '0');
        a_4_1_reg <= (others => '0');
        a_4_2_reg <= (others => '0');
        a_4_3_reg <= (others => '0');
        a_4_4_reg <= (others => '0');
        a_4_5_reg <= (others => '0');

        a_5_0_reg <= (others => '0');
        a_5_1_reg <= (others => '0');
        a_5_2_reg <= (others => '0');
        a_5_3_reg <= (others => '0');
        a_5_4_reg <= (others => '0');
        a_5_5_reg <= (others => '0');

        b_0_reg   <= (others => '0');
        b_1_reg   <= (others => '0');
        b_2_reg   <= (others => '0');
        b_3_reg   <= (others => '0');
        b_4_reg   <= (others => '0');
        b_5_reg   <= (others => '0');
        valid_reg <= '0';
        done_reg <= '0';
      else
        done_reg <= DONE;
        valid_reg <= INPUT_VALID;
        if INPUT_VALID = '1' then
          a_0_0_reg <= a_0_0_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_0_0(FRAC_BITS_IN))&A_0_0);
          a_0_1_reg <= a_0_1_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_0_1(FRAC_BITS_IN))&A_0_1);
          a_0_2_reg <= a_0_2_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_0_2(FRAC_BITS_IN))&A_0_2);
          a_0_3_reg <= a_0_3_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_0_3(FRAC_BITS_IN))&A_0_3);
          a_0_4_reg <= a_0_4_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_0_4(FRAC_BITS_IN))&A_0_4);
          a_0_5_reg <= a_0_5_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_0_5(FRAC_BITS_IN))&A_0_5);

          a_1_0_reg <= a_1_0_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_1_0(FRAC_BITS_IN))&A_1_0);
          a_1_1_reg <= a_1_1_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_1_1(FRAC_BITS_IN))&A_1_1);
          a_1_2_reg <= a_1_2_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_1_2(FRAC_BITS_IN))&A_1_2);
          a_1_3_reg <= a_1_3_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_1_3(FRAC_BITS_IN))&A_1_3);
          a_1_4_reg <= a_1_4_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_1_4(FRAC_BITS_IN))&A_1_4);
          a_1_5_reg <= a_1_5_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_1_5(FRAC_BITS_IN))&A_1_5);

          a_2_0_reg <= a_2_0_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_2_0(FRAC_BITS_IN))&A_2_0);
          a_2_1_reg <= a_2_1_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_2_1(FRAC_BITS_IN))&A_2_1);
          a_2_2_reg <= a_2_2_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_2_2(FRAC_BITS_IN))&A_2_2);
          a_2_3_reg <= a_2_3_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_2_3(FRAC_BITS_IN))&A_2_3);
          a_2_4_reg <= a_2_4_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_2_4(FRAC_BITS_IN))&A_2_4);
          a_2_5_reg <= a_2_5_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_2_5(FRAC_BITS_IN))&A_2_5);

          a_3_0_reg <= a_3_0_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_3_0(FRAC_BITS_IN))&A_3_0);
          a_3_1_reg <= a_3_1_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_3_1(FRAC_BITS_IN))&A_3_1);
          a_3_2_reg <= a_3_2_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_3_2(FRAC_BITS_IN))&A_3_2);
          a_3_3_reg <= a_3_3_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_3_3(FRAC_BITS_IN))&A_3_3);
          a_3_4_reg <= a_3_4_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_3_4(FRAC_BITS_IN))&A_3_4);
          a_3_5_reg <= a_3_5_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_3_5(FRAC_BITS_IN))&A_3_5);

          a_4_0_reg <= a_4_0_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_4_0(FRAC_BITS_IN))&A_4_0);
          a_4_1_reg <= a_4_1_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_4_1(FRAC_BITS_IN))&A_4_1);
          a_4_2_reg <= a_4_2_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_4_2(FRAC_BITS_IN))&A_4_2);
          a_4_3_reg <= a_4_3_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_4_3(FRAC_BITS_IN))&A_4_3);
          a_4_4_reg <= a_4_4_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_4_4(FRAC_BITS_IN))&A_4_4);
          a_4_5_reg <= a_4_5_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_4_5(FRAC_BITS_IN))&A_4_5);

          a_5_0_reg <= a_5_0_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_5_0(FRAC_BITS_IN))&A_5_0);
          a_5_1_reg <= a_5_1_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_5_1(FRAC_BITS_IN))&A_5_1);
          a_5_2_reg <= a_5_2_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_5_2(FRAC_BITS_IN))&A_5_2);
          a_5_3_reg <= a_5_3_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_5_3(FRAC_BITS_IN))&A_5_3);
          a_5_4_reg <= a_5_4_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_5_4(FRAC_BITS_IN))&A_5_4);
          a_5_5_reg <= a_5_5_reg + signed((WHOLE_BITS_OUT-2 downto 0 => A_5_5(FRAC_BITS_IN))&A_5_5);

          b_0_reg <= b_0_reg - signed((WHOLE_BITS_OUT-2 downto 0 => B_0(FRAC_BITS_IN))&B_0);
          b_1_reg <= b_1_reg - signed((WHOLE_BITS_OUT-2 downto 0 => B_1(FRAC_BITS_IN))&B_1);
          b_2_reg <= b_2_reg - signed((WHOLE_BITS_OUT-2 downto 0 => B_2(FRAC_BITS_IN))&B_2);
          b_3_reg <= b_3_reg - signed((WHOLE_BITS_OUT-2 downto 0 => B_3(FRAC_BITS_IN))&B_3);
          b_4_reg <= b_4_reg - signed((WHOLE_BITS_OUT-2 downto 0 => B_4(FRAC_BITS_IN))&B_4);
          b_5_reg <= b_5_reg - signed((WHOLE_BITS_OUT-2 downto 0 => B_5(FRAC_BITS_IN))&B_5);
        end if;
      end if;
    end if;
  end process;
  OUTPUT_VALID <= valid_reg;

  A_0_0_S <= std_logic_vector(a_0_0_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_0_1_S <= std_logic_vector(a_0_1_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_0_2_S <= std_logic_vector(a_0_2_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_0_3_S <= std_logic_vector(a_0_3_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_0_4_S <= std_logic_vector(a_0_4_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_0_5_S <= std_logic_vector(a_0_5_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));

  A_1_0_S <= std_logic_vector(a_1_0_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_1_1_S <= std_logic_vector(a_1_1_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_1_2_S <= std_logic_vector(a_1_2_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_1_3_S <= std_logic_vector(a_1_3_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_1_4_S <= std_logic_vector(a_1_4_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_1_5_S <= std_logic_vector(a_1_5_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));

  A_2_0_S <= std_logic_vector(a_2_0_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_2_1_S <= std_logic_vector(a_2_1_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_2_2_S <= std_logic_vector(a_2_2_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_2_3_S <= std_logic_vector(a_2_3_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_2_4_S <= std_logic_vector(a_2_4_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_2_5_S <= std_logic_vector(a_2_5_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));

  A_3_0_S <= std_logic_vector(a_3_0_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_3_1_S <= std_logic_vector(a_3_1_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_3_2_S <= std_logic_vector(a_3_2_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_3_3_S <= std_logic_vector(a_3_3_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_3_4_S <= std_logic_vector(a_3_4_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_3_5_S <= std_logic_vector(a_3_5_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));

  A_4_0_S <= std_logic_vector(a_4_0_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_4_1_S <= std_logic_vector(a_4_1_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_4_2_S <= std_logic_vector(a_4_2_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_4_3_S <= std_logic_vector(a_4_3_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_4_4_S <= std_logic_vector(a_4_4_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_4_5_S <= std_logic_vector(a_4_5_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));

  A_5_0_S <= std_logic_vector(a_5_0_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_5_1_S <= std_logic_vector(a_5_1_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_5_2_S <= std_logic_vector(a_5_2_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_5_3_S <= std_logic_vector(a_5_3_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_5_4_S <= std_logic_vector(a_5_4_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  A_5_5_S <= std_logic_vector(a_5_5_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));


  B_0_S <= std_logic_vector(b_0_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  B_1_S <= std_logic_vector(b_1_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  B_2_S <= std_logic_vector(b_2_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  B_3_S <= std_logic_vector(b_3_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  B_4_S <= std_logic_vector(b_4_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  B_5_S <= std_logic_vector(b_5_reg(WHOLE_BITS_OUT+FRAC_BITS_IN-1 downto 7));
  DONE_BUF <= done_reg;
end Behavioral;
