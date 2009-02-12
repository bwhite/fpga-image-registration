LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY registration_controller IS
  GENERIC (
      IMGSIZE_BITS : integer := 10;
      PIXEL_BITS   : integer := 9);
  PORT (CLK               : IN  std_logic;
         RST              : IN  std_logic;
         -- Memory Connections
         MEM_VALUE        : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
         MEM_INPUT_VALID  : IN  std_logic;
         MEM_ADDR         : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
         MEM_BW_B         : OUT std_logic_vector(3 DOWNTO 0);
         MEM_OUTPUT_VALID : OUT std_logic;

         H_0_0_O : OUT std_logic_vector(29 DOWNTO 0);
         H_0_1_O : OUT std_logic_vector(29 DOWNTO 0);
         H_0_2_O : OUT std_logic_vector(29 DOWNTO 0);
         H_1_0_O : OUT std_logic_vector(29 DOWNTO 0);
         H_1_1_O : OUT std_logic_vector(29 DOWNTO 0);
         H_1_2_O : OUT std_logic_vector(29 DOWNTO 0);
         OUTPUT_VALID : OUT std_logic
         );
END registration_controller;

ARCHITECTURE Behavioral OF registration_controller IS
  COMPONENT registration_stage IS
    GENERIC (
      CONV_HEIGHT  : integer := 3;
      IMGSIZE_BITS : integer := 10;
      PIXEL_BITS   : integer := 9;

      WHOLE_BITS       : integer := 8;
      FRAC_BITS        : integer := 19;
      CONV_HEIGHT_BITS : integer := 2);
    PORT (CLK              : IN  std_logic;
          RST              : IN  std_logic;
          LEVEL            : IN  std_logic_vector(2 DOWNTO 0);
          COORD_SHIFT      : IN  std_logic_vector(3 DOWNTO 0);
          -- 1:IMGSIZE_BITS:1 Format
          COORD_TRANS      : IN  std_logic_vector(IMGSIZE_BITS+1 DOWNTO 0);
          -- Rotation and Non-Isotropic Scale
          -- 1:6:11 Format
          H_0_0            : IN  std_logic_vector(17 DOWNTO 0);
          H_0_1            : IN  std_logic_vector(17 DOWNTO 0);
          H_1_0            : IN  std_logic_vector(17 DOWNTO 0);
          H_1_1            : IN  std_logic_vector(17 DOWNTO 0);
          -- Translation
          -- 1:10:11 Format 
          H_0_2            : IN  std_logic_vector(21 DOWNTO 0);
          H_1_2            : IN  std_logic_vector(21 DOWNTO 0);
          -- Memory Connections
          MEM_VALUE        : IN  std_logic_vector(PIXEL_BITS-1 DOWNTO 0);
          MEM_INPUT_VALID  : IN  std_logic;
          MEM_ADDR         : OUT std_logic_vector(2*IMGSIZE_BITS-1 DOWNTO 0);
          MEM_BW_B         : OUT std_logic_vector(3 DOWNTO 0);
          MEM_OUTPUT_VALID : OUT std_logic;

          -- 1:10:9 Format
          H_0_0_O      : OUT std_logic_vector(29 DOWNTO 0);
          H_0_1_O      : OUT std_logic_vector(29 DOWNTO 0);
          H_0_2_O      : OUT std_logic_vector(29 DOWNTO 0);
          H_1_0_O      : OUT std_logic_vector(29 DOWNTO 0);
          H_1_1_O      : OUT std_logic_vector(29 DOWNTO 0);
          H_1_2_O      : OUT std_logic_vector(29 DOWNTO 0);
          OUTPUT_VALID : OUT std_logic
          );
  END COMPONENT;
  
BEGIN

  registration_stage_i : registration_stage
    PORT MAP(
      CLK              => CLK,
      RST              => RST,
      LEVEL            => "111",
      COORD_SHIFT      => "1001",
      COORD_TRANS      => "001010000000",
      -- Make all H values the identity
      H_0_0            => "000000100000000000",
      H_0_1            => "000000000000000000",
      H_1_0            => "000000000000000000",
      H_1_1            => "000000100000000000",
      H_0_2            => "0000000000000000000000",
      H_1_2            => "0000000000000000000000",
      -- Memory Inputs
      MEM_VALUE        => MEM_VALUE,
      MEM_INPUT_VALID  => MEM_INPUT_VALID,
      MEM_ADDR         => MEM_ADDR,
      MEM_BW_B         => MEM_BW_B,
      MEM_OUTPUT_VALID => MEM_OUTPUT_VALID ,
      -- Output homographies
      H_0_0_O          => H_0_0_O,
      H_0_1_O          => H_0_1_O,
      H_1_0_O          => H_1_0_O,
      H_1_1_O          => H_1_1_O,
      H_0_2_O          => H_0_2_O,
      H_1_2_O          => H_1_2_O,
      OUTPUT_VALID     => OUTPUT_VALID
      );
END Behavioral;

