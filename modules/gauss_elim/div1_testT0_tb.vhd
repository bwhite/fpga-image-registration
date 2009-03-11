LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY div1_testT0_tb IS
PORT(
  CLK : IN STD_LOGIC;
  RST : IN STD_LOGIC;
  DONE : OUT STD_LOGIC;
  FAIL : OUT STD_LOGIC;
  FAIL_NUM : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END div1_testT0_tb;
ARCHITECTURE behavior OF div1_testT0_tb IS
  COMPONENT div1_test
  PORT(
    CLK : IN STD_LOGIC;
    RST : IN STD_LOGIC;
    VALID_IN : IN STD_LOGIC;
    A : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    C : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    OOB : OUT STD_LOGIC;
    VALID_OUT : OUT STD_LOGIC);
  END COMPONENT;
  SIGNAL uut_rst_wire, uut_rst : STD_LOGIC;
  SIGNAL state : STD_LOGIC_VECTOR(6 DOWNTO 0);
  -- UUT Input
  SIGNAL uut_valid_in : STD_LOGIC;
  SIGNAL uut_a, uut_b : STD_LOGIC_VECTOR(26 DOWNTO 0);
  -- UUT Output
  SIGNAL uut_oob, uut_valid_out : STD_LOGIC;
  SIGNAL uut_c : STD_LOGIC_VECTOR(26 DOWNTO 0);
BEGIN
  uut_rst_wire <= RST OR uut_rst;
  uut :  div1_test PORT MAP (
    CLK => CLK,
    RST => uut_rst_wire,
    VALID_IN => uut_valid_in,
    A => uut_a,
    B => uut_b,
    C => uut_c,
    OOB => uut_oob,
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
            uut_a <= "110110000010111010110000010";
            uut_b <= "010001111101000000100010110";
            state <= "0000001";
            uut_rst <= '0';
          WHEN "0000001" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0000010";
            uut_rst <= '0';
          WHEN "0000010" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0000011";
            uut_rst <= '0';
          WHEN "0000011" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0000100";
            uut_rst <= '0';
          WHEN "0000100" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0000101";
            uut_rst <= '0';
          WHEN "0000101" =>
            uut_valid_in <= '1';
            uut_a <= "010011010010010100011101111";
            uut_b <= "101110100101001111101010001";
            state <= "0000110";
            uut_rst <= '0';
          WHEN "0000110" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0000111";
            uut_rst <= '0';
          WHEN "0000111" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0001000";
            uut_rst <= '0';
          WHEN "0001000" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0001001";
            uut_rst <= '0';
          WHEN "0001001" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0001010";
            uut_rst <= '0';
          WHEN "0001010" =>
            uut_valid_in <= '1';
            uut_a <= "111111111000001100011011100";
            uut_b <= "011001101001111001000100110";
            state <= "0001011";
            uut_rst <= '0';
          WHEN "0001011" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0001100";
            uut_rst <= '0';
          WHEN "0001100" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0001101";
            uut_rst <= '0';
          WHEN "0001101" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0001110";
            uut_rst <= '0';
          WHEN "0001110" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0001111";
            uut_rst <= '0';
          WHEN "0001111" =>
            uut_valid_in <= '1';
            uut_a <= "000100110001110011111111011";
            uut_b <= "010110000101110110011001000";
            state <= "0010000";
            uut_rst <= '0';
          WHEN "0010000" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0010001";
            uut_rst <= '0';
          WHEN "0010001" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0010010";
            uut_rst <= '0';
          WHEN "0010010" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0010011";
            uut_rst <= '0';
          WHEN "0010011" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0010100";
            uut_rst <= '0';
          WHEN "0010100" =>
            uut_valid_in <= '1';
            uut_a <= "001111010001011110000111110";
            uut_b <= "000101100000001100111111001";
            state <= "0010101";
            uut_rst <= '0';
          WHEN "0010101" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0010110";
            uut_rst <= '0';
          WHEN "0010110" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0010111";
            uut_rst <= '0';
          WHEN "0010111" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0011000";
            uut_rst <= '0';
          WHEN "0011000" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0011001";
            uut_rst <= '0';
          WHEN "0011001" =>
            uut_valid_in <= '1';
            uut_a <= "101111110010100111111110011";
            uut_b <= "001010101001101001000000111";
            state <= "0011010";
            uut_rst <= '0';
          WHEN "0011010" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0011011";
            uut_rst <= '0';
          WHEN "0011011" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0011100";
            uut_rst <= '0';
          WHEN "0011100" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0011101";
            uut_rst <= '0';
          WHEN "0011101" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0011110";
            uut_rst <= '0';
          WHEN "0011110" =>
            uut_valid_in <= '1';
            uut_a <= "100101010101111100100001010";
            uut_b <= "001000000011111011100110100";
            state <= "0011111";
            uut_rst <= '0';
          WHEN "0011111" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0100000";
            uut_rst <= '0';
          WHEN "0100000" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            IF uut_c /= "111111110111001000001110110" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0000000";
              state <= "1100111";
            ELSE
              state <= "0100001";
            END IF;
            uut_rst <= '0';
          WHEN "0100001" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0100010";
            uut_rst <= '0';
          WHEN "0100010" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0100011";
            uut_rst <= '0';
          WHEN "0100011" =>
            uut_valid_in <= '1';
            uut_a <= "001010010011001110101001101";
            uut_b <= "001110101101000100000100100";
            state <= "0100100";
            uut_rst <= '0';
          WHEN "0100100" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0100101";
            uut_rst <= '0';
          WHEN "0100101" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            IF uut_c /= "111111101110010010001010111" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0000101";
              state <= "1100111";
            ELSE
              state <= "0100110";
            END IF;
            uut_rst <= '0';
          WHEN "0100110" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0100111";
            uut_rst <= '0';
          WHEN "0100111" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0101000";
            uut_rst <= '0';
          WHEN "0101000" =>
            uut_valid_in <= '1';
            uut_a <= "011001000000100001010100101";
            uut_b <= "011110110111100000111001011";
            state <= "0101001";
            uut_rst <= '0';
          WHEN "0101001" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0101010";
            uut_rst <= '0';
          WHEN "0101010" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            IF uut_c /= "111111111111111011001000011" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0001010";
              state <= "1100111";
            ELSE
              state <= "0101011";
            END IF;
            uut_rst <= '0';
          WHEN "0101011" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0101100";
            uut_rst <= '0';
          WHEN "0101100" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0101101";
            uut_rst <= '0';
          WHEN "0101101" =>
            uut_valid_in <= '1';
            uut_a <= "010001001101111100010111001";
            uut_b <= "000101001101100110101101011";
            state <= "0101110";
            uut_rst <= '0';
          WHEN "0101110" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0101111";
            uut_rst <= '0';
          WHEN "0101111" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            IF uut_c /= "000000000011011101011111010" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0001111";
              state <= "1100111";
            ELSE
              state <= "0110000";
            END IF;
            uut_rst <= '0';
          WHEN "0110000" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0110001";
            uut_rst <= '0';
          WHEN "0110001" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0110010";
            uut_rst <= '0';
          WHEN "0110010" =>
            uut_valid_in <= '1';
            uut_a <= "011011011010010111101100110";
            uut_b <= "000101001000000011001101011";
            state <= "0110011";
            uut_rst <= '0';
          WHEN "0110011" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0110100";
            uut_rst <= '0';
          WHEN "0110100" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            IF uut_c /= "000000101100011001111010011" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0010100";
              state <= "1100111";
            ELSE
              state <= "0110101";
            END IF;
            uut_rst <= '0';
          WHEN "0110101" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0110110";
            uut_rst <= '0';
          WHEN "0110110" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0110111";
            uut_rst <= '0';
          WHEN "0110111" =>
            uut_valid_in <= '1';
            uut_a <= "100001000101100011111110011";
            uut_b <= "100111101111000010100111001";
            state <= "0111000";
            uut_rst <= '0';
          WHEN "0111000" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0111001";
            uut_rst <= '0';
          WHEN "0111001" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            IF uut_c /= "111111100111101001100110001" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0011001";
              state <= "1100111";
            ELSE
              state <= "0111010";
            END IF;
            uut_rst <= '0';
          WHEN "0111010" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0111011";
            uut_rst <= '0';
          WHEN "0111011" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0111100";
            uut_rst <= '0';
          WHEN "0111100" =>
            uut_valid_in <= '1';
            uut_a <= "010111001101101010011100001";
            uut_b <= "111110111111101011011011001";
            state <= "0111101";
            uut_rst <= '0';
          WHEN "0111101" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "0111110";
            uut_rst <= '0';
          WHEN "0111110" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            IF uut_c /= "111111001011000101111001000" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0011110";
              state <= "1100111";
            ELSE
              state <= "0111111";
            END IF;
            uut_rst <= '0';
          WHEN "0111111" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "1000000";
            uut_rst <= '0';
          WHEN "1000000" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "1000001";
            uut_rst <= '0';
          WHEN "1000001" =>
            uut_valid_in <= '1';
            uut_a <= "010110000100100001110110001";
            uut_b <= "101101011001101110010010011";
            state <= "1000010";
            uut_rst <= '0';
          WHEN "1000010" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "1000011";
            uut_rst <= '0';
          WHEN "1000011" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            IF uut_c /= "000000001011001101010100111" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0100011";
              state <= "1100111";
            ELSE
              state <= "1000100";
            END IF;
            uut_rst <= '0';
          WHEN "1000100" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "1000101";
            uut_rst <= '0';
          WHEN "1000101" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "1000110";
            uut_rst <= '0';
          WHEN "1000110" =>
            uut_valid_in <= '0';
            uut_a <= "001010101111011100010101111";
            uut_b <= "010110000010101000010101101";
            state <= "1000111";
            uut_rst <= '0';
          WHEN "1000111" =>
            state <= "1001000";
            uut_rst <= '0';
          WHEN "1001000" =>
            IF uut_c /= "000000001100111101100111111" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0101000";
              state <= "1100111";
            ELSE
              state <= "1001001";
            END IF;
            uut_rst <= '0';
          WHEN "1001001" =>
            state <= "1001010";
            uut_rst <= '0';
          WHEN "1001010" =>
            state <= "1001011";
            uut_rst <= '0';
          WHEN "1001011" =>
            state <= "1001100";
            uut_rst <= '0';
          WHEN "1001100" =>
            state <= "1001101";
            uut_rst <= '0';
          WHEN "1001101" =>
            IF uut_c /= "000000110100110110011010100" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0101101";
              state <= "1100111";
            ELSE
              state <= "1001110";
            END IF;
            uut_rst <= '0';
          WHEN "1001110" =>
            state <= "1001111";
            uut_rst <= '0';
          WHEN "1001111" =>
            state <= "1010000";
            uut_rst <= '0';
          WHEN "1010000" =>
            state <= "1010001";
            uut_rst <= '0';
          WHEN "1010001" =>
            state <= "1010010";
            uut_rst <= '0';
          WHEN "1010010" =>
            IF uut_c /= "000001010101100100001110001" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0110010";
              state <= "1100111";
            ELSE
              state <= "1010011";
            END IF;
            uut_rst <= '0';
          WHEN "1010011" =>
            state <= "1010100";
            uut_rst <= '0';
          WHEN "1010100" =>
            state <= "1010101";
            uut_rst <= '0';
          WHEN "1010101" =>
            state <= "1010110";
            uut_rst <= '0';
          WHEN "1010110" =>
            state <= "1010111";
            uut_rst <= '0';
          WHEN "1010111" =>
            IF uut_c /= "000000010100011000100011100" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0110111";
              state <= "1100111";
            ELSE
              state <= "1011000";
            END IF;
            uut_rst <= '0';
          WHEN "1011000" =>
            state <= "1011001";
            uut_rst <= '0';
          WHEN "1011001" =>
            state <= "1011010";
            uut_rst <= '0';
          WHEN "1011010" =>
            state <= "1011011";
            uut_rst <= '0';
          WHEN "1011011" =>
            state <= "1011100";
            uut_rst <= '0';
          WHEN "1011100" =>
            IF uut_c /= "111010001110011100001101001" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "0111100";
              state <= "1100111";
            ELSE
              state <= "1011101";
            END IF;
            uut_rst <= '0';
          WHEN "1011101" =>
            state <= "1011110";
            uut_rst <= '0';
          WHEN "1011110" =>
            state <= "1011111";
            uut_rst <= '0';
          WHEN "1011111" =>
            state <= "1100000";
            uut_rst <= '0';
          WHEN "1100000" =>
            state <= "1100001";
            uut_rst <= '0';
          WHEN "1100001" =>
            IF uut_c /= "111111101101000000110010111" OR uut_oob /= '0' OR uut_valid_out /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "1000001";
              state <= "1100111";
            ELSE
              state <= "1100010";
            END IF;
            uut_rst <= '0';
          WHEN "1100010" =>
            state <= "1100011";
            uut_rst <= '0';
          WHEN "1100011" =>
            state <= "1100100";
            uut_rst <= '0';
          WHEN "1100100" =>
            state <= "1100101";
            uut_rst <= '0';
          WHEN "1100101" =>
            state <= "1100110";
            uut_rst <= '0';
          WHEN "1100110" =>
            state <= "1100111";
            uut_rst <= '0';
          WHEN OTHERS =>
            DONE <= '1';
            uut_rst <= '1';
        END CASE;
      END IF;
    END IF;
  END PROCESS;
END;
