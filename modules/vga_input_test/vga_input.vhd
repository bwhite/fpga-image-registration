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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY vga_input IS
  PORT (CLK  : IN std_logic;
         RST : IN std_logic;

         -- VGA Chip connections
         VGA_PIXEL_CLK : IN std_logic;
         VGA_Y         : IN std_logic_vector (7 DOWNTO 0);
         VGA_HSYNC     : IN std_logic;
         VGA_VSYNC     : IN std_logic;
         VGA_ODD_EVEN_B: IN std_logic;
         VGA_SOGOUT : IN std_logic;
         VGA_CLAMP : IN std_logic;
         VGA_COAST : IN std_logic;
         -- Dummy Chipscope outputs
         PIX_CLK : OUT std_logic;
         Y       : OUT std_logic_vector (7 DOWNTO 0);
         HSYNC   : OUT std_logic;
         VSYNC   : OUT std_logic;
         ODD_EVEN_B: OUT std_logic;
         SOGOUT : OUT std_logic;
        CLAMP : OUT std_logic;
        COAST : OUT std_logic);
END vga_input;

ARCHITECTURE Behavioral OF vga_input IS

BEGIN
PIX_CLK <= VGA_PIXEL_CLK;
Y <= VGA_Y;
HSYNC <= VGA_HSYNC;
VSYNC <= VGA_VSYNC;
ODD_EVEN_B <= VGA_ODD_EVEN_B;
SOGOUT <= VGA_SOGOUT;
CLAMP <= VGA_CLAMP;
COAST <= VGA_COAST;
END Behavioral;

