-- =============================================================================
-- Whatis        : multiplier signed parallel Baugh-Wooley
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : mul_sg_par_bw_ab.vhd
-- Language      : VHDL-93
-- Module        : mul_sg_par_bw_ab
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


entity mul_sg_par_bw_ab is
    generic (
        N   : positive := 4
    );
    port (
        a   : in  std_logic_vector(N-1 downto 0);
        b   : in  std_logic_vector(N-1 downto 0);
        z   : out std_logic_vector(2*N-1 downto 0)
    );
end mul_sg_par_bw_ab;


architecture rtl of mul_sg_par_bw_ab is

    -- simple entry
    -- z = a*b

    --   a2 a1 a0
    --   /__/__/__b0
    --  /__/__/___b1
    -- /__/__/____b2

    type mul_matrix_t is array (0 to N-1) of std_logic_vector(N-1 downto 0);

    signal PP_matrix : mul_matrix_t ;
    signal S_matrix  : mul_matrix_t ;
    signal C_matrix  : mul_matrix_t ;

    signal res_l  : std_logic_vector(N-1 downto 0);
    signal res_h  : std_logic_vector(N-1 downto 0);
    signal lastS  : std_logic_vector(N-1 downto 0);
    signal lastC  : std_logic_vector(N-1 downto 0);
    signal cchain : std_logic_vector(N downto 0);

begin

    -- Partial Products matrix
    -- ---------------------------------
    --   a2  a1  a0
    --   /__ /__ /__ b0
    --  p02 p01 p00
    --   /__ /__ /__ b1
    --  p12 p11 p10
    --   /__ /__ /__ b2
    --  p22 p21 p20
    -- ---------------------------------

    -- Baugh-Wooley: line quasi-negation
    -- ---------------------------------
    --                #p03  p02  p01  p00
    --           #p13  p12  p11  p10
    --      #p23  p22  p21  p20
    --  p33 #p32 #p31 #p30
    -- ---------------------------------
    gen_PP_row: for i in 0 to N-1 generate
        gen_PP_col: for j in N-1 downto 0 generate
            gen_PPn_col: if (j=N-1) and (i/=N-1) generate -- Baugh-Wooley negation
                PP_matrix(i)(j) <= not( b(i) and a(j) );
            end generate gen_PPn_col;
            gen_PPn_row: if (j/=N-1) and (i=N-1) generate -- Baugh-Wooley negation
                PP_matrix(i)(j) <= not( b(i) and a(j) );
            end generate gen_PPn_row;
            gen_PP_std: if (j<N-1) or (i<N-1) generate
                PP_matrix(i)(j) <= b(i) and a(j);
            end generate gen_PP_std;
            gen_PP_last: if (j=N-1) or (i=N-1) generate
                PP_matrix(i)(j) <= b(i) and a(j);
            end generate gen_PP_last;
        end generate gen_PP_col;
    end generate gen_PP_row;


    -- carry-save S sub-matrix
    -- ---------------------------------
    S_matrix(0) <= PP_matrix(0);
    gen_S_row: for i in 1 to N-1 generate
        gen_S_col: for j in N-2 downto 0 generate
            S_matrix(i)(j) <= PP_matrix(i)(j) xor C_matrix(i-1)(j) xor S_matrix(i-1)(j+1);
        end generate gen_S_col;
        S_matrix(i)(N-1) <= PP_matrix(i)(N-1) xor C_matrix(i-1)(N-1);
    end generate gen_S_row;


    -- carry-save C sub-matrix
    -- ---------------------------------
    C_matrix(0) <= (others=>'0');
    gen_C_row: for i in 1 to N-1 generate
        gen_C_col: for j in N-2 downto 0 generate
            C_matrix(i)(j) <= (PP_matrix(i)(j) and C_matrix(i-1)(j)) or ((PP_matrix(i)(j) xor C_matrix(i-1)(j)) and S_matrix(i-1)(j+1));
        end generate gen_C_col;
        C_matrix(i)(N-1) <= (PP_matrix(i)(N-1) and C_matrix(i-1)(N-1));
    end generate gen_C_row;


    -- result-low
    -- ---------------------------------
    gen_res_l: for j in N-1 downto 0 generate
        res_l(j)    <= S_matrix(j)(0);
    end generate gen_res_l;


    -- result-high
    -- ---------------------------------
    lastS   <= '1' & S_matrix(N-1)(N-1 downto 1); -- Baugh-Wooley insertion
    lastC   <= C_matrix(N-1)(N-1 downto 0);

    cchain(0) <= '1'; -- Baugh-Wooley insertion
    gen_last_adder: for j in 0 to N-1 generate
        res_h(j)    <= lastS(j) xor lastC(j) xor cchain(j);
        cchain(j+1) <= (lastS(j) and lastC(j)) or ((lastS(j) xor lastC(j)) and cchain(j));
    end generate gen_last_adder;

    -- cat
    -- ---------------------------------
    z <= res_h & res_l;


end rtl;
