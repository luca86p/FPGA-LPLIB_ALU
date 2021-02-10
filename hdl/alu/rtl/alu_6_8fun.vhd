-- =============================================================================
-- Whatis        : combinational alu
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : alu_6_8fun.vhd
-- Language      : VHDL-93
-- Module        : alu_6_8fun
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


entity alu_6_8fun is
    generic (
        N           : positive := 4
    );
    port (
        op1         : in  std_logic_vector (N-1 downto 0);
        op2         : in  std_logic_vector (N-1 downto 0);
        cbin        : in  std_logic;
        --
        cmd_f       : in  std_logic_vector(2 downto 0);
        --
        y           : out std_logic_vector(N-1 downto 0);
        --
        z           : out std_logic; -- zero
        c           : out std_logic; -- carry
        v           : out std_logic; -- c2 overflow
        s           : out std_logic; -- sign
        p           : out std_logic  -- even parity
    );
end alu_6_8fun;

architecture rtl of alu_6_8fun is

    --
    signal op1_s        : std_logic_vector(N-1 downto 0);
    signal op2_s        : std_logic_vector(N-1 downto 0);
    signal c_chain      : std_logic_vector(N   downto 0);
    --
    signal y_sum        : std_logic_vector(N-1 downto 0);
    signal y_and        : std_logic_vector(N-1 downto 0);
    signal y_or         : std_logic_vector(N-1 downto 0);
    signal y_srl        : std_logic_vector(N-1 downto 0);
    signal y_sra        : std_logic_vector(N-1 downto 0);
    signal y_sr         : std_logic_vector(N-1 downto 0);
    --
    signal y_s          : std_logic_vector(N-1 downto 0);

    -- alias "signals"
    signal cmd_f_1_0    : std_logic_vector(1 downto 0);

begin

    -- cmd_f = "000"  : cmd_and     (op1 & op2)
    -- cmd_f = "001"  : cmd_or      (op1 | op2)
    -- cmd_f = "010"  : cmd_add     (op1 + op2)
    -- cmd_f = "011"  : cmd_srl     (op1 >> 1 (insert 0))
    -- cmd_f = "100"  : cmd_and*    (op1 & !op2)
    -- cmd_f = "101"  : cmd_or*     (op1 | !op2)
    -- cmd_f = "110"  : cmd_sub     (op1 - op2)
    -- cmd_f = "111"  : cmd_sra     (op1 >> 1 (insert MSB))

    -- op1, op2 pre-logic
    op1_s       <= op1;
    op2_s       <= op2 when cmd_f(2)='0' else (not op2);
    
    -- sum functions: adder "subtractor"
    c_chain(0)  <= cbin xor cmd_f(2);
    
    -- adder
    gen_adder: for i in 0 to N-1 generate
        y_sum(i)        <= op1_s(i) xor op2_s(i) xor c_chain(i);
        c_chain(i+1)    <= (op1_s(i) and op2_s(i)) or ((op1_s(i) xor op2_s(i)) and c_chain(i));
    end generate gen_adder;

    -- logic functions
    y_and   <= op1_s and op2_s;
    y_or    <= op1_s  or op2_s;
   
    -- shift right
    -- logical    : op1_s >> 1 (insert 0)
    y_srl   <= '0' & op1(N-1 downto 1);
    -- arithmetic : op1_s >> 1 (insert MSB)
    y_sra   <= op1(N-1) & op1(N-1 downto 1);
    -- mux
    y_sr    <= y_srl when cmd_f(2)='0' else y_sra;


    -- alias assignment
    cmd_f_1_0   <= cmd_f(1 downto 0);

    -- output assignment
    y_s     <= y_and    when cmd_f_1_0="00"  else
               y_or     when cmd_f_1_0="01"  else
               y_sum    when cmd_f_1_0="10"  else
               y_sr     when cmd_f_1_0="11"  else
               (others=>'X'); -- what does the synthesizer? (maybe delete the line)
    --           
    y       <= y_s;


    -- flags
    z       <=  '1' when unsigned(y_s)=0 else '0';
    --
    c       <=  c_chain(N) xor cmd_f(2) when cmd_f(0)='0' else 
                op1(0)                  when cmd_f(0)='1' else
                'X'; -- what does the synthesizer? (maybe delete the line)
    --
    v       <=  c_chain(N) xor c_chain(N-1);
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
