-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_alu_1_addsub.vhd
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
--  Dump process
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


    -- Dump Process
    -- ----------------------------------------
    constant DUMP_FNAME  : string := "dump.log";
    file DUMP_F : TEXT open write_mode is DUMP_FNAME;


    -- Constant
    -- ----------------------------------------
    constant N       : positive := 4;


    -- Signals
    -- ----------------------------------------
    signal alu_1_op1        : std_logic_vector(N-1 downto 0);
    signal alu_1_op2        : std_logic_vector(N-1 downto 0);
    signal alu_1_cbin       : std_logic;
    signal alu_1_cmd_add    : std_logic;
    signal alu_1_cmd_sub    : std_logic;
    signal alu_1_y          : std_logic_vector(N-1 downto 0); 
    signal alu_1_z          : std_logic;
    signal alu_1_c          : std_logic;
    signal alu_1_v          : std_logic;
    signal alu_1_s          : std_logic;


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
    i_uut: entity lplib_alu.alu_1_addsub(rtl)
        generic map (
            N               => N
        )
        port map (
            op1             => alu_1_op1     ,
            op2             => alu_1_op2     ,
            cbin            => alu_1_cbin    ,
            cmd_add         => alu_1_cmd_add ,
            cmd_sub         => alu_1_cmd_sub ,
            y               => alu_1_y       ,
            z               => alu_1_z       ,
            c               => alu_1_c       ,
            v               => alu_1_v       ,
            s               => alu_1_s       
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
        alu_1_op1       <= (others=>'0');
        alu_1_op2       <= (others=>'0');
        alu_1_cbin      <= '0';
        alu_1_cmd_add   <= '0';
        alu_1_cmd_sub   <= '0';
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
        -- ======== cmd_add test
        tcase   <= 1;
        wait until rising_edge(clk);
        --
        alu_1_cmd_add   <= '1';
        alu_1_cmd_sub   <= '0';
        --
        alu_1_cbin      <= '0';
        for i in 0 to 2**N-1 loop
            alu_1_op1 <= std_logic_vector(TO_UNSIGNED(i,N));
            for j in 0 to 2**N-1 loop
                alu_1_op2 <= std_logic_vector(TO_UNSIGNED(j,N));
                wait until rising_edge(clk);
            end loop;
        end loop;
        --
        alu_1_cbin      <= '1';
        for i in 0 to 2**N-1 loop
            alu_1_op1 <= std_logic_vector(TO_UNSIGNED(i,N));
            for j in 0 to 2**N-1 loop
                alu_1_op2 <= std_logic_vector(TO_UNSIGNED(j,N));
                wait until rising_edge(clk);
            end loop;
        end loop;
        --
        --
        -- ======== cmd_sub test
        tcase   <= 2;
        wait until rising_edge(clk);
        --
        alu_1_cmd_add   <= '0';
        alu_1_cmd_sub   <= '1';
        --
        alu_1_cbin      <= '0';
        for i in 0 to 2**N-1 loop
            alu_1_op1 <= std_logic_vector(TO_UNSIGNED(i,N));
            for j in 0 to 2**N-1 loop
                alu_1_op2 <= std_logic_vector(TO_UNSIGNED(j,N));
                wait until rising_edge(clk);
            end loop;
        end loop;
        --
        alu_1_cbin      <= '1';
        for i in 0 to 2**N-1 loop
            alu_1_op1 <= std_logic_vector(TO_UNSIGNED(i,N));
            for j in 0 to 2**N-1 loop
                alu_1_op2 <= std_logic_vector(TO_UNSIGNED(j,N));
                wait until rising_edge(clk);
            end loop;
        end loop;
        --
        --
        --
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
        variable aux_int            : integer;
        --
        variable alu_1_cbin_int     : integer;
        variable alu_1_op1_int      : integer;
        variable alu_1_op2_int      : integer;
        variable alu_1_y_int        : integer;
        --
        variable ref_alu_1_y_int    : integer; 
        variable ref_alu_1_z        : std_logic;
        variable ref_alu_1_c        : std_logic;
        variable ref_alu_1_v        : std_logic;
        variable ref_alu_1_s        : std_logic;
        --
        variable check_err          : integer := 0;
    begin
        if tcase=-1 then -- update the error counter
            --
            check_err_counter   <= check_err;
            --
        elsif falling_edge(clk) and rst /= RST_POL then
            --
            --
            -- prepare the integer variables
            if alu_1_cbin='1' then
                alu_1_cbin_int  := 1;
            else
                alu_1_cbin_int  := 0;
            end if;
            --
            alu_1_op1_int   := TO_INTEGER(unsigned(alu_1_op1));
            alu_1_op2_int   := TO_INTEGER(unsigned(alu_1_op2));
            alu_1_y_int     := TO_INTEGER(unsigned(alu_1_y));
            --
            --
            -- ======== check operation: cmd_add
            if alu_1_cmd_add='1' then
                --
                -- expected references
                aux_int         :=  alu_1_op1_int + alu_1_op2_int + alu_1_cbin_int;
                ref_alu_1_y_int :=  aux_int mod 2**N;
                --
                if unsigned(alu_1_y)=0 then
                    ref_alu_1_z     := '1';
                else
                    ref_alu_1_z     := '0';
                end if;
                --
                if aux_int > (2**N)-1 then
                    ref_alu_1_c     := '1';
                else
                    ref_alu_1_c     := '0';
                end if;
                --
                aux_int := TO_INTEGER(signed(alu_1_op1)) + TO_INTEGER(signed(alu_1_op2)) + alu_1_cbin_int;
                if aux_int < -(2**(N-1)) or aux_int > (2**(N-1))-1 then
                    ref_alu_1_v     := '1';
                else
                    ref_alu_1_v     := '0';
                end if;
                --
                if aux_int mod 2**N >= 2**(N-1) then
                    ref_alu_1_s     := '1';
                else
                    ref_alu_1_s     := '0';
                end if;
                --
                -- check
                if alu_1_y_int /= ref_alu_1_y_int then
                    REPORT "expected alu_1_y " & integer'image(ref_alu_1_y_int) & " got " & integer'image(alu_1_y_int)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                if alu_1_z /= ref_alu_1_z then
                    REPORT "expected alu_1_z " & std_logic'image(ref_alu_1_z) & " got " & std_logic'image(alu_1_z)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                if alu_1_c /= ref_alu_1_c then
                    REPORT "expected alu_1_c " & std_logic'image(ref_alu_1_c) & " got " & std_logic'image(alu_1_c)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                if alu_1_v /= ref_alu_1_v then
                    REPORT "expected alu_1_v " & std_logic'image(ref_alu_1_v) & " got " & std_logic'image(alu_1_v)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                if alu_1_s /= ref_alu_1_s then
                    REPORT "expected alu_1_s " & std_logic'image(ref_alu_1_s) & " got " & std_logic'image(alu_1_s)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
            --
            --
            --
            -- ======== check operation: cmd_sub
            elsif alu_1_cmd_sub='1' then
                --
                -- expected references
                aux_int         :=  alu_1_op1_int - alu_1_op2_int - alu_1_cbin_int;
                ref_alu_1_y_int :=  aux_int mod 2**N;
                --
                if unsigned(alu_1_y)=0 then
                    ref_alu_1_z     := '1';
                else
                    ref_alu_1_z     := '0';
                end if;
                --
                if aux_int < 0 then
                    ref_alu_1_c     := '1';
                else
                    ref_alu_1_c     := '0';
                end if;
                --
                aux_int := TO_INTEGER(signed(alu_1_op1)) - TO_INTEGER(signed(alu_1_op2)) - alu_1_cbin_int;
                if aux_int < -(2**(N-1)) or aux_int > (2**(N-1))-1 then
                    ref_alu_1_v     := '1';
                else
                    ref_alu_1_v     := '0';
                end if;
                --
                if aux_int mod 2**N >= 2**(N-1) then
                    ref_alu_1_s     := '1';
                else
                    ref_alu_1_s     := '0';
                end if;
                --
                -- check
                if alu_1_y_int /= ref_alu_1_y_int then
                    REPORT "expected alu_1_y " & integer'image(ref_alu_1_y_int) & " got " & integer'image(alu_1_y_int)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                if alu_1_z /= ref_alu_1_z then
                    REPORT "expected alu_1_z " & std_logic'image(ref_alu_1_z) & " got " & std_logic'image(alu_1_z)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                if alu_1_c /= ref_alu_1_c then
                    REPORT "expected alu_1_c " & std_logic'image(ref_alu_1_c) & " got " & std_logic'image(alu_1_c)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                if alu_1_v /= ref_alu_1_v then
                    REPORT "expected alu_1_v " & std_logic'image(ref_alu_1_v) & " got " & std_logic'image(alu_1_v)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                if alu_1_s /= ref_alu_1_s then
                    REPORT "expected alu_1_s " & std_logic'image(ref_alu_1_s) & " got " & std_logic'image(alu_1_s)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
            --
            --
            --
            -- ======== check operation: null
            else
                -- expected references
                ref_alu_1_y_int := 0;
                ref_alu_1_z     := '1';
                ref_alu_1_c     := '0';
                ref_alu_1_v     := '0';
                ref_alu_1_s     := '0';
                --
                -- check
                if alu_1_y_int /= ref_alu_1_y_int then
                    REPORT "expected alu_1_y " & integer'image(ref_alu_1_y_int) & " got " & integer'image(alu_1_y_int)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                if alu_1_z /= ref_alu_1_z then
                    REPORT "expected alu_1_z " & std_logic'image(ref_alu_1_z) & " got " & std_logic'image(alu_1_z)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                if alu_1_c /= ref_alu_1_c then
                    REPORT "expected alu_1_c " & std_logic'image(ref_alu_1_c) & " got " & std_logic'image(alu_1_c)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                if alu_1_v /= ref_alu_1_v then
                    REPORT "expected alu_1_v " & std_logic'image(ref_alu_1_v) & " got " & std_logic'image(alu_1_v)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                if alu_1_s /= ref_alu_1_s then
                    REPORT "expected alu_1_s " & std_logic'image(ref_alu_1_s) & " got " & std_logic'image(alu_1_s)
                    SEVERITY ERROR;
                    check_err := check_err + 1;
                end if;
                --
                --
                --
                --
            end if;
            --
            --
            --
            --
        end if;

    end process proc_check;




    -- Dump Process (on clk falling edge)
    -- ----------------------------------------
    proc_dump: process(clk, rst)
        variable wrline     : line ;
	    variable clk_cnt    : integer := 0;
    begin    
        if falling_edge(clk) and rst /= RST_POL then
            clk_cnt := clk_cnt+1;
            --
            write(wrline, NOW); -- runtime stamp
            write(wrline, string'(" "));
            --
            --write(wrline, integer'image(clk_cnt));
	        --write(wrline, string'(" "));
            --
	        write(wrline, string'(" alu_1_op1 0x"));
	        hwrite(wrline, alu_1_op1);
	        write(wrline, string'(" alu_1_op2 0x"));
	        hwrite(wrline, alu_1_op2);
	        write(wrline, string'(" alu_1_cbin 0x"));
	        write(wrline, alu_1_cbin);
	        write(wrline, string'(" alu_1_cmd_add 0x"));
	        write(wrline, alu_1_cmd_add);
	        write(wrline, string'(" alu_1_cmd_sub 0x"));
	        write(wrline, alu_1_cmd_sub);
	        write(wrline, string'(" alu_1_y 0x"));
	        hwrite(wrline, alu_1_y);
	        write(wrline, string'(" alu_1_z 0x"));
	        write(wrline, alu_1_z);
	        write(wrline, string'(" alu_1_c 0x"));
	        write(wrline, alu_1_c);
	        write(wrline, string'(" alu_1_v 0x"));
	        write(wrline, alu_1_v);
	        write(wrline, string'(" alu_1_s 0x"));
	        write(wrline, alu_1_s);
            --
            writeline(DUMP_F, wrline);
	    end if;
    end process proc_dump;

end beh;
