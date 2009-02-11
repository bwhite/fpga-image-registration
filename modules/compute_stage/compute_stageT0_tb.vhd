LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY compute_stageT0_tb IS
PORT(
  CLK : IN STD_LOGIC;
  RST : IN STD_LOGIC;
  DONE : OUT STD_LOGIC;
  FAIL : OUT STD_LOGIC;
  FAIL_NUM : OUT STD_LOGIC_VECTOR(5 DOWNTO 0));
END compute_stageT0_tb;
ARCHITECTURE behavior OF compute_stageT0_tb IS
  COMPONENT compute_stage
  PORT(
    CLK : IN STD_LOGIC;
    RST : IN STD_LOGIC;
    IMG0_0_1 : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG0_1_0 : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG0_1_1 : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG0_1_2 : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG0_2_1 : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG1_1_1 : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    TRANS_X_COORD : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    TRANS_Y_COORD : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    FSCS_VALID : IN STD_LOGIC;
    DONE : IN STD_LOGIC;
    IX : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    IY : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    IT : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    TRANS_X_COORD_BUF : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    TRANS_Y_COORD_BUF : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    DONE_BUF : OUT STD_LOGIC;
    CSSS_VALID : OUT STD_LOGIC);
  END COMPONENT;
  SIGNAL uut_rst_wire, uut_rst : STD_LOGIC;
  SIGNAL state : STD_LOGIC_VECTOR(5 DOWNTO 0);
  -- UUT Input
  SIGNAL uut_fscs_valid, uut_done : STD_LOGIC;
  SIGNAL uut_img0_0_1, uut_img0_1_0, uut_img0_1_1, uut_img0_1_2, uut_img0_2_1, uut_img1_1_1 : STD_LOGIC_VECTOR(8 DOWNTO 0);
  SIGNAL uut_trans_x_coord, uut_trans_y_coord : STD_LOGIC_VECTOR(11 DOWNTO 0);
  -- UUT Output
  SIGNAL uut_done_buf, uut_csss_valid : STD_LOGIC;
  SIGNAL uut_ix, uut_iy, uut_it : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL uut_trans_x_coord_buf, uut_trans_y_coord_buf : STD_LOGIC_VECTOR(11 DOWNTO 0);
BEGIN
  uut_rst_wire <= RST OR uut_rst;
  uut :  compute_stage PORT MAP (
    CLK => CLK,
    RST => uut_rst_wire,
    IMG0_0_1 => uut_img0_0_1,
    IMG0_1_0 => uut_img0_1_0,
    IMG0_1_1 => uut_img0_1_1,
    IMG0_1_2 => uut_img0_1_2,
    IMG0_2_1 => uut_img0_2_1,
    IMG1_1_1 => uut_img1_1_1,
    TRANS_X_COORD => uut_trans_x_coord,
    TRANS_Y_COORD => uut_trans_y_coord,
    FSCS_VALID => uut_fscs_valid,
    DONE => uut_done,
    IX => uut_ix,
    IY => uut_iy,
    IT => uut_it,
    TRANS_X_COORD_BUF => uut_trans_x_coord_buf,
    TRANS_Y_COORD_BUF => uut_trans_y_coord_buf,
    DONE_BUF => uut_done_buf,
    CSSS_VALID => uut_csss_valid
  );
  PROCESS (CLK) IS
  BEGIN
    IF CLK'event AND CLK='1' THEN
      IF RST='1' THEN
        DONE <= '0';
        FAIL <= '0';
        uut_rst <= '1';
        FAIL_NUM <= (OTHERS => '0');
        state <= (OTHERS => '0');
      ELSE
        CASE state IS
          WHEN "000000" =>
            uut_img0_0_1 <= "101100011";
            uut_img0_1_0 <= "101100100";
            uut_img0_1_1 <= "101100100";
            uut_img0_1_2 <= "101100011";
            uut_img0_2_1 <= "101100101";
            uut_img1_1_1 <= "101100100";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            state <= "000001";
            uut_rst <= '0';
          WHEN "000001" =>
            uut_img0_0_1 <= "100001101";
            uut_img0_1_0 <= "100000110";
            uut_img0_1_1 <= "011100101";
            uut_img0_1_2 <= "010111110";
            uut_img0_2_1 <= "011001000";
            uut_img1_1_1 <= "010101000";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            state <= "000010";
            uut_rst <= '0';
          WHEN "000010" =>
            uut_img0_0_1 <= "011010010";
            uut_img0_1_0 <= "010101000";
            uut_img0_1_1 <= "010110110";
            uut_img0_1_2 <= "010111001";
            uut_img0_2_1 <= "010100000";
            uut_img1_1_1 <= "010010100";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111111111" OR uut_iy /= "0000000010" OR uut_it /= "0000000000" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "000000";
              state <= "110101";
            ELSE
              state <= "000011";
            END IF;
            uut_rst <= '0';
          WHEN "000011" =>
            uut_img0_0_1 <= "011011100";
            uut_img0_1_0 <= "010111001";
            uut_img0_1_1 <= "010110011";
            uut_img0_1_2 <= "010101010";
            uut_img0_2_1 <= "010011010";
            uut_img1_1_1 <= "010011001";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1110111000" OR uut_iy /= "1110111011" OR uut_it /= "1111000011" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "000001";
              state <= "110101";
            ELSE
              state <= "000100";
            END IF;
            uut_rst <= '0';
          WHEN "000100" =>
            uut_img0_0_1 <= "011010100";
            uut_img0_1_0 <= "010100011";
            uut_img0_1_1 <= "010101111";
            uut_img0_1_2 <= "010110110";
            uut_img0_2_1 <= "010011111";
            uut_img1_1_1 <= "010011101";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000010001" OR uut_iy /= "1111001110" OR uut_it /= "1111011110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "000010";
              state <= "110101";
            ELSE
              state <= "000101";
            END IF;
            uut_rst <= '0';
          WHEN "000101" =>
            uut_img0_0_1 <= "010111001";
            uut_img0_1_0 <= "010100101";
            uut_img0_1_1 <= "010100111";
            uut_img0_1_2 <= "010100110";
            uut_img0_2_1 <= "010100101";
            uut_img1_1_1 <= "010101100";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111110001" OR uut_iy /= "1110111110" OR uut_it /= "1111100110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "000011";
              state <= "110101";
            ELSE
              state <= "000110";
            END IF;
            uut_rst <= '0';
          WHEN "000110" =>
            uut_img0_0_1 <= "101101010";
            uut_img0_1_0 <= "101101010";
            uut_img0_1_1 <= "101101010";
            uut_img0_1_2 <= "101101011";
            uut_img0_2_1 <= "101101011";
            uut_img1_1_1 <= "101101010";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000010011" OR uut_iy /= "1111001011" OR uut_it /= "1111101110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "000100";
              state <= "110101";
            ELSE
              state <= "000111";
            END IF;
            uut_rst <= '0';
          WHEN "000111" =>
            uut_img0_0_1 <= "011101100";
            uut_img0_1_0 <= "011111111";
            uut_img0_1_1 <= "011111011";
            uut_img0_1_2 <= "011110011";
            uut_img0_2_1 <= "011110100";
            uut_img1_1_1 <= "011011001";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000001" OR uut_iy /= "1111101100" OR uut_it /= "0000000101" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "000101";
              state <= "110101";
            ELSE
              state <= "001000";
            END IF;
            uut_rst <= '0';
          WHEN "001000" =>
            uut_img0_0_1 <= "011011101";
            uut_img0_1_0 <= "011101100";
            uut_img0_1_1 <= "011100101";
            uut_img0_1_2 <= "011011001";
            uut_img0_2_1 <= "011110011";
            uut_img1_1_1 <= "100000111";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000001" OR uut_iy /= "0000000001" OR uut_it /= "0000000000" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "000110";
              state <= "110101";
            ELSE
              state <= "001001";
            END IF;
            uut_rst <= '0';
          WHEN "001001" =>
            uut_img0_0_1 <= "011000110";
            uut_img0_1_0 <= "010111000";
            uut_img0_1_1 <= "010111010";
            uut_img0_1_2 <= "011000001";
            uut_img0_2_1 <= "011001011";
            uut_img1_1_1 <= "011101011";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111110100" OR uut_iy /= "0000001000" OR uut_it /= "1111011110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "000111";
              state <= "110101";
            ELSE
              state <= "001010";
            END IF;
            uut_rst <= '0';
          WHEN "001010" =>
            uut_img0_0_1 <= "101100101";
            uut_img0_1_0 <= "101110000";
            uut_img0_1_1 <= "101100100";
            uut_img0_1_2 <= "101000011";
            uut_img0_2_1 <= "101100001";
            uut_img1_1_1 <= "101100110";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111101101" OR uut_iy /= "0000010110" OR uut_it /= "0000100010" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "001000";
              state <= "110101";
            ELSE
              state <= "001011";
            END IF;
            uut_rst <= '0';
          WHEN "001011" =>
            uut_img0_0_1 <= "010001101";
            uut_img0_1_0 <= "010000101";
            uut_img0_1_1 <= "010000110";
            uut_img0_1_2 <= "010011101";
            uut_img0_2_1 <= "001111111";
            uut_img1_1_1 <= "001111001";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000001001" OR uut_iy /= "0000000101" OR uut_it /= "0000110001" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "001001";
              state <= "110101";
            ELSE
              state <= "001100";
            END IF;
            uut_rst <= '0';
          WHEN "001100" =>
            uut_img0_0_1 <= "101101000";
            uut_img0_1_0 <= "101101000";
            uut_img0_1_1 <= "101101001";
            uut_img0_1_2 <= "101101001";
            uut_img0_2_1 <= "101101001";
            uut_img1_1_1 <= "101100111";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111010011" OR uut_iy /= "1111111100" OR uut_it /= "0000000010" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "001010";
              state <= "110101";
            ELSE
              state <= "001101";
            END IF;
            uut_rst <= '0';
          WHEN "001101" =>
            uut_img0_0_1 <= "100110010";
            uut_img0_1_0 <= "011111111";
            uut_img0_1_1 <= "100000011";
            uut_img0_1_2 <= "100001000";
            uut_img0_2_1 <= "011011011";
            uut_img1_1_1 <= "011101001";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000011000" OR uut_iy /= "1111110010" OR uut_it /= "1111110011" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "001011";
              state <= "110101";
            ELSE
              state <= "001110";
            END IF;
            uut_rst <= '0';
          WHEN "001110" =>
            uut_img0_0_1 <= "011000110";
            uut_img0_1_0 <= "010011100";
            uut_img0_1_1 <= "010011110";
            uut_img0_1_2 <= "010110101";
            uut_img0_2_1 <= "010011100";
            uut_img1_1_1 <= "010011001";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000001" OR uut_iy /= "0000000001" OR uut_it /= "1111111110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "001100";
              state <= "110101";
            ELSE
              state <= "001111";
            END IF;
            uut_rst <= '0';
          WHEN "001111" =>
            uut_img0_0_1 <= "011011110";
            uut_img0_1_0 <= "010011110";
            uut_img0_1_1 <= "010110101";
            uut_img0_1_2 <= "011010010";
            uut_img0_2_1 <= "010101000";
            uut_img1_1_1 <= "010101011";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000001001" OR uut_iy /= "1110101001" OR uut_it /= "1111100110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "001101";
              state <= "110101";
            ELSE
              state <= "010000";
            END IF;
            uut_rst <= '0';
          WHEN "010000" =>
            uut_img0_0_1 <= "011100010";
            uut_img0_1_0 <= "010101111";
            uut_img0_1_1 <= "010110110";
            uut_img0_1_2 <= "010111011";
            uut_img0_2_1 <= "010100001";
            uut_img1_1_1 <= "010011110";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000011001" OR uut_iy /= "1111010110" OR uut_it /= "1111111011" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "001110";
              state <= "110101";
            ELSE
              state <= "010001";
            END IF;
            uut_rst <= '0';
          WHEN "010001" =>
            uut_img0_0_1 <= "011011111";
            uut_img0_1_0 <= "011100000";
            uut_img0_1_1 <= "011111001";
            uut_img0_1_2 <= "011111111";
            uut_img0_2_1 <= "011110110";
            uut_img1_1_1 <= "011111000";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000110100" OR uut_iy /= "1111001010" OR uut_it /= "1111110110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "001111";
              state <= "110101";
            ELSE
              state <= "010010";
            END IF;
            uut_rst <= '0';
          WHEN "010010" =>
            uut_img0_0_1 <= "011101100";
            uut_img0_1_0 <= "011111011";
            uut_img0_1_1 <= "011110011";
            uut_img0_1_2 <= "011101100";
            uut_img0_2_1 <= "011110101";
            uut_img1_1_1 <= "011110101";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000001100" OR uut_iy /= "1110111111" OR uut_it /= "1111101000" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "010000";
              state <= "110101";
            ELSE
              state <= "010011";
            END IF;
            uut_rst <= '0';
          WHEN "010011" =>
            uut_img0_0_1 <= "101101111";
            uut_img0_1_0 <= "101101110";
            uut_img0_1_1 <= "101101111";
            uut_img0_1_2 <= "101110000";
            uut_img0_2_1 <= "101101111";
            uut_img1_1_1 <= "101101111";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000011111" OR uut_iy /= "0000010111" OR uut_it /= "1111111111" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "010001";
              state <= "110101";
            ELSE
              state <= "010100";
            END IF;
            uut_rst <= '0';
          WHEN "010100" =>
            uut_img0_0_1 <= "011110001";
            uut_img0_1_0 <= "011110100";
            uut_img0_1_1 <= "100000000";
            uut_img0_1_2 <= "011111000";
            uut_img0_2_1 <= "100000101";
            uut_img1_1_1 <= "100000111";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111110001" OR uut_iy /= "0000001001" OR uut_it /= "0000000010" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "010010";
              state <= "110101";
            ELSE
              state <= "010101";
            END IF;
            uut_rst <= '0';
          WHEN "010101" =>
            uut_img0_0_1 <= "101100010";
            uut_img0_1_0 <= "101100010";
            uut_img0_1_1 <= "101100010";
            uut_img0_1_2 <= "101100010";
            uut_img0_2_1 <= "101100011";
            uut_img1_1_1 <= "101100001";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000010" OR uut_iy /= "0000000000" OR uut_it /= "0000000000" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "010011";
              state <= "110101";
            ELSE
              state <= "010110";
            END IF;
            uut_rst <= '0';
          WHEN "010110" =>
            uut_img0_0_1 <= "101100010";
            uut_img0_1_0 <= "101100011";
            uut_img0_1_1 <= "101100011";
            uut_img0_1_2 <= "101100011";
            uut_img0_2_1 <= "101100100";
            uut_img1_1_1 <= "101100010";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000100" OR uut_iy /= "0000010100" OR uut_it /= "0000000111" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "010100";
              state <= "110101";
            ELSE
              state <= "010111";
            END IF;
            uut_rst <= '0';
          WHEN "010111" =>
            uut_img0_0_1 <= "101100011";
            uut_img0_1_0 <= "101100100";
            uut_img0_1_1 <= "101100100";
            uut_img0_1_2 <= "101100100";
            uut_img0_2_1 <= "101100101";
            uut_img1_1_1 <= "101100010";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000000" OR uut_iy /= "0000000001" OR uut_it /= "1111111111" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "010101";
              state <= "110101";
            ELSE
              state <= "011000";
            END IF;
            uut_rst <= '0';
          WHEN "011000" =>
            uut_img0_0_1 <= "101101000";
            uut_img0_1_0 <= "101101001";
            uut_img0_1_1 <= "101101001";
            uut_img0_1_2 <= "101101010";
            uut_img0_2_1 <= "101011111";
            uut_img1_1_1 <= "101101000";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000000" OR uut_iy /= "0000000010" OR uut_it /= "1111111111" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "010110";
              state <= "110101";
            ELSE
              state <= "011001";
            END IF;
            uut_rst <= '0';
          WHEN "011001" =>
            uut_img0_0_1 <= "100101110";
            uut_img0_1_0 <= "011101100";
            uut_img0_1_1 <= "011100100";
            uut_img0_1_2 <= "011010001";
            uut_img0_2_1 <= "010101100";
            uut_img1_1_1 <= "010111101";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000000" OR uut_iy /= "0000000010" OR uut_it /= "1111111110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "010111";
              state <= "110101";
            ELSE
              state <= "011010";
            END IF;
            uut_rst <= '0';
          WHEN "011010" =>
            uut_img0_0_1 <= "011111101";
            uut_img0_1_0 <= "010111010";
            uut_img0_1_1 <= "011010100";
            uut_img0_1_2 <= "011100010";
            uut_img0_2_1 <= "010101111";
            uut_img1_1_1 <= "011000001";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000001" OR uut_iy /= "1111110111" OR uut_it /= "1111111111" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "011000";
              state <= "110101";
            ELSE
              state <= "011011";
            END IF;
            uut_rst <= '0';
          WHEN "011011" =>
            uut_img0_0_1 <= "010110111";
            uut_img0_1_0 <= "011100101";
            uut_img0_1_1 <= "011010110";
            uut_img0_1_2 <= "011001011";
            uut_img0_2_1 <= "011110000";
            uut_img1_1_1 <= "011100111";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111100101" OR uut_iy /= "1101111110" OR uut_it /= "1111011001" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "011001";
              state <= "110101";
            ELSE
              state <= "011100";
            END IF;
            uut_rst <= '0';
          WHEN "011100" =>
            uut_img0_0_1 <= "011100101";
            uut_img0_1_0 <= "011110011";
            uut_img0_1_1 <= "011101100";
            uut_img0_1_2 <= "011100101";
            uut_img0_2_1 <= "011111100";
            uut_img1_1_1 <= "011101111";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000101000" OR uut_iy /= "1110110010" OR uut_it /= "1111101101" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "011010";
              state <= "110101";
            ELSE
              state <= "011101";
            END IF;
            uut_rst <= '0';
          WHEN "011101" =>
            uut_img0_0_1 <= "101101101";
            uut_img0_1_0 <= "101101101";
            uut_img0_1_1 <= "101101101";
            uut_img0_1_2 <= "101101110";
            uut_img0_2_1 <= "101101101";
            uut_img1_1_1 <= "101101110";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111100110" OR uut_iy /= "0000111001" OR uut_it /= "0000010001" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "011011";
              state <= "110101";
            ELSE
              state <= "011110";
            END IF;
            uut_rst <= '0';
          WHEN "011110" =>
            uut_img0_0_1 <= "101101111";
            uut_img0_1_0 <= "101101111";
            uut_img0_1_1 <= "101110000";
            uut_img0_1_2 <= "101110000";
            uut_img0_2_1 <= "101101111";
            uut_img1_1_1 <= "101101111";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111110010" OR uut_iy /= "0000010111" OR uut_it /= "0000000011" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "011100";
              state <= "110101";
            ELSE
              state <= "011111";
            END IF;
            uut_rst <= '0';
          WHEN "011111" =>
            uut_img0_0_1 <= "101100010";
            uut_img0_1_0 <= "101100011";
            uut_img0_1_1 <= "101100011";
            uut_img0_1_2 <= "101100100";
            uut_img0_2_1 <= "101100101";
            uut_img1_1_1 <= "101100010";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000001" OR uut_iy /= "0000000000" OR uut_it /= "0000000001" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "011101";
              state <= "110101";
            ELSE
              state <= "100000";
            END IF;
            uut_rst <= '0';
          WHEN "100000" =>
            uut_img0_0_1 <= "101100100";
            uut_img0_1_0 <= "101100101";
            uut_img0_1_1 <= "101100101";
            uut_img0_1_2 <= "101100101";
            uut_img0_2_1 <= "101100110";
            uut_img1_1_1 <= "101100011";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000001" OR uut_iy /= "0000000000" OR uut_it /= "1111111111" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "011110";
              state <= "110101";
            ELSE
              state <= "100001";
            END IF;
            uut_rst <= '0';
          WHEN "100001" =>
            uut_img0_0_1 <= "101100011";
            uut_img0_1_0 <= "101100101";
            uut_img0_1_1 <= "101100101";
            uut_img0_1_2 <= "101100101";
            uut_img0_2_1 <= "101100110";
            uut_img1_1_1 <= "101100011";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000001" OR uut_iy /= "0000000011" OR uut_it /= "1111111111" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "011111";
              state <= "110101";
            ELSE
              state <= "100010";
            END IF;
            uut_rst <= '0';
          WHEN "100010" =>
            uut_img0_0_1 <= "101100101";
            uut_img0_1_0 <= "101100110";
            uut_img0_1_1 <= "101100110";
            uut_img0_1_2 <= "101100110";
            uut_img0_2_1 <= "101101000";
            uut_img1_1_1 <= "101100100";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000000" OR uut_iy /= "0000000010" OR uut_it /= "1111111110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "100000";
              state <= "110101";
            ELSE
              state <= "100011";
            END IF;
            uut_rst <= '0';
          WHEN "100011" =>
            uut_img0_0_1 <= "101100001";
            uut_img0_1_0 <= "101100010";
            uut_img0_1_1 <= "101100001";
            uut_img0_1_2 <= "101100001";
            uut_img0_2_1 <= "101100010";
            uut_img1_1_1 <= "101100000";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000000" OR uut_iy /= "0000000011" OR uut_it /= "1111111110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "100001";
              state <= "110101";
            ELSE
              state <= "100100";
            END IF;
            uut_rst <= '0';
          WHEN "100100" =>
            uut_img0_0_1 <= "101100010";
            uut_img0_1_0 <= "101100100";
            uut_img0_1_1 <= "101100011";
            uut_img0_1_2 <= "101100011";
            uut_img0_2_1 <= "101100100";
            uut_img1_1_1 <= "101100010";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000000" OR uut_iy /= "0000000011" OR uut_it /= "1111111110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "100010";
              state <= "110101";
            ELSE
              state <= "100101";
            END IF;
            uut_rst <= '0';
          WHEN "100101" =>
            uut_img0_0_1 <= "101100110";
            uut_img0_1_0 <= "101101001";
            uut_img0_1_1 <= "101101000";
            uut_img0_1_2 <= "101100111";
            uut_img0_2_1 <= "101101001";
            uut_img1_1_1 <= "101100101";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111111111" OR uut_iy /= "0000000001" OR uut_it /= "1111111111" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "100011";
              state <= "110101";
            ELSE
              state <= "100110";
            END IF;
            uut_rst <= '0';
          WHEN "100110" =>
            uut_img0_0_1 <= "100001101";
            uut_img0_1_0 <= "011010010";
            uut_img0_1_1 <= "011011111";
            uut_img0_1_2 <= "011011100";
            uut_img0_2_1 <= "010111001";
            uut_img1_1_1 <= "011011100";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111111111" OR uut_iy /= "0000000010" OR uut_it /= "1111111111" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "100100";
              state <= "110101";
            ELSE
              state <= "100111";
            END IF;
            uut_rst <= '0';
          WHEN "100111" =>
            uut_img0_0_1 <= "010100000";
            uut_img0_1_0 <= "010010110";
            uut_img0_1_1 <= "010011000";
            uut_img0_1_2 <= "010011000";
            uut_img0_2_1 <= "010011010";
            uut_img1_1_1 <= "010010101";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111111110" OR uut_iy /= "0000000011" OR uut_it /= "1111111101" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "100101";
              state <= "110101";
            ELSE
              state <= "101000";
            END IF;
            uut_rst <= '0';
          WHEN "101000" =>
            uut_img0_0_1 <= "010101100";
            uut_img0_1_0 <= "010011101";
            uut_img0_1_1 <= "010100010";
            uut_img0_1_2 <= "011000101";
            uut_img0_2_1 <= "010011100";
            uut_img1_1_1 <= "010010100";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000001010" OR uut_iy /= "1110101100" OR uut_it /= "1111111101" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "100110";
              state <= "110101";
            ELSE
              state <= "101001";
            END IF;
            uut_rst <= '0';
          WHEN "101001" =>
            uut_img0_0_1 <= "010100110";
            uut_img0_1_0 <= "011001011";
            uut_img0_1_1 <= "010110111";
            uut_img0_1_2 <= "010101100";
            uut_img0_2_1 <= "011010110";
            uut_img1_1_1 <= "010110011";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000010" OR uut_iy /= "1111111010" OR uut_it /= "1111111101" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "100111";
              state <= "110101";
            ELSE
              state <= "101010";
            END IF;
            uut_rst <= '0';
          WHEN "101010" =>
            uut_img0_0_1 <= "100000010";
            uut_img0_1_0 <= "011010000";
            uut_img0_1_1 <= "011100000";
            uut_img0_1_2 <= "011100000";
            uut_img0_2_1 <= "011100001";
            uut_img1_1_1 <= "011001100";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000101000" OR uut_iy /= "1111110000" OR uut_it /= "1111110010" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "101000";
              state <= "110101";
            ELSE
              state <= "101011";
            END IF;
            uut_rst <= '0';
          WHEN "101011" =>
            uut_img0_0_1 <= "101101101";
            uut_img0_1_0 <= "101101101";
            uut_img0_1_1 <= "101101101";
            uut_img0_1_2 <= "101101110";
            uut_img0_2_1 <= "101101101";
            uut_img1_1_1 <= "101101101";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111100001" OR uut_iy /= "0000110000" OR uut_it /= "1111111100" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "101001";
              state <= "110101";
            ELSE
              state <= "101100";
            END IF;
            uut_rst <= '0';
          WHEN "101100" =>
            uut_img0_0_1 <= "101101111";
            uut_img0_1_0 <= "101101110";
            uut_img0_1_1 <= "101101111";
            uut_img0_1_2 <= "101110000";
            uut_img0_2_1 <= "101101111";
            uut_img1_1_1 <= "101101110";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000010000" OR uut_iy /= "1111011111" OR uut_it /= "1111101100" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "101010";
              state <= "110101";
            ELSE
              state <= "101101";
            END IF;
            uut_rst <= '0';
          WHEN "101101" =>
            uut_img0_0_1 <= "011111001";
            uut_img0_1_0 <= "011111100";
            uut_img0_1_1 <= "011111010";
            uut_img0_1_2 <= "011101111";
            uut_img0_2_1 <= "011110101";
            uut_img1_1_1 <= "011110110";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000001" OR uut_iy /= "0000000000" OR uut_it /= "0000000000" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "101011";
              state <= "110101";
            ELSE
              state <= "101110";
            END IF;
            uut_rst <= '0';
          WHEN "101110" =>
            uut_img0_0_1 <= "011010000";
            uut_img0_1_0 <= "010011101";
            uut_img0_1_1 <= "010110010";
            uut_img0_1_2 <= "010110011";
            uut_img0_2_1 <= "010011011";
            uut_img1_1_1 <= "010101010";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000000010" OR uut_iy /= "0000000000" OR uut_it /= "1111111111" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "101100";
              state <= "110101";
            ELSE
              state <= "101111";
            END IF;
            uut_rst <= '0';
          WHEN "101111" =>
            uut_img0_0_1 <= "100000010";
            uut_img0_1_0 <= "011100110";
            uut_img0_1_1 <= "011101010";
            uut_img0_1_2 <= "011110011";
            uut_img0_2_1 <= "011010110";
            uut_img1_1_1 <= "011100000";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "1111110011" OR uut_iy /= "1111111100" OR uut_it /= "1111111100" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "101101";
              state <= "110101";
            ELSE
              state <= "110000";
            END IF;
            uut_rst <= '0';
          WHEN "110000" =>
            uut_img0_0_1 <= "010011101";
            uut_img0_1_0 <= "001111111";
            uut_img0_1_1 <= "010001011";
            uut_img0_1_2 <= "010011011";
            uut_img0_2_1 <= "001111110";
            uut_img1_1_1 <= "010000110";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000010110" OR uut_iy /= "1111001011" OR uut_it /= "1111111000" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "101110";
              state <= "110101";
            ELSE
              state <= "110001";
            END IF;
            uut_rst <= '0';
          WHEN "110001" =>
            uut_img0_0_1 <= "101100011";
            uut_img0_1_0 <= "101100011";
            uut_img0_1_1 <= "101100100";
            uut_img0_1_2 <= "101100100";
            uut_img0_2_1 <= "101100101";
            uut_img1_1_1 <= "101100010";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000001101" OR uut_iy /= "1111010100" OR uut_it /= "1111110110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "101111";
              state <= "110101";
            ELSE
              state <= "110010";
            END IF;
            uut_rst <= '0';
          WHEN "110010" =>
            uut_img0_0_1 <= "101100001";
            uut_img0_1_0 <= "101100010";
            uut_img0_1_1 <= "101100011";
            uut_img0_1_2 <= "101100010";
            uut_img0_2_1 <= "101100100";
            uut_img1_1_1 <= "101100001";
            uut_trans_x_coord <= "000000000000";
            uut_trans_y_coord <= "000000000000";
            uut_fscs_valid <= '0';
            uut_done <= '0';
            IF uut_ix /= "0000011100" OR uut_iy /= "1111100001" OR uut_it /= "1111111011" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "110000";
              state <= "110101";
            ELSE
              state <= "110011";
            END IF;
            uut_rst <= '0';
          WHEN "110011" =>
            IF uut_ix /= "0000000001" OR uut_iy /= "0000000010" OR uut_it /= "1111111110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "110001";
              state <= "110101";
            ELSE
              state <= "110100";
            END IF;
            uut_rst <= '0';
          WHEN "110100" =>
            IF uut_ix /= "0000000000" OR uut_iy /= "0000000011" OR uut_it /= "1111111110" OR uut_trans_x_coord_buf /= "000000000000" OR uut_trans_y_coord_buf /= "000000000000" OR uut_done_buf /= '0' OR uut_csss_valid /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "110010";
              state <= "110101";
            ELSE
              state <= "110101";
            END IF;
            uut_rst <= '0';
          WHEN OTHERS =>
            DONE <= '1';
            uut_rst <= '1';
        END CASE;
      END IF;
    END IF;
  END PROCESS;
END;
