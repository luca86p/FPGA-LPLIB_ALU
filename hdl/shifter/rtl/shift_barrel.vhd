-- =============================================================================
-- Whatis        : barrel shifter
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : shift_barrel.vhd
-- Language      : VHDL-93
-- Module        : shift_barrel
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
-- 2015-06-05  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity shift_barrel is
    generic (
        RST_POL : std_logic := '0';
        USE_REG : integer range 0 to 1 := 0; -- buffered output
        N       : positive  := 8
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        en      : in  std_logic;
        di      : in  std_logic_vector(N-1 downto 0);
        shamt   : in  std_logic_vector(integer(CEIL(LOG2(real(N))))-1 downto 0); -- encoded
        lr      : in  std_logic;
        c2      : in  std_logic;
        do      : out std_logic_vector(N-1 downto 0)
    );
end shift_barrel;

architecture rtl of shift_barrel is

    signal shamt_i      : integer range 0 to N-1;
    signal di_un        : unsigned(N-1 downto 0);
    signal di_sg        :   signed(N-1 downto 0);

    signal do_s         : std_logic_vector(N-1 downto 0);
    signal do_p         : std_logic_vector(N-1 downto 0);

begin

    shamt_i     <= TO_INTEGER(unsigned(shamt));
    di_un       <= unsigned(di);
    di_sg       <=   signed(di);

    do_s <= std_logic_vector(SHIFT_LEFT (di_un, shamt_i)) when lr='0' else
            std_logic_vector(SHIFT_RIGHT(di_un, shamt_i)) when lr='1' and c2='0' else
            std_logic_vector(SHIFT_RIGHT(di_sg, shamt_i)); -- when lr='1' and c2='1';

    gen_USE_REG_0: if USE_REG=0 generate
        do_p <= do_s;
    end generate gen_USE_REG_0;

    gen_USE_REG_1: if USE_REG=1 generate
        proc_shift: process(clk,rst)
        begin
            if rst=RST_POL then
                do_p <= (others=>'0');
            elsif rising_edge(clk) then
                if en='1' then
                    do_p <= do_s;
                end if;
            end if;
        end process proc_shift;
    end generate gen_USE_REG_1;

    do  <= do_p;

end rtl;


architecture rtl2 of shift_barrel is

    signal shamt_i      : integer range 0 to N-1;

    type t_sh_matrix is array (0 to N-1) of std_logic_vector(N-1 downto 0);
    signal sh_matrix_l  : t_sh_matrix;
    signal sh_matrix_r  : t_sh_matrix;
    signal sh_matrix    : t_sh_matrix;

    signal new_msb      : std_logic;
    signal do_s         : std_logic_vector(N-1 downto 0);
    signal do_p         : std_logic_vector(N-1 downto 0);

begin

    sh_matrix_l(0) <= di;
    sh_matrix_r(0) <= di;

    new_msb        <= c2 and di(N-1);

    gen_sh_matrix_l: for i in 1 to N-1 generate
        sh_matrix_l(i)(N-1 downto i) <= di(N-1-i downto 0);
        sh_matrix_l(i)(i-1 downto 0) <= (others=>'0');
    end generate gen_sh_matrix_l;

    gen_sh_matrix_r: for i in 1 to N-1 generate
        sh_matrix_r(i)(N-1-i downto 0) <= di(N-1 downto i);
        sh_matrix_r(i)(N-1 downto N-i) <= (others=>new_msb);
    end generate gen_sh_matrix_r;

    sh_matrix   <= sh_matrix_l when lr='0' else sh_matrix_r;
    shamt_i     <= TO_INTEGER(unsigned(shamt));
    do_s        <= sh_matrix(shamt_i);

    gen_USE_REG_0: if USE_REG=0 generate
        do_p <= do_s;
    end generate gen_USE_REG_0;

    gen_USE_REG_1: if USE_REG=1 generate
        proc_shift: process(clk,rst)
        begin
            if rst=RST_POL then
                do_p <= (others=>'0');
            elsif rising_edge(clk) then
                if en='1' then
                    do_p <= do_s;
                end if;
            end if;
        end process proc_shift;
    end generate gen_USE_REG_1;

    do  <= do_p;

end rtl2;