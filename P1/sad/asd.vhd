-- contador de 4 bits en VHDL
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY contador IS PORT (
    clk, hab, dir : IN STD_LOGIC; -- reloj, habilitaci�n y direcci�n
    cnt : OUT STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000"); -- salida del contador binario de 4 bits
END contador;

ARCHITECTURE contado OF contador IS
    SIGNAL cont : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000"; -- se�al de conteo
    SIGNAL contador_24 : INTEGER RANGE 1 TO 50000000 := 1;
    SIGNAL SAL_400Hz : STD_LOGIC;
BEGIN
    PROCESS (SAL_400Hz, hab, dir,cont)
    BEGIN
        -- cada vez que existe un flanco de subida se realiza lo siguiente:
        -- si hab = '1' contar� seg�n dir
        -- si dir = '1' contar� hacia arriba, si dir = '0' contar� hacia abajo
        IF SAL_400Hz'EVENT AND SAL_400Hz = '1'THEN

            IF hab = '1' AND dir = '1' THEN
                cont <= cont + 1; -- cuenta ascendente
            ELSIF hab = '1' AND dir = '0' THEN
                cont <= cont - 1; -- cuenta descendente
            ELSE
                cont <= cont;
            END IF;
        END IF;
        cnt <= cont; -- se actualiza el contador cnt con la se�al cont
    END PROCESS; --fin del proceso

    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF (contador_24 = 24999999) THEN --cuenta 1250us (50MHz=62500)
                -- if (conta_1250us = 125000) then --cuenta 1250us (100MHz=125000)
                SAL_400Hz <= NOT(SAL_400Hz); --genera un barrido de 2.5ms
                contador_24 <= 1;
            ELSE
                contador_24 <= contador_24 + 1;
            END IF;
        END IF;
    END PROCESS;
END contado; --fin de la arquitectura