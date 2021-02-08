-- =============================================================================
-- Whatis        : basic shift registerwith parallel load and shift direction
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : shift_reg.vhd
-- Language      : VHDL-93
-- Module        : shift_reg
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


entity shift_reg is
    generic (
        RST_POL         : std_logic := '0';
        N               : positive  := 8
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        clr             : in  std_logic;
        load            : in  std_logic;
        load_val        : in  std_logic_vector(N-1 downto 0);
        shift           : in  std_logic;
        shift_in        : in  std_logic;
        shift_lr        : in  std_logic;
        reg_val         : out std_logic_vector(N-1 downto 0)
    );
end shift_reg;

architecture rtl of shift_reg is

    signal data : std_logic_vector(N-1 downto 0);

begin

    proc_shift: process(clk,rst)
    begin
        if rst=RST_POL then
            data <= (others=>'0');
        elsif rising_edge(clk) then
            if clr='1' then
                data <= (others=>'0');
            elsif load='1' then
                data <= load_val;
            elsif shift='1' then
                if shift_lr='0' then
                    data(0) <= shift_in;
                    data(N-1 downto 1) <= data(N-2 downto 0);
                else -- shift_lr='1'
                    data(N-1) <= shift_in;
                    data(N-2 downto 0) <= data(N-1 downto 1);
                end if;
            end if;
        end if;
    end process proc_shift;

    reg_val <= data;

end rtl;
