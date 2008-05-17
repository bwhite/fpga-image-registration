----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:50:57 04/22/2008 
-- Design Name: 
-- Module Name:    conv_pix_ordering_mem_addr_select_test - Behavioral 
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

ENTITY conv_pix_ordering_mem_addr_select_test IS
  PORT ( CLK          : IN  std_logic;
         RST          : IN  std_logic;
         MEM_VALUE    : IN  std_logic_vector(8 DOWNTO 0);
         MEM_ADDR     : OUT std_logic_vector(19 DOWNTO 0);
         IMG0_0_1     : OUT std_logic_vector(8 DOWNTO 0);
         IMG0_1_0     : OUT std_logic_vector(8 DOWNTO 0);
         IMG0_1_1     : OUT std_logic_vector(8 DOWNTO 0);
         IMG0_1_2     : OUT std_logic_vector(8 DOWNTO 0);
         IMG0_2_1     : OUT std_logic_vector(8 DOWNTO 0);
         IMG1_1_1     : OUT std_logic_vector(8 DOWNTO 0);
         OUTPUT_VALID : OUT std_logic);
END conv_pix_ordering_mem_addr_select_test;

ARCHITECTURE Behavioral OF conv_pix_ordering_mem_addr_select_test IS
  COMPONENT conv_pixel_ordering IS
                                  GENERIC (
                                    CONV_HEIGHT      :    integer := 3;
                                    WIDTH_BITS       :    integer := 10;
                                    HEIGHT_BITS      :    integer := 10;
                                    CONV_HEIGHT_BITS :    integer := 2);
                                PORT ( CLK           : IN std_logic;
                                       CLKEN         : IN std_logic;
                                       RST           : IN std_logic;
                                       -- HEIGHT/WIDTH/WIDTH_OFFSET entered externally
                                       -- NOTE:  HEIGHT/WIDTH/WIDTH_OFFSET MUST BE CONSTANT AFTER RST FOR
                                       -- CORRECT RESULTS!
                                       HEIGHT        : IN std_logic_vector(HEIGHT_BITS-1 DOWNTO 0);
                                       WIDTH         : IN std_logic_vector(WIDTH_BITS-1 DOWNTO 0);
                                       WIDTH_OFFSET  : IN std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);  -- (CONV_HEIGHT-1)*WIDTH-1

                                       MEM_ADDR   : OUT std_logic_vector (WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
                                       X_COORD    : OUT std_logic_vector (WIDTH_BITS-1 DOWNTO 0);
                                       Y_COORD    : OUT std_logic_vector (HEIGHT_BITS-1 DOWNTO 0);
                                       CONV_Y_POS : OUT std_logic_vector (CONV_HEIGHT_BITS-1 DOWNTO 0);
                                       DATA_VALID : OUT std_logic;
                                       DONE       : OUT std_logic);
  END COMPONENT;

  COMPONENT mem_addr_selector IS
                                GENERIC (
                                  MEMADDR_BITS  : integer := 20;
                                  PIXSTATE_BITS : integer := 2);

                              PORT ( CLK                  : IN  std_logic;
                                     RST                  : IN  std_logic;
                                     INPUT_VALID0         : IN  std_logic;
                                     INPUT_VALID1         : IN  std_logic;
                                     PIXEL_STATE          : IN  std_logic_vector(PIXSTATE_BITS-1 DOWNTO 0);
                                     MEM_ADDR0            : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
                                     MEM_ADDR1            : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
                                     MEM_ADDROFF0         : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
                                     MEM_ADDROFF1         : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
                                     PATTERN_STATE        : OUT std_logic_vector (PIXSTATE_BITS DOWNTO 0);
                                     MEM_ADDR             : OUT std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
                                     OUTPUT_VALID         : OUT std_logic;
                                     PIXGEN_CLKEN         : OUT std_logic);
  END COMPONENT;
  COMPONENT pixel_conv_buffer IS
                                GENERIC (
                                  PIXEL_BITS              : IN  integer := 9);
                              PORT ( CLK                  : IN  std_logic;
                                     RST                  : IN  std_logic;
                                     MEM_VALUE            : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
                                     INPUT_VALID          : IN  std_logic;
                                     PATTERN_STATE        : IN  std_logic_vector(2 DOWNTO 0);
                                     OUTPUT_VALID         : OUT std_logic;
                                     IMG0_0_1             : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
                                     IMG0_1_0             : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
                                     IMG0_1_1             : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
                                     IMG0_1_2             : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
                                     IMG0_2_1             : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
                                     IMG1_1_1             : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0));
  END COMPONENT;
  SIGNAL coord_gen_state                                  :     std_logic_vector(1 DOWNTO 0);
  SIGNAL coord_gen_mem_addr                               :     std_logic_vector(19 DOWNTO 0);
  SIGNAL pixgen_clken, coord_valid, mem_addr_output_valid :     std_logic;
  SIGNAL pattern_state_wire                               :     std_logic_vector(2 DOWNTO 0);
  SIGNAL mem_value_buf : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0');
BEGIN
PROCESS (CLK) IS
BEGIN  -- PROCESS
  IF CLK'event AND CLK = '1' THEN       -- rising clock edge
    mem_value_buf <= MEM_VALUE;
  END IF;
END PROCESS;
  
-- Conv pixel ordering should output 3 pixels corresponding to one vertical 3
-- pixel segment, it should be paused (i.e., should not output another pixel)
-- while the warped memory address is taken, it should then be unpaused and the
-- next pixel should be the first of the next 3 pattern.

-- Convolution Pixel Stream: Stream pixel coordinates in a convolution pattern.
  conv_pixel_ordering_i : conv_pixel_ordering
    PORT MAP ( CLK          => CLK,
               CLKEN        => pixgen_clken,
               RST          => RST,
               HEIGHT       => "0000100000",      --std_logic_vector(#16#1e0),
               WIDTH        => "0000100000",
               WIDTH_OFFSET => "00000000000000111111",
               MEM_ADDR     => coord_gen_mem_addr,
               DATA_VALID   => coord_valid,
               CONV_Y_POS   => coord_gen_state);  -- 0=above cur pixel, 1=
                                                  -- current pixel, 2=below cur pixel for
                                                  -- 3x3

  mem_addr_selector_i : mem_addr_selector
    PORT MAP ( CLK           => CLK,
               RST           => RST,
               INPUT_VALID0  => coord_valid,
               INPUT_VALID1  => '1',
               PIXEL_STATE   => coord_gen_state,
               MEM_ADDR0     => coord_gen_mem_addr,
               MEM_ADDR1     => "10101010101010101010",  -- NOTE: Sentinal value
               MEM_ADDROFF0  => "00000000000000000000",
               MEM_ADDROFF1  => "00000000000000000000",
               PATTERN_STATE => pattern_state_wire,
               MEM_ADDR      => MEM_ADDR,
               OUTPUT_VALID  => mem_addr_output_valid,
               PIXGEN_CLKEN  => pixgen_clken);

  pixel_conv_buffer_i : pixel_conv_buffer
    PORT MAP (
      CLK           => CLK,
      RST           => RST,
      MEM_VALUE     => mem_value_buf,
      INPUT_VALID   => mem_addr_output_valid,
      PATTERN_STATE => pattern_state_wire,
      OUTPUT_VALID  => OUTPUT_VALID,
      IMG0_0_1      => IMG0_0_1,
      IMG0_1_0      => IMG0_1_0,
      IMG0_1_1      => IMG0_1_1,
      IMG0_1_2      => IMG0_1_2,
      IMG0_2_1      => IMG0_2_1,
      IMG1_1_1      => IMG1_1_1);
END Behavioral;
