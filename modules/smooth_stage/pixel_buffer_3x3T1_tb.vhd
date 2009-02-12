LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY pixel_buffer_3x3T1_tb IS
PORT(
  CLK : IN STD_LOGIC;
  RST : IN STD_LOGIC;
  DONE : OUT STD_LOGIC;
  FAIL : OUT STD_LOGIC;
  FAIL_NUM : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END pixel_buffer_3x3T1_tb;
ARCHITECTURE behavior OF pixel_buffer_3x3T1_tb IS
  COMPONENT pixel_buffer_3x3
  GENERIC(
    PIXEL_BITS : integer := 9);
  PORT(
    CLK : IN STD_LOGIC;
    RST : IN STD_LOGIC;
    MEM_VALUE : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    CLKEN : IN STD_LOGIC;
    NEW_ROW : IN STD_LOGIC;
    OUTPUT_VALID : OUT STD_LOGIC;
    IMG_0_0 : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG_1_0 : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG_2_0 : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG_0_1 : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG_1_1 : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG_2_1 : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG_0_2 : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG_1_2 : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    IMG_2_2 : OUT STD_LOGIC_VECTOR(8 DOWNTO 0));
  END COMPONENT;
  SIGNAL uut_rst_wire, uut_rst : STD_LOGIC;
  SIGNAL state : STD_LOGIC_VECTOR(3 DOWNTO 0);
  -- UUT Input
  SIGNAL uut_clken, uut_new_row : STD_LOGIC;
  SIGNAL uut_mem_value : STD_LOGIC_VECTOR(8 DOWNTO 0);
  -- UUT Output
  SIGNAL uut_output_valid : STD_LOGIC;
  SIGNAL uut_img_0_0, uut_img_1_0, uut_img_2_0, uut_img_0_1, uut_img_1_1, uut_img_2_1, uut_img_0_2, uut_img_1_2, uut_img_2_2 : STD_LOGIC_VECTOR(8 DOWNTO 0);
BEGIN
  uut_rst_wire <= RST OR uut_rst;
  uut :  pixel_buffer_3x3 PORT MAP (
    CLK => CLK,
    RST => uut_rst_wire,
    MEM_VALUE => uut_mem_value,
    CLKEN => uut_clken,
    NEW_ROW => uut_new_row,
    OUTPUT_VALID => uut_output_valid,
    IMG_0_0 => uut_img_0_0,
    IMG_1_0 => uut_img_1_0,
    IMG_2_0 => uut_img_2_0,
    IMG_0_1 => uut_img_0_1,
    IMG_1_1 => uut_img_1_1,
    IMG_2_1 => uut_img_2_1,
    IMG_0_2 => uut_img_0_2,
    IMG_1_2 => uut_img_1_2,
    IMG_2_2 => uut_img_2_2
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
          WHEN "0000" =>
            uut_mem_value <= "000000001";
            uut_clken <= '1';
            state <= "0001";
            uut_rst <= '0';
          WHEN "0001" =>
            uut_mem_value <= "000000010";
            uut_clken <= '1';
            state <= "0010";
            uut_rst <= '0';
          WHEN "0010" =>
            uut_mem_value <= "000000011";
            uut_clken <= '1';
            IF uut_output_valid /= '0' OR uut_img_0_0 /= "000000000" OR uut_img_1_0 /= "000000000" OR uut_img_2_0 /= "000000000" OR uut_img_0_1 /= "000000000" OR uut_img_1_1 /= "000000000" OR uut_img_2_1 /= "000000000" OR uut_img_0_2 /= "000000001" OR uut_img_1_2 /= "000000000" OR uut_img_2_2 /= "000000000" THEN
              FAIL <= '1';
              FAIL_NUM <= "0000";
              state <= "1111";
            ELSE
              state <= "0011";
            END IF;
            uut_rst <= '0';
          WHEN "0011" =>
            uut_mem_value <= "000000100";
            uut_clken <= '1';
            IF uut_output_valid /= '0' OR uut_img_0_0 /= "000000000" OR uut_img_1_0 /= "000000000" OR uut_img_2_0 /= "000000000" OR uut_img_0_1 /= "000000000" OR uut_img_1_1 /= "000000000" OR uut_img_2_1 /= "000000000" OR uut_img_0_2 /= "000000001" OR uut_img_1_2 /= "000000010" OR uut_img_2_2 /= "000000000" THEN
              FAIL <= '1';
              FAIL_NUM <= "0001";
              state <= "1111";
            ELSE
              state <= "0100";
            END IF;
            uut_rst <= '0';
          WHEN "0100" =>
            uut_mem_value <= "000000101";
            uut_clken <= '1';
            IF uut_output_valid /= '0' OR uut_img_0_0 /= "000000000" OR uut_img_1_0 /= "000000000" OR uut_img_2_0 /= "000000000" OR uut_img_0_1 /= "000000000" OR uut_img_1_1 /= "000000000" OR uut_img_2_1 /= "000000000" OR uut_img_0_2 /= "000000001" OR uut_img_1_2 /= "000000010" OR uut_img_2_2 /= "000000011" THEN
              FAIL <= '1';
              FAIL_NUM <= "0010";
              state <= "1111";
            ELSE
              state <= "0101";
            END IF;
            uut_rst <= '0';
          WHEN "0101" =>
            uut_mem_value <= "000000110";
            uut_clken <= '1';
            IF uut_output_valid /= '0' OR uut_img_0_0 /= "000000000" OR uut_img_1_0 /= "000000000" OR uut_img_2_0 /= "000000000" OR uut_img_0_1 /= "000000001" OR uut_img_1_1 /= "000000010" OR uut_img_2_1 /= "000000011" OR uut_img_0_2 /= "000000100" OR uut_img_1_2 /= "000000010" OR uut_img_2_2 /= "000000011" THEN
              FAIL <= '1';
              FAIL_NUM <= "0011";
              state <= "1111";
            ELSE
              state <= "0110";
            END IF;
            uut_rst <= '0';
          WHEN "0110" =>
            uut_mem_value <= "000000111";
            uut_clken <= '1';
            IF uut_output_valid /= '0' OR uut_img_0_0 /= "000000000" OR uut_img_1_0 /= "000000000" OR uut_img_2_0 /= "000000000" OR uut_img_0_1 /= "000000001" OR uut_img_1_1 /= "000000010" OR uut_img_2_1 /= "000000011" OR uut_img_0_2 /= "000000100" OR uut_img_1_2 /= "000000101" OR uut_img_2_2 /= "000000011" THEN
              FAIL <= '1';
              FAIL_NUM <= "0100";
              state <= "1111";
            ELSE
              state <= "0111";
            END IF;
            uut_rst <= '0';
          WHEN "0111" =>
            uut_mem_value <= "000001000";
            uut_clken <= '1';
            IF uut_output_valid /= '0' OR uut_img_0_0 /= "000000000" OR uut_img_1_0 /= "000000000" OR uut_img_2_0 /= "000000000" OR uut_img_0_1 /= "000000001" OR uut_img_1_1 /= "000000010" OR uut_img_2_1 /= "000000011" OR uut_img_0_2 /= "000000100" OR uut_img_1_2 /= "000000101" OR uut_img_2_2 /= "000000110" THEN
              FAIL <= '1';
              FAIL_NUM <= "0101";
              state <= "1111";
            ELSE
              state <= "1000";
            END IF;
            uut_rst <= '0';
          WHEN "1000" =>
            uut_mem_value <= "000001001";
            uut_clken <= '1';
            IF uut_output_valid /= '0' OR uut_img_0_0 /= "000000001" OR uut_img_1_0 /= "000000010" OR uut_img_2_0 /= "000000011" OR uut_img_0_1 /= "000000100" OR uut_img_1_1 /= "000000101" OR uut_img_2_1 /= "000000110" OR uut_img_0_2 /= "000000111" OR uut_img_1_2 /= "000000101" OR uut_img_2_2 /= "000000110" THEN
              FAIL <= '1';
              FAIL_NUM <= "0110";
              state <= "1111";
            ELSE
              state <= "1001";
            END IF;
            uut_rst <= '0';
          WHEN "1001" =>
            uut_mem_value <= "000000000";
            uut_clken <= '0';
            IF uut_output_valid /= '0' OR uut_img_0_0 /= "000000001" OR uut_img_1_0 /= "000000010" OR uut_img_2_0 /= "000000011" OR uut_img_0_1 /= "000000100" OR uut_img_1_1 /= "000000101" OR uut_img_2_1 /= "000000110" OR uut_img_0_2 /= "000000111" OR uut_img_1_2 /= "000001000" OR uut_img_2_2 /= "000000110" THEN
              FAIL <= '1';
              FAIL_NUM <= "0111";
              state <= "1111";
            ELSE
              state <= "1010";
            END IF;
            uut_rst <= '0';
          WHEN "1010" =>
            uut_mem_value <= "000001010";
            uut_clken <= '1';
            IF uut_output_valid /= '1' OR uut_img_0_0 /= "000000001" OR uut_img_1_0 /= "000000010" OR uut_img_2_0 /= "000000011" OR uut_img_0_1 /= "000000100" OR uut_img_1_1 /= "000000101" OR uut_img_2_1 /= "000000110" OR uut_img_0_2 /= "000000111" OR uut_img_1_2 /= "000001000" OR uut_img_2_2 /= "000001001" THEN
              FAIL <= '1';
              FAIL_NUM <= "1000";
              state <= "1111";
            ELSE
              state <= "1011";
            END IF;
            uut_rst <= '0';
          WHEN "1011" =>
            uut_mem_value <= "000001011";
            uut_clken <= '1';
            IF uut_output_valid /= '0' OR uut_img_0_0 /= "000000001" OR uut_img_1_0 /= "000000010" OR uut_img_2_0 /= "000000011" OR uut_img_0_1 /= "000000100" OR uut_img_1_1 /= "000000101" OR uut_img_2_1 /= "000000110" OR uut_img_0_2 /= "000000111" OR uut_img_1_2 /= "000001000" OR uut_img_2_2 /= "000001001" THEN
              FAIL <= '1';
              FAIL_NUM <= "1001";
              state <= "1111";
            ELSE
              state <= "1100";
            END IF;
            uut_rst <= '0';
          WHEN "1100" =>
            uut_mem_value <= "000001100";
            uut_clken <= '1';
            IF uut_output_valid /= '0' OR uut_img_0_0 /= "000000100" OR uut_img_1_0 /= "000000101" OR uut_img_2_0 /= "000000110" OR uut_img_0_1 /= "000000111" OR uut_img_1_1 /= "000001000" OR uut_img_2_1 /= "000001001" OR uut_img_0_2 /= "000001010" OR uut_img_1_2 /= "000001000" OR uut_img_2_2 /= "000001001" THEN
              FAIL <= '1';
              FAIL_NUM <= "1010";
              state <= "1111";
            ELSE
              state <= "1101";
            END IF;
            uut_rst <= '0';
          WHEN "1101" =>
            IF uut_output_valid /= '0' OR uut_img_0_0 /= "000000100" OR uut_img_1_0 /= "000000101" OR uut_img_2_0 /= "000000110" OR uut_img_0_1 /= "000000111" OR uut_img_1_1 /= "000001000" OR uut_img_2_1 /= "000001001" OR uut_img_0_2 /= "000001010" OR uut_img_1_2 /= "000001011" OR uut_img_2_2 /= "000001001" THEN
              FAIL <= '1';
              FAIL_NUM <= "1011";
              state <= "1111";
            ELSE
              state <= "1110";
            END IF;
            uut_rst <= '0';
          WHEN "1110" =>
            IF uut_output_valid /= '1' OR uut_img_0_0 /= "000000100" OR uut_img_1_0 /= "000000101" OR uut_img_2_0 /= "000000110" OR uut_img_0_1 /= "000000111" OR uut_img_1_1 /= "000001000" OR uut_img_2_1 /= "000001001" OR uut_img_0_2 /= "000001010" OR uut_img_1_2 /= "000001011" OR uut_img_2_2 /= "000001100" THEN
              FAIL <= '1';
              FAIL_NUM <= "1100";
              state <= "1111";
            ELSE
              state <= "1111";
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
