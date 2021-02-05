-- =============================================================================
-- Whatis        : combinational adder subtractor
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : add_sub_comb.vhd
-- Language      : VHDL-93
-- Module        : add_sub_comb
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


entity add_sub_comb is
    generic (
        N       : positive := 8
    );
    port (
        a       : in  std_logic_vector(N-1 downto 0);
        b       : in  std_logic_vector(N-1 downto 0);
        cbin    : in  std_logic;
        sub     : in  std_logic;
        s       : out std_logic_vector(N-1 downto 0);
        cbout   : out std_logic;
        c2ovf   : out std_logic
    );
end add_sub_comb;

architecture rtl of add_sub_comb is

    signal cchain   : std_logic_vector(N downto 0);
    signal b_s      : std_logic_vector(N-1 downto 0);

begin

    cchain(0)   <= cbin xor sub;
    b_s         <= b when sub='0' else (not b);

    gen_adder: for i in 0 to N-1 generate
        s(i)        <= a(i) xor b_s(i) xor cchain(i);
        cchain(i+1) <= (a(i) and b_s(i)) or ((a(i) xor b_s(i)) and cchain(i));
    end generate gen_adder;

    cbout       <= cchain(N) xor sub;
    c2ovf       <= cchain(N) xor cchain(N-1);

end rtl;
