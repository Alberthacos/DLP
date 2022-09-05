
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Clk_div is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           clkdiv : inout  STD_LOGIC
           );
end Clk_div;

architecture Behavioral of Clk_div is
    SIGNAL cnt : STD_LOGIC_VECTOR(4 DOWNTO 0); -- divisor counter
    --SIGNAL clkdiv : STD_LOGIC; -- divisor
begin
    div : PROCESS (rst, clk, clkdiv)
    BEGIN
        -- divisor 1MHz (1us)
        IF (rst = '1') THEN
            clkdiv <= '0';
        ELSIF (rising_edge(clk)) THEN
            IF cnt = "11000" THEN
                cnt <= "00000"; -- 0 a 24

                clkdiv <= NOT clkdiv; -- 0.5us alto, 0.5us bajo

            ELSE
                cnt <= cnt + '1';
            END IF;
        END IF;
        --SCK <= clkdiv;

    END PROCESS div;


end Behavioral;

