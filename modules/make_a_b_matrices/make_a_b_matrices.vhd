library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity make_a_b_matrices is
  generic (
    IMGSIZE_BITS : integer := 11;
    PIXEL_BITS   : integer := 9;
    FRAC_BITS    : integer := 26;
    DELAY        : integer := 4);
  port (CLK : in std_logic;

        RST         : in std_logic;
        COORD_SHIFT : in std_logic_vector(3 downto 0);
        -- 1:IMGSIZE_BITS-1:1 Format
        X           : in std_logic_vector(IMGSIZE_BITS downto 0);
        Y           : in std_logic_vector(IMGSIZE_BITS downto 0);
        -- 1:0:PIXEL_BITS Format
        FX          : in std_logic_vector(PIXEL_BITS downto 0);
        FY          : in std_logic_vector(PIXEL_BITS downto 0);
        FT          : in std_logic_vector(PIXEL_BITS downto 0);
        VALID_IN    : in std_logic;

        VALID_OUT : out std_logic;

        A_0_0 : out std_logic_vector(FRAC_BITS downto 0);
        A_0_1 : out std_logic_vector(FRAC_BITS downto 0);
        A_0_2 : out std_logic_vector(FRAC_BITS downto 0);
        A_0_3 : out std_logic_vector(FRAC_BITS downto 0);
        A_0_4 : out std_logic_vector(FRAC_BITS downto 0);
        A_0_5 : out std_logic_vector(FRAC_BITS downto 0);

        A_1_0 : out std_logic_vector(FRAC_BITS downto 0);
        A_1_1 : out std_logic_vector(FRAC_BITS downto 0);
        A_1_2 : out std_logic_vector(FRAC_BITS downto 0);
        A_1_3 : out std_logic_vector(FRAC_BITS downto 0);
        A_1_4 : out std_logic_vector(FRAC_BITS downto 0);
        A_1_5 : out std_logic_vector(FRAC_BITS downto 0);

        A_2_0 : out std_logic_vector(FRAC_BITS downto 0);
        A_2_1 : out std_logic_vector(FRAC_BITS downto 0);
        A_2_2 : out std_logic_vector(FRAC_BITS downto 0);
        A_2_3 : out std_logic_vector(FRAC_BITS downto 0);
        A_2_4 : out std_logic_vector(FRAC_BITS downto 0);
        A_2_5 : out std_logic_vector(FRAC_BITS downto 0);

        A_3_0 : out std_logic_vector(FRAC_BITS downto 0);
        A_3_1 : out std_logic_vector(FRAC_BITS downto 0);
        A_3_2 : out std_logic_vector(FRAC_BITS downto 0);
        A_3_3 : out std_logic_vector(FRAC_BITS downto 0);
        A_3_4 : out std_logic_vector(FRAC_BITS downto 0);
        A_3_5 : out std_logic_vector(FRAC_BITS downto 0);

        A_4_0 : out std_logic_vector(FRAC_BITS downto 0);
        A_4_1 : out std_logic_vector(FRAC_BITS downto 0);
        A_4_2 : out std_logic_vector(FRAC_BITS downto 0);
        A_4_3 : out std_logic_vector(FRAC_BITS downto 0);
        A_4_4 : out std_logic_vector(FRAC_BITS downto 0);
        A_4_5 : out std_logic_vector(FRAC_BITS downto 0);

        A_5_0 : out std_logic_vector(FRAC_BITS downto 0);
        A_5_1 : out std_logic_vector(FRAC_BITS downto 0);
        A_5_2 : out std_logic_vector(FRAC_BITS downto 0);
        A_5_3 : out std_logic_vector(FRAC_BITS downto 0);
        A_5_4 : out std_logic_vector(FRAC_BITS downto 0);
        A_5_5 : out std_logic_vector(FRAC_BITS downto 0);

        B_0 : out std_logic_vector(FRAC_BITS downto 0);
        B_1 : out std_logic_vector(FRAC_BITS downto 0);
        B_2 : out std_logic_vector(FRAC_BITS downto 0);
        B_3 : out std_logic_vector(FRAC_BITS downto 0);
        B_4 : out std_logic_vector(FRAC_BITS downto 0);
        B_5 : out std_logic_vector(FRAC_BITS downto 0)
        );
end make_a_b_matrices;

architecture Behavioral of make_a_b_matrices is
  component signed_norm_mult is
    generic (
      FRAC_BITS : integer := FRAC_BITS;
      DELAY     : integer := DELAY);
    port (CLK      : in  std_logic;
          RST      : in  std_logic;
          VALID_IN : in  std_logic;
          -- 1:0:FRAC_BITS
          A        : in  std_logic_vector (FRAC_BITS downto 0);
          B        : in  std_logic_vector (FRAC_BITS downto 0);
          C        : out std_logic_vector (FRAC_BITS downto 0);

          VALID_OUT : out std_logic);
  end component;

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


  component right_shifter is
    generic (
      SIZE : integer := FRAC_BITS+1);
    port (CLK         : in  std_logic;
          COORD_SHIFT : in  std_logic_vector(3 downto 0);
          DIN         : in  std_logic_vector(SIZE-1 downto 0);
          DOUT        : out std_logic_vector(SIZE-1 downto 0));
  end component;
  signal coord_shift2                                                             : std_logic_vector(3 downto 0);
  signal pass1_valid, pass2_valid, valid_in_reg                                  : std_logic;
  signal x_reg, y_reg, fx_reg, fy_reg, ft_reg, x_reg2, y_reg2, fx2_reg2, fy2_reg2, fxfy_reg2, fxft_reg2, fyft_reg2 : std_logic_vector(FRAC_BITS downto 0);
  signal fx2, fxft, fxfy, fy2, fyft, x2, y2, xy                                   : std_logic_vector(FRAC_BITS downto 0);
  signal fx2_v, fxft_v, fxfy_v, fy2_v, fyft_v, x2_v, y2_v, xy_v                   : std_logic;

  signal fx2_t_x, fx2_t_y, fx2_t_x2, fx2_t_y2, fx2_t_xy, fy2_t_x, fy2_t_y, fy2_t_x2, fy2_t_y2, fy2_t_xy, fxfy_t_x, fxfy_t_y, fxfy_t_x2, fxfy_t_y2, fxfy_t_xy, fxft_t_x, fyft_t_x, fxft_t_y, fyft_t_y                                       : std_logic_vector(FRAC_BITS downto 0);
  signal fx2_t_x_v, fx2_t_y_v, fx2_t_x2_v, fx2_t_y2_v, fx2_t_xy_v, fy2_t_x_v, fy2_t_y_v, fy2_t_x2_v, fy2_t_y2_v, fy2_t_xy_v, fxfy_t_x_v, fxfy_t_y_v, fxfy_t_x2_v, fxfy_t_y2_v, fxfy_t_xy_v, fxft_t_x_v, fyft_t_x_v, fxft_t_y_v, fyft_t_y_v : std_logic;

begin
  process (CLK)
  begin  -- process
    if CLK'event and CLK = '1' then     -- rising clock edge
      -- NOTE: This assumes that the shift will include all data bits in the
      -- new fractional area of x/y_reg, if not then errors will occur.  Ensure
      -- that the correct COORD_SHIFT is used for the correct range of X/Y values!
      case COORD_SHIFT is
        when "0101" =>                  -- 5
          x_reg(FRAC_BITS)                      <= X(IMGSIZE_BITS);
          x_reg(FRAC_BITS-1 downto FRAC_BITS-6) <= X(5 downto 0);
          x_reg(FRAC_BITS-7 downto 0)           <= (others => '0');

          y_reg(FRAC_BITS)                      <= Y(IMGSIZE_BITS);
          y_reg(FRAC_BITS-1 downto FRAC_BITS-6) <= Y(5 downto 0);
          y_reg(FRAC_BITS-7 downto 0)           <= (others => '0');
        when "0110" =>                  -- 6
          x_reg(FRAC_BITS)                      <= X(IMGSIZE_BITS);
          x_reg(FRAC_BITS-1 downto FRAC_BITS-7) <= X(6 downto 0);
          x_reg(FRAC_BITS-8 downto 0)           <= (others => '0');

          y_reg(FRAC_BITS)                      <= Y(IMGSIZE_BITS);
          y_reg(FRAC_BITS-1 downto FRAC_BITS-7) <= Y(6 downto 0);
          y_reg(FRAC_BITS-8 downto 0)           <= (others => '0');
        when "0111" =>                  -- 7
          x_reg(FRAC_BITS)                      <= X(IMGSIZE_BITS);
          x_reg(FRAC_BITS-1 downto FRAC_BITS-8) <= X(7 downto 0);
          x_reg(FRAC_BITS-9 downto 0)           <= (others => '0');

          y_reg(FRAC_BITS)                      <= Y(IMGSIZE_BITS);
          y_reg(FRAC_BITS-1 downto FRAC_BITS-8) <= Y(7 downto 0);
          y_reg(FRAC_BITS-9 downto 0)           <= (others => '0');
        when "1000" =>                  -- 8
          x_reg(FRAC_BITS)                      <= X(IMGSIZE_BITS);
          x_reg(FRAC_BITS-1 downto FRAC_BITS-9) <= X(8 downto 0);
          x_reg(FRAC_BITS-10 downto 0)          <= (others => '0');

          y_reg(FRAC_BITS)                      <= Y(IMGSIZE_BITS);
          y_reg(FRAC_BITS-1 downto FRAC_BITS-9) <= Y(8 downto 0);
          y_reg(FRAC_BITS-10 downto 0)          <= (others => '0');
        when "1001" =>                  -- 9
          x_reg(FRAC_BITS)                       <= X(IMGSIZE_BITS);
          x_reg(FRAC_BITS-1 downto FRAC_BITS-10) <= X(9 downto 0);
          x_reg(FRAC_BITS-11 downto 0)           <= (others => '0');

          y_reg(FRAC_BITS)                       <= Y(IMGSIZE_BITS);
          y_reg(FRAC_BITS-1 downto FRAC_BITS-10) <= Y(9 downto 0);
          y_reg(FRAC_BITS-11 downto 0)           <= (others => '0');
        when others =>                  -- 10
          x_reg(FRAC_BITS)                       <= X(IMGSIZE_BITS);
          x_reg(FRAC_BITS-1 downto FRAC_BITS-11) <= X(10 downto 0);
          x_reg(FRAC_BITS-12 downto 0)           <= (others => '0');

          y_reg(FRAC_BITS)                       <= Y(IMGSIZE_BITS);
          y_reg(FRAC_BITS-1 downto FRAC_BITS-11) <= Y(10 downto 0);
          y_reg(FRAC_BITS-12 downto 0)           <= (others => '0');
      end case;

      valid_in_reg                                  <= VALID_IN;
      fx_reg(FRAC_BITS-PIXEL_BITS-1 downto 0)       <= (others => '0');
      fx_reg(FRAC_BITS downto FRAC_BITS-PIXEL_BITS) <= FX;
      fy_reg(FRAC_BITS-PIXEL_BITS-1 downto 0)       <= (others => '0');
      fy_reg(FRAC_BITS downto FRAC_BITS-PIXEL_BITS) <= FY;
      ft_reg(FRAC_BITS-PIXEL_BITS-1 downto 0)       <= (others => '0');
      ft_reg(FRAC_BITS downto FRAC_BITS-PIXEL_BITS) <= FT;
    end if;
  end process;


-------------------------------------------------------------------------------
-- Pass 1 Multiply
  --fx2=fx*fx
  fx2_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => valid_in_reg,
      A         => fx_reg,
      B         => fx_reg,
      C         => fx2,
      VALID_OUT => fx2_v);

  --fxft=fx*ft
  fxft_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => valid_in_reg,
      A         => fx_reg,
      B         => ft_reg,
      C         => fxft,
      VALID_OUT => fxft_v);

  --fxfy=fx*fy
  fxfy_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => valid_in_reg,
      A         => fx_reg,
      B         => fy_reg,
      C         => fxfy,
      VALID_OUT => fxfy_v);

  --fy2=fy*fy
  fy2_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => valid_in_reg,
      A         => fy_reg,
      B         => fy_reg,
      C         => fy2,
      VALID_OUT => fy2_v);

  --fyft=fy*ft
  fyft_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => valid_in_reg,
      A         => fy_reg,
      B         => ft_reg,
      C         => fyft,
      VALID_OUT => fyft_v);

  --x2=x*x
  x2_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => valid_in_reg,
      A         => x_reg,
      B         => x_reg,
      C         => x2,
      VALID_OUT => x2_v);

  --y2=y*y
  y2_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => valid_in_reg,
      A         => y_reg,
      B         => y_reg,
      C         => y2,
      VALID_OUT => y2_v);

  --xy=x*y
  xy_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => valid_in_reg,
      A         => x_reg,
      B         => y_reg,
      C         => xy,
      VALID_OUT => xy_v);

  pass1_valid <= '1' when xy_v = '1' and y2_v = '1' and x2_v = '1' and fyft_v = '1' and fy2_v = '1' and fxfy_v = '1' and fxft_v = '1' and fx2_v = '1' else '0';

  x_reg_buffer : pipeline_buffer
    generic map (
      WIDTH  => FRAC_BITS+1,
      STAGES => DELAY+1)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => x_reg,
      DOUT  => x_reg2);

  y_reg_buffer : pipeline_buffer
    generic map (
      WIDTH  => FRAC_BITS+1,
      STAGES => DELAY+1)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => y_reg,
      DOUT  => y_reg2);

  coord_shift2_buffer : pipeline_buffer
    generic map (
      WIDTH  => 4,
      STAGES => 2*DELAY+3)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => COORD_SHIFT,
      DOUT  => coord_shift2);


-------------------------------------------------------------------------------
-- Pass 2 Multiply


--fx2_t_x=fx2*x
  fx2_t_x_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fx2,
      B         => x_reg2,
      C         => fx2_t_x,
      VALID_OUT => fx2_t_x_v);

--fx2_t_y=fx2*y
  fx2_t_y_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fx2,
      B         => y_reg2,
      C         => fx2_t_y,
      VALID_OUT => fx2_t_y_v);

--fx2_t_x2=fx2*x2
  fx2_t_x2_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fx2,
      B         => x2,
      C         => fx2_t_x2,
      VALID_OUT => fx2_t_x2_v);

--fx2_t_y2=fx2*y2
  fx2_t_y2_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fx2,
      B         => y2,
      C         => fx2_t_y2,
      VALID_OUT => fx2_t_y2_v);

--fx2_t_xy=fx2*xy
  fx2_t_xy_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fx2,
      B         => xy,
      C         => fx2_t_xy,
      VALID_OUT => fx2_t_xy_v);

--fy2_t_x=fy2*x
  fy2_t_x_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fy2,
      B         => x_reg2,
      C         => fy2_t_x,
      VALID_OUT => fy2_t_x_v);

--fy2_t_y=fy2*y
  fy2_t_y_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fy2,
      B         => y_reg2,
      C         => fy2_t_y,
      VALID_OUT => fy2_t_y_v);

--fy2_t_x2=fy2*x2
  fy2_t_x2_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fy2,
      B         => x2,
      C         => fy2_t_x2,
      VALID_OUT => fy2_t_x2_v);

--fy2_t_y2=fy2*y2
  fy2_t_y2_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fy2,
      B         => y2,
      C         => fy2_t_y2,
      VALID_OUT => fy2_t_y2_v);

--fy2_t_xy=fy2*xy
  fy2_t_xy_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fy2,
      B         => xy,
      C         => fy2_t_xy,
      VALID_OUT => fy2_t_xy_v);

--fxfy_t_x=fxfy*x
  fxfy_t_x_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fxfy,
      B         => x_reg2,
      C         => fxfy_t_x,
      VALID_OUT => fxfy_t_x_v);

--fxfy_t_y=fxfy*y
  fxfy_t_y_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fxfy,
      B         => y_reg2,
      C         => fxfy_t_y,
      VALID_OUT => fxfy_t_y_v);

--fxfy_t_x2=fxfy*x2
  fxfy_t_x2_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fxfy,
      B         => x2,
      C         => fxfy_t_x2,
      VALID_OUT => fxfy_t_x2_v);

--fxfy_t_y2=fxfy*y2
  fxfy_t_y2_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fxfy,
      B         => y2,
      C         => fxfy_t_y2,
      VALID_OUT => fxfy_t_y2_v);

--fxfy_t_xy=fxfy*xy
  fxfy_t_xy_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fxfy,
      B         => xy,
      C         => fxfy_t_xy,
      VALID_OUT => fxfy_t_xy_v);

--fxft_t_x=fxft*x
  fxft_t_x_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fxft,
      B         => x_reg2,
      C         => fxft_t_x,
      VALID_OUT => fxft_t_x_v);

--fyft_t_x=fyft*x
  fyft_t_x_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fyft,
      B         => x_reg2,
      C         => fyft_t_x,
      VALID_OUT => fyft_t_x_v);

--fxft_t_y=fxft*y
  fxft_t_y_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fxft,
      B         => y_reg2,
      C         => fxft_t_y,
      VALID_OUT => fxft_t_y_v);

--fyft_t_y=fyft*y
  fyft_t_y_mult : signed_norm_mult
    port map (
      CLK       => CLK,
      RST       => RST,
      VALID_IN  => pass1_valid,
      A         => fyft,
      B         => y_reg2,
      C         => fyft_t_y,
      VALID_OUT => fyft_t_y_v);

  fx2_buffer : pipeline_buffer
    generic map (
      WIDTH  => FRAC_BITS+1,
      STAGES => DELAY+1)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => fx2,
      DOUT  => fx2_reg2);

  fy2_buffer : pipeline_buffer
    generic map (
      WIDTH  => FRAC_BITS+1,
      STAGES => DELAY+1)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => fy2,
      DOUT  => fy2_reg2);

  fxfy_buffer : pipeline_buffer
    generic map (
      WIDTH  => FRAC_BITS+1,
      STAGES => DELAY+1)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => fxfy,
      DOUT  => fxfy_reg2);

  fxft_buffer : pipeline_buffer
    generic map (
      WIDTH  => FRAC_BITS+1,
      STAGES => DELAY+1)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => fxft,
      DOUT  => fxft_reg2);

  fyft_buffer : pipeline_buffer
    generic map (
      WIDTH  => FRAC_BITS+1,
      STAGES => DELAY+1)
    port map (
      CLK   => CLK,
      RST   => RST,
      CLKEN => '1',
      DIN   => fyft,
      DOUT  => fyft_reg2);

  -- A COL0 (Scaled)
  a_0_0_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fx2_reg2,
      DOUT        => A_0_0);

  a_1_0_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fx2_t_x,
      DOUT        => A_1_0);

  a_2_0_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fx2_t_y,
      DOUT        => A_2_0);

  a_3_0_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fxfy_reg2,
      DOUT        => A_3_0);

  a_4_0_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fxfy_t_x,
      DOUT        => A_4_0);

  a_5_0_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fxfy_t_y,
      DOUT        => A_5_0);

  -- A COL3 (Scaled)
  a_0_3_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fxfy_reg2,
      DOUT        => A_0_3);

  a_1_3_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fxfy_t_x,
      DOUT        => A_1_3);

  a_2_3_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fxfy_t_y,
      DOUT        => A_2_3);

  a_3_3_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fy2_reg2,
      DOUT        => A_3_3);

  a_4_3_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fy2_t_x,
      DOUT        => A_4_3);

  a_5_3_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fy2_t_y,
      DOUT        => A_5_3);

  process (CLK)
  begin  -- process
    if CLK'event and CLK = '1' then     -- rising clock edge
      if RST = '1' then                 -- synchronous reset (active high)
        VALID_OUT <= '0';
      else
        if fx2_t_x_v = '1' and fx2_t_y_v = '1' and fx2_t_x2_v = '1' and fx2_t_y2_v = '1' and fx2_t_xy_v = '1' and fy2_t_x_v = '1' and fy2_t_y_v = '1' and fy2_t_x2_v = '1' and fy2_t_y2_v = '1' and fy2_t_xy_v = '1' and fxfy_t_x_v = '1' and fxfy_t_y_v = '1' and fxfy_t_x2_v = '1' and fxfy_t_y2_v = '1' and fxfy_t_xy_v = '1' and fxft_t_x_v = '1' and fyft_t_x_v = '1' and fxft_t_y_v = '1' and fyft_t_y_v = '1' then
          VALID_OUT <= '1';
        else
          VALID_OUT <= '0';
        end if;
      end if;
      -- A COL1
      A_0_1 <= fx2_t_x;
      A_1_1 <= fx2_t_x2;
      A_2_1 <= fx2_t_xy;
      A_3_1 <= fxfy_t_x;
      A_4_1 <= fxfy_t_x2;
      A_5_1 <= fxfy_t_xy;

      -- A COL2
      A_0_2 <= fx2_t_y;
      A_1_2 <= fx2_t_xy;
      A_2_2 <= fx2_t_y2;
      A_3_2 <= fxfy_t_y;
      A_4_2 <= fxfy_t_xy;
      A_5_2 <= fxfy_t_y2;

      -- A COL4
      A_0_4 <= fxfy_t_x;
      A_1_4 <= fxfy_t_x2;
      A_2_4 <= fxfy_t_xy;
      A_3_4 <= fy2_t_x;
      A_4_4 <= fy2_t_x2;
      A_5_4 <= fy2_t_xy;

      -- A COL5
      A_0_5 <= fxfy_t_y;
      A_1_5 <= fxfy_t_xy;
      A_2_5 <= fxfy_t_y2;
      A_3_5 <= fy2_t_y;
      A_4_5 <= fy2_t_xy;
      A_5_5 <= fy2_t_y2;
    end if;
  end process;

  -- b COL0 (Scaled)
  b_0_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fxft_reg2,
      DOUT        => B_0);

  b_1_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fxft_t_x,
      DOUT        => B_1);

  b_2_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fxft_t_y,
      DOUT        => B_2);

  b_3_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fyft,
      DOUT        => B_3);

  b_4_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fyft_t_x,
      DOUT        => B_4);

  b_5_rs : right_shifter
    port map (
      CLK         => CLK,
      COORD_SHIFT => coord_shift2,
      DIN         => fyft_t_y,
      DOUT        => B_5);

end Behavioral;
