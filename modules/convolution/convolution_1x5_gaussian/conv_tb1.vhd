
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:46:41 12/27/2007
-- Design Name:   convolution_1x5_gaussian
-- Module Name:   /home/brandyn/fpga_new/modules/convolution/convolution_1x5_gaussian/conv_tb1.vhd
-- Project Name:  convolution_1x5_gaussian
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: convolution_1x5_gaussian
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY conv_tb1_vhd IS
END conv_tb1_vhd;

ARCHITECTURE behavior OF conv_tb1_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT convolution_1d_linear_5x1
	PORT(
		CLK : IN std_logic;
                CLKEN : IN std_logic;
		RST : IN std_logic;
		DATA_IN : IN unsigned(11 downto 0);          
		DATA_OUT : OUT unsigned(11 downto 0);
		DATA_VALID : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL CLK :  std_logic := '0';
        SIGNAL CLKEN : std_logic := '1';
	SIGNAL RST :  std_logic := '0';
	SIGNAL DATA_IN :  unsigned(11 downto 0) := (others=>'0');

	--Outputs
	SIGNAL DATA_OUT :  unsigned(11 downto 0);
	SIGNAL DATA_VALID :  std_logic;

BEGIN
  CLK <= not CLK after 5 ns;
	-- Instantiate the Unit Under Test (UUT)
	uut: convolution_1d_linear_5x1 PORT MAP(
		CLK => CLK,
                CLKEN => CLKEN,
		RST => RST,
		DATA_IN => DATA_IN,
		DATA_OUT => DATA_OUT,
		DATA_VALID => DATA_VALID
	);

	tb : PROCESS
	BEGIN

		-- Wait 100 ns for global reset to finish
                RST <= '1';
                wait for 100 ns;
                RST <= '0';
                
		-- Place stimulus here
                DATA_IN <= X"66B";
                wait for 10 ns;
                DATA_IN <= X"5D4";
                wait for 10 ns;
                DATA_IN <= X"345";
                wait for 10 ns;
                DATA_IN <= X"7FC";
                wait for 10 ns;
                DATA_IN <= X"E98";
                wait for 10 ns;
                DATA_IN <= X"362";
                wait for 10 ns;
                DATA_IN <= X"2D4";
                wait for 10 ns;
                DATA_IN <= X"059";
                wait for 10 ns;
                DATA_IN <= X"6BC";
                wait for 10 ns;
                DATA_IN <= X"9FF";
                wait for 10 ns;
                DATA_IN <= X"F37";
                wait for 10 ns;
                DATA_IN <= X"15D";
                wait for 10 ns;
                DATA_IN <= X"927";
                wait for 10 ns;
                DATA_IN <= X"9ED";
                wait for 10 ns;
                DATA_IN <= X"21C";
                wait for 10 ns;
                DATA_IN <= X"98C";
                wait for 10 ns;
                DATA_IN <= X"2F5";
                wait for 10 ns;
                DATA_IN <= X"D50";
                wait for 10 ns;
                DATA_IN <= X"407";
                wait for 10 ns;
                DATA_IN <= X"520";
                wait for 10 ns;
                DATA_IN <= X"3FB";
                wait for 10 ns;
                DATA_IN <= X"5F6";
                wait for 10 ns;
                DATA_IN <= X"CAD";
                wait for 10 ns;
                DATA_IN <= X"B34";
                wait for 10 ns;
                DATA_IN <= X"85D";

                
		wait; -- will wait forever
	END PROCESS;

END;
