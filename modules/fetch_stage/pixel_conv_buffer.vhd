----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:26:39 04/24/2008 
-- Design Name: 
-- Module Name:    pixel_conv_buffer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pixel_conv_buffer IS
  GENERIC (
    PIXEL_BITS         : IN  integer := 9);
  PORT ( CLK           : IN  std_logic;
         RST           : IN  std_logic;
         NEW_ROW       : IN  std_logic;
         MEM_VALUE     : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         INPUT_VALID   : IN  std_logic;
         PATTERN_STATE : IN  std_logic_vector(2 DOWNTO 0);
         OUTPUT_VALID  : OUT std_logic;
         IMG0_0_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG0_1_0      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG0_1_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG0_1_2      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG0_2_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG1_1_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0));
END pixel_conv_buffer;

ARCHITECTURE Behavioral OF pixel_conv_buffer IS
  TYPE vec3x1 IS ARRAY (2 DOWNTO 0) OF std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
  SIGNAL col1, col2           : vec3x1;
  SIGNAL img1_1_1_reg, col0_1 : std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
  SIGNAL col_init_cnt         : unsigned(1 DOWNTO 0)         := (OTHERS => '0');
  SIGNAL output_valid_reg     : std_logic                    := '0';
  SIGNAL prev_pattern         : std_logic_vector(2 DOWNTO 0) := (OTHERS => '0');
BEGIN
-- COL2 gets the newest data in from MEM_VALUE, after it is full and IMG1_1_1's
-- value is received we signal that the output is valid, the next CT we
-- transfer COL0<= COL1 and COL1<= COL2, again filling up COL2 with valid
-- values. Initially, we must ensure that COL0-2 are properly initialized
-- before signaling that the data is valid.
-- NOTE: This assumes a convolution size of 3!
-- NOTE: Assumes that the pattern will be strictly followed (i.e., 3 pixels
-- forming an IMG0 column, followed by a middle pixel value). More
-- specifically,since INPUT_VALID is a CLKEN signal the pattern must be
-- followed only when INPUT_VALID='1'. (e.g., If the pattern will wait a CT,
-- then set INPUT_VALID='0')
  IMG1_1_1                           <= img1_1_1_reg;  -- IMG1 middle pixel (1,1)
  IMG0_0_1                           <= col1(0);  -- Middle column
  IMG0_1_1                           <= col1(1);
  IMG0_2_1                           <= col1(2);
  IMG0_1_0                           <= col0_1;  -- Left and right middle row
  IMG0_1_2                           <= col2(1);
  OUTPUT_VALID                       <= output_valid_reg;
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        col_init_cnt                 <= (OTHERS                         => '0');
        output_valid_reg             <= '0';
        prev_pattern                 <= (OTHERS                         => '0');
      ELSE
        IF NEW_ROW = '1' THEN
          col_init_cnt               <= (OTHERS                         => '0');
        END IF;
        prev_pattern                 <= PATTERN_STATE;
        -- NOTE: The col pixels must be valid, but the IMG1 value does not, the
        -- first two IMG1 values are ignored for each row, and thus their valid
        -- signal is not checked.
        IF INPUT_VALID = '1' OR PATTERN_STATE(0) = '0' THEN
          CASE PATTERN_STATE IS
            WHEN "001"                                                  =>
              -- First pixel of column pattern
              col2(0)                <= MEM_VALUE;
              col1                   <= col2;
              col0_1                 <= col1(1);
              output_valid_reg       <= '0';
            WHEN "011"                                                  =>
              col2(1)                <= MEM_VALUE;
              output_valid_reg       <= '0';
            WHEN "101"                                                  =>
              -- Last pixel of the column pattern
              col2(2)                <= MEM_VALUE;
              output_valid_reg       <= '0';
            WHEN OTHERS                                                 =>
              IF PATTERN_STATE = "000" OR PATTERN_STATE = "100" THEN
                -- Middle IMG1 pixel, last pixel in pattern. "100" occurs when
                -- coordgen is in done state.
                IF prev_pattern = "101" THEN
                  img1_1_1_reg       <= MEM_VALUE;
                  IF col_init_cnt < 2 THEN
                    output_valid_reg <= '0';
                    col_init_cnt     <= col_init_cnt + 1;
                  ELSE
                    output_valid_reg <= INPUT_VALID;
                  END IF;
                ELSE
                  output_valid_reg   <= '0';
                END IF;
              ELSE
                output_valid_reg     <= '0';
              END IF;
          END CASE;
        ELSE
          output_valid_reg <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;
