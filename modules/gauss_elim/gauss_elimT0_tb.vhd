LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

LIBRARY UNIMACRO;
USE UNIMACRO.vcomponents.ALL;


ENTITY gauss_elimT0_tb IS
PORT(
  CLK : IN STD_LOGIC;
  RST : IN STD_LOGIC;
  DONE : OUT STD_LOGIC);
END gauss_elimT0_tb;
ARCHITECTURE behavior OF gauss_elimT0_tb IS
  COMPONENT gauss_elim
  PORT(
    CLK : IN STD_LOGIC;
    RST : IN STD_LOGIC;
    INPUT_LOAD : IN STD_LOGIC;
    A_0_0 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_0_1 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_0_2 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_0_3 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_0_4 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_0_5 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_1_0 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_1_1 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_1_2 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_1_3 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_1_4 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_1_5 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_2_0 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_2_1 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_2_2 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_2_3 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_2_4 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_2_5 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_3_0 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_3_1 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_3_2 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_3_3 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_3_4 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_3_5 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_4_0 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_4_1 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_4_2 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_4_3 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_4_4 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_4_5 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_5_0 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_5_1 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_5_2 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_5_3 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_5_4 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    A_5_5 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    B_0 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    B_1 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    B_2 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    B_3 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    B_4 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    B_5 : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
    X_0 : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    X_1 : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    X_2 : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    X_3 : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    X_4 : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    X_5 : OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
    OUTPUT_VALID : OUT STD_LOGIC);
  END COMPONENT;
  SIGNAL uut_rst_wire : STD_LOGIC;
  SIGNAL uut_rst : STD_LOGIC := '1';
  SIGNAL state : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  -- UUT Input
  SIGNAL uut_input_load : STD_LOGIC;
  SIGNAL uut_a_0_0, uut_a_0_1, uut_a_0_2, uut_a_0_3, uut_a_0_4, uut_a_0_5, uut_a_1_0, uut_a_1_1, uut_a_1_2, uut_a_1_3, uut_a_1_4, uut_a_1_5, uut_a_2_0, uut_a_2_1, uut_a_2_2, uut_a_2_3, uut_a_2_4, uut_a_2_5, uut_a_3_0, uut_a_3_1, uut_a_3_2, uut_a_3_3, uut_a_3_4, uut_a_3_5, uut_a_4_0, uut_a_4_1, uut_a_4_2, uut_a_4_3, uut_a_4_4, uut_a_4_5, uut_a_5_0, uut_a_5_1, uut_a_5_2, uut_a_5_3, uut_a_5_4, uut_a_5_5, uut_b_0, uut_b_1, uut_b_2, uut_b_3, uut_b_4, uut_b_5 : STD_LOGIC_VECTOR(26 DOWNTO 0);
  -- UUT Output
  SIGNAL uut_output_valid, clk_int : STD_LOGIC;
  SIGNAL uut_x_0, uut_x_1, uut_x_2, uut_x_3, uut_x_4, uut_x_5 : STD_LOGIC_VECTOR(26 DOWNTO 0);
BEGIN


  -- Buffer and Deskew SRAM CLK
  DCM_BASE_sram : DCM_BASE
    GENERIC MAP (
      CLKIN_PERIOD          => 10.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLKIN_DIVIDE_BY_2     => true,
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,  -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "LOW",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "LOW",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => clk_int,            -- 0 degree DCM CLK output
      CLKFB => clk_int,             -- DCM clock feedback
      CLKIN => CLK,            -- Clock input (from IBUFG, BUFG or DCM)
      RST   => '0'                  -- DCM asynchronous reset input
      );
  
  uut_rst_wire <= uut_rst;
  uut :  gauss_elim PORT MAP (
    CLK => clk_int,
    RST => uut_rst_wire,
    INPUT_LOAD => uut_input_load,
    A_0_0 => uut_a_0_0,
    A_0_1 => uut_a_0_1,
    A_0_2 => uut_a_0_2,
    A_0_3 => uut_a_0_3,
    A_0_4 => uut_a_0_4,
    A_0_5 => uut_a_0_5,
    A_1_0 => uut_a_1_0,
    A_1_1 => uut_a_1_1,
    A_1_2 => uut_a_1_2,
    A_1_3 => uut_a_1_3,
    A_1_4 => uut_a_1_4,
    A_1_5 => uut_a_1_5,
    A_2_0 => uut_a_2_0,
    A_2_1 => uut_a_2_1,
    A_2_2 => uut_a_2_2,
    A_2_3 => uut_a_2_3,
    A_2_4 => uut_a_2_4,
    A_2_5 => uut_a_2_5,
    A_3_0 => uut_a_3_0,
    A_3_1 => uut_a_3_1,
    A_3_2 => uut_a_3_2,
    A_3_3 => uut_a_3_3,
    A_3_4 => uut_a_3_4,
    A_3_5 => uut_a_3_5,
    A_4_0 => uut_a_4_0,
    A_4_1 => uut_a_4_1,
    A_4_2 => uut_a_4_2,
    A_4_3 => uut_a_4_3,
    A_4_4 => uut_a_4_4,
    A_4_5 => uut_a_4_5,
    A_5_0 => uut_a_5_0,
    A_5_1 => uut_a_5_1,
    A_5_2 => uut_a_5_2,
    A_5_3 => uut_a_5_3,
    A_5_4 => uut_a_5_4,
    A_5_5 => uut_a_5_5,
    B_0 => uut_b_0,
    B_1 => uut_b_1,
    B_2 => uut_b_2,
    B_3 => uut_b_3,
    B_4 => uut_b_4,
    B_5 => uut_b_5,
    X_0 => uut_x_0,
    X_1 => uut_x_1,
    X_2 => uut_x_2,
    X_3 => uut_x_3,
    X_4 => uut_x_4,
    X_5 => uut_x_5,
    OUTPUT_VALID => uut_output_valid
  );
  PROCESS (clk_int) IS
  BEGIN
    IF clk_int'event AND clk_int='1' THEN
      
        CASE state IS
          WHEN "0000" =>
            uut_input_load <= '1';
            uut_a_0_0 <= "000000000000000000000000000";
            uut_a_0_1 <= "000000000000000000000000000";
            uut_a_0_2 <= "000000000000000000000000000";
            uut_a_0_3 <= "000000000000000000000000000";
            uut_a_0_4 <= "000000000000000000000000000";
            uut_a_0_5 <= "000000000000000000000000000";
            uut_a_1_0 <= "000000000000000000000000000";
            uut_a_1_1 <= "000000000000000000000000000";
            uut_a_1_2 <= "000000000000000000000000000";
            uut_a_1_3 <= "000000000000000000000000000";
            uut_a_1_4 <= "000000000000000000000000000";
            uut_a_1_5 <= "000000000000000000000000000";
            uut_a_2_0 <= "000000000000000000000000000";
            uut_a_2_1 <= "000000000000000000000000000";
            uut_a_2_2 <= "000000000000000000000000000";
            uut_a_2_3 <= "000000000000000000000000000";
            uut_a_2_4 <= "000000000000000000000000000";
            uut_a_2_5 <= "000000000000000000000000000";
            uut_a_3_0 <= "000000000000000000000000000";
            uut_a_3_1 <= "000000000000000000000000000";
            uut_a_3_2 <= "000000000000000000000000000";
            uut_a_3_3 <= "000000000000000000000000000";
            uut_a_3_4 <= "000000000000000000000000000";
            uut_a_3_5 <= "000000000000000000000000000";
            uut_a_4_0 <= "000000000000000000000000000";
            uut_a_4_1 <= "000000000000000000000000000";
            uut_a_4_2 <= "000000000000000000000000000";
            uut_a_4_3 <= "000000000000000000000000000";
            uut_a_4_4 <= "000000000000000000000000000";
            uut_a_4_5 <= "000000000000000000000000000";
            uut_a_5_0 <= "000000000000000000000000000";
            uut_a_5_1 <= "000000000000000000000000000";
            uut_a_5_2 <= "000000000000000000000000000";
            uut_a_5_3 <= "000000000000000000000000000";
            uut_a_5_4 <= "000000000000000000000000000";
            uut_a_5_5 <= "000000000000000000000000000";
            uut_b_0 <= "000000000000000000000000000";
            uut_b_1 <= "000000000000000000000000000";
            uut_b_2 <= "000000000000000000000000000";
            uut_b_3 <= "000000000000000000000000000";
            uut_b_4 <= "000000000000000000000000000";
            uut_b_5 <= "000000000000000000000000000";
            state <= "0001";
            uut_rst <= '1';
          WHEN "0001" =>
            uut_input_load <= '1';

            state <= "0010";
            uut_rst <= '0';
          WHEN "0010" =>
            uut_input_load <= '1';
            state <= "0011";
            uut_rst <= '0';
          WHEN "0011" =>
            uut_input_load <= '1';
            state <= "0100";
            uut_rst <= '0';
          WHEN "0100" =>
            uut_input_load <= '1';
            state <= "0101";
            uut_rst <= '0';
          WHEN "0101" =>
            uut_input_load <= '1';
            state <= "0110";
            uut_rst <= '0';
          WHEN "0110" =>
            state <= "0111";
            uut_rst <= '0';
          WHEN "0111" =>
            state <= "1000";
            uut_rst <= '0';
          WHEN "1000" =>
            state <= "1001";
            uut_rst <= '0';
          WHEN "1001" =>
            state <= "1010";
            uut_rst <= '0';
          WHEN "1010" =>
            state <= "1011";
            uut_rst <= '0';
          WHEN "1011" =>
            state <= "1100";
            uut_rst <= '0';
          WHEN OTHERS =>
            DONE <= '1';
            uut_rst <= '0';
        END CASE;
    END IF;
  END PROCESS;
END;
