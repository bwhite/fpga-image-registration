----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:20:41 03/20/2009 
-- Design Name: 
-- Module Name:    demo_low_level_tld - Behavioral 
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


ENTITY demo_low_level_tld IS
  GENERIC (
    IMGSIZE_BITS : integer := 10;
    PIXEL_BITS   : integer := 9);
  PORT (CLK_P : IN std_logic;
        CLK_N : IN std_logic;

        -- IO
        RST      : IN std_logic;
        GPIO_SW  : IN std_logic_vector(4 DOWNTO 0);
        GPIO_DIP : IN std_logic_vector(7 DOWNTO 0);

        -- I2C Signals
        I2C_SDA : OUT std_logic;
        I2C_SCL : OUT std_logic;

        -- DVI Signals
        DVI_D       : OUT std_logic_vector (11 DOWNTO 0);
        DVI_H       : OUT std_logic;
        DVI_V       : OUT std_logic;
        DVI_DE      : OUT std_logic;
        DVI_XCLK_N  : OUT std_logic;
        DVI_XCLK_P  : OUT std_logic;
        DVI_RESET_B : OUT std_logic;

        -- VGA Chip connections
        VGA_PIXEL_CLK : IN std_logic;
        VGA_Y_GREEN   : IN std_logic_vector (7 DOWNTO 0);
        VGA_HSYNC     : IN std_logic;
        VGA_VSYNC     : IN std_logic;

        -- SRAM Connections
        SRAM_CLK_FB : IN    std_logic;
        SRAM_CLK    : OUT   std_logic;
        SRAM_ADDR   : OUT   std_logic_vector (17 DOWNTO 0);
        SRAM_WE_B   : OUT   std_logic;
        SRAM_BW_B   : OUT   std_logic_vector (3 DOWNTO 0);
        SRAM_CS_B   : OUT   std_logic;
        SRAM_OE_B   : OUT   std_logic;
        SRAM_DATA   : INOUT std_logic_vector (35 DOWNTO 0)
        );
END demo_low_level_tld;



ARCHITECTURE Behavioral OF demo_low_level_tld IS
COMPONENT demo_low_level IS
  GENERIC (
    IMGSIZE_BITS : integer := 10;
    PIXEL_BITS   : integer := 9);
  PORT (CLK_P : IN std_logic;
        CLK_N : IN std_logic;

        -- IO
        RST      : IN std_logic;
        GPIO_SW  : IN std_logic_vector(4 DOWNTO 0);
        GPIO_DIP : IN std_logic_vector(7 DOWNTO 0);

        -- I2C Signals
        I2C_SDA : OUT std_logic;
        I2C_SCL : OUT std_logic;

        -- DVI Signals
        DVI_D       : OUT std_logic_vector (11 DOWNTO 0);
        DVI_H       : OUT std_logic;
        DVI_V       : OUT std_logic;
        DVI_DE      : OUT std_logic;
        DVI_XCLK_N  : OUT std_logic;
        DVI_XCLK_P  : OUT std_logic;
        DVI_RESET_B : OUT std_logic;

        -- VGA Chip connections
        VGA_PIXEL_CLK : IN std_logic;
        VGA_Y_GREEN   : IN std_logic_vector (7 DOWNTO 0);
        VGA_HSYNC     : IN std_logic;
        VGA_VSYNC     : IN std_logic;

        -- SRAM Connections
        SRAM_CLK_FB : IN    std_logic;
        SRAM_CLK    : OUT   std_logic;
        SRAM_ADDR   : OUT   std_logic_vector (17 DOWNTO 0);
        SRAM_WE_B   : OUT   std_logic;
        SRAM_BW_B   : OUT   std_logic_vector (3 DOWNTO 0);
        SRAM_CS_B   : OUT   std_logic;
        SRAM_OE_B   : OUT   std_logic;
        SRAM_DATA_I : IN std_logic_vector (35 DOWNTO 0);
        SRAM_DATA_O : OUT std_logic_vector (35 DOWNTO 0);
        SRAM_DATA_T : OUT std_logic

        -- Output Signals
--        H_0_0_O      : OUT std_logic_vector(29 DOWNTO 0);
--        H_0_1_O      : OUT std_logic_vector(29 DOWNTO 0);
--        H_0_2_O      : OUT std_logic_vector(29 DOWNTO 0);
--        H_1_0_O      : OUT std_logic_vector(29 DOWNTO 0);
--        H_1_1_O      : OUT std_logic_vector(29 DOWNTO 0);
--        H_1_2_O      : OUT std_logic_vector(29 DOWNTO 0);
--        BUSY : OUT std_logic
        );
END COMPONENT;
  
SIGNAL sram_data_i_wire,sram_data_o_wire : std_logic_vector(35 DOWNTO 0);
SIGNAL sram_data_t_wire : std_logic;

BEGIN

  
demo_low_level_i : demo_low_level
  PORT MAP (
    CLK_P => CLK_P,
    CLK_N => CLK_N,
    RST => RST,
    GPIO_SW => GPIO_SW,
    GPIO_DIP => GPIO_DIP,
    I2C_SDA => I2C_SDA,
    I2C_SCL => I2C_SCL,
    DVI_D => DVI_D,
    DVI_H => DVI_H,
    DVI_V => DVI_V,
    DVI_DE => DVI_DE,
    DVI_XCLK_N => DVI_XCLK_N,
    DVI_XCLK_P => DVI_XCLK_P,
    DVI_RESET_B => DVI_RESET_B,
    VGA_PIXEL_CLK => VGA_PIXEL_CLK,
    VGA_Y_GREEN => VGA_Y_GREEN,
    VGA_HSYNC => VGA_HSYNC,
    VGA_VSYNC => VGA_VSYNC,
    SRAM_CLK_FB => SRAM_CLK_FB,
    SRAM_CLK => SRAM_CLK,
    SRAM_ADDR => SRAM_ADDR,
    SRAM_WE_B => SRAM_WE_B,
    SRAM_BW_B => SRAM_BW_B,
    SRAM_CS_B => SRAM_CS_B,
    SRAM_OE_B => SRAM_OE_B,
    SRAM_DATA_I => sram_data_i_wire,
    SRAM_DATA_O => sram_data_o_wire,
    SRAM_DATA_T => sram_data_t_wire);

    sram_data_i_wire <= SRAM_DATA;
    PROCESS (sram_data_t_wire,sram_data_o_wire) IS
    BEGIN  -- PROCESS
      IF sram_data_t_wire='1' THEN
        SRAM_DATA <= sram_data_o_wire; 
      ELSE
        SRAM_DATA <= (OTHERS => 'Z');
      END IF;
    END PROCESS;
END Behavioral;

