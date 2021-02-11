-- =============================================================================
-- Whatis        : sequential alu
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : alu_8_16cmd_seq.vhd
-- Language      : VHDL-93
-- Module        : alu_8_16cmd_seq
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


entity alu_8_16cmd_seq is
    generic (
        RST_POL     : std_logic := '0';
        N           : positive := 4
    );
    port (
        rst         : in  std_logic;
        clk         : in  std_logic;
        --
        op1         : in  std_logic_vector (N-1 downto 0);
        op2         : in  std_logic_vector (N-1 downto 0);
        cbin        : in  std_logic;
        --
        cmd_add     : in  std_logic; -- op1 + op2               z c v s p
        cmd_addc    : in  std_logic; -- op1 + op2 + cbin        z c v s p
        cmd_sub     : in  std_logic; -- op1 - op2               z c v s p
        cmd_subb    : in  std_logic; -- op1 - op2 - cbin        z c v s p
        cmd_mul     : in  std_logic; -- op1 * op2 unsigned      z - - s p
        --
        cmd_and     : in  std_logic; -- op1 and  op2            z - - s p
        cmd_or      : in  std_logic; -- op1 or   op2            z - - s p
        cmd_xor     : in  std_logic; -- op1 xor  op2            z - - s p
        cmd_xnor    : in  std_logic; -- op1 xnor op2            z - - s p
        --
        cmd_sll     : in  std_logic; -- op1 << 1 (ins 0)        z c - s p
        cmd_srl     : in  std_logic; -- op1 >> 1 (ins 0)        z c - s p
        cmd_sra     : in  std_logic; -- op1 >> 1 (ins MSB)      z c - s p
        --
        cmd_rl      : in  std_logic; -- op1 << 1 (ins MSB)      z - - s p
        cmd_rlc     : in  std_logic; -- op1 << 1 (ins cbin)     z c - s p
        cmd_rr      : in  std_logic; -- op1 >> 1 (ins LSB)      z - - s p
        cmd_rrc     : in  std_logic; -- op1 >> 1 (ins cbin)     z c - s p
        --
        y           : out std_logic_vector(N-1 downto 0); -- all result (high part of mul)
        y_mul_l     : out std_logic_vector(N-1 downto 0); -- the low part of mul
        y_ready     : out std_logic; -- the valid flag of y result
        --
        z           : out std_logic; -- zero
        c           : out std_logic; -- carry
        v           : out std_logic; -- c2 overflow
        s           : out std_logic; -- sign
        p           : out std_logic  -- even parity
    );
end alu_8_16cmd_seq;

architecture rtl of alu_8_16cmd_seq is

    -- constant
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

    -- buffers and timing
    signal op1_buf      : std_logic_vector(N-1 downto 0);
    signal op2_buf      : std_logic_vector(N-1 downto 0);
    signal cbin_buf     : std_logic;
    signal cmd_join     : std_logic_vector( 15 downto 0);
    signal cmd_buf      : std_logic_vector( 15 downto 0);
    --
    signal cmd_timer    : integer range 0 to N-1;
    signal cmd_busy     : std_logic;

    -- adder subtractor
    signal c_chain      : std_logic_vector(N   downto 0);
    --
    signal op1_s        : std_logic_vector(N-1 downto 0);
    signal op2_s        : std_logic_vector(N-1 downto 0);
    --
    signal y_sum        : std_logic_vector(N-1 downto 0);

    -- multiplier serial
    -- z = a*b
    --                                  v=======\
    -- ==> op1 -> [op1_buf] === and ==> + ==> [reg_h]
    -- ==> op2 -> [reg_l]  -----^       |LSB
    --            ^--------------------/
    --
    signal mul_sum          : std_logic_vector(N-1 downto 0);
    signal mul_sum_op1      : std_logic_vector(N-1 downto 0);
    signal mul_sum_op2      : std_logic_vector(N-1 downto 0);
    signal mul_sum_cchain   : std_logic_vector(N   downto 0);
    --
    signal reg_h        : std_logic_vector(N-1 downto 0);
    signal y_mul_h      : std_logic_vector(N-1 downto 0);
    signal reg_l        : std_logic_vector(N-1 downto 0);

    -- logic functions
    signal y_and        : std_logic_vector(N-1 downto 0);
    signal y_or         : std_logic_vector(N-1 downto 0);
    signal y_xor        : std_logic_vector(N-1 downto 0);
    signal y_xnor       : std_logic_vector(N-1 downto 0);

    -- shift/rotate functions
    signal y_sll        : std_logic_vector(N-1 downto 0);
    signal y_srl        : std_logic_vector(N-1 downto 0);
    signal y_sra        : std_logic_vector(N-1 downto 0);
    --
    signal y_rl         : std_logic_vector(N-1 downto 0);
    signal y_rlc        : std_logic_vector(N-1 downto 0);
    signal y_rr         : std_logic_vector(N-1 downto 0);
    signal y_rrc        : std_logic_vector(N-1 downto 0);
    
    -- output
    signal y_s          : std_logic_vector(N-1 downto 0);
    signal y_outreg     : std_logic_vector(N-1 downto 0);

    signal z_flag       : std_logic;
    signal c_flag       : std_logic;
    signal v_flag       : std_logic;
    signal s_flag       : std_logic;
    signal p_flag       : std_logic;
    signal z_s          : std_logic;
    signal c_s          : std_logic;
    signal v_s          : std_logic;
    signal s_s          : std_logic;
    signal p_s          : std_logic;

begin


    -- control, timing and buffering
    -- ------------------------------------------------------------------
    cmd_join(IDX_ADD )  <= cmd_add;
    cmd_join(IDX_ADDC)  <= cmd_addc;
    cmd_join(IDX_SUB )  <= cmd_sub;
    cmd_join(IDX_SUBB)  <= cmd_subb;
    cmd_join(IDX_MUL )  <= cmd_mul;
    cmd_join(IDX_AND )  <= cmd_and;
    cmd_join(IDX_OR  )  <= cmd_or;
    cmd_join(IDX_XOR )  <= cmd_xor;
    cmd_join(IDX_XNOR)  <= cmd_xnor;
    cmd_join(IDX_SLL )  <= cmd_sll;
    cmd_join(IDX_SRL )  <= cmd_srl;
    cmd_join(IDX_SRA )  <= cmd_sra;
    cmd_join(IDX_RL  )  <= cmd_rl;
    cmd_join(IDX_RLC )  <= cmd_rlc;
    cmd_join(IDX_RR  )  <= cmd_rr;
    cmd_join(IDX_RRC )  <= cmd_rrc;
    --
    proc_timing: process (rst,clk)
    begin
        if rst=RST_POL then
            op1_buf     <= (others=>'0');
            op2_buf     <= (others=>'0');
            cbin_buf    <= '0';
            cmd_buf     <= (others=>'0');
            --
            cmd_timer   <= 0;
            cmd_busy    <= '0';
        elsif rising_edge(clk) then
            if cmd_busy='0' then
                if unsigned(cmd_join) /= 0 then
                    op1_buf     <= op1;
                    op2_buf     <= op2;
                    cbin_buf    <= cbin;
                    cmd_buf     <= cmd_join;
                    cmd_busy    <= '1';
                end if;
            else -- cmd_busy='1'
                --
                cmd_timer   <= cmd_timer + 1;
                --
                case TO_INTEGER(unsigned(cmd_buf)) is
                    when 4 => -- cmd_mul
                        if cmd_timer=N-1 then -- ready
                            cmd_timer   <= 0;
                            cmd_busy    <= '0';
                        end if;
                    when others =>
                        cmd_timer   <= 0;
                        cmd_busy    <= '0';
                end case;
            end if;
        end if;
    end process proc_timing;

    y_ready <= not cmd_busy;

    -- adder subtractor: RippleCarryAdder like
    -- ------------------------------------------------------------------
    -- adder subtractor: carry/borrow in
    c_chain(0)  <=  '0'             when cmd_buf(IDX_ADD)  ='1' else
                    cbin_buf        when cmd_buf(IDX_ADDC) ='1' else
                    '1'             when cmd_buf(IDX_SUB)  ='1' else
                    not cbin_buf    when cmd_buf(IDX_SUBB) ='1' else
                    '0' ;

    -- adder subtractor: operands
    op1_s       <=  op1_buf;
    op2_s       <=  op2_buf         when (cmd_buf(IDX_ADD) or cmd_buf(IDX_ADDC))='1' else
                    (not op2_buf)   when (cmd_buf(IDX_SUB) or cmd_buf(IDX_SUBB))='1' else
                    (others=>'0') ;
    
    -- adder subtractor: the RCA core
    gen_adder: for i in 0 to N-1 generate
        y_sum(i)        <= op1_s(i) xor op2_s(i) xor c_chain(i);
        c_chain(i+1)    <= (op1_s(i) and op2_s(i)) or ((op1_s(i) xor op2_s(i)) and c_chain(i));
    end generate gen_adder;


    -- multiplier adder
    -- ---------------------------------
    gen_mul_adder: for i in 0 to N-1 generate
        mul_sum(i)          <= mul_sum_op1(i) xor mul_sum_op2(i) xor mul_sum_cchain(i);
        mul_sum_cchain(i+1) <= (mul_sum_op1(i) and mul_sum_op2(i)) or ((mul_sum_op1(i) xor mul_sum_op2(i)) and mul_sum_cchain(i));
    end generate gen_mul_adder;

    mul_sum_op1 <= op1_buf when reg_l(0)='1' else (others=>'0');
    mul_sum_op2 <= reg_h;

    -- buffer h: shift the mul high part partial sum
    -- ---------------------------------
    proc_reg_h: process (rst,clk)
    begin
        if rst=RST_POL then
            reg_h   <= (others=>'0');
        elsif rising_edge(clk) then
            if cmd_mul='1' and cmd_busy='0' then
                reg_h   <= (others=>'0');
            elsif cmd_busy='1' then
                reg_h   <= mul_sum_cchain(N) & mul_sum(N-1 downto 1);
            end if;
        end if;
    end process proc_reg_h;

    -- buffer l: shift the mul low part partial sum
    -- ---------------------------------
    proc_reg_l: process (rst,clk)
    begin
        if rst=RST_POL then
            reg_l   <= (others=>'0');
        elsif rising_edge(clk) then
            if cmd_mul='1' and cmd_busy='0' then
                reg_l   <= op2;
            elsif cmd_busy='1' then
                reg_l(N-1)          <= mul_sum(0);
                reg_l(N-2 downto 0) <= reg_l(N-1 downto 1);
            end if;
        end if;
    end process proc_reg_l;

    -- result high and low
    -- ---------------------------------
    y_mul_h     <= reg_h;
    y_mul_l     <= reg_l;


    -- logic functions
    -- ------------------------------------------------------------------
    y_and   <= op1_buf and  op2_buf;
    y_or    <= op1_buf  or  op2_buf;
    y_xor   <= op1_buf xor  op2_buf;
    y_xnor  <= op1_buf xnor op2_buf;

    -- shift/rotate functions
    -- ------------------------------------------------------------------
    -- left logical     : op1_s << 1 (insert 0)
    y_sll   <= op1_s(N-2 downto 0) & '0';
    -- right logical    : op1_s >> 1 (insert 0)
    y_srl   <= '0' & op1_s(N-1 downto 1);
    -- right arithmetic : op1_s >> 1 (insert MSB)
    y_sra   <= op1_s(N-1) & op1_s(N-1 downto 1);

    -- rotate left
    y_rl    <= op1_s(N-2 downto 0) & op1_s(N-1);
    -- rotate left (through carry)
    y_rlc   <= op1_s(N-2 downto 0) & cbin_buf;

    -- rotate right
    y_rr    <= op1_s(N-1) & op1_s(N-1 downto 1);
    -- rotate right (through carry)
    y_rrc   <= cbin_buf & op1_s(N-1 downto 1);


    -- output assignment
    -- ------------------------------------------------------------------
    y_s <=  y_sum   when cmd_buf(IDX_ADD ) = '1' else
            y_sum   when cmd_buf(IDX_ADDC) = '1' else
            y_sum   when cmd_buf(IDX_SUB ) = '1' else
            y_sum   when cmd_buf(IDX_SUBB) = '1' else
            y_mul_h when cmd_buf(IDX_MUL ) = '1' else
            y_and   when cmd_buf(IDX_AND ) = '1' else
            y_or    when cmd_buf(IDX_OR  ) = '1' else
            y_xor   when cmd_buf(IDX_XOR ) = '1' else
            y_xnor  when cmd_buf(IDX_XNOR) = '1' else
            y_sll   when cmd_buf(IDX_SLL ) = '1' else
            y_srl   when cmd_buf(IDX_SRL ) = '1' else
            y_sra   when cmd_buf(IDX_SRA ) = '1' else
            y_rl    when cmd_buf(IDX_RL  ) = '1' else
            y_rlc   when cmd_buf(IDX_RLC ) = '1' else
            y_rr    when cmd_buf(IDX_RR  ) = '1' else
            y_rrc   when cmd_buf(IDX_RRC ) = '1' else
            (others=>'0');


    -- flags
    -- ------------------------------------------------------------------
    z_s     <=  '1' when unsigned(y_s)=0 else '0';
    --
    c_s     <=  c_chain(N)      when cmd_buf(IDX_ADD ) ='1' else
                c_chain(N)      when cmd_buf(IDX_ADDC) ='1' else
                not c_chain(N)  when cmd_buf(IDX_SUB ) ='1' else
                not c_chain(N)  when cmd_buf(IDX_SUBB) ='1' else
                op1(N-1)        when cmd_buf(IDX_SLL ) ='1' else
                op1(0)          when cmd_buf(IDX_SRL ) ='1' else
                op1(0)          when cmd_buf(IDX_SRA ) ='1' else
                op1(N-1)        when cmd_buf(IDX_RLC ) ='1' else
                op1(0)          when cmd_buf(IDX_RRC ) ='1' else
                '0';
    --
    v_s     <=  c_chain(N) xor c_chain(N-1) when (cmd_buf(IDX_ADD ) or cmd_buf(IDX_ADDC) or cmd_buf(IDX_SUB ) or cmd_buf(IDX_SUBB))='1' else '0';
    --
    s_s     <=  y_s(N-1);
    --
    proc_parity: process(y_s)
        variable pv : std_logic;
    begin
        pv := '0';
        for i in 0 to N-1 loop
            pv := pv xor y_s(i);
        end loop;
        p_s <= pv ;
    end process proc_parity;

    -- buffering the output
    -- ------------------------------------------------------------------
    proc_bufout: process (rst,clk)
    begin
        if rst=RST_POL then
            y_outreg    <= (others=>'0');
            z_flag      <= '0';
            c_flag      <= '0';
            v_flag      <= '0';
            s_flag      <= '0';
            p_flag      <= '0';
        elsif rising_edge(clk) then
            if cmd_busy='1' then
                y_outreg    <= y_s;
                z_flag      <= z_s;
                c_flag      <= c_s;
                v_flag      <= v_s;
                s_flag      <= s_s;
                p_flag      <= p_s;
            end if;
        end if;
    end process proc_bufout;


    -- final assignment
    -- ------------------------------------------------------------------
    y   <= y_outreg;
    z   <= z_flag;
    c   <= c_flag;
    v   <= v_flag;
    s   <= s_flag;
    p   <= p_flag;


end rtl;
