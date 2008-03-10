----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:57:54 02/25/2008 
-- Design Name: 
-- Module Name:    dvi_video_test - Behavioral 
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

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY dvi_video_test IS
  PORT (CLK_P   : IN  std_logic;
        CLK_N   : IN  std_logic;
        -- I2C Signals
        I2C_SDA : OUT std_logic;
        I2C_SCL : OUT std_logic;

        -- DVI Signals
        DVI_D       : OUT std_logic_vector (11 DOWNTO 0);
        DVI_H       : OUT std_logic;
        DVI_V       : OUT std_logic;
        DVI_DE      : OUT std_logic;
        DVI_XCLK_N  : OUT std_logic;
        DVI_XCLK_P  : OUT std_logic;
        DVI_RESET_B : OUT std_logic;

        -- VGA Chip connections
        VGA_PIXEL_CLK  : IN std_logic;
        VGA_Y_GREEN    : IN std_logic_vector (7 DOWNTO 0);
        VGA_CBCR_RED   : IN std_logic_vector (7 DOWNTO 0);
        VGA_BLUE       : IN std_logic_vector(7 DOWNTO 0);
        VGA_HSYNC      : IN std_logic;
        VGA_VSYNC      : IN std_logic;
        VGA_ODD_EVEN_B : IN std_logic;
        VGA_SOGOUT     : IN std_logic;
        VGA_CLAMP      : IN std_logic;
        VGA_COAST      : IN std_logic;

        -- Dummy Chipscope outputs
        SOGOUT            : OUT std_logic;
        PIXEL_X_COORD     : OUT std_logic_vector(9 DOWNTO 0);
        PIXEL_Y_COORD     : OUT std_logic_vector(9 DOWNTO 0);
        TOTAL_PIXEL_COUNT : OUT std_logic_vector(19 DOWNTO 0);
        VGA_DATA_VALID    : OUT std_logic;
        Y                 : OUT std_logic_vector (7 DOWNTO 0);
        HSYNC             : OUT std_logic;
        VSYNC             : OUT std_logic;
        DVI_PIXEL_COUNT   : OUT std_logic_vector(19 DOWNTO 0);
        DVI_X_COORD       : OUT std_logic_vector(9 DOWNTO 0);
        DVI_Y_COORD       : OUT std_logic_vector(9 DOWNTO 0);
        DVI_DATA_VALID    : OUT std_logic
        );
END dvi_video_test;

ARCHITECTURE Behavioral OF dvi_video_test IS
  COMPONENT vga_timing_generator IS
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
          X_COORD        : OUT unsigned(WIDTH_BITS-1 DOWNTO 0);
          Y_COORD        : OUT unsigned(HEIGHT_BITS-1 DOWNTO 0);
          PIXEL_COUNT    : OUT unsigned(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
          DATA_VALID     : OUT std_logic;
          DATA_VALID_EXT : OUT std_logic);
  END COMPONENT;

  COMPONENT vga_timing_decode IS
    GENERIC (
      HEIGHT      : integer := 480;
      WIDTH       : integer := 640;
      H_BP        : integer := 117;
      V_BP        : integer := 34;
      HEIGHT_BITS : integer := 10;
      WIDTH_BITS  : integer := 10;
      DATA_DELAY  : integer := 0
      );
    PORT (CLK         : IN  std_logic;
          RST         : IN  std_logic;
          VSYNC       : IN  std_logic;
          HSYNC       : IN  std_logic;
          X_COORD     : OUT unsigned(WIDTH_BITS-1 DOWNTO 0);
          Y_COORD     : OUT unsigned(HEIGHT_BITS-1 DOWNTO 0);
          PIXEL_COUNT : OUT unsigned(HEIGHT_BITS+WIDTH_BITS-1 DOWNTO 0);
          DATA_VALID  : OUT std_logic);
  END COMPONENT;

  COMPONENT i2c_video_programmer IS
    PORT (CLK200Mhz : IN  std_logic;
          RST       : IN  std_logic;
          I2C_SDA   : OUT std_logic;
          I2C_SCL   : OUT std_logic);
  END COMPONENT;

  SIGNAL pix_clk                                     : std_logic;  -- This is the pixel clock for the DVI output and sync generator
  SIGNAL clk_fb, data_valid, data_valid_ext, clk_buf : std_logic;
  SIGNAL dvi_red, dvi_green, dvi_blue,dvi_gray                : std_logic_vector(7 DOWNTO 0);  -- These hold the values for the packed RGB DVI output data
  SIGNAL dvi_h_wire, dvi_v_wire                      : std_logic;
  SIGNAL dvi_x_coord_wire, dvi_y_coord_wire          : unsigned(9 DOWNTO 0);
  SIGNAL dvi_pixel_count_wire                        : unsigned(19 DOWNTO 0);
  SIGNAL vga_x_coord_wire, vga_y_coord_wire          : unsigned(9 DOWNTO 0);
  SIGNAL vga_pixel_count_wire                        : unsigned(19 DOWNTO 0);
BEGIN

  -----------------------------------------------------------------------------
  -- CLK Management
  IBUFGDS_inst : IBUFGDS
    GENERIC MAP (
      IOSTANDARD => "DEFAULT")
    PORT MAP (
      O  => clk_buf,                    -- Clock buffer output
      I  => CLK_P,                      -- Diff_p clock buffer input
      IB => CLK_N                       -- Diff_n clock buffer input
      );

  DCM_BASE_dvi : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 8.0,  -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE          => 16,      -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 2,       -- Can be any integer from 2 to 32
      CLKIN_DIVIDE_BY_2     => false,  -- TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD          => 5.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLKOUT_PHASE_SHIFT    => "NONE",  -- Specify phase shift mode of NONE or FIXED
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,   -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "HIGH",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "HIGH",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      PHASE_SHIFT           => 0,  -- Amount of fixed phase shift from -255 to 1023
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => clk_fb,                  -- 0 degree DCM CLK ouptput
      CLKDV => pix_clk,
      CLKFB => clk_fb,                  -- DCM clock feedback
      CLKIN => clk_buf,            -- Clock input (from IBUFG, BUFG or DCM)
      RST   => '0'                      -- DCM asynchronous reset input
      );

  -----------------------------------------------------------------------------
  -- I2C Code
  i2c_video_programmer_i : i2c_video_programmer
    PORT MAP (
      CLK200Mhz => clk_buf,
      RST       => '0',
      I2C_SDA   => I2C_SDA,
      I2C_SCL   => I2C_SCL);


  -------------------------------------------------------------------------------
  -- DVI Code
  DVI_DE <= data_valid_ext;

  -- This is a way to generate a differential clock with low jitter (as both
  -- edges are handled in the same way)
  ODDR_xclk_p : ODDR
    GENERIC MAP(
      DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE" 
      INIT         => '0',  -- Initial value for Q port ('1' or '0')
      SRTYPE       => "SYNC")           -- Reset Type ("ASYNC" or "SYNC")
    PORT MAP (
      Q  => DVI_XCLK_P,                 -- 1-bit DDR output
      C  => pix_clk,                    -- 1-bit clock input
      CE => '1',                        -- 1-bit clock enable input
      D1 => '1',                        -- 1-bit data input (positive edge)
      D2 => '0',                        -- 1-bit data input (negative edge)
      R  => '0',                        -- 1-bit reset input
      S  => '0'                         -- 1-bit set input
      );
  ODDR_xclk_n : ODDR
    GENERIC MAP(
      DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE" 
      INIT         => '0',  -- Initial value for Q port ('1' or '0')
      SRTYPE       => "SYNC")           -- Reset Type ("ASYNC" or "SYNC")
    PORT MAP (
      Q  => DVI_XCLK_N,                 -- 1-bit DDR output
      C  => pix_clk,                    -- 1-bit clock input
      CE => '1',                        -- 1-bit clock enable input
      D1 => '0',                        -- 1-bit data input (positive edge)
      D2 => '1',                        -- 1-bit data input (negative edge)
      R  => '0',                        -- 1-bit reset input
      S  => '0'                         -- 1-bit set input
      );

  DVI_RESET_B <= '1';
  PROCESS (dvi_x_coord_wire) IS
  BEGIN  -- PROCESS
    IF dvi_y_coord_wire(0)='1' THEN
      CASE to_integer(dvi_x_coord_wire) IS
        WHEN 1 =>
          dvi_gray <= "11111111";
        WHEN 2 =>
          dvi_gray <= "00000000";
        WHEN 5 =>
          dvi_gray <= "11111111";
        WHEN 6 =>
          dvi_gray <= "11111111";
        WHEN 7 =>
          dvi_gray <= "00000000";
        WHEN 8 =>
          dvi_gray <= "00000000";
        WHEN 12 =>
          dvi_gray <= "11111111";
        WHEN 13 =>
          dvi_gray <= "11111111";
        WHEN 14 =>
          dvi_gray <= "11111111";
        WHEN 15 =>
          dvi_gray <= "00000000";
        WHEN 16 =>
          dvi_gray <= "00000000";
        WHEN 17 =>
          dvi_gray <= "00000000";
          
        WHEN 639-1 =>
          dvi_gray <= "11111111";
        WHEN 639-2 =>
          dvi_gray <= "00000000";
        WHEN 639-5 =>
          dvi_gray <= "11111111";
        WHEN 639-6 =>
          dvi_gray <= "11111111";
        WHEN 639-7 =>
          dvi_gray <= "00000000";
        WHEN 639-8 =>
          dvi_gray <= "00000000";
        WHEN 639-12 =>
          dvi_gray <= "11111111";
        WHEN 639-13 =>
          dvi_gray <= "11111111";
        WHEN 639-14 =>
          dvi_gray <= "11111111";
        WHEN 639-15 =>
          dvi_gray <= "00000000";
        WHEN 639-16 =>
          dvi_gray <= "00000000";
        WHEN 639-17 =>
          dvi_gray <= "00000000";
        WHEN OTHERS =>
          dvi_gray <= "01111111";
      END CASE;
    ELSE
      CASE to_integer(dvi_x_coord_wire) IS
        WHEN 1 =>
          dvi_gray <= "00000000";
        WHEN 2 =>
          dvi_gray <= "11111111";
        WHEN 5 =>
          dvi_gray <= "00000000";
        WHEN 6 =>
          dvi_gray <= "00000000";
        WHEN 7 =>
          dvi_gray <= "11111111";
        WHEN 8 =>
          dvi_gray <= "11111111";
        WHEN 12 =>
          dvi_gray <= "00000000";
        WHEN 13 =>
          dvi_gray <= "00000000";
        WHEN 14 =>
          dvi_gray <= "00000000";
        WHEN 15 =>
          dvi_gray <= "11111111";
        WHEN 16 =>
          dvi_gray <= "11111111";
        WHEN 17 =>
          dvi_gray <= "11111111";

        WHEN 639-1 =>
          dvi_gray <= "00000000";
        WHEN 639-2 =>
          dvi_gray <= "11111111";
        WHEN 639-5 =>
          dvi_gray <= "00000000";
        WHEN 639-6 =>
          dvi_gray <= "00000000";
        WHEN 639-7 =>
          dvi_gray <= "11111111";
        WHEN 639-8 =>
          dvi_gray <= "11111111";
        WHEN 639-12 =>
          dvi_gray <= "00000000";
        WHEN 639-13 =>
          dvi_gray <= "00000000";
        WHEN 639-14 =>
          dvi_gray <= "00000000";
        WHEN 639-15 =>
          dvi_gray <= "11111111";
        WHEN 639-16 =>
          dvi_gray <= "11111111";
        WHEN 639-17 =>
          dvi_gray <= "11111111";
        WHEN OTHERS =>
          dvi_gray <= "01111111";
      END CASE;
    END IF;
    
    dvi_red <= dvi_gray;
    dvi_blue <= dvi_gray;
    dvi_green <= dvi_gray;
--    IF h_pixel_count < "00000000100" THEN
--      dvi_red   <= "00000000";
--      dvi_green <= "00000000";
--      dvi_blue  <= "11111111";
--    ELSIF h_pixel_count < "00000001000" THEN
--      dvi_red   <= "00000000";
--      dvi_green <= "11111111";
--      dvi_blue  <= "00000000";
--    ELSIF h_pixel_count > "01001111000" THEN
--      dvi_red   <= "11111111";
--      dvi_green <= "00000000";
--      dvi_blue  <= "00000000";
--    ELSE
--      dvi_red   <= "00000000";
--      dvi_green <= "00000000";
--      dvi_blue  <= "11111111";
--    END IF;
  END PROCESS;
  -- This outputs the color values in the DVI chips DDR mode, if the
  -- dvi_reg/green/blue wires are used on the posedge of the pix_clk, then
  -- knowledge of this DDR format isn't necessary
  ODDR_dvi_d0 : ODDR
    PORT MAP (DVI_D(0), pix_clk, '1', dvi_green(4), dvi_blue(0), NOT data_valid_ext, '0');
  ODDR_dvi_d1 : ODDR
    PORT MAP (DVI_D(1), pix_clk, '1', dvi_green(5), dvi_blue(1), NOT data_valid_ext, '0');
  ODDR_dvi_d2 : ODDR
    PORT MAP (DVI_D(2), pix_clk, '1', dvi_green(6), dvi_blue(2), NOT data_valid_ext, '0');
  ODDR_dvi_d3 : ODDR
    PORT MAP (DVI_D(3), pix_clk, '1', dvi_green(7), dvi_blue(3), NOT data_valid_ext, '0');
  ODDR_dvi_d4 : ODDR
    PORT MAP (DVI_D(4), pix_clk, '1', dvi_red(0), dvi_blue(4), NOT data_valid_ext, '0');
  ODDR_dvi_d5 : ODDR
    PORT MAP (DVI_D(5), pix_clk, '1', dvi_red(1), dvi_blue(5), NOT data_valid_ext, '0');
  ODDR_dvi_d6 : ODDR
    PORT MAP (DVI_D(6), pix_clk, '1', dvi_red(2), dvi_blue(6), NOT data_valid_ext, '0');
  ODDR_dvi_d7 : ODDR
    PORT MAP (DVI_D(7), pix_clk, '1', dvi_red(3), dvi_blue(7), NOT data_valid_ext, '0');
  ODDR_dvi_d8 : ODDR
    PORT MAP (DVI_D(8), pix_clk, '1', dvi_red(4), dvi_green(0), NOT data_valid_ext, '0');
  ODDR_dvi_d9 : ODDR
    PORT MAP (DVI_D(9), pix_clk, '1', dvi_red(5), dvi_green(1), NOT data_valid_ext, '0');
  ODDR_dvi_d10 : ODDR
    PORT MAP (DVI_D(10), pix_clk, '1', dvi_red(6), dvi_green(2), NOT data_valid_ext, '0');
  ODDR_dvi_d11 : ODDR
    PORT MAP (DVI_D(11), pix_clk, '1', dvi_red(7), dvi_green(3), NOT data_valid_ext, '0');

  vga_timing_generator_i : vga_timing_generator
    GENERIC MAP(WIDTH  => 640,
                H_FP   => 16,
                H_SYNC => 96,
                H_BP   => 48,

                HEIGHT     => 480,
                V_FP       => 12,
                V_SYNC     => 2,
                V_BP       => 31,
                DATA_DELAY => 0)

    PORT MAP (
      RST            => '0',
      HSYNC          => dvi_h_wire,
      VSYNC          => dvi_v_wire,
      DATA_VALID     => data_valid,
      DATA_VALID_EXT => data_valid_ext,
      X_COORD        => dvi_x_coord_wire,
      Y_COORD        => dvi_y_coord_wire,
      PIXEL_COUNT    => dvi_pixel_count_wire,
      CLK            => pix_clk);
  DVI_DATA_VALID  <= data_valid;
  DVI_H           <= NOT dvi_h_wire;
  DVI_V           <= NOT dvi_v_wire;
  DVI_X_COORD     <= std_logic_vector(dvi_x_coord_wire);
  DVI_Y_COORD     <= std_logic_vector(dvi_y_coord_wire);
  DVI_PIXEL_COUNT <= std_logic_vector(dvi_pixel_count_wire);

  -----------------------------------------------------------------------------
  -- VGA Input

  -- Hooks to chipscope outputs
  Y      <= VGA_Y_GREEN;
  HSYNC  <= VGA_HSYNC;
  VSYNC  <= VGA_VSYNC;
  SOGOUT <= VGA_SOGOUT;
  vga_timing_decode_i : vga_timing_decode
    PORT MAP (
      CLK         => VGA_PIXEL_CLK,
      RST         => '0',
      VSYNC       => VGA_VSYNC,
      HSYNC       => VGA_HSYNC,
      DATA_VALID  => VGA_DATA_VALID,
      X_COORD     => vga_x_coord_wire,
      Y_COORD     => vga_y_coord_wire,
      PIXEL_COUNT => vga_pixel_count_wire);
  PIXEL_X_COORD <= std_logic_vector(vga_x_coord_wire);
  PIXEL_Y_COORD <= std_logic_vector(vga_y_coord_wire);
  TOTAL_PIXEL_COUNT <= std_logic_vector(vga_pixel_count_wire);
END Behavioral;
