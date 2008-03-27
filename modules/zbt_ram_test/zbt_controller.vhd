-- Module Name:  zbt_controller.vhd
-- File Description:  Crude zbt memory test (obsoleted), shouldn't be used.
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


-- Additional Comments: The purpose of this is to test out the ZBT ram on the
-- ML505 and ML506 development boards. Data is entered on the DIP switches for
-- input, and output is displayed on the LEDs. Everything is in 1 byte
-- segments, the parity bits will not be used in this example. To advance by a
-- byte, push the encoder wheel up, and to decrement push the encoder wheel
-- down. Pushing the encoder wheel in will save the value on the DIP switches
-- to that location. The address will wrap around from 0 to the maximum
-- address and the other way around to produce a ring buffer with no obvious
-- edges,be careful of valid data overwriting.
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY zbt_controller IS
  PORT (
    CLK_P, CLK_N : IN std_logic;
    RST          : IN std_logic;

    --Connections to misc board devices
    FPGA_ROTARY : IN  std_logic_vector (2 DOWNTO 0);
    GPIO_SW     : IN  std_logic_vector (4 DOWNTO 0);
    GPIO_DIP_SW : IN  std_logic_vector (7 DOWNTO 0);
    GPIO_LED    : OUT std_logic_vector (7 DOWNTO 0);

    -- Connections to SRAM
    SRAM_CS_B        : OUT   std_logic;
    SRAM_BW_B        : OUT   std_logic_vector (3 DOWNTO 0);
    SRAM_ADV_LD_B    : OUT   std_logic;
    SRAM_OE_B        : OUT   std_logic;
    SRAM_WE_B        : OUT   std_logic;
    SRAM_CLK         : OUT   std_logic;
    SRAM_CLK_FB      : IN    std_logic;
    SRAM_A           : OUT   std_logic_vector (17 DOWNTO 0);
    SRAM_D           : INOUT std_logic_vector (7 DOWNTO 0);  --(31 DOWNTO 0);  --(15 DOWNTO 0);
    SRAM_FLASH_D_OUT : OUT   std_logic_vector(7 DOWNTO 0));
END zbt_controller;

ARCHITECTURE Behavioral OF zbt_controller IS
  TYPE ZBT_STATE IS (IDLE, WRITE_START, WRITE_CMD, WRITE_WAIT, WRITE, READ_START, READ_CMD, READ_WAIT, READ);
  -- This is the type that defines the possible states the system can be in.
--  SIGNAL RST                 : std_logic;
  SIGNAL clk_int, clk_buf, clk_intbuf, clk, clk_0                                                       : std_logic;  -- Delay corrected clock for SRAM
  SIGNAL cur_state                                                                                      : ZBT_STATE                     := IDLE;  -- Current system state
  SIGNAL cur_addr                                                                                       : unsigned (1 DOWNTO 0)         := (OTHERS => '0');  --(17 DOWNTO 0) := (OTHERS => '0');
  SIGNAL sram_flash_we_b_reg                                                                            : std_logic                     := '1';
  SIGNAL sram_cs_b_reg                                                                                  : std_logic                     := '1';
  SIGNAL gpio_led_reg                                                                                   : std_logic_vector (7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL initial_read                                                                                   : std_logic                     := '0';
  -- This is 1 if the initial read has occured to set gpio_led_reg
  SIGNAL sram_flash_d_reg                                                                               : std_logic_vector (7 DOWNTO 0) := (OTHERS => '0');
  -- This is a reg for the used portion of the sram_flash_d_res input, it is used to enable tri-state output on the register
  SIGNAL sram_flash_d_oe_b                                                                              : std_logic                     := '0';
  -- This is a register that determines if the sram_flash_d_reg is connected to the inout port, or floated
  SIGNAL user_input_enable                                                                              : std_logic                     := '1';  -- This is a trivial way to fix button bouncing, after each command, require that a dedicated button be pressed to allow input to occur again.
-- TODO generate SRAM_CLK from input clock, use it for all processing in this
-- module;
  SIGNAL global_reset                                                                                   : std_logic;  -- This combines all of the reset
                                        -- signals (active low)
  SIGNAL sram_dll_locked, initial_dll_locked, int_dll_locked, startup_dcm_rst, clk_predcm, clk0_initial : std_logic;
  SIGNAL gpio_sw_reg                                                                                    : std_logic_vector (4 DOWNTO 0) := (OTHERS => '0');
  SIGNAL rst_reg                                                                                        : std_logic                     := '1';
  SIGNAL fpga_rotary_reg                                                                                : std_logic_vector (2 DOWNTO 0) := (OTHERS => '0');
BEGIN
  global_reset     <= rst_reg AND sram_dll_locked AND initial_dll_locked AND int_dll_locked;
  SRAM_BW_B        <= "0000";
  SRAM_ADV_LD_B    <= '0';
  SRAM_A           <= ("0000000000000000"&std_logic_vector(cur_addr));
  SRAM_WE_B        <= sram_flash_we_b_reg;
  SRAM_CS_B        <= sram_cs_b_reg;
  GPIO_LED         <= gpio_led_reg;
  SRAM_CLK         <= clk_0;            --CLK;
  SRAM_FLASH_D_OUT <= SRAM_D(7 DOWNTO 0);

-------------------------------------------------------------------------------
  --This is the differential input clock BUFFER
  IBUFGDS_inst : IBUFGDS
    GENERIC MAP (
      IOSTANDARD => "DEFAULT")
    PORT MAP (
      O          => clk_predcm,         -- Clock buffer output
      I          => CLK_P,              -- Diff_p clock buffer input
      IB         => CLK_N               -- Diff_n clock buffer input
      );

  DCM_BASE_initial : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 2.0,     -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE          => 8,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 5,       -- Can be any integer from 2 to 32
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
      CLK0                  => clk0_initial,  -- 0 degree DCM CLK ouptput
      --CLK180 => CLK180,               -- 180 degree DCM CLK output
      --CLK270 => CLK270,               -- 270 degree DCM CLK output
      --CLK2X => CLK2X,                 -- 2X DCM CLK output
      --CLK2X180 => CLK2X180,           -- 2X, 180 degree DCM CLK out
      --CLK90 => CLK90,                 -- 90 degree DCM CLK output
      --CLKDV => CLKDV,                 -- Divided DCM CLK out (CLKDV_DIVIDE)
      CLKFX                 => clk,     -- DCM CLK synthesis out (M/D)
      --CLKFX180 => CLKFX180,           -- 180 degree CLK synthesis out
      LOCKED                => initial_dll_locked,  -- DCM LOCK status output
      CLKFB                 => clk0_initial,  -- DCM clock feedback
      CLKIN                 => clk_predcm,  -- Clock input (from IBUFG, BUFG or DCM)
      RST                   => '0'      -- DCM asynchronous reset input
      );



  BUFGCTRL_inst : BUFGCTRL
    GENERIC MAP (
      INIT_OUT     => 0,                -- Inital value of 0 or 1 after configuration
      PRESELECT_I0 => false,            -- TRUE/FALSE set the I0 input after configuration
      PRESELECT_I1 => false)            -- TRUE/FALSE set the I1 input after configuration
    PORT MAP (
      O            => clk_buf,          -- Clock MUX output
      CE0          => '1',              -- Clock enable0 input
      CE1          => '1',              -- Clock enable1 input
      I0           => clk,              -- Clock0 input
      I1           => '0',              -- Clock1 input
      IGNORE0      => '0',              -- Ignore clock select0 input
      IGNORE1      => '0',              -- Ignore clock select1 input
      S0           => '1',              -- Clock select0 input
      S1           => '0'               -- Clock select1 input
      );

-----------------------------------------------------------------------------
  --This shift register forces the DCM/DLL's to reset immediately after the fpga
  --is setup, this is to prevent the sram DCM from trying to lock before its
  --feedback pin is permitted to take current.
  SRL16_startup_rst : SRL16
    GENERIC MAP (
      INIT => X"FFFF")
    PORT MAP (
      Q    => startup_dcm_rst,          -- SRL data output
      A0   => '1',                      -- Select[0] input
      A1   => '1',                      -- Select[1] input
      A2   => '1',                      -- Select[2] input
      A3   => '1',                      -- Select[3] input
      CLK  => clk_predcm,               -- Clock input
      D    => '0'                       -- SRL data input
      );

-------------------------------------------------------------------------------
  --This DDL is used to align the internal FPGA clock
  DCM_BASE_internal : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 2.0,     -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE          => 1,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 4,       -- Can be any integer from 2 to 32
      CLKIN_DIVIDE_BY_2     => false,   -- TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD          => 8.0,     -- Specify period of input clock in ns from 1.25 to 1000.00
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
      CLK0                  => clk_int,  -- 0 degree DCM CLK ouptput
      --CLK180 => CLK180,               -- 180 degree DCM CLK output
      --CLK270 => CLK270,               -- 270 degree DCM CLK output
      --CLK2X => CLK2X,                 -- 2X DCM CLK output
      --CLK2X180 => CLK2X180,           -- 2X, 180 degree DCM CLK out
      --CLK90 => CLK90,                 -- 90 degree DCM CLK output
      --CLKDV => CLKDV,                 -- Divided DCM CLK out (CLKDV_DIVIDE)
      --CLKFX => clk_int,               -- DCM CLK synthesis out (M/D)
      --CLKFX180 => CLKFX180,           -- 180 degree CLK synthesis out
      LOCKED                => int_dll_locked,  -- DCM LOCK status output
      CLKFB                 => clk_intbuf,  -- DCM clock feedback
      CLKIN                 => clk_buf,  -- Clock input (from IBUFG, BUFG or DCM)
      RST                   => startup_dcm_rst  -- DCM asynchronous reset input
      );
  BUFG_inst         : BUFG
    PORT MAP (
      O                     => clk_intbuf,  -- Clock buffer output
      I                     => clk_int  -- Clock buffer input
      );


-----------------------------------------------------------------------------
  --This DLL is used to align the input clock to the child sram clock to
  --eliminate delay.


  DCM_BASE_sram : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 2.0,     -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE          => 4,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 3,       -- Can be any integer from 2 to 32
      CLKIN_DIVIDE_BY_2     => false,   -- TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD          => 8.0,     -- Specify period of input clock in ns from 1.25 to 1000.00
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
      CLK0                  => clk_0,   -- 0 degree DCM CLK ouptput
      --CLK180 => CLK180,               -- 180 degree DCM CLK output
      --CLK270 => CLK270,               -- 270 degree DCM CLK output
      --CLK2X => CLK2X,                 -- 2X DCM CLK output
      --CLK2X180 => CLK2X180,           -- 2X, 180 degree DCM CLK out
      --CLK90 => CLK90,                 -- 90 degree DCM CLK output
      --CLKDV => CLKDV,                 -- Divided DCM CLK out (CLKDV_DIVIDE)
      --CLKFX => clk_0,                 -- DCM CLK synthesis out (M/D)
      --CLKFX180 => CLKFX180,           -- 180 degree CLK synthesis out
      LOCKED                => sram_dll_locked,  -- DCM LOCK status output
      CLKFB                 => SRAM_CLK_FB,  -- DCM clock feedback
      CLKIN                 => clk_buf,  -- Clock input (from IBUFG, BUFG or DCM)
      RST                   => startup_dcm_rst  -- DCM asynchronous reset input
      );

-------------------------------------------------------------------------------
-- purpose: This determines if the sram_flash_d_reg is connected to the inout
-- port
-- type : combinational
-- inputs : sram_flash_d_reg, sram_flash_d_oe_b
-- outputs: SRAM_FLASH_D, SRAM_OE_B
  PROCESS (sram_flash_d_reg, sram_flash_d_oe_b) IS
  BEGIN  -- PROCESS
    IF sram_flash_d_oe_b = '0' THEN
      SRAM_D(7 DOWNTO 0) <= sram_flash_d_reg;
    ELSE
      SRAM_D(7 DOWNTO 0) <= (OTHERS => 'Z');
    END IF;
  END PROCESS;

-------------------------------------------------------------------------------
-- Currently Implemented Method
-- Only uses the lower 8 bits to store the data in it.

  PROCESS (clk_intbuf) IS
  BEGIN  -- PROCESS
    IF clk_intbuf'event AND clk_intbuf = '1' THEN  -- rising clock edge
      gpio_sw_reg     <= GPIO_SW;
      fpga_rotary_reg <= FPGA_ROTARY;
      rst_reg         <= RST;

      IF global_reset = '0' THEN        -- synchronous reset (active low)
        cur_addr              <= (OTHERS => '0');
        initial_read          <= '0';
        cur_state             <= IDLE;
        sram_cs_b_reg         <= '1';
        sram_flash_d_oe_b     <= '1';
        SRAM_OE_B             <= '1';   -- Disable SRAM output
        user_input_enable     <= '1';
      ELSE
        -------------------------------------------------------------------------
        -- This state machine is written to account for the register delay by
        -- setting values one CT before hand, that is why semantically these seem
        -- ahead (by their name).  Before the states are entered, the expected
        -- preconditions must be satisfied.
        ZBT_FSM : CASE cur_state IS
          WHEN IDLE                      =>
            sram_flash_d_oe_b <= '1';   -- Set ALL used data reg lines to
                                        -- High Z when they are not to
                                        -- be written TO
            IF gpio_sw_reg(3) = '0' THEN
              sram_cs_b_reg   <= '1';
              SRAM_OE_B       <= '1';   -- Disable SRAM output
            ELSE
              SRAM_OE_B       <= '0';
              sram_cs_b_reg   <= '0';
            END IF;

            -------------------------------------------------------------------------
            -- This is the main control structure for user input and state initialization
            control     : IF initial_read = '0' THEN
              initial_read        <= '1';
              cur_state           <= READ_START;
            ELSIF user_input_enable = '1' THEN
              cmd_input : IF fpga_rotary_reg(0) = '1' THEN
                user_input_enable <= '0';
                cur_addr          <= cur_addr - 1;  -- Dec
                cur_state         <= READ_START;
              ELSIF fpga_rotary_reg(1) = '1' THEN
                user_input_enable <= '0';
                cur_addr          <= cur_addr + 1;  -- Inc
                cur_state         <= READ_START;
              ELSIF fpga_rotary_reg(2) = '1' THEN  -- Save
                user_input_enable <= '0';
                cur_state         <= WRITE_START;
              ELSIF gpio_sw_reg(0) = '1' THEN
                user_input_enable <= '0';
                cur_addr          <= (OTHERS => '0');
                cur_state         <= READ_START;
              ELSIF gpio_sw_reg(1) = '1' THEN
                user_input_enable <= '0';
                cur_state         <= READ_START;
              ELSIF gpio_sw_reg(2) = '1' THEN
                user_input_enable <= '0';
                cur_addr          <= (OTHERS => '1');
                cur_state         <= READ_START;
              END IF;
            ELSIF gpio_sw_reg(4) = '1' THEN
              user_input_enable   <= '1';
            END IF;
          WHEN WRITE_START                   =>
            cur_state             <= WRITE_CMD;
            sram_cs_b_reg         <= '0';  -- Enable command
            sram_flash_we_b_reg   <= '0';  -- Enable write
          WHEN WRITE_CMD                     =>
            sram_flash_we_b_reg   <= '1';  -- Disable write (read mode)
            sram_cs_b_reg         <= '1';  -- Disable chip commands
            cur_state             <= WRITE_WAIT;
          WHEN WRITE_WAIT                    =>
            cur_state             <= WRITE;
            SRAM_OE_B             <= '1';  -- Disable SRAM output
            sram_flash_d_reg      <= GPIO_DIP_SW;  -- Put DIP values on data bus
            sram_flash_d_oe_b     <= '0';  -- Enable data reg output
          WHEN WRITE                         =>
            --cur_state                    <= READ_START;
            cur_state             <= IDLE;
          WHEN READ_START                    =>
            cur_state             <= READ_CMD;
            sram_cs_b_reg         <= '0';  -- Enable command
            sram_flash_we_b_reg   <= '1';  -- Enable read
            sram_flash_d_oe_b     <= '1';  -- Disable data reg output
            SRAM_OE_B             <= '0';  -- Enable SRAM output
          WHEN READ_CMD                      =>  -- Disable chip commands
            sram_cs_b_reg         <= '1';
            cur_state             <= READ_WAIT;
          WHEN READ_WAIT                     =>
            cur_state             <= READ;
          WHEN READ                          =>  -- Save value on the data bus to the
                                        -- LED reg
            gpio_led_reg          <= SRAM_D(7 DOWNTO 0);
            cur_state             <= IDLE;
          WHEN OTHERS                        => NULL;
        END CASE;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

