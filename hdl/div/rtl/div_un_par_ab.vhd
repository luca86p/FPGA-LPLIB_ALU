-- =============================================================================
-- Whatis        : divider unsigned parallel (a = qb + r)
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : div_un_par_ab.vhd
-- Language      : VHDL-93
-- Module        : div_un_par_ab
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
-- 2018-02-26  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity div_un_par_ab is
    generic (
        N       : positive := 4
    );
    port (
        a       : in  std_logic_vector(N-1 downto 0);
        b       : in  std_logic_vector(N-1 downto 0);
        --
        q       : out std_logic_vector(N-1 downto 0);
        r       : out std_logic_vector(N-1 downto 0)
    );
end div_un_par_ab;

architecture rtl of div_un_par_ab is

    type   diff_matrix_t is array (N-1 downto 0) of unsigned(N downto 0);
    signal diff_matrix   : diff_matrix_t;

    type   r_matrix_t is array (N downto 0) of unsigned(N-1 downto 0);
    signal r_matrix   : r_matrix_t;

    signal q_s : std_logic_vector(N-1 downto 0);
    signal r_s : std_logic_vector(N-1 downto 0);

begin

    diff_matrix_gen: for i in N-1 downto 0 generate
        diff_matrix(i) <= ('0' & r_matrix(i+1)) - ('0' & unsigned(b));
        q_s(i)         <= '0' when diff_matrix(i)(N)='1' else '1';
    end generate diff_matrix_gen;

    q <= q_s;

    r_matrix_gen: for i in N downto 0 generate
        first_row_gen: if i=N generate
            r_matrix(i) <= TO_UNSIGNED(0,N-1) & a(i-1);
        end generate first_row_gen;
        mid_row_gen: if i>0 and i<N generate
            r_matrix(i) <=  diff_matrix(i)(N-2 downto 0) & a(i-1) when diff_matrix(i)(N)='0' else
                            r_matrix(i+1)(N-2 downto 0) & a(i-1);
        end generate mid_row_gen;
        last_row_gen: if i=0 generate
            r_matrix(i) <=  diff_matrix(i)(N-1 downto 0) when diff_matrix(i)(N)='0' else
                            r_matrix(i+1);
        end generate last_row_gen;
    end generate r_matrix_gen;

    r_s <= std_logic_vector(r_matrix(0));
    r   <= r_s;


end rtl;
