LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY image_store_display_test IS
  GENERIC (
    IMGSIZE_BITS : integer := 10;
    PIXEL_BITS   : integer := 9);
  PORT (CLK_P       : IN  std_logic;
        CLK_N       : IN  std_logic;
        -- IO
        RST         : IN  std_logic;
        GPIO_SW     : IN  std_logic_vector(4 DOWNTO 0);
        GPIO_ROTARY : IN  std_logic_vector(2 DOWNTO 0);
                                        -- I2C Signals
        I2C_SDA     : OUT std_logic;
        I2C_SCL     : OUT std_logic;

                                        -- DVI Signals
        DVI_D       : OUT std_logic_vector (11 DOWNTO 0);
        DVI_H       : OUT std_logic;
        DVI_V       : OUT std_logic;
        DVI_DE      : OUT std_logic;
        DVI_XCLK_N  : OUT std_logic;
        DVI_XCLK_P  : OUT std_logic;
        DVI_RESET_B : OUT std_logic;

                                        -- VGA Chip connections
        VGA_PIXEL_CLK  : IN std_logic;
        VGA_Y_GREEN    : IN std_logic_vector (7 DOWNTO 0);
        VGA_CBCR_RED   : IN std_logic_vector (7 DOWNTO 0);
        VGA_BLUE       : IN std_logic_vector (7 DOWNTO 0);
        VGA_HSYNC      : IN std_logic;
        VGA_VSYNC      : IN std_logic;
        VGA_ODD_EVEN_B : IN std_logic;
        VGA_SOGOUT     : IN std_logic;
        VGA_CLAMP      : IN std_logic;
        VGA_COAST      : IN std_logic;

                                        -- SRAM Connections
        SRAM_CLK_FB   : IN    std_logic;
        SRAM_CLK      : OUT   std_logic;
        SRAM_ADV_LD_B : OUT   std_logic;
        SRAM_ADDR     : OUT   std_logic_vector (17 DOWNTO 0);
        SRAM_WE_B     : OUT   std_logic;
        SRAM_BW_B     : OUT   std_logic_vector (3 DOWNTO 0);
        --SRAM_CKE_B    : OUT   std_logic;  -- NOTE Unconnected for now
        SRAM_CS_B     : OUT   std_logic;
        SRAM_OE_B     : OUT   std_logic;
        SRAM_DATA     : INOUT std_logic_vector (35 DOWNTO 0);

        -- Chipscope
        MEMORY_DUMP_RST_VALUE  : OUT std_logic;
        MEMORY_DUMP_DONE_VALUE : OUT std_logic;
        MEMORY_READ_VALUE      : OUT std_logic_vector(8 DOWNTO 0);
        MEMORY_WRITE_VALUE     : OUT std_logic_vector(8 DOWNTO 0);
        MEMORY_ADDR_VALUE      : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
        PSCOUNTER_VALUE        : OUT std_logic_vector(10 DOWNTO 0)
        );

END image_store_display_test;

ARCHITECTURE Behavioral OF image_store_display_test IS
  COMPONENT i2c_video_programmer IS
    PORT (CLK200Mhz : IN  std_logic;
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

          -- External Memory Connections
          -- 0:0:PIXEL_BITS Format
          MEM_OUT_VALUE    : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          MEM_ADDR         : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
          MEM_OUTPUT_VALID : OUT std_logic;
          DONE             : OUT std_logic
          );
  END COMPONENT;

  COMPONENT pixel_memory_controller IS
    PORT (CLK    : IN std_logic;
          CLK_OE : IN std_logic;
          RST    : IN std_logic;

          -- Control signals
          ADDR             : IN  std_logic_vector (19 DOWNTO 0);
          WE_B             : IN  std_logic;
          CS_B             : IN  std_logic;
          PIXEL_WRITE      : IN  std_logic_vector (8 DOWNTO 0);
          PIXEL_READ       : OUT std_logic_vector(8 DOWNTO 0);
          PIXEL_READ_VALID : OUT std_logic;

          -- SRAM Connections
          SRAM_ADV_LD_B : OUT   std_logic;
          SRAM_ADDR     : OUT   std_logic_vector (17 DOWNTO 0);
          SRAM_WE_B     : OUT   std_logic;
          SRAM_BW_B     : OUT   std_logic_vector (3 DOWNTO 0);
          SRAM_CKE_B    : OUT   std_logic;
          SRAM_CS_B     : OUT   std_logic;
          SRAM_OE_B     : OUT   std_logic;
          SRAM_DATA     : INOUT std_logic_vector (35 DOWNTO 0));
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

  COMPONENT memory_dump IS
    GENERIC (
      BASE_OFFSET  : integer := 0;
      COUNT_LENGTH : integer := 786432;
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

  SIGNAL rst_not, clk200mhz_buf, clk_int, sram_int_clk_3x, clk_buf, sram_int_clk, clk_intbuf, we_b, image_store_done, image_store_mem_output_valid, image_display_mem_output_valid, cs_b, image_store_rst : std_logic;

  SIGNAL memory_dump_done, memory_dump_rst, memory_dump_mem_out_valid, memory_dump_rst_reg, image_display_rst, image_display_done : std_logic;

  SIGNAL image_store_mem_addr, image_display_mem_addr, memory_dump_mem_addr, mem_addr : std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
  SIGNAL mem_out_value, mem_write_value, mem_read_value                               : std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
  TYPE   current_state IS (IMAGE_STORE, IMAGE_DISPLAY, MEM_DUMP_WRITE, MEM_DUMP_READ, IDLE);
  SIGNAL cur_state                                                                    : current_state        := IDLE;
  SIGNAL memory_dump_done_reg, psen, pscount_enable, psincdec                         : std_logic            := '0';
  SIGNAL pscounter                                                                    : signed(10 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL psinner_count                                                                : unsigned(5 DOWNTO 0) := (OTHERS => '0');
BEGIN

-------------------------------------------------------------------------------
-- CLK Management
  rst_not <= NOT RST;
  IBUFGDS_inst : IBUFGDS
    GENERIC MAP (
      IOSTANDARD => "DEFAULT")
    PORT MAP (
      O  => clk200mhz_buf,              -- Clock buffer output
      I  => CLK_P,                      -- Diff_p clock buffer input
      IB => CLK_N                       -- Diff_n clock buffer input
      );

--  BUFGCTRL_inst : BUFGCTRL
--    GENERIC MAP (
--      INIT_OUT     => 0,      -- Inital value of 0 or 1 after configuration
--      PRESELECT_I0 => false,  -- TRUE/FALSE set the I0 input after configuration
--      PRESELECT_I1 => false)  -- TRUE/FALSE set the I1 input after configuration
--    PORT MAP (
--      O       => clk_buf,               -- Clock MUX output
--      CE0     => '1',                   -- Clock enable0 input
--      CE1     => '1',                   -- Clock enable1 input
--      I0      => clk200mhz_buf,         -- Clock0 input
--      I1      => '0',                   -- Clock1 input
--      IGNORE0 => '0',                   -- Ignore clock select0 input
--      IGNORE1 => '0',                   -- Ignore clock select1 input
--      S0      => '1',                   -- Clock select0 input
--      S1      => '0'                    -- Clock select1 input
--      );

   DCM_BASE_freq : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 2.0,  -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE          => 1,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 3,       -- Can be any integer from 2 to 32
      CLKIN_DIVIDE_BY_2     => TRUE,  -- TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD          => 5.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLKOUT_PHASE_SHIFT    => "NONE",  -- Specify phase shift mode of NONE or FIXED
      CLK_FEEDBACK          => "NONE",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,   -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "HIGH",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "HIGH",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      PHASE_SHIFT           => 0,  -- Amount of fixed phase shift from -255 to 1023
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => clk_buf,                 -- 0 degree DCM CLK ouptput
      CLKFB => '0',              -- DCM clock feedback
--      CLKFX =>  clk_buf,
      CLKIN =>  clk200mhz_buf,            -- Clock input (from IBUFG, BUFG or DCM)
      RST   => rst_not                  -- DCM asynchronous reset input
      );
  
  DCM_BASE_internal : DCM_BASE
    GENERIC MAP (
      CLKDV_DIVIDE          => 2.0,  -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE          => 1,       -- Can be any interger from 1 to 32
      CLKFX_MULTIPLY        => 3,       -- Can be any integer from 2 to 32
      CLKIN_DIVIDE_BY_2     => false,  -- TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD          => 10.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLKOUT_PHASE_SHIFT    => "NONE",  -- Specify phase shift mode of NONE or FIXED
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,   -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "HIGH",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "HIGH",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      PHASE_SHIFT           => 0,  -- Amount of fixed phase shift from -255 to 1023
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => clk_int,                 -- 0 degree DCM CLK ouptput
      CLKFB => clk_intbuf,              -- DCM clock feedback
      CLKIN => clk_buf,            -- Clock input (from IBUFG, BUFG or DCM)
      RST   => rst_not                  -- DCM asynchronous reset input
      );

  -- Buffer Internal Clock Signal
  BUFG_inst : BUFG
    PORT MAP (
      O => clk_intbuf,                  -- Clock buffer output
      I => clk_int                      -- Clock buffer input
      );

  -- Buffer and Deskew SRAM CLK

  DCM_ADV_sram : DCM_ADV
    GENERIC MAP (
      CLKDV_DIVIDE          => 2.0,  -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE          => 1,       -- Can be any integer from 1 to 32
      CLKFX_MULTIPLY        => 4,       -- Can be any integer from 2 to 32
      CLKIN_DIVIDE_BY_2     => false,  -- TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD          => 10.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLKOUT_PHASE_SHIFT    => "VARIABLE_CENTER",  -- Specify phase shift mode of NONE, FIXED, 
      -- VARIABLE_POSITIVE, VARIABLE_CENTER or DIRECT
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,    -- DCM calibration circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "HIGH",  -- HIGH or LOW frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "HIGH",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      PHASE_SHIFT           => 0,  -- Amount of fixed phase shift from -255 to 1023
      SIM_DEVICE            => "VIRTEX5",  -- Set target device, "VIRTEX4" or "VIRTEX5" 
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0     => sram_int_clk,         -- 0 degree DCM CLK output
      --DO => DO,             -- 16-bit data output for Dynamic Reconfiguration Port (DRP)
      --DRDY => DRDY,         -- Ready output signal from the DRP
      -- LOCKED   => LOCKED,               -- DCM LOCK status output
      CLKFB    => SRAM_CLK_FB,          -- DCM clock feedback
      CLKIN    => clk_buf,         -- Clock input (from IBUFG, BUFG or DCM)
      --DADDR => DADDR,       -- 7-bit address for the DRP
      --DCLK => DCLK,         -- Clock for the DRP
      --DEN => DEN,           -- Enable input for the DRP
      --DI => DI,             -- 16-bit data input for the DRP
      --DWE => DWE,           -- Active high allows for writing configuration memory
      PSCLK    => clk_buf,              -- Dynamic phase adjust clock input
      PSEN     => psen,                 -- Dynamic phase adjust enable input
      PSINCDEC => psincdec,        -- Dynamic phase adjust increment/decrement
      RST      => rst_not               -- DCM asynchronous reset input
      );

  -- Controls the phase shift counter value, keeps track of the count so that
  -- it can be displayed
  -- Uses a button to enable scroller input per increment for debouncing
  PROCESS (clk_buf) IS
  BEGIN  -- PROCESS
    IF clk_buf'event AND clk_buf = '1' THEN  -- rising clock edge
      IF rst_not = '1' THEN                  -- synchronous reset (active high)
        pscounter      <= (OTHERS => '0');
        psen           <= '0';
        psincdec       <= '0';
        pscount_enable <= '0';
        psinner_count  <= (OTHERS => '0');
      ELSE
        IF pscount_enable = '1' AND psinner_count = 0 THEN
          CASE GPIO_SW(3 DOWNTO 2) IS
            WHEN "01" =>                     -- INC - South
              pscount_enable <= '0';
              IF pscounter < 1023 THEN
                psincdec      <= '1';
                pscounter     <= pscounter + 1;
                psen          <= '1';
                psinner_count <= to_unsigned(7, 6);
              ELSE
                psen <= '0';
              END IF;
            WHEN "10" =>                     -- DEC - West
              pscount_enable <= '0';
              IF pscounter > -255 THEN
                psincdec      <= '0';
                pscounter     <= pscounter - 1;
                psen          <= '1';
                psinner_count <= to_unsigned(7, 6);
              ELSE
                psen <= '0';
              END IF;
            WHEN OTHERS =>
              psen <= '0';
          END CASE;
        ELSIF psinner_count /= 0 THEN
          psinner_count <= psinner_count -1;
        ELSE
          psen <= '0';
          IF GPIO_SW(4) = '1' THEN           -- Unlock other switches
            pscount_enable <= '1';
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS;
  PSCOUNTER_VALUE <= std_logic_vector(pscounter);

--  DCM_BASE_sram : DCM_BASE
--    GENERIC MAP (
--      CLKDV_DIVIDE          => 2.0,  -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
--      --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
--      CLKFX_DIVIDE          => 1,       -- Can be any interger from 1 to 32
--      CLKFX_MULTIPLY        => 3,       -- Can be any integer from 2 to 32
--      CLKIN_DIVIDE_BY_2     => false,  -- TRUE/FALSE to enable CLKIN divide by two feature
--      CLKIN_PERIOD          => 5.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
--      CLKOUT_PHASE_SHIFT    => "FIXED",  -- Specify phase shift mode of NONE or FIXED
--      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
--      DCM_AUTOCALIBRATION   => true,   -- DCM calibrartion circuitry TRUE/FALSE
--      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
--      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
--                                        --   an integer from 0 to 15
--      DFS_FREQUENCY_MODE    => "HIGH",  -- LOW or HIGH frequency mode for frequency synthesis
--      DLL_FREQUENCY_MODE    => "HIGH",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
--      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
--      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
--      PHASE_SHIFT           => 128,  -- Amount of fixed phase shift from -255 to 1023
--      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
--    PORT MAP (
--      CLK0  => sram_int_clk,            -- 0 degree DCM CLK ouptput
--      --CLKFX => sram_int_clk_3x,
--      CLKFB => SRAM_CLK_FB,             -- DCM clock feedback
--      CLKIN => clk_buf,              -- Clock input (from IBUFG, BUFG or DCM)
--      RST   => rst_not                  -- DCM asynchronous reset input
--      );


-------------------------------------------------------------------------------
-- Main State Machine
--Controls activity of IMAGE_STORE_STAGE, IMAGE_DISPLAY_STAGE, MEMORY_DUMP

  PROCESS (clk_intbuf) IS
  BEGIN  -- PROCESS
    IF clk_intbuf'event AND clk_intbuf = '1' THEN  -- rising clock edge
      IF rst_not = '1' THEN             -- synchronous reset (active high)
        cur_state <= IDLE;
      ELSE
        MEMORY_DUMP_RST_VALUE  <= memory_dump_rst;
        MEMORY_DUMP_DONE_VALUE <= memory_dump_done;
        MEMORY_READ_VALUE      <= mem_read_value;
        MEMORY_WRITE_VALUE     <= mem_write_value;
        MEMORY_ADDR_VALUE      <= mem_addr;
        CASE cur_state IS
          WHEN IDLE =>                  -- 001
            memory_dump_rst_reg <= '1';
            image_store_rst     <= '1';
            image_display_rst   <= '1';

            -- Switch states on button press
            CASE GPIO_SW IS
              WHEN "00001" =>           -- N
                cur_state <= MEM_DUMP_WRITE;
              WHEN "00010" =>           -- E
                cur_state <= MEM_DUMP_READ;
--              WHEN "00100" =>           -- S
--                cur_state <= IMAGE_STORE;
--              WHEN "01000" =>           -- W
--                cur_state <= IMAGE_DISPLAY;
              WHEN OTHERS => NULL;
            END CASE;
          WHEN MEM_DUMP_WRITE =>        -- 100
            memory_dump_rst_reg <= '0';
            IF memory_dump_done = '1' THEN
              cur_state <= IDLE;
            END IF;
            
          WHEN MEM_DUMP_READ =>         -- 011
            memory_dump_rst_reg <= '0';
            IF memory_dump_done = '1' THEN
              cur_state <= IDLE;
            END IF;

--          WHEN IMAGE_STORE =>           -- 000
--            image_store_rst <= '0';
--            IF image_store_done = '1'THEN
--              cur_state <= IDLE;
--            END IF;

--          WHEN IMAGE_DISPLAY =>         -- 001
--            image_display_rst <= '0';
--            IF image_display_done = '1'THEN
--              cur_state <= IDLE;
--            END IF;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END IF;
  END PROCESS;

  PROCESS (cur_state, image_store_mem_output_valid, image_display_mem_output_valid, image_store_mem_addr, image_display_mem_addr) IS
  BEGIN  -- PROCESS
    CASE cur_state IS
      WHEN IDLE =>
        we_b            <= '1';
        cs_b            <= '1';
        mem_addr        <= (OTHERS => '0');
        mem_write_value <= (OTHERS => '0');
        
      WHEN MEM_DUMP_WRITE =>
        we_b            <= '0';
        cs_b            <= NOT memory_dump_mem_out_valid;
        mem_addr        <= memory_dump_mem_addr;
        mem_write_value <= memory_dump_mem_addr(8 DOWNTO 0);
        
      WHEN MEM_DUMP_READ =>
        we_b            <= '1';
        cs_b            <= NOT memory_dump_mem_out_valid;
        mem_addr        <= memory_dump_mem_addr;
        mem_write_value <= (OTHERS => '0');

--      WHEN IMAGE_STORE =>
--        we_b            <= '0';
--        cs_b            <= NOT image_store_mem_output_valid;
--        mem_addr        <= image_store_mem_addr;
--        mem_write_value <= mem_out_value;

--      WHEN IMAGE_DISPLAY =>
--        we_b            <= '1';
--        cs_b            <= NOT image_display_mem_output_valid;
--        mem_addr        <= image_display_mem_addr;
--        mem_write_value <= (OTHERS => '0');
        
      WHEN OTHERS =>
        we_b            <= '1';
        cs_b            <= '1';
        mem_addr        <= (OTHERS => '0');
        mem_write_value <= (OTHERS => '0');
        
    END CASE;
  END PROCESS;

-------------------------------------------------------------------------------
-- Program Video In/Out Over I2C
--  i2c_video_programmer_i : i2c_video_programmer
--    PORT MAP (
--      CLK200Mhz => clk200mhz_buf,
--      RST       => rst_not,
--      I2C_SDA   => I2C_SDA,
--      I2C_SCL   => I2C_SCL);

-------------------------------------------------------------------------------  
-- Image Store Stage
--  image_store_stage_i : image_store_stage
--    PORT MAP (
--      CLK              => clk_intbuf,
--      RST              => image_store_rst,
--      -- VGA Chip Connections
--      VGA_Y            => VGA_Y_GREEN,
--      VGA_HSYNC        => VGA_HSYNC,
--      VGA_VSYNC        => VGA_VSYNC,
--      -- External Memory Connections
--      -- 0:0:PIXEL_BITS Format
--      MEM_OUT_VALUE    => mem_out_value,
--      MEM_ADDR         => image_store_mem_addr,
--      MEM_OUTPUT_VALID => image_store_mem_output_valid,
--      DONE             => image_store_done);
  -- TODO Use FIFOs to buffer valid ADDR and Value signals on the VGA clock
  -- domain to be used by the ZBT RAM domain

-------------------------------------------------------------------------------
-- Image Display Stage
--  image_display_stage_i : image_display_stage
--    PORT MAP (
--      CLK           => clk_intbuf,
--      RST           => rst_not,
--      MEM_IN_VALUE  => mem_read_value,
--      MEM_ADDR      => image_display_mem_addr,
--      MEM_OUT_VALID => image_display_mem_output_valid,
--      DVI_D         => DVI_D,
--      DVI_H         => DVI_H,
--      DVI_V         => DVI_V,
--      DVI_DE        => DVI_DE,
--      DVI_XCLK_P    => DVI_XCLK_P,
--      DVI_XCLK_N    => DVI_XCLK_N,
--      DVI_RESET_B   => DVI_RESET_B);

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
      CLK         => sram_int_clk,
      CLK_OE      => sram_int_clk_3x,
      RST         => rst_not,
      ADDR        => mem_addr,
      WE_B        => we_b,
      CS_B        => cs_b,
      --PIXEL_WRITE => memory_dump_mem_addr(8 DOWNTO 0),
      PIXEL_WRITE => mem_write_value,
      PIXEL_READ  => mem_read_value,
      --PIXEL_READ_VALID => ,

      -- SRAM Connections
      SRAM_ADV_LD_B => SRAM_ADV_LD_B,
      SRAM_ADDR     => SRAM_ADDR,
      SRAM_WE_B     => SRAM_WE_B,
      SRAM_BW_B     => SRAM_BW_B,
      --SRAM_CKE_B    => SRAM_CKE_B,
      SRAM_CS_B     => SRAM_CS_B,
      SRAM_OE_B     => SRAM_OE_B,
      SRAM_DATA     => SRAM_DATA);
  SRAM_CLK <= sram_int_clk;             -- TODO Use feedback
END Behavioral;
