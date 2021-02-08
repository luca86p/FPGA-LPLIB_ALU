-- =============================================================================
-- Whatis        : Linear Feedback Shift Register (galois)
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : lfsr_galois.vhd
-- Language      : VHDL-93
-- Module        : lfsr_fibonacci
-- Library       : lplib_alu
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  THEORY:
--     --->[ 4 ]-+-[ 3 ]-+-[ 2 ]-+-[ 1 ]-->
--       ^t4     ^t3     ^t2     ^t1     |t0
--       \-------\-------\-------\----<-/
--
--  IMPLEMENTATION:
--     --->[ N-1 ]-+-[ N-2 ]-+-[ ... ]-+-[  0  ]-->
--       ^t(N-1)   ^t(N-2)   ^t(.)     ^t(0)    |
--       \---------\---------\---------\------<-/
--
-- feedback polynomial (fibonacci)
-- ===================================
-- t7*x^7 + t6*x^6 + t5*x^5 + t4*x^4 + t3*x^3 + t2*x^2 + t1*x^1 + 1
-- Taps [t7 t6 t5 t4 t3 t2 t1 t0] defines the polynomial.
-- t0 always 1 for feedback.
-- tN indicates the grade N of the polynomial.
--  e.g. [7 6 0] is the 7-th grade polynomial x^7 + x^6 + 1.
-- A maximum-length LFSR produces an m-sequence through all possible 2^m−1 states,
--  except the state where all bits are zero. A zero seed won't move.
-- A maximum-length "mirror" sequence should come with "mirror" taps: m-taps.
--  e.g. [7 6 0] ==(7-taps)==> [0 1 7] ==(mirror)==> [7 1 0]
--      x^7 + x^6 + 1   -- ---------------->  x^7 + x + 1
--  e.g the [7 6 0] polynomial is defined by taps="110_0000"
--
-- "usexnor" produce a complement of the state of an LFSR.
-- A state with all ones is illegal when using an XNOR feedback.
--
-- galois vs. fibonacci
-- ===================================
--  galois do(N-1) = fibonacci do(N-1)
-- -------------------
--  galois do(N-2) = fibonacci do(0)
--  galois do(N-3) = fibonacci do(1)
--  ...
--  galois do(N-i) = fibonacci do(i)
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
-- 2015-06-05  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity lfsr_galois is
    generic (
        RST_POL     : std_logic := '0';
        N           : positive  := 8
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        taps        : in  std_logic_vector(N-1 downto 0);
        usexnor     : in  std_logic;
        load        : in  std_logic;
        seed2load   : in  std_logic_vector(N-1 downto 0);
        shift       : in  std_logic;
        do          : out std_logic_vector(N-1 downto 0)
  );
end lfsr_galois;


architecture rtl of lfsr_galois is

    signal q_s              : std_logic_vector(N-1 downto 0);
    signal q_s_next         : std_logic_vector(N-1 downto 0);

begin

    proc_shift: process(clk,rst)
    begin
        if rst=RST_POL then
            q_s <= (others=>'0');
        elsif rising_edge(clk) then
            if load='1' then
                q_s <= seed2load;
            elsif shift='1' then
                q_s <= q_s_next;
            end if;
        end if;
    end process proc_shift;

    do <= q_s;

    gen_next_galois: for i in N-1 downto 0 generate
        gen_first: if i=N-1 generate
            q_s_next(i) <= q_s(0) and  taps(i) when usexnor='0' else
                           q_s(0) nand taps(i);
        end generate gen_first;
        gen_others: if i<N-1 generate
            q_s_next(i) <= (q_s(i+1) xor  (q_s(0) and  taps(i))) when usexnor='0' else
                           (q_s(i+1) xnor (q_s(0) nand taps(i)));
        end generate gen_others;
    end generate gen_next_galois;


end rtl;
