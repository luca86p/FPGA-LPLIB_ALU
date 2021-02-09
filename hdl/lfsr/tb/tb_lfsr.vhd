-- =============================================================================
-- Whatis        : testbench for LFSR(s)
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : tb_lfsr.vhd
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
-- 2020-02-25  Luca Pilato       file creation
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
    constant NBIT   : positive  := 7;


    -- Signals 
    -- ----------------------------------------
    signal taps        : std_logic_vector(NBIT-1 downto 0);
    signal usexnor     : std_logic;
    signal load        : std_logic;
    signal seed2load   : std_logic_vector(NBIT-1 downto 0);
    signal shift       : std_logic;
    signal do          : std_logic_vector(NBIT-1 downto 0);


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
    i_lfsr_fibonacci: entity lplib_alu.lfsr_fibonacci(rtl)
        generic map (
            RST_POL     => '0',
            N           => NBIT
        )
        port map (
            clk         => clk        ,
            rst         => rst        ,
            taps        => taps       ,
            usexnor     => usexnor    ,
            load        => load       ,
            seed2load   => seed2load  ,
            shift       => shift      ,
            do          => open
        );


    i_lfsr_galois: entity lplib_alu.lfsr_galois
        generic map (
            RST_POL     => '0',
            N           => NBIT
        )
        port map (
            clk         => clk        ,
            rst         => rst        ,
            taps        => taps       ,
            usexnor     => usexnor    ,
            load        => load       ,
            seed2load   => seed2load  ,
            shift       => shift      ,
            do          => open
        );


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
        taps        <= "1100000"      ; -- [7 6 (0)]
        --taps        <= "110"      ; -- [3 2 (0)]
        usexnor     <= '0'            ;
        load        <= '0'            ;
        seed2load   <= (others=>'0')  ;
        shift       <= '0'            ;
        --
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
        --
        wait for 333 ns;
        wait until rising_edge(clk);
        shift       <= '1'            ;
        --
        wait for 333 ns;
        wait until rising_edge(clk);
        load        <= '1'            ;
        seed2load   <= (others=>'1')  ;
        wait until rising_edge(clk);
        load        <= '0'            ;
        --
        wait for (2**NBIT)*TCLK;
        wait until rising_edge(clk);
        --
        --
        --
        --
        wait for 333 ns;
        wait until rising_edge(clk);
        load        <= '1'            ;
        seed2load   <= (others=>'0')  ;
        usexnor     <= '1'            ;
        wait until rising_edge(clk);
        load        <= '0'            ;
        --
        wait for (2**NBIT)*TCLK;
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

end beh;
