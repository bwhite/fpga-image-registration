LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY pipeline_bit_buffer IS
  GENERIC (
    STAGES : integer := 1);
  PORT (CLK   : IN  std_logic;
        RST   : IN  std_logic;
        SET   : IN  std_logic;
        CLKEN : IN  std_logic;
        DIN   : IN  std_logic;
        DOUT  : OUT std_logic);
END pipeline_bit_buffer;

ARCHITECTURE Behavioral OF pipeline_bit_buffer IS
  TYPE   pipe_stages IS ARRAY (STAGES-1 DOWNTO 0) OF std_logic;
  SIGNAL buf : pipe_stages;
BEGIN
  -- NOTE: Unfortunately ISE 10.1 didn't like the 'clean' version of this (see
  -- the pipeline_buffer as an example), so I had to revert back to this messy
  -- way.  Until they fix it, this will have to stay the way it is.
  DOUT <= buf(STAGES-1);
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        FOR i IN STAGES-1 DOWNTO 0 LOOP
          buf(i) <= '0';
        END LOOP;  -- i
      ELSIF SET = '1' THEN
        FOR i IN STAGES-1 DOWNTO 0 LOOP
          buf(i) <= '1';
        END LOOP;  -- i
      ELSIF CLKEN = '1' THEN
        IF STAGES > 2 THEN
          FOR i IN STAGES-2 DOWNTO 0 LOOP
            buf(i+1) <= buf(i);
          END LOOP;  -- i
        END IF;
        buf(0) <= DIN;
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

