LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY image_store_stage IS
  GENERIC (
    IMGSIZE_BITS : integer := 10;
    PIXEL_BITS   : integer := 9;
    BASE_OFFSET  : integer := 100);
  PORT (CLK           : IN std_logic;
        RST           : IN std_logic;
        START         : IN std_logic;
        -- VGA Chip Connections
        VGA_PIXEL_CLK : IN std_logic;
        VGA_Y         : IN std_logic_vector (7 DOWNTO 0);
        VGA_HSYNC     : IN std_logic;
        VGA_VSYNC     : IN std_logic;

        -- External Memory Connections
        -- 0:0:PIXEL_BITS Format
        MEM_OUT_VALUE    : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        MEM_ADDR         : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
        MEM_OUTPUT_VALID : OUT std_logic;
        BUSY             : OUT std_logic;
        DONE             : OUT std_logic
        );
END image_store_stage;

ARCHITECTURE Behavioral OF image_store_stage IS
  COMPONENT vga_timing_decode IS
    GENERIC (
      HEIGHT      : integer := 480;
      WIDTH       : integer := 640;
      H_BP        : integer := 117;
      V_BP        : integer := 34;
      HEIGHT_BITS : integer := IMGSIZE_BITS;
      WIDTH_BITS  : integer := IMGSIZE_BITS;
      DATA_DELAY  : integer := 0
      );
    PORT (CLK         : IN  std_logic;
          RST         : IN  std_logic;
          VSYNC       : IN  std_logic;
          HSYNC       : IN  std_logic;
          X_COORD     : OUT unsigned(WIDTH_BITS-1 DOWNTO 0);
          Y_COORD     : OUT unsigned(HEIGHT_BITS-1 DOWNTO 0);
          PIXEL_COUNT : OUT unsigned(HEIGHT_BITS+WIDTH_BITS-1 DOWNTO 0);
          DATA_VALID  : OUT std_logic;
          DONE        : OUT std_logic);
  END COMPONENT;
  TYPE   input_state IS (IDLE_STATE, BUSY_STATE, DONE_STATE);
  SIGNAL state                                    : input_state                         := IDLE_STATE;
  SIGNAL vga_timing_rst, vga_data_valid, vga_done : std_logic;
  SIGNAL vga_data_valid_buf, vga_done_buf         : std_logic                           := '0';
  SIGNAL mem_addr_reg, vga_pixel_count_wire       : unsigned(2*IMGSIZE_BITS-1 DOWNTO 0) := (OTHERS  => '0');
  TYPE   pixel_value_buffer IS ARRAY (2 DOWNTO 0) OF std_logic_vector(7 DOWNTO 0);
  SIGNAL pixel_value_buf                          : pixel_value_buffer                  := ((OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'));
BEGIN
  -- Main State Machine
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        state <= IDLE_STATE;
      ELSE
        CASE state IS
          WHEN IDLE_STATE =>
            vga_timing_rst <= '1';
            BUSY           <= '0';
            IF START = '1' THEN
              state <= BUSY_STATE;
            END IF;
          WHEN BUSY_STATE =>
            vga_timing_rst <= '0';
            BUSY           <= '1';
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END IF;
  END PROCESS;

  -- VGA Timing Decode
  vga_timing_decode_i : vga_timing_decode
    PORT MAP (
      CLK         => VGA_PIXEL_CLK,
      RST         => vga_timing_rst,
      VSYNC       => VGA_VSYNC,
      HSYNC       => VGA_HSYNC,
      DATA_VALID  => vga_data_valid,
--      X_COORD     => vga_x_coord_wire,
--      Y_COORD     => vga_y_coord_wire,
      PIXEL_COUNT => vga_pixel_count_wire,
      DONE        => vga_done);
  -- Pixel Value Buf
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)

      ELSE
        FOR i IN 1 DOWNTO 0 LOOP
          pixel_value_buf(i+1) <= pixel_value_buf(i);
        END LOOP;  -- i
        pixel_value_buf(0) <= VGA_Y;
      END IF;
    END IF;
  END PROCESS;

  -- Memory Address Computation
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        mem_addr_reg       <= (OTHERS => '0');
        vga_data_valid_buf <= '0';
        vga_done_buf       <= '0';
      ELSE
        mem_addr_reg       <= unsigned(vga_pixel_count_wire) + BASE_OFFSET;
        vga_data_valid_buf <= vga_data_valid;
        vga_done_buf       <= vga_done;
      END IF;
    END IF;
  END PROCESS;
  MEM_OUTPUT_VALID <= vga_data_valid_buf;
  MEM_ADDR         <= std_logic_vector(mem_addr_reg);
  MEM_OUT_VALUE    <= pixel_value_buf(2)&'0';
  DONE <= vga_done_buf;
END Behavioral;

