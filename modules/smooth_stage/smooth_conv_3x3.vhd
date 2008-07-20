----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:40:24 07/20/2008 
-- Design Name: 
-- Module Name:    smooth_conv_3x3 - Behavioral 
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

ENTITY smooth_conv_3x3 IS
  GENERIC (
    PIXEL_BITS : IN integer := 9);
  PORT (CLK          : IN  std_logic;
        RST          : IN  std_logic;
        INPUT_VALID  : IN  std_logic;
        -- 0:0:9
        IMG_0_0      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_0_1      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_0_2      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_1_0      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_1_1      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_1_2      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_2_0      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_2_1      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_2_2      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        OUTPUT_VALID : OUT std_logic;
        -- 0:0:9
        IMG_SMOOTH   : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0));
END smooth_conv_3x3;

ARCHITECTURE Behavioral OF smooth_conv_3x3 IS

BEGIN


END Behavioral;

