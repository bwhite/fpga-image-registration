-------------------------------------------------------------------------------
-- registration_core_0_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library registration_core_v1_00_a;
use registration_core_v1_00_a.all;

entity registration_core_0_wrapper is
  port (
    SPLB_Clk : in std_logic;
    SPLB_Rst : in std_logic;
    PLB_ABus : in std_logic_vector(0 to 31);
    PLB_UABus : in std_logic_vector(0 to 31);
    PLB_PAValid : in std_logic;
    PLB_SAValid : in std_logic;
    PLB_rdPrim : in std_logic;
    PLB_wrPrim : in std_logic;
    PLB_masterID : in std_logic_vector(0 to 0);
    PLB_abort : in std_logic;
    PLB_busLock : in std_logic;
    PLB_RNW : in std_logic;
    PLB_BE : in std_logic_vector(0 to 3);
    PLB_MSize : in std_logic_vector(0 to 1);
    PLB_size : in std_logic_vector(0 to 3);
    PLB_type : in std_logic_vector(0 to 2);
    PLB_lockErr : in std_logic;
    PLB_wrDBus : in std_logic_vector(0 to 31);
    PLB_wrBurst : in std_logic;
    PLB_rdBurst : in std_logic;
    PLB_wrPendReq : in std_logic;
    PLB_rdPendReq : in std_logic;
    PLB_wrPendPri : in std_logic_vector(0 to 1);
    PLB_rdPendPri : in std_logic_vector(0 to 1);
    PLB_reqPri : in std_logic_vector(0 to 1);
    PLB_TAttribute : in std_logic_vector(0 to 15);
    Sl_addrAck : out std_logic;
    Sl_SSize : out std_logic_vector(0 to 1);
    Sl_wait : out std_logic;
    Sl_rearbitrate : out std_logic;
    Sl_wrDAck : out std_logic;
    Sl_wrComp : out std_logic;
    Sl_wrBTerm : out std_logic;
    Sl_rdDBus : out std_logic_vector(0 to 31);
    Sl_rdWdAddr : out std_logic_vector(0 to 3);
    Sl_rdDAck : out std_logic;
    Sl_rdComp : out std_logic;
    Sl_rdBTerm : out std_logic;
    Sl_MBusy : out std_logic_vector(0 to 1);
    Sl_MWrErr : out std_logic_vector(0 to 1);
    Sl_MRdErr : out std_logic_vector(0 to 1);
    Sl_MIRQ : out std_logic_vector(0 to 1);
    DVI_D : out std_logic_vector(11 downto 0);
    DVI_H : out std_logic;
    DVI_V : out std_logic;
    DVI_DE : out std_logic;
    DVI_XCLK_N : out std_logic;
    DVI_XCLK_P : out std_logic;
    DVI_RESET_B : out std_logic;
    VGA_PIXEL_CLK : in std_logic;
    VGA_Y_GREEN : in std_logic_vector(7 downto 0);
    VGA_HSYNC : in std_logic;
    VGA_VSYNC : in std_logic;
    SRAM_CLK_FB : in std_logic;
    SRAM_CLK : out std_logic;
    SRAM_ADDR : out std_logic_vector(17 downto 0);
    SRAM_WE_B : out std_logic;
    SRAM_BW_B : out std_logic_vector(3 downto 0);
    SRAM_CS_B : out std_logic;
    SRAM_OE_B : out std_logic;
    GPIO_DIP : in std_logic_vector(7 downto 0);
    GPIO_SW : in std_logic_vector(4 downto 0);
    I2C_SDA_I : in std_logic;
    I2C_SDA_O : out std_logic;
    I2C_SDA_T : out std_logic;
    I2C_SCL_I : in std_logic;
    I2C_SCL_O : out std_logic;
    I2C_SCL_T : out std_logic;
    SRAM_DATA_I : in std_logic_vector(35 downto 0);
    SRAM_DATA_O : out std_logic_vector(35 downto 0);
    SRAM_DATA_T : out std_logic
  );

  attribute x_core_info : STRING;
  attribute x_core_info of registration_core_0_wrapper : entity is "registration_core_v1_00_a";

end registration_core_0_wrapper;

architecture STRUCTURE of registration_core_0_wrapper is

  component registration_core is
    generic (
      C_BASEADDR : std_logic_vector;
      C_HIGHADDR : std_logic_vector;
      C_SPLB_AWIDTH : INTEGER;
      C_SPLB_DWIDTH : INTEGER;
      C_SPLB_NUM_MASTERS : INTEGER;
      C_SPLB_MID_WIDTH : INTEGER;
      C_SPLB_NATIVE_DWIDTH : INTEGER;
      C_SPLB_P2P : INTEGER;
      C_SPLB_SUPPORT_BURSTS : INTEGER;
      C_SPLB_SMALLEST_MASTER : INTEGER;
      C_SPLB_CLK_PERIOD_PS : INTEGER;
      C_INCLUDE_DPHASE_TIMER : INTEGER;
      C_FAMILY : STRING
    );
    port (
      SPLB_Clk : in std_logic;
      SPLB_Rst : in std_logic;
      PLB_ABus : in std_logic_vector(0 to 31);
      PLB_UABus : in std_logic_vector(0 to 31);
      PLB_PAValid : in std_logic;
      PLB_SAValid : in std_logic;
      PLB_rdPrim : in std_logic;
      PLB_wrPrim : in std_logic;
      PLB_masterID : in std_logic_vector(0 to (C_SPLB_MID_WIDTH-1));
      PLB_abort : in std_logic;
      PLB_busLock : in std_logic;
      PLB_RNW : in std_logic;
      PLB_BE : in std_logic_vector(0 to ((C_SPLB_DWIDTH/8)-1));
      PLB_MSize : in std_logic_vector(0 to 1);
      PLB_size : in std_logic_vector(0 to 3);
      PLB_type : in std_logic_vector(0 to 2);
      PLB_lockErr : in std_logic;
      PLB_wrDBus : in std_logic_vector(0 to (C_SPLB_DWIDTH-1));
      PLB_wrBurst : in std_logic;
      PLB_rdBurst : in std_logic;
      PLB_wrPendReq : in std_logic;
      PLB_rdPendReq : in std_logic;
      PLB_wrPendPri : in std_logic_vector(0 to 1);
      PLB_rdPendPri : in std_logic_vector(0 to 1);
      PLB_reqPri : in std_logic_vector(0 to 1);
      PLB_TAttribute : in std_logic_vector(0 to 15);
      Sl_addrAck : out std_logic;
      Sl_SSize : out std_logic_vector(0 to 1);
      Sl_wait : out std_logic;
      Sl_rearbitrate : out std_logic;
      Sl_wrDAck : out std_logic;
      Sl_wrComp : out std_logic;
      Sl_wrBTerm : out std_logic;
      Sl_rdDBus : out std_logic_vector(0 to (C_SPLB_DWIDTH-1));
      Sl_rdWdAddr : out std_logic_vector(0 to 3);
      Sl_rdDAck : out std_logic;
      Sl_rdComp : out std_logic;
      Sl_rdBTerm : out std_logic;
      Sl_MBusy : out std_logic_vector(0 to (C_SPLB_NUM_MASTERS-1));
      Sl_MWrErr : out std_logic_vector(0 to (C_SPLB_NUM_MASTERS-1));
      Sl_MRdErr : out std_logic_vector(0 to (C_SPLB_NUM_MASTERS-1));
      Sl_MIRQ : out std_logic_vector(0 to (C_SPLB_NUM_MASTERS-1));
      DVI_D : out std_logic_vector(11 downto 0);
      DVI_H : out std_logic;
      DVI_V : out std_logic;
      DVI_DE : out std_logic;
      DVI_XCLK_N : out std_logic;
      DVI_XCLK_P : out std_logic;
      DVI_RESET_B : out std_logic;
      VGA_PIXEL_CLK : in std_logic;
      VGA_Y_GREEN : in std_logic_vector(7 downto 0);
      VGA_HSYNC : in std_logic;
      VGA_VSYNC : in std_logic;
      SRAM_CLK_FB : in std_logic;
      SRAM_CLK : out std_logic;
      SRAM_ADDR : out std_logic_vector(17 downto 0);
      SRAM_WE_B : out std_logic;
      SRAM_BW_B : out std_logic_vector(3 downto 0);
      SRAM_CS_B : out std_logic;
      SRAM_OE_B : out std_logic;
      GPIO_DIP : in std_logic_vector(7 downto 0);
      GPIO_SW : in std_logic_vector(4 downto 0);
      I2C_SDA_I : in std_logic;
      I2C_SDA_O : out std_logic;
      I2C_SDA_T : out std_logic;
      I2C_SCL_I : in std_logic;
      I2C_SCL_O : out std_logic;
      I2C_SCL_T : out std_logic;
      SRAM_DATA_I : in std_logic_vector(35 downto 0);
      SRAM_DATA_O : out std_logic_vector(35 downto 0);
      SRAM_DATA_T : out std_logic
    );
  end component;

begin

  registration_core_0 : registration_core
    generic map (
      C_BASEADDR => X"c2000000",
      C_HIGHADDR => X"c200ffff",
      C_SPLB_AWIDTH => 32,
      C_SPLB_DWIDTH => 32,
      C_SPLB_NUM_MASTERS => 2,
      C_SPLB_MID_WIDTH => 1,
      C_SPLB_NATIVE_DWIDTH => 32,
      C_SPLB_P2P => 0,
      C_SPLB_SUPPORT_BURSTS => 0,
      C_SPLB_SMALLEST_MASTER => 32,
      C_SPLB_CLK_PERIOD_PS => 10000,
      C_INCLUDE_DPHASE_TIMER => 1,
      C_FAMILY => "virtex5"
    )
    port map (
      SPLB_Clk => SPLB_Clk,
      SPLB_Rst => SPLB_Rst,
      PLB_ABus => PLB_ABus,
      PLB_UABus => PLB_UABus,
      PLB_PAValid => PLB_PAValid,
      PLB_SAValid => PLB_SAValid,
      PLB_rdPrim => PLB_rdPrim,
      PLB_wrPrim => PLB_wrPrim,
      PLB_masterID => PLB_masterID,
      PLB_abort => PLB_abort,
      PLB_busLock => PLB_busLock,
      PLB_RNW => PLB_RNW,
      PLB_BE => PLB_BE,
      PLB_MSize => PLB_MSize,
      PLB_size => PLB_size,
      PLB_type => PLB_type,
      PLB_lockErr => PLB_lockErr,
      PLB_wrDBus => PLB_wrDBus,
      PLB_wrBurst => PLB_wrBurst,
      PLB_rdBurst => PLB_rdBurst,
      PLB_wrPendReq => PLB_wrPendReq,
      PLB_rdPendReq => PLB_rdPendReq,
      PLB_wrPendPri => PLB_wrPendPri,
      PLB_rdPendPri => PLB_rdPendPri,
      PLB_reqPri => PLB_reqPri,
      PLB_TAttribute => PLB_TAttribute,
      Sl_addrAck => Sl_addrAck,
      Sl_SSize => Sl_SSize,
      Sl_wait => Sl_wait,
      Sl_rearbitrate => Sl_rearbitrate,
      Sl_wrDAck => Sl_wrDAck,
      Sl_wrComp => Sl_wrComp,
      Sl_wrBTerm => Sl_wrBTerm,
      Sl_rdDBus => Sl_rdDBus,
      Sl_rdWdAddr => Sl_rdWdAddr,
      Sl_rdDAck => Sl_rdDAck,
      Sl_rdComp => Sl_rdComp,
      Sl_rdBTerm => Sl_rdBTerm,
      Sl_MBusy => Sl_MBusy,
      Sl_MWrErr => Sl_MWrErr,
      Sl_MRdErr => Sl_MRdErr,
      Sl_MIRQ => Sl_MIRQ,
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
      GPIO_DIP => GPIO_DIP,
      GPIO_SW => GPIO_SW,
      I2C_SDA_I => I2C_SDA_I,
      I2C_SDA_O => I2C_SDA_O,
      I2C_SDA_T => I2C_SDA_T,
      I2C_SCL_I => I2C_SCL_I,
      I2C_SCL_O => I2C_SCL_O,
      I2C_SCL_T => I2C_SCL_T,
      SRAM_DATA_I => SRAM_DATA_I,
      SRAM_DATA_O => SRAM_DATA_O,
      SRAM_DATA_T => SRAM_DATA_T
    );

end architecture STRUCTURE;

