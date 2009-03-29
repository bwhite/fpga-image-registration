library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity compose_h_matrix is
  generic (
    STAGES : integer := 6);
  port (CLK : in std_logic;
        RST : in std_logic;

        DONE_IN  : in std_logic;
        VALID_IN : in std_logic;

        -- 1:10:19
        H_0_0_I   : in  std_logic_vector(29 downto 0);
        H_0_1_I   : in  std_logic_vector(29 downto 0);
        H_0_2_I   : in  std_logic_vector(29 downto 0);
        H_1_0_I   : in  std_logic_vector(29 downto 0);
        H_1_1_I   : in  std_logic_vector(29 downto 0);
        H_1_2_I   : in  std_logic_vector(29 downto 0);
        -- 1:10:19 Format
        P_0_0     : in  std_logic_vector(29 downto 0);
        P_0_1     : in  std_logic_vector(29 downto 0);
        P_1_0     : in  std_logic_vector(29 downto 0);
        P_1_1     : in  std_logic_vector(29 downto 0);
        -- 1:10:19 Format 
        P_0_2     : in  std_logic_vector(29 downto 0);
        P_1_2     : in  std_logic_vector(29 downto 0);
        -- 1:10:19 Format 
        H_0_0     : out std_logic_vector(29 downto 0);
        H_0_1     : out std_logic_vector(29 downto 0);
        H_0_2     : out std_logic_vector(29 downto 0);
        H_1_0     : out std_logic_vector(29 downto 0);
        H_1_1     : out std_logic_vector(29 downto 0);
        H_1_2     : out std_logic_vector(29 downto 0);
        VALID_OUT : out std_logic;
        DONE_OUT  : out std_logic);
end compose_h_matrix;
architecture Behavioral of compose_h_matrix is
  component pipeline_buffer is
    generic (
      WIDTH         : integer := 1;
      STAGES        : integer := 1;
      DEFAULT_VALUE : integer := 2#0#);
    port (CLK   : in  std_logic;
          RST   : in  std_logic;
          CLKEN : in  std_logic;
          DIN   : in  std_logic_vector(WIDTH-1 downto 0);
          DOUT  : out std_logic_vector(WIDTH-1 downto 0));
  end component;
  
  component pipeline_bit_buffer is
    generic (
      STAGES : integer := 1);
    port (CLK   : in  std_logic;
          RST   : in  std_logic;
          SET   : in  std_logic;
          CLKEN : in  std_logic;
          DIN   : in  std_logic;
          DOUT  : out std_logic);
  end component;

  signal h0_t_p0_buf, h0_t_p1_buf, h0_t_p2_buf, h1_t_p3_buf, h1_t_p4_buf, h1_t_p5_buf, h3_t_p0_buf, h3_t_p1_buf, h3_t_p2_buf, h4_t_p3_buf, h4_t_p4_buf, h4_t_p5_buf : std_logic_vector(59 downto 0);

  signal h0_t_p0_wire, h0_t_p1_wire, h0_t_p2_wire, h1_t_p3_wire, h1_t_p4_wire, h1_t_p5_wire, h3_t_p0_wire, h3_t_p1_wire, h3_t_p2_wire, h4_t_p3_wire, h4_t_p4_wire, h4_t_p5_wire : std_logic_vector(59 downto 0);

  signal h0_t_p0, h0_t_p1, h0_t_p2, h1_t_p3, h1_t_p4, h1_t_p5, h3_t_p0, h3_t_p1, h3_t_p2, h4_t_p3, h4_t_p4, h4_t_p5 : signed(29 downto 0);

  signal h2_buf, h5_buf : std_logic_vector(29 downto 0);
  signal h2, h5         : signed(29 downto 0);
begin
  -- Multiply Stage
  -- 1:21:38
  h0_t_p0_wire <= std_logic_vector(signed(H_0_0_I)*signed(P_0_0));
  h0_t_p1_wire <= std_logic_vector(signed(H_0_0_I)*signed(P_0_1));
  h0_t_p2_wire <= std_logic_vector(signed(H_0_0_I)*signed(P_0_2));

  h1_t_p3_wire <= std_logic_vector(signed(H_0_1_I)*signed(P_1_0));
  h1_t_p4_wire <= std_logic_vector(signed(H_0_1_I)*signed(P_1_1));
  h1_t_p5_wire <= std_logic_vector(signed(H_0_1_I)*signed(P_1_2));

  h3_t_p0_wire <= std_logic_vector(signed(H_1_0_I)*signed(P_0_0));
  h3_t_p1_wire <= std_logic_vector(signed(H_1_0_I)*signed(P_0_1));
  h3_t_p2_wire <= std_logic_vector(signed(H_1_0_I)*signed(P_0_2));

  h4_t_p3_wire <= std_logic_vector(signed(H_1_1_I)*signed(P_1_0));
  h4_t_p4_wire <= std_logic_vector(signed(H_1_1_I)*signed(P_1_1));
  h4_t_p5_wire <= std_logic_vector(signed(H_1_1_I)*signed(P_1_2));


  valid_buffer : pipeline_bit_buffer
    generic map (
      STAGES => STAGES+1)
    port map (
      CLK   => CLK,
      RST   => RST,
      SET   => '0',
      CLKEN => '1',
      DIN   => VALID_IN,
      DOUT  => VALID_OUT);


  done_buffer : pipeline_bit_buffer
    generic map (
      STAGES => STAGES+1)
    port map (
      CLK   => CLK,
      RST   => RST,
      SET   => '0',
      CLKEN => '1',
      DIN   => DONE_IN,
      DOUT  => DONE_OUT);

  
  -- H0's 0,1,2
  -- 1:10:19
  h0_t_p2_buffer : pipeline_buffer
    generic map (
      WIDTH  => 60,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => h0_t_p2_wire,
      DOUT  => h0_t_p2_buf);

  h0_t_p1_buffer : pipeline_buffer
    generic map (
      WIDTH  => 60,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => h0_t_p1_wire,
      DOUT  => h0_t_p1_buf);

  h0_t_p0_buffer : pipeline_buffer
    generic map (
      WIDTH  => 60,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => h0_t_p0_wire,
      DOUT  => h0_t_p0_buf);

  -- H1's 3,4,5
  h1_t_p5_buffer : pipeline_buffer
    generic map (
      WIDTH  => 60,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => h1_t_p5_wire,
      DOUT  => h1_t_p5_buf);

  h1_t_p4_buffer : pipeline_buffer
    generic map (
      WIDTH  => 60,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => h1_t_p4_wire,
      DOUT  => h1_t_p4_buf);

  h1_t_p3_buffer : pipeline_buffer
    generic map (
      WIDTH  => 60,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => h1_t_p3_wire,
      DOUT  => h1_t_p3_buf);

  -- H3's 0,1,2
  h3_t_p2_buffer : pipeline_buffer
    generic map (
      WIDTH  => 60,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => h3_t_p2_wire,
      DOUT  => h3_t_p2_buf);

  h3_t_p1_buffer : pipeline_buffer
    generic map (
      WIDTH  => 60,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => h3_t_p1_wire,
      DOUT  => h3_t_p1_buf);

  h3_t_p0_buffer : pipeline_buffer
    generic map (
      WIDTH  => 60,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => h3_t_p0_wire,
      DOUT  => h3_t_p0_buf);

  -- H4's 3,4,5
  h4_t_p5_buffer : pipeline_buffer
    generic map (
      WIDTH  => 60,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => h4_t_p5_wire,
      DOUT  => h4_t_p5_buf);

  h4_t_p4_buffer : pipeline_buffer
    generic map (
      WIDTH  => 60,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => h4_t_p4_wire,
      DOUT  => h4_t_p4_buf);

  h4_t_p3_buffer : pipeline_buffer
    generic map (
      WIDTH  => 60,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => h4_t_p3_wire,
      DOUT  => h4_t_p3_buf);

  h2_buffer : pipeline_buffer
    generic map (
      WIDTH  => 30,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => H_0_2_I,
      DOUT  => h2_buf);

  h5_buffer : pipeline_buffer
    generic map (
      WIDTH  => 30,
      STAGES => STAGES)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => H_1_2_I,
      DOUT  => h5_buf);

  h2 <= signed(h2_buf);
  h5 <= signed(h5_buf);

  h0_t_p0 <= signed(h0_t_p0_buf(48 downto 19));
  h0_t_p1 <= signed(h0_t_p1_buf(48 downto 19));
  h0_t_p2 <= signed(h0_t_p2_buf(48 downto 19));

  h1_t_p3 <= signed(h1_t_p3_buf(48 downto 19));
  h1_t_p4 <= signed(h1_t_p4_buf(48 downto 19));
  h1_t_p5 <= signed(h1_t_p5_buf(48 downto 19));

  h3_t_p0 <= signed(h3_t_p0_buf(48 downto 19));
  h3_t_p1 <= signed(h3_t_p1_buf(48 downto 19));
  h3_t_p2 <= signed(h3_t_p2_buf(48 downto 19));

  h4_t_p3 <= signed(h4_t_p3_buf(48 downto 19));
  h4_t_p4 <= signed(h4_t_p4_buf(48 downto 19));
  h4_t_p5 <= signed(h4_t_p5_buf(48 downto 19));

  process (CLK)
  begin  -- process
    if CLK'event and CLK = '1' then     -- rising clock edge
      if RST = '1' then                 -- synchronous reset (active high)
        H_0_0 <= (others => '0');
        H_0_1 <= (others => '0');
        H_0_2 <= (others => '0');

        H_1_0 <= (others => '0');
        H_1_1 <= (others => '0');
        H_1_2 <= (others => '0');
      else

        -- Assemble Stage
        -- 1:10:19 Format
        H_0_0 <= std_logic_vector(h0_t_p0+h1_t_p3);
        H_0_1 <= std_logic_vector(h0_t_p1+h1_t_p4);
        H_0_2 <= std_logic_vector(h0_t_p2+h1_t_p5+h2);

        H_1_0 <= std_logic_vector(h3_t_p0+h4_t_p3);
        H_1_1 <= std_logic_vector(h3_t_p1+h4_t_p4);
        H_1_2 <= std_logic_vector(h3_t_p2+h4_t_p5+h5);
      end if;
    end if;
  end process;

-- H*P
-- [    h0*p0+h1*p3,    h0*p1+h1*p4, h0*p2+h1*p5+h2]
-- [    h3*p0+h4*p3,    h3*p1+h4*p4, h3*p2+h4*p5+h5]
-- [              0,              0,              1]
  
end Behavioral;

