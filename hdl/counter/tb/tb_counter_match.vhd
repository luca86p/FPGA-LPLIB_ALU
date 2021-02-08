-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_counter_match.vhd
-- Language      : VHDL-93
-- Module        : tb
-- Library       : lplib_alu_verif
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  Auto-checking process to verify the correct count
-- 
-- -----------------------------------------------------------------------------
-- Dependencies
-- 
-- -----------------------------------------------------------------------------
-- Issues
-- 
-- -----------------------------------------------------------------------------
-- Copyright (c) 2021 Luca Pilato
-- MIT License
-- -----------------------------------------------------------------------------
-- date        who               changes
-- 2019-09-06  Luca Pilato       file creation
-- =============================================================================


-- STD lib
-- ----------------------------------------
use std.textio.all;

-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;

-- User lib
-- ----------------------------------------
library lplib_alu;



entity tb is
end entity tb;


architecture beh of tb is

    -- TB common parameters and signals
    -- ----------------------------------------
    constant RST_POL    : std_logic := '0';
    constant CLK_FREQ   : positive  := 10000000; -- 10 MHz (100 ns)
    --
    constant TCLK       : time  := 1.0e10/real(CLK_FREQ) * (0.1 ns); -- clock period
    constant DUTYCLK    : real  := 0.5; -- clock duty-cycle

    signal en_clk       : std_logic;
    --
    signal clk          : std_logic := '0';
    signal rst          : std_logic := RST_POL;
    --
    signal tcase        : integer   := 0;


    -- Check Process
    -- ----------------------------------------
    signal err_counter          : integer   := 0;
    signal check_err_counter    : integer   := 0;


    -- Constant
    -- ----------------------------------------
    constant NBIT   : positive  := 8;


    -- Signals 
    -- ----------------------------------------
    signal clr          : std_logic;
    signal updw         : std_logic;
    signal load         : std_logic;
    signal load_val     : std_logic_vector(NBIT-1 downto 0);
    signal en           : std_logic;
    signal match_val    : std_logic_vector(NBIT-1 downto 0);
    signal match        : std_logic;
    signal cnt          : std_logic_vector(NBIT-1 downto 0);

    signal match_pipe   : std_logic;
    signal cnt_pipe     : std_logic_vector(NBIT-1 downto 0);


begin


    -- clock generator 50%
    -- ----------------------------------------
    clk <= not clk after TCLK/2 when en_clk='1' else '0';


    -- clock generator DUTYCLK% 
    -- ----------------------------------------
    -- proc_clk: process(clk, en_clk)
    -- begin
    --     if en_clk='1' then
    --         if clk='0' then
    --             clk <= '1' after TCLK*(1.0-DUTYCLK);
    --         else
    --             clk <= '0' after TCLK*DUTYCLK;
    --         end if;
    --     else
    --         clk <= '0'
    --     end if;
    -- end process proc_clk;


    -- Unit(s) Under Test
    -- ----------------------------------------
    i_counter_match_pipe_0: entity lplib_alu.counter_match(rtl)
    generic map (
        RST_POL     => RST_POL  ,
        NBIT        => NBIT     ,
        MATCH_PIPE  => 0
    )
    port map (
        clk         => clk      ,
        rst         => rst      ,
        clr         => clr      ,
        updw        => updw     ,
        load        => load     ,
        load_val    => load_val ,
        en          => en       ,
        match_val   => match_val,
        match       => match    ,
        cnt         => cnt
    );

    i_counter_match_pipe_1: entity lplib_alu.counter_match(rtl)
    generic map (
        RST_POL     => RST_POL  ,
        NBIT        => NBIT     ,
        MATCH_PIPE  => 1
    )
    port map (
        clk         => clk      ,
        rst         => rst      ,
        clr         => clr      ,
        updw        => updw     ,
        load        => load     ,
        load_val    => load_val ,
        en          => en       ,
        match_val   => match_val,
        match       => match_pipe    ,
        cnt         => cnt_pipe
    );

    -- HARD equivalency
    -- ----------------------------------------   
    ASSERT cnt=cnt_pipe
        REPORT "i_counter_match_pipe_0:cnt NOT EQUAL to i_counter_match_pipe_1:cnt"
            SEVERITY FAILURE; 

    -- Drive Process
    -- ----------------------------------------    
    proc_drive: process
        constant BLANK_TIME : time := 0.1 ms;
    begin
        -- ========
        tcase       <= 0;
        --
        en_clk      <= '0';
        rst         <= RST_POL;
        --
        clr         <= '0';
        updw        <= '0';
        load        <= '0';
        load_val    <= (others=>'0');
        en          <= '0';
        match_val   <= (others=>'0');
        --
        wait for 333 ns;
        en_clk     <= '1';
        wait for 333 ns;
        wait until falling_edge(clk);
        rst        <= not RST_POL;
        wait for 333 ns;
        wait until rising_edge(clk);
        --
        -- ========
        tcase   <= 1;
        wait until rising_edge(clk);
        --
        en          <= '1';
        --
        wait for BLANK_TIME;
        wait until rising_edge(clk);
        --
        --
        clr         <= '1';
        wait until rising_edge(clk);
        clr         <= '0';
        wait until rising_edge(clk);
        --
        load        <= '1';
        load_val    <= std_logic_vector(TO_UNSIGNED(2**(NBIT-1),NBIT));
        wait until rising_edge(clk);
        load        <= '0';
        wait until rising_edge(clk);
        --
        wait for BLANK_TIME;
        wait until rising_edge(clk);
        --
        updw        <= '1';
        --
        wait for BLANK_TIME;
        wait until rising_edge(clk);
        --
        match_val   <= std_logic_vector(TO_UNSIGNED(2**(NBIT-1),NBIT));
        --
        clr         <= '1';
        wait until rising_edge(clk);
        clr         <= '0';
        wait until rising_edge(clk);
        --
        --
        en          <= '0';
        wait until rising_edge(clk);
        en          <= '1';
        wait until rising_edge(clk);
        --
        --
        wait for BLANK_TIME;
        wait until rising_edge(clk);
        --
        --
        -- ======== Power Off
        tcase   <= -1;
        wait until rising_edge(clk);
        --
        wait for 333 ns;
        wait until rising_edge(clk);
        rst        <= '0';
        wait for 333 ns;
        en_clk     <= '0';
        wait for 333 ns;
        --
        err_counter <= err_counter + check_err_counter;
        wait for 333 ns;
        --
        if err_counter /= 0 then
            REPORT "... ==|[ TEST FAILED ]|== ...";
        else
            REPORT "... ==|[ TEST SUCCESS ]|== ...";
        end if;
        REPORT "... ==|[ err_counter: " & integer'image(err_counter) & " ]|== ...";
        --
        -- ASSERT FALSE
        --     REPORT "... ==|[ proc_drive: SIMULATION END ]|== ..."
        --         SEVERITY FAILURE;
        --
        REPORT "... ==|[ proc_drive: SIMULATION END ]|== ...";
        --
        wait;
    end process proc_drive;


    -- Check Process (on clk falling edge)
    -- ----------------------------------------
    proc_check: process(clk, rst)
        variable exp_cnt_i      : integer := 0;
        --
        variable check_err      : integer := 0;
        --
        variable match_del      : std_logic := '1';
    begin
        if tcase=-1 then -- update the error counter
            check_err_counter   <= check_err;
        elsif falling_edge(clk) and rst /= RST_POL then
            --
            -- check
            if unsigned(cnt) /= exp_cnt_i then
                REPORT "expected cnt " & integer'image(exp_cnt_i) & " got " & integer'image(TO_INTEGER(unsigned(cnt)))
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
            --
            if match='1' then
                if (cnt /= match_val) then
                    REPORT "expected cnt on match " & integer'image(TO_INTEGER(unsigned(match_val))) & " got " & integer'image(TO_INTEGER(unsigned(cnt)))
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
            end if;
            --
            if (cnt = match_val) then
                if match/='1' then
                    REPORT "expected match but got " & std_logic'image(match)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
            end if;
            --
            if (rst /= RST_POL) and (match_del /= match_pipe) then
                REPORT "expected match_del = match_pipe but got " & std_logic'image(match_del) & " " & std_logic'image(match_pipe)
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
            match_del   := match;
            --
            -- prepare next expected value
            if clr='1' then
                --
                exp_cnt_i   := 0;
                --
            elsif load='1' then
                --
                exp_cnt_i   := TO_INTEGER(unsigned(load_val));
                --
            elsif en='1' then
                if updw='0' then
                    --
                    exp_cnt_i   := (exp_cnt_i + 1) mod 2**NBIT;
                    --
                else
                    --
                    exp_cnt_i   := (exp_cnt_i - 1) mod 2**NBIT;
                    --
                end if;
            end if;
            --
            --
        end if;
    end process proc_check;


end beh;
