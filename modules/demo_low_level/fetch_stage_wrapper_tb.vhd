--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:29:35 02/12/2009
-- Design Name:   
-- Module Name:   /home/brandyn/fpga-image-registration/modules/demo_low_level/fetch_stage_wrapper_tb.vhd
-- Project Name:  demo_low_level
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fetch_stage_wrapper
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
 
ENTITY fetch_stage_wrapper_tb IS
END fetch_stage_wrapper_tb;
 
ARCHITECTURE behavior OF fetch_stage_wrapper_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fetch_stage_wrapper
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         IMG0_0_1 : OUT  std_logic_vector(8 downto 0);
         IMG0_1_0 : OUT  std_logic_vector(8 downto 0);
         IMG0_1_1 : OUT  std_logic_vector(8 downto 0);
         IMG0_1_2 : OUT  std_logic_vector(8 downto 0);
         IMG0_2_1 : OUT  std_logic_vector(8 downto 0);
         IMG1_1_1 : OUT  std_logic_vector(8 downto 0);
         TRANS_X_COORD : OUT  std_logic_vector(11 downto 0);
         TRANS_Y_COORD : OUT  std_logic_vector(11 downto 0);
         OUTPUT_VALID : OUT  std_logic;
         DONE : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';

 	--Outputs
   signal IMG0_0_1 : std_logic_vector(8 downto 0);
   signal IMG0_1_0 : std_logic_vector(8 downto 0);
   signal IMG0_1_1 : std_logic_vector(8 downto 0);
   signal IMG0_1_2 : std_logic_vector(8 downto 0);
   signal IMG0_2_1 : std_logic_vector(8 downto 0);
   signal IMG1_1_1 : std_logic_vector(8 downto 0);
   signal TRANS_X_COORD : std_logic_vector(11 downto 0);
   signal TRANS_Y_COORD : std_logic_vector(11 downto 0);
   signal OUTPUT_VALID : std_logic;
   signal DONE : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fetch_stage_wrapper PORT MAP (
          CLK => CLK,
          RST => RST,
          IMG0_0_1 => IMG0_0_1,
          IMG0_1_0 => IMG0_1_0,
          IMG0_1_1 => IMG0_1_1,
          IMG0_1_2 => IMG0_1_2,
          IMG0_2_1 => IMG0_2_1,
          IMG1_1_1 => IMG1_1_1,
          TRANS_X_COORD => TRANS_X_COORD,
          TRANS_Y_COORD => TRANS_Y_COORD,
          OUTPUT_VALID => OUTPUT_VALID,
          DONE => DONE
        );
 
   -- No clocks detected in port list. Replace below with 
   -- appropriate port name 
 
 
   clk_process :process
   begin
		clk <= '0';
		wait for 1ns;
		clk <= '1';
		wait for 1ns;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
     RST <= '1';
      wait for 10ns;	
     RST <= '0';
      wait for 10ns;

      -- insert stimulus here 

      wait;
   end process;

END;
