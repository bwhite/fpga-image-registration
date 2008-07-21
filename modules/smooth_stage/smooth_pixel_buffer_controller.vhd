LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY smooth_pixel_buffer_controller IS
  GENERIC (
    PIXEL_BITS : IN integer := 9);
  PORT (CLK           : IN  std_logic;
        RST           : IN  std_logic;
        NEW_ROW       : IN  std_logic;
        PATTERN_STATE : IN  std_logic_vector(2 DOWNTO 0);
        MEM_VALUE     : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        INPUT_VALID   : IN  std_logic;
        OUTPUT_VALID  : OUT std_logic;
        IMG_0_0       : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_0_1       : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_0_2       : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_1_0       : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_1_1       : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_1_2       : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_2_0       : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_2_1       : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_2_2       : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0));
END smooth_pixel_buffer_controller;

ARCHITECTURE Behavioral OF smooth_pixel_buffer_controller IS
  COMPONENT pixel_buffer_3x3 IS
    GENERIC (
      PIXEL_BITS : IN integer := 9);
    PORT (CLK          : IN  std_logic;
          RST          : IN  std_logic;
          CLKEN        : IN  std_logic;
          NEW_ROW      : IN  std_logic;
          MEM_VALUE    : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          OUTPUT_VALID : OUT std_logic;
          IMG_0_0      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_0_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_0_2      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_1_0      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_1_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_1_2      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_2_0      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_2_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          IMG_2_2      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0));
  END COMPONENT;
  SIGNAL pix_buffer_rst_reg, pix_buffer_rst_wire, pix_buffer_input_valid : std_logic;
BEGIN

  pixel_buffer_3x3_i : pixel_buffer_3x3
    PORT MAP (
      CLK          => CLK,
      RST          => RST,
      CLKEN        => pix_buffer_input_valid,
      NEW_ROW      => NEW_ROW,
      MEM_VALUE    => MEM_VALUE,
      OUTPUT_VALID => OUTPUT_VALID,
      IMG_0_0      => IMG_0_0,
      IMG_0_1      => IMG_0_1,
      IMG_0_2      => IMG_0_2,
      IMG_1_0      => IMG_1_0,
      IMG_1_1      => IMG_1_1,
      IMG_1_2      => IMG_1_2,
      IMG_2_0      => IMG_2_0,
      IMG_2_1      => IMG_2_1,
      IMG_2_2      => IMG_2_2);

  PROCESS (PATTERN_STATE) IS
  BEGIN  -- PROCESS
    CASE PATTERN_STATE IS
      WHEN "001" =>                     -- When top pixel
        pix_buffer_input_valid <= '1';
      WHEN "011" =>                     -- When middle pixel
        pix_buffer_input_valid <= '1';
      WHEN "101" =>                     -- When bottom pixel
        pix_buffer_input_valid <= '1';
      WHEN "100" =>                     -- When write cycle
        pix_buffer_input_valid <= '0';
      WHEN OTHERS => NULL;
    END CASE;
  END PROCESS;
END Behavioral;

