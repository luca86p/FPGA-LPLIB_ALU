-- =============================================================================
-- Whatis        : combinational alu
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : alu_5_11cmd.vhd
-- Language      : VHDL-93
-- Module        : alu_5_11cmd
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


entity alu_5_11cmd is
    generic (
        N           : positive := 4
    );
    port (
        op1         : in  std_logic_vector (N-1 downto 0);
        op2         : in  std_logic_vector (N-1 downto 0);
        cbin        : in  std_logic;
        --
        cmd_add     : in  std_logic;
        cmd_sub     : in  std_logic;
        cmd_and     : in  std_logic;
        cmd_or      : in  std_logic;
        cmd_xor     : in  std_logic;
        cmd_xnor    : in  std_logic;
        cmd_sll     : in  std_logic;
        cmd_srl     : in  std_logic;
        cmd_sra     : in  std_logic;
        cmd_rl      : in  std_logic;
        cmd_rr      : in  std_logic;
        --
        y           : out std_logic_vector(N-1 downto 0);
        --
        z           : out std_logic; -- zero
        c           : out std_logic; -- carry
        v           : out std_logic; -- c2 overflow
        s           : out std_logic; -- sign
        p           : out std_logic  -- even parity
    );
end alu_5_11cmd;

architecture rtl of alu_5_11cmd is

    signal c_chain      : std_logic_vector(N   downto 0);
    --
    signal op1_s        : std_logic_vector(N-1 downto 0);
    signal op2_s        : std_logic_vector(N-1 downto 0);
    --
    signal y_sum        : std_logic_vector(N-1 downto 0);
    signal y_and        : std_logic_vector(N-1 downto 0);
    signal y_or         : std_logic_vector(N-1 downto 0);
    signal y_xor        : std_logic_vector(N-1 downto 0);
    signal y_xnor       : std_logic_vector(N-1 downto 0);
    signal y_sll        : std_logic_vector(N-1 downto 0);
    signal y_srl        : std_logic_vector(N-1 downto 0);
    signal y_sra        : std_logic_vector(N-1 downto 0);
    signal y_rl         : std_logic_vector(N-1 downto 0);
    signal y_rr         : std_logic_vector(N-1 downto 0);
    --
    signal y_s          : std_logic_vector(N-1 downto 0);

begin

    -- sum functions: adder subtractor
    c_chain(0)  <= cbin xor cmd_sub;
    op1_s       <= op1;
    op2_s       <= op2 when cmd_sub='0' else (not op2);
    --
    gen_adder: for i in 0 to N-1 generate
        y_sum(i)        <= op1_s(i) xor op2_s(i) xor c_chain(i);
        c_chain(i+1)    <= (op1_s(i) and op2_s(i)) or ((op1_s(i) xor op2_s(i)) and c_chain(i));
    end generate gen_adder;

    -- logic functions
    y_and   <= op1 and op2;
    y_or    <= op1  or op2;
    y_xor   <= op1 xor op2;
    y_xnor  <= op1 xnor op2;

    -- shift/rotate functions
    -- left logical     : op1_s << 1 (insert 0)
    y_sll   <= op1(N-2 downto 0) & '0';
    -- right logical    : op1_s >> 1 (insert 0)
    y_srl   <= '0' & op1(N-1 downto 1);
    -- right arithmetic : op1_s >> 1 (insert MSB)
    y_sra   <= op1(N-1) & op1(N-1 downto 1);
    -- rotate left (through carry)
    y_rl    <= op1(N-2 downto 0) & cbin;
    -- rotate right (through carry)
    y_rr    <= cbin & op1(N-1 downto 1);


    -- output assignment
    y_s     <= y_sum    when (cmd_add or cmd_sub)='1'  else
               y_and    when cmd_and    ='1' else
               y_or     when cmd_or     ='1' else
               y_xor    when cmd_xor    ='1' else
               y_xnor   when cmd_xnor   ='1' else
               y_sll    when cmd_sll    ='1' else
               y_srl    when cmd_srl    ='1' else
               y_sra    when cmd_sra    ='1' else
               y_rl     when cmd_rl     ='1' else
               y_rr     when cmd_rr     ='1' else
               (others=>'0');
    --           
    y       <= y_s;


    -- flags
    z       <=  '1' when unsigned(y_s)=0 else '0';
    --
    c       <=  c_chain(N) xor cmd_sub  when (cmd_add or cmd_sub)='1' else 
                op1(N-1)                when (cmd_sll or cmd_rl)='1' else
                op1(0)                  when (cmd_srl or cmd_sra or cmd_rr)='1' else
                '0';
    --
    v       <=  c_chain(N) xor c_chain(N-1) when (cmd_add or cmd_sub)='1' else '0';
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
