----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:23:27 09/19/2007 
-- Design Name: 
-- Module Name:    vga_timing_generator - Behavioral 
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
-- TODO This needs to be changed to reference vcount/hcount like the decoder
-- module does.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY vga_timing_generator IS
  GENERIC (WIDTH       : integer := 1024;
           H_FP        : integer := 24;
           H_SYNC      : integer := 136;
           H_BP        : integer := 160;
           HEIGHT      : integer := 768;
           V_FP        : integer := 3;
           V_SYNC      : integer := 6;
           V_BP        : integer := 29;
           HEIGHT_BITS : integer := 10;
           WIDTH_BITS  : integer := 10;
           DATA_DELAY  : integer := 0
           );
  PORT (CLK            : IN  std_logic;
        RST            : IN  std_logic;
        HSYNC          : OUT std_logic;
        VSYNC          : OUT std_logic;
        X_COORD        : OUT std_logic_vector(WIDTH_BITS-1 DOWNTO 0);
        Y_COORD        : OUT std_logic_vector(HEIGHT_BITS-1 DOWNTO 0);
        PIXEL_COUNT    : OUT std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
        DATA_VALID     : OUT std_logic;
        DATA_VALID_EXT : OUT std_logic);
END vga_timing_generator;

ARCHITECTURE Behavioral OF vga_timing_generator IS
  CONSTANT H_TOTAL              : integer                                     := WIDTH+H_FP+H_SYNC+H_BP;
  CONSTANT V_TOTAL              : integer                                     := HEIGHT+V_FP+V_SYNC+V_BP;
  SIGNAL   hcount               : unsigned(WIDTH_BITS-1 DOWNTO 0)             := (OTHERS => '0');
  SIGNAL   vcount               : unsigned(HEIGHT_BITS-1 DOWNTO 0)            := (OTHERS => '0');
  SIGNAL   vsync_reg, hsync_reg : std_logic                                   := '0';  -- NOTE These are active high signals
  SIGNAL   pixel_count_reg      : unsigned(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0) := (OTHERS => '0');  -- This is used to keep track of the number of valid pixels that have been output this frame.  Used to allow pixel selection to be made based on 1D memory addresses.
  SIGNAL   x_coord_reg          : unsigned(WIDTH_BITS-1 DOWNTO 0)             := (OTHERS => '0');
  SIGNAL   y_coord_reg          : unsigned(HEIGHT_BITS-1 DOWNTO 0)            := (OTHERS => '0');
  SIGNAL   data_valid_reg       : std_logic                                   := '0';
BEGIN
  HSYNC       <= hsync_reg;
  VSYNC       <= vsync_reg;
  X_COORD     <= std_logic_vector(x_coord_reg);
  Y_COORD     <= std_logic_vector(y_coord_reg);
  PIXEL_COUNT <= std_logic_vector(pixel_count_reg);
  DATA_VALID  <= data_valid_reg;
  PROCESS(CLK)
  BEGIN
    -- Horizontal Pixel Count
    IF (CLK'event AND CLK = '1') THEN
      IF (RST = '1') THEN
        vcount          <= (OTHERS => '0');
        hcount          <= (OTHERS => '0');
        hsync_reg       <= '0';
        vsync_reg       <= '0';
        pixel_count_reg <= (OTHERS => '0');
        x_coord_reg     <= (OTHERS => '0');
        y_coord_reg     <= (OTHERS => '0');
      ELSE
        -- Data valid signal
        IF (H_BP-DATA_DELAY-1 <= hcount AND hcount < WIDTH+H_BP-DATA_DELAY-1 AND V_BP <= vcount AND vcount < HEIGHT+V_BP) THEN
          data_valid_reg <= '1';
          IF data_valid_reg = '1' THEN
            x_coord_reg <= x_coord_reg + 1;
          END IF;
          IF (data_valid_reg = '1' AND vcount = V_BP) OR vcount > V_BP THEN
            pixel_count_reg <= pixel_count_reg + 1;
          END IF;
        ELSE
          x_coord_reg    <= (OTHERS => '0');
          data_valid_reg <= '0';
        END IF;

        -- Data valid external signal (to be in line with HSYNC/VSYNC)
        IF (H_BP-1 <= hcount AND hcount < WIDTH+H_BP-1 AND V_BP <= vcount AND vcount < HEIGHT+V_BP) THEN
          DATA_VALID_EXT <= '1';
        ELSE
          DATA_VALID_EXT <= '0';
        END IF;

        -- Horizontal Line Counter
        IF hcount = (H_TOTAL-1) THEN    -- Reset hcount
          hcount <= (OTHERS => '0');
        ELSE
          hcount <= hcount + 1;
        END IF;

        -- Vertical Line Counter
        IF hcount = (H_TOTAL - 1) AND (vcount = (V_TOTAL - 1)) THEN  -- Reset
                                                                     -- vcount
          vcount          <= (OTHERS => '0');
          pixel_count_reg <= (OTHERS => '0');
          y_coord_reg     <= (OTHERS => '0');
        ELSIF hcount = (H_TOTAL - 1) THEN
          vcount  <= vcount + 1;
          IF V_BP <= vcount AND vcount < HEIGHT+V_BP-1 THEN
            y_coord_reg <= y_coord_reg + 1;
          END IF;
        END IF;

        -- Horizontal Sync Pulse
        IF hcount = (WIDTH+H_FP+H_BP-1) THEN
          hsync_reg <= '1';
        ELSIF hcount = (H_TOTAL-1) THEN
          hsync_reg <= '0';
        END IF;

        -- Vertical Sync Pulse
        IF hcount = (H_TOTAL-1) AND vcount = (HEIGHT+V_FP+V_BP-1) THEN
          vsync_reg <= '1';
        ELSIF hcount = (H_TOTAL-1) AND vcount = (V_TOTAL-1) THEN
          vsync_reg <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

