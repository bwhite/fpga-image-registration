----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:38:04 02/20/2008 
-- Design Name: 
-- Module Name:    vga_timing_decode - Behavioral 
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
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY vga_timing_decode IS
  GENERIC (
    HEIGHT       : unsigned(10 DOWNTO 0) := "00111100000";
    WIDTH        : unsigned(10 DOWNTO 0) := "01010000000";
    H_BACK_PORCH : unsigned(10 DOWNTO 0) := "00001110101";
    V_BACK_PORCH : unsigned(10 DOWNTO 0) := "00000100010");
  PORT (PIXEL_CLK         : IN  std_logic;
        VSYNC             : IN  std_logic;
        HSYNC             : IN  std_logic;
        HCOUNT            : OUT std_logic_vector(9 DOWNTO 0);
        VCOUNT            : OUT std_logic_vector(9 DOWNTO 0);
        --H_PIXEL_COUNT : out  STD_LOGIC_VECTOR(10 DOWNTO 0);
        PIXEL_Y_COORD     : OUT std_logic_vector(10 DOWNTO 0);
        TOTAL_PIXEL_COUNT : OUT std_logic_vector(21 DOWNTO 0);
        DATA_VALID        : OUT std_logic;
        PIXEL_X_COORD     : OUT std_logic_vector (10 DOWNTO 0));
END vga_timing_decode;

ARCHITECTURE Behavioral OF vga_timing_decode IS
  SIGNAL hcount_reg, vcount_reg               : unsigned(9 DOWNTO 0)  := (OTHERS => '0');  -- Number of pixels after the negative edge of the H/VSYNC
  SIGNAL total_pixel_count_reg                : unsigned(21 DOWNTO 0) := (OTHERS => '0');
  SIGNAL prev_hsync                           : std_logic             := '0';
  SIGNAL pixel_x_coord_reg, pixel_y_coord_reg : unsigned(10 DOWNTO 0) := (OTHERS => '0');
  SIGNAL data_valid_reg                       : std_logic             := '0';
BEGIN
  HCOUNT            <= std_logic_vector(hcount_reg);
  VCOUNT            <= std_logic_vector(vcount_reg);
  PIXEL_X_COORD     <= std_logic_vector(pixel_x_coord_reg);
  PIXEL_Y_COORD     <= std_logic_vector(pixel_y_coord_reg);
  TOTAL_PIXEL_COUNT <= std_logic_vector(total_pixel_count_reg);
  DATA_VALID        <= data_valid_reg;

  PROCESS (PIXEL_CLK) IS
  BEGIN  -- PROCESS 
    IF PIXEL_CLK'event AND PIXEL_CLK = '1' THEN
      prev_hsync <= HSYNC;
      -- The backporch -1 is due to the register delay
      IF HSYNC = '0' AND VSYNC = '0' AND hcount_reg >= H_BACK_PORCH-1 AND hcount_reg < H_BACK_PORCH+WIDTH-1 AND vcount_reg >= V_BACK_PORCH AND vcount_reg < V_BACK_PORCH+HEIGHT THEN
        data_valid_reg <= '1';
        IF data_valid_reg = '1' THEN    -- This makes the first valid pixel 0,
                                        -- instead of 1
          pixel_x_coord_reg <= pixel_x_coord_reg + 1;
        END IF;

        -- This makes the first valid pixel 0, and properly increments the
        -- first pixels of every other line
        IF (data_valid_reg = '1' AND vcount_reg = V_BACK_PORCH) OR vcount_reg > V_BACK_PORCH THEN
          total_pixel_count_reg <= total_pixel_count_reg + 1;
        END IF;
      ELSE
        data_valid_reg    <= '0';
        pixel_x_coord_reg <= (OTHERS => '0');
      END IF;

      IF VSYNC = '0' THEN
        IF HSYNC = '1' AND prev_hsync = '0' AND vcount_reg >= V_BACK_PORCH AND vcount_reg < V_BACK_PORCH+HEIGHT THEN
          pixel_y_coord_reg <= pixel_y_coord_reg + 1;
        END IF;
      ELSE
        total_pixel_count_reg <= (OTHERS => '0');
        pixel_y_coord_reg     <= (OTHERS => '0');
      END IF;

      IF HSYNC = '1' THEN
        hcount_reg <= (OTHERS => '0');
        IF prev_hsync = '0' THEN
          vcount_reg <= vcount_reg + 1;
        END IF;
      ELSE
        hcount_reg <= hcount_reg + 1;
      END IF;

      IF VSYNC = '1' THEN
        vcount_reg <= (OTHERS => '0');
      END IF;
    END IF;
  END PROCESS;

END Behavioral;

