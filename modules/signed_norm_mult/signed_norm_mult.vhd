library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity signed_norm_mult is
  generic (
    FRAC_BITS : integer := 26;
    DELAY     : integer := 3);
  port (CLK      : in  std_logic;
        RST      : in  std_logic;
        VALID_IN : in  std_logic;
        -- 1:0:FRAC_BITS
        A        : in  std_logic_vector (FRAC_BITS downto 0);
        B        : in  std_logic_vector (FRAC_BITS downto 0);
        C        : out std_logic_vector (FRAC_BITS downto 0);

        VALID_OUT : out std_logic);
end signed_norm_mult;

architecture Behavioral of signed_norm_mult is
  component pipeline_bit_buffer is
    generic (
      STAGES : integer := 1);
    port (CLK   : in  std_logic;
          RST   : in  std_logic;
          SET   : in  std_logic;
          CLKEN : in  std_logic;
          DIN   : in  std_logic;
          DOUT  : out std_logic);
  end component;

  component pipeline_buffer is
    generic (
      WIDTH         : integer := 1;
      STAGES        : integer := 1;
      DEFAULT_VALUE : integer := 2#0#);
    port (CLK   : in  std_logic;
          RST   : in  std_logic;
          CLKEN : in  std_logic;
          DIN   : in  std_logic_vector(WIDTH-1 downto 0);
          DOUT  : out std_logic_vector(WIDTH-1 downto 0));
  end component;


  signal c_wire, c_buf : std_logic_vector(2*FRAC_BITS+1 downto 0);
  signal valid_in_buf : std_logic;

begin
  c_wire <= std_logic_vector(signed(A)*signed(B));


process (CLK)
begin  -- process
  if CLK'event and CLK = '1' then       -- rising clock edge
    if c_buf(2*FRAC_BITS+1) = c_buf(2*FRAC_BITS) then
      VALID_OUT <= valid_in_buf;
    else
      VALID_OUT <= '0';
    end if;
      C      <= c_buf(2*FRAC_BITS downto 2*FRAC_BITS-FRAC_BITS);
  end if;
end process;
  
  valid_buffer : pipeline_bit_buffer
    generic map (
      STAGES => DELAY)                      
    port map (
      CLK   => CLK,
      SET   => '0',
      RST   => RST,
      CLKEN => '1',
      DIN   => VALID_IN,
      DOUT  => valid_in_buf);

  mult_buffer : pipeline_buffer
    generic map (
      WIDTH         => 2*FRAC_BITS+2,
      STAGES        => DELAY)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => c_wire,
      DOUT  => c_buf);
end Behavioral;
