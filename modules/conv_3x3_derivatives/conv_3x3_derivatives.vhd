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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY conv_3x3_derivatives IS
  GENERIC (
    GAUSS_3x1_0      :     unsigned(23 DOWNTO 0) := (X"46295C");
    GAUSS_3x1_1      :     unsigned(23 DOWNTO 0) := (X"73AD47"));
  PORT ( CLK         : IN  std_logic;
         RST         : IN  std_logic;
         INPUT_VALID : IN  std_logic;
         IMG0_0_0    : IN  std_logic_vector (8 DOWNTO 0);   -- IMG Range <0,1)
         IMG0_0_1    : IN  std_logic_vector (8 DOWNTO 0);   -- 0:0:9
         IMG0_0_2    : IN  std_logic_vector (8 DOWNTO 0);
         IMG0_1_0    : IN  std_logic_vector (8 DOWNTO 0);
         IMG0_1_1    : IN  std_logic_vector (8 DOWNTO 0);
         IMG0_1_2    : IN  std_logic_vector (8 DOWNTO 0);
         IMG0_2_0    : IN  std_logic_vector (8 DOWNTO 0);
         IMG0_2_1    : IN  std_logic_vector (8 DOWNTO 0);
         IMG0_2_2    : IN  std_logic_vector (8 DOWNTO 0);
         IMG1_1_1    : IN  std_logic_vector (8 DOWNTO 0);
         IX          : OUT std_logic_vector (33 DOWNTO 0);  -- 1:0:33
         IY          : OUT std_logic_vector (33 DOWNTO 0);
         IT          : OUT std_logic_vector (9 DOWNTO 0);   -- 1:0:9
         DATA_VALID  : OUT std_logic
         );
END conv_3x3_derivatives;

ARCHITECTURE Behavioral OF conv_3x3_derivatives IS
  TYPE unsigned9_3x3mat IS ARRAY (2 DOWNTO 0, 2 DOWNTO 0) OF unsigned(8 DOWNTO 0);
  TYPE unsigned33_3x2mat IS ARRAY (2 DOWNTO 0, 1 DOWNTO 0) OF unsigned(32 DOWNTO 0);
  TYPE unsigned33_2x3mat IS ARRAY (1 DOWNTO 0, 2 DOWNTO 0) OF unsigned(32 DOWNTO 0);
  TYPE unsigned9_2x1vec IS ARRAY (1 DOWNTO 0) OF unsigned(8 DOWNTO 0);
  TYPE unsigned33_2x1vec IS ARRAY (1 DOWNTO 0) OF unsigned(32 DOWNTO 0);
  TYPE signed10_6x1 IS ARRAY (5 DOWNTO 0) OF signed(9 DOWNTO 0);

  SIGNAL img0_reg                     : unsigned9_3x3mat  := (((OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0')), ((OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0')), ((OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0')));
  SIGNAL img0_xs0, img0_xs1, img0_xs2 : unsigned33_2x3mat := (((OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0')),
                                                              ((OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0')));

  SIGNAL img0_ys0, img0_ys1, img0_ys2 : unsigned33_3x2mat := (((OTHERS => '0'), (OTHERS => '0')),
                                                              ((OTHERS => '0'), (OTHERS => '0')),
                                                              ((OTHERS => '0'), (OTHERS => '0')));

  SIGNAL img0_psumx, img0_sumx, img0_psumy, img0_sumy : unsigned33_2x1vec            := ((OTHERS => '0'), (OTHERS => '0'));
  SIGNAL img0_xs3, img0_ys3                           : unsigned33_2x1vec            := ((OTHERS => '0'), (OTHERS => '0'));
  SIGNAL ix_reg, iy_reg                               : signed(33 DOWNTO 0)          := (OTHERS  => '0');
  SIGNAL img1_1_1_reg                                 : unsigned(8 DOWNTO 0)         := (OTHERS  => '0');
  SIGNAL it_reg                                       : signed10_6x1;
  SIGNAL input_valid_reg                              : std_logic_vector(6 DOWNTO 0) := (OTHERS  => '0');
BEGIN
    IX         <= std_logic_vector(ix_reg);
    IY         <= std_logic_vector(iy_reg);
    IT         <= std_logic_vector(it_reg(5));
    DATA_VALID <= input_valid_reg(6);
  PROCESS (CLK) IS
  BEGIN  -- PROCESS
    IF CLK'event AND CLK = '1' THEN     -- rising clock edge

      -----------------------------------------------------------------------
      -- Pass the InputValid signal through 7 registers, with the last
      -- connected to DATA_VALID
      input_valid_reg(0)   <= INPUT_VALID;
      FOR i IN 6 DOWNTO 1 LOOP
        input_valid_reg(i) <= input_valid_reg(i-1);
      END LOOP;  -- i

      -----------------------------------------------------------------------
      -- Register input data
      img0_reg(0, 0) <= unsigned(IMG0_0_0);
      img0_reg(0, 1) <= unsigned(IMG0_0_1);
      img0_reg(0, 2) <= unsigned(IMG0_0_2);
      img0_reg(1, 0) <= unsigned(IMG0_1_0);
      img0_reg(1, 1) <= unsigned(IMG0_1_1);
      img0_reg(1, 2) <= unsigned(IMG0_1_2);
      img0_reg(2, 0) <= unsigned(IMG0_2_0);
      img0_reg(2, 1) <= unsigned(IMG0_2_1);
      img0_reg(2, 2) <= unsigned(IMG0_2_2);
      img1_1_1_reg   <= unsigned(IMG1_1_1);
      -----------------------------------------------------------------------
      -- Compute IT, pass through pipeline registers to be output with the
      -- other data.  New middle pixel - old middle pixel = IT
      it_reg(0)      <= signed('0'&img1_1_1_reg) - signed('0'&img0_reg(1, 1));
      FOR i IN 5 DOWNTO 1 LOOP
        it_reg(i)    <= it_reg(i-1);
      END LOOP;  -- i

      -----------------------------------------------------------------------
      -- Multiply by gaussian coefficients (both in the X and the Y direction)
      -- This is 6 multiplies each
      -- XSmooth
      FOR i IN 2 DOWNTO 0 LOOP
        FOR j IN 2 DOWNTO 0 LOOP
          IF i/=1 THEN                  -- Ignore middle row
            IF j = 1 THEN
              img0_xs0(i/2, j) <= img0_reg(i, j)*GAUSS_3x1_1;
            ELSE
              img0_xs0(i/2, j) <= img0_reg(i, j)*GAUSS_3x1_0;
            END IF;
          END IF;
        END LOOP;  -- j
      END LOOP;  -- i

      -- YSmooth
      FOR i IN 2 DOWNTO 0 LOOP
        FOR j IN 2 DOWNTO 0 LOOP
          IF j/=1 THEN                  -- Ignore middle column
            IF i = 1 THEN
              img0_ys0(i, j/2) <= img0_reg(i, j)*GAUSS_3x1_1;
            ELSE
              img0_ys0(i, j/2) <= img0_reg(i, j)*GAUSS_3x1_0;
            END IF;
          END IF;
        END LOOP;  -- j
      END LOOP;  -- i

      -- Add a pipeline for the multipliers
      img0_xs1 <= img0_xs0;
      img0_xs2 <= img0_xs1;
      img0_ys1 <= img0_ys0;
      img0_ys2 <= img0_ys1;

      -----------------------------------------------------------------------
      -- Sum each set of 3 of the above multiples to produce 2 3 vectors, one
      -- XSmooth Sum (Sum along the X direction A(:,0)+A(:,1)+A(:,2))
      FOR i IN 1 DOWNTO 0 LOOP
        img0_psumx(i) <= img0_xs2(i, 0)+img0_xs2(i, 1);
      END LOOP;  -- i

      -- Save for next CT
      FOR i IN 1 DOWNTO 0 LOOP
        img0_xs3(i) <= img0_xs2(i, 2);
      END LOOP;  -- i

      FOR i IN 1 DOWNTO 0 LOOP
        img0_sumx(i) <= img0_psumx(i)+img0_xs3(i);
      END LOOP;  -- i

      -----------------------------------------------------------------------
      -- YSmooth Sum (Sum along the Y direction A(0,:)+A(1,:)+A(2,:))
      FOR i IN 1 DOWNTO 0 LOOP
        img0_psumy(i) <= img0_ys2(0, i)+img0_ys2(1, i);
      END LOOP;  -- i

      -- Save for next CT
      FOR i IN 1 DOWNTO 0 LOOP
        img0_ys3(i) <= img0_ys2(2, i);
      END LOOP;  -- i

      FOR i IN 1 DOWNTO 0 LOOP
        img0_sumy(i) <= img0_psumy(i)+img0_ys3(i);
      END LOOP;  -- i

      -- Subtract sum(2)-sum(0) for the spatial derivatives
      ix_reg <= signed('0'&img0_sumx(1))-signed('0'&img0_sumx(0));
      iy_reg <= signed('0'&img0_sumy(1))-signed('0'&img0_sumy(0));

    END IF;
  END PROCESS;

END Behavioral;

