----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:58:00 05/24/2008 
-- Design Name: 
-- Module Name:    smooth_stage - Behavioral 
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

entity smooth_stage is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC);
end smooth_stage;

architecture Behavioral of smooth_stage is
  COMPONENT conv_pixel_ordering IS
    GENERIC (
      CONV_HEIGHT      : integer := 3;
      BORDER_SIZE      : integer := 1;
      WIDTH_BITS       : integer := IMGSIZE_BITS;
      HEIGHT_BITS      : integer := IMGSIZE_BITS;
      CONV_HEIGHT_BITS : integer := 2);
    PORT (CLK              : IN  std_logic;
          CLKEN            : IN  std_logic;
          RST              : IN  std_logic;
          HEIGHT           : IN  std_logic_vector(HEIGHT_BITS-1 DOWNTO 0);
          WIDTH            : IN  std_logic_vector(WIDTH_BITS-1 DOWNTO 0);
          WIDTH_OFFSET     : IN  std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);  -- (CONV_HEIGHT-1)*WIDTH-1
          INITIAL_MEM_ADDR : IN  std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
          MEM_ADDR         : OUT std_logic_vector (WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
          X_COORD          : OUT std_logic_vector (WIDTH_BITS-1 DOWNTO 0);
          Y_COORD          : OUT std_logic_vector (HEIGHT_BITS-1 DOWNTO 0);
          CONV_Y_POS       : OUT std_logic_vector (CONV_HEIGHT_BITS-1 DOWNTO 0);
          DATA_VALID       : OUT std_logic;
          NEW_ROW          : OUT std_logic;
          DONE             : OUT std_logic);
  END COMPONENT;

  COMPONENT pipeline_buffer IS
  GENERIC (
    WIDTH         :     integer := 1;
    STAGES        :     integer := 1;
    DEFAULT_VALUE :     integer := 2#0#);
  PORT ( CLK      : IN  std_logic;
         RST      : IN  std_logic;
         CLKEN    : IN  std_logic;
         DIN      : IN  std_logic_vector(WIDTH-1 DOWNTO 0);
         DOUT     : OUT std_logic_vector(WIDTH-1 DOWNTO 0));
END COMPONENT;

begin
-------------------------------------------------------------------------------
  -- Coord Generator
-- 1CT Delay
  conv_pixel_ordering_i : conv_pixel_ordering
    PORT MAP (CLK              => CLK,
              CLKEN            => pixgen_clken,
              RST              => RST,
              HEIGHT           => img_height,
              WIDTH            => img_width,
              WIDTH_OFFSET     => img_width_offset,
              INITIAL_MEM_ADDR => initial_mem_addr,
              MEM_ADDR         => img0_mem_addr,
              CONV_Y_POS       => coord_gen_state,  -- 0=above cur pixel, 1=
                                                    -- current pixel, 2=below cur pixel for
                                                    -- 3x3
              X_COORD          => x_coord,
              Y_COORD          => y_coord,
              DATA_VALID       => img0_addr_valid,
              NEW_ROW          => coord_gen_new_row,
              DONE             => coord_gen_done);

  
-------------------------------------------------------------------------------
  -- New Row Buffer

-------------------------------------------------------------------------------
  -- 1D Address Buffer

  
-------------------------------------------------------------------------------
  -- Memory Address Selector

-------------------------------------------------------------------------------
  -- State Buffer
  
-------------------------------------------------------------------------------
  -- 3x3 Buffer

-------------------------------------------------------------------------------
  -- 3x3 Smooth
  

  
  

end Behavioral;

