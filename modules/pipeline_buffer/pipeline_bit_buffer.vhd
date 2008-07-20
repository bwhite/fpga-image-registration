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
  TYPE   pipe_stages IS ARRAY (STAGES DOWNTO 0) OF std_logic;
  SIGNAL buf : pipe_stages;
BEGIN
  buf(0) <= DIN;
  DOUT   <= buf(STAGES);
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)
        FOR i IN STAGES DOWNTO 1 LOOP
          buf(i) <= '0';
        END LOOP;  -- i
      ELSIF SET = '1' THEN
        FOR i IN STAGES DOWNTO 1 LOOP
          buf(i) <= '1';
        END LOOP;  -- i
      ELSIF CLKEN = '1' THEN
        FOR i IN STAGES-1 DOWNTO 0 LOOP
          buf(i+1) <= buf(i);
        END LOOP;  -- i
      END IF;
    END IF;
  END PROCESS;
END Behavioral;

