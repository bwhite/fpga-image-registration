library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pyramid_stage IS
  GENERIC (
    CONV_HEIGHT      : integer := 3;
    IMGSIZE_BITS     : integer := 10;
    PIXEL_BITS       : integer := 9;
    CONV_HEIGHT_BITS : integer := 2);
  PORT (CLK   : IN std_logic;
        RST   : IN std_logic;
        START : IN std_logic;

        MEM_VALUE        : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        MEM_INPUT_VALID  : IN  std_logic;
        MEM_READ         : OUT std_logic;
        MEM_ADDR         : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
        MEM_OUTPUT_VALID : OUT std_logic;
        BUSY             : OUT std_logic;
        DONE             : OUT std_logic);
end pyramid_stage;

architecture Behavioral of pyramid_stage is

begin
  IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        CASE LEVEL IS
          -- NOTE x/y_coord_trans is in 1:IMGSIZE_BITS:1 Format, thus constants
          -- are multiplied by 2
          WHEN "000" =>                 -- 720x480
            y_coord_trans    <= int_to_stdlvec(10#480#, IMGSIZE_BITS+1);  -- 240
            x_coord_trans    <= int_to_stdlvec(10#720#, IMGSIZE_BITS+1);  -- 360
            img0_offset      <= int_to_stdlvec(10#0#, 2*IMGSIZE_BITS);  -- 0
            img1_offset      <= int_to_stdlvec(10#345600#, 2*IMGSIZE_BITS);  -- 345,600
            img_height       <= int_to_stdlvec(10#480#, IMGSIZE_BITS);  -- 480
            img_width        <= int_to_stdlvec(10#720#, IMGSIZE_BITS);  -- 720
            img_width_offset <= int_to_stdlvec(10#1439#, 2*IMGSIZE_BITS);  -- 1439 (CONV_HEIGHT-1)*WIDTH-1
            initial_mem_addr <= int_to_stdlvec(10#721#, 2*IMGSIZE_BITS);  -- 721 WIDTH+1

          WHEN "001" =>                 -- 360x240
            y_coord_trans    <= int_to_stdlvec(10#240#, IMGSIZE_BITS+1);  -- 120
            x_coord_trans    <= int_to_stdlvec(10#360#, IMGSIZE_BITS+1);  -- 180
            img0_offset      <= int_to_stdlvec(10#691200#, 2*IMGSIZE_BITS);  -- 691,200
            img1_offset      <= int_to_stdlvec(10#777600#, 2*IMGSIZE_BITS);  -- 777,600
            img_height       <= int_to_stdlvec(10#240#, IMGSIZE_BITS);  -- 240
            img_width        <= int_to_stdlvec(10#360#, IMGSIZE_BITS);  -- 360
            img_width_offset <= int_to_stdlvec(10#719#, 2*IMGSIZE_BITS);  -- 719
            initial_mem_addr <= int_to_stdlvec(10#361#, 2*IMGSIZE_BITS);  -- 361

          WHEN "010" =>                 -- 180x120
            y_coord_trans    <= int_to_stdlvec(10#120#, IMGSIZE_BITS+1);  -- 60
            x_coord_trans    <= int_to_stdlvec(10#180#, IMGSIZE_BITS+1);  -- 90
            img0_offset      <= int_to_stdlvec(10#864000#, 2*IMGSIZE_BITS);  -- 864,000
            img1_offset      <= int_to_stdlvec(10#885600#, 2*IMGSIZE_BITS);  -- 885,600
            img_height       <= int_to_stdlvec(10#120#, IMGSIZE_BITS);  -- 120
            img_width        <= int_to_stdlvec(10#180#, IMGSIZE_BITS);  -- 180
            img_width_offset <= int_to_stdlvec(10#359#, 2*IMGSIZE_BITS);  -- 359
            initial_mem_addr <= int_to_stdlvec(10#181#, 2*IMGSIZE_BITS);  -- 181
            
          WHEN "011" =>                 -- 90x60
            y_coord_trans    <= int_to_stdlvec(10#60#, IMGSIZE_BITS+1);   -- 30
            x_coord_trans    <= int_to_stdlvec(10#90#, IMGSIZE_BITS+1);   -- 45
            img0_offset      <= int_to_stdlvec(10#907200#, 2*IMGSIZE_BITS);  -- 907,200
            img1_offset      <= int_to_stdlvec(10#912600#, 2*IMGSIZE_BITS);  -- 912,600
            img_height       <= int_to_stdlvec(10#60#, IMGSIZE_BITS);     -- 60
            img_width        <= int_to_stdlvec(10#90#, IMGSIZE_BITS);     -- 90
            img_width_offset <= int_to_stdlvec(10#179#, 2*IMGSIZE_BITS);  -- 179
            initial_mem_addr <= int_to_stdlvec(10#91#, 2*IMGSIZE_BITS);   -- 91
            
          WHEN "100" =>                 -- 45x30
            y_coord_trans    <= int_to_stdlvec(10#30#, IMGSIZE_BITS+1);  -- 15
            x_coord_trans    <= int_to_stdlvec(10#45#, IMGSIZE_BITS+1);  -- 22.5
            img0_offset      <= int_to_stdlvec(10#918000#, 2*IMGSIZE_BITS);  -- 918,000
            img1_offset      <= int_to_stdlvec(10#919350#, 2*IMGSIZE_BITS);  -- 919,350
            img_height       <= int_to_stdlvec(10#30#, IMGSIZE_BITS);    -- 30
            img_width        <= int_to_stdlvec(10#45#, IMGSIZE_BITS);    -- 45
            img_width_offset <= int_to_stdlvec(10#89#, 2*IMGSIZE_BITS);  -- 89
            initial_mem_addr <= int_to_stdlvec(10#46#, 2*IMGSIZE_BITS);  -- 46
            
          WHEN "101" =>                 -- 5x5 TESTING ONLY!!!
            y_coord_trans    <= int_to_stdlvec(10#5#, IMGSIZE_BITS+1);  -- 2.5
            x_coord_trans    <= int_to_stdlvec(10#5#, IMGSIZE_BITS+1);  -- 2.5
            img0_offset      <= int_to_stdlvec(10#918000#, 2*IMGSIZE_BITS);  -- 920,700
            img1_offset      <= int_to_stdlvec(10#919350#, 2*IMGSIZE_BITS);  -- 920,725
            img_height       <= int_to_stdlvec(10#5#, IMGSIZE_BITS);    -- 5
            img_width        <= int_to_stdlvec(10#5#, IMGSIZE_BITS);    -- 5
            img_width_offset <= int_to_stdlvec(10#9#, 2*IMGSIZE_BITS);  -- 9
            initial_mem_addr <= int_to_stdlvec(10#6#, 2*IMGSIZE_BITS);  -- 6
          WHEN "110" =>                 -- 6x6 TESTING ONLY!!!
            y_coord_trans    <= int_to_stdlvec(10#6#, IMGSIZE_BITS+1);  -- 3
            x_coord_trans    <= int_to_stdlvec(10#6#, IMGSIZE_BITS+1);  -- 3
            img0_offset      <= int_to_stdlvec(10#918000#, 2*IMGSIZE_BITS);  -- 920,700
            img1_offset      <= int_to_stdlvec(10#919350#, 2*IMGSIZE_BITS);  -- 920,725
            img_height       <= int_to_stdlvec(10#6#, IMGSIZE_BITS);    -- 6
            img_width        <= int_to_stdlvec(10#6#, IMGSIZE_BITS);    -- 6
            img_width_offset <= int_to_stdlvec(10#11#, 2*IMGSIZE_BITS);  -- 11
            initial_mem_addr <= int_to_stdlvec(10#7#, 2*IMGSIZE_BITS);  -- 7

          WHEN OTHERS =>
            y_coord_trans    <= (OTHERS => '0');
            x_coord_trans    <= (OTHERS => '0');
            img0_offset      <= (OTHERS => '0');
            img1_offset      <= (OTHERS => '0');
            img_height       <= (OTHERS => '0');
            img_width        <= (OTHERS => '0');
            img_width_offset <= (OTHERS => '0');
            initial_mem_addr <= (OTHERS => '0');
        END CASE;
      END IF;
    END IF;
  END PROCESS;


    -- Convolution Pixel Stream: Stream pixel coordinates in a 2x2 convolution pattern.
    -- TODO Add ROW_SKIP feature
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

    -- Coord Gen Pause: Pause the coordinate generator for one CT periodically
    -- to allow for storage back to the RAM

      
    -- RAM Signal Generator
    -- TODO Implement, hookup address,read/write,valid,etc
    -- Compute true address w/ offset

      

    -- Buffer 2x2 Region

      
    -- Perform a 2x2 smoothing on the region


    -- Store every other valid signal (i.e.,every other column, use the first
    -- valid signal every new row)
      
end Behavioral;

