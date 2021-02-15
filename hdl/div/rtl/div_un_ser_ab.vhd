-- =============================================================================
-- Whatis        : divider unsigned serial (a = qb + r)
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : div_un_ser_ab.vhd
-- Language      : VHDL-93
-- Module        : div_un_ser_ab
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


--  req __/````XXXXXXXXX\_____
--  rdy ``````\_________/`````
--        (start) (busy) (ready)
--  clk     #1      #N


entity div_un_ser_ab is
    generic (
        RST_POL : std_logic := '0';
        N       : positive := 4
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        --
        a       : in  std_logic_vector(N-1 downto 0);
        b       : in  std_logic_vector(N-1 downto 0);
        --
        q       : out std_logic_vector(N-1 downto 0);
        r       : out std_logic_vector(N-1 downto 0);
        --
        req     : in  std_logic;
        rdy     : out std_logic
    );
end div_un_ser_ab;

architecture rtl of div_un_ser_ab is

    signal busy         : std_logic;
    signal busy_last    : std_logic;
    signal busy_cnt     : integer range 0 to N-1;
    --
    signal sum_a    : std_logic_vector(N-1 downto 0);
    signal sum_b    : std_logic_vector(N-1 downto 0);
    signal sum_cc   : std_logic_vector(N   downto 0);
    signal sum_s    : std_logic_vector(N-1 downto 0);
    signal borrow   : std_logic;
    --
    signal buf_b    : std_logic_vector(N-1 downto 0);
    --
    signal reg_q    : std_logic_vector(N-1 downto 0);
    signal reg_r    : std_logic_vector(N-1 downto 0);

begin

    proc_buf_b: process (rst,clk)
    begin
        if rst=RST_POL then
            buf_b   <= (others=>'0');
        elsif rising_edge(clk) then
            if req='1' and busy='0' then
                buf_b   <= b;
            end if;
        end if;
    end process proc_buf_b;


    sum_cc(0)   <= '1';
    gen_subtractor: for i in 0 to N-1 generate
        sum_s(i)    <= sum_a(i) xor sum_b(i) xor sum_cc(i);
        sum_cc(i+1) <= (sum_a(i) and sum_b(i)) or ((sum_a(i) xor sum_b(i)) and sum_cc(i));
    end generate gen_subtractor;

    sum_a   <= reg_r;
    sum_b   <= not buf_b;
    borrow  <= not sum_cc(N);

    proc_reg_r: process (rst,clk)
    begin
        if rst=RST_POL then
            reg_r   <= (others=>'0');
        elsif rising_edge(clk) then
            if req='1' and busy='0' then -- first load
                reg_r(N-1 downto 1) <= (others=>'0');
                reg_r(0)            <= a(N-1);
            elsif busy='1' and busy_last='0' then -- during computation
                if borrow='1' then -- if borrow, hold and shift-in the next "a"-bit
                    reg_r   <= reg_r(N-2 downto 0) & reg_q(N-1);
                else -- otherwise take the rest and shift-in the next "a"-bit
                    reg_r   <= sum_s(N-2 downto 0) & reg_q(N-1);     
                end if;
            elsif busy='1' and busy_last='1' then -- last cycle we do not need the "pre-shift" to present the rest
                if borrow='1' then -- if borrow, hold
                    reg_r   <= reg_r;
                else -- otherwise take the rest
                    reg_r   <= sum_s;
                end if;
            end if;
        end if;
    end process proc_reg_r;

    r   <= reg_r;

    proc_reg_q: process (rst,clk)
    begin
        if rst=RST_POL then
            reg_q   <= (others=>'0');
        elsif rising_edge(clk) then
            if req='1' and busy='0' then  -- first load
                reg_q   <= a(N-2 downto 0) & '0';
            elsif busy='1' then -- during computation
                reg_q   <= reg_q(N-2 downto 0) & sum_cc(N); -- when not borrow, then the q-bit is 1
            end if;
        end if;
    end process proc_reg_q;

    q   <= reg_q;

    -- timer for execution 
    proc_timing: process (rst,clk)
    begin
        if rst=RST_POL then
            busy_cnt    <= 0;
            busy        <= '0';
        elsif rising_edge(clk) then
            if req='1' and busy='0' then -- start
                busy       <= '1';
            elsif busy='1' then
                if busy_cnt=N-1 then -- ready
                    busy_cnt    <= 0;
                    busy        <= '0';
                else
                    busy_cnt    <= busy_cnt+1;
                end if;
            end if;
        end if;
    end process proc_timing;

    busy_last   <= '1' when busy_cnt=N-1 else '0';

    rdy         <= not busy;


end rtl;
