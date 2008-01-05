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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity zbt_controller is
    PORT (
      CLK              : IN STD_LOGIC;
      RST              : IN STD_LOGIC;

      --Connections to misc board devices
      FPGA_ROTARY      : IN STD_LOGIC_VECTOR  (2 DOWNTO 0);
      GPIO_DIP_SW      : IN STD_LOGIC_VECTOR  (7 DOWNTO 0);
      GPIO_LED         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);

      -- Connections to SRAM
      SRAM_CS_B        : OUT STD_LOGIC;
      SRAM_BW          : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      SRAM_ADV_LD_B    : OUT STD_LOGIC;
      SRAM_OE_B        : OUT STD_LOGIC;
      SRAM_FLASH_WE_B  : OUT STD_LOGIC;
      SRAM_CLK         : OUT STD_LOGIC;
      SRAM_FLASH_A     : OUT STD_LOGIC_VECTOR (20 DOWNTO 0);
      SRAM_DQP         : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
      SRAM_D_RES       : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      SRAM_FLASH_D_RES : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0));
end zbt_controller;

architecture Behavioral of zbt_controller is
TYPE ZBT_STATE IS (IDLE, WRITE_CMD, WRITE_WAIT, WRITE, READ_CMD, READ_WAIT, READ);  
                                        -- This is the type that defines the possible states the system can be in.
SIGNAL cur_state : ZBT_STATE := IDLE;   -- Current system state
SIGNAL cur_addr : UNSIGNED (17 DOWNTO 0) := (OTHERS => '0');
SIGNAL sram_flash_we_b_reg : STD_LOGIC := '1';
SIGNAL sram_cs_b_reg : STD_LOGIC := '1';
SIGNAL gpio_led_reg : std_logic_vector (7 DOWNTO 0) := (OTHERS => '0');
SIGNAL initial_read : STD_LOGIC := '0';  
                                        -- This is 1 if the initial read has occured to set gpio_led_reg
SIGNAL sram_flash_d_res_reg : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');  
                                        -- This is a reg for the used portion of the sram_flash_d_res input, it is used to enable tri-state output on the register
SIGNAL sram_flash_d_res_oe : STD_LOGIC := '0';  
                                        -- This is a register that determines if the sram_flash_d_res_reg is connected to the inout port, or floated
-- TODO generate SRAM_CLK from input clock, use it for all processing in this
-- module

begin
SRAM_BW <= "0000";
SRAM_OE_B <= '0';
SRAM_ADV_LD_B <= '0';
SRAM_FLASH_A(18 DOWNTO 1) <= STD_LOGIC_VECTOR(cur_addr);  -- NOTE These bounds
                                                          -- may be wrong!!
SRAM_FLASH_WE_B <= sram_flash_we_b_reg;
SRAM_CS_B <= sram_cs_b_reg;
GPIO_LED <= gpio_led_reg;
-- purpose: This determines if the sram_flash_d_res_reg is connected to the inout port
-- type   : combinational
-- inputs : sram_flash_d_res_reg, sram_flash_d_res_oe
-- outputs: SRAM_FLASH_D_RES
PROCESS (sram_flash_d_res_reg, sram_flash_d_res_oe) IS
BEGIN  -- PROCESS
  IF sram_flash_d_res_oe='1' THEN
    SRAM_FLASH_D_RES(7 DOWNTO 0) <= sram_flash_d_res_reg;
  ELSE
    SRAM_FLASH_D_RES(7 DOWNTO 0) <= (OTHERS => 'Z');
  END IF;
END PROCESS;

-- Currently Implemented Method
-- Only uses the lower 8 bits to store the data in it.

PROCESS (CLK) IS
BEGIN  -- PROCESS
  IF CLK'event AND CLK = '1' THEN       -- rising clock edge
    IF RST = '1' THEN                   -- synchronous reset (active high)
      cur_addr <= (OTHERS => '0');
      initial_read <= '0';
      cur_state <= IDLE;
      sram_cs_b_reg <= '1';
      sram_flash_d_res_oe <= '0';
    ELSE
      -------------------------------------------------------------------------
      -- This state machine is written to account for the register delay by
      -- setting values one CT before hand, that is why semantically these seem
      -- ahead (by their name).  Before the states are entered, the expected
      -- preconditions must be satisfied.
      ZBT_FSM:CASE cur_state IS
        WHEN IDLE =>
          sram_flash_d_res_oe <= '0';             -- Set ALL used data lines to
                                                  -- High Z when they are not to
                                                  -- be written to
          sram_cs_b_reg <= '1';
          -------------------------------------------------------------------------
          -- This is the main control structure for user input and state initialization
          control:IF initial_read='0' THEN
            initial_read <= '1';
            -- Give read command
            cur_state <= READ_CMD;
            sram_cs_b_reg <= '0';               -- Enable command
            sram_flash_we_b_reg <= '1';         -- Enable read
          ELSE
            cmd_input:IF FPGA_ROTARY(0)='1' THEN
              cur_addr <= cur_addr - 1;     -- Dec
              -- Give read command
              cur_state <= READ_CMD;
              sram_cs_b_reg <= '0';               -- Enable command
              sram_flash_we_b_reg <= '1';         -- Enable read
            ELSIF FPGA_ROTARY(1)='1' THEN 
              cur_addr <= cur_addr + 1;     -- Inc
              -- Give read command
              cur_state <= READ_CMD;
              sram_cs_b_reg <= '0';               -- Enable command
              sram_flash_we_b_reg <= '1';         -- Enable read
            ELSIF FPGA_ROTARY(2)='1' THEN   -- Save
              -- Give write command
              cur_state <= WRITE_CMD;
              sram_cs_b_reg <= '0';             -- Enable command
              sram_flash_we_b_reg <= '0';       -- Enable write
            END IF;
          END IF;
        WHEN WRITE_CMD =>               -- Disable chip commands
          sram_cs_b_reg <= '1';
          cur_state <= WRITE_WAIT;
        WHEN WRITE_WAIT =>              -- Put DIP values on data bus
          sram_flash_d_res_reg(7 DOWNTO 0) <= GPIO_DIP_SW;
          sram_flash_d_res_oe <= '1';
          cur_state <= WRITE;
        WHEN WRITE =>                   -- Set data bus to High Z
          sram_flash_d_res_oe <= '0';
          -- Give read command
          cur_state <= READ_CMD;
          sram_cs_b_reg <= '0';               -- Enable command
          sram_flash_we_b_reg <= '1';         -- Enable read
        WHEN READ_CMD =>                -- Disable chip commands
          sram_cs_b_reg <= '1';
          cur_state <= READ_WAIT;
        WHEN READ_WAIT =>
          cur_state <= READ;
        WHEN READ =>                    -- Save value on the data bus to the
                                        -- LED reg
          gpio_led_reg <= SRAM_FLASH_D_RES(7 DOWNTO 0);
          cur_state <= IDLE;
        WHEN OTHERS => NULL;
      END CASE;
    END IF;
  END IF;
END PROCESS;
end Behavioral;

