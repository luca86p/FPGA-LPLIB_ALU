-- =============================================================================
-- Whatis        : multiplier unsigned serial (a*b)
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : mul_un_ser_ab.vhd
-- Language      : VHDL-93
-- Module        : mul_un_ser_ab
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


--  req __/````XXXXXXXX\_____
--  ack ______/````````\_____
--     (start) (busy)  (ready)
--  clk   #1    #M


entity mul_un_ser_ab is
    generic (
        RST_POL : std_logic := '0';
        N       : positive := 4;
        M       : positive := 4
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        --
        a       : in  std_logic_vector(N-1 downto 0);
        b       : in  std_logic_vector(M-1 downto 0);
        z       : out std_logic_vector(N+M-1 downto 0);
        --
        req     : in  std_logic;
        ack     : out std_logic
    );
end mul_un_ser_ab;


architecture rtl of mul_un_ser_ab is

    signal ack_s    : std_logic;
    --
    signal busy_cnt : integer range 0 to M-1;
    --
    signal sum_a    : std_logic_vector(N-1 downto 0);
    signal sum_b    : std_logic_vector(N-1 downto 0);
    signal sum_cc   : std_logic_vector(N   downto 0);
    signal sum_s    : std_logic_vector(N-1 downto 0);
    --
    signal buf_a    : std_logic_vector(N-1 downto 0);
    --
    signal reg_H    : std_logic_vector(N-1 downto 0);
    signal reg_L    : std_logic_vector(M-1 downto 0);
    --
    signal lsbit_b  : std_logic;
    --
    constant all_zero_N : std_logic_vector(N-1 downto 0) := (others=>'0');
    constant all_zero_M : std_logic_vector(M-1 downto 0) := (others=>'0');

begin


    sum_cc(0)   <= '0';
    gen_adder: for i in 0 to N-1 generate
        sum_s(i)    <= sum_a(i) xor sum_b(i) xor sum_cc(i);
        sum_cc(i+1) <= (sum_a(i) and sum_b(i)) or ((sum_a(i) xor sum_b(i)) and sum_cc(i));
    end generate gen_adder;

    sum_a   <= buf_a when lsbit_b='1' else all_zero_N;
    lsbit_b <= reg_L(0);
    sum_b   <= reg_H;

    proc_buf_a: process (rst,clk)
    begin
        if rst=RST_POL then
            buf_a   <= (others=>'0');
        elsif rising_edge(clk) then
            if req='1' and ack_s='0' then
                buf_a   <= a;
            end if;
        end if;
    end process proc_buf_a;

    proc_reg_H: process (rst,clk)
    begin
        if rst=RST_POL then
            reg_H   <= (others=>'0');
        elsif rising_edge(clk) then
            if req='1' and ack_s='0' then
                reg_H   <= (others=>'0');
            elsif ack_s='1' then
                reg_H   <= sum_cc(N) & sum_s(N-1 downto 1);
            end if;
        end if;
    end process proc_reg_H;

    proc_reg_L: process (rst,clk)
    begin
        if rst=RST_POL then
            reg_L   <= (others=>'0');
        elsif rising_edge(clk) then
            if req='1' and ack_s='0' then
                reg_L   <= b;
            elsif ack_s='1' then -- shift
                reg_L(M-1)          <= sum_s(0);
                reg_L(M-2 downto 0) <= reg_L(M-1 downto 1);
            end if;
        end if;
    end process proc_reg_L;

    z <= reg_H & reg_L;


    -- timer for execution and ack
    proc_timing: process (rst,clk)
    begin
        if rst=RST_POL then
            busy_cnt    <= 0;
            ack_s       <= '0';
        elsif rising_edge(clk) then
            if req='1' and ack_s='0' then -- start
                ack_s       <= '1';
            elsif ack_s='1' then -- shift
                if busy_cnt=M-1 then -- ready
                    busy_cnt    <= 0;
                    ack_s       <= '0';
                else
                    busy_cnt    <= busy_cnt+1;
                end if;
            end if;
        end if;
    end process proc_timing;

    ack <= ack_s;



end rtl;
