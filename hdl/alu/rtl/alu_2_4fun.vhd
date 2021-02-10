-- =============================================================================
-- Whatis        : combinational alu
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : alu_2_4fun.vhd
-- Language      : VHDL-93
-- Module        : alu_2_4fun
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


entity alu_2_4fun is
    generic (
        N           : positive := 4
    );
    port (
        op1         : in  std_logic_vector(N-1 downto 0);
        op2         : in  std_logic_vector(N-1 downto 0);
        cbin        : in  std_logic;
        --
        fun         : in  std_logic_vector(1 downto 0);
        --
        y           : out std_logic_vector(N-1 downto 0);
        --
        z           : out std_logic; -- zero
        c           : out std_logic; -- carry
        v           : out std_logic; -- c2 overflow
        s           : out std_logic  -- sign
    );
end entity alu_2_4fun;

architecture rtl of alu_2_4fun is

    signal c_chain      : std_logic_vector(N   downto 0);
    --
    signal op1_s        : std_logic_vector(N-1 downto 0);
    signal op2_s        : std_logic_vector(N-1 downto 0);
    --
    signal y_sum        : std_logic_vector(N-1 downto 0);
    signal y_and        : std_logic_vector(N-1 downto 0);
    signal y_or         : std_logic_vector(N-1 downto 0);
    --
    signal y_s          : std_logic_vector(N-1 downto 0);
  
begin

    -- fun = "00"  : cmd_add
    -- fun = "01"  : cmd_sub
    -- fun = "10"  : cmd_and
    -- fun = "11"  : cmd_or

    -- sum functions: adder subtractor
    c_chain(0)  <= cbin xor fun(0);
    op1_s       <= op1;
    op2_s       <= op2 when fun(0)='0' else (not op2);
    --
    gen_adder: for i in 0 to N-1 generate
        y_sum(i)        <= op1_s(i) xor op2_s(i) xor c_chain(i);
        c_chain(i+1)    <= (op1_s(i) and op2_s(i)) or ((op1_s(i) xor op2_s(i)) and c_chain(i));
    end generate gen_adder;

    -- logic functions
    y_and   <= op1 and op2;
    y_or    <= op1  or op2;
  
    -- output assignment
    y_s     <= y_sum when fun(1)='0' else
               y_and when fun(0)='0' else
               y_or;
    --           
    y       <= y_s;

    -- flags
    z       <= '1' when unsigned(y_s)=0 else '0';
    c       <=  c_chain(N) xor fun(0) when fun(1)='0' else '0';
    v       <=  c_chain(N) xor c_chain(N-1) when fun(1)='0' else '0';
    s       <=  y_s(N-1);

end rtl;