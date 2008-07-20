LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY smooth_conv_3x3 IS
  GENERIC (
    PIXEL_BITS       :     integer := 9;
    KERNEL_BITS      :     integer := 16;
    SMOOTH_0_0       :     integer := 16#133B#;
    SMOOTH_0_1       :     integer := 16#1FB4#;
    SMOOTH_0_2       :     integer := 16#133B#;
    SMOOTH_1_0       :     integer := 16#1FB4#;
    SMOOTH_1_1       :     integer := 16#3445#;
    SMOOTH_1_2       :     integer := 16#1FB4#;
    SMOOTH_2_0       :     integer := 16#133B#;
    SMOOTH_2_1       :     integer := 16#1FB4#;
    SMOOTH_2_2       :     integer := 16#133B#);
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
                                    STAGES  :     integer := 1);
                                PORT (CLK   : IN  std_logic;
                                      RST   : IN  std_logic;
                                      SET   : IN  std_logic;
                                      CLKEN : IN  std_logic;
                                      DIN   : IN  std_logic;
                                      DOUT  : OUT std_logic);
  END COMPONENT;


  TYPE prod_vec9x1 IS ARRAY (8 DOWNTO 0) OF std_logic_vector(PIXEL_BITS+KERNEL_BITS-1 DOWNTO 0);
  TYPE sum_vec3x1 IS ARRAY (2 DOWNTO 0) OF std_logic_vector(PIXEL_BITS+KERNEL_BITS-1 DOWNTO 0);
  SIGNAL smooth_prod0, smooth_prod1 : prod_vec9x1;
  SIGNAL smooth_sum                 : sum_vec3x1;
  SIGNAL smooth_full                : std_logic_vector(PIXEL_BITS+KERNEL_BITS DOWNTO 0);
BEGIN
  valid_pipeline                    : pipeline_bit_buffer
    GENERIC MAP (
      STAGES => 5)
    PORT MAP (
      CLK    => CLK,
      RST    => RST,
      SET    => '0',
      CLKEN  => '1',
      DIN    => INPUT_VALID,
      DOUT   => OUTPUT_VALID);

  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge

      -- 0:0:PIXEL_BITS+KERNEL_BITS
      smooth_prod0(0) <= unsigned(IMG_0_0)*to_unsigned(SMOOTH_0_0, KERNEL_BITS);
      smooth_prod0(1) <= unsigned(IMG_0_1)*to_unsigned(SMOOTH_0_1, KERNEL_BITS);
      smooth_prod0(2) <= unsigned(IMG_0_2)*to_unsigned(SMOOTH_0_2, KERNEL_BITS);
      smooth_prod0(3) <= unsigned(IMG_1_0)*to_unsigned(SMOOTH_1_0, KERNEL_BITS);
      smooth_prod0(4) <= unsigned(IMG_1_1)*to_unsigned(SMOOTH_1_1, KERNEL_BITS);
      smooth_prod0(5) <= unsigned(IMG_1_2)*to_unsigned(SMOOTH_1_2, KERNEL_BITS);
      smooth_prod0(6) <= unsigned(IMG_2_0)*to_unsigned(SMOOTH_2_0, KERNEL_BITS);
      smooth_prod0(7) <= unsigned(IMG_2_1)*to_unsigned(SMOOTH_2_1, KERNEL_BITS);
      smooth_prod0(8) <= unsigned(IMG_2_2)*to_unsigned(SMOOTH_2_2, KERNEL_BITS);

      smooth_prod1 <= smooth_prod0;

      -- As long as the smoothing kernel sums to 1 we only need 1 carry bit,
      -- it will be checked and the result saturated such that we have no
      -- whole bits.
      -- 0:0:PIXEL_BITS+KERNEL_BITS
      FOR i IN 2 DOWNTO 0 LOOP
        smooth_sum(i) <= smooth_prod1(3*i)+smooth_prod1(3*i+1)+smooth_prod1(3*i+2);
      END LOOP;  -- i

      -- 0:1:PIXEL_BITS+KERNEL_BITS
      smooth_full <= '0'&smooth_sum(0)+'0'&smooth_sum(1)+'0'&smooth_sum(2);

      -- IMG_SMOOTH
      -- 0:0:PIXEL_BITS
      IF smooth_full(PIXEL_BITS+KERNEL_BITS) = '0' THEN
        IMG_SMOOTH <= smooth_full(PIXEL_BITS+KERNEL_BITS-1 DOWNTO KERNEL_BITS);
      ELSE
        IMG_SMOOTH <= (OTHERS => '1');
      END IF;
    END IF;
  END PROCESS;

END Behavioral;

