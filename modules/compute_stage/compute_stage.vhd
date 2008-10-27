LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY compute_stage IS
  GENERIC (
    IMGSIZE_BITS : integer := 10;
    PIXEL_BITS   : integer := 9);
  PORT (CLK           : IN std_logic;
        RST           : IN std_logic;
        -- IMG0 Neighborhood for spatial derivative computation (only output
        -- the union of the middle row pixels and the middle column pixels)
        -- 0:0:PIXEL_BITS Format
        IMG0_0_1      : IN std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_1_0      : IN std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_1_1      : IN std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_1_2      : IN std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_2_1      : IN std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        -- IMG1 Center pixel value for temporal derivative computation
        IMG1_1_1      : IN std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        -- Offset pixel coordinates for A/b matrix computation (offset to
        -- increase numerical accuracy, corrected later in the pipeline)
        -- 1:IMGSIZE_BITS:1 Format
        TRANS_X_COORD : IN std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);
        TRANS_Y_COORD : IN std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);

        FSCS_VALID : IN std_logic;
        DONE       : IN std_logic;

        -- 1:0:PIXEL_BITS Format
        IX                : OUT std_logic_vector(PIXEL_BITS DOWNTO 0);
        IY                : OUT std_logic_vector(PIXEL_BITS DOWNTO 0);
        IT                : OUT std_logic_vector(PIXEL_BITS DOWNTO 0);
        -- 1:IMGSIZE_BITS:1 Format
        TRANS_X_COORD_BUF : OUT std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);
        TRANS_Y_COORD_BUF : OUT std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);

        DONE_BUF   : OUT std_logic;
        CSSS_VALID : OUT std_logic);
END compute_stage;

ARCHITECTURE Behavioral OF compute_stage IS

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

  COMPONENT pipeline_bit_buffer IS
    GENERIC (
      STAGES : integer := 1);
    PORT (CLK   : IN  std_logic;
          RST   : IN  std_logic;
          SET   : IN  std_logic;
          CLKEN : IN  std_logic;
          DIN   : IN  std_logic;
          DOUT  : OUT std_logic);
  END COMPONENT;
  
BEGIN

  done_buffer : pipeline_bit_buffer
    GENERIC MAP (
      STAGES => 1)
    PORT MAP (
      CLK   => CLK,
      SET   => '0',
      RST   => RST,
      CLKEN => '1',
      DIN   => DONE,
      DOUT  => DONE_BUF);

  valid_buffer : pipeline_bit_buffer
    GENERIC MAP (
      STAGES => 1)
    PORT MAP (
      CLK   => CLK,
      SET   => '0',
      RST   => RST,
      CLKEN => '1',
      DIN   => FSCS_VALID,
      DOUT  => CSSS_VALID);

  x_coord_buffer : pipeline_buffer
    GENERIC MAP (
      WIDTH         => IMGSIZE_BITS+2,
      STAGES        => 1,
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => TRANS_X_COORD,
      DOUT  => TRANS_X_COORD_BUF);

  y_coord_buffer : pipeline_buffer
    GENERIC MAP (
      WIDTH         => IMGSIZE_BITS+2,
      STAGES        => 1,
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => TRANS_Y_COORD,
      DOUT  => TRANS_Y_COORD_BUF);

  -- Compute differences
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IX <= std_logic_vector(signed('0'&IMG0_1_2)-signed('0'&IMG0_1_0));
      IY <= std_logic_vector(signed('0'&IMG0_2_1)-signed('0'&IMG0_0_1));
      IT <= std_logic_vector(signed('0'&IMG1_1_1)-signed('0'&IMG0_1_1));
    END IF;
  END PROCESS;
END Behavioral;

