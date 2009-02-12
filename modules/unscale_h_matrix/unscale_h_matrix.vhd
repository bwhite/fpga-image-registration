LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY unscale_h_matrix IS
  GENERIC (
    WHOLE_BITS   : integer := 8;
    FRAC_BITS    : integer := 19;
    IMGSIZE_BITS : integer := 10
    );
  PORT (CLK          : IN  std_logic;
        RST          : IN  std_logic;
        H_0_0_I      : IN  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 DOWNTO 0);
        H_0_1_I      : IN  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 DOWNTO 0);
        H_0_2_I      : IN  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 DOWNTO 0);
        H_1_0_I      : IN  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 DOWNTO 0);
        H_1_1_I      : IN  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 DOWNTO 0);
        H_1_2_I      : IN  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 DOWNTO 0);
        -- The X and Y shift values
        -- 1:IMGSIZE_BITS:1 Format
        COORD_TRANS  : IN  std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);
        INPUT_VALID  : IN  std_logic;
        OUTPUT_VALID : OUT std_logic;

        H_0_0 : OUT std_logic_vector(29 DOWNTO 0);
        H_0_1 : OUT std_logic_vector(29 DOWNTO 0);
        H_0_2 : OUT std_logic_vector(29 DOWNTO 0);
        H_1_0 : OUT std_logic_vector(29 DOWNTO 0);
        H_1_1 : OUT std_logic_vector(29 DOWNTO 0);
        H_1_2 : OUT std_logic_vector(29 DOWNTO 0));
END unscale_h_matrix;

ARCHITECTURE Behavioral OF unscale_h_matrix IS
  SIGNAL h_0_0_reg, h_0_1_reg, h_0_2_reg, h_1_0_reg, h_1_1_reg, h_1_2_reg : signed(29 DOWNTO 0) := (OTHERS => '0');
  SIGNAL h0_buf, h1_buf, h2_buf, h3_buf, h4_buf, h5_buf, coord_trans_buf  : signed(29 DOWNTO 0) := (OTHERS => '0');
  SIGNAL h0_t_xb, h3_t_xb, h1_t_yb, h4_t_yb                               : signed(38 DOWNTO 0) := (OTHERS => '0');
  SIGNAL valid_reg0, valid_reg1                                           : std_logic           := '0';
BEGIN
  PROCESS (CLK)
  BEGIN  -- process
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        h_0_0_reg  <= (OTHERS => '0');
        h_0_1_reg  <= (OTHERS => '0');
        h_0_2_reg  <= (OTHERS => '0');
        h_1_0_reg  <= (OTHERS => '0');
        h_1_1_reg  <= (OTHERS => '0');
        h_1_2_reg  <= (OTHERS => '0');
        valid_reg0 <= '0';
        valid_reg1 <= '0';
      ELSE
        -- inv(T)*X*T
        --[ h0, h1, h2 + xb - h0*xb - h1*yb]
        --[ h3, h4, h5 + yb - h3*xb - h4*yb]
        --[  0,  0,                       1]

        -- Stage 1, finish multipliers
        -- 1:10:1 -> 1:10:19
        coord_trans_buf <= signed((COORD_TRANS&(17 DOWNTO 0 => '0')));

        -- 1:7:19 -> 1:10:19
        h0_buf     <= signed((2 DOWNTO 0 => H_0_0_I(26))&H_0_0_I);
        h1_buf     <= signed((2 DOWNTO 0 => H_0_1_I(26))&H_0_1_I);
        h2_buf     <= signed((2 DOWNTO 0 => H_0_2_I(26))&H_0_2_I);
        h3_buf     <= signed((2 DOWNTO 0 => H_1_0_I(26))&H_1_0_I);
        h4_buf     <= signed((2 DOWNTO 0 => H_1_1_I(26))&H_1_1_I);
        h5_buf     <= signed((2 DOWNTO 0 => H_1_2_I(26))&H_1_2_I);
        -- 1:18:20
        h0_t_xb    <= signed(H_0_0_I)*signed(COORD_TRANS);
        h1_t_yb    <= signed(H_0_1_I)*signed(COORD_TRANS);
        h3_t_xb    <= signed(H_1_0_I)*signed(COORD_TRANS);
        h4_t_yb    <= signed(H_1_1_I)*signed(COORD_TRANS);
        valid_reg0 <= INPUT_VALID;

        -- Buffer multipliers and truncate the extended precision from the multiplication


        -- Combine the values in the unscaled matrix
        h_0_0_reg  <= h0_buf;
        h_0_1_reg  <= h1_buf;
        -- Convert back to 1:10:19
        h_0_2_reg  <= h2_buf+coord_trans_buf-h0_t_xb(30 DOWNTO 1)-h1_t_yb(30 DOWNTO 1);
        h_1_0_reg  <= h3_buf;
        h_1_1_reg  <= h4_buf;
        h_1_2_reg  <= h5_buf+coord_trans_buf-h3_t_xb(30 DOWNTO 1)-h4_t_yb(30 DOWNTO 1);
        valid_reg1 <= valid_reg0;
      END IF;
    END IF;
  END PROCESS;

  H_0_0        <= std_logic_vector(h_0_0_reg);
  H_0_1        <= std_logic_vector(h_0_1_reg);
  H_0_2        <= std_logic_vector(h_0_2_reg);
  H_1_0        <= std_logic_vector(h_1_0_reg);
  H_1_1        <= std_logic_vector(h_1_1_reg);
  H_1_2        <= std_logic_vector(h_1_2_reg);
  OUTPUT_VALID <= valid_reg1;

END Behavioral;

