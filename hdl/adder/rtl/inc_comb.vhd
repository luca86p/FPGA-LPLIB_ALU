-- =============================================================================
-- Whatis        : combinational incrementer
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : inc_comb.vhd
-- Language      : VHDL-93
-- Module        : inc_comb
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


entity inc_comb is
    generic (
        N        : positive := 8
    );
    port (
        x        : in  std_logic_vector(N-1 downto 0);
        inc      : in  std_logic;
        y        : out std_logic_vector(N-1 downto 0);
        cout     : out std_logic
  );
end inc_comb;

architecture rtl of inc_comb is

    signal c    : std_logic_vector(N downto 0);

begin

    c(0) <= inc;

    gen_inc: for i in 0 to N-1 generate
        y(i)   <= x(i) xor c(i);
        c(i+1) <= x(i) and c(i);
    end generate gen_inc;

    cout <= c(N);

end rtl;
