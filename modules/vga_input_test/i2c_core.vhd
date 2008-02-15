----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:22:35 09/02/2007 
-- Design Name: 
-- Module Name:    i2c_core - Behavioral 
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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY i2c_core IS
  PORT (clk            : IN  std_logic;
         data          : IN  std_logic_vector (23 DOWNTO 0);
         new_data      : IN  std_logic;
         reset         : IN  std_logic;
         i2c_sda       : OUT std_logic;
         i2c_scl       : OUT std_logic;
         received_data : OUT std_logic);
END i2c_core;

ARCHITECTURE Behavioral OF i2c_core IS
  SIGNAL cur_data          : std_logic_vector (23 DOWNTO 0);  -- {device_id(7 downto 0), address(7 downto 0), data(7 downto 0)}
  SIGNAL i2c_state         : std_logic_vector (2 DOWNTO 0) := (OTHERS => '0');  -- {START, DATA, POST_DATA, STOP, STOP_WAIT, X, X, X}
  SIGNAL byte_position     : std_logic_vector(1 DOWNTO 0)  := (OTHERS => '0');  -- {device_id, address, data, X}
  SIGNAL bit_position      : std_logic_vector(2 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL received_data_reg : std_logic                     := '0';
  SIGNAL i2c_sda_reg       : std_logic                     := '1';

-- I2C Clock Variables
  SIGNAL i2c_clock_counter    : std_logic_vector (8 DOWNTO 0) := (OTHERS => '0');  -- [0,499]
  SIGNAL i2c_edge_count       : std_logic_vector (2 DOWNTO 0) := (OTHERS => '0');  -- [0,4]
  SIGNAL i2c_clock            : std_logic                     := '1';
  SIGNAL i2c_clock_5x         : std_logic                     := '1';
  SIGNAL i2c_clock_5x_posedge : std_logic                     := '1';

BEGIN
  i2c_scl       <= '0' WHEN i2c_clock = '0'   ELSE 'Z';  -- Output using {0,Z logic}
  i2c_sda       <= '0' WHEN i2c_sda_reg = '0' ELSE 'Z';  -- Output using {0,Z logic}
  received_data <= received_data_reg;

  PROCESS(clk)
  BEGIN
    IF (clk'event AND clk = '1') THEN
      -- Set initial register values upon synchronous reset
      IF (reset = '1') THEN
        i2c_state         <= (OTHERS => '0');
        byte_position     <= (OTHERS => '0');
        bit_position      <= (OTHERS => '0');
        received_data_reg <= '0';
        i2c_sda_reg       <= '1';

        -- I2C Clock Variables
        i2c_clock_counter    <= (OTHERS => '0');
        i2c_edge_count       <= (OTHERS => '0');
        i2c_clock            <= '1';
        i2c_clock_5x         <= '1';
        i2c_clock_5x_posedge <= '1';
      ELSE
        -- If we are supposed to start; however, no data is ready, then reset the clock logic to hold it high
        IF (i2c_state = "000" AND new_data='0') THEN
          i2c_sda_reg       <= '1';
          received_data_reg <= '0';

                                        -- I2C Clock Variables
          i2c_clock_counter    <= (OTHERS => '0');
          i2c_edge_count       <= (OTHERS => '0');
          i2c_clock            <= '1';
          i2c_clock_5x         <= '1';
          i2c_clock_5x_posedge <= '1';
        ELSE
                                        -- I2C Clock generation - Reduces clock rate by 100 for internal use and 500 for external use.
          IF (i2c_clock_counter = 99 OR i2c_clock_counter = 199 OR i2c_clock_counter = 299 OR i2c_clock_counter = 399 OR i2c_clock_counter = 499) THEN
            i2c_clock_5x <= NOT i2c_clock_5x;
            IF (i2c_clock_5x = '0') THEN
              i2c_clock_5x_posedge <= '1';
              IF (i2c_edge_count < 4) THEN
                i2c_edge_count <= i2c_edge_count + 1;
              ELSE
                i2c_edge_count <= (OTHERS => '0');
              END IF;
            END IF;
          END IF;

                                        -- Toggle the external I2C clock every 500 ticks
          IF (i2c_clock_counter = 499) THEN
            i2c_clock_counter <= (OTHERS => '0');
            i2c_clock         <= NOT i2c_clock;
          ELSE
            i2c_clock_counter <= i2c_clock_counter + 1;
          END IF;
          
        END IF;

        -- Main I2C Logic
        IF (i2c_clock_5x_posedge = '1') THEN
          i2c_clock_5x_posedge <= '0';
          CASE i2c_edge_count IS  -- Edge selection -> individual state selection
            WHEN "001" =>
              IF (i2c_state = "011") THEN      -- STATE: stop
                i2c_sda_reg <= '1';
                i2c_state   <= "000";   -- 'start'
              END IF;
            WHEN "010" =>
              IF (i2c_state = "000") THEN      -- STATE: start
                IF (new_data = '1' AND received_data_reg = '0') THEN
                  i2c_sda_reg       <= '0';
                  cur_data          <= data;
                  received_data_reg <= '1';
                  i2c_state         <= "001";  -- 'data'
                END IF;
              END IF;

            WHEN "100" =>
              CASE i2c_state IS
                WHEN "001" =>           -- STATE: data
                  CASE bit_position IS  -- Select bit position and output it (NOTE:  MSB is output first!), TODO investigate other bit selection methods
                    WHEN "000" =>
                      i2c_sda_reg <= cur_data(7);
                    WHEN "001" =>
                      i2c_sda_reg <= cur_data(6);
                    WHEN "010" =>
                      i2c_sda_reg <= cur_data(5);
                    WHEN "011" =>
                      i2c_sda_reg <= cur_data(4);
                    WHEN "100" =>
                      i2c_sda_reg <= cur_data(3);
                    WHEN "101" =>
                      i2c_sda_reg <= cur_data(2);
                    WHEN "110" =>
                      i2c_sda_reg <= cur_data(1);
                    WHEN "111" =>
                      i2c_sda_reg <= cur_data(0);
                    WHEN OTHERS =>
                      i2c_sda_reg <= 'X';
                  END CASE;
                      bit_position <= bit_position + 1;
                      IF (bit_position = "111") THEN
                        i2c_state <= "010";  -- 'post_data'
                      ELSE
                        i2c_state <= "001";  -- 'data'
                      END IF;
                WHEN "010" =>           -- STATE: post_data
                  cur_data(15 DOWNTO 0) <= cur_data(23 DOWNTO 8);  -- Shift right by 8, TODO investigate other shifting methods
                  i2c_sda_reg           <= '1';
                  IF (byte_position = 2) THEN
                    byte_position <= (OTHERS => '0');
                    i2c_state     <= "100";
                  ELSE
                    byte_position <= byte_position + 1;
                    i2c_state     <= "001";
                  END IF;
                WHEN "100" =>           -- STATE: stop_wait
                  i2c_sda_reg <= '0';
                  i2c_state   <= "011";      -- 'stop'
                WHEN OTHERS =>
                  NULL;
              END CASE;
            WHEN OTHERS =>
              NULL;
          END CASE;
        END IF;

        -- Data synchronization acknowledgement
        IF (new_data = '0' AND received_data_reg = '1') THEN
          received_data_reg <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

