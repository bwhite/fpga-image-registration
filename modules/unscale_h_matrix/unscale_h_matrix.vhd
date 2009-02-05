library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity unscale_h_matrix is
  generic (
    WHOLE_BITS : integer := 8;
    FRAC_BITS  : integer := 19
    );
  port (CLK     : in std_logic;
        RST     : in std_logic;
        H_0_0_I : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_0_1_I : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_0_2_I : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_0_I : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_1_I : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_2_I : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        -- The X and Y shift values
        XB : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        YB : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        INPUT_VALID : in std_logic;
        OUTPUT_VALID : out std_logic;

        H_0_0 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_0_1 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_0_2 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_0 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_1 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_2 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0));
end unscale_h_matrix;

architecture Behavioral of unscale_h_matrix is
  signal h_0_0_reg, h_0_1_reg, h_0_2_reg, h_1_0_reg, h_1_1_reg, h_1_2_reg : signed(WHOLE_BITS+FRAC_BITS-1 downto 0) := (others => '0');
  signal h0_buf,h1_buf,h2_buf,h3_buf,h4_buf,h5_buf,xb_buf,yb_buf : signed(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal h0_t_xb,h3_t_xb,h1_t_yb,h4_t_yb : signed(2*(WHOLE_BITS+FRAC_BITS)-1 downto 0);
  signal valid_reg0,valid_reg1 : std_logic := '0';
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
        valid_reg0 <= '0';
                valid_reg1 <= '0';
      else
        -- inv(T)*X*T
        --[ h0, h1, h2 + xb - h0*xb - h1*yb]
        --[ h3, h4, h5 + yb - h3*xb - h4*yb]
        --[  0,  0,                       1]

        -- Stage 1, finish multipliers
        h0_buf <= signed(H_0_0_I);
        h1_buf <= signed(H_0_1_I);
        h2_buf <= signed(H_0_2_I);
        h3_buf <= signed(H_1_0_I);
        h4_buf <= signed(H_1_1_I);
        h5_buf <= signed(H_1_2_I);
        h0_t_xb <= signed(H_0_0_I)*signed(XB);
        h1_t_yb <= signed(H_0_1_I)*signed(YB);
        h3_t_xb <= signed(H_1_0_I)*signed(XB);
        h4_t_yb <= signed(H_1_1_I)*signed(YB);
        xb_buf <= signed(XB);
        yb_buf <= signed(YB);
        valid_reg0 <= INPUT_VALID;
        
        -- Buffer multipliers and truncate the extended precision from the multiplication
        
        
        -- Combine the values in the unscaled matrix
        h_0_0_reg <= h0_buf;
        h_0_1_reg <= h1_buf;
        h_0_2_reg <= h2_buf+xb_buf-h0_t_xb(WHOLE_BITS+2*FRAC_BITS-1 downto FRAC_BITS)-h1_t_yb(WHOLE_BITS+2*FRAC_BITS-1 downto FRAC_BITS);
        h_1_0_reg <= h3_buf;
        h_1_1_reg <= h4_buf;
        h_1_2_reg <= h5_buf+yb_buf-h3_t_xb(WHOLE_BITS+2*FRAC_BITS-1 downto FRAC_BITS)-h4_t_yb(WHOLE_BITS+2*FRAC_BITS-1 downto FRAC_BITS);
        valid_reg1 <= valid_reg0;
      end if;
    end if;
  end process;
  
  H_0_0        <= std_logic_vector(h_0_0_reg);
  H_0_1        <= std_logic_vector(h_0_1_reg);
  H_0_2        <= std_logic_vector(h_0_2_reg);
  H_1_0        <= std_logic_vector(h_1_0_reg);
  H_1_1        <= std_logic_vector(h_1_1_reg);
  H_1_2        <= std_logic_vector(h_1_2_reg);
  OUTPUT_VALID <= valid_reg1;

end Behavioral;

