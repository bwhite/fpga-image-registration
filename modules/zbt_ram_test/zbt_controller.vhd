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
--    RST : IN std_logic;

    --Connections to misc board devices
    FPGA_ROTARY : IN  std_logic_vector (2 DOWNTO 0);
    GPIO_SW     : IN  std_logic_vector (4 DOWNTO 0);
    GPIO_DIP_SW : IN  std_logic_vector (7 DOWNTO 0);
    GPIO_LED    : OUT std_logic_vector (7 DOWNTO 0);

    -- Connections to SRAM
    SRAM_CS_B        : OUT   std_logic;
    SRAM_BW_B          : OUT   std_logic_vector (3 DOWNTO 0);
    SRAM_ADV_LD_B    : OUT   std_logic;
    SRAM_OE_B        : OUT   std_logic;
    SRAM_WE_B  : OUT   std_logic;
    SRAM_CLK         : OUT   std_logic;
   -- SRAM_CLK_FB : IN std_logic;
    SRAM_A     : OUT   std_logic_vector (17 DOWNTO 0);
    -- SRAM_DQP         : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
    SRAM_D           : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);--(31 DOWNTO 0);--(15 DOWNTO 0);
    SRAM_FLASH_D_OUT : OUT   std_logic_vector(7 DOWNTO 0));
    --SRAM_FLASH_D     : INOUT std_logic_vector (7 DOWNTO 0));
  -- (15 DOWNTO 0));
END zbt_controller;

ARCHITECTURE Behavioral OF zbt_controller IS
  TYPE   ZBT_STATE IS (IDLE, WRITE_START, WRITE_CMD, WRITE_WAIT, WRITE, READ_START, READ_CMD, READ_WAIT, READ);
                                        -- This is the type that defines the possible states the system can be in.
  SIGNAL RST : std_logic;
                                        
  SIGNAL cur_state           : ZBT_STATE                     := IDLE;  -- Current system state
  SIGNAL cur_addr            : unsigned (1 DOWNTO 0)         := (OTHERS => '0');  --(17 DOWNTO 0) := (OTHERS => '0');
  SIGNAL sram_flash_we_b_reg : std_logic                     := '1';
  SIGNAL sram_cs_b_reg       : std_logic                     := '1';
  SIGNAL gpio_led_reg        : std_logic_vector (7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL initial_read        : std_logic                     := '0';
                                                                      -- This is 1 if the initial read has occured to set gpio_led_reg
  SIGNAL sram_flash_d_reg    : std_logic_vector (7 DOWNTO 0) := (OTHERS => '0');
                                                                      -- This is a reg for the used portion of the sram_flash_d_res input, it is used to enable tri-state output on the register
  SIGNAL sram_flash_d_oe_b   : std_logic                     := '0';
                                                                      -- This is a register that determines if the sram_flash_d_reg is connected to the inout port, or floated
  SIGNAL user_input_enable   : std_logic                     := '1';  -- This is a trivial way to fix button bouncing, after each command, require that a dedicated button be pressed to allow input to occur again.
-- TODO generate SRAM_CLK from input clock, use it for all processing in this
-- module;
BEGIN
  RST <= '1';
  SRAM_BW_B          <= "0000";
  SRAM_ADV_LD_B    <= '0';
  SRAM_A     <= ("0000000000000000"&std_logic_vector(cur_addr));
  SRAM_WE_B  <= sram_flash_we_b_reg;
  SRAM_CS_B        <= sram_cs_b_reg;
  GPIO_LED         <= gpio_led_reg;
  SRAM_CLK         <= CLK;
  SRAM_FLASH_D_OUT <= SRAM_D(7 DOWNTO 0);

-- purpose: This determines if the sram_flash_d_reg is connected to the inout
-- port
-- type   : combinational
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

-- Currently Implemented Method
-- Only uses the lower 8 bits to store the data in it.

  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '0' THEN                 -- synchronous reset (active low)
        cur_addr          <= (OTHERS => '0');
        initial_read      <= '0';
        cur_state         <= IDLE;
        sram_cs_b_reg     <= '1';
        sram_flash_d_oe_b <= '1';
        SRAM_OE_B         <= '1';       -- Disable SRAM output
        user_input_enable <= '1';
      ELSE
        -------------------------------------------------------------------------
        -- This state machine is written to account for the register delay by
        -- setting values one CT before hand, that is why semantically these seem
        -- ahead (by their name).  Before the states are entered, the expected
        -- preconditions must be satisfied.
        ZBT_FSM : CASE cur_state IS
          WHEN IDLE =>
            sram_flash_d_oe_b <= '1';   -- Set ALL used data reg lines to
                                        -- High Z when they are not to
                                        -- be written TO
            IF GPIO_SW(3) = '0' THEN
              sram_cs_b_reg <= '1';
              SRAM_OE_B     <= '1';     -- Disable SRAM output
            ELSE
              SRAM_OE_B     <= '0';
              sram_cs_b_reg <= '0';
            END IF;


            -------------------------------------------------------------------------
            -- This is the main control structure for user input and state initialization
            control : IF initial_read = '0' THEN
              initial_read <= '1';
              cur_state    <= READ_START;
            ELSIF user_input_enable = '1' THEN
              cmd_input : IF FPGA_ROTARY(0) = '1' THEN
                user_input_enable <= '0';
                cur_addr          <= cur_addr - 1;  -- Dec
                cur_state         <= READ_START;
              ELSIF FPGA_ROTARY(1) = '1' THEN
                user_input_enable <= '0';
                cur_addr          <= cur_addr + 1;  -- Inc
                cur_state         <= READ_START;
              ELSIF FPGA_ROTARY(2) = '1' THEN    -- Save
                user_input_enable <= '0';
                cur_state         <= WRITE_START;
              ELSIF GPIO_SW(0) = '1' THEN
                user_input_enable <= '0';
                cur_addr          <= (OTHERS => '0');
                cur_state         <= READ_START;
              ELSIF GPIO_SW(1) = '1' THEN
                user_input_enable <= '0';
                cur_state         <= READ_START;
              ELSIF GPIO_SW(2) = '1' THEN
                user_input_enable <= '0';
                cur_addr          <= (OTHERS => '1');
                cur_state         <= READ_START;
              END IF;
            ELSIF GPIO_SW(4) = '1' THEN
              user_input_enable <= '1';
            END IF;
          WHEN WRITE_START =>
            cur_state           <= WRITE_CMD;
            sram_cs_b_reg       <= '0';          -- Enable command
            sram_flash_we_b_reg <= '0';          -- Enable write
            sram_flash_d_oe_b   <= '0';          -- Enable data reg output
            SRAM_OE_B           <= '1';          -- Disable SRAM output
            sram_flash_d_reg    <= GPIO_DIP_SW;  -- Put DIP values on data bus
          WHEN WRITE_CMD =>
            sram_flash_we_b_reg <= '1';          -- Disable write (read mode)
            sram_cs_b_reg       <= '1';          -- Disable chip commands
            cur_state           <= WRITE_WAIT;
          WHEN WRITE_WAIT =>
            cur_state <= WRITE;
          WHEN WRITE =>
            --cur_state                    <= READ_START;
            cur_state <= IDLE;
            --sram_flash_d_reg <= (OTHERS => '0');  -- Clear sram data buffer
            --sram_flash_d_oe_b <= '1';   -- Disable data reg output
          WHEN READ_START =>
            cur_state           <= READ_CMD;
            sram_cs_b_reg       <= '0';          -- Enable command
            sram_flash_we_b_reg <= '1';          -- Enable read
            sram_flash_d_oe_b   <= '1';          -- Disable data reg output
            SRAM_OE_B           <= '0';          -- Enable SRAM output
          WHEN READ_CMD =>              -- Disable chip commands
            sram_cs_b_reg <= '1';
            cur_state     <= READ_WAIT;
          WHEN READ_WAIT =>
            cur_state <= READ;
          WHEN READ =>                  -- Save value on the data bus to the
                                        -- LED reg
            gpio_led_reg <= SRAM_D(7 DOWNTO 0);
            cur_state    <= IDLE;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

