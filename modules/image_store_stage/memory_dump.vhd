LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY memory_dump IS
  GENERIC (
    BASE_OFFSET  : integer := 0;
    COUNT_LENGTH : integer := 786432;
    COUNTER_BITS : integer := 20;
    ADDR_BITS    : integer := 20
    );
  PORT (CLK            : IN  std_logic;
         RST           : IN  std_logic;
         MEM_ADDR      : OUT std_logic_vector(ADDR_BITS-1 DOWNTO 0);
         MEM_OUT_VALID : OUT std_logic;
         DONE          : OUT std_logic
         );
END memory_dump;

ARCHITECTURE Behavioral OF memory_dump IS
  SIGNAL mem_addr_reg      : unsigned(ADDR_BITS-1 DOWNTO 0)    := (OTHERS => '0');
  SIGNAL counter           : unsigned(COUNTER_BITS-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL mem_out_valid_reg : std_logic                         := '0';
  SIGNAL done_reg : std_logic := '0';
BEGIN
  MEM_ADDR <= std_logic_vector(mem_addr_reg);
  MEM_OUT_VALID <= mem_out_valid_reg;
  DONE <= done_reg;
  
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        mem_addr_reg      <= (OTHERS => '0');
        counter           <= (OTHERS => '0');
        mem_out_valid_reg <= '0';
        done_reg <= '0';
      ELSE
        IF counter >= COUNT_LENGTH THEN
          done_reg          <= '1';
          mem_out_valid_reg <= '0';
        ELSE
          counter           <= counter + 1;
          mem_addr_reg      <= counter + BASE_OFFSET;
          mem_out_valid_reg <= '1';
        END IF;
      END IF;
    END IF;
  END PROCESS;

END Behavioral;

