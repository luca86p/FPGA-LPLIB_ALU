-- =============================================================================
-- Whatis        : basic up-counter with enable
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : counter_basic.vhd
-- Language      : VHDL-93
-- Module        : counter_basic
-- Library       : lplib_alu
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
-- 2019-09-06  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity counter_basic is
    generic (
        RST_POL         : std_logic := '0';
        NBIT            : positive  := 8
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        en              : in  std_logic;
        cnt             : out std_logic_vector(NBIT-1 downto 0)
    );
end entity counter_basic;


-- All in seq process
-- ----------------------------------------
architecture rtl of counter_basic is

    signal cnt_u  : unsigned(NBIT-1 downto 0);

begin

    proc_cnt: process (rst,clk)
    begin
        if rst=RST_POL then
            cnt_u <= (others=>'0');
        elsif rising_edge(clk) then
            if en='1' then
                cnt_u <= cnt_u + 1;
            end if;
        end if;
    end process proc_cnt;

    cnt <= std_logic_vector(cnt_u);

end rtl;


-- Alternative arch: next_* process
-- ----------------------------------------
architecture rtl2 of counter_basic is

    signal cnt_u        : unsigned(NBIT-1 downto 0);
    signal cnt_next_u   : unsigned(NBIT-1 downto 0);

begin

    proc_cnt: process (rst,clk)
    begin
        if rst=RST_POL then
            cnt_u <= (others=>'0');
        elsif rising_edge(clk) then
            cnt_u <= cnt_next_u;
        end if;
    end process proc_cnt;

    cnt_next_u  <=  cnt_u+1     when en='1' else
                    cnt_u;

    cnt <= std_logic_vector(cnt_u);

end rtl2;