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
  PORT (CLK     : IN  std_logic;
        -- I2C Signals
        I2C_SDA : OUT std_logic;
        I2C_SCL : OUT std_logic;

        -- DVI Signals
        DVI_D      : OUT std_logic_vector (11 DOWNTO 0);
        DVI_H      : OUT std_logic;
        DVI_V      : OUT std_logic;
        DVI_DE     : OUT std_logic;
        DVI_XCLK_N : OUT std_logic;
        DVI_XCLK_P : OUT std_logic;

        -- VGA Chip connections
        VGA_PIXEL_CLK  : IN std_logic;
        VGA_Y          : IN std_logic_vector (7 DOWNTO 0);
        VGA_HSYNC      : IN std_logic;
        VGA_VSYNC      : IN std_logic;
        VGA_ODD_EVEN_B : IN std_logic;
        VGA_SOGOUT     : IN std_logic;
        VGA_CLAMP      : IN std_logic;
        VGA_COAST      : IN std_logic;

        -- Dummy Chipscope outputs
        -- PIX_CLK    : OUT std_logic;
        Y           : OUT std_logic_vector (7 DOWNTO 0);
        HSYNC       : OUT std_logic;
        VSYNC       : OUT std_logic;
        ODD_EVEN_B  : OUT std_logic;
        SOGOUT      : OUT std_logic;
        CLAMP       : OUT std_logic;
        COAST       : OUT std_logic;
        HCOUNT      : OUT std_logic_vector(9 DOWNTO 0);
        VCOUNT      : OUT std_logic_vector(9 DOWNTO 0);
        DVI_RESET_B : OUT std_logic);
END dvi_video_test;

ARCHITECTURE Behavioral OF dvi_video_test IS
  COMPONENT vga_timing_generator IS
    GENERIC (H_ACTIVE      : std_logic_vector(10 DOWNTO 0);
             H_FRONT_PORCH : std_logic_vector(10 DOWNTO 0);
             H_SYNC        : std_logic_vector(10 DOWNTO 0);
             H_BACK_PORCH  : std_logic_vector(10 DOWNTO 0);


             V_ACTIVE      : std_logic_vector(10 DOWNTO 0);
             V_FRONT_PORCH : std_logic_vector(10 DOWNTO 0);
             V_SYNC        : std_logic_vector(10 DOWNTO 0);
             V_BACK_PORCH  : std_logic_vector(10 DOWNTO 0)

             );
    PORT (PIXEL_CLOCK : IN  std_logic;
          RESET       : IN  std_logic;
          CLKEN       : IN  std_logic;
          H_SYNC_Z    : OUT std_logic;
          V_SYNC_Z    : OUT std_logic;
          DATA_VALID  : OUT std_logic);
    --PIXEL_COUNT : OUT std_logic_vector(10 DOWNTO 0);
    --LINE_COUNT  : OUT std_logic_vector(10 DOWNTO 0));
  END COMPONENT;

  COMPONENT vga_timing_decode IS
    PORT (PIXEL_CLK : IN  std_logic;
          VSYNC     : IN  std_logic;
          HSYNC     : IN  std_logic;
          HCOUNT    : OUT std_logic_vector(9 DOWNTO 0);
          VCOUNT    : OUT std_logic_vector(9 DOWNTO 0));
  END COMPONENT;
  SIGNAL pix_clk            : std_logic;  -- This is the pixel clock for the DVI output and sync generator
  SIGNAL clk_fb, data_valid, clk_buf : std_logic;

  COMPONENT i2c_video_programmer IS
    PORT (CLK200Mhz : IN  std_logic;
          RST       : IN  std_logic;
          I2C_SDA   : OUT std_logic;
          I2C_SCL   : OUT std_logic);
  END COMPONENT;
BEGIN

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
  DVI_DE <= data_valid;

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
  DVI_D       <= "111111111111" WHEN data_valid = '1' ELSE (OTHERS => '0');

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
  BUFG_inst : BUFG
    PORT MAP (
      O => clk_buf,                     -- Clock buffer output
      I => CLK                          -- Clock buffer input
      );
  vga_timing_generator_i : vga_timing_generator
    GENERIC MAP(H_ACTIVE      => std_logic_vector(to_unsigned(10#640#, 11)),
                H_FRONT_PORCH => std_logic_vector(to_unsigned(10#16#, 11)),
                H_SYNC        => std_logic_vector(to_unsigned(10#96#, 11)),
                H_BACK_PORCH  => std_logic_vector(to_unsigned(10#48#, 11)),

                V_ACTIVE      => std_logic_vector(to_unsigned(10#480#, 11)),
                V_FRONT_PORCH => std_logic_vector(to_unsigned(10#12#, 11)),
                V_SYNC        => std_logic_vector(to_unsigned(10#2#, 11)),
                V_BACK_PORCH  => std_logic_vector(to_unsigned(10#31#, 11)))

    PORT MAP (
      RESET       => '0',
      CLKEN       => '1',
      H_SYNC_Z    => DVI_H,
      V_SYNC_Z    => DVI_V,
      DATA_VALID  => data_valid,
      PIXEL_CLOCK => pix_clk);

  -----------------------------------------------------------------------------
  -- VGA Input
  --PIX_CLK    <= VGA_PIXEL_CLK;
  Y          <= VGA_Y;
  HSYNC      <= VGA_HSYNC;
  VSYNC      <= VGA_VSYNC;
  ODD_EVEN_B <= VGA_ODD_EVEN_B;
  SOGOUT     <= VGA_SOGOUT;
  CLAMP      <= VGA_CLAMP;
  COAST      <= VGA_COAST;

  vga_timing_decode_i : vga_timing_decode
    PORT MAP (
      PIXEL_CLK => VGA_PIXEL_CLK,
      VSYNC     => VGA_VSYNC,
      VCOUNT    => VCOUNT,
      HSYNC     => VGA_HSYNC,
      HCOUNT    => HCOUNT);
END Behavioral;

