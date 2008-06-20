
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY smooth_stage IS
  GENERIC (
    WIDTH        :     integer := 9;
    IMGSIZE_BITS :     integer := 10);
  PORT (CLK      : IN  std_logic;
        RST      : IN  std_logic;
        -- TODO Add address output
        -- TODO Add memory output valid
        DIN      : IN  std_logic_vector(WIDTH-1 DOWNTO 0);
        DOUT     : OUT std_logic_vector(WIDTH-1 DOWNTO 0));
END smooth_stage;

ARCHITECTURE Behavioral OF smooth_stage IS
  COMPONENT conv_pixel_ordering IS
                                  GENERIC (
                                    CONV_HEIGHT        :     integer := 3;
                                    BORDER_SIZE        :     integer := 1;
                                    WIDTH_BITS         :     integer := IMGSIZE_BITS;
                                    HEIGHT_BITS        :     integer := IMGSIZE_BITS;
                                    CONV_HEIGHT_BITS   :     integer := 2);
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
                            PORT ( CLK        : IN  std_logic;
                                   RST        : IN  std_logic;
                                   CLKEN      : IN  std_logic;
                                   DIN        : IN  std_logic_vector(WIDTH-1 DOWNTO 0);
                                   DOUT       : OUT std_logic_vector(WIDTH-1 DOWNTO 0));
  END COMPONENT;

  SIGNAL pixgen_clken, img0_addr_valid, coord_gen_new_row, coord_gen_done, coord_gen_new_row_buf : std_logic;
  SIGNAL img_height, img_width, x_coord, y_coord                                                 : std_logic_vector(IMGSIZE-1 DOWNTO 0);
  SIGNAL img_width_offset, img0_mem_addr, img0_mem_addr_buf, initial_mem_offset                  : std_logic_vector(2*IMGSIZE-1 DOWNTO 0);
  SIGNAL coord_gen_state                                                                         : std_logic_vector(1 DOWNTO 0);
  SIGNAL pattern_state, pattern_state_buf                                                        : std_logic_vector(2 DOWNTO 0);
BEGIN

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
              NEW_ROW_OFFSET   => (OTHERS => '0'),
              LAST_VALID_Y_POS => (OTHERS => '0'),
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
  pipebuf_newrow : pipeline_buffer
    GENERIC MAP (
      WIDTH         => 1,
      STAGES        => 3,
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK           => CLK,
      RST           => '0',
      CLKEN         => '1',
      DIN           => (0 DOWNTO 0 => coord_gen_new_row),
      DOUT          => (0 DOWNTO 0 => coord_gen_new_row_buf));

-------------------------------------------------------------------------------
  -- 1D Address Buffer
  pipebuf_1d_addr : pipeline_buffer
    GENERIC MAP (
      WIDTH         => 2*IMGSIZE_BITS,
      STAGES        => 3,
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK           => CLK,
      RST           => '0',
      CLKEN         => '1',
      DIN           => img0_mem_addr,
      DOUT          => img0_mem_addr_buf);


-------------------------------------------------------------------------------
  -- Memory Address Selector:  Take in the coord gen state and the pixgen_clken
  -- signal to select the correct address (for reading values to the buffer or
  -- for writing the smoothed value back), control RAM signals, 


-------------------------------------------------------------------------------
  -- State Buffer
  pipebuf_state : pipeline_buffer
    GENERIC MAP (
      WIDTH         => 3,
      STAGES        => 5,
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK           => CLK,
      RST           => '0',
      CLKEN         => '1',
      DIN           => pattern_state,
      DOUT          => pattern_state_buf);

-------------------------------------------------------------------------------
  -- 3x3 Convolution Buffer:  Buffer a 3x3 neighborhood, ignore values that
  -- result from memory writes (use the stage generated in the address selector)

-------------------------------------------------------------------------------
  -- 3x3 Smooth: Take in a neighborhood and produce a smoothed pixel value
  -- centered in that neighborhood.



END Behavioral;

