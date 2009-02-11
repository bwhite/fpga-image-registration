library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


entity compose_h_matrix is
  generic (
    WHOLE_BITS : integer := 8;
    FRAC_BITS  : integer := 19
    );
  port (CLK : in std_logic;
        RST : in std_logic;

        DONE_IN : in std_logic;
        VALID_IN: in std_logic;
        H_0_0_I : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_0_1_I : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_0_2_I : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_0_I : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_1_I : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_2_I : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

        P_0_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        P_0_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        P_0_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        P_1_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        P_1_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        P_1_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        

        H_0_0 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_0_1 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_0_2 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_0 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_1 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        H_1_2 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0));
end compose_h_matrix;

architecture Behavioral of compose_h_matrix is

begin
-- H*P
-- [    h0*p0+h1*p3,    h0*p1+h1*p4, h0*p2+h1*p5+h2]
-- [    h3*p0+h4*p3,    h3*p1+h4*p4, h3*p2+h4*p5+h5]
-- [              0,              0,              1]
h0_t_p0;
h0_t_p1;
h0_t_p2;
h1_t_p3;
h1_t_p4;
h1_t_p5;
h3_t_p0;
h3_t_p1;
h3_t_p2;
h4_t_p3;
h4_t_p4;
h4_t_p5;

  
end Behavioral;





