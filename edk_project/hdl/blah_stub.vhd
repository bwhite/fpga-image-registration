-------------------------------------------------------------------------------
-- blah_stub.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity blah_stub is
  port (
    fpga_0_RS232_Uart_1_RX_pin : in std_logic;
    fpga_0_RS232_Uart_1_TX_pin : out std_logic;
    fpga_0_LEDs_8Bit_GPIO_IO_pin : inout std_logic_vector(0 to 7);
    sys_clk_pin : in std_logic;
    sys_rst_pin : in std_logic;
    SRAM_OE_B : out std_logic;
    SRAM_CS_B : out std_logic;
    SRAM_BW_B : out std_logic_vector(3 downto 0);
    SRAM_WE_B : out std_logic;
    SRAM_ADDR : out std_logic_vector(17 downto 0);
    SRAM_CLK : out std_logic;
    SRAM_CLK_FB : in std_logic;
    VGA_VSYNC : in std_logic;
    VGA_Y_GREEN : in std_logic_vector(7 downto 0);
    VGA_HSYNC : in std_logic;
    VGA_PIXEL_CLK : in std_logic;
    DVI_RESET_B : out std_logic;
    DVI_XCLK_P : out std_logic;
    DVI_XCLK_N : out std_logic;
    DVI_DE : out std_logic;
    DVI_V : out std_logic;
    DVI_H : out std_logic;
    I2C_SCL : inout std_logic;
    I2C_SDA : inout std_logic;
    DVI_D : out std_logic_vector(11 downto 0);
    SRAM_DATA : inout std_logic_vector(35 downto 0);
    GPIO_DIP : in std_logic_vector(7 downto 0);
    GPIO_SW : in std_logic_vector(4 downto 0)
  );
end blah_stub;

architecture STRUCTURE of blah_stub is

  component blah is
    port (
      fpga_0_RS232_Uart_1_RX_pin : in std_logic;
      fpga_0_RS232_Uart_1_TX_pin : out std_logic;
      fpga_0_LEDs_8Bit_GPIO_IO_pin : inout std_logic_vector(0 to 7);
      sys_clk_pin : in std_logic;
      sys_rst_pin : in std_logic;
      SRAM_OE_B : out std_logic;
      SRAM_CS_B : out std_logic;
      SRAM_BW_B : out std_logic_vector(3 downto 0);
      SRAM_WE_B : out std_logic;
      SRAM_ADDR : out std_logic_vector(17 downto 0);
      SRAM_CLK : out std_logic;
      SRAM_CLK_FB : in std_logic;
      VGA_VSYNC : in std_logic;
      VGA_Y_GREEN : in std_logic_vector(7 downto 0);
      VGA_HSYNC : in std_logic;
      VGA_PIXEL_CLK : in std_logic;
      DVI_RESET_B : out std_logic;
      DVI_XCLK_P : out std_logic;
      DVI_XCLK_N : out std_logic;
      DVI_DE : out std_logic;
      DVI_V : out std_logic;
      DVI_H : out std_logic;
      I2C_SCL : inout std_logic;
      I2C_SDA : inout std_logic;
      DVI_D : out std_logic_vector(11 downto 0);
      SRAM_DATA : inout std_logic_vector(35 downto 0);
      GPIO_DIP : in std_logic_vector(7 downto 0);
      GPIO_SW : in std_logic_vector(4 downto 0)
    );
  end component;

begin

  blah_i : blah
    port map (
      fpga_0_RS232_Uart_1_RX_pin => fpga_0_RS232_Uart_1_RX_pin,
      fpga_0_RS232_Uart_1_TX_pin => fpga_0_RS232_Uart_1_TX_pin,
      fpga_0_LEDs_8Bit_GPIO_IO_pin => fpga_0_LEDs_8Bit_GPIO_IO_pin,
      sys_clk_pin => sys_clk_pin,
      sys_rst_pin => sys_rst_pin,
      SRAM_OE_B => SRAM_OE_B,
      SRAM_CS_B => SRAM_CS_B,
      SRAM_BW_B => SRAM_BW_B,
      SRAM_WE_B => SRAM_WE_B,
      SRAM_ADDR => SRAM_ADDR,
      SRAM_CLK => SRAM_CLK,
      SRAM_CLK_FB => SRAM_CLK_FB,
      VGA_VSYNC => VGA_VSYNC,
      VGA_Y_GREEN => VGA_Y_GREEN,
      VGA_HSYNC => VGA_HSYNC,
      VGA_PIXEL_CLK => VGA_PIXEL_CLK,
      DVI_RESET_B => DVI_RESET_B,
      DVI_XCLK_P => DVI_XCLK_P,
      DVI_XCLK_N => DVI_XCLK_N,
      DVI_DE => DVI_DE,
      DVI_V => DVI_V,
      DVI_H => DVI_H,
      I2C_SCL => I2C_SCL,
      I2C_SDA => I2C_SDA,
      DVI_D => DVI_D,
      SRAM_DATA => SRAM_DATA,
      GPIO_DIP => GPIO_DIP,
      GPIO_SW => GPIO_SW
    );

end architecture STRUCTURE;

