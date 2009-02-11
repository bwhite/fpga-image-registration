library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity registration_stage is
  generic (
    CONV_HEIGHT  : integer := 3;
    IMGSIZE_BITS : integer := 10;
    PIXEL_BITS   : integer := 9;

    WHOLE_BITS       : integer := 8;
    FRAC_BITS        : integer := 19;
    CONV_HEIGHT_BITS : integer := 2);
  port (CLK              : in  std_logic;
        RST              : in  std_logic;
        LEVEL            : in  std_logic_vector(2 downto 0);
        COORD_SHIFT      : in  std_logic_vector(3 downto 0);
        COORD_TRANS      : in  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        -- Rotation and Non-Isotropic Scale
        -- 1:6:11 Format
        H_0_0            : in  std_logic_vector(17 downto 0);
        H_0_1            : in  std_logic_vector(17 downto 0);
        H_1_0            : in  std_logic_vector(17 downto 0);
        H_1_1            : in  std_logic_vector(17 downto 0);
        -- Translation
        -- 1:10:11 Format 
        H_0_2            : in  std_logic_vector(21 downto 0);
        H_1_2            : in  std_logic_vector(21 downto 0);
        -- Memory Connections
        MEM_VALUE        : in  std_logic_vector(PIXEL_BITS-1 downto 0);
        MEM_INPUT_VALID  : in  std_logic;
        MEM_ADDR         : out std_logic_vector(2*IMGSIZE_BITS-1 downto 0);
        MEM_BW_B         : out std_logic_vector(3 downto 0);
        MEM_OUTPUT_VALID : out std_logic;

        -- 1:7:9 Format 
        H_0_0_O      : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_0_1_O      : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_0_O      : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_1_O      : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_0_2_O      : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_2_O      : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        OUTPUT_VALID : out std_logic
        );
end registration_stage;

architecture Behavioral of registration_stage is
  component fetch_stage is
    generic (
      CONV_HEIGHT      : integer := 3;
      IMGSIZE_BITS     : integer := 10;
      PIXEL_BITS       : integer := 9;
      CONV_HEIGHT_BITS : integer := 2);
    port (CLK              : in  std_logic;  -- NOTE: The clock should not be gated
                                        -- as the timing in this module depends
                                        -- on the timing of an external RAM
          RST              : in  std_logic;
          LEVEL            : in  std_logic_vector(2 downto 0);
          -- Affine Homography elements IMG2_VEC=H*IMG1_VEC
          -- Rotation and Non-Isotropic Scale
          -- 1:6:11 Format
          H_0_0            : in  std_logic_vector(17 downto 0);
          H_0_1            : in  std_logic_vector(17 downto 0);
          H_1_0            : in  std_logic_vector(17 downto 0);
          H_1_1            : in  std_logic_vector(17 downto 0);
          -- Translation
          -- 1:10:11 Format 
          H_0_2            : in  std_logic_vector(21 downto 0);
          H_1_2            : in  std_logic_vector(21 downto 0);
          -- External Memory Connections
          -- 0:0:PIXEL_BITS Format
          MEM_VALUE        : in  std_logic_vector(PIXEL_BITS-1 downto 0);
          MEM_INPUT_VALID  : in  std_logic;
          MEM_ADDR         : out std_logic_vector(2*IMGSIZE_BITS-1 downto 0);
          MEM_BW_B         : out std_logic_vector(3 downto 0);
          MEM_OUTPUT_VALID : out std_logic;
          -- IMG0 Neighborhood for spatial derivative computation (only output
          -- the union of the middle row pixels and the middle column pixels)
          -- 0:0:PIXEL_BITS Format
          IMG0_0_1         : out std_logic_vector(PIXEL_BITS-1 downto 0);
          IMG0_1_0         : out std_logic_vector(PIXEL_BITS-1 downto 0);
          IMG0_1_1         : out std_logic_vector(PIXEL_BITS-1 downto 0);
          IMG0_1_2         : out std_logic_vector(PIXEL_BITS-1 downto 0);
          IMG0_2_1         : out std_logic_vector(PIXEL_BITS-1 downto 0);
          -- IMG1 Center pixel value for temporal derivative computation
          IMG1_1_1         : out std_logic_vector(PIXEL_BITS-1 downto 0);
          -- Offset pixel coordinates for A/b matrix computation (offset to
          -- increase numerical accuracy, corrected later in the pipeline)
          -- 1:IMGSIZE_BITS:1 Format
          TRANS_X_COORD    : out std_logic_vector(IMGSIZE_BITS+1 downto 0);
          TRANS_Y_COORD    : out std_logic_vector(IMGSIZE_BITS+1 downto 0);

          FSCS_VALID : out std_logic;
          DONE       : out std_logic);
  end component;

  component compute_stage is
    generic (
      IMGSIZE_BITS : integer := 10;
      PIXEL_BITS   : integer := 9);
    port (CLK           : in std_logic;
          RST           : in std_logic;
          -- IMG0 Neighborhood for spatial derivative computation (only output
          -- the union of the middle row pixels and the middle column pixels)
          -- 0:0:PIXEL_BITS Format
          IMG0_0_1      : in std_logic_vector(PIXEL_BITS-1 downto 0);
          IMG0_1_0      : in std_logic_vector(PIXEL_BITS-1 downto 0);
          IMG0_1_1      : in std_logic_vector(PIXEL_BITS-1 downto 0);
          IMG0_1_2      : in std_logic_vector(PIXEL_BITS-1 downto 0);
          IMG0_2_1      : in std_logic_vector(PIXEL_BITS-1 downto 0);
          -- IMG1 Center pixel value for temporal derivative computation
          IMG1_1_1      : in std_logic_vector(PIXEL_BITS-1 downto 0);
          -- Offset pixel coordinates for A/b matrix computation (offset to
          -- increase numerical accuracy, corrected later in the pipeline)
          -- 1:IMGSIZE_BITS:1 Format
          TRANS_X_COORD : in std_logic_vector(IMGSIZE_BITS+1 downto 0);
          TRANS_Y_COORD : in std_logic_vector(IMGSIZE_BITS+1 downto 0);

          FSCS_VALID : in std_logic;
          DONE       : in std_logic;

          -- 1:0:PIXEL_BITS Format
          IX                : out std_logic_vector(PIXEL_BITS downto 0);
          IY                : out std_logic_vector(PIXEL_BITS downto 0);
          IT                : out std_logic_vector(PIXEL_BITS downto 0);
          -- 1:IMGSIZE_BITS:1 Format
          TRANS_X_COORD_BUF : out std_logic_vector(IMGSIZE_BITS+1 downto 0);
          TRANS_Y_COORD_BUF : out std_logic_vector(IMGSIZE_BITS+1 downto 0);

          DONE_BUF   : out std_logic;
          CSSS_VALID : out std_logic);
  end component;

  component make_a_b_matrices is
    generic (
      IMGSIZE_BITS : integer := 11;
      PIXEL_BITS   : integer := 9;
      FRAC_BITS    : integer := 26;
      DELAY        : integer := 4);
    port (CLK : in std_logic;

          RST         : in  std_logic;
          COORD_SHIFT : in  std_logic_vector(3 downto 0);
          -- 1:IMGSIZE_BITS-1:1 Format
          X           : in  std_logic_vector(IMGSIZE_BITS downto 0);
          Y           : in  std_logic_vector(IMGSIZE_BITS downto 0);
          -- 1:0:PIXEL_BITS Format
          FX          : in  std_logic_vector(PIXEL_BITS downto 0);
          FY          : in  std_logic_vector(PIXEL_BITS downto 0);
          FT          : in  std_logic_vector(PIXEL_BITS downto 0);
          VALID_IN    : in  std_logic;
          DONE        : in  std_logic;
          DONE_BUF    : out std_logic;
          VALID_OUT   : out std_logic;
          -- 1:0:26
          A_0_0       : out std_logic_vector(FRAC_BITS downto 0);
          A_0_1       : out std_logic_vector(FRAC_BITS downto 0);
          A_0_2       : out std_logic_vector(FRAC_BITS downto 0);
          A_0_3       : out std_logic_vector(FRAC_BITS downto 0);
          A_0_4       : out std_logic_vector(FRAC_BITS downto 0);
          A_0_5       : out std_logic_vector(FRAC_BITS downto 0);

          A_1_0 : out std_logic_vector(FRAC_BITS downto 0);
          A_1_1 : out std_logic_vector(FRAC_BITS downto 0);
          A_1_2 : out std_logic_vector(FRAC_BITS downto 0);
          A_1_3 : out std_logic_vector(FRAC_BITS downto 0);
          A_1_4 : out std_logic_vector(FRAC_BITS downto 0);
          A_1_5 : out std_logic_vector(FRAC_BITS downto 0);

          A_2_0 : out std_logic_vector(FRAC_BITS downto 0);
          A_2_1 : out std_logic_vector(FRAC_BITS downto 0);
          A_2_2 : out std_logic_vector(FRAC_BITS downto 0);
          A_2_3 : out std_logic_vector(FRAC_BITS downto 0);
          A_2_4 : out std_logic_vector(FRAC_BITS downto 0);
          A_2_5 : out std_logic_vector(FRAC_BITS downto 0);

          A_3_0 : out std_logic_vector(FRAC_BITS downto 0);
          A_3_1 : out std_logic_vector(FRAC_BITS downto 0);
          A_3_2 : out std_logic_vector(FRAC_BITS downto 0);
          A_3_3 : out std_logic_vector(FRAC_BITS downto 0);
          A_3_4 : out std_logic_vector(FRAC_BITS downto 0);
          A_3_5 : out std_logic_vector(FRAC_BITS downto 0);

          A_4_0 : out std_logic_vector(FRAC_BITS downto 0);
          A_4_1 : out std_logic_vector(FRAC_BITS downto 0);
          A_4_2 : out std_logic_vector(FRAC_BITS downto 0);
          A_4_3 : out std_logic_vector(FRAC_BITS downto 0);
          A_4_4 : out std_logic_vector(FRAC_BITS downto 0);
          A_4_5 : out std_logic_vector(FRAC_BITS downto 0);

          A_5_0 : out std_logic_vector(FRAC_BITS downto 0);
          A_5_1 : out std_logic_vector(FRAC_BITS downto 0);
          A_5_2 : out std_logic_vector(FRAC_BITS downto 0);
          A_5_3 : out std_logic_vector(FRAC_BITS downto 0);
          A_5_4 : out std_logic_vector(FRAC_BITS downto 0);
          A_5_5 : out std_logic_vector(FRAC_BITS downto 0);

          B_0 : out std_logic_vector(FRAC_BITS downto 0);
          B_1 : out std_logic_vector(FRAC_BITS downto 0);
          B_2 : out std_logic_vector(FRAC_BITS downto 0);
          B_3 : out std_logic_vector(FRAC_BITS downto 0);
          B_4 : out std_logic_vector(FRAC_BITS downto 0);
          B_5 : out std_logic_vector(FRAC_BITS downto 0)
          );
  end component;

  component sum_a_b_matrices is
    generic (
      FRAC_BITS_IN   : integer := 26;
      FRAC_BITS_OUT  : integer := 19;
      WHOLE_BITS_OUT : integer := 8);
    port (CLK : in std_logic;
          RST : in std_logic;

          INPUT_VALID  : in  std_logic;
          DONE         : in  std_logic;
          DONE_BUF     : out std_logic;
          OUTPUT_VALID : out std_logic;
          -- 1:0:26
          A_0_0        : in  std_logic_vector(FRAC_BITS_IN downto 0);
          A_0_1        : in  std_logic_vector(FRAC_BITS_IN downto 0);
          A_0_2        : in  std_logic_vector(FRAC_BITS_IN downto 0);
          A_0_3        : in  std_logic_vector(FRAC_BITS_IN downto 0);
          A_0_4        : in  std_logic_vector(FRAC_BITS_IN downto 0);
          A_0_5        : in  std_logic_vector(FRAC_BITS_IN downto 0);

          A_1_0 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_1_1 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_1_2 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_1_3 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_1_4 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_1_5 : in std_logic_vector(FRAC_BITS_IN downto 0);

          A_2_0 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_2_1 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_2_2 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_2_3 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_2_4 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_2_5 : in std_logic_vector(FRAC_BITS_IN downto 0);

          A_3_0 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_3_1 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_3_2 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_3_3 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_3_4 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_3_5 : in std_logic_vector(FRAC_BITS_IN downto 0);

          A_4_0 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_4_1 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_4_2 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_4_3 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_4_4 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_4_5 : in std_logic_vector(FRAC_BITS_IN downto 0);

          A_5_0 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_5_1 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_5_2 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_5_3 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_5_4 : in std_logic_vector(FRAC_BITS_IN downto 0);
          A_5_5 : in std_logic_vector(FRAC_BITS_IN downto 0);

          B_0 : in std_logic_vector(FRAC_BITS_IN downto 0);
          B_1 : in std_logic_vector(FRAC_BITS_IN downto 0);
          B_2 : in std_logic_vector(FRAC_BITS_IN downto 0);
          B_3 : in std_logic_vector(FRAC_BITS_IN downto 0);
          B_4 : in std_logic_vector(FRAC_BITS_IN downto 0);
          B_5 : in std_logic_vector(FRAC_BITS_IN downto 0);



          -- A Matrix Outputs (6x6)
          -- 1:WHOLE_BITS_OUT-1:FRAC_BITS_OUT
          A_0_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_0_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_0_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_0_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_0_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_0_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);

          A_1_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_1_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_1_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_1_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_1_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_1_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);

          A_2_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_2_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_2_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_2_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_2_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_2_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);

          A_3_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_3_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_3_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_3_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_3_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_3_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);

          A_4_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_4_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_4_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_4_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_4_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_4_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);

          A_5_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_5_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_5_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_5_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_5_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          A_5_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);

          -- b Vector Outputs (6x1)
          B_0_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          B_1_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          B_2_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          B_3_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          B_4_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0);
          B_5_S : out std_logic_vector(WHOLE_BITS_OUT+FRAC_BITS_OUT-1 downto 0)
          );
  end component;

  component gauss_elim is
    generic (
      WHOLE_BITS : integer := 8;
      FRAC_BITS  : integer := 19
      );
    port (CLK        : in std_logic;
          RST        : in std_logic;
          INPUT_LOAD : in std_logic;

          -- A Matrix Inputs (6x6)
          -- 1:WHOLE_BITS-1:FRAC_BITS
          A_0_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_0_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_0_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_0_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_0_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_0_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

          A_1_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_1_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_1_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_1_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_1_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_1_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

          A_2_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_2_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_2_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_2_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_2_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_2_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

          A_3_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_3_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_3_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_3_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_3_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_3_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

          A_4_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_4_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_4_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_4_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_4_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_4_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

          A_5_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_5_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_5_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_5_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_5_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          A_5_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

          -- b Vector Inputs (6x1)
          B_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          B_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          B_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          B_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          B_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          B_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

          -- x Vector Outputs (6x1)
          X_0 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          X_1 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          X_2 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          X_3 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          X_4 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          X_5 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

          OUTPUT_VALID : out std_logic
          );
  end component;

  component make_affine_homography is
    generic (
      WHOLE_BITS : integer := 8;
      FRAC_BITS  : integer := 19
      );
    port (CLK         : in std_logic;
          RST         : in std_logic;
          INPUT_VALID : in std_logic;
          X_0         : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          X_1         : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          X_2         : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          X_3         : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          X_4         : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          X_5         : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

          OUTPUT_VALID : out std_logic;
          H_0_0        : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_0_1        : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_0_2        : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_1_0        : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_1_1        : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_1_2        : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0)
          );
  end component;

  component unscale_h_matrix is
    generic (
      WHOLE_BITS : integer := 8;
      FRAC_BITS  : integer := 19
      );
    port (CLK          : in  std_logic;
          RST          : in  std_logic;
          H_0_0_I      : in  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_0_1_I      : in  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_0_2_I      : in  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_1_0_I      : in  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_1_1_I      : in  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_1_2_I      : in  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          -- The X and Y shift values
          XB           : in  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          YB           : in  std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          INPUT_VALID  : in  std_logic;
          OUTPUT_VALID : out std_logic;

          H_0_0 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_0_1 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_0_2 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_1_0 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_1_1 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
          H_1_2 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0));
  end component;
-- Homographies
  signal h_0_0_ma, h_0_1_ma, h_0_2_ma, h_1_0_ma, h_1_1_ma, h_1_2_ma : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

  signal x_0, x_1, x_2, x_3, x_4, x_5, x_6, x_7, x_8                : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal img0_0_1, img0_1_0, img0_1_1, img0_1_2, img0_2_1, img1_1_1 : std_logic_vector(PIXEL_BITS-1 downto 0);
  signal x_f, y_f, x_cs, y_cs                                       : std_logic_vector(IMGSIZE_BITS+1 downto 0);
  signal ix,iy,it : std_logic_vector(PIXEL_BITS downto 0);

-- A/b matrices
  signal a_0_0, a_1_0, a_2_0, a_3_0, a_4_0, a_5_0 : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal a_0_1, a_1_1, a_2_1, a_3_1, a_4_1, a_5_1 : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal a_0_2, a_1_2, a_2_2, a_3_2, a_4_2, a_5_2 : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal a_0_3, a_1_3, a_2_3, a_3_3, a_4_3, a_5_3 : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal a_0_4, a_1_4, a_2_4, a_3_4, a_4_4, a_5_4 : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal a_0_5, a_1_5, a_2_5, a_3_5, a_4_5, a_5_5 : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal b_0, b_1, b_2, b_3, b_4, b_5             : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

  signal a_0_0_s, a_1_0_s, a_2_0_s, a_3_0_s, a_4_0_s, a_5_0_s : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal a_0_1_s, a_1_1_s, a_2_1_s, a_3_1_s, a_4_1_s, a_5_1_s : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal a_0_2_s, a_1_2_s, a_2_2_s, a_3_2_s, a_4_2_s, a_5_2_s : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal a_0_3_s, a_1_3_s, a_2_3_s, a_3_3_s, a_4_3_s, a_5_3_s : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal a_0_4_s, a_1_4_s, a_2_4_s, a_3_4_s, a_4_4_s, a_5_4_s : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal a_0_5_s, a_1_5_s, a_2_5_s, a_3_5_s, a_4_5_s, a_5_5_s : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal b_0_s, b_1_s, b_2_s, b_3_s, b_4_s, b_5_s             : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);


-- Done/Valid
  signal done_f, done_cs, done_mab, done_sab                         : std_logic;
  signal valid_f, valid_cs, valid_mab, valid_sab, valid_ge, valid_sa, valid_ma : std_logic;
begin
-- Advisory Stage (Control which pyramid level/iteration we are on)
-- TODO Make a state machine (IDLE,SUMMING,SOLVING)

  -- Fetch Stage (Read memory to get convolution neighborhoods)
  fetch_stage_i : fetch_stage
    port map (
      CLK              => CLK,
      RST              => RST,
      LEVEL            => LEVEL,
      H_0_0            => H_0_0,
      H_0_1            => H_0_1,
      H_0_2            => H_0_2,
      H_1_0            => H_1_0,
      H_1_1            => H_1_1,
      H_1_2            => H_1_2,
      -- EXT INPUT
      MEM_VALUE        => MEM_VALUE,
      MEM_INPUT_VALID  => MEM_INPUT_VALID,
      -- EXT OUTPUT
      MEM_ADDR         => MEM_ADDR,
      MEM_BW_B         => MEM_BW_B,
      MEM_OUTPUT_VALID => MEM_OUTPUT_VALID,
      -- Output
      IMG0_0_1         => img0_0_1,
      IMG0_1_0         => img0_1_0,
      IMG0_1_1         => img0_1_1,
      IMG0_1_2         => img0_1_2,
      IMG0_2_1         => img0_2_1,
      IMG1_1_1         => img1_1_1,
      TRANS_X_COORD    => x_f,
      TRANS_Y_COORD    => y_f,
      FSCS_VALID       => valid_f,
      DONE             => done_f);

-- Compute Stage (Compute derivatives)
  compute_stage_i : compute_stage
    port map (CLK      => CLK,
              RST      => RST,
              IMG0_0_1 => img0_0_1,
              IMG0_1_0 => img0_1_0,
              IMG0_1_1 => img0_1_1,
              IMG0_1_2 => img0_1_2,
              IMG0_2_1 => img0_2_1,
              IMG1_1_1 => img1_1_1,

              TRANS_X_COORD     => x_f,
              TRANS_Y_COORD     => y_f,
              FSCS_VALID        => valid_f,
              DONE              => done_f,
              -- Output
              IX                => ix,
              IY                => iy,
              IT                => it,
              TRANS_X_COORD_BUF => x_cs,
              TRANS_Y_COORD_BUF => y_cs,
              DONE_BUF          => done_cs,
              CSSS_VALID        => valid_cs);

-- Make A/b matrices
  make_a_b_matrices_i : make_a_b_matrices
    port map (CLK         => CLK,
              RST         => RST,
              COORD_SHIFT => COORD_SHIFT,
              X           => x_cs,
              Y           => y_cs,
              FX          => ix,
              FY          => iy,
              FT          => it,
              VALID_IN    => valid_cs,
              DONE        => done_cs,
              -- Output
              DONE_BUF    => done_mab,
              VALID_OUT   => valid_mab,
              A_0_0       => a_0_0,
              A_0_1       => a_0_1,
              A_0_2       => a_0_2,
              A_0_3       => a_0_3,
              A_0_4       => a_0_4,
              A_0_5       => a_0_5,

              A_1_0 => a_1_0,
              A_1_1 => a_1_1,
              A_1_2 => a_1_2,
              A_1_3 => a_1_3,
              A_1_4 => a_1_4,
              A_1_5 => a_1_5,

              A_2_0 => a_2_0,
              A_2_1 => a_2_1,
              A_2_2 => a_2_2,
              A_2_3 => a_2_3,
              A_2_4 => a_2_4,
              A_2_5 => a_2_5,

              A_3_0 => a_3_0,
              A_3_1 => a_3_1,
              A_3_2 => a_3_2,
              A_3_3 => a_3_3,
              A_3_4 => a_3_4,
              A_3_5 => a_3_5,

              A_4_0 => a_4_0,
              A_4_1 => a_4_1,
              A_4_2 => a_4_2,
              A_4_3 => a_4_3,
              A_4_4 => a_4_4,
              A_4_5 => a_4_5,

              A_5_0 => a_5_0,
              A_5_1 => a_5_1,
              A_5_2 => a_5_2,
              A_5_3 => a_5_3,
              A_5_4 => a_5_4,
              A_5_5 => a_5_5,

              B_0 => b_0,
              B_1 => b_1,
              B_2 => b_2,
              B_3 => b_3,
              B_4 => b_4,
              B_5 => b_5);

-- Sum A/b matrices
  -- IN:  1:0:26
  -- INTERNAL: 1:7:26
  -- OUT: 1:7:19
  sum_a_b_matrices_i : sum_a_b_matrices
    port map (CLK         => CLK,
              RST         => RST,
              INPUT_VALID => valid_mab,
              DONE        => done_mab,
              A_0_0       => a_0_0,
              A_0_1       => a_0_1,
              A_0_2       => a_0_2,
              A_0_3       => a_0_3,
              A_0_4       => a_0_4,
              A_0_5       => a_0_5,

              A_1_0 => a_1_0,
              A_1_1 => a_1_1,
              A_1_2 => a_1_2,
              A_1_3 => a_1_3,
              A_1_4 => a_1_4,
              A_1_5 => a_1_5,

              A_2_0 => a_2_0,
              A_2_1 => a_2_1,
              A_2_2 => a_2_2,
              A_2_3 => a_2_3,
              A_2_4 => a_2_4,
              A_2_5 => a_2_5,

              A_3_0 => a_3_0,
              A_3_1 => a_3_1,
              A_3_2 => a_3_2,
              A_3_3 => a_3_3,
              A_3_4 => a_3_4,
              A_3_5 => a_3_5,

              A_4_0 => a_4_0,
              A_4_1 => a_4_1,
              A_4_2 => a_4_2,
              A_4_3 => a_4_3,
              A_4_4 => a_4_4,
              A_4_5 => a_4_5,

              A_5_0 => a_5_0,
              A_5_1 => a_5_1,
              A_5_2 => a_5_2,
              A_5_3 => a_5_3,
              A_5_4 => a_5_4,
              A_5_5 => a_5_5,

              B_0 => b_0,
              B_1 => b_1,
              B_2 => b_2,
              B_3 => b_3,
              B_4 => b_4,
              B_5 => b_5,

              -- Output
              DONE_BUF     => done_sab,
              OUTPUT_VALID => valid_sab,
              A_0_0_S      => a_0_0_s,
              A_0_1_S      => a_0_1_s,
              A_0_2_S      => a_0_2_s,
              A_0_3_S      => a_0_3_s,
              A_0_4_S      => a_0_4_s,
              A_0_5_S      => a_0_5_s,

              A_1_0_S => a_1_0_s,
              A_1_1_S => a_1_1_s,
              A_1_2_S => a_1_2_s,
              A_1_3_S => a_1_3_s,
              A_1_4_S => a_1_4_s,
              A_1_5_S => a_1_5_s,

              A_2_0_S => a_2_0_s,
              A_2_1_S => a_2_1_s,
              A_2_2_S => a_2_2_s,
              A_2_3_S => a_2_3_s,
              A_2_4_S => a_2_4_s,
              A_2_5_S => a_2_5_s,

              A_3_0_S => a_3_0_s,
              A_3_1_S => a_3_1_s,
              A_3_2_S => a_3_2_s,
              A_3_3_S => a_3_3_s,
              A_3_4_S => a_3_4_s,
              A_3_5_S => a_3_5_s,

              A_4_0_S => a_4_0_s,
              A_4_1_S => a_4_1_s,
              A_4_2_S => a_4_2_s,
              A_4_3_S => a_4_3_s,
              A_4_4_S => a_4_4_s,
              A_4_5_S => a_4_5_s,

              A_5_0_S => a_5_0_s,
              A_5_1_S => a_5_1_s,
              A_5_2_S => a_5_2_s,
              A_5_3_S => a_5_3_s,
              A_5_4_S => a_5_4_s,
              A_5_5_S => a_5_5_s,

              B_0_S => b_0_s,
              B_1_S => b_1_s,
              B_2_S => b_2_s,
              B_3_S => b_3_s,
              B_4_S => b_4_s,
              B_5_S => b_5_s);


-- Solve stage (Solve summed A/b matrices using gaussian elimination)
  -- TODO Make the GE INPUT_LOAD signal hook up to the state machine
  gauss_elim_i : gauss_elim
    port map (CLK        => CLK,
              RST        => RST,
              INPUT_LOAD => '1',        -- TODO THIS MUST BE CHANGED!!!
                                        -- 1:7:19
              A_0_0      => a_0_0_s,
              A_0_1      => a_0_1_s,
              A_0_2      => a_0_2_s,
              A_0_3      => a_0_3_s,
              A_0_4      => a_0_4_s,
              A_0_5      => a_0_5_s,

              A_1_0 => a_1_0_s,
              A_1_1 => a_1_1_s,
              A_1_2 => a_1_2_s,
              A_1_3 => a_1_3_s,
              A_1_4 => a_1_4_s,
              A_1_5 => a_1_5_s,

              A_2_0 => a_2_0_s,
              A_2_1 => a_2_1_s,
              A_2_2 => a_2_2_s,
              A_2_3 => a_2_3_s,
              A_2_4 => a_2_4_s,
              A_2_5 => a_2_5_s,

              A_3_0 => a_3_0_s,
              A_3_1 => a_3_1_s,
              A_3_2 => a_3_2_s,
              A_3_3 => a_3_3_s,
              A_3_4 => a_3_4_s,
              A_3_5 => a_3_5_s,

              A_4_0 => a_4_0_s,
              A_4_1 => a_4_1_s,
              A_4_2 => a_4_2_s,
              A_4_3 => a_4_3_s,
              A_4_4 => a_4_4_s,
              A_4_5 => a_4_5_s,

              A_5_0 => a_5_0_s,
              A_5_1 => a_5_1_s,
              A_5_2 => a_5_2_s,
              A_5_3 => a_5_3_s,
              A_5_4 => a_5_4_s,
              A_5_5 => a_5_5_s,

              B_0          => b_0_s,
              B_1          => b_1_s,
              B_2          => b_2_s,
              B_3          => b_3_s,
              B_4          => b_4_s,
              B_5          => b_5_s,
              -- Output
              X_0          => x_0,
              X_1          => x_1,
              X_2          => x_2,
              X_3          => x_3,
              X_4          => x_4,
              X_5          => x_5,
              OUTPUT_VALID => valid_ge);

-- Add diag([1,1,0]) to produce the homography between iterations
-- M=[p(2) p(3) p(1);p(5) p(6) p(4); 0 0 1];
  make_affine_homography_i : make_affine_homography
    port map (CLK          => CLK,
              RST          => RST,
              INPUT_VALID  => valid_ge,
              X_0          => x_0,
              X_1          => x_1,
              X_2          => x_2,
              X_3          => x_3,
              X_4          => x_4,
              X_5          => x_5,
              -- Output
              OUTPUT_VALID => valid_ma,
              H_0_0        => h_0_0_ma,
              H_0_1        => h_0_1_ma,
              H_0_2        => h_0_2_ma,
              H_1_0        => h_1_0_ma,
              H_1_1        => h_1_1_ma,
              H_1_2        => h_1_2_ma
              );

-- Make H matrix (transform solved values into a homography and multiply by
-- previous homography)
-- inv(T)*X*T
-- [                 h0,                 h1, -h0*xb-h1*yb+h2+xb]
-- [                 h3,                 h4, -h3*xb-h4*yb+h5+yb]
-- [                  0,                  0,                  1]
  unscale_h_matrix_i : unscale_h_matrix
    port map (CLK          => CLK,
              RST          => RST,
              H_0_0_I      => h_0_0_ma,
              H_0_1_I      => h_0_1_ma,
              H_0_2_I      => h_0_2_ma,
              H_1_0_I      => h_1_0_ma,
              H_1_1_I      => h_1_1_ma,
              H_1_2_I      => h_1_2_ma,
              XB           => COORD_TRANS,
              YB           => COORD_TRANS,
              INPUT_VALID  => valid_ma,
              -- Output
              OUTPUT_VALID => OUTPUT_VALID,
              H_0_0        => H_0_0_O,
              H_0_1        => H_0_1_O,
              H_0_2        => H_0_2_O,
              H_1_0        => H_1_0_O,
              H_1_1        => H_1_1_O,
              H_1_2        => H_1_2_O);

-- Make composed homography from the previous to the next
-- H*P
-- [    h0*p0+h1*p3,    h0*p1+h1*p4, h0*p2+h1*p5+h2]
-- [    h3*p0+h4*p3,    h3*p1+h4*p4, h3*p2+h4*p5+h5]
-- [              0,              0,              1]
--TODO Finish

end Behavioral;

