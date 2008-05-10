LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fetch_stage IS
  PORT ( CLK       : IN std_logic;      -- NOTE: The clock should not be gated
                                        -- as the timing in this module depends
                                        -- on the timing of an external RAM
         RST       : IN std_logic;
         LEVEL     : IN std_logic;
         MEM_VALUE : IN std_logic;
         MEM_VALID : IN std_logic;
         -- Affine Homography elements IMG2_VEC=H*IMG1_VEC
         -- Rotation and Non-Isotropic Scale
         H_0_0     : IN signed(0 DOWNTO 0);
         H_0_1     : IN signed(0 DOWNTO 0);
         H_1_0     : IN signed(0 DOWNTO 0);
         H_1_1     : IN signed(0 DOWNTO 0);
         -- Translation
         H_0_2     : IN signed(0 DOWNTO 0);
         H_1_2     : IN signed(0 DOWNTO 0);

         MEM_ADDR      : OUT std_logic;
         -- IMG0 Neighborhood for spatial derivative computation (only output
         -- the union of the middle row pixels and the middle column pixels)
         IMG0_0_1      : OUT std_logic;
         IMG0_1_0      : OUT std_logic;
         IMG0_1_1      : OUT std_logic;
         IMG0_1_2      : OUT std_logic;
         IMG0_2_1      : OUT std_logic;
         -- IMG1 Center pixel value for temporal derivative computation
         IMG1_1_1      : OUT std_logic;
         -- Offset pixel coordinates for A/b matrix computation (offset to
         -- increase numerical accuracy, corrected later in the pipeline)
         TRANS_X_COORD : OUT std_logic;
         TRANS_Y_COORD : OUT std_logic;

         FSCS_VALID : OUT std_logic);
END fetch_stage;

ARCHITECTURE Behavioral OF fetch_stage IS
  COMPONENT conv_pixel_ordering IS
                                  GENERIC (
                                    WIDTH            :     integer := 4;
                                    HEIGHT           :     integer := 4;
                                    CONV_HEIGHT      :     integer := 3;
                                    WIDTH_BITS       :     integer := 10;
                                    HEIGHT_BITS      :     integer := 10;
                                    CONV_HEIGHT_BITS :     integer := 3);
                                PORT ( CLK           : IN  std_logic;
                                       CLKEN         : IN  std_logic;
                                       RST           : IN  std_logic;
                                       MEM_ADDR      : OUT std_logic_vector (WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
                                       X_COORD       : OUT std_logic_vector (WIDTH_BITS-1 DOWNTO 0);
                                       Y_COORD       : OUT std_logic_vector (HEIGHT_BITS-1 DOWNTO 0);
                                       DATA_VALID    : OUT std_logic;
                                       DONE          : OUT std_logic);
  END COMPONENT;

  COMPONENT affine_coord_transform IS
                                     PORT ( CLK      : IN  std_logic;
                                            RST      : IN  std_logic;
                                        -- 1:10:14
                                            X_COORD  : IN  std_logic_vector (24 DOWNTO 0);
                                            Y_COORD  : IN  std_logic_vector (24 DOWNTO 0);
                                        -- 1:5:12 Format
                                            H_0_0    : IN  std_logic_vector (17 DOWNTO 0);
                                            H_1_0    : IN  std_logic_vector (17 DOWNTO 0);
                                            H_0_1    : IN  std_logic_vector (17 DOWNTO 0);
                                            H_1_1    : IN  std_logic_vector (17 DOWNTO 0);
                                        -- 1:10:14 Format 
                                            H_0_2    : IN  std_logic_vector (24 DOWNTO 0);
                                            H_1_2    : IN  std_logic_vector (24 DOWNTO 0);
                                        -- 1:16:8 Format
                                            XP_COORD : OUT std_logic_vector (32 DOWNTO 0);
                                            YP_COORD : OUT std_logic_vector (32 DOWNTO 0);

                                            OUTPUT_VALID : OUT std_logic;
                                            INPUT_VALID  : IN  std_logic);
  END COMPONENT;
  COMPONENT mem_addr_selector IS
                                PORT ( CLK               : IN  std_logic;
                                       RST               : IN  std_logic;
                                       PIXEL_STATE       : IN  std_logic_vector(0 DOWNTO 0);
                                       MEM_ADDR0         : IN  std_logic_vector(0 DOWNTO 0);
                                       MEM_ADDR1         : IN  std_logic_vector(0 DOWNTO 0);
                                       MEM_ADDROFF0      : IN  std_logic_vector(0 DOWNTO 0);
                                       MEM_ADDROFF1      : IN  std_logic_vector(0 DOWNTO 0);
                                       MEM_ADDR          : OUT std_logic_vector(0 DOWNTO 0);
                                       PIXGEN_CLKEN      : OUT std_logic);
  END COMPONENT;

BEGIN
-- Parameter ROM: Holds parameters that vary depending on the pyramid level.
-- (Maximum X/Y image coordinates, X/Y Offset Values (to produce a zero mean of
-- pixel coordinates)), level/img offsets, and width*3 values(for conv.
-- coordinate generation). This only loads the new value on RST.
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN      -- rising clock edge
      IF RST = '1' THEN                  -- synchronous reset (active high)
        CASE LEVEL IS
          WHEN 0                     =>  -- 720x480
            x_coord_trans <=;            -- TODO Compute translation values
            y_coord_trans <=;
            img0_offset   <=;
            img1_offset   <=;
            triple_width  <=;
          WHEN 1                     =>  -- 360x240
            x_coord_trans <=;
            y_coord_trans <=;
            img0_offset   <=;
            img1_offset   <=;
            triple_width  <=;
          WHEN 2                     =>  -- 180x120
            x_coord_trans <=;
            y_coord_trans <=;
            img0_offset   <=;
            img1_offset   <=;
            triple_width  <=;
          WHEN 3                     =>  -- 90x60
            x_coord_trans <=;
            y_coord_trans <=;
            img0_offset   <=;
            img1_offset   <=;
            triple_width  <=;
          WHEN 4                     =>  -- 45x30
            x_coord_trans <=;
            y_coord_trans <=;
            img0_offset   <=;
            img1_offset   <=;
            triple_width  <=;
          WHEN OTHERS                =>
            x_coord_trans <= (OTHERS => '0');
            y_coord_trans <= (OTHERS => '0');
            img0_offset   <= (OTHERS => '0');
            img1_offset   <= (OTHERS => '0');
            triple_width  <= (OTHERS => '0');
        END CASE;
      END IF;
    END IF;
  END PROCESS;

-- Convolution Pixel Stream: Stream pixel coordinates in a convolution pattern.
  conv_pixel_ordering_i : conv_pixel_ordering
    PORT MAP ( CLK        => CLK,
               CLKEN      => pixgen_clken,  -- TODO Hookup to memory selector
               RST        => RST,
               MEM_ADDR   => coord_gen_mem_addr,
               PIX_STATE  => coord_gen_state,  -- TODO Implement, 0=above cur pixel, 1=
                                        -- current pixel, 2=below cur pixel for
                                        -- 3x3
               X_COORD    => x_coord,
               Y_COORD    => y_coord,
               DATA_VALID => coord_valid,
               DONE       => coord_gen_done);

-- Current Pixel Coord Buffer: Store current pixel coordinates (the center of
-- the convolution).
-- NOTE: This assumes that the pixel generator will never be halted (CLKEN='0') on the center pixel value.
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        coord_buff_x      <= (OTHERS => '0');
        coord_buff_y      <= (OTHERS => '0');
      ELSE
        IF coord_gen_state = "01" THEN
          coord_buff_x(1) <= x_coord;
          coord_buff_y(1) <= y_coord;
          coord_buff_x(0) <= coord_buff_x(1);
          coord_buff_y(0) <= coord_buff_y(1);
        END IF;
      END IF;
    END IF;
  END PROCESS;

-- Affine Transform: Warp current pixel coordinate using H.
  affine_coord_transform_i : affine_coord_transform
    PORT MAP ( CLK         => CLK,
               RST         => RST,
               INPUT_VALID => coord_valid,
               X_COORD     => coord_buff_x(0),
               Y_COORD     => coord_buff_y(0),
               IMG_HEIGHT  => img_height,  -- TODO Hook these up to ROM
               IMG_WIDTH   => img_width,

               H_0_0 => h_0_0_reg,      -- TODO Correct the precisions for
                                        -- these internally
               H_1_0 => h_1_0_reg,
               H_0_1 => h_0_1_reg,
               H_1_1 => h_1_1_reg,

               H_0_2 => h_0_2_reg,
               H_1_2 => h_1_2_reg,

               XP_COORD     => xp_coord,
               YP_COORD     => yp_coord,
               OUTPUT_VALID => warp_coord_valid);

-- Round Transformed Coords: Round to the nearest whole coordinate.
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        xp_coord_round   <= (OTHERS => '0');
        yp_coord_round   <= (OTHERS => '0');
      ELSE
        IF xp_coord(0) = '0' THEN
          xp_coord_round <= xp_coord(top-1 DOWNTO 1);  -- TODO Replace top with
                                        -- correct value
        ELSE
          xp_coord_round <= xp_coord(top-1 DOWNTO 1) + 1;
        END IF;
        IF yp_coord(0) = '0' THEN
          yp_coord_round <= yp_coord(top-1 DOWNTO 1);
        ELSE
          yp_coord_round <= yp_coord(top-1 DOWNTO 1) + 1;
        END IF;
      END IF;
    END IF;
  END PROCESS;

-- 2D to 1D Coord Conversion: Convert warped 2D coords to 1D memory locations
-- (Y*WIDTH+X)
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        warped_width_offset <= (OTHERS => '0');
        warped_mem_addr     <= (OTHERS => '0');
      ELSE
        warped_width_offset <= img_width*yp_coord_round;
        warped_mem_addr     <= warped_width_offset + xp_coord_round;
      END IF;
    END IF;
  END PROCESS;

-- Translate Coords: Translate the image coordinates to reduce the
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        x_coord_trans <= (OTHERS => '0');
        y_coord_trans <= (OTHERS => '0');
      ELSE
        x_coord_trans <= coord_buff_x(0)+x_coord_trans;  -- TODO: Properly
                                        -- account for FP
        y_coord_trans <= coord_buff_y(0)+y_coord_trans;
      END IF;
    END IF;
  END PROCESS;

-- Memory Address Selector: Read 3 pixels from IMG0 using the coord generator'
-- s memory address, pause the coord generator, read 1 pixel from IMG1 using
-- the warped coord address
  mem_addr_selector_i : mem_addr_selector
    PORT MAP ( CLK          <= CLK,
               RST          <= RST,
               PIXEL_STATE  <= coord_gen_state,
               MEM_ADDR0    <= coord_gen_mem_addr,
               MEM_ADDR1    <= warped_mem_addr,
               MEM_ADDROFF0 <= img0_offset,
               MEM_ADDROFF1 <= img1_offset,
               MEM_ADDR     <= MEM_ADDR,
               PIXGEN_CLKEN <= pixgen_clken);

-- Pixel Buffer : Store the kernel neighborhood and update it with incoming
-- pixel values. Note that since there is a delay between when the read
-- command is asserted and when the valid data is available, the cur pixel
-- state will be pipelined to align the valid data with the pixel state.
--
-- TODO Create 3, 3 row shift registers to act as the local neighborhood of the
-- image.
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

