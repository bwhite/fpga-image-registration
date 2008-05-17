LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fetch_stage IS
  GENERIC (
    CONV_HEIGHT      :    integer := 3;
    IMGSIZE_BITS     :    integer := 10;
    PIXEL_BITS       :    integer := 9;
    CONV_HEIGHT_BITS :    integer := 2);
  PORT ( CLK         : IN std_logic;    -- NOTE: The clock should not be gated
                                        -- as the timing in this module depends
                                        -- on the timing of an external RAM
         RST         : IN std_logic;
         LEVEL       : IN std_logic_vector(2 DOWNTO 0);
         -- 0:0:PIXEL_BITS Format
         MEM_VALUE   : IN std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         MEM_VALID   : IN std_logic;
         -- Affine Homography elements IMG2_VEC=H*IMG1_VEC
         -- Rotation and Non-Isotropic Scale
         -- 1:6:11 Format
         H_0_0       : IN std_logic_vector(17 DOWNTO 0);
         H_0_1       : IN std_logic_vector(17 DOWNTO 0);
         H_1_0       : IN std_logic_vector(17 DOWNTO 0);
         H_1_1       : IN std_logic_vector(17 DOWNTO 0);
         -- Translation
         -- 1:10:11 Format 
         H_0_2       : IN std_logic_vector(21 DOWNTO 0);
         H_1_2       : IN std_logic_vector(21 DOWNTO 0);

         MEM_ADDR      : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
         -- IMG0 Neighborhood for spatial derivative computation (only output
         -- the union of the middle row pixels and the middle column pixels)
         -- 0:0:PIXEL_BITS Format
         IMG0_0_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG0_1_0      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG0_1_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG0_1_2      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         IMG0_2_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         -- IMG1 Center pixel value for temporal derivative computation
         IMG1_1_1      : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         -- Offset pixel coordinates for A/b matrix computation (offset to
         -- increase numerical accuracy, corrected later in the pipeline)
         -- 1:IMGSIZE_BITS:1 Format
         TRANS_X_COORD : OUT std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);
         TRANS_Y_COORD : OUT std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);

         FSCS_VALID : OUT std_logic);
END fetch_stage;

ARCHITECTURE Behavioral OF fetch_stage IS
  COMPONENT conv_pixel_ordering IS
                                  GENERIC (
                                    CONV_HEIGHT      :     integer := 3;
                                    WIDTH_BITS       :     integer := 10;
                                    HEIGHT_BITS      :     integer := 10;
                                    CONV_HEIGHT_BITS :     integer := 2);
                                PORT ( CLK           : IN  std_logic;
                                       CLKEN         : IN  std_logic;
                                       RST           : IN  std_logic;
                                       HEIGHT        : IN  std_logic_vector(HEIGHT_BITS-1 DOWNTO 0);
                                       WIDTH         : IN  std_logic_vector(WIDTH_BITS-1 DOWNTO 0);
                                       WIDTH_OFFSET  : IN  std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);  -- (CONV_HEIGHT-1)*WIDTH-1
                                       MEM_ADDR      : OUT std_logic_vector (WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
                                       X_COORD       : OUT std_logic_vector (WIDTH_BITS-1 DOWNTO 0);
                                       Y_COORD       : OUT std_logic_vector (HEIGHT_BITS-1 DOWNTO 0);
                                       CONV_Y_POS    : OUT std_logic_vector (CONV_HEIGHT_BITS-1 DOWNTO 0);
                                       DATA_VALID    : OUT std_logic;
                                       DONE          : OUT std_logic);
  END COMPONENT;



  COMPONENT mem_addr_selector IS
                                GENERIC (
                                  MEMADDR_BITS           :     integer := 20;
                                  PIXSTATE_BITS          :     integer := 2);

                              PORT ( CLK            : IN  std_logic;
                                     RST            : IN  std_logic;
                                     INPUT_VALID0   : IN  std_logic;
                                     INPUT_VALID1   : IN  std_logic;
                                     PIXEL_STATE    : IN  std_logic_vector(PIXSTATE_BITS-1 DOWNTO 0);
                                     MEM_ADDR0      : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
                                     MEM_ADDR1      : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
                                     MEM_ADDROFF0   : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
                                     MEM_ADDROFF1   : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
                                     PATTERN_STATE  : OUT std_logic_vector (PIXSTATE_BITS DOWNTO 0);
                                     MEM_ADDR       : OUT std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
                                     OUTPUT_VALID   : OUT std_logic;
                                     PIXGEN_CLKEN   : OUT std_logic);
  END COMPONENT;

  COMPONENT pixel_conv_buffer IS
                                GENERIC (
                                  PIXEL_BITS                                   : IN  integer := 9);
                              PORT ( CLK                                       : IN  std_logic;
                                     RST                                       : IN  std_logic;
                                     MEM_VALUE                                 : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
                                     INPUT_VALID                               : IN  std_logic;
                                     PATTERN_STATE                             : IN  std_logic_vector(2 DOWNTO 0);
                                     OUTPUT_VALID                              : OUT std_logic;
                                     IMG0_0_1                                  : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
                                     IMG0_1_0                                  : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
                                     IMG0_1_1                                  : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
                                     IMG0_1_2                                  : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
                                     IMG0_2_1                                  : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
                                     IMG1_1_1                                  : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0));
  END COMPONENT;
  SIGNAL x_coord_trans, y_coord_trans, img_height, img_width, img_width_offset :     std_logic_vector(9 DOWNTO 0);
  SIGNAL img0_offset, img1_offset                                              :     std_logic_vector(19 DOWNTO 0);
BEGIN
-- Parameter ROM: Holds parameters that vary depending on the pyramid level.
-- (Maximum X/Y image coordinates, X/Y Offset Values (to produce a zero mean of
-- pixel coordinates)), level/img offsets, and width offset values(for conv.
-- coordinate generation). This only loads the new value on RST.
-- NOTE: Care must be taken in selecting these values to prevent (over/under)flow
  -- 0CT Delay
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        CASE LEVEL IS
          WHEN 0 =>                     -- 720x480
            y_coord_trans    <= "";     -- 240
            x_coord_trans    <= "";     -- 360
            img0_offset      <=;        -- 0
            img1_offset      <=;        -- 345,600
            img_height       <=;        -- 480
            img_width        <=;        -- 720
            img_width_offset <=;        -- 1439 (CONV_HEIGHT-1)*WIDTH-1

          WHEN 1 =>                     -- 360x240
            y_coord_trans    <=;        -- 120
            x_coord_trans    <=;        -- 180
            img0_offset      <=;        -- 691,200
            img1_offset      <=;        -- 777,600
            img_height       <=;        -- 240
            img_width        <=;        -- 360
            img_width_offset <=;        -- 719

          WHEN 2 =>                     -- 180x120
            y_coord_trans    <=;        -- 60
            x_coord_trans    <=;        -- 90
            img0_offset      <=;        -- 864,000
            img1_offset      <=;        -- 885,600
            img_height       <=;        -- 120
            img_width        <=;        -- 180
            img_width_offset <=;        -- 359

          WHEN 3 =>                     -- 90x60
            y_coord_trans    <=;        -- 30
            x_coord_trans    <=;        -- 45
            img0_offset      <=;        -- 907,200
            img1_offset      <=;        -- 912,600
            img_height       <=;        -- 60
            img_width        <=;        -- 90
            img_width_offset <=;        -- 179

          WHEN 4 =>                     -- 45x30
            y_coord_trans    <=;        -- 15
            x_coord_trans    <=;        -- 22.5
            img0_offset      <=;        -- 918,000
            img1_offset      <=;        -- 919,350
            img_height       <=;        -- 30
            img_width        <=;        -- 45
            img_width_offset <=;        -- 89

          WHEN OTHERS                   =>
            y_coord_trans    <= (OTHERS => '0');
            x_coord_trans    <= (OTHERS => '0');
            img0_offset      <= (OTHERS => '0');
            img1_offset      <= (OTHERS => '0');
            img_height       <= (OTHERS => '0');
            img_width        <= (OTHERS => '0');
            img_width_offset <= (OTHERS => '0');
        END CASE;
      END IF;
    END IF;
  END PROCESS;

-- Convolution Pixel Stream: Stream pixel coordinates in a convolution pattern.
-- 1CT Delay
  conv_pixel_ordering_i : conv_pixel_ordering
    PORT MAP ( CLK          => CLK,
               CLKEN        => pixgen_clken,
               RST          => RST,
               HEIGHT       => img_height,
               WIDTH        => img_width,
               WIDTH_OFFSET => img_width_offset,
               MEM_ADDR     => coord_gen_mem_addr,
               CONV_Y_POS   => coord_gen_state,  -- 0=above cur pixel, 1=
                                                 -- current pixel, 2=below cur pixel for
                                                 -- 3x3
               X_COORD      => x_coord,
               Y_COORD      => y_coord,
               DATA_VALID   => coord_valid,
               DONE         => coord_gen_done);

-- Current Pixel Coord Check: Store current pixel coordinates (the center of
-- the convolution).
-- NOTE: This assumes that the pixel generator will never be halted (CLKEN='0') on the center pixel value.
  -- 0CT Delay
  PROCESS (coord_valid, coord_gen_state) IS
  BEGIN  -- PROCESS
    IF coord_valid = '1' AND coord_gen_state = "01" THEN
      center_pixel_active <= '1';
    ELSE
      center_pixel_active <= '0';
    END IF;
  END PROCESS;

  -- 0CT Delay
  PROCESS (center_pixel_active, coord_valid) IS
  BEGIN  -- PROCESS
    IF center_pixel_active = '1' AND coord_valid = '1' THEN
      affine_input_valid <= '1';
    ELSE
      affine_input_valid <= '0';
    END IF;
  END PROCESS;

  

-- Translate Coords: Translate the image coordinates to reduce the
  -- 1CT Delay
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        x_coord_trans   <= (OTHERS => '0');
        y_coord_trans   <= (OTHERS => '0');
      ELSE
        IF center_pixel_active = '1' THEN
          x_coord_trans <= unsigned(x_coord)-unsigned(x_coord_trans);
          y_coord_trans <= unsigned(y_coord)-unsigned(y_coord_trans);
        END IF;
      END IF;
    END IF;
  END PROCESS;

-- Memory Address Selector: Read 3 pixels from IMG0 using the coord generator'
-- s memory address, pause the coord generator, read 1 pixel from IMG1 using
-- the warped coord address
-- 1CT Delay
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
  
-- Pixel Buffer : Store the kernel neighborhood and update it with incoming
-- pixel values. Note that since there is a delay between when the read
-- command is asserted and when the valid data is available, the cur pixel
-- state will be pipelined to align the valid data with the pixel state.
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

-- Signal Pipeline: Passes previously computed values through the pipeline to
-- allow the signals to be output simultaneously. Signals: coord_stage,translated_
-- coords, bounds checking OOB, affine transform OOB, coord_valid
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        coord_gen_state_buf <= (OTHERS => '0');
      ELSE
                                        -- Pipeline pixel state  -- TODO Fix this to be the exact number
                                        -- of stages

        coord_gen_state_buf(2) <= coord_gen_state;
        coord_gen_state_buf(1) <= coord_gen_state_buf(2);
        coord_gen_state_buf(0) <= coord_gen_state_buf(1);
      END IF;
    END IF;
  END PROCESS;

-- Output Valid: Set FSCS_VALID='1' if the output is valid for this CT. 3x3
-- IMG0 buffer must be full/valid, IMG1 warped value must be valid, and the
-- translated coords must be valid.
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)

      ELSE

      END IF;
    END IF;
  END PROCESS;
END Behavioral;

