LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY RELOJ1KHZ IS
    PORT (
        CLK50MHZ : IN STD_LOGIC;
        CLK1KHZ : OUT STD_LOGIC);
END RELOJ1KHZ;

ARCHITECTURE Behavioral OF RELOJ1KHZ IS
    SIGNAL pulso : STD_LOGIC := '0';
    SIGNAL contador : INTEGER RANGE 0 TO 24999 := 0;

BEGIN
    PROCESS (CLK50Mhz)
    BEGIN
        IF (CLK50Mhz'event AND CLK50Mhz = '1') THEN
            IF (contador = 24999) THEN
                pulso <= NOT(pulso);
                contador <= 0;
            ELSE
                contador <= contador + 1;
            END IF;
        END IF;
    END PROCESS;
    CLK1KHZ <= pulso;

END Behavioral;