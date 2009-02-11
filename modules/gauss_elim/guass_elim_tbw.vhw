--------------------------------------------------------------------------------
-- Copyright (c) 1995-2003 Xilinx, Inc.
-- All Right Reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 10.1.03
--  \   \         Application : ISE
--  /   /         Filename : guass_elim_tbw.vhw
-- /___/   /\     Timestamp : Fri Dec 19 18:56:25 2008
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: 
--Design Name: guass_elim_tbw
--Device: Xilinx
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE STD.TEXTIO.ALL;

ENTITY guass_elim_tbw IS
END guass_elim_tbw;

ARCHITECTURE testbench_arch OF guass_elim_tbw IS
    FILE RESULTS: TEXT OPEN WRITE_MODE IS "results.txt";

    COMPONENT gauss_elim
        PORT (
            CLK : In std_logic;
            RST : In std_logic;
            INPUT_LOAD : In std_logic;
            A_0_0 : In std_logic_vector (26 DownTo 0);
            A_0_1 : In std_logic_vector (26 DownTo 0);
            A_0_2 : In std_logic_vector (26 DownTo 0);
            A_0_3 : In std_logic_vector (26 DownTo 0);
            A_0_4 : In std_logic_vector (26 DownTo 0);
            A_0_5 : In std_logic_vector (26 DownTo 0);
            A_1_0 : In std_logic_vector (26 DownTo 0);
            A_1_1 : In std_logic_vector (26 DownTo 0);
            A_1_2 : In std_logic_vector (26 DownTo 0);
            A_1_3 : In std_logic_vector (26 DownTo 0);
            A_1_4 : In std_logic_vector (26 DownTo 0);
            A_1_5 : In std_logic_vector (26 DownTo 0);
            A_2_0 : In std_logic_vector (26 DownTo 0);
            A_2_1 : In std_logic_vector (26 DownTo 0);
            A_2_2 : In std_logic_vector (26 DownTo 0);
            A_2_3 : In std_logic_vector (26 DownTo 0);
            A_2_4 : In std_logic_vector (26 DownTo 0);
            A_2_5 : In std_logic_vector (26 DownTo 0);
            A_3_0 : In std_logic_vector (26 DownTo 0);
            A_3_1 : In std_logic_vector (26 DownTo 0);
            A_3_2 : In std_logic_vector (26 DownTo 0);
            A_3_3 : In std_logic_vector (26 DownTo 0);
            A_3_4 : In std_logic_vector (26 DownTo 0);
            A_3_5 : In std_logic_vector (26 DownTo 0);
            A_4_0 : In std_logic_vector (26 DownTo 0);
            A_4_1 : In std_logic_vector (26 DownTo 0);
            A_4_2 : In std_logic_vector (26 DownTo 0);
            A_4_3 : In std_logic_vector (26 DownTo 0);
            A_4_4 : In std_logic_vector (26 DownTo 0);
            A_4_5 : In std_logic_vector (26 DownTo 0);
            A_5_0 : In std_logic_vector (26 DownTo 0);
            A_5_1 : In std_logic_vector (26 DownTo 0);
            A_5_2 : In std_logic_vector (26 DownTo 0);
            A_5_3 : In std_logic_vector (26 DownTo 0);
            A_5_4 : In std_logic_vector (26 DownTo 0);
            A_5_5 : In std_logic_vector (26 DownTo 0);
            B_0 : In std_logic_vector (26 DownTo 0);
            B_1 : In std_logic_vector (26 DownTo 0);
            B_2 : In std_logic_vector (26 DownTo 0);
            B_3 : In std_logic_vector (26 DownTo 0);
            B_4 : In std_logic_vector (26 DownTo 0);
            B_5 : In std_logic_vector (26 DownTo 0);
            X_0 : Out std_logic_vector (26 DownTo 0);
            X_1 : Out std_logic_vector (26 DownTo 0);
            X_2 : Out std_logic_vector (26 DownTo 0);
            X_3 : Out std_logic_vector (26 DownTo 0);
            X_4 : Out std_logic_vector (26 DownTo 0);
            X_5 : Out std_logic_vector (26 DownTo 0);
            OUTPUT_VALID : Out std_logic
        );
    END COMPONENT;

    SIGNAL CLK : std_logic := '0';
    SIGNAL RST : std_logic := '0';
    SIGNAL INPUT_LOAD : std_logic := '0';
    SIGNAL A_0_0 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_0_1 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_0_2 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_0_3 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_0_4 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_0_5 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_1_0 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_1_1 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_1_2 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_1_3 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_1_4 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_1_5 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_2_0 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_2_1 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_2_2 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_2_3 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_2_4 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_2_5 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_3_0 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_3_1 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_3_2 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_3_3 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_3_4 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_3_5 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_4_0 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_4_1 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_4_2 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_4_3 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_4_4 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_4_5 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_5_0 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_5_1 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_5_2 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_5_3 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_5_4 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL A_5_5 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL B_0 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL B_1 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL B_2 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL B_3 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL B_4 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL B_5 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL X_0 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL X_1 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL X_2 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL X_3 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL X_4 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL X_5 : std_logic_vector (26 DownTo 0) := "000000000000000000000000000";
    SIGNAL OUTPUT_VALID : std_logic := '0';

    constant PERIOD : time := 10 ns;
    constant DUTY_CYCLE : real := 0.5;
    constant OFFSET : time := 100 ns;

    BEGIN
        UUT : gauss_elim
        PORT MAP (
            CLK => CLK,
            RST => RST,
            INPUT_LOAD => INPUT_LOAD,
            A_0_0 => A_0_0,
            A_0_1 => A_0_1,
            A_0_2 => A_0_2,
            A_0_3 => A_0_3,
            A_0_4 => A_0_4,
            A_0_5 => A_0_5,
            A_1_0 => A_1_0,
            A_1_1 => A_1_1,
            A_1_2 => A_1_2,
            A_1_3 => A_1_3,
            A_1_4 => A_1_4,
            A_1_5 => A_1_5,
            A_2_0 => A_2_0,
            A_2_1 => A_2_1,
            A_2_2 => A_2_2,
            A_2_3 => A_2_3,
            A_2_4 => A_2_4,
            A_2_5 => A_2_5,
            A_3_0 => A_3_0,
            A_3_1 => A_3_1,
            A_3_2 => A_3_2,
            A_3_3 => A_3_3,
            A_3_4 => A_3_4,
            A_3_5 => A_3_5,
            A_4_0 => A_4_0,
            A_4_1 => A_4_1,
            A_4_2 => A_4_2,
            A_4_3 => A_4_3,
            A_4_4 => A_4_4,
            A_4_5 => A_4_5,
            A_5_0 => A_5_0,
            A_5_1 => A_5_1,
            A_5_2 => A_5_2,
            A_5_3 => A_5_3,
            A_5_4 => A_5_4,
            A_5_5 => A_5_5,
            B_0 => B_0,
            B_1 => B_1,
            B_2 => B_2,
            B_3 => B_3,
            B_4 => B_4,
            B_5 => B_5,
            X_0 => X_0,
            X_1 => X_1,
            X_2 => X_2,
            X_3 => X_3,
            X_4 => X_4,
            X_5 => X_5,
            OUTPUT_VALID => OUTPUT_VALID
        );

        PROCESS    -- clock process for CLK
        BEGIN
            WAIT for OFFSET;
            CLOCK_LOOP : LOOP
                CLK <= '0';
                WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
                CLK <= '1';
                WAIT FOR (PERIOD * DUTY_CYCLE);
            END LOOP CLOCK_LOOP;
        END PROCESS;

        PROCESS
            BEGIN
                -- -------------  Current Time:  100ns
                WAIT FOR 100 ns;
                RST <= '1';
                A_0_0 <= "000000000001101101111001111";
                A_0_1 <= "111111111001101010011011101";
                A_0_2 <= "000000000011101111000111000";
                A_0_3 <= "000000000000000101010011100";
                A_0_4 <= "000000000001101010110011100";
                A_0_5 <= "111111111111111001010110000";
                A_1_0 <= "111111111111110011010100110";
                A_1_1 <= "000000000100011000011111011";
                A_1_2 <= "000000000000000011101100111";
                A_1_3 <= "000000000000000011010101100";
                A_1_4 <= "000000000000101000100010111";
                A_1_5 <= "000000000000001000011111111";
                A_2_0 <= "000000000000000111011110001";
                A_2_1 <= "000000000000000011101100111";
                A_2_2 <= "000000000001100010010100011";
                A_2_3 <= "111111111111111111110010101";
                A_2_4 <= "000000000000001000011111111";
                A_2_5 <= "000000000000001011100100111";
                A_3_0 <= "000000000000000101010011100";
                A_3_1 <= "000000000001101010110011100";
                A_3_2 <= "111111111111111001010110000";
                A_3_3 <= "000000000010110011001110001";
                A_3_4 <= "000000001100100001100001011";
                A_3_5 <= "111111111001010101101111101";
                A_4_0 <= "000000000000000011010101100";
                A_4_1 <= "000000000000101000100010111";
                A_4_2 <= "000000000000001000011111111";
                A_4_3 <= "000000000000011001000011000";
                A_4_4 <= "000000000111001000001010011";
                A_4_5 <= "111111111111001000000100110";
                A_5_0 <= "111111111111111111110010101";
                A_5_1 <= "000000000000001000011111111";
                A_5_2 <= "000000000000001011100100111";
                A_5_3 <= "111111111111110010101011011";
                A_5_4 <= "111111111111001000000100110";
                A_5_5 <= "000000000010100001100000101";
                B_0 <= "000000000000010110111010010";
                B_1 <= "000000000000000000010101101";
                B_2 <= "000000000000000000100110100";
                B_3 <= "000000000010100001000000110";
                B_4 <= "000000000000010101110101000";
                B_5 <= "111111111111110000011111011";
                -- -------------------------------------
                -- -------------  Current Time:  185ns
                WAIT FOR 85 ns;
                RST <= '0';
                -- -------------------------------------
                -- -------------  Current Time:  235ns
                WAIT FOR 50 ns;
                INPUT_LOAD <= '1';
                -- -------------------------------------
                -- -------------  Current Time:  245ns
                WAIT FOR 10 ns;
                INPUT_LOAD <= '0';
                -- -------------------------------------
                WAIT FOR 99765 ns;

            END PROCESS;

    END testbench_arch;

