library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity make_affine_homography is
  generic (
    WHOLE_BITS : integer := 8;
    FRAC_BITS  : integer := 19
    );
  port (CLK         : in std_logic;
        RST         : in std_logic;
        INPUT_VALID : in std_logic;
        X_0         : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        X_1         : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        X_2         : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        X_3         : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        X_4         : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        X_5         : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

        OUTPUT_VALID : out std_logic;
        H_0_0        : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_0_1        : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_0_2        : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_0        : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_1        : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_2        : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0)
        );
end make_affine_homography;

architecture Behavioral of make_affine_homography is
  signal h_0_0_reg, h_0_1_reg, h_0_2_reg, h_1_0_reg, h_1_1_reg, h_1_2_reg : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0) := (others => '0');
  signal valid_reg                                                        : std_logic                                         := '0';
begin
  process (CLK)
  begin  -- process
    if CLK'event and CLK = '1' then     -- rising clock edge
      if RST = '1' then                 -- synchronous reset (active high)
        h_0_0_reg <= (others => '0');
        h_0_1_reg <= (others => '0');
        h_0_2_reg <= (others => '0');
        h_1_0_reg <= (others => '0');
        h_1_1_reg <= (others => '0');
        h_1_2_reg <= (others => '0');
        valid_reg <= '0';
      else
        --H=[p(1)+1 p(2) p(0);p(4) p(5)+1 p(3); 0 0 1];
        h_0_0_reg <= X_1 + ((WHOLE_BITS-2 downto 0 => '0')&'1'&(FRAC_BITS-1 downto 0 => '0'));
        h_0_1_reg <= X_2;
        h_0_2_reg <= X_0;
        h_1_0_reg <= X_4;
        h_1_1_reg <= X_5 + ((WHOLE_BITS-2 downto 0 => '0')&'1'&(FRAC_BITS-1 downto 0 => '0'));
        h_1_2_reg <= X_3;
        valid_reg <= INPUT_VALID;
      end if;
    end if;
  end process;

  H_0_0        <= h_0_0_reg;
  H_0_1        <= h_0_1_reg;
  H_0_2        <= h_0_2_reg;
  H_1_0        <= h_1_0_reg;
  H_1_1        <= h_1_1_reg;
  H_1_2        <= h_1_2_reg;
  OUTPUT_VALID <= valid_reg;
end Behavioral;

