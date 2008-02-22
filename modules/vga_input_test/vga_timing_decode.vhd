----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:38:04 02/20/2008 
-- Design Name: 
-- Module Name:    vga_timing_decode - Behavioral 
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
USE ieee.numeric_std.ALL;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_timing_decode is
    Port ( PIXEL_CLK : in  STD_LOGIC;
           VSYNC : in  STD_LOGIC;
           HSYNC : in  STD_LOGIC;
           HCOUNT : out  STD_LOGIC_VECTOR(9 DOWNTO 0);
           VCOUNT : out  STD_LOGIC_VECTOR (9 DOWNTO 0));
end vga_timing_decode;

architecture Behavioral of vga_timing_decode is
SIGNAL hcount_reg,vcount_reg :unsigned(9 DOWNTO 0) := (OTHERS => '0');  -- Number of pixels after the negative edge of the H/VSYNC
SIGNAL prev_hsync : std_logic := '0';
BEGIN
  HCOUNT <= std_logic_vector(hcount_reg);
  VCOUNT <= std_logic_vector(vcount_reg);
PROCESS (PIXEL_CLK) IS
BEGIN  -- PROCESS 
  IF PIXEL_CLK'event AND PIXEL_CLK = '1' THEN
    prev_hsync <= HSYNC;
   IF HSYNC='1' THEN
     hcount_reg <= (OTHERS => '0');
     IF prev_hsync='0' THEN
       vcount_reg <= vcount_reg + 1;
     END IF;
   ELSE
     hcount_reg <= hcount_reg + 1;
   END if;
   IF VSYNC='1' THEN
     vcount_reg <= (OTHERS => '0');
   END IF;
  END IF;
END PROCESS;

end Behavioral;

