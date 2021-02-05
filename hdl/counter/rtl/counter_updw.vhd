-- =============================================================================
-- Whatis        : basic up/dw-counter with clear and enable
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : counter_updw.vhd
-- Language      : VHDL-93
-- Module        : counter_updw
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


entity counter_updw is
    generic (
        RST_POL         : std_logic := '0';
        NBIT            : positive  := 8
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        clr             : in  std_logic;
        en              : in  std_logic;
        updw            : in  std_logic;
        cnt             : out std_logic_vector(NBIT-1 downto 0)
    );
end entity counter_updw;


architecture rtl of counter_updw is

    signal cnt_u         : unsigned(NBIT-1 downto 0);
    signal cnt_next_u    : unsigned(NBIT-1 downto 0);

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
                    cnt_u+1             when en='1' and updw='0' else
                    cnt_u-1             when en='1' and updw='1' else
                    cnt_u;

    cnt <= std_logic_vector(cnt_u);

end rtl;
