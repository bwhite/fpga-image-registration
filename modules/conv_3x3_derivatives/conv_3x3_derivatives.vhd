-- Module Name: conv_3x3_derivatives
-- File Description:  Takes in a 3x3 neighborhood from the previous image (
-- IMG0), and the corresponding middle pixel from the current image (IMG1).
-- The output is the Ix,Iy spatial derivatives of IMG0 for this pixel value,
-- and the temporal derivative It.
-- Project:  FPGA Image Registration
-- Target Device:  XC5VSX50T (Xilinx Virtex5 SXT)
-- Target Board:  ML506
-- Synthesis Tool:  Xilinx ISE 9.2
-- Copyright (C) 2008 Brandyn Allen White
-- Contact:  bwhite(at)cs.ucf.edu
-- Project Website:  http://code.google.com/p/fpga-image-registration/

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY conv_3x3_derivatives IS
  GENERIC (
    GAUSS_3x1_0          :     signed(24 DOWNTO 0) := (X"046295C");
    GAUSS_3x1_1          :     signed(24 DOWNTO 0) := (X"073AD47"))
    PORT ( CLK         : IN  std_logic;
           RST         : IN  std_logic;
           INPUT_VALID : IN  std_logic;
           IMG0_0_0    : IN  std_logic_vector (17 DOWNTO 0);
           IMG0_0_1    : IN  std_logic_vector (17 DOWNTO 0);
           IMG0_0_2    : IN  std_logic_vector (17 DOWNTO 0);
           IMG0_1_0    : IN  std_logic_vector (17 DOWNTO 0);
           IMG0_1_1    : IN  std_logic_vector (17 DOWNTO 0);
           IMG0_1_2    : IN  std_logic_vector (17 DOWNTO 0);
           IMG0_2_0    : IN  std_logic_vector (17 DOWNTO 0);
           IMG0_2_1    : IN  std_logic_vector (17 DOWNTO 0);
           IMG0_2_2    : IN  std_logic_vector (17 DOWNTO 0);
           IMG1_1_1    : IN  std_logic_vector (17 DOWNTO 0);
           IX          : OUT std_logic_vector (17 DOWNTO 0);
           IY          : OUT std_logic_vector (17 DOWNTO 0);
           IT          : OUT std_logic_vector (17 DOWNTO 0);
           DATA_VALID  : OUT std_logic
           );
END conv_3x3_derivatives;

ARCHITECTURE Behavioral OF conv_3x3_derivatives IS
  SIGNAL img0_0_0_reg, img0_0_1_reg, img0_0_2_reg, img0_1_0_reg, img0_1_1_reg, img0_1_2_reg, img0_2_0_reg, img0_2_1_reg, img0_2_2_reg, img1_1_1_reg : signed(17 DOWNTO 0) := (OTHERS => '0');

BEGIN
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge
      IF RST = '1' THEN                 -- synchronous reset (active high)

      ELSE
        -- Register input data
        img0_0_0_reg <= signed(IMG0_0_0);
        img0_0_1_reg <= signed(IMG0_0_1);
        img0_0_2_reg <= signed(IMG0_0_2);
        img0_1_0_reg <= signed(IMG0_1_0);
        img0_1_1_reg <= signed(IMG0_1_1);
        img0_1_2_reg <= signed(IMG0_1_2);
        img0_2_0_reg <= signed(IMG0_2_0);
        img0_2_1_reg <= signed(IMG0_2_1);
        img0_2_2_reg <= signed(IMG0_2_2);
        img1_1_1_reg <= signed(IMG1_1_1);

        -- Multiply by gaussian coefficients (both in the X and the Y direction)
        -- This is 9 multiplies each
        -- XSmooth
        img0_0_0_xs0 <= img0_0_0_reg*GAUSS_3x1_0;
        img0_0_2_xs0 <= img0_0_2_reg*GAUSS_3x1_0;
        img0_1_0_xs0 <= img0_1_0_reg*GAUSS_3x1_0;
        img0_1_2_xs0 <= img0_1_2_reg*GAUSS_3x1_0;
        img0_2_0_xs0 <= img0_2_0_reg*GAUSS_3x1_0;
        img0_2_2_xs0 <= img0_2_2_reg*GAUSS_3x1_0;
        img0_0_1_xs0 <= img0_0_1_reg*GAUSS_3x1_1;
        img0_1_1_xs0 <= img0_1_1_reg*GAUSS_3x1_1;
        img0_2_1_xs0 <= img0_2_1_reg*GAUSS_3x1_1;
        -- Pipeline the result
        img0_0_0_xs1 <= img0_0_0_xs0;
        img0_0_2_xs1 <= img0_0_2_xs0;
        img0_1_0_xs1 <= img0_1_0_xs0;
        img0_1_2_xs1 <= img0_1_2_xs0;
        img0_2_0_xs1 <= img0_2_0_xs0;
        img0_2_2_xs1 <= img0_2_2_xs0;
        img0_0_1_xs1 <= img0_0_1_xs0;
        img0_1_1_xs1 <= img0_1_1_xs0;
        img0_2_1_xs1 <= img0_2_1_xs0;
        
        -- YSmooth
        img0_0_0_ys0 <= img0_0_0_reg*GAUSS_3x1_0;
        img0_2_0_ys0 <= img0_2_0_reg*GAUSS_3x1_0;
        img0_0_1_ys0 <= img0_0_1_reg*GAUSS_3x1_0;
        img0_2_1_ys0 <= img0_2_1_reg*GAUSS_3x1_0;
        img0_0_2_ys0 <= img0_0_2_reg*GAUSS_3x1_0;
        img0_2_2_ys0 <= img0_2_2_reg*GAUSS_3x1_0;
        img0_1_0_ys0 <= img0_1_0_reg*GAUSS_3x1_1;
        img0_1_1_ys0 <= img0_1_1_reg*GAUSS_3x1_1;
        img0_1_2_ys0 <= img0_1_2_reg*GAUSS_3x1_1;
        -- Pipeline the result
        img0_0_0_ys1 <= img0_0_0_ys0;
        img0_2_0_ys1 <= img0_2_0_ys0;
        img0_0_1_ys1 <= img0_0_1_ys0;
        img0_2_1_ys1 <= img0_2_1_ys0;
        img0_0_2_ys1 <= img0_0_2_ys0;
        img0_2_2_ys1 <= img0_2_2_ys0;
        img0_1_0_ys1 <= img0_1_0_ys0;
        img0_1_1_ys1 <= img0_1_1_ys0;
        img0_1_2_ys1 <= img0_1_2_ys0;
        
        -- Sum each set of 3 of the above multiples to produce 2 3 vectors, one
        -- smoothed in the x direction, the other smoothed in the y direction
        -- This is 6 sums each
        -- XSmooth Sum (Sum along the X direction A(:,0)+A(:,1)+A(:,2))
        img0_0_psumx <= img0_0_0_xs1 + img0_0_1_xs1;
        img0_1_psumx <= img0_1_0_xs1 + img0_1_1_xs1;
        img0_2_psumx <= img0_2_0_xs1 + img0_2_1_xs1;
        img0_0_sumx <= img0_0_psumx + img0_0_2_xs1;
        img0_1_sumx <= img0_1_psumx + img0_1_2_xs1;
        img0_2_sumx <= img0_2_psumx + img0_2_2_xs1;


        -- YSmooth Sum (Sum along the Y direction A(0,:)+A(1,:)+A(2,:))
        img0_0_psumy <= img0_0_0_ys1 + img0_1_0_ys1;
        img0_1_psumy <= img0_0_1_ys1 + img0_1_1_ys1;
        img0_2_psumy <= img0_0_2_ys1 + img0_1_2_ys1;
        img0_0_sumy <= img0_0_psumy + img0_2_0_ys1;
        img0_1_sumy <= img0_1_psumy + img0_2_1_ys1;
        img0_2_sumy <= img0_2_psumy + img0_2_2_ys1;

        -- Convolve both vectors with a (-1 0 1) kernel (3 multiplies each)


        -- Sum the results, 2 sums each

        -- Compute temporal derivative
      END IF;
    END IF;
  END PROCESS;

end Behavioral;

