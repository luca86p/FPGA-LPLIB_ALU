-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_1_addsub is
    generic (
        N           : positive := 4
    );
    port (
        op1         : in  std_logic_vector(N-1 downto 0);
        op2         : in  std_logic_vector(N-1 downto 0);
        cbin        : in  std_logic;
        --
        cmd_add     : in  std_logic; -- op1 + op2
        cmd_sub     : in  std_logic; -- op1 - op2
        --
        y           : out std_logic_vector(N-1 downto 0);
        --
        z           : out std_logic; -- zero
        c           : out std_logic; -- carry
        v           : out std_logic; -- c2 overflow
        s           : out std_logic  -- sign
    );
end alu_1_addsub;

architecture rtl of alu_1_addsub is

    signal c_chain      : std_logic_vector(N   downto 0);
    --
    signal op1_s        : std_logic_vector(N-1 downto 0);
    signal op2_s        : std_logic_vector(N-1 downto 0);
    --
    signal y_sum        : std_logic_vector(N-1 downto 0);
    signal y_s          : std_logic_vector(N-1 downto 0);

begin

    -- adder subtractor
    c_chain(0)  <= cbin xor cmd_sub;
    op1_s       <= op1;
    op2_s       <= op2 when cmd_sub='0' else (not op2);
    --
    gen_adder: for i in 0 to N-1 generate
        y_sum(i)          <= op1_s(i) xor op2_s(i) xor c_chain(i);
        c_chain(i+1)    <= (op1_s(i) and op2_s(i)) or ((op1_s(i) xor op2_s(i)) and c_chain(i));
    end generate gen_adder;

    -- output assignment
    y_s     <=  y_sum when (cmd_add or cmd_sub)='1'  else
                (others=>'0');
    --
    y       <=  y_s;

    -- flags
    z       <=  '1' when unsigned(y_s)=0 else '0';
    c       <=  c_chain(N) xor cmd_sub;
    v       <=  c_chain(N) xor c_chain(N-1);
    s       <=  y_s(N-1);

end rtl;
