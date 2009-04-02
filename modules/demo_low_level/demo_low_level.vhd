LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

LIBRARY UNIMACRO;
USE UNIMACRO.vcomponents.ALL;

ENTITY demo_low_level IS
  GENERIC (
    IMGSIZE_BITS : integer := 10;
    PIXEL_BITS   : integer := 9);
  PORT (CLK : IN std_logic;

        -- IO
        RST      : IN std_logic;
        GPIO_SW  : IN std_logic_vector(4 DOWNTO 0);
        GPIO_DIP : IN std_logic_vector(7 DOWNTO 0);

        -- I2C Signals
        I2C_SDA_I : IN  std_logic;      -- NOT Used
        I2C_SDA_O : OUT std_logic;      -- Tied to 0
        I2C_SDA_T : OUT std_logic;      -- Actual data signal

        I2C_SCL_I : IN  std_logic;      -- NOT Used
        I2C_SCL_O : OUT std_logic;      -- Tied to 0
        I2C_SCL_T : OUT std_logic;      -- Actual data signal

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
        SRAM_CLK_FB : IN  std_logic;
        SRAM_CLK    : OUT std_logic;
        SRAM_ADDR   : OUT std_logic_vector (17 DOWNTO 0);
        SRAM_WE_B   : OUT std_logic;
        SRAM_BW_B   : OUT std_logic_vector (3 DOWNTO 0);
        SRAM_CS_B   : OUT std_logic;
        SRAM_OE_B   : OUT std_logic;
        --SRAM_DATA : INOUT std_logic_vector (35 DOWNTO 0)
        SRAM_DATA_I : IN  std_logic_vector (35 DOWNTO 0);
        SRAM_DATA_O : OUT std_logic_vector (35 DOWNTO 0);
        SRAM_DATA_T : OUT std_logic;
        H_0_0       : OUT std_logic_vector(29 DOWNTO 0);
        H_0_1       : OUT std_logic_vector(29 DOWNTO 0);
        H_0_2       : OUT std_logic_vector(29 DOWNTO 0);
        H_1_0       : OUT std_logic_vector(29 DOWNTO 0);
        H_1_1       : OUT std_logic_vector(29 DOWNTO 0);
        H_1_2       : OUT std_logic_vector(29 DOWNTO 0);
        BUSY        : OUT std_logic;
        OUT_STATE   : OUT std_logic_vector(2 DOWNTO 0)
        );
END demo_low_level;

ARCHITECTURE Behavioral OF demo_low_level IS
  COMPONENT pixel_memory_controller IS
    PORT (CLK : IN std_logic;
          RST : IN std_logic;

          -- Control signals
          ADDR             : IN  std_logic_vector (19 DOWNTO 0);
          WE_B             : IN  std_logic;
          CS_B             : IN  std_logic;
          BW_B             : IN  std_logic_vector(3 DOWNTO 0);
          PIXEL_WRITE      : IN  std_logic_vector (8 DOWNTO 0);
          PIXEL_READ       : OUT std_logic_vector(8 DOWNTO 0);
          PIXEL_READ_VALID : OUT std_logic;

          -- SRAM Connections
          SRAM_ADDR   : OUT std_logic_vector (17 DOWNTO 0);
          SRAM_WE_B   : OUT std_logic;
          SRAM_BW_B   : OUT std_logic_vector (3 DOWNTO 0);
          SRAM_CS_B   : OUT std_logic;
          SRAM_OE_B   : OUT std_logic;
          SRAM_DATA_I : IN  std_logic_vector (35 DOWNTO 0);
          SRAM_DATA_O : OUT std_logic_vector (35 DOWNTO 0);
          SRAM_DATA_T : OUT std_logic);
  END COMPONENT;

  COMPONENT pipeline_buffer IS
    GENERIC (
      WIDTH         : integer := 1;
      STAGES        : integer := 1;
      DEFAULT_VALUE : integer := 2#0#);
    PORT (CLK   : IN  std_logic;
          RST   : IN  std_logic;
          CLKEN : IN  std_logic;
          DIN   : IN  std_logic_vector(WIDTH-1 DOWNTO 0);
          DOUT  : OUT std_logic_vector(WIDTH-1 DOWNTO 0));
  END COMPONENT;

  COMPONENT memory_dump IS
    GENERIC (
      BASE_OFFSET  : integer := 0;
      COUNT_LENGTH : integer := 307200;
      COUNTER_BITS : integer := 20;
      ADDR_BITS    : integer := 20
      );
    PORT (CLK           : IN  std_logic;
          RST           : IN  std_logic;
          MEM_ADDR      : OUT std_logic_vector(ADDR_BITS-1 DOWNTO 0);
          MEM_OUT_VALID : OUT std_logic;
          DONE          : OUT std_logic
          );
  END COMPONENT;

  COMPONENT i2c_video_programmer IS
    PORT (CLK100Mhz : IN  std_logic;
          RST       : IN  std_logic;
          I2C_SDA   : OUT std_logic;
          I2C_SCL   : OUT std_logic);
  END COMPONENT;

  COMPONENT image_store_stage IS
    GENERIC (
      IMGSIZE_BITS : integer := 10;
      PIXEL_BITS   : integer := 9;
      BASE_OFFSET  : integer := 0);
    PORT (CLK       : IN std_logic;
          RST       : IN std_logic;
          -- VGA Chip Connections
          VGA_Y     : IN std_logic_vector (7 DOWNTO 0);
          VGA_HSYNC : IN std_logic;
          VGA_VSYNC : IN std_logic;
          INC_EXEC  : IN std_logic;
          INC       : IN std_logic;
          INC_HORIZ : IN std_logic;
          CALIBRATE : IN std_logic;

          -- External Memory Connections
          -- 0:0:PIXEL_BITS Format
          MEM_OUT_VALUE    : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          MEM_ADDR         : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
          MEM_OUTPUT_VALID : OUT std_logic;
          DONE             : OUT std_logic
          );
  END COMPONENT;

  COMPONENT image_display_stage IS
    GENERIC (
      IMGSIZE_BITS : integer := 10;
      PIXEL_BITS   : integer := 9;
      BASE_OFFSET  : integer := 0);
    PORT (CLK : IN std_logic;
          RST : IN std_logic;

          -- RAM Signals
          MEM_IN_VALUE  : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          MEM_ADDR      : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
          X_COORD       : OUT std_logic_vector(IMGSIZE_BITS-1 DOWNTO 0);
          Y_COORD       : OUT std_logic_vector(IMGSIZE_BITS-1 DOWNTO 0);
          MEM_OUT_VALID : OUT std_logic;

          -- DVI Signals
          DVI_D       : OUT std_logic_vector (11 DOWNTO 0);
          DVI_H       : OUT std_logic;
          DVI_V       : OUT std_logic;
          DVI_DE      : OUT std_logic;
          DVI_XCLK_N  : OUT std_logic;
          DVI_XCLK_P  : OUT std_logic;
          DVI_RESET_B : OUT std_logic);
  END COMPONENT;

  COMPONENT smooth_stage IS
    GENERIC (
      IMGSIZE_BITS : integer := 10;
      PIXEL_BITS   : integer := 9;
      MEM_DELAY    : integer := 4);
    PORT (CLK   : IN std_logic;
          RST   : IN std_logic;
          LEVEL : IN std_logic_vector(2 DOWNTO 0);

          MEM_PIXEL_READ   : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          MEM_ADDR         : OUT std_logic_vector (2*IMGSIZE_BITS-1 DOWNTO 0);
          MEM_PIXEL_WRITE  : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          MEM_RE           : OUT std_logic;
          MEM_BW_B         : OUT std_logic_vector(3 DOWNTO 0);
          MEM_OUTPUT_VALID : OUT std_logic;
          DONE             : OUT std_logic);
  END COMPONENT;

  COMPONENT registration_controller IS
    GENERIC (
      IMGSIZE_BITS : integer := 10;
      PIXEL_BITS   : integer := 9);
    PORT (CLK              : IN  std_logic;
          RST              : IN  std_logic;
          H_0_0            : IN  std_logic_vector(29 DOWNTO 0);
          H_0_1            : IN  std_logic_vector(29 DOWNTO 0);
          H_1_0            : IN  std_logic_vector(29 DOWNTO 0);
          H_1_1            : IN  std_logic_vector(29 DOWNTO 0);
          -- Translation
          -- 1:10:11 Format 
          H_0_2            : IN  std_logic_vector(29 DOWNTO 0);
          H_1_2            : IN  std_logic_vector(29 DOWNTO 0);
          -- Memory Connections
          MEM_VALUE        : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          MEM_INPUT_VALID  : IN  std_logic;
          MEM_ADDR         : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
          MEM_BW_B         : OUT std_logic_vector(3 DOWNTO 0);
          MEM_OUTPUT_VALID : OUT std_logic;

          H_0_0_O      : OUT std_logic_vector(29 DOWNTO 0);
          H_0_1_O      : OUT std_logic_vector(29 DOWNTO 0);
          H_0_2_O      : OUT std_logic_vector(29 DOWNTO 0);
          H_1_0_O      : OUT std_logic_vector(29 DOWNTO 0);
          H_1_1_O      : OUT std_logic_vector(29 DOWNTO 0);
          H_1_2_O      : OUT std_logic_vector(29 DOWNTO 0);
          OUTPUT_VALID : OUT std_logic
          );
  END COMPONENT;

  SIGNAL rst_not, clk200mhz_buf, clk_int, clk_buf, sram_int_clk, sram_int_clk_unbuf, clk_intbuf, we_b, we_b_next, image_store_done, image_store_mem_output_valid, image_display_mem_output_valid, cs_b, cs_b_next, image_store_rst, smooth_rst, smooth_rst_reg, compute_affine_rst_reg, compute_affine_rst, compute_affine_done, smooth_re, compute_affine_re, smooth_done, smooth_output_valid, compute_affine_output_valid, manual_offset_enabled, cs_mem_read_valid, vga_calibrate, cs_we_b : std_logic;

  SIGNAL memory_dump_done, memory_dump_rst, memory_dump_mem_out_valid, memory_dump_rst_reg : std_logic;

  SIGNAL image_store_mem_addr, mem_addr_next, image_store_mem_addr_fifo, image_display_mem_addr, memory_dump_mem_addr, mem_addr, smooth_addr, compute_affine_addr, manual_offset, cs_mem_addr_split : std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
  SIGNAL mem_out_value, image_store_mem_out_value_fifo, mem_write_value, mem_write_value_next, mem_read_value, smooth_pixel_write, cs_mem_read, cs_mem_write_value                                  : std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
  TYPE   current_state IS (IMAGE_STORE, IMAGE_DISPLAY, SMOOTH, IDLE, MEM_DUMP_WRITE, MEM_DUMP_READ, COMPUTE_AFFINE, CLEAR_H);
  SIGNAL cur_state, cur_state_next                                                                                                                                                                  : current_state := IDLE;

  SIGNAL sram_addr_wire                                    : std_logic_vector(17 DOWNTO 0);
  SIGNAL image_display_fifo_mem_addr                       : std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
  SIGNAL image_display_value_fifo                          : std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
  SIGNAL smooth_bw_b, compute_affine_bw_b, bw_b, bw_b_next : std_logic_vector(3 DOWNTO 0);
  SIGNAL gpio_sw_reg0, gpio_sw_reg1                        : std_logic_vector(4 DOWNTO 0);
  SIGNAL gpio_dip_reg0, gpio_dip_reg1                      : std_logic_vector(7 DOWNTO 0);

  -- Pixel Memory Controller Signals
  SIGNAL mem_read_valid : std_logic;

  -- Image Store FIFO Signals
  SIGNAL image_store_fifo_read_count, image_store_fifo_write_count : std_logic_vector(8 DOWNTO 0);
  SIGNAL image_store_fifo_do, image_store_fifo_di                  : std_logic_vector(35 DOWNTO 0);
  SIGNAL image_store_fifo_empty, image_store_fifo_re               : std_logic;

  -- DVI Signals
  SIGNAL clk_dvi_fb, clk_dvi_fb_unbuf, dvi_pixel_clk, image_display_fifo_re, image_display_fifo_re_buf, image_display_fifo_empty, image_display_fifo_rst, image_display_fifo_we, dvi_h_wire, dvi_v_wire : std_logic;
  SIGNAL image_display_fifo_read_count0, image_display_fifo_write_count0, image_display_fifo_read_count1, image_display_fifo_write_count1                                                               : std_logic_vector(8 DOWNTO 0);
  SIGNAL i2c_sda_i_reg, i2c_scl_i_reg, i2c_scl_t_wire, i2c_sda_t_wire                                                                                                                                   : std_logic;
  -- Homographies
  SIGNAL h_0_0w, h_0_1w, h_0_2w, h_1_0w, h_1_1w, h_1_2w                                                                                                                                                 : std_logic_vector(29 DOWNTO 0);
  SIGNAL h_0_0p, h_1_1p                                                                                                                                                                                 : std_logic_vector(29 DOWNTO 0) := "000000000010000000000000000000";
  SIGNAL h_0_1p, h_0_2p, h_1_0p, h_1_2p                                                                                                                                                                 : std_logic_vector(29 DOWNTO 0) := (OTHERS => '0');
--  SIGNAL SRAM_DATA_I, SRAM_DATA_O : std_logic_vector(35 DOWNTO 0);
--  SIGNAL SRAM_DATA_T : std_logic;
  ATTRIBUTE KEEP                                                                                                                                                                                        : string;
  ATTRIBUTE keep OF memory_dump_mem_addr, cs_mem_addr_split, cs_mem_read, cs_mem_read_valid, cs_mem_write_value, cs_we_b, h_0_0, h_0_1, h_0_2, h_1_0, h_1_1, h_1_2, compute_affine_done                 : SIGNAL IS "true";
  
BEGIN
-------------------------------------------------------------------------------
-- CLK Management
  rst_not <= NOT RST;

  H_0_0 <= h_0_0p;
  H_0_1 <= h_0_1p;
  H_0_2 <= h_0_2p;
  H_1_0 <= h_1_0p;
  H_1_1 <= h_1_1p;
  H_1_2 <= h_1_2p;

  DCM_BASE_internal : DCM_BASE
    GENERIC MAP (
      CLKIN_PERIOD          => 10.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,  -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      --CLKIN_DIVIDE_BY_2     => true,
      DFS_FREQUENCY_MODE    => "LOW",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "LOW",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => clk_int,                 -- 0 degree DCM CLK ouptput
      CLKFB => clk_intbuf,              -- DCM clock feedback
      CLKIN => CLK,                   -- Clock input (from IBUFG, BUFG or DCM)
      RST   => rst_not                  -- DCM asynchronous reset input
      );

  -- Buffer Internal Clock Signal
  BUFG_inst : BUFG
    PORT MAP (
      O => clk_intbuf,                  -- Clock buffer output
      I => clk_int                      -- Clock buffer input
      );

  -- Buffer and Deskew SRAM CLK
  DCM_BASE_sram : DCM_BASE
    GENERIC MAP (
      CLKIN_PERIOD          => 10.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,  -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "LOW",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "LOW",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => sram_int_clk_unbuf,      -- 0 degree DCM CLK output
      CLKFB => SRAM_CLK_FB,             -- DCM clock feedback
      CLKIN => clk_intbuf,            -- Clock input (from IBUFG, BUFG or DCM)
      RST   => rst_not                  -- DCM asynchronous reset input
      );
  -- Buffer Internal Clock Signal
  BUFG_sram : BUFG
    PORT MAP (
      O => sram_int_clk,                -- Clock buffer output
      I => sram_int_clk_unbuf           -- Clock buffer input
      );

  SRAM_CLK <= sram_int_clk;

  DCM_BASE_dvi : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 4.0,  -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKIN_PERIOD          => 10.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,  -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "LOW",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "LOW",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => clk_dvi_fb_unbuf,        -- 0 degree DCM CLK ouptput
      CLKDV => dvi_pixel_clk,
      CLKFB => clk_dvi_fb,              -- DCM clock feedback
      CLKIN => clk_intbuf,           -- Clock input (from IBUFG, BUFG or DCM)
      RST   => rst_not                  -- DCM asynchronous reset input
      );

  BUFG_dvi : BUFG
    PORT MAP (
      O => clk_dvi_fb,                  -- Clock buffer output
      I => clk_dvi_fb_unbuf             -- Clock buffer input
      );

  PROCESS (cur_state) IS
  BEGIN  -- PROCESS
    IF cur_state = IDLE THEN
      BUSY <= '0';
    ELSE
      BUSY <= '1';
    END IF;
    CASE cur_state IS
      WHEN IDLE =>
        OUT_STATE <= "000";
      WHEN MEM_DUMP_WRITE =>
        OUT_STATE <= "001";
      WHEN MEM_DUMP_READ =>
        OUT_STATE <= "010";
      WHEN IMAGE_STORE =>
        OUT_STATE <= "011";
      WHEN IMAGE_DISPLAY =>
        OUT_STATE <= "100";
      WHEN SMOOTH =>
        OUT_STATE <= "101";
      WHEN COMPUTE_AFFINE =>
        OUT_STATE <= "110";
      WHEN OTHERS =>
        OUT_STATE <= "000";
    END CASE;
  END PROCESS;

-------------------------------------------------------------------------------
-- Main State Machine
-- DIP Switch selects state, center button press activates state
--Controls activity of IMAGE_STORE_STAGE, IMAGE_DISPLAY_STAGE, MEMORY_DUMP
  PROCESS (clk_intbuf) IS
  BEGIN  -- PROCESS
    IF clk_intbuf'event AND clk_intbuf = '1' THEN  -- rising clock edge
      IF rst_not = '1' THEN
        h_0_0p <= "000000000010000000000000000000";
        h_0_1p <= (OTHERS => '0');
        h_0_2p <= (OTHERS => '0');
        h_1_0p <= (OTHERS => '0');
        h_1_1p <= "000000000010000000000000000000";
        h_1_2p <= (OTHERS => '0');
      ELSIF compute_affine_done = '1' THEN
        h_0_0p <= h_0_0w;
        h_0_1p <= h_0_1w;
        h_0_2p <= h_0_2w;
        h_1_0p <= h_1_0w;
        h_1_1p <= h_1_1w;
        h_1_2p <= h_1_2w;
      END IF;

      i2c_scl_i_reg      <= I2C_SCL_I;
      i2c_sda_i_reg      <= I2C_SDA_I;
      cs_mem_read        <= mem_read_value;
      cs_mem_read_valid  <= mem_read_valid;
      cs_mem_write_value <= mem_write_value;
      cs_we_b            <= we_b;
      gpio_dip_reg0      <= GPIO_DIP;
      gpio_dip_reg1      <= gpio_dip_reg0;
      gpio_sw_reg0       <= gpio_sw;
      gpio_sw_reg1       <= gpio_sw_reg0;
      cs_mem_addr_split  <= mem_addr;

      IF rst_not = '1' THEN             -- synchronous reset (active high)
        cur_state     <= IDLE;
        manual_offset <= (OTHERS => '0');
      ELSE
        -- cur_state_next is one CT behind cur_state
        cur_state_next <= cur_state;
        CASE cur_state IS
          WHEN IDLE =>  --------------------------------------------------------
            memory_dump_rst_reg    <= '1';
            image_store_rst        <= '1';
            smooth_rst_reg         <= '1';
            compute_affine_rst_reg <= '1';
            -- Switch states on button press
            IF gpio_sw_reg1(4) = '1' THEN
              -- Lower 6 bits select mode, upper bit selects image slot, next
              -- bit selects offset
              CASE gpio_dip_reg1(5 DOWNTO 0) IS
                WHEN "000001" =>
                  cur_state <= MEM_DUMP_WRITE;
                WHEN "000010" =>
                  cur_state <= MEM_DUMP_READ;
                WHEN "000100" =>
                  cur_state <= IMAGE_STORE;
                WHEN "001000" =>
                  cur_state <= IMAGE_DISPLAY;
                WHEN "010000" =>
                  cur_state <= SMOOTH;
                WHEN "011000" =>
                  cur_state <= COMPUTE_AFFINE;
                WHEN "111111" =>
                  cur_state <= CLEAR_H;
                WHEN OTHERS => NULL;
              END CASE;
            END IF;
            we_b_next            <= '1';
            cs_b_next            <= '1';
            mem_addr_next        <= (OTHERS => 'X');
            mem_write_value_next <= (OTHERS => 'X');
            
          WHEN MEM_DUMP_WRITE =>  ----------------------------------------------
            memory_dump_rst_reg <= '0';
            IF memory_dump_done = '1' THEN
              cur_state <= IDLE;
            END IF;
            we_b_next     <= '0';
            cs_b_next     <= NOT memory_dump_mem_out_valid;
            mem_addr_next <= memory_dump_mem_addr;
            IF gpio_dip_reg1(7) = '0' THEN
              mem_write_value_next <= memory_dump_mem_addr(8 DOWNTO 0);
            ELSE
              mem_write_value_next <= std_logic_vector(unsigned(memory_dump_mem_addr(8 DOWNTO 0))+1);
            END IF;

            CASE memory_dump_mem_addr(1 DOWNTO 0) IS
              WHEN "00" =>
                bw_b_next <= "1110";
              WHEN "01" =>
                bw_b_next <= "1101";
              WHEN "10" =>
                bw_b_next <= "1011";
              WHEN "11" =>
                bw_b_next <= "0111";
              WHEN OTHERS => NULL;
            END CASE;

          WHEN MEM_DUMP_READ =>  -----------------------------------------------
            memory_dump_rst_reg <= '0';

            IF memory_dump_done = '1' THEN
              cur_state <= IDLE;
            END IF;
            we_b_next            <= '1';
            cs_b_next            <= NOT memory_dump_mem_out_valid;
            mem_addr_next        <= memory_dump_mem_addr;
            mem_write_value_next <= (OTHERS => 'X');

          WHEN IMAGE_STORE =>  -------------------------------------------------
            image_store_rst <= '0';
            IF image_store_done = '1'THEN
              cur_state <= IDLE;
            END IF;

            IF image_store_fifo_empty = '0' THEN
              image_store_fifo_re <= '1';  -- Read Values
            ELSE
              image_store_fifo_re <= '0';
            END IF;

            we_b_next            <= '0';
            cs_b_next            <= NOT image_store_fifo_re;
            mem_addr_next        <= image_store_mem_addr_fifo;
            mem_write_value_next <= image_store_mem_out_value_fifo;
            CASE image_store_mem_addr_fifo(1 DOWNTO 0) IS
              WHEN "00" =>
                bw_b_next <= "1110";
              WHEN "01" =>
                bw_b_next <= "1101";
              WHEN "10" =>
                bw_b_next <= "1011";
              WHEN "11" =>
                bw_b_next <= "0111";
              WHEN OTHERS => NULL;
            END CASE;
            
          WHEN IMAGE_DISPLAY =>  -----------------------------------------------
            -- If not empty then read a value, if it is empty when we try to
            -- read, then don't read from memory
            IF image_display_fifo_empty = '0' THEN
              image_display_fifo_re <= '1';  -- Read Values
            ELSE
              image_display_fifo_re <= '0';
            END IF;

            IF image_display_fifo_empty = '0' THEN
              image_display_fifo_re_buf <= image_display_fifo_re;  -- Read Values
            ELSE
              image_display_fifo_re_buf <= '0';
            END IF;

            IF gpio_sw_reg1(4) /= '1' OR gpio_dip_reg1(5 DOWNTO 0) /= "001000" THEN
              cur_state <= IDLE;
            END IF;

            we_b_next     <= '1';
            cs_b_next     <= NOT image_display_fifo_re_buf;
            mem_addr_next <= image_display_fifo_mem_addr;
          WHEN SMOOTH =>  ------------------------------------------------------
            smooth_rst_reg <= '0';
            IF smooth_done = '1'THEN
              cur_state <= IDLE;
            END IF;

          WHEN COMPUTE_AFFINE =>  ------------------------------------------------------
            compute_affine_rst_reg <= '0';
            IF compute_affine_done = '1'THEN
              cur_state <= IDLE;
            END IF;
          WHEN CLEAR_H =>
            h_0_0p    <= "000000000010000000000000000000";
            h_0_1p    <= (OTHERS => '0');
            h_0_2p    <= (OTHERS => '0');
            h_1_0p    <= (OTHERS => '0');
            h_1_1p    <= "000000000010000000000000000000";
            h_1_2p    <= (OTHERS => '0');
            cur_state <= IDLE;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END IF;
  END PROCESS;

  -- Multiplexer for memory IO
  PROCESS (cur_state_next, smooth_re, smooth_output_valid, smooth_addr, smooth_pixel_write, smooth_bw_b, we_b_next, cs_b_next, bw_b_next, mem_addr_next, mem_write_value_next) IS
    --   PROCESS (clk_intbuf) IS
  BEGIN  -- PROCESS
    CASE cur_state_next IS
      WHEN SMOOTH =>
        we_b <= smooth_re;
        cs_b <= NOT smooth_output_valid;
        bw_b <= smooth_bw_b;
        IF smooth_addr(19) = gpio_dip_reg1(7) THEN
          mem_addr(19) <= '0';
        ELSE
          mem_addr(19) <= '1';
        END IF;
        mem_addr(18 DOWNTO 0) <= smooth_addr(18 DOWNTO 0);
        mem_write_value       <= smooth_pixel_write;

      WHEN COMPUTE_AFFINE =>
        we_b <= '1';
        cs_b <= NOT compute_affine_output_valid;
        bw_b <= compute_affine_bw_b;
        IF compute_affine_addr(19) = gpio_dip_reg1(7) THEN
          mem_addr(19) <= '0';
        ELSE
          mem_addr(19) <= '1';
        END IF;
        mem_addr(18 DOWNTO 0) <= compute_affine_addr(18 DOWNTO 0);
        mem_write_value       <= (PIXEL_BITS-1 DOWNTO 0 => '0');

      WHEN OTHERS =>
        we_b                  <= we_b_next;
        cs_b                  <= cs_b_next;
        bw_b                  <= bw_b_next;
        mem_addr(19)          <= gpio_dip_reg1(7);
        mem_addr(18 DOWNTO 0) <= mem_addr_next(18 DOWNTO 0);
        mem_write_value       <= mem_write_value_next;
    END CASE;
  END PROCESS;


-------------------------------------------------------------------------------
-- Program Video In/Out Over I2C
  i2c_video_programmer_i : i2c_video_programmer
    PORT MAP (
      CLK100Mhz => clk_intbuf,
      RST       => rst_not,
      I2C_SDA   => I2C_SDA_T_wire,
      I2C_SCL   => I2C_SCL_T_wire);

  I2C_SDA_T <= i2c_sda_t_wire;
  I2C_SCL_T <= i2c_scl_t_wire;
  I2C_SDA_O <= '0';
  I2C_SCL_O <= '0';


-- VGA Calibrate
  vga_calibrate <= gpio_sw_reg1(0);
-------------------------------------------------------------------------------  
-- Image Store Stage
  image_store_stage_i : image_store_stage
    PORT MAP (
      CLK       => VGA_PIXEL_CLK,
      RST       => rst_not,             --image_store_rst,
      -- VGA Chip Connections
      VGA_Y     => VGA_Y_GREEN,
      VGA_HSYNC => VGA_HSYNC,
      VGA_VSYNC => VGA_VSYNC,
      INC_EXEC => gpio_sw_reg1(3),
      INC => gpio_sw_reg1(2),
      INC_HORIZ => gpio_sw_reg1(1),
      CALIBRATE        => vga_calibrate,
      -- External Memory Connections
      -- 0:0:PIXEL_BITS Format
      MEM_OUT_VALUE    => mem_out_value,
      MEM_ADDR         => image_store_mem_addr,
      MEM_OUTPUT_VALID => image_store_mem_output_valid,
      DONE             => image_store_done);


  -- Use FIFOs to buffer valid ADDR and Value signals on the VGA clock
  -- domain to be used by the ZBT RAM domain
  FIFO_DUALCLOCK_vgain : FIFO_DUALCLOCK_MACRO
    GENERIC MAP (
      DEVICE                  => "VIRTEX5",    -- Target Device: "VIRTEX5" 
      DATA_WIDTH              => 29,  -- Valid values are 4, 9, 18, 36 or 72 (72 only valid when FIFO_SIZE="36Kb")
      FIFO_SIZE               => "18Kb",  -- Target BRAM, "18Kb" or "36Kb" 
      FIRST_WORD_FALL_THROUGH => false)  -- Sets the FIFO FWFT to TRUE or FALSE
    PORT MAP (
      DO      => image_store_fifo_do,   -- Output data
      RDCOUNT => image_store_fifo_read_count,
      WRCOUNT => image_store_fifo_write_count,
      EMPTY   => image_store_fifo_empty,  -- Output empty
      DI      => image_store_fifo_di,   -- Input data
      RDCLK   => clk_intbuf,            -- Input read clock
      RDEN    => image_store_fifo_re,   -- Input read enable
      RST     => image_store_rst,       -- Input reset
      WRCLK   => VGA_PIXEL_CLK,         -- Input write clock
      WREN    => image_store_mem_output_valid  -- Input write enable
      );

  -- Pack data into fifo in/out signals
  image_store_fifo_di            <= mem_out_value&image_store_mem_addr;
  image_store_mem_addr_fifo      <= image_store_fifo_do(19 DOWNTO 0);
  image_store_mem_out_value_fifo <= image_store_fifo_do(28 DOWNTO 20);

-------------------------------------------------------------------------------
-- Image Display Stage
  image_display_stage_i : image_display_stage
    PORT MAP (
      CLK           => dvi_pixel_clk,
      RST           => rst_not,
      MEM_IN_VALUE  => image_display_value_fifo,
      MEM_ADDR      => image_display_mem_addr,
      MEM_OUT_VALID => image_display_mem_output_valid,
      DVI_D         => DVI_D,
      DVI_H         => dvi_h_wire,
      DVI_V         => dvi_v_wire,
      DVI_DE        => DVI_DE,
      DVI_XCLK_P    => DVI_XCLK_P,
      DVI_XCLK_N    => DVI_XCLK_N,
      DVI_RESET_B   => DVI_RESET_B);
  DVI_H <= dvi_h_wire;
  DVI_V <= dvi_v_wire;

  -- Reset Circuitry
  PROCESS (rst_not, dvi_v_wire, dvi_h_wire, cur_state) IS
  BEGIN  -- PROCESS
    IF rst_not = '1' OR dvi_v_wire = '0' OR dvi_h_wire = '0' OR cur_state /= IMAGE_DISPLAY THEN
      image_display_fifo_rst <= '1';
    ELSE
      image_display_fifo_rst <= '0';
    END IF;
  END PROCESS;

  -- Pass address from the DVI clock region to the RAM
  FIFO_DUALCLOCK_address : FIFO_DUALCLOCK_MACRO
    GENERIC MAP (
      DEVICE                  => "VIRTEX5",  -- Target Device: "VIRTEX5"
      ALMOST_FULL_OFFSET      => X"0000",
      ALMOST_EMPTY_OFFSET     => X"0001",    -- Sets the almost empty threshold
      DATA_WIDTH              => 20,  -- Valid values are 4, 9, 18, 36 or 72 (72 only valid when FIFO_SIZE="36Kb")
      FIFO_SIZE               => "18Kb",     -- Target BRAM, "18Kb" or "36Kb" 
      FIRST_WORD_FALL_THROUGH => false)  -- Sets the FIFO FWFT to TRUE or FALSE
    PORT MAP (
      RDCOUNT => image_display_fifo_read_count0,
      WRCOUNT => image_display_fifo_write_count0,


      DO          => image_display_fifo_mem_addr,    -- Output data      
      ALMOSTEMPTY => image_display_fifo_empty,       -- Output empty
      DI          => image_display_mem_addr,         -- Input data
      RDCLK       => clk_intbuf,                     -- Input read clock
      RDEN        => image_display_fifo_re,          -- Input read enable
      RST         => image_display_fifo_rst,         -- Input reset
      WRCLK       => dvi_pixel_clk,                  -- Input write clock
      WREN        => image_display_mem_output_valid  -- Input write enable
      );

  PROCESS (cur_state, mem_read_valid) IS
  BEGIN  -- PROCESS
    IF cur_state_next = IMAGE_DISPLAY AND mem_read_valid = '1' THEN
      image_display_fifo_we <= '1';
    ELSE
      image_display_fifo_we <= '0';
    END IF;
  END PROCESS;

-- Pass value back to the DVI clock region from the RAM
  FIFO_DUALCLOCK_value : FIFO_DUALCLOCK_MACRO
    GENERIC MAP (
      DEVICE                  => "VIRTEX5",  -- Target Device: "VIRTEX5" 
      DATA_WIDTH              => 9,  -- Valid values are 4, 9, 18, 36 or 72 (72 only valid when FIFO_SIZE="36Kb")
      FIFO_SIZE               => "18Kb",     -- Target BRAM, "18Kb" or "36Kb" 
      FIRST_WORD_FALL_THROUGH => false)  -- Sets the FIFO FWFT to TRUE or FALSE
    PORT MAP (
      RDCOUNT => image_display_fifo_read_count1,
      WRCOUNT => image_display_fifo_write_count1,
      RDEN    => '1',                   -- Input read enable
      RST     => image_display_fifo_rst,     -- Input reset

      DO    => image_display_value_fifo,  -- Output data
      DI    => mem_read_value,            -- Input data
      RDCLK => dvi_pixel_clk,             -- Input read clock
      WRCLK => clk_intbuf,                -- Input write clock
      WREN  => image_display_fifo_we      -- Input write enable
      );

-------------------------------------------------------------------------------
-- Memory Dump:  A counter with a base offset that is used to output a range of
-- memory values in sequential order.
  PROCESS (clk_intbuf) IS
  BEGIN  -- PROCESS
    IF clk_intbuf'event AND clk_intbuf = '1' THEN  -- rising clock edge
      IF rst_not = '1' OR memory_dump_rst_reg = '1' THEN
        memory_dump_rst <= '1';
      ELSE
        memory_dump_rst <= '0';
      END IF;
    END IF;
  END PROCESS;

  memory_dump_i : memory_dump
    PORT MAP (
      CLK           => clk_intbuf,
      RST           => memory_dump_rst,
      MEM_ADDR      => memory_dump_mem_addr,
      MEM_OUT_VALID => memory_dump_mem_out_valid,
      DONE          => memory_dump_done);

-------------------------------------------------------------------------------
-- Pixel Memory Controller  
  pixel_memory_controller_i : pixel_memory_controller
    PORT MAP (
      CLK              => clk_intbuf,
      RST              => rst_not,
      ADDR             => mem_addr,
      WE_B             => we_b,
      CS_B             => cs_b,
      BW_B             => bw_b,
      PIXEL_WRITE      => mem_write_value,
      PIXEL_READ       => mem_read_value,
      PIXEL_READ_VALID => mem_read_valid,

      -- SRAM Connections
      SRAM_ADDR => sram_addr_wire,      --SRAM_ADDR
      SRAM_WE_B => SRAM_WE_B,
      SRAM_BW_B => SRAM_BW_B,
      SRAM_CS_B => SRAM_CS_B,
      SRAM_OE_B => SRAM_OE_B,

      SRAM_DATA_I => SRAM_DATA_I,
      SRAM_DATA_O => SRAM_DATA_O,
      SRAM_DATA_T => SRAM_DATA_T);
  SRAM_ADDR <= sram_addr_wire;

-------------------------------------------------------------------------------
-- Smooth Stage
  smooth_rst <= smooth_rst_reg OR rst_not;

  smooth_stage_i : smooth_stage
    PORT MAP (
      CLK              => clk_intbuf,
      RST              => smooth_rst,
      LEVEL            => "000",
      MEM_PIXEL_READ   => mem_read_value,
      MEM_ADDR         => smooth_addr,
      MEM_PIXEL_WRITE  => smooth_pixel_write,
      MEM_RE           => smooth_re,
      MEM_BW_B         => smooth_bw_b,
      MEM_OUTPUT_VALID => smooth_output_valid,
      DONE             => smooth_done);

-------------------------------------------------------------------------------
-- Compute Affine
  compute_affine_rst <= compute_affine_rst_reg OR rst_not;
  registration_controller_i : registration_controller PORT MAP(
    CLK   => clk_intbuf,
    RST   => compute_affine_rst,
    H_0_0 => h_0_0p,
    H_0_1 => h_0_1p,
    H_1_0 => h_1_0p,
    H_1_1 => h_1_1p,
    H_0_2 => h_0_2p,
    H_1_2 => h_1_2p,

    MEM_VALUE        => mem_read_value,
    MEM_INPUT_VALID  => mem_read_valid,
    MEM_ADDR         => compute_affine_addr,
    MEM_BW_B         => compute_affine_bw_b,
    MEM_OUTPUT_VALID => compute_affine_output_valid,
    H_0_0_O          => h_0_0w,
    H_0_1_O          => h_0_1w,
    H_0_2_O          => h_0_2w,
    H_1_0_O          => h_1_0w,
    H_1_1_O          => h_1_1w,
    H_1_2_O          => h_1_2w,
    OUTPUT_VALID     => compute_affine_done
    );
END Behavioral;
