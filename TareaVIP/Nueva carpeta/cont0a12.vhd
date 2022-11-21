LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Cont_0al2 IS
    PORT (
        Clk : IN STD_LOGIC;
        Q : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0));
END Cont_0al2;

ARCHITECTURE Behavioral OF Cont_0al2 IS

BEGIN
    PROCESS (Clk)
    BEGIN
        IF Clk = '1' AND Clk'event THEN
            IF Q = "11" THEN
                Q <= "00";
            ELSE
                Q <= Q + 1;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;