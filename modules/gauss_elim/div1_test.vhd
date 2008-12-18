library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity div1_test is
  generic (
    QUOTIENT_BITS : integer := 27;
    FRACTION_BITS : integer := 19);
  port (clk       : in  std_logic;
        rst   : in std_logic;
        valid_in  : in  std_logic;
        a         : in  std_logic_vector (QUOTIENT_BITS-1 downto 0);
        b         : in  std_logic_vector (QUOTIENT_BITS-1 downto 0);
        c         : out std_logic_vector (QUOTIENT_BITS-1 downto 0);
        oob       : out std_logic;
        valid_out : out std_logic);
end div1_test;

architecture Behavioral of div1_test is
  component div1 is
    port (
      clk            : in  std_logic;
      nd             : in  std_logic;
      dividend       : in  std_logic_vector (QUOTIENT_BITS-1 downto 0);
      divisor        : in  std_logic_vector (QUOTIENT_BITS-1 downto 0);
      rfd            : out std_logic;
      rdy            : out std_logic;
      divide_by_zero : out std_logic;
      quotient       : out std_logic_vector (QUOTIENT_BITS-1 downto 0);
      fractional     : out std_logic_vector (FRACTION_BITS-1 downto 0)
      );
  end component;
  signal quotient_wire  : std_logic_vector(QUOTIENT_BITS-1 downto 0);
  signal frac_wire      : std_logic_vector(FRACTION_BITS-1 downto 0);
  signal divide_by_zero,valid_wire,valid_out_wire : std_logic;
begin
  c(QUOTIENT_BITS-1 downto FRACTION_BITS) <= quotient_wire(QUOTIENT_BITS-FRACTION_BITS-1 downto 0);
  c(FRACTION_BITS-1 downto 0)             <= frac_wire;
  process (quotient_wire,divide_by_zero)
  begin  -- process
    -- and (quotient_wire(QUOTIENT_BITS-1 downto QUOTIENT_BITS-FRACTION_BITS-1) = (QUOTIENT_BITS-1 downto QUOTIENT_BITS-FRACTION_BITS-1 => '0') or quotient_wire(QUOTIENT_BITS-1 downto QUOTIENT_BITS-FRACTION_BITS-1) = (QUOTIENT_BITS-1 downto QUOTIENT_BITS-FRACTION_BITS-1 => '1')) 
    if divide_by_zero = '0' then
      oob <= '0';
    else
      oob <= '1';
    end if;
  end process;
  
  valid_wire <= VALID_IN and (not RST);
  VALID_OUT <= valid_out_wire;
  
  
  div : div1
    port map (
      CLK            => CLK,
      ND             => valid_wire,
      DIVIDEND       => A,
      DIVISOR        => B,
--      RFD        => RFD,
      RDY            => valid_out_wire,
      divide_by_zero => divide_by_zero,
      QUOTIENT       => quotient_wire,
      FRACTIONAL     => frac_wire);

end Behavioral;
