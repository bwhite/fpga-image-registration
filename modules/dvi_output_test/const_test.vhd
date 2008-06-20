----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:29:51 03/07/2008 
-- Design Name: 
-- Module Name:    const_test - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity const_test IS
    GENERIC (
      D : integer := 100;
      E : integer := -1);
    Port ( 
           C : out  STD_LOGIC);
end const_test;

architecture Behavioral of const_test is
CONSTANT F : integer := D+E;
begin
c <= '1' WHEN F<D ELSE '0';

end Behavioral;

