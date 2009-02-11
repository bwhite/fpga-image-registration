LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY signed_norm_multT0_tb IS
PORT(
  CLK : IN STD_LOGIC;
  RST : IN STD_LOGIC;
  DONE : OUT STD_LOGIC;
  FAIL : OUT STD_LOGIC;
  FAIL_NUM : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END signed_norm_multT0_tb;
ARCHITECTURE behavior OF signed_norm_multT0_tb IS
  COMPONENT signed_norm_mult
  PORT(
    CLK : IN STD_LOGIC;
    RST : IN STD_LOGIC;
    VALID_IN : IN STD_LOGIC;
    A : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    C : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    VALID_OUT : OUT STD_LOGIC);
  END COMPONENT;
  SIGNAL uut_rst_wire, uut_rst : STD_LOGIC;
  SIGNAL state : STD_LOGIC_VECTOR(6 DOWNTO 0);
  -- UUT Input
  SIGNAL uut_valid_in : STD_LOGIC;
  SIGNAL uut_a, uut_b : STD_LOGIC_VECTOR(26 DOWNTO 0);
  -- UUT Output
  SIGNAL uut_valid_out : STD_LOGIC;
  SIGNAL uut_c : STD_LOGIC_VECTOR(26 DOWNTO 0);
BEGIN
  uut_rst_wire <= RST OR uut_rst;
  uut :  signed_norm_mult PORT MAP (
    CLK => CLK,
    RST => uut_rst_wire,
    VALID_IN => uut_valid_in,
    A => uut_a,
    B => uut_b,
    C => uut_c,
    VALID_OUT => uut_valid_out
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
          WHEN "0000000" =>
            uut_valid_in <= '1';
            uut_a <= "111101000000100110000110111";
            uut_b <= "010000010011001100110111111";
            state <= "0000001";
            uut_rst <= '0';
          WHEN "0000001" =>
            uut_valid_in <= '1';
            uut_a <= "011011011011111111111110010";
            uut_b <= "001110011011001101101010001";
            state <= "0000010";
            uut_rst <= '0';
          WHEN "0000010" =>
            uut_valid_in <= '1';
            uut_a <= "001000110010111011101110011";
            uut_b <= "001110101100110001101111010";
            state <= "0000011";
            uut_rst <= '0';
          WHEN "0000011" =>
            uut_valid_in <= '1';
            uut_a <= "000011011100010000101001101";
            uut_b <= "000001010100011100011100100";
            state <= "0000100";
            uut_rst <= '0';
          WHEN "0000100" =>
            uut_valid_in <= '1';
            uut_a <= "010011010101110100011111001";
            uut_b <= "010101011111010000010111110";
            state <= "0000101";
            uut_rst <= '0';
          WHEN "0000101" =>
            uut_valid_in <= '1';
            uut_a <= "101100110100100010101011010";
            uut_b <= "000000011101110111110111010";
            state <= "0000110";
            uut_rst <= '0';
          WHEN "0000110" =>
            uut_valid_in <= '1';
            uut_a <= "010000110101111011011001001";
            uut_b <= "010010001010010000111001101";
            IF uut_c /= "111110011110100000001101000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0000000";
              state <= "1110100";
            ELSE
              state <= "0000111";
            END IF;
            uut_rst <= '0';
          WHEN "0000111" =>
            uut_valid_in <= '1';
            uut_a <= "001001110111101010001110001";
            uut_b <= "010100010011111100101100010";
            IF uut_c /= "001100010111100101010100101" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0000001";
              state <= "1110100";
            ELSE
              state <= "0001000";
            END IF;
            uut_rst <= '0';
          WHEN "0001000" =>
            uut_valid_in <= '1';
            uut_a <= "001110111111110100010000011";
            uut_b <= "011100011001001111101010110";
            IF uut_c /= "000100000010100101110101011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0000010";
              state <= "1110100";
            ELSE
              state <= "0001001";
            END IF;
            uut_rst <= '0';
          WHEN "0001001" =>
            uut_valid_in <= '1';
            uut_a <= "001010100111100100000011010";
            uut_b <= "000011110111001001000011111";
            IF uut_c /= "000000001001000101001111100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0000011";
              state <= "1110100";
            ELSE
              state <= "0001010";
            END IF;
            uut_rst <= '0';
          WHEN "0001010" =>
            uut_valid_in <= '1';
            uut_a <= "001101101011011101100000001";
            uut_b <= "001110010011111010111101011";
            IF uut_c /= "001100111111001101011110100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0000100";
              state <= "1110100";
            ELSE
              state <= "0001011";
            END IF;
            uut_rst <= '0';
          WHEN "0001011" =>
            uut_valid_in <= '1';
            uut_a <= "001001000001011101101011011";
            uut_b <= "010100110000111100000111010";
            IF uut_c /= "111111101110000110001000100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0000101";
              state <= "1110100";
            ELSE
              state <= "0001100";
            END IF;
            uut_rst <= '0';
          WHEN "0001100" =>
            uut_valid_in <= '1';
            uut_a <= "001011011010101000000010100";
            uut_b <= "000001111000011110101010000";
            IF uut_c /= "001001100011101111001001111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0000110";
              state <= "1110100";
            ELSE
              state <= "0001101";
            END IF;
            uut_rst <= '0';
          WHEN "0001101" =>
            uut_valid_in <= '1';
            uut_a <= "101110010101010100000000010";
            uut_b <= "000101011000000001101011100";
            IF uut_c /= "000110010000111100001001111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0000111";
              state <= "1110100";
            ELSE
              state <= "0001110";
            END IF;
            uut_rst <= '0';
          WHEN "0001110" =>
            uut_valid_in <= '1';
            uut_a <= "011011011011010000011010011";
            uut_b <= "010000011111001100010110110";
            IF uut_c /= "001101010011101010111011000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0001000";
              state <= "1110100";
            ELSE
              state <= "0001111";
            END IF;
            uut_rst <= '0';
          WHEN "0001111" =>
            uut_valid_in <= '1';
            uut_a <= "001011000110000110001101001";
            uut_b <= "010101010111101001111010010";
            IF uut_c /= "000001010010000000011000101" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0001001";
              state <= "1110100";
            ELSE
              state <= "0010000";
            END IF;
            uut_rst <= '0';
          WHEN "0010000" =>
            uut_valid_in <= '1';
            uut_a <= "100101001101101010100111111";
            uut_b <= "000111001100111100110101000";
            IF uut_c /= "000110000111100001111010100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0001010";
              state <= "1110100";
            ELSE
              state <= "0010001";
            END IF;
            uut_rst <= '0';
          WHEN "0010001" =>
            uut_valid_in <= '1';
            uut_a <= "110010001100000010011111110";
            uut_b <= "011101001111011000110101101";
            IF uut_c /= "000101110110101101101100011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0001011";
              state <= "1110100";
            ELSE
              state <= "0010010";
            END IF;
            uut_rst <= '0';
          WHEN "0010010" =>
            uut_valid_in <= '1';
            uut_a <= "101110101010011001100110011";
            uut_b <= "000111111101001011001011001";
            IF uut_c /= "000000101010111110110010000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0001100";
              state <= "1110100";
            ELSE
              state <= "0010011";
            END IF;
            uut_rst <= '0';
          WHEN "0010011" =>
            uut_valid_in <= '1';
            uut_a <= "001011010010000101100100000";
            uut_b <= "010100110000000110111101111";
            IF uut_c /= "111101000010000100001011101" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0001101";
              state <= "1110100";
            ELSE
              state <= "0010100";
            END IF;
            uut_rst <= '0';
          WHEN "0010100" =>
            uut_valid_in <= '1';
            uut_a <= "001101000010010000101010100";
            uut_b <= "011010110010011000110011010";
            IF uut_c /= "001110001000010111001100110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0001110";
              state <= "1110100";
            ELSE
              state <= "0010101";
            END IF;
            uut_rst <= '0';
          WHEN "0010101" =>
            uut_valid_in <= '1';
            uut_a <= "001110100011000000001101000";
            uut_b <= "000000100111110011010011011";
            IF uut_c /= "000111011010001100111111000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0001111";
              state <= "1110100";
            ELSE
              state <= "0010110";
            END IF;
            uut_rst <= '0';
          WHEN "0010110" =>
            uut_valid_in <= '1';
            uut_a <= "000101010111000001101000110";
            uut_b <= "011101011101111101001010101";
            IF uut_c /= "111001111110001001100001111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0010000";
              state <= "1110100";
            ELSE
              state <= "0010111";
            END IF;
            uut_rst <= '0';
          WHEN "0010111" =>
            uut_valid_in <= '1';
            uut_a <= "100101110111100000110101101";
            uut_b <= "010001101111101111010111100";
            IF uut_c /= "110011011000010001001011110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0010001";
              state <= "1110100";
            ELSE
              state <= "0011000";
            END IF;
            uut_rst <= '0';
          WHEN "0011000" =>
            uut_valid_in <= '1';
            uut_a <= "011011100100100100010111100";
            uut_b <= "000110011000011110101100100";
            IF uut_c /= "111011101100001000010111101" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0010010";
              state <= "1110100";
            ELSE
              state <= "0011001";
            END IF;
            uut_rst <= '0';
          WHEN "0011001" =>
            uut_valid_in <= '1';
            uut_a <= "000001100111101101011000001";
            uut_b <= "000100000011100011111100101";
            IF uut_c /= "000111010100010001000100000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0010011";
              state <= "1110100";
            ELSE
              state <= "0011010";
            END IF;
            uut_rst <= '0';
          WHEN "0011010" =>
            uut_valid_in <= '1';
            uut_a <= "001111111010110010010111010";
            uut_b <= "001010000100011100010000010";
            IF uut_c /= "001010111010010111001011001" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0010100";
              state <= "1110100";
            ELSE
              state <= "0011011";
            END IF;
            uut_rst <= '0';
          WHEN "0011011" =>
            uut_valid_in <= '1';
            uut_a <= "101011111110101010100100110";
            uut_b <= "011111010111110110010110011";
            IF uut_c /= "000000010010000101111110110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0010101";
              state <= "1110100";
            ELSE
              state <= "0011100";
            END IF;
            uut_rst <= '0';
          WHEN "0011100" =>
            uut_valid_in <= '1';
            uut_a <= "001101100111101111010110110";
            uut_b <= "011010011010111011100110000";
            IF uut_c /= "000100111011111000100110000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0010110";
              state <= "1110100";
            ELSE
              state <= "0011101";
            END IF;
            uut_rst <= '0';
          WHEN "0011101" =>
            uut_valid_in <= '1';
            uut_a <= "001011101110011101111110011";
            uut_b <= "010110000011111001010001011";
            IF uut_c /= "110001100000100000010011000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0010111";
              state <= "1110100";
            ELSE
              state <= "0011110";
            END IF;
            uut_rst <= '0';
          WHEN "0011110" =>
            uut_valid_in <= '1';
            uut_a <= "000001111110011101111011010";
            uut_b <= "000110000010110001011011101";
            IF uut_c /= "000101011111111100101100010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0011000";
              state <= "1110100";
            ELSE
              state <= "0011111";
            END IF;
            uut_rst <= '0';
          WHEN "0011111" =>
            uut_valid_in <= '1';
            uut_a <= "111111100011011001000111000";
            uut_b <= "010001111001111100000000100";
            IF uut_c /= "000000001101001001001101110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0011001";
              state <= "1110100";
            ELSE
              state <= "0100000";
            END IF;
            uut_rst <= '0';
          WHEN "0100000" =>
            uut_valid_in <= '1';
            uut_a <= "010101000000101000101101000";
            uut_b <= "000110011111011110011001001";
            IF uut_c /= "000101000000100101001001000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0011010";
              state <= "1110100";
            ELSE
              state <= "0100001";
            END IF;
            uut_rst <= '0';
          WHEN "0100001" =>
            uut_valid_in <= '1';
            uut_a <= "000001110001101001100000010";
            uut_b <= "011001110110011001011011100";
            IF uut_c /= "101100010111110010010001111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0011011";
              state <= "1110100";
            ELSE
              state <= "0100010";
            END IF;
            uut_rst <= '0';
          WHEN "0100010" =>
            uut_valid_in <= '1';
            uut_a <= "110110101110100000100000001";
            uut_b <= "010001100001110011010110010";
            IF uut_c /= "001011001111110000001000011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0011100";
              state <= "1110100";
            ELSE
              state <= "0100011";
            END IF;
            uut_rst <= '0';
          WHEN "0100011" =>
            uut_valid_in <= '1';
            uut_a <= "001101111010101000000001101";
            uut_b <= "000110011110101111101100110";
            IF uut_c /= "001000000101010111111100110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0011101";
              state <= "1110100";
            ELSE
              state <= "0100100";
            END IF;
            uut_rst <= '0';
          WHEN "0100100" =>
            uut_valid_in <= '1';
            uut_a <= "001001001100110101000000100";
            uut_b <= "000000000000001011101010101";
            IF uut_c /= "000000010111111000100100010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0011110";
              state <= "1110100";
            ELSE
              state <= "0100101";
            END IF;
            uut_rst <= '0';
          WHEN "0100101" =>
            uut_valid_in <= '1';
            uut_a <= "000000110101111110010001000";
            uut_b <= "010010001111000000101000001";
            IF uut_c /= "111111101111111111100010110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0011111";
              state <= "1110100";
            ELSE
              state <= "0100110";
            END IF;
            uut_rst <= '0';
          WHEN "0100110" =>
            uut_valid_in <= '1';
            uut_a <= "100000011100110100101000001";
            uut_b <= "011100100011110010001001100";
            IF uut_c /= "000100010000110010001100111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0100000";
              state <= "1110100";
            ELSE
              state <= "0100111";
            END IF;
            uut_rst <= '0';
          WHEN "0100111" =>
            uut_valid_in <= '1';
            uut_a <= "010101010100110000101101000";
            uut_b <= "011000110011100010011111001";
            IF uut_c /= "000001011011110011100111100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0100001";
              state <= "1110100";
            ELSE
              state <= "0101000";
            END IF;
            uut_rst <= '0';
          WHEN "0101000" =>
            uut_valid_in <= '1';
            uut_a <= "010010011100001101000001110";
            uut_b <= "001011111101001100011000000";
            IF uut_c /= "111010111010111010010110010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0100010";
              state <= "1110100";
            ELSE
              state <= "0101001";
            END IF;
            uut_rst <= '0';
          WHEN "0101001" =>
            uut_valid_in <= '1';
            uut_a <= "101001101111110111101010111";
            uut_b <= "001011010001011011011101100";
            IF uut_c /= "000010110100010111001101011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0100011";
              state <= "1110100";
            ELSE
              state <= "0101010";
            END IF;
            uut_rst <= '0';
          WHEN "0101010" =>
            uut_valid_in <= '1';
            uut_a <= "001001010010010100100011001";
            uut_b <= "011101110100100110110100000";
            IF uut_c /= "000000000000000011010110101" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0100100";
              state <= "1110100";
            ELSE
              state <= "0101011";
            END IF;
            uut_rst <= '0';
          WHEN "0101011" =>
            uut_valid_in <= '1';
            uut_a <= "100101111110001111100011001";
            uut_b <= "010111101001000001000101000";
            IF uut_c /= "000000011110110000010101110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0100101";
              state <= "1110100";
            ELSE
              state <= "0101100";
            END IF;
            uut_rst <= '0';
          WHEN "0101100" =>
            uut_valid_in <= '1';
            uut_a <= "100011100010011000000000011";
            uut_b <= "011000001110101010010001100";
            IF uut_c /= "100011110101111100001000010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0100110";
              state <= "1110100";
            ELSE
              state <= "0101101";
            END IF;
            uut_rst <= '0';
          WHEN "0101101" =>
            uut_valid_in <= '1';
            uut_a <= "111101101010011100111101000";
            uut_b <= "000001011100001010110100101";
            IF uut_c /= "010000100001111010100110001" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0100111";
              state <= "1110100";
            ELSE
              state <= "0101110";
            END IF;
            uut_rst <= '0';
          WHEN "0101110" =>
            uut_valid_in <= '1';
            uut_a <= "010101111000111100111110110";
            uut_b <= "000101010001010101000100101";
            IF uut_c /= "000110111000111101010111110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0101000";
              state <= "1110100";
            ELSE
              state <= "0101111";
            END IF;
            uut_rst <= '0';
          WHEN "0101111" =>
            uut_valid_in <= '1';
            uut_a <= "100111010111010101111100010";
            uut_b <= "001000101100001010000001101";
            IF uut_c /= "111000001010010101011110001" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0101001";
              state <= "1110100";
            ELSE
              state <= "0110000";
            END IF;
            uut_rst <= '0';
          WHEN "0110000" =>
            uut_valid_in <= '1';
            uut_a <= "110100000111101110011110101";
            uut_b <= "010011011001010001011000010";
            IF uut_c /= "001000101001110111101010000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0101010";
              state <= "1110100";
            ELSE
              state <= "0110001";
            END IF;
            uut_rst <= '0';
          WHEN "0110001" =>
            uut_valid_in <= '1';
            uut_a <= "001011010110111001110101010";
            uut_b <= "011111100110101100001111101";
            IF uut_c /= "101100110001011000000011000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0101011";
              state <= "1110100";
            ELSE
              state <= "0110010";
            END IF;
            uut_rst <= '0';
          WHEN "0110010" =>
            uut_valid_in <= '1';
            uut_a <= "011111100100011001010110001";
            uut_b <= "011000001111011011110011011";
            IF uut_c /= "101010011100101111011100010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0101100";
              state <= "1110100";
            ELSE
              state <= "0110011";
            END IF;
            uut_rst <= '0';
          WHEN "0110011" =>
            uut_valid_in <= '1';
            uut_a <= "110001100110101001001110011";
            uut_b <= "011110100001110100011111010";
            IF uut_c /= "111111111001010001010000101" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0101101";
              state <= "1110100";
            ELSE
              state <= "0110100";
            END IF;
            uut_rst <= '0';
          WHEN "0110100" =>
            uut_valid_in <= '1';
            uut_a <= "111010010011110010110001110";
            uut_b <= "000110111011101001001111110";
            IF uut_c /= "000011100110110000001100101" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0101110";
              state <= "1110100";
            ELSE
              state <= "0110101";
            END IF;
            uut_rst <= '0';
          WHEN "0110101" =>
            uut_valid_in <= '1';
            uut_a <= "001000010000111010101011001";
            uut_b <= "000000011110011100111010100";
            IF uut_c /= "111001010011110101110111010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0101111";
              state <= "1110100";
            ELSE
              state <= "0110110";
            END IF;
            uut_rst <= '0';
          WHEN "0110110" =>
            uut_valid_in <= '1';
            uut_a <= "100010110001010110110001110";
            uut_b <= "000101110001001011010100011";
            IF uut_c /= "111000110011001101001011100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0110000";
              state <= "1110100";
            ELSE
              state <= "0110111";
            END IF;
            uut_rst <= '0';
          WHEN "0110111" =>
            uut_valid_in <= '1';
            uut_a <= "101100110101000110101110001";
            uut_b <= "010111000001001111101000100";
            IF uut_c /= "001011001101111010111011010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0110001";
              state <= "1110100";
            ELSE
              state <= "0111000";
            END IF;
            uut_rst <= '0';
          WHEN "0111000" =>
            uut_valid_in <= '1';
            uut_a <= "111100010101111111000100101";
            uut_b <= "011011000011100100011010001";
            IF uut_c /= "010111111010100001011111110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0110010";
              state <= "1110100";
            ELSE
              state <= "0111001";
            END IF;
            uut_rst <= '0';
          WHEN "0111001" =>
            uut_valid_in <= '1';
            uut_a <= "111000111100100101001000101";
            uut_b <= "011010110011010011101001000";
            IF uut_c /= "110010010001000000111000101" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0110011";
              state <= "1110100";
            ELSE
              state <= "0111010";
            END IF;
            uut_rst <= '0';
          WHEN "0111010" =>
            uut_valid_in <= '1';
            uut_a <= "001111111001100001011101011";
            uut_b <= "010010101011101111110101011";
            IF uut_c /= "111110110001000110101011100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0110100";
              state <= "1110100";
            ELSE
              state <= "0111011";
            END IF;
            uut_rst <= '0';
          WHEN "0111011" =>
            uut_valid_in <= '1';
            uut_a <= "101010010001101101011001111";
            uut_b <= "010000111011000100001001000";
            IF uut_c /= "000000000111110111010100111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0110101";
              state <= "1110100";
            ELSE
              state <= "0111100";
            END IF;
            uut_rst <= '0';
          WHEN "0111100" =>
            uut_valid_in <= '1';
            uut_a <= "111101100111000110011001101";
            uut_b <= "001100001001010011100100100";
            IF uut_c /= "111010101110110010110011000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0110110";
              state <= "1110100";
            ELSE
              state <= "0111101";
            END IF;
            uut_rst <= '0';
          WHEN "0111101" =>
            uut_valid_in <= '1';
            uut_a <= "100101111101110111101011101";
            uut_b <= "001000010010101110101101100";
            IF uut_c /= "110010001101011011000111111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0110111";
              state <= "1110100";
            ELSE
              state <= "0111110";
            END IF;
            uut_rst <= '0';
          WHEN "0111110" =>
            uut_valid_in <= '1';
            uut_a <= "110101011111100101100011111";
            uut_b <= "001100000000001110101101010";
            IF uut_c /= "111100111010001001000111100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0111000";
              state <= "1110100";
            ELSE
              state <= "0111111";
            END IF;
            uut_rst <= '0';
          WHEN "0111111" =>
            uut_valid_in <= '1';
            uut_a <= "101001010111000101000101110";
            uut_b <= "001010001000101111101010010";
            IF uut_c /= "111010000101111010011001000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0111001";
              state <= "1110100";
            ELSE
              state <= "1000000";
            END IF;
            uut_rst <= '0';
          WHEN "1000000" =>
            uut_valid_in <= '1';
            uut_a <= "110001111111111001100011011";
            uut_b <= "011010001111100111001111100";
            IF uut_c /= "001001010010000101111000011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0111010";
              state <= "1110100";
            ELSE
              state <= "1000001";
            END IF;
            uut_rst <= '0';
          WHEN "1000001" =>
            uut_valid_in <= '1';
            uut_a <= "110101111001001100110000000";
            uut_b <= "011011111001110111000100001";
            IF uut_c /= "110100100000110000100010110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0111011";
              state <= "1110100";
            ELSE
              state <= "1000010";
            END IF;
            uut_rst <= '0';
          WHEN "1000010" =>
            uut_valid_in <= '1';
            uut_a <= "110001001001110110010100100";
            uut_b <= "011000110100000101011001000";
            IF uut_c /= "111111000101111101111011111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0111100";
              state <= "1110100";
            ELSE
              state <= "1000011";
            END IF;
            uut_rst <= '0';
          WHEN "1000011" =>
            uut_valid_in <= '1';
            uut_a <= "000110111111010100011110111";
            uut_b <= "000000100100110011001101100";
            IF uut_c /= "111001010000001110101110001" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0111101";
              state <= "1110100";
            ELSE
              state <= "1000100";
            END IF;
            uut_rst <= '0';
          WHEN "1000100" =>
            uut_valid_in <= '1';
            uut_a <= "001100111001011001000001000";
            uut_b <= "000000100000010000101011111";
            IF uut_c /= "111100000011110001010000011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0111110";
              state <= "1110100";
            ELSE
              state <= "1000101";
            END IF;
            uut_rst <= '0';
          WHEN "1000101" =>
            uut_valid_in <= '1';
            uut_a <= "001011110001001110011110101";
            uut_b <= "011100000101111100010100101";
            IF uut_c /= "111000110101000001101001000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0111111";
              state <= "1110100";
            ELSE
              state <= "1000110";
            END IF;
            uut_rst <= '0';
          WHEN "1000110" =>
            uut_valid_in <= '1';
            uut_a <= "111011101000101011010111101";
            uut_b <= "010100001100111111011000001";
            IF uut_c /= "110100100001000101100010110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1000000";
              state <= "1110100";
            ELSE
              state <= "1000111";
            END IF;
            uut_rst <= '0';
          WHEN "1000111" =>
            uut_valid_in <= '1';
            uut_a <= "000101100000011011000100000";
            uut_b <= "000111010001101111001111110";
            IF uut_c /= "110111001011111111010000001" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1000001";
              state <= "1110100";
            ELSE
              state <= "1001000";
            END IF;
            uut_rst <= '0';
          WHEN "1001000" =>
            uut_valid_in <= '1';
            uut_a <= "010010001101111100100001000";
            uut_b <= "001001001101000101000100001";
            IF uut_c /= "110100011111001110001111100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1000010";
              state <= "1110100";
            ELSE
              state <= "1001001";
            END IF;
            uut_rst <= '0';
          WHEN "1001001" =>
            uut_valid_in <= '1';
            uut_a <= "011011001010001111100001001";
            uut_b <= "001001100011010001101110111";
            IF uut_c /= "000000001000000010011010111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1000011";
              state <= "1110100";
            ELSE
              state <= "1001010";
            END IF;
            uut_rst <= '0';
          WHEN "1001010" =>
            uut_valid_in <= '1';
            uut_a <= "000010010100101100101010011";
            uut_b <= "001010101011010011110101111";
            IF uut_c /= "000000001101000000000111011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1000100";
              state <= "1110100";
            ELSE
              state <= "1001011";
            END IF;
            uut_rst <= '0';
          WHEN "1001011" =>
            uut_valid_in <= '1';
            uut_a <= "101111001011111101001100000";
            uut_b <= "010001011100101001100110001";
            IF uut_c /= "001010010101010000100010111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1000101";
              state <= "1110100";
            ELSE
              state <= "1001100";
            END IF;
            uut_rst <= '0';
          WHEN "1001100" =>
            uut_valid_in <= '1';
            uut_a <= "100110111001000101001000111";
            uut_b <= "000100011000111001001110001";
            IF uut_c /= "111101001111101001101101110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1000110";
              state <= "1110100";
            ELSE
              state <= "1001101";
            END IF;
            uut_rst <= '0';
          WHEN "1001101" =>
            uut_valid_in <= '1';
            uut_a <= "100110000010110001100110001";
            uut_b <= "001001111100101100001000110";
            IF uut_c /= "000001010000001001010001100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1000111";
              state <= "1110100";
            ELSE
              state <= "1001110";
            END IF;
            uut_rst <= '0';
          WHEN "1001110" =>
            uut_valid_in <= '1';
            uut_a <= "010100000000100011110000001";
            uut_b <= "010000011011110001000010000";
            IF uut_c /= "000101001111010111100100011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1001000";
              state <= "1110100";
            ELSE
              state <= "1001111";
            END IF;
            uut_rst <= '0';
          WHEN "1001111" =>
            uut_valid_in <= '1';
            uut_a <= "010111011101000101100110000";
            uut_b <= "011111011000000010011010110";
            IF uut_c /= "001000000110110100100111100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1001001";
              state <= "1110100";
            ELSE
              state <= "1010000";
            END IF;
            uut_rst <= '0';
          WHEN "1010000" =>
            uut_valid_in <= '1';
            uut_a <= "110100111001111110000001111";
            uut_b <= "000111000001110001100111110";
            IF uut_c /= "000000110001100111001101011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1001010";
              state <= "1110100";
            ELSE
              state <= "1010001";
            END IF;
            uut_rst <= '0';
          WHEN "1010001" =>
            uut_valid_in <= '1';
            uut_a <= "000001001010101001001111101";
            uut_b <= "001011010010111101001011101";
            IF uut_c /= "110110110101010011000111001" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1001011";
              state <= "1110100";
            ELSE
              state <= "1010010";
            END IF;
            uut_rst <= '0';
          WHEN "1010010" =>
            uut_valid_in <= '1';
            uut_a <= "010111000000011010110001101";
            uut_b <= "001000010100100001011011010";
            IF uut_c /= "111100100011100110100011100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1001100";
              state <= "1110100";
            ELSE
              state <= "1010011";
            END IF;
            uut_rst <= '0';
          WHEN "1010011" =>
            uut_valid_in <= '1';
            uut_a <= "010101111111111000011001111";
            uut_b <= "010010101001100100111101110";
            IF uut_c /= "110111111011100011010110011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1001101";
              state <= "1110100";
            ELSE
              state <= "1010100";
            END IF;
            uut_rst <= '0';
          WHEN "1010100" =>
            uut_valid_in <= '1';
            uut_a <= "001110000010101011110110000";
            uut_b <= "001010111111100010010110010";
            IF uut_c /= "001010010001101001000000010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1001110";
              state <= "1110100";
            ELSE
              state <= "1010101";
            END IF;
            uut_rst <= '0';
          WHEN "1010101" =>
            uut_valid_in <= '1';
            uut_a <= "100000100101111111000110100";
            uut_b <= "000110001010001000010110000";
            IF uut_c /= "010110111111110011000000011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1001111";
              state <= "1110100";
            ELSE
              state <= "1010110";
            END IF;
            uut_rst <= '0';
          WHEN "1010110" =>
            uut_valid_in <= '1';
            uut_a <= "000000011110010000101010011";
            uut_b <= "000000110001101001011011010";
            IF uut_c /= "111101100100000100001011010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1010000";
              state <= "1110100";
            ELSE
              state <= "1010111";
            END IF;
            uut_rst <= '0';
          WHEN "1010111" =>
            uut_valid_in <= '1';
            uut_a <= "000011001100111110000100000";
            uut_b <= "001000110101101000000000001";
            IF uut_c /= "000000011010010110011001010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1010001";
              state <= "1110100";
            ELSE
              state <= "1011000";
            END IF;
            uut_rst <= '0';
          WHEN "1011000" =>
            uut_valid_in <= '1';
            uut_a <= "001100100011110011011101001";
            uut_b <= "011100001101000000101011010";
            IF uut_c /= "000101111110110110111111001" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1010010";
              state <= "1110100";
            ELSE
              state <= "1011001";
            END IF;
            uut_rst <= '0';
          WHEN "1011001" =>
            uut_valid_in <= '1';
            uut_a <= "100001100101000110000101001";
            uut_b <= "001010111010110010100111001";
            IF uut_c /= "001100110100100000111111001" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1010011";
              state <= "1110100";
            ELSE
              state <= "1011010";
            END IF;
            uut_rst <= '0';
          WHEN "1011010" =>
            uut_valid_in <= '1';
            uut_a <= "111010111110000100111110000";
            uut_b <= "000010100011110111001110001";
            IF uut_c /= "000100110100101110000011110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1010100";
              state <= "1110100";
            ELSE
              state <= "1011011";
            END IF;
            uut_rst <= '0';
          WHEN "1011011" =>
            uut_valid_in <= '1';
            uut_a <= "100101000101000010000111111";
            uut_b <= "000010010100001110011111111";
            IF uut_c /= "111001111101001011100000110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1010101";
              state <= "1110100";
            ELSE
              state <= "1011100";
            END IF;
            uut_rst <= '0';
          WHEN "1011100" =>
            uut_valid_in <= '1';
            uut_a <= "011001100111110010111111100";
            uut_b <= "011111000001001001001011010";
            IF uut_c /= "000000000000101110111100101" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1010110";
              state <= "1110100";
            ELSE
              state <= "1011101";
            END IF;
            uut_rst <= '0';
          WHEN "1011101" =>
            uut_valid_in <= '1';
            uut_a <= "111001000010110010110001010";
            uut_b <= "001010000010001110001110100";
            IF uut_c /= "000000111000100111000000000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1010111";
              state <= "1110100";
            ELSE
              state <= "1011110";
            END IF;
            uut_rst <= '0';
          WHEN "1011110" =>
            uut_valid_in <= '1';
            uut_a <= "000011011010010111110101011";
            uut_b <= "011001010110000111010100101";
            IF uut_c /= "001011000100011011110101010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1011000";
              state <= "1110100";
            ELSE
              state <= "1011111";
            END IF;
            uut_rst <= '0';
          WHEN "1011111" =>
            uut_valid_in <= '1';
            uut_a <= "010011000101111001001111110";
            uut_b <= "011011100111111101000001011";
            IF uut_c /= "110101100111101101000001011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1011001";
              state <= "1110100";
            ELSE
              state <= "1100000";
            END IF;
            uut_rst <= '0';
          WHEN "1100000" =>
            uut_valid_in <= '1';
            uut_a <= "010011000100011101000000010";
            uut_b <= "000000001101000011110001001";
            IF uut_c /= "111111100110001111100001110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1011010";
              state <= "1110100";
            ELSE
              state <= "1100001";
            END IF;
            uut_rst <= '0';
          WHEN "1100001" =>
            uut_valid_in <= '1';
            uut_a <= "011010110111111010100111110";
            uut_b <= "000000100100110010010110001";
            IF uut_c /= "111110000011010011000101001" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1011011";
              state <= "1110100";
            ELSE
              state <= "1100010";
            END IF;
            uut_rst <= '0';
          WHEN "1100010" =>
            uut_valid_in <= '1';
            uut_a <= "100001111000011111010110101";
            uut_b <= "010110110001000011011011001";
            IF uut_c /= "011000110101011101111111010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1011100";
              state <= "1110100";
            ELSE
              state <= "1100011";
            END IF;
            uut_rst <= '0';
          WHEN "1100011" =>
            uut_valid_in <= '1';
            uut_a <= "000010011101010110000011000";
            uut_b <= "010000110010010110110111111";
            IF uut_c /= "111101110100011000111100101" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1011101";
              state <= "1110100";
            ELSE
              state <= "1100100";
            END IF;
            uut_rst <= '0';
          WHEN "1100100" =>
            uut_valid_in <= '1';
            uut_a <= "000000001001001011001011110";
            uut_b <= "000010000110011111110100110";
            IF uut_c /= "000010101100111101100010000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1011110";
              state <= "1110100";
            ELSE
              state <= "1100101";
            END IF;
            uut_rst <= '0';
          WHEN "1100101" =>
            uut_valid_in <= '1';
            uut_a <= "101110101110001111110001001";
            uut_b <= "000011101111101100101101010";
            IF uut_c /= "010000011110110011111001000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1011111";
              state <= "1110100";
            ELSE
              state <= "1100110";
            END IF;
            uut_rst <= '0';
          WHEN "1100110" =>
            uut_valid_in <= '1';
            uut_a <= "011111010110000110100010111";
            uut_b <= "000010010000011010101111001";
            IF uut_c /= "000000000111110010000011011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1100000";
              state <= "1110100";
            ELSE
              state <= "1100111";
            END IF;
            uut_rst <= '0';
          WHEN "1100111" =>
            uut_valid_in <= '1';
            uut_a <= "100011110101110110110101110";
            uut_b <= "010101001010111010001110111";
            IF uut_c /= "000000011110111001001011111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1100001";
              state <= "1110100";
            ELSE
              state <= "1101000";
            END IF;
            uut_rst <= '0';
          WHEN "1101000" =>
            uut_valid_in <= '1';
            uut_a <= "110110000001010000101011100";
            uut_b <= "000100000111001100100000000";
            IF uut_c /= "101010100100101010110101010" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1100010";
              state <= "1110100";
            ELSE
              state <= "1101001";
            END IF;
            uut_rst <= '0';
          WHEN "1101001" =>
            uut_valid_in <= '1';
            uut_a <= "001000110001101101010010101";
            uut_b <= "010111111000110011101100101";
            IF uut_c /= "000001010010100010101000011" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1100011";
              state <= "1110100";
            ELSE
              state <= "1101010";
            END IF;
            uut_rst <= '0';
          WHEN "1101010" =>
            uut_valid_in <= '1';
            uut_a <= "010011100010010111111111011";
            uut_b <= "001000100110111101111011001";
            IF uut_c /= "000000000000100110100011111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1100100";
              state <= "1110100";
            ELSE
              state <= "1101011";
            END IF;
            uut_rst <= '0';
          WHEN "1101011" =>
            uut_valid_in <= '1';
            uut_a <= "111011110001100101001100011";
            uut_b <= "001100110110111001100101000";
            IF uut_c /= "111101111110100101010000111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1100101";
              state <= "1110100";
            ELSE
              state <= "1101100";
            END IF;
            uut_rst <= '0';
          WHEN "1101100" =>
            uut_valid_in <= '1';
            uut_a <= "000110111010111100110111011";
            uut_b <= "011000101001001000111001110";
            IF uut_c /= "000010001101011101101001100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1100110";
              state <= "1110100";
            ELSE
              state <= "1101101";
            END IF;
            uut_rst <= '0';
          WHEN "1101101" =>
            uut_valid_in <= '1';
            uut_a <= "011100001110110110000000000";
            uut_b <= "000100001101001111010110100";
            IF uut_c /= "101101010111101111100100111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1100111";
              state <= "1110100";
            ELSE
              state <= "1101110";
            END IF;
            uut_rst <= '0';
          WHEN "1101110" =>
            IF uut_c /= "111110101101111010011101100" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1101000";
              state <= "1110100";
            ELSE
              state <= "1101111";
            END IF;
            uut_rst <= '0';
          WHEN "1101111" =>
            IF uut_c /= "000110100011010011101110000" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1101001";
              state <= "1110100";
            ELSE
              state <= "1110000";
            END IF;
            uut_rst <= '0';
          WHEN "1110000" =>
            IF uut_c /= "000101010000011000100111111" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1101010";
              state <= "1110100";
            ELSE
              state <= "1110001";
            END IF;
            uut_rst <= '0';
          WHEN "1110001" =>
            IF uut_c /= "111110010011010110000000110" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1101011";
              state <= "1110100";
            ELSE
              state <= "1110010";
            END IF;
            uut_rst <= '0';
          WHEN "1110010" =>
            IF uut_c /= "000101010101000111000110101" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1101100";
              state <= "1110100";
            ELSE
              state <= "1110011";
            END IF;
            uut_rst <= '0';
          WHEN "1110011" =>
            IF uut_c /= "000011101101100010010100101" OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1101101";
              state <= "1110100";
            ELSE
              state <= "1110100";
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
