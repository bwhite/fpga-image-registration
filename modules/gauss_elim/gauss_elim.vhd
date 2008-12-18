library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity gauss_elim is
  generic (
    WHOLE_BITS : integer := 8;
    FRAC_BITS  : integer := 19
    );
  port (CLK        : in std_logic;
        RST        : in std_logic;
        INPUT_LOAD : in std_logic;

        -- A Matrix Inputs (6x6)
        -- 1:WHOLE_BITS-1:FRAC_BITS
        A_0_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_0_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_0_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_0_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_0_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_0_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

        A_1_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_1_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_1_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_1_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_1_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_1_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

        A_2_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_2_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_2_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_2_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_2_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_2_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

        A_3_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_3_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_3_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_3_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_3_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_3_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

        A_4_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_4_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_4_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_4_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_4_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_4_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

        A_5_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_5_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_5_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_5_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_5_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        A_5_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

        -- b Vector Inputs (6x1)
        B_0 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        B_1 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        B_2 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        B_3 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        B_4 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        B_5 : in std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);

        -- x Vector Outputs (6x1)
        X_0 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        X_1 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        X_2 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        X_3 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        X_4 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
        X_5 : out std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);


        OUTPUT_VALID : out std_logic
        );
end gauss_elim;

architecture Behavioral of gauss_elim is
  component div1_test is
    generic (
      QUOTIENT_BITS : integer := 27;
      FRACTION_BITS : integer := 19);
    port (clk       : in  std_logic;
          rst       : in  std_logic;
          valid_in  : in  std_logic;
          a         : in  std_logic_vector (WHOLE_BITS+FRAC_BITS-1 downto 0);
          b         : in  std_logic_vector (WHOLE_BITS+FRAC_BITS-1 downto 0);
          c         : out std_logic_vector (WHOLE_BITS+FRAC_BITS-1 downto 0);
          oob       : out std_logic;
          valid_out : out std_logic);
  end component;

  type   overall_state_type is (IDLE, FP_MK_INV, FP_ELIM_COL, BP_ROW_MULT, BP_ROW_MULT_SUM, BP_DIFF_AB, BP_DIV, ERR);
  signal state                                : overall_state_type := IDLE;
  type   aug_row_type is array (6 downto 0) of signed(WHOLE_BITS+FRAC_BITS-1 downto 0);
  type   mult_aug_row_type is array (6 downto 0) of signed(2*(WHOLE_BITS+FRAC_BITS)-1 downto 0);
  type   aug_matrix_type is array (5 downto 0) of aug_row_type;
  signal bp_row_mult_cnt, bp_row_mult_sum_cnt : unsigned(2 downto 0);
  signal aug                                  : aug_matrix_type;


-- FP Signals
  signal cur_i, cur_j, cur_j_delay0, cur_j_delay1, cur_j_delay2, cur_j_delay3, cur_j_delay4, cur_j_delay5                         : unsigned(2 downto 0) := (others => '0');
  signal fp_mk_inv_pivot                                                                                                          : signed(WHOLE_BITS+FRAC_BITS-1 downto 0);
  type   pivot_row_type is array (6 downto 0) of signed(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal pivot_row0                                                                                                               : pivot_row_type;
  signal new_aug, aug_i, aug_j, aug_j_delay0, aug_j_delay1, aug_j_delay2, aug_j_delay3, aug_j_delay4                              : aug_row_type;
  signal new_aug_delay0, new_aug_delay1, new_aug_delay2, new_aug_delay3, new_aug_delay4                                           : mult_aug_row_type;
  signal aug_j_i, aug_i_j, aug_i_i                                                                                                : signed(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal fp_mk_inv_done, fp_mk_pivot_done, fp_elim_col_done, bp_row_mult_done, bp_row_mult_sum_done, bp_diff_ab_done, bp_div_done : std_logic;


-- BP Signals
  type   row_mult_type_ext is array (4 downto 0) of signed(2*(WHOLE_BITS+FRAC_BITS)-1 downto 0);
  type   row_mult_type is array (4 downto 0) of signed((WHOLE_BITS+FRAC_BITS)-1 downto 0);
  signal row_mult                                                                                         : row_mult_type;
  signal row_mult_delay0, row_mult_delay1, row_mult_delay2, row_mult_delay3, row_mult_delay4              : row_mult_type_ext;
  signal row_mult_sum, row_mult_sum_delay0, row_mult_sum_delay1, row_mult_sum_delay2, row_mult_sum_delay3 : signed(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal new_x                                                                                            : signed(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal diff_ab                                                                                          : signed(WHOLE_BITS+FRAC_BITS-1 downto 0);

  type   x_type is array (5 downto 0) of signed(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal x_reg : x_type;

  -- 1:WHOLE_BITS-1:FRAC_BITS
  signal diva, divb                       : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0) := (others => '0');
  signal divc                             : std_logic_vector(WHOLE_BITS+FRAC_BITS-1 downto 0);
  signal div_valid_in                     : std_logic                                         := '0';
  signal div_valid_out, div_busy, div_oob : std_logic;
  attribute KEEP                          : string;
  attribute keep of aug                   : signal is "true";
  signal done_reg                         : std_logic                                         := '0';
begin
  X_0          <= std_logic_vector(x_reg(0));
  X_1          <= std_logic_vector(x_reg(1));
  X_2          <= std_logic_vector(x_reg(2));
  X_3          <= std_logic_vector(x_reg(3));
  X_4          <= std_logic_vector(x_reg(4));
  X_5          <= std_logic_vector(x_reg(5));
  OUTPUT_VALID <= done_reg;

  process (cur_i, cur_j, aug, aug_j, aug_j_i)
  begin  -- process
    case cur_i is
      when "000" =>
        aug_i   <= aug(0);
        aug_i_i <= aug(0)(0);
        aug_j_i <= aug_j(0);
      when "001" =>
        aug_i   <= aug(1);
        aug_i_i <= aug(1)(1);
        aug_j_i <= aug_j(1);
      when "010" =>
        aug_i   <= aug(2);
        aug_i_i <= aug(2)(2);
        aug_j_i <= aug_j(2);
      when "011" =>
        aug_i   <= aug(3);
        aug_i_i <= aug(3)(3);
        aug_j_i <= aug_j(3);
      when "100" =>
        aug_i   <= aug(4);
        aug_i_i <= aug(4)(4);
        aug_j_i <= aug_j(4);
      when "101" =>
        aug_i   <= aug(5);
        aug_i_i <= aug(5)(5);
        aug_j_i <= aug_j(5);
      when others =>
        aug_i   <= aug(0);
        aug_i_i <= aug(0)(0);
        aug_j_i <= aug_j(0);
    end case;

    case cur_j is
      when "000" =>
        aug_j   <= aug(0);
        aug_i_j <= aug_i(0);
      when "001" =>
        aug_j   <= aug(1);
        aug_i_j <= aug_i(1);
      when "010" =>
        aug_j   <= aug(2);
        aug_i_j <= aug_i(2);
      when "011" =>
        aug_j   <= aug(3);
        aug_i_j <= aug_i(3);
      when "100" =>
        aug_j   <= aug(4);
        aug_i_j <= aug_i(4);
      when "101" =>
        aug_j   <= aug(5);
        aug_i_j <= aug_i(5);
      when "110" =>
        aug_j   <= aug(0);              -- NOTE Shouldn't happen
        aug_i_j <= aug_i(6);
      when others =>
        aug_j   <= aug(0);
        aug_i_j <= aug_i(0);
    end case;
  end process;

  process (CLK)
  begin  -- process
    if CLK'event and CLK = '1' then     -- rising clock edge
      -- Initial initialization of the 
      if RST = '1' then                 -- synchronous reset (active low)
        state <= IDLE;
      else
        case state is
          when ERR =>
            null;
            ---------------------------------------------------------------------
            -- IDLE
          when IDLE =>
            if INPUT_LOAD = '1' then
              -- Row 0
              aug(0)(0) <= signed(A_0_0);
              aug(0)(1) <= signed(A_0_1);
              aug(0)(2) <= signed(A_0_2);
              aug(0)(3) <= signed(A_0_3);
              aug(0)(4) <= signed(A_0_4);
              aug(0)(5) <= signed(A_0_5);
              aug(0)(6) <= signed(B_0);

              -- Row 1
              aug(1)(0) <= signed(A_1_0);
              aug(1)(1) <= signed(A_1_1);
              aug(1)(2) <= signed(A_1_2);
              aug(1)(3) <= signed(A_1_3);
              aug(1)(4) <= signed(A_1_4);
              aug(1)(5) <= signed(A_1_5);
              aug(1)(6) <= signed(B_1);

              -- Row 2
              aug(2)(0) <= signed(A_2_0);
              aug(2)(1) <= signed(A_2_1);
              aug(2)(2) <= signed(A_2_2);
              aug(2)(3) <= signed(A_2_3);
              aug(2)(4) <= signed(A_2_4);
              aug(2)(5) <= signed(A_2_5);
              aug(2)(6) <= signed(B_2);

              -- Row 3
              aug(3)(0) <= signed(A_3_0);
              aug(3)(1) <= signed(A_3_1);
              aug(3)(2) <= signed(A_3_2);
              aug(3)(3) <= signed(A_3_3);
              aug(3)(4) <= signed(A_3_4);
              aug(3)(5) <= signed(A_3_5);
              aug(3)(6) <= signed(B_3);

              -- Row 4
              aug(4)(0) <= signed(A_4_0);
              aug(4)(1) <= signed(A_4_1);
              aug(4)(2) <= signed(A_4_2);
              aug(4)(3) <= signed(A_4_3);
              aug(4)(4) <= signed(A_4_4);
              aug(4)(5) <= signed(A_4_5);
              aug(4)(6) <= signed(B_4);

              -- Row 5
              aug(5)(0) <= signed(A_5_0);
              aug(5)(1) <= signed(A_5_1);
              aug(5)(2) <= signed(A_5_2);
              aug(5)(3) <= signed(A_5_3);
              aug(5)(4) <= signed(A_5_4);
              aug(5)(5) <= signed(A_5_5);
              aug(5)(6) <= signed(B_5);

              state    <= FP_MK_INV;
              cur_i    <= (others                           => '0');  -- Set the current pivot row to 0
              cur_j    <= (others                           => '0');
              -- Zero x_reg
              x_reg    <= ((WHOLE_BITS+FRAC_BITS-1 downto 0 => '0'), (WHOLE_BITS+FRAC_BITS-1 downto 0 => '0'), (WHOLE_BITS+FRAC_BITS-1 downto 0 => '0'), (WHOLE_BITS+FRAC_BITS-1 downto 0 => '0'), (WHOLE_BITS+FRAC_BITS-1 downto 0 => '0'), (WHOLE_BITS+FRAC_BITS-1 downto 0 => '0'));
              done_reg <= '0';
              div_busy <= '0';
            end if;
            -------------------------------------------------------------------
            -- FP
          when FP_MK_INV =>
            diva <= std_logic_vector(aug_i_j);
            divb <= std_logic_vector(aug_i_i);

            if div_valid_out = '1' then
              case cur_j is
                when "000" =>
                  pivot_row0(0) <= signed(divc);
                when "001" =>
                  pivot_row0(1) <= signed(divc);
                when "010" =>
                  pivot_row0(2) <= signed(divc);
                when "011" =>
                  pivot_row0(3) <= signed(divc);
                when "100" =>
                  pivot_row0(4) <= signed(divc);
                when "101" =>
                  pivot_row0(5) <= signed(divc);
                when "110" =>
                  pivot_row0(6) <= signed(divc);
                when others =>
                  null;
              end case;
            end if;

            if div_busy = '0' then
              if cur_j = "111" then           -- Done
                fp_elim_col_done <= '0';
                state            <= FP_ELIM_COL;
                cur_j            <= cur_i+1;  -- Start at i+1
                cur_j_delay0     <= (others => '0');
                cur_j_delay1     <= (others => '0');
                cur_j_delay2     <= (others => '0');
                cur_j_delay3     <= (others => '0');
                cur_j_delay4     <= (others => '0');
                cur_j_delay5     <= (others => '0');
              else
                div_valid_in <= '1';
                div_busy     <= '1';
              end if;
            else
              div_valid_in <= '0';
              if div_valid_out = '1' then
                div_busy <= '0';
                cur_j    <= cur_j+1;          -- Next j
              end if;
            end if;
            
          when FP_ELIM_COL =>  -- cur_i=current pivot row cur_j=current row
            -- Delay chain
            cur_j_delay0 <= cur_j;
            cur_j_delay1 <= cur_j_delay0;
            cur_j_delay2 <= cur_j_delay1;
            cur_j_delay3 <= cur_j_delay2;
            cur_j_delay4 <= cur_j_delay3;
            cur_j_delay5 <= cur_j_delay4;

            cur_j <= cur_j+1;

            -- Store the new eliminated column value in the aug matrix

            -- Multiply the pivot row by the current value to be eliminated (aug_j_i)
            for j in 6 downto 0 loop
              -- 1:2*WHOLE_BITS-1:2*FRAC_BITS
              new_aug_delay0(j) <= aug_j_i * pivot_row0(j);
            end loop;  -- j

            new_aug_delay1 <= new_aug_delay0;
            new_aug_delay2 <= new_aug_delay1;
            new_aug_delay3 <= new_aug_delay2;
            new_aug_delay4 <= new_aug_delay3;
            aug_j_delay0   <= aug_j;
            aug_j_delay1   <= aug_j_delay0;
            aug_j_delay2   <= aug_j_delay1;
            aug_j_delay3   <= aug_j_delay2;
            aug_j_delay4   <= aug_j_delay3;
            -- Subtract the pivot row by the current row to create a zero
            -- TODO: Due to numerical errors, we will force these zeros later
            for j in 6 downto 0 loop
              -- TODO Check for overflow
              new_aug(j) <= new_aug_delay4(j)(2*FRAC_BITS+WHOLE_BITS-1 downto FRAC_BITS) - aug_j_delay4(j);
            end loop;  -- j

            -- Store the new row back in the aug matrix
            case cur_j_delay5 is
              when "001" =>
                aug(1) <= new_aug;
              when "010" =>
                aug(2) <= new_aug;
              when "011" =>
                aug(3) <= new_aug;
              when "100" =>
                aug(4) <= new_aug;
              when "101" =>
                aug(5) <= new_aug;
              when others =>
                null;
            end case;


            if cur_j_delay5 = 5 then  -- If we have eliminated all 6 rows with
              -- the current pivot
              if cur_i /= 4 then        -- 0 to N-2, If we haven't gone through
                                        -- all of the pivot rows
                state <= FP_MK_INV;
                cur_j <= (others => '0');
                cur_i <= cur_i + 1;
              else
                state            <= BP_ROW_MULT;
                bp_row_mult_done <= '0';
                cur_i            <= "101";  -- N-1=5
                bp_row_mult_cnt  <= (others => '0');
              end if;
            end if;

            -------------------------------------------------------------------
            -- BP
          when BP_ROW_MULT =>
            bp_row_mult_cnt <= bp_row_mult_cnt + 1;
            for i in 5 downto 1 loop
              row_mult_delay0(i-1) <= x_reg(i)*aug_i(i);
            end loop;  -- i

            row_mult_delay1 <= row_mult_delay0;
            row_mult_delay2 <= row_mult_delay1;
            row_mult_delay3 <= row_mult_delay2;
            row_mult_delay4 <= row_mult_delay3;
            for i in 4 downto 0 loop
              row_mult(i) <= row_mult_delay4(i)(2*FRAC_BITS+WHOLE_BITS-1 downto FRAC_BITS);
            end loop;  -- i
            if bp_row_mult_cnt = "110" then
              state               <= BP_ROW_MULT_SUM;
              bp_row_mult_sum_cnt <= (others => '0');
            end if;
            
          when BP_ROW_MULT_SUM =>
            bp_row_mult_sum_cnt <= bp_row_mult_sum_cnt + 1;
            row_mult_sum_delay0 <= row_mult(0)+row_mult(1)+row_mult(2)+row_mult(3)+row_mult(4);
            row_mult_sum_delay1 <= row_mult_sum_delay0;
            row_mult_sum_delay2 <= row_mult_sum_delay1;
            row_mult_sum_delay3 <= row_mult_sum_delay2;
            row_mult_sum        <= row_mult_sum_delay3;

            if bp_row_mult_sum_cnt = "101" then
              state <= BP_DIFF_AB;
            end if;
            
          when BP_DIFF_AB =>
            diff_ab  <= aug_i(6)-row_mult_sum;
            state    <= BP_DIV;
            div_busy <= '0';
            
          when BP_DIV =>
            diva <= std_logic_vector(diff_ab);  -- diff_ab/aug(i,i)
            divb <= std_logic_vector(aug_i_i);


            if div_valid_out = '1' then
              div_busy <= '0';
              case cur_i is
                when "000" =>
                  x_reg(0) <= signed(divc);
                when "001" =>
                  x_reg(1) <= signed(divc);
                when "010" =>
                  x_reg(2) <= signed(divc);
                when "011" =>
                  x_reg(3) <= signed(divc);
                when "100" =>
                  x_reg(4) <= signed(divc);
                when "101" =>
                  x_reg(5) <= signed(divc);
                when others =>
                  null;
              end case;

              if cur_i /= 0 then
                -- Next row
                cur_i           <= cur_i - 1;
                state           <= BP_ROW_MULT;
                bp_row_mult_cnt <= (others => '0');
              else
                -- WE ARE DONE
                state    <= IDLE;
                done_reg <= '1';
              end if;
            else
              if div_busy = '1' then
                div_valid_in <= '0';
              else
                div_valid_in <= '1';
                div_busy     <= '1';
              end if;
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process;


  div : div1_test
    port map (
      CLK       => CLK,
      RST       => '0',
      VALID_IN  => div_valid_in,
      A         => diva,
      B         => divb,
      C         => divc,
      OOB       => div_oob,
      VALID_OUT => div_valid_out);

end Behavioral;
