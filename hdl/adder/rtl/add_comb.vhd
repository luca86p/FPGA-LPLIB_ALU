-- =============================================================================
-- Whatis        : combinational adder
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : add_comb.vhd
-- Language      : VHDL-93
-- Module        : add_comb
-- Library       : lplib_alu
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
-- 
--  More than one rtl architecture, just as examples.
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


entity add_comb is
    generic (
        N       : positive := 8
    );
    port (
        a       : in  std_logic_vector(N-1 downto 0);
        b       : in  std_logic_vector(N-1 downto 0);
        cin     : in  std_logic;
        s       : out std_logic_vector(N-1 downto 0);
        cout    : out std_logic;
        c2ovf   : out std_logic
    );
end add_comb;


-- Ripple Carry Adder with generate FA statements
-- ----------------------------------------
architecture rtl of add_comb is

    signal cchain : std_logic_vector(N downto 0);

begin

    cchain(0)   <= cin;

    gen_adder: for i in 0 to N-1 generate
        s(i)        <= a(i) xor b(i) xor cchain(i);
        cchain(i+1) <= (a(i) and b(i)) or ((a(i) xor b(i)) and cchain(i));
    end generate gen_adder;

    cout        <= cchain(N);
    c2ovf       <= cchain(N) xor cchain(N-1);

end rtl;


-- Ripple Carry Adder with unsigned extended cast
-- ----------------------------------------
architecture rtl2 of add_comb is

    signal a_un     : unsigned(N downto 0);
    signal b_un     : unsigned(N downto 0);
    signal s_un     : unsigned(N downto 0);

begin

    a_un    <= '0' & unsigned(a) ; -- extended unsigned
    b_un    <= '0' & unsigned(b) ; -- extended unsigned
    --
    s_un    <= a_un + b_un + unsigned('0' & cin); -- very tricky: convert to vector, then allowed unsigned cast and '+'
    s       <= std_logic_vector(s_un(N-1 downto 0));
    --
    cout    <= std_logic(s_un(N));
    c2ovf   <= ( a(N-1) and b(N-1) and (not s_un(N-1)) ) or
             ( (not a(N-1)) and (not a(N-1)) and s_un(N-1) );

end rtl2;


-- Ripple Carry Adder with FA combinational process
-- ----------------------------------------
architecture rtl3 of add_comb is

begin

    proc_add: process(a,b,cin) -- process(all)
        variable c      : std_logic;
        variable c_prev : std_logic;
    begin
        c := cin;
        for i in 0 to N-1 loop
            s(i)   <= a(i) xor b(i) xor c;
            c_prev := c;
            c      := (a(i) and b(i)) or (a(i) and c) or (b(i) and c);
        end loop;
        --
        cout   <= c;
        c2ovf  <= c xor c_prev;
        --
    end process proc_add;
  
end rtl3;