-- =============================================================================
-- Whatis        : up/dw-counter with clear, enable, load and match features
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : counter_match.vhd
-- Language      : VHDL-93
-- Module        : counter_match
-- Library       : lplib_alu
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  MATCH_PIPE=0 
--      the match signal is combinational with match_value comparison.
--
--  MATCH_PIPE=1 
--      the match signal is buffered with one clk delay on match_value comparison.
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

entity counter_match is
    generic (
        RST_POL         : std_logic := '0';
        NBIT            : positive  := 8;
        MATCH_PIPE      : integer range 0 to 1 := 0
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        clr             : in  std_logic;
        updw            : in  std_logic;
        load            : in  std_logic;
        load_val        : in  std_logic_vector(NBIT-1 downto 0);
        en              : in  std_logic;
        match_val       : in  std_logic_vector(NBIT-1 downto 0);
        match           : out std_logic;
        cnt             : out std_logic_vector(NBIT-1 downto 0)
    );
end entity counter_match;


architecture rtl of counter_match is

    signal cnt_u    : unsigned(NBIT-1 downto 0);
    signal cnt_next_u    : unsigned(NBIT-1 downto 0);

    signal match_s  : std_logic;
    signal match_p  : std_logic;

begin

    proc_cnt: process (rst,clk)
    begin
        if rst=RST_POL then
            cnt_u <= (others=>'0');
        elsif rising_edge(clk) then
            cnt_u <= cnt_next_u;
        end if;
    end process proc_cnt;

    cnt_next_u  <=  TO_UNSIGNED(0,NBIT) when clr='1' else
                    unsigned(load_val)  when load='1' else
                    cnt_u+1             when en='1' and updw='0' else
                    cnt_u-1             when en='1' and updw='1' else
                    cnt_u;

    cnt <= std_logic_vector(cnt_u);

    match_s <= '1' when cnt_u=unsigned(match_val) else '0';

    gen_MATCH_PIPE_0: if MATCH_PIPE=0 generate
        match_p <= match_s;
    end generate gen_MATCH_PIPE_0;

    gen_MATCH_PIPE_1: if MATCH_PIPE=1 generate
        proc_match_pipe: process (rst,clk)
        begin
            if rst=RST_POL then
                match_p <= '0';
            elsif rising_edge(clk) then
                match_p <= match_s;
            end if;
        end process proc_match_pipe;
    end generate gen_MATCH_PIPE_1;

    match <= match_p;

end rtl;
