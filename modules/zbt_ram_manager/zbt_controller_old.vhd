----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:58:13 12/28/2007 
-- Design Name: 
-- Module Name:    zbt_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: The purpose of this is to test out the ZBT ram on the
-- ML505 and ML506 development boards.  Data is entered on the DIP switches for
-- input, and output is displayed on the LEDs.  Everything is in 1 byte
-- segments, the parity bits will not be used in this example.  To advance by a
-- byte, push the encoder wheel up, and to decrement push the encoder wheel
-- down. Pushing the encoder wheel in will save the value on the DIP switches
-- to that location.  The address will wrap around from 0 to the maximum
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
    CLK : IN std_logic;
    RST : IN std_logic;
    CMD_ENABLE : IN std_logic;  -- If true, we use input as a command
    BW_B : IN std_logic_vector(3 DOWNTO 0);
    WE_B : IN std_logic;
    ADDR : IN std_logic_vector(17 DOWNTO 0);
    DATA_WRITE : IN std_logic_vector(35 DOWNTO 0);
    SRAM_CS_B : OUT std_logic;
    SRAM_BW_B : OUT std_logic_vector (3 DOWNTO 0);
    SRAM_OE_B : OUT std_logic;
    SRAM_WE_B : OUT std_logic;
    SRAM_ADDR : OUT std_logic_vector (17 DOWNTO 0);
    DATA_READ : OUT std_logic_vector(35 DOWNTO 0);
    DATA_READ_VALID : OUT std_logic;
    SRAM_DATA : INOUT std_logic_vector (35 DOWNTO 0));
END zbt_controller;

ARCHITECTURE Behavioral OF zbt_controller IS
  TYPE ZBT_STATE IS (IDLE, WRITE_START, WRITE_CMD, WRITE_WAIT, WRITE, READ_START, READ_CMD, READ_WAIT, READ);
  -- This is the type that defines the possible states the system can be in.
--  SIGNAL RST                 : std_logic;
  SIGNAL clk_int, clk_buf, clk_intbuf, clk, clk_0 : std_logic;  -- Delay corrected clock for SRAM
  SIGNAL cur_state : ZBT_STATE := IDLE;  -- Current system state
  SIGNAL cur_addr : unsigned (1 DOWNTO 0) := (OTHERS => '0');  --(17 DOWNTO 0) := (OTHERS => '0');
  SIGNAL sram_flash_we_b_reg : std_logic := '1';
  SIGNAL sram_cs_b_reg : std_logic := '1';
  SIGNAL gpio_led_reg : std_logic_vector (7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL initial_read : std_logic := '0';
  -- This is 1 if the initial read has occured to set gpio_led_reg
  SIGNAL sram_data_reg : std_logic_vector (7 DOWNTO 0) := (OTHERS => '0');
  -- This is a reg for the used portion of the sram_flash_d_res input, it is used to enable tri-state output on the register
  SIGNAL sram_data_oe_b : std_logic := '0';
  -- This is a register that determines if the sram_flash_d_reg is connected to the inout port, or floated
  SIGNAL user_input_enable : std_logic := '1';  -- This is a trivial way to fix button bouncing, after each command, require that a dedicated button be pressed to allow input to occur again.
-- TODO generate SRAM_CLK from input clock, use it for all processing in this
-- module;
  SIGNAL global_reset : std_logic;  -- This combines all of the reset
                                        -- signals (active low)
  SIGNAL sram_dll_locked, initial_dll_locked, int_dll_locked, startup_dcm_rst, clk_predcm, clk0_initial : std_logic;
  SIGNAL gpio_sw_reg : std_logic_vector (4 DOWNTO 0) := (OTHERS => '0');
  SIGNAL rst_reg : std_logic := '1';
  SIGNAL fpga_rotary_reg : std_logic_vector (2 DOWNTO 0) := (OTHERS => '0');
BEGIN
  global_reset <= rst_reg AND sram_dll_locked AND initial_dll_locked AND int_dll_locked;
  SRAM_A <= std_logic_vector(cur_addr);
  SRAM_WE_B <= sram_flash_we_b_reg;
  SRAM_CS_B <= sram_cs_b_reg;

-------------------------------------------------------------------------------  
-- purpose: This determines if the sram_flash_d_reg is connected to the inout
-- port
-- type   : combinational
-- inputs : sram_flash_d_reg, sram_flash_d_oe_b
-- outputs: SRAM_FLASH_D, SRAM_OE_B
  PROCESS (sram_data_reg, sram_data_oe_b) IS
  BEGIN  -- PROCESS
    IF sram_data_oe_b = '0' THEN
      SRAM_DATA <= sram_data_reg;
    ELSE
      SRAM_DATA <= (OTHERS => 'Z');
    END IF;
  END PROCESS;




-------------------------------------------------------------------------------  
-- Currently Implemented Method
-- Only uses the lower 8 bits to store the data in it.

  PROCESS (clk_intbuf) IS
  BEGIN  -- PROCESS
    IF clk_intbuf'event AND clk_intbuf = '1' THEN  -- rising clock edge
      gpio_sw_reg <= GPIO_SW;
      fpga_rotary_reg <= FPGA_ROTARY;
      rst_reg <= RST;

      IF global_reset = '0' THEN  -- synchronous reset (active low)
        cur_addr <= (OTHERS => '0');
        initial_read <= '0';
        cur_state <= IDLE;
        sram_cs_b_reg <= '1';
        sram_flash_d_oe_b <= '1';
        SRAM_OE_B <= '1';  -- Disable SRAM output
        user_input_enable <= '1';
      ELSE
                                        -------------------------------------------------------------------------
                                        -- This state machine is written to account for the register delay by
                                        -- setting values one CT before hand, that is why semantically these seem
                                        -- ahead (by their name).  Before the states are entered, the expected
                                        -- preconditions must be satisfied.
        ZBT_FSM : CASE cur_state IS
          WHEN IDLE =>
            sram_flash_d_oe_b <= '1';  -- Set ALL used data reg lines to
                                        -- High Z when they are not to
                                        -- be written TO
            IF gpio_sw_reg(3) = '0' THEN
              sram_cs_b_reg <= '1';
              SRAM_OE_B <= '1';  -- Disable SRAM output
            ELSE
              SRAM_OE_B <= '0';
              sram_cs_b_reg <= '0';
            END IF;

            -------------------------------------------------------------------------
            -- This is the main control structure for user input and state initialization
            control : IF initial_read = '0' THEN
              initial_read <= '1';
              cur_state <= READ_START;
            ELSIF user_input_enable = '1' THEN
              cmd_input : IF fpga_rotary_reg(0) = '1' THEN
                user_input_enable <= '0';
                cur_addr <= cur_addr - 1;  -- Dec
                cur_state <= READ_START;
              ELSIF fpga_rotary_reg(1) = '1' THEN
                user_input_enable <= '0';
                cur_addr <= cur_addr + 1;  -- Inc
                cur_state <= READ_START;
              ELSIF fpga_rotary_reg(2) = '1' THEN  -- Save
                user_input_enable <= '0';
                cur_state <= WRITE_START;
              ELSIF gpio_sw_reg(0) = '1' THEN
                user_input_enable <= '0';
                cur_addr <= (OTHERS => '0');
                cur_state <= READ_START;
              ELSIF gpio_sw_reg(1) = '1' THEN
                user_input_enable <= '0';
                cur_state <= READ_START;
              ELSIF gpio_sw_reg(2) = '1' THEN
                user_input_enable <= '0';
                cur_addr <= (OTHERS => '1');
                cur_state <= READ_START;
              END IF;
            ELSIF gpio_sw_reg(4) = '1' THEN
              user_input_enable <= '1';
            END IF;
          WHEN WRITE_START =>
            cur_state <= WRITE_CMD;
            sram_cs_b_reg <= '0';  -- Enable command
            sram_flash_we_b_reg <= '0';  -- Enable write
          WHEN WRITE_CMD =>
            sram_flash_we_b_reg <= '1';  -- Disable write (read mode)
            sram_cs_b_reg <= '1';  -- Disable chip commands
            cur_state <= WRITE_WAIT;
          WHEN WRITE_WAIT =>
            cur_state <= WRITE;
            SRAM_OE_B <= '1';  -- Disable SRAM output
            sram_flash_d_reg <= GPIO_DIP_SW;  -- Put DIP values on data bus
            sram_flash_d_oe_b <= '0';  -- Enable data reg output
          WHEN WRITE =>
            --cur_state                    <= READ_START;
            cur_state <= IDLE;
          WHEN READ_START =>
            cur_state <= READ_CMD;
            sram_cs_b_reg <= '0';  -- Enable command
            sram_flash_we_b_reg <= '1';  -- Enable read
            sram_flash_d_oe_b <= '1';  -- Disable data reg output
            SRAM_OE_B <= '0';  -- Enable SRAM output
          WHEN READ_CMD =>  -- Disable chip commands
            sram_cs_b_reg <= '1';
            cur_state <= READ_WAIT;
          WHEN READ_WAIT =>
            cur_state <= READ;
          WHEN READ =>  -- Save value on the data bus to the
                                        -- LED reg
            gpio_led_reg <= SRAM_D(7 DOWNTO 0);
            cur_state <= IDLE;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

