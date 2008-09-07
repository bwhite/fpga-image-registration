
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY smooth_address_selector IS
  GENERIC (
    IMGSIZE_BITS   : integer := 10;
    PIXEL_BITS     : integer := 9;
    MEM_DELAY      : integer := 4;
    IMG_ADDR_DELAY : integer := 4);

  
  PORT (CLK              : IN  std_logic;
        RST              : IN  std_logic;
        IMG_MEM_ADDR     : IN  std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
        IMG_ADDR_VALID   : IN  std_logic;
        CONV_Y_POS       : IN  std_logic_vector(1 DOWNTO 0);
        SMOOTH_VALID     : IN  std_logic;
        MEM_ADDROFF     : IN  std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
        MEM_ADDR         : OUT std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
        MEM_RE           : OUT std_logic;
        MEM_OUTPUT_VALID : OUT std_logic;
        PIXGEN_CLKEN     : OUT std_logic);
END smooth_address_selector;

ARCHITECTURE Behavioral OF smooth_address_selector IS
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
  SIGNAL img_mem_addr_buf                                                   : std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
  SIGNAL img_addr_valid_buf, output_valid_reg, mem_re_reg, addr_select_img0 : std_logic;
  SIGNAL mem_address_reg                                                    : unsigned(IMGSIZE_BITS*2-1 DOWNTO 0);
BEGIN
  PIXGEN_CLKEN     <= addr_select_img0;
  MEM_ADDR         <= std_logic_vector(mem_address_reg);
  MEM_OUTPUT_VALID <= output_valid_reg;
  MEM_RE           <= mem_re_reg;

-------------------------------------------------------------------------------
-- IMG Mem Addr Buffer
  pipebuf_mem_addr : pipeline_buffer
    GENERIC MAP (
      WIDTH         => IMGSIZE_BITS*2,
      STAGES        => IMG_ADDR_DELAY,
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK   => CLK,
      RST   => '0',
      CLKEN => '1',--addr_select_img0,
      DIN   => IMG_MEM_ADDR,
      DOUT  => img_mem_addr_buf);

-------------------------------------------------------------------------------
-- IMG Mem Addr Valid Buffer
  pipebuf_valid : pipeline_bit_buffer
    GENERIC MAP (
      STAGES => IMG_ADDR_DELAY)
    PORT MAP (
      CLK   => CLK,
      RST   => RST,
      SET   => '0',
      CLKEN => '1',--addr_select_img0,
      DIN   => IMG_ADDR_VALID,
      DOUT  => img_addr_valid_buf);

  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        addr_select_img0 <= '1';
      ELSE
        IF unsigned(CONV_Y_POS) = 2 AND addr_select_img0 = '1' THEN
          -- Allows module to increment on this CT (where it will be 0, then it
          -- will be paused for 1 CT)
          addr_select_img0 <= '0';
        ELSE
          addr_select_img0 <= '1';
        END IF;

        -- Select which mem address to use, and add the proper offset to it
        IF addr_select_img0 = '1' THEN
          -- Add an offset to the input address, set the read flag, and pass on
          -- the validity of the address
          mem_address_reg  <= '0'&(unsigned(IMG_MEM_ADDR(18 DOWNTO 0))+unsigned(MEM_ADDROFF(18 DOWNTO 0)));
          output_valid_reg <= IMG_ADDR_VALID;
          mem_re_reg       <= '1';
        ELSE
          mem_address_reg <= '1'&(unsigned(img_mem_addr_buf(18 DOWNTO 0))+unsigned(MEM_ADDROFF(18 DOWNTO 0)));  -- IMG1
          IF SMOOTH_VALID = '1' AND img_addr_valid_buf = '1' THEN
            output_valid_reg <= '1';
            mem_re_reg       <= '0';
          ELSE
            output_valid_reg <= '0';
            mem_re_reg       <= '1';
          END IF;          
        END IF;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;
