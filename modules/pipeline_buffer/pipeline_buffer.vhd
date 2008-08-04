LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY pipeline_buffer IS
  GENERIC (
    WIDTH         :     integer := 1;
    STAGES        :     integer := 1;
    DEFAULT_VALUE :     integer := 2#0#);
  PORT ( CLK      : IN  std_logic;
         RST      : IN  std_logic;
         CLKEN    : IN  std_logic;
         DIN      : IN  std_logic_vector(WIDTH-1 DOWNTO 0);
         DOUT     : OUT std_logic_vector(WIDTH-1 DOWNTO 0));
END pipeline_buffer;

ARCHITECTURE Behavioral OF pipeline_buffer IS
  TYPE pipe_stages IS ARRAY (STAGES-1 DOWNTO 0) OF std_logic_vector(WIDTH-1 DOWNTO 0);
  SIGNAL buf : pipe_stages;
BEGIN
  -- NOTE: Unfortunately ISE 10.1 didn't like the 'clean' version of this (see
  -- the older pipeline_buffer as an example), so I had to revert back to this messy
  -- way.  Until they fix it, this will have to stay the way it is.
  DOUT               <= buf(STAGES-1);
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        FOR i IN STAGES-1 DOWNTO 0 LOOP
          buf(i)     <= std_logic_vector(to_unsigned(DEFAULT_VALUE,WIDTH));
        END LOOP;  -- i
      ELSE
        IF CLKEN = '1' THEN
          FOR i IN STAGES-2 DOWNTO 0 LOOP
            buf(i+1) <= buf(i);
          END LOOP;  -- i
          buf(0) <= DIN;
        END IF;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

