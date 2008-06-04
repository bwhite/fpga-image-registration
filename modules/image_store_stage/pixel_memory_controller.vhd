LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pixel_memory_controller IS
  PORT (CLK    : IN std_logic;
        CLK_OE : IN std_logic;
        RST    : IN std_logic;

        -- Control signals
        ADDR             : IN  std_logic_vector (19 DOWNTO 0);
        WE_B             : IN  std_logic;
        CS_B             : IN  std_logic;
        PIXEL_WRITE      : IN  std_logic_vector (8 DOWNTO 0);
        PIXEL_READ       : OUT std_logic_vector(8 DOWNTO 0);
        PIXEL_READ_VALID : OUT std_logic;

        -- SRAM Connections
        SRAM_ADV_LD_B : OUT   std_logic;
        SRAM_ADDR     : OUT   std_logic_vector (17 DOWNTO 0);
        SRAM_WE_B     : OUT   std_logic;
        SRAM_BW_B     : OUT   std_logic_vector (3 DOWNTO 0);
        SRAM_CKE_B    : OUT   std_logic;
        SRAM_CS_B     : OUT   std_logic;
        SRAM_OE_B     : OUT   std_logic;
        SRAM_DATA     : INOUT std_logic_vector (35 DOWNTO 0));
END pixel_memory_controller;

ARCHITECTURE Behavioral OF pixel_memory_controller IS
  COMPONENT zbt_controller IS
    PORT (CLK : IN std_logic;
          RST : IN std_logic;

          -- Control signals
          ADV_LD_B        : IN  std_logic;
          ADDR            : IN  std_logic_vector (17 DOWNTO 0);
          WE_B            : IN  std_logic;
          BW_B            : IN  std_logic_vector (3 DOWNTO 0);
          CKE_B           : IN  std_logic;
          CS_B            : IN  std_logic;
          DATA_WRITE      : IN  std_logic_vector (35 DOWNTO 0);
          DATA_READ       : OUT std_logic_vector(35 DOWNTO 0);
          DATA_READ_VALID : OUT std_logic;

          -- SRAM Connections
          SRAM_ADV_LD_B : OUT   std_logic;
          SRAM_ADDR     : OUT   std_logic_vector (17 DOWNTO 0);
          SRAM_WE_B     : OUT   std_logic;
          SRAM_BW_B     : OUT   std_logic_vector (3 DOWNTO 0);
          SRAM_CKE_B    : OUT   std_logic;
          SRAM_CS_B     : OUT   std_logic;
          SRAM_OE_B     : OUT   std_logic;
          SRAM_DATA     : INOUT std_logic_vector (35 DOWNTO 0));
  END COMPONENT zbt_controller;
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
  SIGNAL byte_buf                             : std_logic_vector(1 DOWNTO 0);
  SIGNAL data_read, data_write, data_read_buf : std_logic_vector(35 DOWNTO 0);
  SIGNAL bw_b                                 : std_logic_vector(3 DOWNTO 0);
BEGIN
-- Byte Buffer: Buffers 2CTs the last 2 bits of the address which are used to
-- select which 9bit segment we want from the incoming data
  byte_pipe : pipeline_buffer
    GENERIC MAP (
      WIDTH         => 2,
      STAGES        => 3,
      DEFAULT_VALUE => 0)
    PORT MAP (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => ADDR(1 DOWNTO 0),
      DOUT  => byte_buf);

  -- Pad the pixel data with zeros and set the byte write mask to only write to
  -- the correct pixel
  PROCESS (ADDR(1 DOWNTO 0), PIXEL_WRITE) IS
  BEGIN  -- PROCESS
    CASE ADDR(1 DOWNTO 0) IS
      WHEN "00" =>
        bw_b       <= "1110";
        data_write <= (26 DOWNTO 0 => '0') & PIXEL_WRITE;
      WHEN "01" =>
        bw_b       <= "1101";
        data_write <= (17 DOWNTO 0 => '0') & PIXEL_WRITE & (8 DOWNTO 0 => '0');
      WHEN "10" =>
        bw_b       <= "1011";
        data_write <= (8 DOWNTO 0 => '0') & PIXEL_WRITE & (17 DOWNTO 0 => '0');
      WHEN "11" =>
        bw_b       <= "0111";
        data_write <= PIXEL_WRITE & (26 DOWNTO 0 => '0');
      WHEN OTHERS => NULL;

    END CASE;
  END PROCESS;

  -- Extract the pixel that we requested from the 4 read
  PROCESS (byte_buf, data_read_buf) IS
  BEGIN  -- PROCESS
    CASE byte_buf IS
      WHEN "00" =>
        PIXEL_READ <= data_read_buf(8 DOWNTO 0);
      WHEN "01" =>
        PIXEL_READ <= data_read_buf(17 DOWNTO 9);
      WHEN "10" =>
        PIXEL_READ <= data_read_buf(26 DOWNTO 18);
      WHEN "11" =>
        PIXEL_READ <= data_read_buf(35 DOWNTO 27);
      WHEN OTHERS => NULL;
    END CASE;
  END PROCESS;

  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      data_read_buf <= data_read;
    END IF;
  END PROCESS;
  
  zbt_controller_i : zbt_controller PORT MAP (
    CLK => CLK,
    RST => RST,

    -- Control signals
    ADV_LD_B        => '0',
    ADDR            => ADDR(19 DOWNTO 2),
    WE_B            => WE_B,
    BW_B            => bw_b,
    CKE_B           => '0',
    CS_B            => CS_B,
    DATA_WRITE      => data_write,
    DATA_READ       => data_read,
    DATA_READ_VALID => PIXEL_READ_VALID,

    -- SRAM Connections
    SRAM_ADV_LD_B => SRAM_ADV_LD_B,
    SRAM_ADDR     => SRAM_ADDR,
    SRAM_WE_B     => SRAM_WE_B,
    SRAM_BW_B     => SRAM_BW_B,
    SRAM_CKE_B    => SRAM_CKE_B,
    SRAM_CS_B     => SRAM_CS_B,
    SRAM_OE_B     => SRAM_OE_B,
    SRAM_DATA     => SRAM_DATA);
END Behavioral;

