----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:01:02 12/27/2007 
-- Design Name: 
-- Module Name:    convolution_1d_linear_5x1 - Behavioral 
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
USE ieee.numeric_std.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity convolution_1d_linear_5x1 is
    Port ( CLK : in  STD_LOGIC;
           CLKEN : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           DATA_IN : in  unsigned (11 downto 0);
           DATA_OUT : out  unsigned (11 downto 0);
           DATA_VALID : out  STD_LOGIC);
end convolution_1d_linear_5x1;

architecture Behavioral of convolution_1d_linear_5x1 is

component convolution_1x5_gaussian
  Port ( CLK : in  STD_LOGIC;
         CLKEN : in STD_LOGIC;
         RST : in  STD_LOGIC;
         DATA_IN0 : in  unsigned (11 downto 0);
         DATA_IN1 : in  unsigned (11 downto 0);
         DATA_IN2 : in  unsigned (11 downto 0);
         DATA_IN3 : in  unsigned (11 downto 0);
         DATA_IN4 : in  unsigned (11 downto 0);
         DATA_OUT : out  unsigned (11 downto 0);
         DATA_VALID : out  STD_LOGIC);
end component;

  signal data_buf0, data_buf1, data_buf2, data_buf3 : unsigned (11 downto 0);  
                                        -- Shift registers to buffer valid convolution window
  signal buffer_count : unsigned (2 downto 0) := (others => '0');  
                                        -- Keeps track of valid elements in buffer
  SIGNAL conv_clken : std_logic;
  SIGNAL conv_data_valid : std_logic;
  SIGNAL data_valid_wire : std_logic;

begin
  DATA_VALID <= conv_data_valid AND data_valid_wire;
  conv_clken <= data_valid_wire AND CLKEN;
  
  -- purpose: Drives data_valid_wire signal when buffers are filled
  -- type   : combinational
  -- inputs : buffer_count
  -- outputs: data_valid_wire
  PROCESS (buffer_count) IS
  BEGIN  -- PROCESS
    IF buffer_count >= "100" THEN
      data_valid_wire <= '1';
    else
      data_valid_wire <= '0';
    END IF;
  END PROCESS;
                
  convolution_1x5_gaussian_i : convolution_1x5_gaussian port map (
    CLK      => CLK,
    CLKEN    => conv_clken,
    RST      => RST,
    DATA_IN0 => DATA_IN,
    DATA_IN1 => data_buf0,
    DATA_IN2 => data_buf1,
    DATA_IN3 => data_buf2,
    DATA_IN4 => data_buf3,
    DATA_OUT => DATA_OUT,
    DATA_VALID => conv_data_valid);

-- purpose: Maintains the convolution buffers and valid data counter
-- type   : sequential
-- inputs : CLK, RST, DATA_IN, CLKEN
-- outputs: DATA_OUT, DATA_VALID
PROCESS (CLK) IS
BEGIN  -- PROCESS
  IF CLK'event AND CLK = '1' THEN       -- rising clock edge
    IF RST = '1' THEN                   -- synchronous reset (active high)
      buffer_count <= (OTHERS => '0');
    ELSIF CLKEN='1' THEN
      IF data_valid_wire='0' THEN
        buffer_count <= buffer_count + 1;
      END IF;
      data_buf0 <= DATA_IN;
      data_buf1 <= data_buf0;
      data_buf2 <= data_buf1;
      data_buf3 <= data_buf2;
    END IF;
  END IF;
END PROCESS;
  
end Behavioral;

