----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:07:49 01/16/2008 
-- Design Name: 
-- Module Name:    vhdl_controller_functional_test - Behavioral 
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
LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY vhdl_controller_functional_test IS
  PORT (CLK_P     : IN  std_logic;
        CLK_N     : IN  std_logic;
        RST       : IN  std_logic;      -- Active low reset

        -- SRAM Connections
        SRAM_CLK_FB     : IN    std_logic;
        SRAM_CLK        : OUT   std_logic;
        SRAM_ADV_LD_B   : OUT   std_logic;
        SRAM_ADDR       : OUT   std_logic_vector (17 DOWNTO 0);
        SRAM_WE_B       : OUT   std_logic;
        SRAM_BW_B       : OUT   std_logic_vector (3 DOWNTO 0);
        SRAM_CKE_B      : OUT   std_logic;  -- NOTE Unconnected for now
        SRAM_CS_B       : OUT   std_logic;
        SRAM_OE_B       : OUT   std_logic;
        SRAM_DATA       : INOUT std_logic_vector (35 DOWNTO 0);

        -- Psuedo IO Ports used to probe with Chipscope
        DATA_READ       : OUT   std_logic_vector (35 DOWNTO 0);
        DATA_READ_VALID : OUT   std_logic);
END vhdl_controller_functional_test;

ARCHITECTURE Behavioral OF vhdl_controller_functional_test IS
  COMPONENT zbt_controller IS
    PORT (CLK : IN std_logic;
          CLK_5x : IN std_logic;
          RST : IN std_logic;

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

  SIGNAL clk,clk_predcm,clk0_initial,clk_int,clk_int_5x,clk_intbuf,startup_dcm_rst,clk_buf,clk_0                        : std_logic;
  SIGNAL data_write                 : std_logic_vector (35 DOWNTO 0);
  SIGNAL we_b                       : std_logic;
  SIGNAL addr                       : std_logic_vector (17 DOWNTO 0);
  SIGNAL data_count                 : std_logic_vector(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL addr0, addr1               : std_logic_vector(17 DOWNTO 0);
  SIGNAL data0, data1, data2, data3 : std_logic_vector(35 DOWNTO 0);
BEGIN
  addr0 <= "001100111110110001";
  addr1 <= "100101110111100100";
  data0 <= "110001111111000000110001110110000001";  -- C7F031D81
  data1 <= "011101010001110111101001101101011010";  -- 751DE9B5A
  data2 <= "111110000101101000010101111000100111";  -- F85A15E27
  data3 <= "111010010101011010110001011010111110";  -- E956B16BE
  
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

  DCM_BASE_initial : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 2.0,  -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      -- 125 Mhz, 5/8, 8ns
      -- 100 Mhz, 4/8, 10ns
      CLKFX_DIVIDE          => 8,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 5,       -- Can be any integer from 2 to 32
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
      CLK0   => clk0_initial,           -- 0 degree DCM CLK ouptput
      --CLK180 => CLK180,     -- 180 degree DCM CLK output
      --CLK270 => CLK270,     -- 270 degree DCM CLK output
      --CLK2X => CLK2X,       -- 2X DCM CLK output
      --CLK2X180 => CLK2X180, -- 2X, 180 degree DCM CLK out
      --CLK90 => CLK90,       -- 90 degree DCM CLK output
      --CLKDV => CLKDV,       -- Divided DCM CLK out (CLKDV_DIVIDE)
      CLKFX  => clk,                    -- DCM CLK synthesis out (M/D)
      --CLKFX180 => CLKFX180, -- 180 degree CLK synthesis out
      --LOCKED => initial_dll_locked,     -- DCM LOCK status output
      CLKFB  => clk0_initial,           -- DCM clock feedback
      CLKIN  => clk_predcm,        -- Clock input (from IBUFG, BUFG or DCM)
      RST    => '0'                     -- DCM asynchronous reset input
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
      I0      => clk,                   -- Clock0 input
      I1      => '0',                   -- Clock1 input
      IGNORE0 => '0',                   -- Ignore clock select0 input
      IGNORE1 => '0',                   -- Ignore clock select1 input
      S0      => '1',                   -- Clock select0 input
      S1      => '0'                    -- Clock select1 input
      );

-----------------------------------------------------------------------------
  --This shift register forces the DCM/DLL's to reset immediately after the fpga
  --is setup, this is to prevent the sram DCM from trying to lock before its
  --feedback pin is permitted to take current.
  SRL16_startup_rst : SRL16
    GENERIC MAP (
      INIT => X"FFFF")
    PORT MAP (
      Q   => startup_dcm_rst,           -- SRL data output
      A0  => '1',                       -- Select[0] input
      A1  => '1',                       -- Select[1] input
      A2  => '1',                       -- Select[2] input
      A3  => '1',                       -- Select[3] input
      CLK => clk_predcm,                -- Clock input
      D   => '0'                        -- SRL data input
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
      CLKIN_PERIOD          => 8.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
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
      CLK0   => clk_int,                -- 0 degree DCM CLK ouptput
      --CLK180 => CLK180,     -- 180 degree DCM CLK output
      --CLK270 => CLK270,     -- 270 degree DCM CLK output
      --CLK2X => CLK2X,       -- 2X DCM CLK output
      --CLK2X180 => CLK2X180, -- 2X, 180 degree DCM CLK out
      --CLK90 => CLK90,       -- 90 degree DCM CLK output
      --CLKDV => CLKDV,       -- Divided DCM CLK out (CLKDV_DIVIDE)
      CLKFX => clk_int_5x,       -- DCM CLK synthesis out (M/D)
      --CLKFX180 => CLKFX180, -- 180 degree CLK synthesis out
      --LOCKED => int_dll_locked,         -- DCM LOCK status output
      CLKFB  => clk_intbuf,             -- DCM clock feedback
      CLKIN  => clk_buf,           -- Clock input (from IBUFG, BUFG or DCM)
      RST    => startup_dcm_rst         -- DCM asynchronous reset input
      );
  BUFG_inst : BUFG
    PORT MAP (
      O => clk_intbuf,                  -- Clock buffer output
      I => clk_int                      -- Clock buffer input
      );


-----------------------------------------------------------------------------
  --This DLL is used to align the input clock to the child sram clock to
  --eliminate delay.


  DCM_BASE_sram : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 2.0,  -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE          => 4,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 3,       -- Can be any integer from 2 to 32
      CLKIN_DIVIDE_BY_2     => false,  -- TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD          => 8.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
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
      CLK0   => clk_0,                  -- 0 degree DCM CLK ouptput
      --CLK180 => CLK180,     -- 180 degree DCM CLK output
      --CLK270 => CLK270,     -- 270 degree DCM CLK output
      --CLK2X => CLK2X,       -- 2X DCM CLK output
      --CLK2X180 => CLK2X180, -- 2X, 180 degree DCM CLK out
      --CLK90 => CLK90,       -- 90 degree DCM CLK output
      --CLKDV => CLKDV,       -- Divided DCM CLK out (CLKDV_DIVIDE)
      --CLKFX => clk_0,       -- DCM CLK synthesis out (M/D)
      --CLKFX180 => CLKFX180, -- 180 degree CLK synthesis out
      --LOCKED => sram_dll_locked,        -- DCM LOCK status output
      CLKFB  => SRAM_CLK_FB,            -- DCM clock feedback
      CLKIN  => clk_buf,           -- Clock input (from IBUFG, BUFG or DCM)
      RST    => startup_dcm_rst         -- DCM asynchronous reset input
      );
  SRAM_CLK <= clk_0;

  zbt_controller_i : zbt_controller PORT MAP (
    CLK => clk_intbuf,
    CLK_5X => clk_int_5x,
    RST => NOT RST,

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
  
  PROCESS (clk_intbuf) IS
  BEGIN  -- PROCESS
    IF clk_intbuf'event AND clk_intbuf = '1' THEN     -- rising clock edge
      IF RST = '0' THEN                 -- synchronous reset (active low)
        data_count <= (OTHERS => '0');
      ELSE 
        data_count <= data_count + 1;
      END IF;
       CASE data_count IS
          WHEN "000" =>                 -- ADDR 0 - Write
            addr       <= addr0;
            data_write <= data0;
            we_b       <= '0';
          WHEN "001" =>                 -- ADDR 1 - Write
            addr       <= addr1;
            data_write <= data1;
            we_b       <= '0';
          WHEN "010" =>                 -- ADDR 0 - Read
            addr       <= addr0;
            data_write <= (OTHERS => '0');  -- During read, this shouldn't change anything
            we_b       <= '1';
          WHEN "011" =>                 -- ADDR 1 - Read
            addr       <= addr1;
            data_write <= (OTHERS => '1');  -- During read, this shouldn't change anything
            we_b       <= '1';
          WHEN "100" =>                 -- ADDR 0 - Write
            addr       <= addr0;
            data_write <= data2;
            we_b       <= '0';
          WHEN "101" =>                 -- ADDR 1 - Write
            addr       <= addr1;
            data_write <= data3;
            we_b       <= '0';
          WHEN "110" =>                 -- ADDR 0 - Read
            addr       <= addr0;
            data_write <= NOT data0;  -- During read, this shouldn't change anything
            we_b       <= '1';
          WHEN "111" =>                 -- ADDR 1 - Read
            addr       <= addr1;
            data_write <= NOT data0;  -- During read, this shouldn't change anything
            we_b       <= '1';
          WHEN OTHERS => NULL;
        END CASE;
    END IF;
  END PROCESS;

END Behavioral;

