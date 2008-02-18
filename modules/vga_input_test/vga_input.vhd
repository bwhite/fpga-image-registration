







----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:28:04 01/30/2008 
-- Design Name: 
-- Module Name:    vga_input - Behavioral 
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
USE IEEE.numeric_std.ALL;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY vga_input IS
  PORT (CLK : IN std_logic;
        --RST : IN std_logic;

        -- VGA Chip connections
        VGA_PIXEL_CLK  : IN  std_logic;
        VGA_Y          : IN  std_logic_vector (7 DOWNTO 0);
        VGA_HSYNC      : IN  std_logic;
        VGA_VSYNC      : IN  std_logic;
        VGA_ODD_EVEN_B : IN  std_logic;
        VGA_SOGOUT     : IN  std_logic;
        VGA_CLAMP      : IN  std_logic;
        VGA_COAST      : IN  std_logic;
        I2C_SDA        : OUT std_logic;
        I2C_SCL        : OUT std_logic;
        -- Dummy Chipscope outputs
        PIX_CLK        : OUT std_logic;
        Y              : OUT std_logic_vector (7 DOWNTO 0);
        HSYNC          : OUT std_logic;
        VSYNC          : OUT std_logic;
        ODD_EVEN_B     : OUT std_logic;
        SOGOUT         : OUT std_logic;
        CLAMP          : OUT std_logic;
        COAST          : OUT std_logic);
END vga_input;

ARCHITECTURE Behavioral OF vga_input IS
  COMPONENT i2c_core IS
    PORT (clk           : IN  std_logic;
          data          : IN  std_logic_vector (23 DOWNTO 0);
          new_data      : IN  std_logic;
          reset         : IN  std_logic;
          i2c_sda       : OUT std_logic;
          i2c_scl       : OUT std_logic;
          received_data : OUT std_logic);
  END COMPONENT;
  SIGNAL received_data : std_logic;
  SIGNAL new_data      : std_logic                     := '0';
  SIGNAL data_count    : unsigned(2 DOWNTO 0)          := (OTHERS => '0');  -- Used to count the data
  SIGNAL i2c_data      : std_logic_vector(23 DOWNTO 0);
                                        -- bytes sent over I2C
  SIGNAL i2c_clk       : std_logic;     -- 50Mhz i2c module input clock
  SIGNAL i2c_dcm_fb    : std_logic;
BEGIN
  PROCESS (data_count) IS
  BEGIN  -- PROCESS
    CASE data_count IS
      WHEN "000" =>
        i2c_data <= std_logic_vector(to_unsigned(16#320198#, 24));
      WHEN "001" =>
        i2c_data <= std_logic_vector(to_unsigned(16#000298#, 24));
      WHEN "010" =>
        i2c_data <= std_logic_vector(to_unsigned(16#600398#, 24));
      --WHEN "011" =>
      --  i2c_data <= std_logic_vector(to_unsigned(16#A81298#, 24));
      --WHEN "100" =>
      --  i2c_data <= std_logic_vector(to_unsigned(16#7A1D98#, 24));
      --  i2c_data <= std_logic_vector(to_unsigned(16#DC1498#, 24));
      WHEN OTHERS =>
        i2c_data <= (OTHERS => '0');
                     
    END CASE;
  END PROCESS;
  
  -- DCM to divide input clock (200 mhz) by 16 to produce a 12.5 Mhz I2C Input
  -- clock (which will be divided by 500 for the SCL clock and 100 for the
  -- internal clock)
  -- controller input
  DCM_BASE_inst : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 2.0,  -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE          => 32,       -- Can be any interger from 1 to 32
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
      CLK0  => i2c_dcm_fb,              -- 0 degree DCM CLK ouptput
      --CLK180 => CLK180,     -- 180 degree DCM CLK output
      --CLK270 => CLK270,     -- 270 degree DCM CLK output
      --CLK2X => CLK2X,       -- 2X DCM CLK output
      --CLK2X180 => CLK2X180, -- 2X, 180 degree DCM CLK out
      --CLK90 => CLK90,       -- 90 degree DCM CLK output
      --CLKDV => CLKDV,       -- Divided DCM CLK out (CLKDV_DIVIDE)
      CLKFX => i2c_clk,                 -- DCM CLK synthesis out (M/D)
      -- CLKFX180 => CLKFX180, -- 180 degree CLK synthesis out
      --   LOCKED => LOCKED,     -- DCM LOCK status output
      CLKFB => i2c_dcm_fb,              -- DCM clock feedback
      CLKIN => CLK,                -- Clock input (from IBUFG, BUFG or DCM)
      RST   => '0'                      -- DCM asynchronous reset input
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
        new_data <= '0';
        IF data_count < 2 THEN          -- Prevents overflow
          data_count <= data_count + 1;
        ELSE
          data_count <= (OTHERS => '0');
        END IF;
      END IF;
    END IF;
  END PROCESS;

  PIX_CLK    <= VGA_PIXEL_CLK;
  Y          <= VGA_Y;
  HSYNC      <= VGA_HSYNC;
  VSYNC      <= VGA_VSYNC;
  ODD_EVEN_B <= VGA_ODD_EVEN_B;
  SOGOUT     <= VGA_SOGOUT;
  CLAMP      <= VGA_CLAMP;
  COAST      <= VGA_COAST;

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

