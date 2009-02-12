
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY fetch_stage_wrapper IS
  GENERIC (
    IMGSIZE_BITS     : integer := 10;
    PIXEL_BITS       : integer := 9);
  PORT (CLK : IN std_logic;
        RST : IN std_logic;
        IMG0_0_1         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_1_0         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_1_1         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_1_2         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_2_1         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        -- IMG1 Center pixel value for temporal derivative computation
        IMG1_1_1         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        -- Offset pixel coordinates for A/b matrix computation (offset to
        -- increase numerical accuracy, corrected later in the pipeline)
        -- 1:IMGSIZE_BITS:1 Format
        TRANS_X_COORD    : OUT std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);
        TRANS_Y_COORD    : OUT std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);

        OUTPUT_VALID : OUT std_logic;
        DONE       : OUT std_logic
        );
END fetch_stage_wrapper;

ARCHITECTURE Behavioral OF fetch_stage_wrapper IS

component fetch_stage IS
  GENERIC (
    CONV_HEIGHT      : integer := 3;
    IMGSIZE_BITS     : integer := 10;
    PIXEL_BITS       : integer := 9;
    CONV_HEIGHT_BITS : integer := 2);
  PORT (CLK              : IN  std_logic;  -- NOTE: The clock should not be gated
                                        -- as the timing in this module depends
                                        -- on the timing of an external RAM
        RST              : IN  std_logic;
        LEVEL            : IN  std_logic_vector(2 DOWNTO 0);
        -- Affine Homography elements IMG2_VEC=H*IMG1_VEC
        -- Rotation and Non-Isotropic Scale
        -- 1:6:11 Format
        H_0_0            : IN  std_logic_vector(17 DOWNTO 0);
        H_0_1            : IN  std_logic_vector(17 DOWNTO 0);
        H_1_0            : IN  std_logic_vector(17 DOWNTO 0);
        H_1_1            : IN  std_logic_vector(17 DOWNTO 0);
        -- Translation
        -- 1:10:11 Format 
        H_0_2            : IN  std_logic_vector(21 DOWNTO 0);
        H_1_2            : IN  std_logic_vector(21 DOWNTO 0);
        -- External Memory Connections
        -- 0:0:PIXEL_BITS Format
        MEM_VALUE        : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        MEM_INPUT_VALID  : IN  std_logic;
        MEM_ADDR         : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
        MEM_BW_B         : OUT std_logic_vector(3 DOWNTO 0);
        MEM_OUTPUT_VALID : OUT std_logic;
        -- IMG0 Neighborhood for spatial derivative computation (only output
        -- the union of the middle row pixels and the middle column pixels)
        -- 0:0:PIXEL_BITS Format
        IMG0_0_1         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_1_0         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_1_1         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_1_2         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG0_2_1         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        -- IMG1 Center pixel value for temporal derivative computation
        IMG1_1_1         : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        -- Offset pixel coordinates for A/b matrix computation (offset to
        -- increase numerical accuracy, corrected later in the pipeline)
        -- 1:IMGSIZE_BITS:1 Format
        TRANS_X_COORD    : OUT std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);
        TRANS_Y_COORD    : OUT std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);

        FSCS_VALID : OUT std_logic;
        DONE       : OUT std_logic);
END component;
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

signal mem_value        : std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
  SIGNAL mem_output_valid,mem_output_valid_buf : std_logic;
SIGNAL mem_addr : std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
SIGNAL mem_bw_b : std_logic_vector(3 DOWNTO 0);

BEGIN

  Inst_fetch_stage : fetch_stage PORT MAP(
    CLK   => CLK,
    RST   => RST,
    LEVEL => "110",
    -- Make all H values the identity
    H_0_0 => "000000100000000000",
    H_0_1 => "000000000000000000",
    H_1_0 => "000000000000000000",
    H_1_1 => "000000100000000000",
    H_0_2 => "0000000000000000000000",
    H_1_2 => "0000000000000000000000",

    MEM_VALUE        => mem_value,
    MEM_INPUT_VALID  => mem_output_valid_buf,
    MEM_ADDR         => mem_addr,
    MEM_BW_B         => mem_bw_b,
    MEM_OUTPUT_VALID => mem_output_valid,

    IMG0_0_1      => IMG0_0_1,
    IMG0_1_0      => IMG0_1_0,
    IMG0_1_1      => IMG0_1_1,
    IMG0_1_2      => IMG0_1_2,
    IMG0_2_1      => IMG0_2_1,
    IMG1_1_1      => IMG1_1_1,
    TRANS_X_COORD => TRANS_X_COORD,
    TRANS_Y_COORD => TRANS_Y_COORD,
    FSCS_VALID    => OUTPUT_VALID,
    DONE          => DONE
    );

  fake_mem_valid_buffer : pipeline_bit_buffer
    GENERIC MAP (
      STAGES => 4)                      
    PORT MAP (
      CLK   => CLK,
      SET   => '0',
      RST   => RST,
      CLKEN => '1',
      DIN   => mem_output_valid,
      DOUT  => mem_output_valid_buf);

  fake_mem_value_buffer : pipeline_buffer
    GENERIC MAP (
      WIDTH         => PIXEL_BITS,
      STAGES        => 4,
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => mem_addr(PIXEL_BITS-1 DOWNTO 0),
      DOUT  => mem_value);
END Behavioral;

