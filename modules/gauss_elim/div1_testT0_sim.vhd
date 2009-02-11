LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY div1_testT0_sim IS
END div1_testT0_sim;
ARCHITECTURE behavior OF div1_testT0_sim IS
  COMPONENT div1_testT0_tb
  PORT(
    CLK : IN STD_LOGIC;
    RST : IN STD_LOGIC;
    DONE : OUT STD_LOGIC;
    FAIL : OUT STD_LOGIC;
    FAIL_NUM : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
  END COMPONENT;
  SIGNAL CLK : STD_LOGIC := '0';
  SIGNAL RST : STD_LOGIC := '1';
  SIGNAL done, fail : STD_LOGIC;
  SIGNAL fail_num : STD_LOGIC_VECTOR(6 DOWNTO 0);
BEGIN
  uut :  div1_testT0_tb PORT MAP (
    CLK => clk,
    RST => rst,
    DONE => done,
    FAIL => fail,
    FAIL_NUM => fail_num
  );
  PROCESS
  BEGIN
    CLK <= '0';
    WAIT FOR 5ns;
    CLK <= '1';
    WAIT FOR 5ns;
    CLK <= '0';
    WAIT FOR 5ns;
    CLK <= '1';
    WAIT FOR 5ns;
    RST <= '0';
  END PROCESS;
END;
