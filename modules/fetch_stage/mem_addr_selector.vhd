LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY mem_addr_selector IS
  GENERIC (
    MEMADDR_BITS       :     integer := 20;
    PIXSTATE_BITS      :     integer := 2);
  PORT ( CLK           : IN  std_logic;
         RST           : IN  std_logic;
         INPUT_VALID0  : IN  std_logic;
         INPUT_VALID1  : IN  std_logic;
         PIXEL_STATE   : IN  std_logic_vector(PIXSTATE_BITS-1 DOWNTO 0);
         MEM_ADDR0     : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
         MEM_ADDR1     : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
         MEM_ADDROFF  : IN  std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
         PATTERN_STATE : OUT std_logic_vector (PIXSTATE_BITS DOWNTO 0);
         MEM_ADDR      : OUT std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
         MEM_BW_B         : OUT std_logic_vector(3 DOWNTO 0);
         OUTPUT_VALID  : OUT std_logic;
         PIXGEN_CLKEN  : OUT std_logic);
END mem_addr_selector;

ARCHITECTURE Behavioral OF mem_addr_selector IS
  SIGNAL addr_select_img0  : std_logic                                := '1';
  SIGNAL output_valid_reg  : std_logic                                := '0';
  SIGNAL pattern_state_reg : std_logic_vector(PIXSTATE_BITS DOWNTO 0) := (OTHERS => '0');
  SIGNAL mem_addr_wire : std_logic_vector(MEMADDR_BITS-1 DOWNTO 0);
  SIGNAL output_valid_wire : std_logic;
BEGIN
  PIXGEN_CLKEN             <= addr_select_img0;
  OUTPUT_VALID             <= output_valid_reg;
  PATTERN_STATE            <= pattern_state_reg;
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN        -- rising clock edge
      IF RST = '1' THEN                    -- synchronous reset (active high)
        addr_select_img0   <= '1';
        MEM_ADDR           <= (OTHERS                                            => '0');
        output_valid_reg   <= '0';
        pattern_state_reg <= (OTHERS => '0');
      ELSE
        IF unsigned(PIXEL_STATE) = 2 THEN  -- IMG1
          -- Allows module to increment on this CT (where it will be 0, then it
          -- will be paused for 1 CT)
          addr_select_img0 <= '0';
        ELSE
          addr_select_img0 <= '1';
        END IF;

        CASE mem_addr_wire(1 DOWNTO 0) IS
            WHEN "00" =>
              MEM_BW_B       <= "1110";
            WHEN "01" =>
              MEM_BW_B       <= "1101";
            WHEN "10" =>
              MEM_BW_B       <= "1011";
            WHEN "11" =>
              MEM_BW_B       <= "0111";
            WHEN OTHERS => NULL;
          END CASE;
        
        MEM_ADDR <= (NOT addr_select_img0) & mem_addr_wire(MEMADDR_BITS-2 DOWNTO 0);
        output_valid_reg <= output_valid_wire;
        -- Output the state of the pattern so that the resulting pixel values
        -- returned from memory can be put in the proper buffer position later
        -- on.
        pattern_state_reg <= PIXEL_STATE&addr_select_img0;
      END IF;
    END IF;
  END PROCESS;
PROCESS (MEM_ADDR0, MEM_ADDR1, MEM_ADDROFF, addr_select_img0) IS
BEGIN  -- PROCESS
-- Select which mem address to use, and add the proper offset to it
        IF addr_select_img0 = '1' THEN
          mem_addr_wire         <= MEM_ADDR0 + MEM_ADDROFF;  -- IMG0
          output_valid_wire <= INPUT_VALID0;
        ELSE
          mem_addr_wire         <= MEM_ADDR1 + MEM_ADDROFF;  -- IMG1
          output_valid_wire <= INPUT_VALID1;
        END IF;
END PROCESS;
  
END Behavioral;
