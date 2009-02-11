LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY conv_pixel_orderingT0_tb IS
PORT(
  CLK : IN STD_LOGIC;
  RST : IN STD_LOGIC;
  DONE : OUT STD_LOGIC;
  FAIL : OUT STD_LOGIC;
  FAIL_NUM : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END conv_pixel_orderingT0_tb;
ARCHITECTURE behavior OF conv_pixel_orderingT0_tb IS
  COMPONENT conv_pixel_ordering
  GENERIC(
    CONV_HEIGHT : integer := 3;
    BORDER_SIZE : integer := 0;
    ROW_SKIP : integer := 1;
    WIDTH_BITS : integer := 10;
    HEIGHT_BITS : integer := 10;
    CONV_HEIGHT_BITS : integer := 2);
  PORT(
    CLK : IN STD_LOGIC;
    RST : IN STD_LOGIC;
    CLKEN : IN STD_LOGIC;
    HEIGHT : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    WIDTH : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    WIDTH_OFFSET : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
    LAST_VALID_Y_POS : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    NEW_ROW_OFFSET : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
    INITIAL_MEM_ADDR : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
    MEM_ADDR : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
    X_COORD : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    Y_COORD : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    CONV_Y_POS : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    DATA_VALID : OUT STD_LOGIC;
    NEW_ROW : OUT STD_LOGIC;
    DONE : OUT STD_LOGIC);
  END COMPONENT;
  SIGNAL uut_rst_wire, uut_rst : STD_LOGIC;
  SIGNAL state : STD_LOGIC_VECTOR(7 DOWNTO 0);
  -- UUT Input
  SIGNAL uut_clken : STD_LOGIC;
  SIGNAL uut_height, uut_width, uut_last_valid_y_pos : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL uut_width_offset, uut_new_row_offset, uut_initial_mem_addr : STD_LOGIC_VECTOR(19 DOWNTO 0);
  -- UUT Output
  SIGNAL uut_data_valid, uut_new_row, uut_done : STD_LOGIC;
  SIGNAL uut_x_coord, uut_y_coord : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL uut_mem_addr : STD_LOGIC_VECTOR(19 DOWNTO 0);
  SIGNAL uut_conv_y_pos : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
  uut_rst_wire <= RST OR uut_rst;
  uut :  conv_pixel_ordering PORT MAP (
    CLK => CLK,
    RST => uut_rst_wire,
    CLKEN => uut_clken,
    HEIGHT => uut_height,
    WIDTH => uut_width,
    WIDTH_OFFSET => uut_width_offset,
    LAST_VALID_Y_POS => uut_last_valid_y_pos,
    NEW_ROW_OFFSET => uut_new_row_offset,
    INITIAL_MEM_ADDR => uut_initial_mem_addr,
    MEM_ADDR => uut_mem_addr,
    X_COORD => uut_x_coord,
    Y_COORD => uut_y_coord,
    CONV_Y_POS => uut_conv_y_pos,
    DATA_VALID => uut_data_valid,
    NEW_ROW => uut_new_row,
    DONE => uut_done
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
          WHEN "00000000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            state <= "00000001";
            uut_rst <= '0';
          WHEN "00000001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            state <= "00000010";
            uut_rst <= '0';
          WHEN "00000010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000000000" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000000000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '1' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00000000";
              state <= "10110111";
            ELSE
              state <= "00000011";
            END IF;
            uut_rst <= '0';
          WHEN "00000011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000001100" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000000001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00000001";
              state <= "10110111";
            ELSE
              state <= "00000100";
            END IF;
            uut_rst <= '0';
          WHEN "00000100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011000" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00000010";
              state <= "10110111";
            ELSE
              state <= "00000101";
            END IF;
            uut_rst <= '0';
          WHEN "00000101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000000001" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000000000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00000011";
              state <= "10110111";
            ELSE
              state <= "00000110";
            END IF;
            uut_rst <= '0';
          WHEN "00000110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000001101" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000000001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00000100";
              state <= "10110111";
            ELSE
              state <= "00000111";
            END IF;
            uut_rst <= '0';
          WHEN "00000111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011001" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00000101";
              state <= "10110111";
            ELSE
              state <= "00001000";
            END IF;
            uut_rst <= '0';
          WHEN "00001000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000000010" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000000000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00000110";
              state <= "10110111";
            ELSE
              state <= "00001001";
            END IF;
            uut_rst <= '0';
          WHEN "00001001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000001110" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000000001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00000111";
              state <= "10110111";
            ELSE
              state <= "00001010";
            END IF;
            uut_rst <= '0';
          WHEN "00001010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011010" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00001000";
              state <= "10110111";
            ELSE
              state <= "00001011";
            END IF;
            uut_rst <= '0';
          WHEN "00001011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000000011" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000000000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00001001";
              state <= "10110111";
            ELSE
              state <= "00001100";
            END IF;
            uut_rst <= '0';
          WHEN "00001100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000001111" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000000001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00001010";
              state <= "10110111";
            ELSE
              state <= "00001101";
            END IF;
            uut_rst <= '0';
          WHEN "00001101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011011" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00001011";
              state <= "10110111";
            ELSE
              state <= "00001110";
            END IF;
            uut_rst <= '0';
          WHEN "00001110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000000100" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000000000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00001100";
              state <= "10110111";
            ELSE
              state <= "00001111";
            END IF;
            uut_rst <= '0';
          WHEN "00001111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000010000" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000000001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00001101";
              state <= "10110111";
            ELSE
              state <= "00010000";
            END IF;
            uut_rst <= '0';
          WHEN "00010000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011100" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00001110";
              state <= "10110111";
            ELSE
              state <= "00010001";
            END IF;
            uut_rst <= '0';
          WHEN "00010001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000000101" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000000000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00001111";
              state <= "10110111";
            ELSE
              state <= "00010010";
            END IF;
            uut_rst <= '0';
          WHEN "00010010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000010001" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000000001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00010000";
              state <= "10110111";
            ELSE
              state <= "00010011";
            END IF;
            uut_rst <= '0';
          WHEN "00010011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011101" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00010001";
              state <= "10110111";
            ELSE
              state <= "00010100";
            END IF;
            uut_rst <= '0';
          WHEN "00010100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000000110" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000000000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00010010";
              state <= "10110111";
            ELSE
              state <= "00010101";
            END IF;
            uut_rst <= '0';
          WHEN "00010101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000010010" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000000001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00010011";
              state <= "10110111";
            ELSE
              state <= "00010110";
            END IF;
            uut_rst <= '0';
          WHEN "00010110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011110" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00010100";
              state <= "10110111";
            ELSE
              state <= "00010111";
            END IF;
            uut_rst <= '0';
          WHEN "00010111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000000111" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000000000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00010101";
              state <= "10110111";
            ELSE
              state <= "00011000";
            END IF;
            uut_rst <= '0';
          WHEN "00011000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000010011" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000000001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00010110";
              state <= "10110111";
            ELSE
              state <= "00011001";
            END IF;
            uut_rst <= '0';
          WHEN "00011001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011111" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00010111";
              state <= "10110111";
            ELSE
              state <= "00011010";
            END IF;
            uut_rst <= '0';
          WHEN "00011010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000001000" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000000000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00011000";
              state <= "10110111";
            ELSE
              state <= "00011011";
            END IF;
            uut_rst <= '0';
          WHEN "00011011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000010100" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000000001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00011001";
              state <= "10110111";
            ELSE
              state <= "00011100";
            END IF;
            uut_rst <= '0';
          WHEN "00011100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000100000" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00011010";
              state <= "10110111";
            ELSE
              state <= "00011101";
            END IF;
            uut_rst <= '0';
          WHEN "00011101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000001001" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000000000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00011011";
              state <= "10110111";
            ELSE
              state <= "00011110";
            END IF;
            uut_rst <= '0';
          WHEN "00011110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000010101" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000000001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00011100";
              state <= "10110111";
            ELSE
              state <= "00011111";
            END IF;
            uut_rst <= '0';
          WHEN "00011111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000100001" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00011101";
              state <= "10110111";
            ELSE
              state <= "00100000";
            END IF;
            uut_rst <= '0';
          WHEN "00100000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000001010" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000000000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00011110";
              state <= "10110111";
            ELSE
              state <= "00100001";
            END IF;
            uut_rst <= '0';
          WHEN "00100001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000010110" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000000001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00011111";
              state <= "10110111";
            ELSE
              state <= "00100010";
            END IF;
            uut_rst <= '0';
          WHEN "00100010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000100010" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00100000";
              state <= "10110111";
            ELSE
              state <= "00100011";
            END IF;
            uut_rst <= '0';
          WHEN "00100011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000001011" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000000000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00100001";
              state <= "10110111";
            ELSE
              state <= "00100100";
            END IF;
            uut_rst <= '0';
          WHEN "00100100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000010111" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000000001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00100010";
              state <= "10110111";
            ELSE
              state <= "00100101";
            END IF;
            uut_rst <= '0';
          WHEN "00100101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000100011" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00100011";
              state <= "10110111";
            ELSE
              state <= "00100110";
            END IF;
            uut_rst <= '0';
          WHEN "00100110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011000" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '1' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00100100";
              state <= "10110111";
            ELSE
              state <= "00100111";
            END IF;
            uut_rst <= '0';
          WHEN "00100111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000100100" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000000011" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00100101";
              state <= "10110111";
            ELSE
              state <= "00101000";
            END IF;
            uut_rst <= '0';
          WHEN "00101000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110000" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00100110";
              state <= "10110111";
            ELSE
              state <= "00101001";
            END IF;
            uut_rst <= '0';
          WHEN "00101001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011001" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00100111";
              state <= "10110111";
            ELSE
              state <= "00101010";
            END IF;
            uut_rst <= '0';
          WHEN "00101010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000100101" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000000011" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00101000";
              state <= "10110111";
            ELSE
              state <= "00101011";
            END IF;
            uut_rst <= '0';
          WHEN "00101011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110001" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00101001";
              state <= "10110111";
            ELSE
              state <= "00101100";
            END IF;
            uut_rst <= '0';
          WHEN "00101100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011010" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00101010";
              state <= "10110111";
            ELSE
              state <= "00101101";
            END IF;
            uut_rst <= '0';
          WHEN "00101101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000100110" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000000011" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00101011";
              state <= "10110111";
            ELSE
              state <= "00101110";
            END IF;
            uut_rst <= '0';
          WHEN "00101110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110010" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00101100";
              state <= "10110111";
            ELSE
              state <= "00101111";
            END IF;
            uut_rst <= '0';
          WHEN "00101111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011011" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00101101";
              state <= "10110111";
            ELSE
              state <= "00110000";
            END IF;
            uut_rst <= '0';
          WHEN "00110000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000100111" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000000011" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00101110";
              state <= "10110111";
            ELSE
              state <= "00110001";
            END IF;
            uut_rst <= '0';
          WHEN "00110001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110011" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00101111";
              state <= "10110111";
            ELSE
              state <= "00110010";
            END IF;
            uut_rst <= '0';
          WHEN "00110010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011100" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00110000";
              state <= "10110111";
            ELSE
              state <= "00110011";
            END IF;
            uut_rst <= '0';
          WHEN "00110011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000101000" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000000011" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00110001";
              state <= "10110111";
            ELSE
              state <= "00110100";
            END IF;
            uut_rst <= '0';
          WHEN "00110100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110100" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00110010";
              state <= "10110111";
            ELSE
              state <= "00110101";
            END IF;
            uut_rst <= '0';
          WHEN "00110101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011101" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00110011";
              state <= "10110111";
            ELSE
              state <= "00110110";
            END IF;
            uut_rst <= '0';
          WHEN "00110110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000101001" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000000011" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00110100";
              state <= "10110111";
            ELSE
              state <= "00110111";
            END IF;
            uut_rst <= '0';
          WHEN "00110111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110101" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00110101";
              state <= "10110111";
            ELSE
              state <= "00111000";
            END IF;
            uut_rst <= '0';
          WHEN "00111000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011110" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00110110";
              state <= "10110111";
            ELSE
              state <= "00111001";
            END IF;
            uut_rst <= '0';
          WHEN "00111001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000101010" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000000011" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00110111";
              state <= "10110111";
            ELSE
              state <= "00111010";
            END IF;
            uut_rst <= '0';
          WHEN "00111010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110110" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00111000";
              state <= "10110111";
            ELSE
              state <= "00111011";
            END IF;
            uut_rst <= '0';
          WHEN "00111011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000011111" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00111001";
              state <= "10110111";
            ELSE
              state <= "00111100";
            END IF;
            uut_rst <= '0';
          WHEN "00111100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000101011" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000000011" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00111010";
              state <= "10110111";
            ELSE
              state <= "00111101";
            END IF;
            uut_rst <= '0';
          WHEN "00111101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110111" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00111011";
              state <= "10110111";
            ELSE
              state <= "00111110";
            END IF;
            uut_rst <= '0';
          WHEN "00111110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000100000" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00111100";
              state <= "10110111";
            ELSE
              state <= "00111111";
            END IF;
            uut_rst <= '0';
          WHEN "00111111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000101100" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000000011" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00111101";
              state <= "10110111";
            ELSE
              state <= "01000000";
            END IF;
            uut_rst <= '0';
          WHEN "01000000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000111000" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00111110";
              state <= "10110111";
            ELSE
              state <= "01000001";
            END IF;
            uut_rst <= '0';
          WHEN "01000001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000100001" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "00111111";
              state <= "10110111";
            ELSE
              state <= "01000010";
            END IF;
            uut_rst <= '0';
          WHEN "01000010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000101101" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000000011" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01000000";
              state <= "10110111";
            ELSE
              state <= "01000011";
            END IF;
            uut_rst <= '0';
          WHEN "01000011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000111001" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01000001";
              state <= "10110111";
            ELSE
              state <= "01000100";
            END IF;
            uut_rst <= '0';
          WHEN "01000100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000100010" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01000010";
              state <= "10110111";
            ELSE
              state <= "01000101";
            END IF;
            uut_rst <= '0';
          WHEN "01000101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000101110" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000000011" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01000011";
              state <= "10110111";
            ELSE
              state <= "01000110";
            END IF;
            uut_rst <= '0';
          WHEN "01000110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000111010" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01000100";
              state <= "10110111";
            ELSE
              state <= "01000111";
            END IF;
            uut_rst <= '0';
          WHEN "01000111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000100011" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000000010" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01000101";
              state <= "10110111";
            ELSE
              state <= "01001000";
            END IF;
            uut_rst <= '0';
          WHEN "01001000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000101111" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000000011" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01000110";
              state <= "10110111";
            ELSE
              state <= "01001001";
            END IF;
            uut_rst <= '0';
          WHEN "01001001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000111011" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01000111";
              state <= "10110111";
            ELSE
              state <= "01001010";
            END IF;
            uut_rst <= '0';
          WHEN "01001010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110000" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '1' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01001000";
              state <= "10110111";
            ELSE
              state <= "01001011";
            END IF;
            uut_rst <= '0';
          WHEN "01001011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000111100" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000000101" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01001001";
              state <= "10110111";
            ELSE
              state <= "01001100";
            END IF;
            uut_rst <= '0';
          WHEN "01001100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001000" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01001010";
              state <= "10110111";
            ELSE
              state <= "01001101";
            END IF;
            uut_rst <= '0';
          WHEN "01001101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110001" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01001011";
              state <= "10110111";
            ELSE
              state <= "01001110";
            END IF;
            uut_rst <= '0';
          WHEN "01001110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000111101" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000000101" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01001100";
              state <= "10110111";
            ELSE
              state <= "01001111";
            END IF;
            uut_rst <= '0';
          WHEN "01001111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001001" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01001101";
              state <= "10110111";
            ELSE
              state <= "01010000";
            END IF;
            uut_rst <= '0';
          WHEN "01010000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110010" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01001110";
              state <= "10110111";
            ELSE
              state <= "01010001";
            END IF;
            uut_rst <= '0';
          WHEN "01010001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000111110" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000000101" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01001111";
              state <= "10110111";
            ELSE
              state <= "01010010";
            END IF;
            uut_rst <= '0';
          WHEN "01010010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001010" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01010000";
              state <= "10110111";
            ELSE
              state <= "01010011";
            END IF;
            uut_rst <= '0';
          WHEN "01010011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110011" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01010001";
              state <= "10110111";
            ELSE
              state <= "01010100";
            END IF;
            uut_rst <= '0';
          WHEN "01010100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000111111" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000000101" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01010010";
              state <= "10110111";
            ELSE
              state <= "01010101";
            END IF;
            uut_rst <= '0';
          WHEN "01010101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001011" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01010011";
              state <= "10110111";
            ELSE
              state <= "01010110";
            END IF;
            uut_rst <= '0';
          WHEN "01010110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110100" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01010100";
              state <= "10110111";
            ELSE
              state <= "01010111";
            END IF;
            uut_rst <= '0';
          WHEN "01010111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001000000" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000000101" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01010101";
              state <= "10110111";
            ELSE
              state <= "01011000";
            END IF;
            uut_rst <= '0';
          WHEN "01011000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001100" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01010110";
              state <= "10110111";
            ELSE
              state <= "01011001";
            END IF;
            uut_rst <= '0';
          WHEN "01011001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110101" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01010111";
              state <= "10110111";
            ELSE
              state <= "01011010";
            END IF;
            uut_rst <= '0';
          WHEN "01011010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001000001" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000000101" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01011000";
              state <= "10110111";
            ELSE
              state <= "01011011";
            END IF;
            uut_rst <= '0';
          WHEN "01011011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001101" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01011001";
              state <= "10110111";
            ELSE
              state <= "01011100";
            END IF;
            uut_rst <= '0';
          WHEN "01011100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110110" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01011010";
              state <= "10110111";
            ELSE
              state <= "01011101";
            END IF;
            uut_rst <= '0';
          WHEN "01011101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001000010" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000000101" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01011011";
              state <= "10110111";
            ELSE
              state <= "01011110";
            END IF;
            uut_rst <= '0';
          WHEN "01011110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001110" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01011100";
              state <= "10110111";
            ELSE
              state <= "01011111";
            END IF;
            uut_rst <= '0';
          WHEN "01011111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000110111" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01011101";
              state <= "10110111";
            ELSE
              state <= "01100000";
            END IF;
            uut_rst <= '0';
          WHEN "01100000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001000011" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000000101" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01011110";
              state <= "10110111";
            ELSE
              state <= "01100001";
            END IF;
            uut_rst <= '0';
          WHEN "01100001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001111" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01011111";
              state <= "10110111";
            ELSE
              state <= "01100010";
            END IF;
            uut_rst <= '0';
          WHEN "01100010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000111000" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01100000";
              state <= "10110111";
            ELSE
              state <= "01100011";
            END IF;
            uut_rst <= '0';
          WHEN "01100011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001000100" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000000101" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01100001";
              state <= "10110111";
            ELSE
              state <= "01100100";
            END IF;
            uut_rst <= '0';
          WHEN "01100100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001010000" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01100010";
              state <= "10110111";
            ELSE
              state <= "01100101";
            END IF;
            uut_rst <= '0';
          WHEN "01100101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000111001" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01100011";
              state <= "10110111";
            ELSE
              state <= "01100110";
            END IF;
            uut_rst <= '0';
          WHEN "01100110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001000101" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000000101" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01100100";
              state <= "10110111";
            ELSE
              state <= "01100111";
            END IF;
            uut_rst <= '0';
          WHEN "01100111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001010001" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01100101";
              state <= "10110111";
            ELSE
              state <= "01101000";
            END IF;
            uut_rst <= '0';
          WHEN "01101000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000111010" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01100110";
              state <= "10110111";
            ELSE
              state <= "01101001";
            END IF;
            uut_rst <= '0';
          WHEN "01101001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001000110" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000000101" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01100111";
              state <= "10110111";
            ELSE
              state <= "01101010";
            END IF;
            uut_rst <= '0';
          WHEN "01101010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001010010" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01101000";
              state <= "10110111";
            ELSE
              state <= "01101011";
            END IF;
            uut_rst <= '0';
          WHEN "01101011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000000111011" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000000100" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01101001";
              state <= "10110111";
            ELSE
              state <= "01101100";
            END IF;
            uut_rst <= '0';
          WHEN "01101100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001000111" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000000101" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01101010";
              state <= "10110111";
            ELSE
              state <= "01101101";
            END IF;
            uut_rst <= '0';
          WHEN "01101101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001010011" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01101011";
              state <= "10110111";
            ELSE
              state <= "01101110";
            END IF;
            uut_rst <= '0';
          WHEN "01101110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001000" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '1' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01101100";
              state <= "10110111";
            ELSE
              state <= "01101111";
            END IF;
            uut_rst <= '0';
          WHEN "01101111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001010100" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000000111" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01101101";
              state <= "10110111";
            ELSE
              state <= "01110000";
            END IF;
            uut_rst <= '0';
          WHEN "01110000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100000" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01101110";
              state <= "10110111";
            ELSE
              state <= "01110001";
            END IF;
            uut_rst <= '0';
          WHEN "01110001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001001" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01101111";
              state <= "10110111";
            ELSE
              state <= "01110010";
            END IF;
            uut_rst <= '0';
          WHEN "01110010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001010101" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000000111" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01110000";
              state <= "10110111";
            ELSE
              state <= "01110011";
            END IF;
            uut_rst <= '0';
          WHEN "01110011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100001" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01110001";
              state <= "10110111";
            ELSE
              state <= "01110100";
            END IF;
            uut_rst <= '0';
          WHEN "01110100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001010" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01110010";
              state <= "10110111";
            ELSE
              state <= "01110101";
            END IF;
            uut_rst <= '0';
          WHEN "01110101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001010110" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000000111" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01110011";
              state <= "10110111";
            ELSE
              state <= "01110110";
            END IF;
            uut_rst <= '0';
          WHEN "01110110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100010" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01110100";
              state <= "10110111";
            ELSE
              state <= "01110111";
            END IF;
            uut_rst <= '0';
          WHEN "01110111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001011" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01110101";
              state <= "10110111";
            ELSE
              state <= "01111000";
            END IF;
            uut_rst <= '0';
          WHEN "01111000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001010111" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000000111" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01110110";
              state <= "10110111";
            ELSE
              state <= "01111001";
            END IF;
            uut_rst <= '0';
          WHEN "01111001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100011" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01110111";
              state <= "10110111";
            ELSE
              state <= "01111010";
            END IF;
            uut_rst <= '0';
          WHEN "01111010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001100" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01111000";
              state <= "10110111";
            ELSE
              state <= "01111011";
            END IF;
            uut_rst <= '0';
          WHEN "01111011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001011000" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000000111" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01111001";
              state <= "10110111";
            ELSE
              state <= "01111100";
            END IF;
            uut_rst <= '0';
          WHEN "01111100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100100" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01111010";
              state <= "10110111";
            ELSE
              state <= "01111101";
            END IF;
            uut_rst <= '0';
          WHEN "01111101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001101" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01111011";
              state <= "10110111";
            ELSE
              state <= "01111110";
            END IF;
            uut_rst <= '0';
          WHEN "01111110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001011001" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000000111" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01111100";
              state <= "10110111";
            ELSE
              state <= "01111111";
            END IF;
            uut_rst <= '0';
          WHEN "01111111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100101" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01111101";
              state <= "10110111";
            ELSE
              state <= "10000000";
            END IF;
            uut_rst <= '0';
          WHEN "10000000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001110" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01111110";
              state <= "10110111";
            ELSE
              state <= "10000001";
            END IF;
            uut_rst <= '0';
          WHEN "10000001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001011010" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000000111" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "01111111";
              state <= "10110111";
            ELSE
              state <= "10000010";
            END IF;
            uut_rst <= '0';
          WHEN "10000010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100110" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10000000";
              state <= "10110111";
            ELSE
              state <= "10000011";
            END IF;
            uut_rst <= '0';
          WHEN "10000011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001001111" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10000001";
              state <= "10110111";
            ELSE
              state <= "10000100";
            END IF;
            uut_rst <= '0';
          WHEN "10000100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001011011" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000000111" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10000010";
              state <= "10110111";
            ELSE
              state <= "10000101";
            END IF;
            uut_rst <= '0';
          WHEN "10000101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100111" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10000011";
              state <= "10110111";
            ELSE
              state <= "10000110";
            END IF;
            uut_rst <= '0';
          WHEN "10000110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001010000" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10000100";
              state <= "10110111";
            ELSE
              state <= "10000111";
            END IF;
            uut_rst <= '0';
          WHEN "10000111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001011100" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000000111" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10000101";
              state <= "10110111";
            ELSE
              state <= "10001000";
            END IF;
            uut_rst <= '0';
          WHEN "10001000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001101000" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10000110";
              state <= "10110111";
            ELSE
              state <= "10001001";
            END IF;
            uut_rst <= '0';
          WHEN "10001001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001010001" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10000111";
              state <= "10110111";
            ELSE
              state <= "10001010";
            END IF;
            uut_rst <= '0';
          WHEN "10001010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001011101" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000000111" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10001000";
              state <= "10110111";
            ELSE
              state <= "10001011";
            END IF;
            uut_rst <= '0';
          WHEN "10001011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001101001" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10001001";
              state <= "10110111";
            ELSE
              state <= "10001100";
            END IF;
            uut_rst <= '0';
          WHEN "10001100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001010010" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10001010";
              state <= "10110111";
            ELSE
              state <= "10001101";
            END IF;
            uut_rst <= '0';
          WHEN "10001101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001011110" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000000111" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10001011";
              state <= "10110111";
            ELSE
              state <= "10001110";
            END IF;
            uut_rst <= '0';
          WHEN "10001110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001101010" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10001100";
              state <= "10110111";
            ELSE
              state <= "10001111";
            END IF;
            uut_rst <= '0';
          WHEN "10001111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001010011" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000000110" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10001101";
              state <= "10110111";
            ELSE
              state <= "10010000";
            END IF;
            uut_rst <= '0';
          WHEN "10010000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001011111" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000000111" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10001110";
              state <= "10110111";
            ELSE
              state <= "10010001";
            END IF;
            uut_rst <= '0';
          WHEN "10010001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001101011" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10001111";
              state <= "10110111";
            ELSE
              state <= "10010010";
            END IF;
            uut_rst <= '0';
          WHEN "10010010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100000" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '1' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10010000";
              state <= "10110111";
            ELSE
              state <= "10010011";
            END IF;
            uut_rst <= '0';
          WHEN "10010011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001101100" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000001001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10010001";
              state <= "10110111";
            ELSE
              state <= "10010100";
            END IF;
            uut_rst <= '0';
          WHEN "10010100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001111000" OR uut_x_coord /= "0000000000" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10010010";
              state <= "10110111";
            ELSE
              state <= "10010101";
            END IF;
            uut_rst <= '0';
          WHEN "10010101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100001" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10010011";
              state <= "10110111";
            ELSE
              state <= "10010110";
            END IF;
            uut_rst <= '0';
          WHEN "10010110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001101101" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000001001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10010100";
              state <= "10110111";
            ELSE
              state <= "10010111";
            END IF;
            uut_rst <= '0';
          WHEN "10010111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001111001" OR uut_x_coord /= "0000000001" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10010101";
              state <= "10110111";
            ELSE
              state <= "10011000";
            END IF;
            uut_rst <= '0';
          WHEN "10011000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100010" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10010110";
              state <= "10110111";
            ELSE
              state <= "10011001";
            END IF;
            uut_rst <= '0';
          WHEN "10011001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001101110" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000001001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10010111";
              state <= "10110111";
            ELSE
              state <= "10011010";
            END IF;
            uut_rst <= '0';
          WHEN "10011010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001111010" OR uut_x_coord /= "0000000010" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10011000";
              state <= "10110111";
            ELSE
              state <= "10011011";
            END IF;
            uut_rst <= '0';
          WHEN "10011011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100011" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10011001";
              state <= "10110111";
            ELSE
              state <= "10011100";
            END IF;
            uut_rst <= '0';
          WHEN "10011100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001101111" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000001001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10011010";
              state <= "10110111";
            ELSE
              state <= "10011101";
            END IF;
            uut_rst <= '0';
          WHEN "10011101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001111011" OR uut_x_coord /= "0000000011" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10011011";
              state <= "10110111";
            ELSE
              state <= "10011110";
            END IF;
            uut_rst <= '0';
          WHEN "10011110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100100" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10011100";
              state <= "10110111";
            ELSE
              state <= "10011111";
            END IF;
            uut_rst <= '0';
          WHEN "10011111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001110000" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000001001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10011101";
              state <= "10110111";
            ELSE
              state <= "10100000";
            END IF;
            uut_rst <= '0';
          WHEN "10100000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001111100" OR uut_x_coord /= "0000000100" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10011110";
              state <= "10110111";
            ELSE
              state <= "10100001";
            END IF;
            uut_rst <= '0';
          WHEN "10100001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100101" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10011111";
              state <= "10110111";
            ELSE
              state <= "10100010";
            END IF;
            uut_rst <= '0';
          WHEN "10100010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001110001" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000001001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10100000";
              state <= "10110111";
            ELSE
              state <= "10100011";
            END IF;
            uut_rst <= '0';
          WHEN "10100011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001111101" OR uut_x_coord /= "0000000101" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10100001";
              state <= "10110111";
            ELSE
              state <= "10100100";
            END IF;
            uut_rst <= '0';
          WHEN "10100100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100110" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10100010";
              state <= "10110111";
            ELSE
              state <= "10100101";
            END IF;
            uut_rst <= '0';
          WHEN "10100101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001110010" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000001001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10100011";
              state <= "10110111";
            ELSE
              state <= "10100110";
            END IF;
            uut_rst <= '0';
          WHEN "10100110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001111110" OR uut_x_coord /= "0000000110" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10100100";
              state <= "10110111";
            ELSE
              state <= "10100111";
            END IF;
            uut_rst <= '0';
          WHEN "10100111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001100111" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10100101";
              state <= "10110111";
            ELSE
              state <= "10101000";
            END IF;
            uut_rst <= '0';
          WHEN "10101000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001110011" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000001001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10100110";
              state <= "10110111";
            ELSE
              state <= "10101001";
            END IF;
            uut_rst <= '0';
          WHEN "10101001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001111111" OR uut_x_coord /= "0000000111" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10100111";
              state <= "10110111";
            ELSE
              state <= "10101010";
            END IF;
            uut_rst <= '0';
          WHEN "10101010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001101000" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10101000";
              state <= "10110111";
            ELSE
              state <= "10101011";
            END IF;
            uut_rst <= '0';
          WHEN "10101011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001110100" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000001001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10101001";
              state <= "10110111";
            ELSE
              state <= "10101100";
            END IF;
            uut_rst <= '0';
          WHEN "10101100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000010000000" OR uut_x_coord /= "0000001000" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10101010";
              state <= "10110111";
            ELSE
              state <= "10101101";
            END IF;
            uut_rst <= '0';
          WHEN "10101101" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001101001" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10101011";
              state <= "10110111";
            ELSE
              state <= "10101110";
            END IF;
            uut_rst <= '0';
          WHEN "10101110" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001110101" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000001001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10101100";
              state <= "10110111";
            ELSE
              state <= "10101111";
            END IF;
            uut_rst <= '0';
          WHEN "10101111" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000010000001" OR uut_x_coord /= "0000001001" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10101101";
              state <= "10110111";
            ELSE
              state <= "10110000";
            END IF;
            uut_rst <= '0';
          WHEN "10110000" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001101010" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10101110";
              state <= "10110111";
            ELSE
              state <= "10110001";
            END IF;
            uut_rst <= '0';
          WHEN "10110001" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001110110" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000001001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10101111";
              state <= "10110111";
            ELSE
              state <= "10110010";
            END IF;
            uut_rst <= '0';
          WHEN "10110010" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000010000010" OR uut_x_coord /= "0000001010" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10110000";
              state <= "10110111";
            ELSE
              state <= "10110011";
            END IF;
            uut_rst <= '0';
          WHEN "10110011" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001101011" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000001000" OR uut_conv_y_pos /= "00" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10110001";
              state <= "10110111";
            ELSE
              state <= "10110100";
            END IF;
            uut_rst <= '0';
          WHEN "10110100" =>
            uut_clken <= '1';
            uut_height <= "0000001100";
            uut_width <= "0000001100";
            uut_width_offset <= "00000000000000010111";
            uut_last_valid_y_pos <= "0000001000";
            uut_new_row_offset <= "00000000000000001011";
            uut_initial_mem_addr <= "00000000000000000000";
            IF uut_mem_addr /= "00000000000001110111" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000001001" OR uut_conv_y_pos /= "01" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10110010";
              state <= "10110111";
            ELSE
              state <= "10110101";
            END IF;
            uut_rst <= '0';
          WHEN "10110101" =>
            IF uut_mem_addr /= "00000000000010000011" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '1' OR uut_new_row /= '0' OR uut_done /= '0' THEN
              FAIL <= '1';
              FAIL_NUM <= "10110011";
              state <= "10110111";
            ELSE
              state <= "10110110";
            END IF;
            uut_rst <= '0';
          WHEN "10110110" =>
            IF uut_mem_addr /= "00000000000010000011" OR uut_x_coord /= "0000001011" OR uut_y_coord /= "0000001010" OR uut_conv_y_pos /= "10" OR uut_data_valid /= '0' OR uut_new_row /= '0' OR uut_done /= '1' THEN
              FAIL <= '1';
              FAIL_NUM <= "10110100";
              state <= "10110111";
            ELSE
              state <= "10110111";
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
