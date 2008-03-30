-- Module Name:  vga_zbt_image_save_test.vhd
-- File Description:  An application of both the VGA input and ZBT memory
-- manager to save pixels to memory, and retrieve them for verification in Chipscope
-- Project:  FPGA Image Registration
-- Target Device:  XC5VSX50T (Xilinx Virtex5 SXT)
-- Target Board:  ML506
-- Synthesis Tool:  Xilinx ISE 9.2
-- Copyright (C) 2008 Brandyn Allen White
-- Contact:  bwhite(at)cs.ucf.edu
-- Project Website:  http://code.google.com/p/fpga-image-registration/

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY vga_zbt_image_save_test IS
  PORT (CLK_P : IN std_logic;
        CLK_N : IN std_logic;
        RST   : IN std_logic;           -- Active low reset
        GPIO_SW : IN std_logic_vector(4 DOWNTO 0);
        -- I2C Signals
        I2C_SDA : OUT std_logic;
        I2C_SCL : OUT std_logic;


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

        -- SRAM Connections
        SRAM_CLK_FB   : IN    std_logic;
        SRAM_CLK      : OUT   std_logic;
        SRAM_ADV_LD_B : OUT   std_logic;
        SRAM_ADDR     : OUT   std_logic_vector (17 DOWNTO 0);
        SRAM_WE_B     : OUT   std_logic;
        SRAM_BW_B     : OUT   std_logic_vector (3 DOWNTO 0);
        SRAM_CKE_B    : OUT   std_logic;  -- NOTE Unconnected for now
        SRAM_CS_B     : OUT   std_logic;
        SRAM_OE_B     : OUT   std_logic;
        SRAM_DATA     : INOUT std_logic_vector (35 DOWNTO 0);

        -- Psuedo IO Ports used to probe with Chipscope
        DATA_READ       : OUT std_logic_vector (35 DOWNTO 0);
        DATA_READ_VALID : OUT std_logic);
END vga_zbt_image_save_test;

ARCHITECTURE Behavioral OF vga_zbt_image_save_test IS
  COMPONENT zbt_controller IS
    PORT (CLK    : IN std_logic;
          CLK_3X : IN std_logic;
          RST    : IN std_logic;

          -- Control signals
          ADV_LD_B        : IN  std_logic;
          ADDR            : IN  std_logic_vector (17 DOWNTO 0);
          WE_B            : IN  std_logic;
          BW_B            : IN  std_logic_vector (3 DOWNTO 0);
          CKE_B           : IN  std_logic;
          CS_B            : IN  std_logic;
          DATA_WRITE      : IN  std_logic_vector (35 DOWNTO 0);
          DATA_READ       : OUT std_logic_vector(35 DOWNTO 0);
          DATA_READ_VALID : OUT std_logic;

          -- SRAM Connections
          SRAM_ADV_LD_B : OUT   std_logic;
          SRAM_ADDR     : OUT   std_logic_vector (17 DOWNTO 0);
          SRAM_WE_B     : OUT   std_logic;
          SRAM_BW_B     : OUT   std_logic_vector (3 DOWNTO 0);
          SRAM_CKE_B    : OUT   std_logic;
          SRAM_CS_B     : OUT   std_logic;
          SRAM_OE_B     : OUT   std_logic;
          SRAM_DATA     : INOUT std_logic_vector (35 DOWNTO 0));
  END COMPONENT zbt_controller;


  COMPONENT vga_timing_decode IS
    GENERIC (
      HEIGHT      : integer := 480;
      WIDTH       : integer := 640;
      H_BP        : integer := 117;
      V_BP        : integer := 34;
      HEIGHT_BITS : integer := 10;
      WIDTH_BITS  : integer := 10;
      DATA_DELAY  : integer := 1
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


  SIGNAL clk, clk_predcm, clk0_initial, clk_int, clk_int_3x, clk_intbuf, startup_dcm_rst, clk_buf, clk_0 : std_logic;
  SIGNAL data_write                                                                                      : std_logic_vector (35 DOWNTO 0);
  SIGNAL we_b,vga_data_valid_wire                                                                                            : std_logic;
  SIGNAL read_addr                                                                                 : unsigned (17 DOWNTO 0) := (OTHERS => '0');
   SIGNAL addr                                                                                 : std_logic_vector (17 DOWNTO 0):= (OTHERS => '0');
  SIGNAL pixel_addr_wire                                                                                 : unsigned(19 DOWNTO 0);
  SIGNAL button_in_en, save_frame,write_stream_started : std_logic := '0';
BEGIN

-------------------------------------------------------------------------------
  --This is the differential input clock BUFFER
  IBUFGDS_inst : IBUFGDS
    GENERIC MAP (
      IOSTANDARD => "DEFAULT")
    PORT MAP (
      O  => clk_predcm,                 -- Clock buffer output
      I  => CLK_P,                      -- Diff_p clock buffer input
      IB => CLK_N                       -- Diff_n clock buffer input
      );

  BUFGCTRL_inst : BUFGCTRL
    GENERIC MAP (
      INIT_OUT     => 0,      -- Inital value of 0 or 1 after configuration
      PRESELECT_I0 => false,  -- TRUE/FALSE set the I0 input after configuration
      PRESELECT_I1 => false)  -- TRUE/FALSE set the I1 input after configuration
    PORT MAP (
      O       => clk_buf,               -- Clock MUX output
      CE0     => '1',                   -- Clock enable0 input
      CE1     => '1',                   -- Clock enable1 input
      I0      => VGA_PIXEL_CLK,         -- Clock0 input
      I1      => '0',                   -- Clock1 input
      IGNORE0 => '0',                   -- Ignore clock select0 input
      IGNORE1 => '0',                   -- Ignore clock select1 input
      S0      => '1',                   -- Clock select0 input
      S1      => '0'                    -- Clock select1 input
      );

-------------------------------------------------------------------------------
  --This DDL is used to align the internal FPGA clock
  DCM_BASE_internal : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 2.0,  -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE          => 1,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 3,       -- Can be any integer from 2 to 32
      CLKIN_DIVIDE_BY_2     => false,  -- TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD          => 54.25,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLKOUT_PHASE_SHIFT    => "NONE",  -- Specify phase shift mode of NONE or FIXED
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,  -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "LOW",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "LOW",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      PHASE_SHIFT           => 0,  -- Amount of fixed phase shift from -255 to 1023
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => clk_int,                 -- 0 degree DCM CLK ouptput
      CLKFX => clk_int_3x,              -- DCM CLK synthesis out (M/D)
      CLKFB => clk_intbuf,              -- DCM clock feedback
      CLKIN => clk_buf,            -- Clock input (from IBUFG, BUFG or DCM)
      RST   => GPIO_SW(3)                      -- DCM asynchronous reset input
      );
  BUFG_inst : BUFG
    PORT MAP (
      O => clk_intbuf,                  -- Clock buffer output
      I => clk_int                      -- Clock buffer input
      );


-----------------------------------------------------------------------------
-- ZBT
  --This DLL is used to align the input clock to the child sram clock to
  --eliminate delay.


  DCM_BASE_sram : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 2.0,  -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE          => 4,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 3,       -- Can be any integer from 2 to 32
      CLKIN_DIVIDE_BY_2     => false,  -- TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD          => 54.25,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLKOUT_PHASE_SHIFT    => "NONE",  -- Specify phase shift mode of NONE or FIXED
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,  -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "LOW",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "LOW",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      PHASE_SHIFT           => 0,  -- Amount of fixed phase shift from -255 to 1023
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => clk_0,                   -- 0 degree DCM CLK ouptput
      CLKFB => SRAM_CLK_FB,             -- DCM clock feedback
      CLKIN => clk_buf,            -- Clock input (from IBUFG, BUFG or DCM)
      RST   => GPIO_SW(3)                      -- DCM asynchronous reset input
      );


  SRAM_CLK <= clk_0;
  data_write <= ((35 DOWNTO 8 => '0')&VGA_Y_GREEN);
  -- For this we need to control we_b, addr, data_write
  zbt_controller_i : zbt_controller PORT MAP (
    CLK    => clk_intbuf,
    CLK_3X => clk_int_3x,
    RST    => '0',

    -- Control signals
    ADV_LD_B        => '0',
    ADDR            => addr,
    WE_B            => we_b,
    BW_B            => (OTHERS => '0'),
    CKE_B           => '0',
    CS_B            => '0',
    DATA_WRITE      => data_write,
    DATA_READ       => DATA_READ,
    DATA_READ_VALID => DATA_READ_VALID,

    -- SRAM Connections
    SRAM_ADV_LD_B => SRAM_ADV_LD_B,
    SRAM_ADDR     => SRAM_ADDR,
    SRAM_WE_B     => SRAM_WE_B,
    SRAM_BW_B     => SRAM_BW_B,
    SRAM_CKE_B    => SRAM_CKE_B,
    SRAM_CS_B     => SRAM_CS_B,
    SRAM_OE_B     => SRAM_OE_B,
    SRAM_DATA     => SRAM_DATA);

-------------------------------------------------------------------------------
-- VGA
  vga_timing_decode_i : vga_timing_decode
    PORT MAP (
      CLK         => clk_intbuf,
      RST         => '0',
      VSYNC       => VGA_VSYNC,
      HSYNC       => VGA_HSYNC,
      DATA_VALID  => vga_data_valid_wire,
      PIXEL_COUNT => pixel_addr_wire);

-------------------------------------------------------------------------------
-- I2C
  i2c_video_programmer_i : i2c_video_programmer
    PORT MAP (
      CLK200Mhz => clk_predcm,
      RST       => '0',
      I2C_SDA   => I2C_SDA,
      I2C_SCL   => I2C_SCL);

-------------------------------------------------------------------------------
-- Read Address Counter
  PROCESS (clk_intbuf) IS
  BEGIN  -- PROCESS
    IF clk_intbuf'event AND clk_intbuf = '1' THEN  -- rising clock edge
      IF read_addr /= 262143 THEN          
        read_addr <= read_addr + 1;
      ELSE
        read_addr <= (OTHERS => '0');
      END IF;
    END IF;
  END PROCESS;

-------------------------------------------------------------------------------
-- Address and Read/Write Controller
  PROCESS (clk_intbuf) IS
  BEGIN  -- PROCESS
    IF clk_intbuf'event AND clk_intbuf = '1' THEN  -- rising clock edge
      IF ((save_frame = '1' AND pixel_addr_wire = 0) OR write_stream_started = '1') AND vga_data_valid_wire='1' THEN
        save_frame <= '0';
        write_stream_started <= '1';
        we_b                 <= '0';
        addr                 <= std_logic_vector(pixel_addr_wire(17 DOWNTO 0));
      ELSIF pixel_addr_wire >= 262143 AND write_stream_started='1' THEN-- Last pixel
                                                                                                  -- for
                                                                                                  -- 640x480 307199
        write_stream_started <= '0';
        we_b                 <= '0';
        addr                 <= std_logic_vector(pixel_addr_wire(17 DOWNTO 0));
      ELSE
        we_b <= '1';
        addr <= std_logic_vector(read_addr);
      END IF;

      -- This is the "input enable" button debounce strategy.
      IF GPIO_SW(4) = '1' THEN          -- Enable input
        button_in_en <= '1';
      ELSIF button_in_en = '1' AND GPIO_SW(0) = '1' THEN
        save_frame   <= '1';
        button_in_en <= '0';
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

