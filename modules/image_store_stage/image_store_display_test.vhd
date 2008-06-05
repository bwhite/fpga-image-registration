LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY image_store_display_test IS
  GENERIC (
    IMGSIZE_BITS : integer := 10;
    PIXEL_BITS   : integer := 9);
  PORT (CLK_P : IN std_logic;
        CLK_N : IN std_logic;

        -- IO
        RST     : IN std_logic;
        GPIO_SW : IN std_logic_vector(4 DOWNTO 0);

        -- SRAM Connections
        SRAM_CLK_FB : IN    std_logic;
        SRAM_CLK    : OUT   std_logic;
        SRAM_ADDR   : OUT   std_logic_vector (17 DOWNTO 0);
        SRAM_WE_B   : OUT   std_logic;
        SRAM_BW_B   : OUT   std_logic_vector (3 DOWNTO 0);
        SRAM_CS_B   : OUT   std_logic;
        SRAM_OE_B   : OUT   std_logic;
        SRAM_DATA   : INOUT std_logic_vector (35 DOWNTO 0)
        );
END image_store_display_test;

ARCHITECTURE Behavioral OF image_store_display_test IS
  COMPONENT pixel_memory_controller IS
    PORT (CLK : IN std_logic;
          RST : IN std_logic;

          -- Control signals
          ADDR             : IN  std_logic_vector (19 DOWNTO 0);
          WE_B             : IN  std_logic;
          CS_B             : IN  std_logic;
          PIXEL_WRITE      : IN  std_logic_vector (8 DOWNTO 0);
          PIXEL_READ       : OUT std_logic_vector(8 DOWNTO 0);
          PIXEL_READ_VALID : OUT std_logic;

          -- SRAM Connections
          SRAM_ADDR : OUT   std_logic_vector (17 DOWNTO 0);
          SRAM_WE_B : OUT   std_logic;
          SRAM_BW_B : OUT   std_logic_vector (3 DOWNTO 0);
          SRAM_CS_B : OUT   std_logic;
          SRAM_OE_B : OUT   std_logic;
          SRAM_DATA : INOUT std_logic_vector (35 DOWNTO 0));
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

  SIGNAL rst_not, clk200mhz_buf, clk_freq_fb, clk_int, clk_freq0, sram_int_clk_3x, clk_buf, sram_int_clk, clk_intbuf, we_b, image_store_done, image_store_mem_output_valid, image_display_mem_output_valid, cs_b, image_store_rst : std_logic;

  SIGNAL memory_dump_done, memory_dump_rst, memory_dump_mem_out_valid, memory_dump_rst_reg, image_display_rst, image_display_done : std_logic;

  SIGNAL image_store_mem_addr, image_display_mem_addr, memory_dump_mem_addr, mem_addr : std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
  SIGNAL mem_out_value, mem_write_value, mem_read_value, mem_read_buf                 : std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
  TYPE   current_state IS (IMAGE_STORE, IMAGE_DISPLAY, MEM_DUMP_WRITE, MEM_DUMP_READ, IDLE);
  SIGNAL cur_state                                                                    : current_state        := IDLE;
  SIGNAL memory_dump_done_reg, psen, pscount_enable, psincdec                         : std_logic            := '0';
  SIGNAL pscounter                                                                    : signed(10 DOWNTO 0)  := (OTHERS => '0');
  SIGNAL psinner_count                                                                : unsigned(5 DOWNTO 0) := (OTHERS => '0');

  SIGNAL MEMORY_ADDR_VALUE                             : std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
  SIGNAL MEMORY_READ_VALUE, MEMORY_WRITE_VALUE         : std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
  SIGNAL MEMORY_DUMP_RST_VALUE, MEMORY_DUMP_DONE_VALUE : std_logic;
  SIGNAL PSCOUNTER_VALUE                               : std_logic_vector(10 DOWNTO 0);
  ATTRIBUTE KEEP                                       : string;
  ATTRIBUTE KEEP OF MEMORY_DUMP_RST_VALUE              : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP OF MEMORY_DUMP_DONE_VALUE             : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP OF MEMORY_READ_VALUE                  : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP OF MEMORY_WRITE_VALUE                 : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP OF MEMORY_ADDR_VALUE                  : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP OF PSCOUNTER_VALUE                    : SIGNAL IS "TRUE";
  ATTRIBUTE KEEP OF mem_write_value                    : SIGNAL IS "TRUE";
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

  DCM_BASE_freq : DCM_BASE
    GENERIC MAP (
      CLKIN_PERIOD          => 5.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,   -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "HIGH",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "HIGH",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => clk_buf,                 -- 0 degree DCM CLK ouptput
      CLKFB => clk_buf,                 -- DCM clock feedback
      CLKIN => clk200mhz_buf,        -- Clock input (from IBUFG, BUFG or DCM)
      RST   => rst_not                  -- DCM asynchronous reset input
      );

  DCM_BASE_internal : DCM_BASE
    GENERIC MAP (
      CLKIN_PERIOD          => 5.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,   -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "HIGH",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "HIGH",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => clk_int,                 -- 0 degree DCM CLK ouptput
      CLKFB => clk_intbuf,              -- DCM clock feedback
      CLKIN => clk_buf,              -- Clock input (from IBUFG, BUFG or DCM)
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
      CLKIN_PERIOD          => 5.0,  -- Specify period of input clock in ns from 1.25 to 1000.00
      CLK_FEEDBACK          => "1X",    -- Specify clock feedback of NONE or 1X
      DCM_AUTOCALIBRATION   => true,   -- DCM calibrartion circuitry TRUE/FALSE
      DCM_PERFORMANCE_MODE  => "MAX_SPEED",  -- Can be MAX_SPEED or MAX_RANGE
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                        --   an integer from 0 to 15
      DFS_FREQUENCY_MODE    => "HIGH",  -- LOW or HIGH frequency mode for frequency synthesis
      DLL_FREQUENCY_MODE    => "HIGH",  -- LOW, HIGH, or HIGH_SER frequency mode for DLL
      DUTY_CYCLE_CORRECTION => true,    -- Duty cycle correction, TRUE or FALSE
      FACTORY_JF            => X"F0F0",  -- FACTORY JF Values Suggested to be set to X"F0F0" 
      STARTUP_WAIT          => false)  -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
    PORT MAP (
      CLK0  => sram_int_clk,            -- 0 degree DCM CLK output
      CLKFB => SRAM_CLK_FB,             -- DCM clock feedback
      CLKIN => clk_buf,              -- Clock input (from IBUFG, BUFG or DCM)
      RST   => rst_not                  -- DCM asynchronous reset input
      );
  
  SRAM_CLK <= sram_int_clk;

-------------------------------------------------------------------------------
-- Main State Machine
--Controls activity of IMAGE_STORE_STAGE, IMAGE_DISPLAY_STAGE, MEMORY_DUMP
  PROCESS (clk_intbuf) IS
  BEGIN  -- PROCESS
    IF clk_intbuf'event AND clk_intbuf = '1' THEN  -- rising clock edge
      IF rst_not = '1' THEN             -- synchronous reset (active high)
        cur_state <= IDLE;
      ELSE
        -- Store into regs for chipscope
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
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END IF;
  END PROCESS;

  PROCESS (cur_state, memory_dump_mem_out_valid, memory_dump_mem_addr) IS
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
        
      WHEN OTHERS =>
        we_b            <= '1';
        cs_b            <= '1';
        mem_addr        <= (OTHERS => '0');
        mem_write_value <= (OTHERS => '0');
    END CASE;
  END PROCESS;

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
      CLK         => clk_intbuf,
      RST         => rst_not,
      ADDR        => mem_addr,
      WE_B        => we_b,
      CS_B        => cs_b,
      PIXEL_WRITE => mem_write_value,
      PIXEL_READ  => mem_read_value,

      -- SRAM Connections
      SRAM_ADDR => SRAM_ADDR,
      SRAM_WE_B => SRAM_WE_B,
      SRAM_BW_B => SRAM_BW_B,
      SRAM_CS_B => SRAM_CS_B,
      SRAM_OE_B => SRAM_OE_B,
      SRAM_DATA => SRAM_DATA);
END Behavioral;
