-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_mul_un_ser.vhd
-- Language      : VHDL-93
-- Module        : tb
-- Library       : lplib_alu_verif
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  Self-checking testbench
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


-- STD lib
-- ----------------------------------------
use std.textio.all;

-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;

-- User lib
-- ----------------------------------------
library lplib_alu;


entity tb is
end entity tb;

architecture beh of tb is

    -- TB common parameters and signals
    -- ----------------------------------------
    constant RST_POL    : std_logic := '0';
    constant CLK_FREQ   : positive := 50000000; -- 50 MHz (20 ns)
    -- constant CLK_FREQ   : positive := 33000000; -- 33 MHz (30.303 ns)
    -- constant CLK_FREQ   : positive := 25000000; -- 25 MHz (40 ns)
    -- constant CLK_FREQ   : positive := 20000000; -- 20 MHz (50 ns)
    -- constant CLK_FREQ   : positive := 10000000; -- 10 MHz (100 ns)
    --
    constant TCLK       : time := 1.0e10/real(CLK_FREQ) * (0.1 ns); -- clock period
    constant DUTYCLK    : real := 0.5; -- clock duty-cycle

    signal en_clk       : std_logic;
    --
    signal clk          : std_logic := '0';
    signal rst          : std_logic := RST_POL;
    --
    signal tcase        : integer := 0;


    -- Check Process
    -- ----------------------------------------
    signal err_counter          : integer   := 0;
    signal check_err_counter    : integer   := 0;


   -- Constant
    -- ----------------------------------------
    constant N       : positive := 4;
    constant M       : positive := 4;


    -- Signals
    -- ----------------------------------------
    signal a            : std_logic_vector(N-1 downto 0);
    signal b            : std_logic_vector(M-1 downto 0);
    --
    signal z            : std_logic_vector(N+M-1 downto 0);
    --
    signal req          : std_logic;
    signal ack          : std_logic;


    -- Verification
    ----------------------------------------
    signal z_un      : unsigned(N+M-1 downto 0);
      
      
begin       

      -- clock generator 50%
      -- ----------------------------------------
      clk <= not clk after TCLK/2 when en_clk='1' else '0';
    
    
      -- clock generator DUTYCLK% 
      -- ----------------------------------------
      -- proc_clk: process(clk, en_clk)
      -- begin
      --     if en_clk='1' then
      --         if clk='0' then
      --             clk <= '1' after TCLK*(1.0-DUTYCLK);
      --         else
      --             clk <= '0' after TCLK*DUTYCLK;
      --         end if;
      --     else
      --         clk <= '0'
      --     end if;
      -- end process proc_clk;


      

    -- Unit(s) Under Test
    -- ----------------------------------------
    i_uut: entity lplib_alu.mul_un_ser_ab(rtl)
        generic map (
            N       => N    ,
            M       => M
        )
        port map (
            clk     => clk  ,
            rst     => rst  ,
            a       => a    ,
            b       => b    ,
            z       => z    ,
            req     => req  ,
            ack     => ack
        );
    
    z_un  <= unsigned(z);




    -- Drive Process
    -- ----------------------------------------   
    proc_drive: process
    begin
        -- ========
        tcase       <= 0;
        --
        en_clk      <= '0';
        rst         <= RST_POL;
        --
        --
        a   <= std_logic_vector(TO_UNSIGNED(0,N));
        b   <= std_logic_vector(TO_UNSIGNED(0,M));
        req <= '0';
        --
        --
        wait for 123 ns;
        en_clk     <= '1';
        wait for 123 ns;
        wait until falling_edge(clk);
        -- reset release
        rst        <= not RST_POL;
        wait for 123 ns;
        wait until rising_edge(clk);
        --
        --
        -- ======== test all combination
        tcase           <= 1;
        wait until rising_edge(clk);
        --
        for i in 0 to 2**N-1 loop
            a   <= std_logic_vector(TO_UNSIGNED(i,N));
            for j in 0 to 2**M-1 loop
                b   <= std_logic_vector(TO_UNSIGNED(j,M));
                req <= '1';
                wait until rising_edge(clk);
                req <= '0';
                wait until rising_edge(clk) and ack='0'; -- like "busy"
                --
                if z_un /= i*j then
                    REPORT "expected z " & integer'image(i*j) & " got " & integer'image(TO_INTEGER(z_un))
                    SEVERITY ERROR;
                    err_counter <= err_counter + 1;
                end if;
            end loop;
        end loop;
        --
        wait for 1 us;
        wait until rising_edge(clk);
        --
        -- ======== Power Off
        tcase   <= -1;
        wait until rising_edge(clk);
        --
        wait for 333 ns;
        wait until rising_edge(clk);
        rst        <= '0';
        wait for 333 ns;
        en_clk     <= '0';
        wait for 333 ns;
        --
        err_counter <= err_counter + check_err_counter;
        wait for 333 ns;
        --
        if err_counter /= 0 then
            REPORT "... ==|[ TEST FAILED ]|== ...";
        else
            REPORT "... ==|[ TEST SUCCESS ]|== ...";
        end if;
        REPORT "... ==|[ err_counter: " & integer'image(err_counter) & " ]|== ...";
        --
        -- ASSERT FALSE
        --     REPORT "... ==|[ proc_drive: SIMULATION END ]|== ..."
        --         SEVERITY FAILURE;
        --
        REPORT "... ==|[ proc_drive: SIMULATION END ]|== ...";
        --
        wait;
    end process proc_drive;


end beh;
