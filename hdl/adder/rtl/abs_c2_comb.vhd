-- =============================================================================
-- Whatis        : combinational absolute value (Two's complement)
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : abs_c2_comb.vhd
-- Language      : VHDL-93
-- Module        : abs_c2_comb
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
-- 2019-11-06  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity abs_c2_comb is
    generic (
        N       : positive := 8
    );
  port (
        x       : in  std_logic_vector(N-1 downto 0);
        y       : out std_logic_vector(N-1 downto 0)
    );
end abs_c2_comb;

architecture rtl of abs_c2_comb is

    signal c    : std_logic_vector(N downto 0);
    signal xn   : std_logic_vector(N-1 downto 0);
    signal xc2  : std_logic_vector(N-1 downto 0);

begin

    xn <= not x;

    c(0) <= '1';

    gen_inc: for i in 0 to N-1 generate
        xc2(i) <= xn(i) xor c(i);
        c(i+1) <= xn(i) and c(i);
    end generate gen_inc;

    y <= x when x(N-1)='0' else xc2;

end rtl;
