LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY image_display_stage IS
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
END image_display_stage;

ARCHITECTURE Behavioral OF image_display_stage IS
  COMPONENT vga_timing_generator IS
    GENERIC (WIDTH  : integer := 640;
             H_FP   : integer := 16;
             H_SYNC : integer := 96;
             H_BP   : integer := 48;

             HEIGHT      : integer := 480;
             V_FP        : integer := 11;
             V_SYNC      : integer := 2;
             V_BP        : integer := 31;
             HEIGHT_BITS : integer := IMGSIZE_BITS;
             WIDTH_BITS  : integer := IMGSIZE_BITS;
             HCOUNT_BITS : integer := IMGSIZE_BITS+1;
             VCOUNT_BITS : integer := IMGSIZE_BITS+1;
             DATA_DELAY  : integer := 10
             );
    PORT (CLK            : IN  std_logic;
          RST            : IN  std_logic;
          HSYNC          : OUT std_logic;
          VSYNC          : OUT std_logic;
          X_COORD        : OUT std_logic_vector(WIDTH_BITS-1 DOWNTO 0);
          Y_COORD        : OUT std_logic_vector(HEIGHT_BITS-1 DOWNTO 0);
          PIXEL_COUNT    : OUT std_logic_vector(WIDTH_BITS+HEIGHT_BITS-1 DOWNTO 0);
          DATA_VALID     : OUT std_logic;
          DATA_VALID_EXT : OUT std_logic);
  END COMPONENT;
  SIGNAL mem_addr_wire                                                : std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
  SIGNAL mem_addr_reg                                                 : unsigned(2*IMGSIZE_BITS-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL x_coord_wire, y_coord_wire                                   : std_logic_vector(IMGSIZE_BITS-1 DOWNTO 0);
  SIGNAL hsync_wire, vsync_wire, data_valid_wire, data_valid_ext_wire : std_logic;
  SIGNAL data_valid_buf                                               : std_logic                           := '0';
  SIGNAL dvi_red, dvi_blue, dvi_green                                 : std_logic_vector(7 DOWNTO 0);
BEGIN
  -- VGA Timing Generator
  vga_timing_generator_i : vga_timing_generator
    PORT MAP (
      CLK            => CLK,
      RST            => RST,
      HSYNC          => hsync_wire,
      VSYNC          => vsync_wire,
      X_COORD        => x_coord_wire,
      Y_COORD        => y_coord_wire,
      PIXEL_COUNT    => mem_addr_wire,
      DATA_VALID     => data_valid_wire,
      DATA_VALID_EXT => data_valid_ext_wire);

  -- Compute Address
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        mem_addr_reg   <= (OTHERS => '0');
        data_valid_buf <= '0';
      ELSE
        mem_addr_reg   <= unsigned(mem_addr_wire) + BASE_OFFSET;
        data_valid_buf <= data_valid_wire;
        X_COORD        <= x_coord_wire;
        Y_COORD        <= y_coord_wire;
      END IF;
    END IF;
  END PROCESS;

  -- Output RAM Signals
  MEM_ADDR      <= std_logic_vector(mem_addr_reg);
  MEM_OUT_VALID <= data_valid_buf;

  -- Output Data to DVI
  dvi_green <= MEM_IN_VALUE(8 DOWNTO 1);
  dvi_blue  <= MEM_IN_VALUE(8 DOWNTO 1);
  dvi_red   <= MEM_IN_VALUE(8 DOWNTO 1);

  DVI_H       <= NOT hsync_wire;
  DVI_V       <= NOT vsync_wire;
  DVI_DE      <= data_valid_ext_wire;
  DVI_RESET_B <= '1';
  -- TODO Try to infer the following DDR instantiations
  -- This outputs the color values in the DVI chips DDR mode, if the
  -- dvi_red/green/blue wires are used on the posedge of the CLK, then
  -- knowledge of this DDR format isn't necessary
  ODDR_dvi_d0 : ODDR
    PORT MAP (DVI_D(0), CLK, '1', dvi_green(4), dvi_blue(0), NOT data_valid_ext_wire, '0');
  ODDR_dvi_d1 : ODDR
    PORT MAP (DVI_D(1), CLK, '1', dvi_green(5), dvi_blue(1), NOT data_valid_ext_wire, '0');
  ODDR_dvi_d2 : ODDR
    PORT MAP (DVI_D(2), CLK, '1', dvi_green(6), dvi_blue(2), NOT data_valid_ext_wire, '0');
  ODDR_dvi_d3 : ODDR
    PORT MAP (DVI_D(3), CLK, '1', dvi_green(7), dvi_blue(3), NOT data_valid_ext_wire, '0');
  ODDR_dvi_d4 : ODDR
    PORT MAP (DVI_D(4), CLK, '1', dvi_red(0), dvi_blue(4), NOT data_valid_ext_wire, '0');
  ODDR_dvi_d5 : ODDR
    PORT MAP (DVI_D(5), CLK, '1', dvi_red(1), dvi_blue(5), NOT data_valid_ext_wire, '0');
  ODDR_dvi_d6 : ODDR
    PORT MAP (DVI_D(6), CLK, '1', dvi_red(2), dvi_blue(6), NOT data_valid_ext_wire, '0');
  ODDR_dvi_d7 : ODDR
    PORT MAP (DVI_D(7), CLK, '1', dvi_red(3), dvi_blue(7), NOT data_valid_ext_wire, '0');
  ODDR_dvi_d8 : ODDR
    PORT MAP (DVI_D(8), CLK, '1', dvi_red(4), dvi_green(0), NOT data_valid_ext_wire, '0');
  ODDR_dvi_d9 : ODDR
    PORT MAP (DVI_D(9), CLK, '1', dvi_red(5), dvi_green(1), NOT data_valid_ext_wire, '0');
  ODDR_dvi_d10 : ODDR
    PORT MAP (DVI_D(10), CLK, '1', dvi_red(6), dvi_green(2), NOT data_valid_ext_wire, '0');
  ODDR_dvi_d11 : ODDR
    PORT MAP (DVI_D(11), CLK, '1', dvi_red(7), dvi_green(3), NOT data_valid_ext_wire, '0');

  -- This is a way to generate a differential clock with low jitter (as both
  -- edges are handled in the same way)
  ODDR_xclk_p : ODDR
    GENERIC MAP(
      DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE" 
      INIT         => '0',  -- Initial value for Q port ('1' or '0')
      SRTYPE       => "SYNC")           -- Reset Type ("ASYNC" or "SYNC")
    PORT MAP (
      Q  => DVI_XCLK_P,                 -- 1-bit DDR output
      C  => CLK,                        -- 1-bit clock input
      CE => '1',                        -- 1-bit clock enable input
      D1 => '1',                        -- 1-bit data input (positive edge)
      D2 => '0',                        -- 1-bit data input (negative edge)
      R  => '0',                        -- 1-bit reset input
      S  => '0'                         -- 1-bit set input
      );
  ODDR_xclk_n : ODDR
    GENERIC MAP(
      DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE" 
      INIT         => '0',  -- Initial value for Q port ('1' or '0')
      SRTYPE       => "SYNC")           -- Reset Type ("ASYNC" or "SYNC")
    PORT MAP (
      Q  => DVI_XCLK_N,                 -- 1-bit DDR output
      C  => CLK,                        -- 1-bit clock input
      CE => '1',                        -- 1-bit clock enable input
      D1 => '0',                        -- 1-bit data input (positive edge)
      D2 => '1',                        -- 1-bit data input (negative edge)
      R  => '0',                        -- 1-bit reset input
      S  => '0'                         -- 1-bit set input
      );

END Behavioral;

