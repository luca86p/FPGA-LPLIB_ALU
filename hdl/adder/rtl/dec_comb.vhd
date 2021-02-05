-- =============================================================================
-- Whatis        : combinational decrementer
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : dec_comb.vhd
-- Language      : VHDL-93
-- Module        : dec_comb
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


entity dec_comb is
    generic (
        N        : positive := 8
    );
    port (
        x        : in  std_logic_vector(N-1 downto 0);
        dec      : in  std_logic;
        y        : out std_logic_vector(N-1 downto 0);
        bout     : out std_logic
  );
end dec_comb;

architecture rtl of dec_comb is

    signal b    : std_logic_vector(N downto 0);

begin

    b(0) <= dec;

    gen_dec: for i in 0 to N-1 generate
        y(i)   <= x(i) xor b(i);
        b(i+1) <= (not x(i)) and b(i);
    end generate gen_dec;

    bout <= b(N);

end rtl;
