-- Module Name:  i2c_video_programmer
-- File Description:  Uses the I2C module to program the CH7301C and AD9980.
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
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY i2c_video_programmer IS
  PORT (CLK200Mhz : IN  std_logic;
        RST       : IN  std_logic;
        I2C_SDA   : OUT std_logic;
        I2C_SCL   : OUT std_logic);
END i2c_video_programmer;

ARCHITECTURE Behavioral OF i2c_video_programmer IS
  COMPONENT i2c_core IS
                       PORT (clk                : IN  std_logic;
                             data               : IN  std_logic_vector (23 DOWNTO 0);
                             new_data           : IN  std_logic;
                             reset              : IN  std_logic;
                             i2c_sda            : OUT std_logic;
                             i2c_scl            : OUT std_logic;
                             received_data      : OUT std_logic);
  END COMPONENT;
  COMPONENT vga_timing_decode IS
                                PORT (PIXEL_CLK : IN  std_logic;
                                      VSYNC     : IN  std_logic;
                                      HSYNC     : IN  std_logic;
                                      HCOUNT    : OUT std_logic_vector(9 DOWNTO 0);
                                      VCOUNT    : OUT std_logic_vector(9 DOWNTO 0));
  END COMPONENT;


  SIGNAL received_data : std_logic;
  SIGNAL new_data      : std_logic            := '0';
  SIGNAL data_count    : unsigned(3 DOWNTO 0) := (OTHERS => '0');  -- Used to count the data
  SIGNAL i2c_data      : std_logic_vector(23 DOWNTO 0);
                                        -- bytes sent over I2C
  SIGNAL i2c_clk       : std_logic;     -- 50Mhz i2c module input clock
  SIGNAL i2c_dcm_fb    : std_logic;
BEGIN
  PROCESS (data_count) IS
  BEGIN  -- PROCESS
    CASE data_count IS
      -- START VGA IN I2C Codes
      WHEN "0000"                                        =>
        i2c_data <= std_logic_vector(to_unsigned(16#320198#, 24));
      WHEN "0001"                                        =>
        i2c_data <= std_logic_vector(to_unsigned(16#000298#, 24));
      WHEN "0010"                                        =>
        i2c_data <= std_logic_vector(to_unsigned(16#600398#, 24));
        -- END VGA IN I2C Codes
        -- START DVI OUT I2C Codes
      WHEN "0011"                                        =>
        i2c_data <= std_logic_vector(to_unsigned(16#C049EC#, 24));
      WHEN "0100"                                        =>
        i2c_data <= std_logic_vector(to_unsigned(16#0921EC#, 24));
      WHEN "0101"                                        =>
        i2c_data <= std_logic_vector(to_unsigned(16#0833EC#, 24));
      WHEN "0110"                                        =>
        i2c_data <= std_logic_vector(to_unsigned(16#1634EC#, 24));
      WHEN "0111"                                        =>
        i2c_data <= std_logic_vector(to_unsigned(16#6036EC#, 24));
        -- END DVI OUT I2C Codes
      WHEN OTHERS                                        =>
        i2c_data <= (OTHERS                              => '0');

    END CASE;
  END PROCESS;

  -- DCM to divide input clock (200 mhz) by 16 to produce a 12.5 Mhz I2C Input
  -- clock (which will be divided by 500 for the SCL clock and 100 for the
  -- internal clock)
  -- controller input
  DCM_BASE_i2c : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 16.0,    -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE          => 32,      -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 2,       -- Can be any integer from 2 to 32
      CLKIN_DIVIDE_BY_2     => false,   -- TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD          => 5.0,     -- Specify period of input clock in ns from 1.25 to 1000.00
      CLKOUT_PHASE_SHIFT    => "NONE",  -- Specify phase shift mode of NONE or FIXED
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,    -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "HIGH",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "HIGH",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      PHASE_SHIFT           => 0,       -- Amount of fixed phase shift from -255 to 1023
      STARTUP_WAIT          => false)   -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0                  => i2c_dcm_fb,  -- 0 degree DCM CLK ouptput
      CLKDV                 => i2c_clk,
      CLKFB                 => i2c_dcm_fb,  -- DCM clock feedback
      CLKIN                 => CLK200Mhz,  -- Clock input (from IBUFG, BUFG or DCM)
      RST                   => '0'      -- DCM asynchronous reset input
      );


  -- purpose: This controls the data handshake with the I2C module, and manages the data to be sent
  -- type   : sequential
  -- inputs : CLK, RST, new_data
  -- outputs: received_data
  PROCESS (i2c_clk) IS
  BEGIN  -- PROCESS
    IF i2c_clk'event AND i2c_clk = '1' THEN  -- rising clock edge
      IF new_data = '0' AND received_data = '0' THEN
        new_data <= '1';
      END IF;

      IF new_data = '1' AND received_data = '1' THEN
        new_data     <= '0';
        IF data_count < 7 THEN          -- Prevents overflow
          data_count <= data_count + 1;
        ELSE
          data_count <= (OTHERS => '0');
        END IF;
      END IF; END IF;
    END PROCESS;

      i2c_core_i : i2c_core
        PORT MAP (
          CLK           => i2c_clk,
          data          => i2c_data,
          new_data      => new_data,
          reset         => '0',
          i2c_sda       => I2C_SDA,
          i2c_scl       => I2C_SCL,
          received_data => received_data);


    END Behavioral;

