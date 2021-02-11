-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_alu_2_4fun.vhd
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
--  Procedure to sweep all functions
--  Procedure to check all results
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


    -- Signals
    -- ----------------------------------------
    signal alu_2_op1        : std_logic_vector(N-1 downto 0);
    signal alu_2_op2        : std_logic_vector(N-1 downto 0);
    signal alu_2_cbin       : std_logic;
    signal alu_2_fun        : std_logic_vector(1 downto 0);
    signal alu_2_y          : std_logic_vector(N-1 downto 0); 
    signal alu_2_z          : std_logic;
    signal alu_2_c          : std_logic;
    signal alu_2_v          : std_logic;
    signal alu_2_s          : std_logic;



    -- Drive Procedures
    -- ----------------------------------------
    -- fun = "00"  : cmd_add
    -- fun = "01"  : cmd_sub
    -- fun = "10"  : cmd_and
    -- fun = "11"  : cmd_or
    procedure SWEEP_ALL_FUN (
        signal alu_fun : out std_logic_vector(1 downto 0)
    ) is
    begin
        alu_fun     <= "00";
        wait until rising_edge(clk);
        alu_fun     <= "01";
        wait until rising_edge(clk);
        alu_fun     <= "10";
        wait until rising_edge(clk);
        alu_fun     <= "11";
        wait until rising_edge(clk);
    end procedure SWEEP_ALL_FUN;


    -- Sef-checking Procedures
    -- ----------------------------------------
    -- fun = "00"  : cmd_add
    -- fun = "01"  : cmd_sub
    -- fun = "10"  : cmd_and
    -- fun = "11"  : cmd_or
    procedure CHECK_FUN (
        signal alu_2_op1        : in std_logic_vector(N-1 downto 0);
        signal alu_2_op2        : in std_logic_vector(N-1 downto 0);
        signal alu_2_cbin       : in std_logic;
        signal alu_2_fun        : in std_logic_vector(1 downto 0);
        signal alu_2_y          : in std_logic_vector(N-1 downto 0); 
        signal alu_2_z          : in std_logic;
        signal alu_2_c          : in std_logic;
        signal alu_2_v          : in std_logic;
        signal alu_2_s          : in std_logic;
        --
        variable err            : out integer
    ) is
        variable aux_int        : integer;
        variable aux_std_logic  : integer;
        variable check_err      : integer;
    begin
        --
        check_err := 0;
        --
        -- ======== fun independent checks
        --
        -- zero flag
        if TO_INTEGER(unsigned(alu_2_y)) = 0 then
            if alu_2_z /= '1' then
                REPORT "expected alu_2_z '1' got " & std_logic'image(alu_2_z)
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
        end if;
        --
        -- ======== fun dependent checks
        --
        if alu_2_fun="00" then -- cmd_add
            --
            -- unconstrained operation
            aux_int     :=  TO_INTEGER(unsigned(alu_2_op1)) + TO_INTEGER(unsigned(alu_2_op2));
            if alu_2_cbin='1' then
                aux_int     := aux_int + 1;
            end if;
            -- carry flag
            if aux_int > (2**N)-1 then
                if alu_2_c /= '1' then
                    REPORT "expected alu_2_c '1' got " & std_logic'image(alu_2_c)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
            end if;
            -- N-bit operation
            aux_int     :=  aux_int mod 2**N;
            -- correct add value
            if TO_INTEGER(unsigned(alu_2_y)) /= aux_int then
                REPORT "expected alu_2_y " & integer'image(aux_int) & " got " & integer'image(TO_INTEGER(unsigned(alu_2_y)))
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
            -- sign flag
            if TO_INTEGER(unsigned(alu_2_y)) >= 2**(N-1) then
                if alu_2_s /= '1' then
                    REPORT "expected alu_2_s '1' got " & std_logic'image(alu_2_s)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
            end if;
            -- unconstrained operation
            aux_int     :=  TO_INTEGER(signed(alu_2_op1)) + TO_INTEGER(signed(alu_2_op2));
            if alu_2_cbin='1' then
                aux_int     := aux_int + 1;
            end if;
            -- c2 overflow flag
            if aux_int < -(2**(N-1)) or aux_int > (2**(N-1))-1 then
                if alu_2_v /= '1' then
                    REPORT "expected alu_2_v '1' got " & std_logic'image(alu_2_v)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
            end if;
            --
        elsif alu_2_fun="01" then -- cmd_sub
            --
            -- unconstrained operation
            aux_int     :=  TO_INTEGER(unsigned(alu_2_op1)) - TO_INTEGER(unsigned(alu_2_op2));
            if alu_2_cbin='1' then
                aux_int     := aux_int - 1;
            end if;
            -- borrow flag
            if aux_int < 0 then
                if alu_2_c /= '1' then
                    REPORT "expected alu_2_c '1' got " & std_logic'image(alu_2_c)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
            end if;
            -- N-bit operation
            aux_int     :=  aux_int mod 2**N;
            -- correct sub value
            if TO_INTEGER(unsigned(alu_2_y)) /= aux_int then
                REPORT "expected alu_2_y " & integer'image(aux_int) & " got " & integer'image(TO_INTEGER(unsigned(alu_2_y)))
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
            -- sign flag
            if TO_INTEGER(unsigned(alu_2_y)) >= 2**(N-1) then
                if alu_2_s /= '1' then
                    REPORT "expected alu_2_s '1' got " & std_logic'image(alu_2_s)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
            end if;
            -- unconstrained operation
            aux_int     :=  TO_INTEGER(signed(alu_2_op1)) - TO_INTEGER(signed(alu_2_op2));
            if alu_2_cbin='1' then
                aux_int     := aux_int - 1;
            end if;
            -- c2 overflow flag
            if aux_int < -(2**(N-1)) or aux_int > (2**(N-1))-1 then
                if alu_2_v /= '1' then
                    REPORT "expected alu_2_v '1' got " & std_logic'image(alu_2_v)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
            end if;
            --
        elsif alu_2_fun="10" then -- cmd_and
            --
            -- carry flag
            if alu_2_c /= '0' then
                REPORT "expected alu_2_c '0' got " & std_logic'image(alu_2_c)
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
            -- correct and value
            if alu_2_y /= (alu_2_op1 and alu_2_op2) then
                REPORT "expected alu_2_y " & integer'image(TO_INTEGER(unsigned(alu_2_op1 and alu_2_op2))) & " got " & integer'image(TO_INTEGER(unsigned(alu_2_y)))
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
            -- sign flag
            if TO_INTEGER(unsigned(alu_2_y)) >= 2**(N-1) then
                if alu_2_s /= '1' then
                    REPORT "expected alu_2_s '1' got " & std_logic'image(alu_2_s)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
            end if;
            -- c2 overflow flag
            if alu_2_v /= '0' then
                REPORT "expected alu_2_v '0' got " & std_logic'image(alu_2_v)
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
            --
        elsif alu_2_fun="11" then -- cmd_or
            --
            -- carry flag
            if alu_2_c /= '0' then
                REPORT "expected alu_2_c '0' got " & std_logic'image(alu_2_c)
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
            -- correct or value
            if alu_2_y /= (alu_2_op1 or alu_2_op2) then
                REPORT "expected alu_2_y " & integer'image(TO_INTEGER(unsigned(alu_2_op1 and alu_2_op2))) & " got " & integer'image(TO_INTEGER(unsigned(alu_2_y)))
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
            -- sign flag
            if TO_INTEGER(unsigned(alu_2_y)) >= 2**(N-1) then
                if alu_2_s /= '1' then
                    REPORT "expected alu_2_s '1' got " & std_logic'image(alu_2_s)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
            end if;
            -- c2 overflow flag
            if alu_2_v /= '0' then
                REPORT "expected alu_2_v '0' got " & std_logic'image(alu_2_v)
                SEVERITY ERROR;
                check_err := check_err + 1;
            end if;
            --
        end if;
        --
        err := check_err;
        --
    end procedure CHECK_FUN;


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
    i_uut: entity lplib_alu.alu_2_4fun(rtl)
        generic map (
            N               => N
        )
        port map (
            op1             => alu_2_op1     ,
            op2             => alu_2_op2     ,
            cbin            => alu_2_cbin    ,
            fun             => alu_2_fun     ,
            y               => alu_2_y       ,
            z               => alu_2_z       ,
            c               => alu_2_c       ,
            v               => alu_2_v       ,
            s               => alu_2_s       
        );





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
        alu_2_op1       <= (others=>'0');
        alu_2_op2       <= (others=>'0');
        alu_2_cbin      <= '0';
        alu_2_fun       <= "00";
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
        --
        -- 
        -- ======== test all func each ops: cbin 0
        tcase           <= 1;
        wait until rising_edge(clk);
        --
        alu_2_cbin      <= '0';
        for i in 0 to 2**N-1 loop
            alu_2_op1 <= std_logic_vector(TO_UNSIGNED(i,N));
            for j in 0 to 2**N-1 loop
                alu_2_op2 <= std_logic_vector(TO_UNSIGNED(j,N));
                SWEEP_ALL_FUN(alu_2_fun);
            end loop;
        end loop;
        --
        wait for 1 us;
        wait until rising_edge(clk);
        --
        --
        -- ======== test all func each ops: cbin 1
        tcase           <= 2;
        wait until rising_edge(clk);
        --
        alu_2_cbin      <= '1';
        for i in 0 to 2**N-1 loop
            alu_2_op1 <= std_logic_vector(TO_UNSIGNED(i,N));
            for j in 0 to 2**N-1 loop
                alu_2_op2 <= std_logic_vector(TO_UNSIGNED(j,N));
                SWEEP_ALL_FUN(alu_2_fun);
            end loop;
        end loop;
        --
        wait for 1 us;
        wait until rising_edge(clk);
        --
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



    -- Check Process (on clk falling edge)
    -- ----------------------------------------
    proc_check: process(clk, rst)
        --
        variable err                : integer := 0;
        variable check_err          : integer := 0;
        --
    begin
        if tcase=-1 then -- update the error counter
            --
            check_err_counter   <= check_err;
            --
        elsif falling_edge(clk) and rst /= RST_POL then
            CHECK_FUN(  alu_2_op1 ,
                        alu_2_op2 ,
                        alu_2_cbin ,
                        alu_2_fun ,
                        alu_2_y ,
                        alu_2_z ,
                        alu_2_c ,
                        alu_2_v ,
                        alu_2_s ,
                        err );
            --
            check_err   := check_err + err;
            --
        end if;
    end process proc_check;
     
         
end beh;
