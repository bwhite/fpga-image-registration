
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY smooth_address_selector IS
  GENERIC (
    IMGSIZE_BITS : integer := 10;
    PIXEL_BITS   : integer := 9;
    MEM_DELAY    : integer := 4);

  
  PORT (CLK              : IN  std_logic;
        RST              : IN  std_logic;
        IMG_MEM_ADDR     : IN  std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
        IMG_ADDR_VALID   : IN  std_logic;
        CONV_Y_POS       : IN  std_logic_vector(1 DOWNTO 0);
        SMOOTH_VALID     : IN  std_logic;
        MEM_ADDROFF0     : IN  std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
        MEM_ADDROFF1     : IN  std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
        MEM_ADDR         : OUT std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
        MEM_RE           : OUT std_logic;
        MEM_OUTPUT_VALID : OUT std_logic;
        PIXGEN_CLKEN     : OUT std_logic;
        PIXEL_STATE      : OUT std_logic_vector(2 DOWNTO 0));

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
  SIGNAL img_mem_addr_buf                                                   : std_logic_vector(IMGSIZE_BITS*2-1 DOWNTO 0);
  SIGNAL img_addr_valid_buf, output_valid_reg, mem_re_reg, addr_select_img0 : std_logic;
  SIGNAL img_addr_valid_wire , img_addr_valid_buf_wire                      : std_logic_vector(0 DOWNTO 0);
  SIGNAL mem_address_reg                                                    : unsigned(IMGSIZE_BITS*2-1 DOWNTO 0);
BEGIN
  img_addr_valid_wire <= (0 DOWNTO 0 => IMG_ADDR_VALID);
  img_addr_valid_buf  <= img_addr_valid_buf_wire(0);
  MEM_OUTPUT_VALID    <= output_valid_reg;
  MEM_RE              <= mem_re_reg;
  PIXGEN_CLKEN        <= addr_select_img0;
  MEM_ADDR            <= std_logic_vector(mem_address_reg);

-------------------------------------------------------------------------------
-- IMG Mem Addr Buffer
  pipebuf_mem_addr : pipeline_buffer
    GENERIC MAP (
      WIDTH         => IMGSIZE_BITS*2,
      STAGES        => 4,               -- TODO Fix this
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK   => CLK,
      RST   => '0',
      CLKEN => '1',
      DIN   => IMG_MEM_ADDR,
      DOUT  => img_mem_addr_buf);

-------------------------------------------------------------------------------
-- IMG Mem Addr Valid Buffer
  pipebuf_valid : pipeline_buffer
    GENERIC MAP (
      WIDTH         => 1,
      STAGES        => 4,    -- TODO Fix this
      DEFAULT_VALUE => 2#0#)
    PORT MAP (
      CLK   => CLK,
      RST   => '0',
      CLKEN => '1',
      DIN   => img_addr_valid_wire,
      DOUT  => img_addr_valid_buf_wire);

  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN       -- rising clock edge
      IF RST = '1' THEN                   -- synchronous reset (active high)
        addr_select_img0 <= '1';
      ELSE
        IF unsigned(CONV_Y_POS) = 2 THEN  -- IMG1 -- TODO Correct this value
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
          mem_address_reg  <= unsigned(IMG_MEM_ADDR) + unsigned(MEM_ADDROFF0);  -- IMG0
          output_valid_reg <= IMG_ADDR_VALID;
          mem_re_reg       <= '1';
        ELSE
          mem_address_reg  <= unsigned(img_mem_addr_buf) + unsigned(MEM_ADDROFF1);  -- IMG1
          output_valid_reg <= img_addr_valid_buf;
          mem_re_reg       <= '0';
        END IF;

        PIXEL_STATE <= CONV_Y_POS & addr_select_img0;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;
