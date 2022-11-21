LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Dec7seg IS
    PORT (
        BCD : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        led : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END Dec7seg;

ARCHITECTURE comportamiento OF Dec7seg IS
BEGIN
    PROCESS (BCD)
    BEGIN
        CASE BCD IS
            WHEN "0000" => LED <= "0000001"; --0
            WHEN "0001" => LED <= "1001111"; --1
            WHEN "0010" => LED <= "0010010"; --2
            WHEN "0011" => LED <= "0000110"; --3
            WHEN "0100" => LED <= "1001100"; --4 
            WHEN "0101" => LED <= "0100100"; --5
            WHEN "0110" => LED <= "0100000"; --6
            WHEN "0111" => LED <= "0001111"; --7
            WHEN "1000" => LED <= "0000000"; --8
            WHEN "1001" => LED <= "0001100"; --9
            WHEN OTHERS => LED <= "0001100"; --9
        END CASE;
    END PROCESS;
END comportamiento;