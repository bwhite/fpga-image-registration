
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;



entity right_shifter is
  generic (
    SIZE : integer := 27);
  port (CLK         : in  std_logic;
        COORD_SHIFT : in  std_logic_vector(3 downto 0);
        DIN         : in  std_logic_vector(SIZE-1 downto 0);
        DOUT        : out std_logic_vector(SIZE-1 downto 0));
end right_shifter;

architecture Behavioral of right_shifter is

begin
  process (CLK)
  begin  -- process
    if CLK'event and CLK = '1' then     -- rising clock edge
      case COORD_SHIFT is
        when "0101" =>                  -- 5
          DOUT(SIZE-1-5 downto 0)    <= DIN(SIZE-1 downto 5);
          DOUT(SIZE-1 downto SIZE-5) <= (others => DIN(SIZE-1));
        when "0110" =>                  -- 6
          DOUT(SIZE-1-6 downto 0)    <= DIN(SIZE-1 downto 6);
          DOUT(SIZE-1 downto SIZE-6) <= (others => DIN(SIZE-1));
        when "0111" =>                  -- 7
          DOUT(SIZE-1-7 downto 0)    <= DIN(SIZE-1 downto 7);
          DOUT(SIZE-1 downto SIZE-7) <= (others => DIN(SIZE-1));
        when "1000" =>                  -- 8
          DOUT(SIZE-1-8 downto 0)    <= DIN(SIZE-1 downto 8);
          DOUT(SIZE-1 downto SIZE-8) <= (others => DIN(SIZE-1));
        when "1001" =>                  -- 9
          DOUT(SIZE-1-9 downto 0)    <= DIN(SIZE-1 downto 9);
          DOUT(SIZE-1 downto SIZE-9) <= (others => DIN(SIZE-1));
        when "1010" =>                  -- 10
          DOUT(SIZE-1-10 downto 0)    <= DIN(SIZE-1 downto 10);
          DOUT(SIZE-1 downto SIZE-10) <= (others => DIN(SIZE-1));
        when others => null;
      end case;      
    end if;
  end process;
end Behavioral;

