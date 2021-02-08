-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_counter_clr.vhd
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
--  Auto-checking tb to verify the equivalence of counter_clr architectures
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
    signal en           : std_logic;
    signal clr          : std_logic;
    signal cnt_1        : std_logic_vector(NBIT-1 downto 0);
    signal cnt_2        : std_logic_vector(NBIT-1 downto 0);


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
    i_counter_clr_1: entity lplib_alu.counter_clr(rtl)
    generic map (
        RST_POL     => RST_POL  ,
        NBIT        => NBIT
    )
    port map (
        clk         => clk      ,
        rst         => rst      ,
        clr         => clr      ,
        en          => en       ,
        cnt         => cnt_1
    );

    i_counter_clr_2: entity lplib_alu.counter_clr(rtl2)
    generic map (
        RST_POL     => RST_POL  ,
        NBIT        => NBIT
    )
    port map (
        clk         => clk      ,
        rst         => rst      ,
        clr         => clr      ,
        en          => en       ,
        cnt         => cnt_2
    );



    -- HARD equivalency
    -- ----------------------------------------   
    ASSERT cnt_1=cnt_2
        REPORT "counter_clr(rtl) NOT EQUAL to counter_clr(rtl2)"
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
        en          <= '0';
        clr         <= '0';
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
        --
        en          <= '0';
        wait until rising_edge(clk);
        en          <= '1';
        wait until rising_edge(clk);
        --
        wait for BLANK_TIME;
        wait until rising_edge(clk);
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
        variable exp_cnt_1_i    : integer := 0;
        variable exp_cnt_2_i    : integer := 0;
        --
        variable check_err      : integer := 0;
    begin
        if tcase=-1 then -- update the error counter
            check_err_counter   <= check_err;
        elsif falling_edge(clk) and rst /= RST_POL then
            --
            -- check
            if unsigned(cnt_1) /= exp_cnt_1_i then
                REPORT "expected cnt_1 " & integer'image(exp_cnt_1_i) & " got " & integer'image(TO_INTEGER(unsigned(cnt_1)))
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
            --
            if unsigned(cnt_2) /= exp_cnt_2_i then
                REPORT "expected cnt_2 " & integer'image(exp_cnt_2_i) & " got " & integer'image(TO_INTEGER(unsigned(cnt_2)))
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
            --
            if clr='1' then
                --
                exp_cnt_1_i := 0;
                exp_cnt_2_i := 0;
                --
            elsif en='1' then
                --
                exp_cnt_1_i := (exp_cnt_1_i + 1) mod 2**NBIT;
                exp_cnt_2_i := (exp_cnt_2_i + 1) mod 2**NBIT;
                --
            end if;
            --
            --
        end if;
    end process proc_check;


end beh;
