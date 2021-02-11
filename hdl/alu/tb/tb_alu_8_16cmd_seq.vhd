-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_alu_8_16cmd_seq.vhd
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
    signal alu_8_op1        : std_logic_vector(N-1 downto 0);
    signal alu_8_op2        : std_logic_vector(N-1 downto 0);
    signal alu_8_cbin       : std_logic;
    --
    signal alu_8_cmd_add    : std_logic;
    signal alu_8_cmd_addc   : std_logic;
    signal alu_8_cmd_sub    : std_logic;
    signal alu_8_cmd_subb   : std_logic;
    signal alu_8_cmd_mul    : std_logic;
    signal alu_8_cmd_and    : std_logic;
    signal alu_8_cmd_or     : std_logic;
    signal alu_8_cmd_xor    : std_logic;
    signal alu_8_cmd_xnor   : std_logic;
    signal alu_8_cmd_sll    : std_logic;
    signal alu_8_cmd_srl    : std_logic;
    signal alu_8_cmd_sra    : std_logic;
    signal alu_8_cmd_rl     : std_logic;
    signal alu_8_cmd_rlc    : std_logic;
    signal alu_8_cmd_rr     : std_logic;
    signal alu_8_cmd_rrc    : std_logic;
    --
    signal alu_8_y          : std_logic_vector(N-1 downto 0); 
    signal alu_8_y_mul_l    : std_logic_vector(N-1 downto 0); 
    signal alu_8_y_ready    : std_logic; 
    --
    signal alu_8_z          : std_logic;
    signal alu_8_c          : std_logic;
    signal alu_8_v          : std_logic;
    signal alu_8_s          : std_logic;
    signal alu_8_p          : std_logic;

    -- cmd index
    constant IDX_ADD    : integer := 0;
    constant IDX_ADDC   : integer := 1;
    constant IDX_SUB    : integer := 2;
    constant IDX_SUBB   : integer := 3;
    constant IDX_MUL    : integer := 4;
    constant IDX_AND    : integer := 5;
    constant IDX_OR     : integer := 6;
    constant IDX_XOR    : integer := 7;
    constant IDX_XNOR   : integer := 8;
    constant IDX_SLL    : integer := 9;
    constant IDX_SRL    : integer := 10;
    constant IDX_SRA    : integer := 11;
    constant IDX_RL     : integer := 12;
    constant IDX_RLC    : integer := 13;
    constant IDX_RR     : integer := 14;
    constant IDX_RRC    : integer := 15;

    signal alu_8_cmd_join   : std_logic_vector(15 downto 0); 



    -- Drive Procedures
    -- ----------------------------------------
    procedure SWEEP_ALL_FUN (
        signal alu_8_cmd_join   : out std_logic_vector(15 downto 0);
        signal alu_8_y_ready    : in  std_logic
    ) is
    begin
        wait until rising_edge(clk);
        --
        alu_8_cmd_join <= x"0001";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"0002";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"0004";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"0008";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"0010";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"0020";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"0040";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"0080";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"0100";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"0200";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"0400";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"0800";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"1000";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"2000";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"4000";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        alu_8_cmd_join <= x"8000";
        wait until rising_edge(clk);
        wait until rising_edge(clk) and alu_8_y_ready='1';
        --
        wait until rising_edge(clk);
        --
    end procedure SWEEP_ALL_FUN;


    -- Sef-checking Procedures
    -- ----------------------------------------


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
    i_uut: entity lplib_alu.alu_8_16cmd_seq(rtl)
        generic map (
            RST_POL         => RST_POL          ,
            N               => N
        )
        port map (
            rst             => rst              ,
            clk             => clk              ,
            --
            op1             => alu_8_op1        ,
            op2             => alu_8_op2        ,
            cbin            => alu_8_cbin       ,
            --
            cmd_add         => alu_8_cmd_add    ,
            cmd_addc        => alu_8_cmd_addc   ,
            cmd_sub         => alu_8_cmd_sub    ,
            cmd_subb        => alu_8_cmd_subb   ,
            cmd_mul         => alu_8_cmd_mul    ,
            cmd_and         => alu_8_cmd_and    ,
            cmd_or          => alu_8_cmd_or     ,
            cmd_xor         => alu_8_cmd_xor    ,
            cmd_xnor        => alu_8_cmd_xnor   ,
            cmd_sll         => alu_8_cmd_sll    ,
            cmd_srl         => alu_8_cmd_srl    ,
            cmd_sra         => alu_8_cmd_sra    ,
            cmd_rl          => alu_8_cmd_rl     ,
            cmd_rlc         => alu_8_cmd_rlc    ,
            cmd_rr          => alu_8_cmd_rr     ,
            cmd_rrc         => alu_8_cmd_rrc    ,
            --
            y               => alu_8_y          ,
            y_mul_l         => alu_8_y_mul_l    ,
            y_ready         => alu_8_y_ready    ,
            --
            z               => alu_8_z          ,
            c               => alu_8_c          ,
            v               => alu_8_v          ,
            s               => alu_8_s          ,
            p               => alu_8_s       
        );


    alu_8_cmd_add   <=  alu_8_cmd_join(IDX_ADD );
    alu_8_cmd_addc  <=  alu_8_cmd_join(IDX_ADDC);
    alu_8_cmd_sub   <=  alu_8_cmd_join(IDX_SUB );
    alu_8_cmd_subb  <=  alu_8_cmd_join(IDX_SUBB);
    alu_8_cmd_mul   <=  alu_8_cmd_join(IDX_MUL );
    alu_8_cmd_and   <=  alu_8_cmd_join(IDX_AND );
    alu_8_cmd_or    <=  alu_8_cmd_join(IDX_OR  );
    alu_8_cmd_xor   <=  alu_8_cmd_join(IDX_XOR );
    alu_8_cmd_xnor  <=  alu_8_cmd_join(IDX_XNOR);
    alu_8_cmd_sll   <=  alu_8_cmd_join(IDX_SLL );
    alu_8_cmd_srl   <=  alu_8_cmd_join(IDX_SRL );
    alu_8_cmd_sra   <=  alu_8_cmd_join(IDX_SRA );
    alu_8_cmd_rl    <=  alu_8_cmd_join(IDX_RL  );
    alu_8_cmd_rlc   <=  alu_8_cmd_join(IDX_RLC );
    alu_8_cmd_rr    <=  alu_8_cmd_join(IDX_RR  );
    alu_8_cmd_rrc   <=  alu_8_cmd_join(IDX_RRC );
        

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
        alu_8_op1       <= (others=>'0');
        alu_8_op2       <= (others=>'0');
        alu_8_cbin      <= '0';
        alu_8_cmd_join  <= (others=>'0');
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
        alu_8_cbin      <= '0';
        for i in 0 to 2**N-1 loop
            alu_8_op1 <= std_logic_vector(TO_UNSIGNED(i,N));
            for j in 0 to 2**N-1 loop
                alu_8_op2 <= std_logic_vector(TO_UNSIGNED(j,N));
                SWEEP_ALL_FUN(alu_8_cmd_join, alu_8_y_ready);
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
        alu_8_cbin      <= '1';
        for i in 0 to 2**N-1 loop
            alu_8_op1 <= std_logic_vector(TO_UNSIGNED(i,N));
            for j in 0 to 2**N-1 loop
                alu_8_op2 <= std_logic_vector(TO_UNSIGNED(j,N));
                SWEEP_ALL_FUN(alu_8_cmd_join, alu_8_y_ready);
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
         
         
end beh;
