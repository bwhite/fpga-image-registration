----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:05:10 03/01/2008 
-- Design Name: 
-- Module Name:    vga_rgb_buffer_to_dvi - Behavioral 
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

entity vga_rgb_buffer_to_dvi is
    Port ( VGA_PIXEL_CLK : in  STD_LOGIC;
           DVI_PIXEL_CLK : in  STD_LOGIC;
           VGA_R : in  STD_LOGIC;
           VGA_G : in  STD_LOGIC;
           VGA_B : in  STD_LOGIC;
           VGA_VSYNC : in  STD_LOGIC);
end vga_rgb_buffer_to_dvi;

architecture Behavioral of vga_rgb_buffer_to_dvi is

begin


end Behavioral;

