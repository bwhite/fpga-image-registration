LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pixel_buffer_3x3 IS
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
END pixel_buffer_3x3;

ARCHITECTURE Behavioral OF pixel_buffer_3x3 IS
  TYPE   vec3x1 IS ARRAY (2 DOWNTO 0) OF std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
  SIGNAL col0, col1, col2      : vec3x1               := ((PIXEL_BITS-1 DOWNTO 0 => '0'), (PIXEL_BITS-1 DOWNTO 0 => '0'), (PIXEL_BITS-1 DOWNTO 0 => '0'));
  SIGNAL row_cnt, col_init_cnt : unsigned(1 DOWNTO 0) := (OTHERS                 => '0');
  SIGNAL output_valid_reg      : std_logic            := '0';
BEGIN
  OUTPUT_VALID <= output_valid_reg;
  IMG_0_0      <= col0(0);
  IMG_0_1      <= col1(0);
  IMG_0_2      <= col2(0);
  IMG_1_0      <= col0(1);
  IMG_1_1      <= col1(1);
  IMG_1_2      <= col2(1);
  IMG_2_0      <= col0(2);
  IMG_2_1      <= col1(2);
  IMG_2_2      <= col2(2);

  -- Fills up a 3x3 buffer of pixels representing a sliding window in the +x
  -- direction.
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        output_valid_reg <= '0';
        col_init_cnt     <= (OTHERS                 => '0');
        row_cnt          <= (OTHERS                 => '0');
        col0             <= ((PIXEL_BITS-1 DOWNTO 0 => '0'), (PIXEL_BITS-1 DOWNTO 0 => '0'), (PIXEL_BITS-1 DOWNTO 0 => '0'));
        col1             <= ((PIXEL_BITS-1 DOWNTO 0 => '0'), (PIXEL_BITS-1 DOWNTO 0 => '0'), (PIXEL_BITS-1 DOWNTO 0 => '0'));
        col2             <= ((PIXEL_BITS-1 DOWNTO 0 => '0'), (PIXEL_BITS-1 DOWNTO 0 => '0'), (PIXEL_BITS-1 DOWNTO 0 => '0'));
      ELSE
        IF CLKEN = '1' THEN
          IF NEW_ROW = '1' THEN
            col0             <= col1;
            col1             <= col2;
            col2(0)          <= MEM_VALUE;
            row_cnt          <= "01";
            output_valid_reg <= '0';
            col_init_cnt     <= "00";
          ELSE
            CASE row_cnt IS
              WHEN "00" =>
                col0             <= col1;
                col1             <= col2;
                col2(0)          <= MEM_VALUE;
                row_cnt          <= "01";
                output_valid_reg <= '0';
              WHEN "01" =>
                col2(1)          <= MEM_VALUE;
                row_cnt          <= "10";
                output_valid_reg <= '0';
              WHEN "10" =>
                col2(2) <= MEM_VALUE;
                row_cnt <= "00";
                IF col_init_cnt < 2 THEN
                  col_init_cnt     <= col_init_cnt + 1;
                  output_valid_reg <= '0';
                ELSE
                  output_valid_reg <= '1';
                END IF;
              WHEN OTHERS =>
                output_valid_reg <= '0';
            END CASE;
            
          END IF;
        ELSE
          output_valid_reg <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;
