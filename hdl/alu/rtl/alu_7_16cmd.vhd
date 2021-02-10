-- =============================================================================
-- Whatis        : combinational alu
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : alu_7_16cmd.vhd
-- Language      : VHDL-93
-- Module        : alu_7_16cmd
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
-- 2016-07-01  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity alu_7_16cmd is
    generic (
        N           : positive := 4
    );
    port (
        op1         : in  std_logic_vector (N-1 downto 0);
        op2         : in  std_logic_vector (N-1 downto 0);
        cbin        : in  std_logic;
        --
        cmd_add     : in  std_logic; -- op1 + op2               z c v s p
        cmd_addc    : in  std_logic; -- op1 + op2 + cbin        z c v s p
        cmd_sub     : in  std_logic; -- op1 - op2               z c v s p
        cmd_subb    : in  std_logic; -- op1 - op2 - cbin        z c v s p
        cmd_mul     : in  std_logic; -- op1 * op2 unsigned      z - - s p
        --
        cmd_and     : in  std_logic; -- op1 and  op2            z - - s p
        cmd_or      : in  std_logic; -- op1 or   op2            z - - s p
        cmd_xor     : in  std_logic; -- op1 xor  op2            z - - s p
        cmd_xnor    : in  std_logic; -- op1 xnor op2            z - - s p
        --
        cmd_sll     : in  std_logic; -- op1 << 1 (ins 0)        z c - s p
        cmd_srl     : in  std_logic; -- op1 >> 1 (ins 0)        z c - s p
        cmd_sra     : in  std_logic; -- op1 >> 1 (ins MSB)      z c - s p
        --
        cmd_rl      : in  std_logic; -- op1 << 1 (ins MSB)      z - - s p
        cmd_rlc     : in  std_logic; -- op1 << 1 (ins cbin)     z c - s p
        cmd_rr      : in  std_logic; -- op1 >> 1 (ins LSB)      z - - s p
        cmd_rrc     : in  std_logic; -- op1 >> 1 (ins cbin)     z c - s p
        --
        y           : out std_logic_vector(N-1 downto 0); -- all results (high part of mul)
        y_mul_low   : out std_logic_vector(N-1 downto 0); -- the low part of mul
        --
        z           : out std_logic; -- zero
        c           : out std_logic; -- carry
        v           : out std_logic; -- c2 overflow
        s           : out std_logic; -- sign
        p           : out std_logic  -- even parity
    );
end alu_7_16cmd;

architecture rtl of alu_7_16cmd is

    -- adder subtractor
    signal c_chain      : std_logic_vector(N   downto 0);
    --
    signal op1_s        : std_logic_vector(N-1 downto 0);
    signal op2_s        : std_logic_vector(N-1 downto 0);
    --
    signal y_sum        : std_logic_vector(N-1 downto 0);

    -- multiplier
    -- z = a*b

    -- aN-1  a2 a1 a0
    --       /__/__/__b0
    --      /__/__/___b1
    --     /__/__/____b2

    type mul_matrix_t is array (0 to N-1) of std_logic_vector(N-1 downto 0);
    --
    signal PP_matrix : mul_matrix_t ;
    signal S_matrix  : mul_matrix_t ;
    signal C_matrix  : mul_matrix_t ;
    --
    signal res_l  : std_logic_vector(N-1 downto 0);
    signal res_h  : std_logic_vector(N-1 downto 0);
    signal lastS  : std_logic_vector(N-1 downto 0);
    signal lastC  : std_logic_vector(N-1 downto 0);
    signal cchain : std_logic_vector(N downto 0);
    --
    signal y_mul_h      : std_logic_vector(N-1 downto 0);
    signal y_mul_l      : std_logic_vector(N-1 downto 0);

    -- logic functions
    signal y_and        : std_logic_vector(N-1 downto 0);
    signal y_or         : std_logic_vector(N-1 downto 0);
    signal y_xor        : std_logic_vector(N-1 downto 0);
    signal y_xnor       : std_logic_vector(N-1 downto 0);

    -- shift/rotate functions
    signal y_sll        : std_logic_vector(N-1 downto 0);
    signal y_srl        : std_logic_vector(N-1 downto 0);
    signal y_sra        : std_logic_vector(N-1 downto 0);
    --
    signal y_rl         : std_logic_vector(N-1 downto 0);
    signal y_rlc        : std_logic_vector(N-1 downto 0);
    signal y_rr         : std_logic_vector(N-1 downto 0);
    signal y_rrc        : std_logic_vector(N-1 downto 0);
    
    -- output
    signal y_s          : std_logic_vector(N-1 downto 0);

begin

    -- adder subtractor: RippleCarryAdder like
    -- ------------------------------------------------------------------
    -- adder subtractor: carry/borrow in
    c_chain(0)  <=  '0'         when cmd_add='1'    else
                    cbin        when cmd_addc='1'   else
                    '1'         when cmd_sub='1'    else
                    not cbin    when cmd_subb='1'   else
                    '0' ;

    -- adder subtractor: operands
    op1_s       <=  op1;
    op2_s       <=  op2         when (cmd_add or cmd_addc)='1'  else
                    (not op2)   when (cmd_sub or cmd_subb)='1'  else
                    (others=>'0') ;
    
    -- adder subtractor: the RCA core
    gen_adder: for i in 0 to N-1 generate
        y_sum(i)        <= op1_s(i) xor op2_s(i) xor c_chain(i);
        c_chain(i+1)    <= (op1_s(i) and op2_s(i)) or ((op1_s(i) xor op2_s(i)) and c_chain(i));
    end generate gen_adder;


    -- multiplier: unsigned parallel (a*b)
    -- ------------------------------------------------------------------
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
    gen_PP_row: for i in 0 to N-1 generate
        gen_PP_col: for j in N-1 downto 0 generate
            PP_matrix(i)(j) <= op2(i) and op1(j);
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

    y_mul_l     <= res_l;
    y_mul_low   <= y_mul_l;

    -- result-high
    -- ---------------------------------
    lastS   <= '0' & S_matrix(N-1)(N-1 downto 1);
    lastC   <= C_matrix(N-1)(N-1 downto 0);

    cchain(0) <= '0';
    gen_last_adder: for j in 0 to N-1 generate
        res_h(j)    <= lastS(j) xor lastC(j) xor cchain(j);
        cchain(j+1) <= (lastS(j) and lastC(j)) or ((lastS(j) xor lastC(j)) and cchain(j));
    end generate gen_last_adder;

    y_mul_h <= res_h;
    -- ------------------------------------------------------------------

    -- logic functions
    -- ------------------------------------------------------------------
    y_and   <= op1 and  op2;
    y_or    <= op1  or  op2;
    y_xor   <= op1 xor  op2;
    y_xnor  <= op1 xnor op2;

    -- shift/rotate functions
    -- ------------------------------------------------------------------
    -- left logical     : op1_s << 1 (insert 0)
    y_sll   <= op1(N-2 downto 0) & '0';
    -- right logical    : op1_s >> 1 (insert 0)
    y_srl   <= '0' & op1(N-1 downto 1);
    -- right arithmetic : op1_s >> 1 (insert MSB)
    y_sra   <= op1(N-1) & op1(N-1 downto 1);

    -- rotate left
    y_rl    <= op1(N-2 downto 0) & op1(N-1);
    -- rotate left (through carry)
    y_rlc   <= op1(N-2 downto 0) & cbin;

    -- rotate right
    y_rr    <= op1(N-1) & op1(N-1 downto 1);
    -- rotate right (through carry)
    y_rrc   <= cbin & op1(N-1 downto 1);


    -- output assignment
    -- ------------------------------------------------------------------
    y_s <=  y_sum   when cmd_add    = '1' else
            y_sum   when cmd_addc   = '1' else
            y_sum   when cmd_sub    = '1' else
            y_sum   when cmd_subb   = '1' else
            y_mul_h when cmd_mul    = '1' else
            y_and   when cmd_and    = '1' else
            y_or    when cmd_or     = '1' else
            y_xor   when cmd_xor    = '1' else
            y_xnor  when cmd_xnor   = '1' else
            y_sll   when cmd_sll    = '1' else
            y_srl   when cmd_srl    = '1' else
            y_sra   when cmd_sra    = '1' else
            y_rl    when cmd_rl     = '1' else
            y_rlc   when cmd_rlc    = '1' else
            y_rr    when cmd_rr     = '1' else
            y_rrc   when cmd_rrc    = '1' else
            (others=>'0');
    --           
    y       <= y_s;


    -- flags
    -- ------------------------------------------------------------------
    z       <=  '1' when unsigned(y_s)=0 else '0';
    --
    c       <=  c_chain(N)      when cmd_add='1'    else
                c_chain(N)      when cmd_addc='1'   else
                not c_chain(N)  when cmd_sub='1'    else
                not c_chain(N)  when cmd_subb='1'   else
                op1(N-1)        when cmd_sll='1'    else
                op1(0)          when cmd_srl='1'    else
                op1(0)          when cmd_sra='1'    else
                op1(N-1)        when cmd_rlc='1'    else
                op1(0)          when cmd_rrc='1'    else
                '0';
    --
    v       <=  c_chain(N) xor c_chain(N-1) when (cmd_add or cmd_addc or cmd_sub or cmd_subb)='1' else '0';
    --
    s       <=  y_s(N-1);
    --
    proc_parity: process(y_s)
        variable pv : std_logic;
    begin
        pv := '0';
        for i in 0 to N-1 loop
            pv := pv xor y_s(i);
        end loop;
        p <= pv ;
    end process proc_parity;

end rtl;
