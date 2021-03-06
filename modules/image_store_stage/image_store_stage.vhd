LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY image_store_stage IS
  GENERIC (
    IMGSIZE_BITS : integer := 10;
    PIXEL_BITS   : integer := 9;
    BASE_OFFSET  : integer := 0);
  PORT (CLK  : IN  std_logic;
        RST  : IN  std_logic;
        DONE : OUT std_logic;

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
        MEM_OUTPUT_VALID : OUT std_logic);
END image_store_stage;

ARCHITECTURE Behavioral OF image_store_stage IS
  COMPONENT vga_timing_decode IS
    GENERIC (
      HEIGHT      : integer := 480;
      WIDTH       : integer := 640;
      H_BP        : integer := 116;
      V_BP        : integer := 42;
      HCOUNT_BITS : integer := IMGSIZE_BITS+1;
      VCOUNT_BITS : integer := IMGSIZE_BITS+1;
      HEIGHT_BITS : integer := IMGSIZE_BITS;
      WIDTH_BITS  : integer := IMGSIZE_BITS;
      DATA_DELAY  : integer := 0
      );
    PORT (CLK         : IN  std_logic;
          RST         : IN  std_logic;
          VSYNC       : IN  std_logic;
          HSYNC       : IN  std_logic;
          CALIBRATE   : IN  std_logic;
          INC_EXEC    : IN  std_logic;
          INC         : IN  std_logic;
          INC_HORIZ   : IN  std_logic;
          VGA_Y       : IN  std_logic_vector (7 DOWNTO 0);
          X_COORD     : OUT unsigned(WIDTH_BITS-1 DOWNTO 0);
          Y_COORD     : OUT unsigned(HEIGHT_BITS-1 DOWNTO 0);
          PIXEL_COUNT : OUT unsigned(HEIGHT_BITS+WIDTH_BITS-1 DOWNTO 0);
          DATA_VALID  : OUT std_logic;
          DONE        : OUT std_logic);
  END COMPONENT;
  SIGNAL vga_data_valid, vga_done           : std_logic;
  SIGNAL vga_data_valid_buf, vga_done_buf   : std_logic                           := '0';
  SIGNAL mem_addr_reg, vga_pixel_count_wire : unsigned(2*IMGSIZE_BITS-1 DOWNTO 0) := (OTHERS => '0');
BEGIN

  -- VGA Timing Decode
  vga_timing_decode_i : vga_timing_decode
    GENERIC MAP (
      HEIGHT      => 480,
      WIDTH       => 640,
      H_BP        => 125,
      V_BP        => 42,
      HCOUNT_BITS => IMGSIZE_BITS+1,
      VCOUNT_BITS => IMGSIZE_BITS+1,
      HEIGHT_BITS => IMGSIZE_BITS,
      WIDTH_BITS  => IMGSIZE_BITS,
      DATA_DELAY  => 1)
    PORT MAP (
      CLK         => CLK,
      RST         => RST,
      VSYNC       => VGA_VSYNC,
      HSYNC       => VGA_HSYNC,
      INC_EXEC    => INC_EXEC,
      INC         => INC,
      INC_HORIZ   => INC_HORIZ,
      CALIBRATE   => CALIBRATE,
      VGA_Y       => VGA_Y,
      DATA_VALID  => vga_data_valid,
      PIXEL_COUNT => vga_pixel_count_wire,
      DONE        => vga_done);

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
  MEM_OUT_VALUE    <= VGA_Y&'0';
  DONE             <= vga_done_buf;
END Behavioral;

