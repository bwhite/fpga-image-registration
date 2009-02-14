LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY smooth_conv_3x3 IS
  GENERIC (
    PIXEL_BITS  : integer := 9;
    KERNEL_BITS : integer := 16;
    SMOOTH_0_0  : integer := 16#0#;     -- TODO This does NO smoothing, should
                                        -- not change anything
    SMOOTH_0_1  : integer := 16#0#;  
    SMOOTH_1_1  : integer := 16#ffff#); 
--    SMOOTH_0_0  : integer := 16#133B#;   -- Corners
--    SMOOTH_0_1  : integer := 16#1FB4#;   -- Up/Down/Left/Right of center
--    SMOOTH_1_1  : integer := 16#3444#);  -- Center
  PORT (CLK          : IN  std_logic;
        RST          : IN  std_logic;
        INPUT_VALID  : IN  std_logic;
        -- 0:0:9
        IMG_0_0      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_0_1      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_0_2      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_1_0      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_1_1      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_1_2      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_2_0      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_2_1      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        IMG_2_2      : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
        OUTPUT_VALID : OUT std_logic;
        -- 0:0:9
        IMG_SMOOTH   : OUT std_logic_vector(PIXEL_BITS-1 DOWNTO 0));
END smooth_conv_3x3;

ARCHITECTURE Behavioral OF smooth_conv_3x3 IS
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


  TYPE   prod_vec3x1 IS ARRAY (2 DOWNTO 0) OF unsigned(PIXEL_BITS+KERNEL_BITS+2 DOWNTO 0);
  TYPE   sum_vec3x1 IS ARRAY (2 DOWNTO 0) OF unsigned(PIXEL_BITS+2 DOWNTO 0);
  SIGNAL smooth_prod    : prod_vec3x1;
  SIGNAL smooth_sum     : sum_vec3x1;
  SIGNAL img_smooth_reg : std_logic_vector(PIXEL_BITS+KERNEL_BITS+2 DOWNTO 0);
BEGIN
  -- NOTE: Since the kernel must sum to exactly 1, we do not need to check
  -- carry bits in the final sum
  IMG_SMOOTH <= img_smooth_reg(PIXEL_BITS+KERNEL_BITS-1 DOWNTO KERNEL_BITS);
  valid_pipeline : pipeline_bit_buffer
    GENERIC MAP (
      STAGES => 3)
    PORT MAP (
      CLK   => CLK,
      RST   => RST,
      SET   => '0',
      CLKEN => '1',
      DIN   => INPUT_VALID,
      DOUT  => OUTPUT_VALID);

  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge

      -- 0:3:PIXEL_BITS
      smooth_sum(0) <= ("000"&unsigned(IMG_0_0))+("000"&unsigned(IMG_0_2))+("000"&unsigned(IMG_2_0))+("000"&unsigned(IMG_2_2));
      smooth_sum(1) <= ("000"&unsigned(IMG_0_1))+("000"&unsigned(IMG_1_0))+("000"&unsigned(IMG_1_2))+("000"&unsigned(IMG_2_1));
      smooth_sum(2) <= ("000"&unsigned(IMG_1_1));

      -- 0:3:PIXEL_BITS+KERNEL_BITS
      smooth_prod(0) <= smooth_sum(0)*to_unsigned(SMOOTH_0_0, KERNEL_BITS);
      smooth_prod(1) <= smooth_sum(1)*to_unsigned(SMOOTH_0_1, KERNEL_BITS);
      smooth_prod(2) <= smooth_sum(2)*to_unsigned(SMOOTH_1_1, KERNEL_BITS);

      -- 0:3:PIXEL_BITS+KERNEL_BITS
      -- Sum results, round to nearest
      -- Total Size PIXEL_BITS+KERNEL_BITS+2 DOWNTO 0
      img_smooth_reg <= std_logic_vector(smooth_prod(0)+smooth_prod(1)+smooth_prod(2));
    END IF;
  END PROCESS;
END Behavioral;

