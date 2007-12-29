----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:04:04 12/27/2007 
-- Design Name: 
-- Module Name:    convolution_1x5_gaussian - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity convolution_1x5_gaussian is
  GENERIC (
    K_0 : unsigned (11 DOWNTO 0) := X"038";  -- Kernel constants, only 9 downto
                                             -- 0 is valid
    K_1 : unsigned (11 DOWNTO 0) := X"0FA";
    K_2 : unsigned (11 DOWNTO 0) := X"19C");
  Port ( CLK : in  STD_LOGIC;
         CLKEN : in STD_LOGIC;
         RST : in  STD_LOGIC;
         DATA_IN : in  unsigned (11 downto 0);
         DATA_OUT : out  unsigned (11 downto 0);
         DATA_VALID : out  STD_LOGIC);
end convolution_1x5_gaussian;

architecture Behavioral of convolution_1x5_gaussian is

  signal data_buf0, data_buf1, data_buf2, data_buf3 : unsigned (11 downto 0);  
                                        -- Convolution buffers, newest stored data in data_buf0
  signal buffer_count : unsigned (3 DOWNTO 0) := (others => '0');  
                                        -- Keeps track of valid elements in buffer
  signal data_valid_reg : std_logic := '0';  -- Register for data_valid signal
  SIGNAL prod_0_p0,prod_1_p0,prod_2_p0,prod_3_p0,prod_4_p0 : unsigned (27 DOWNTO 0);  -- Holds data to be output
  SIGNAL prod_0, prod_0_p1, prod_1, prod_1_p1, prod_2, prod_2_p1, prod_3, prod_3_p1, prod_4, prod_4_p1 : unsigned (12 DOWNTO 0);  -- Holds data to be output
  SIGNAL data_OUT_reg : unsigned (12 DOWNTO 0);  -- Holds output data
begin
  DATA_VALID <= data_valid_reg;
  DATA_OUT <= data_out_reg(12 downto 1);
  
  data_valid_set: PROCESS (BUFFER_count) IS
  BEGIN  -- PROCESS data_valid
  if buffer_count >= "1000" then
    DATA_VALID_REG <= '1';
  else
    DATA_VALID_REG <= '0';
  END if;
  END PROCESS data_valid_set;
  
  -- purpose: This takes in a 1-D 0:8:4 stream and convolves with with a gaussian kernel, outputting only valid data.
  -- type   : sequential
  -- inputs : CLK, RST, DATA_IN
  -- outputs: DATA_OUT, DATA_VALID
  conv: process (CLK)
  begin  -- process conv
    if CLK'event and CLK = '1' then     -- rising clock edge
      if RST = '1' then                 -- synchronous reset (active high)
        buffer_count <= (others => '0');
      elsif (CLKEN='1') then
        -- Shift register
        data_buf0 <= DATA_IN;
        data_buf1 <= data_buf0;
        data_buf2 <= data_buf1;
        data_buf3 <= data_buf2;

        -- Valid data counter
        if data_valid_reg='0' then
          buffer_count <= buffer_count + 1;
        end if;

        -- Compute multiplication, use 3 pipeline levels to allow fast DSP48E inference
        -- Multiplication is 0:8:10 * 0:8:10 with a 0:16:20 result.  Result
        -- converted to 0:8:5 to allow for rounding
        prod_0_p0 <= ((DATA_IN & (5 DOWNTO 0 => '0')) * K_0(9 DOWNTO 0));
        prod_0_p1 <= prod_0_p0(27 DOWNTO 15);
        prod_0 <= prod_0_p1;

        prod_1_p0 <= ((data_buf0 & (5 DOWNTO 0 => '0')) * K_1(9 DOWNTO 0));
        prod_1_p1 <= prod_1_p0(27 DOWNTO 15);
        prod_1 <= prod_1_p1;
        
        prod_2_p0 <= ((data_buf1 & (5 DOWNTO 0 => '0')) * K_2(9 DOWNTO 0));
        prod_2_p1 <= prod_2_p0(27 DOWNTO 15);
        prod_2 <= prod_2_p1;
        
        prod_3_p0 <= ((data_buf2 & (5 DOWNTO 0 => '0')) * K_1(9 DOWNTO 0));
        prod_3_p1 <= prod_3_p0(27 DOWNTO 15);
        prod_3 <= prod_3_p1;
        
        prod_4_p0 <= ((data_buf3 & (5 DOWNTO 0 => '0')) * K_0(9 DOWNTO 0));
        prod_4_p1 <= prod_4_p0(27 DOWNTO 15);
        prod_4 <= prod_4_p1;

        -- Sum products, each term is a 0:8:4
        data_out_reg <= prod_0 + prod_1 + prod_2 + prod_3 + prod_4 + 1;
      end if;
    end if;
  end process conv;
  
end Behavioral;

