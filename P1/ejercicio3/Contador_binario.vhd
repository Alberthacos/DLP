
-- contador de 4 bits en VHDL
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY contador_binario IS PORT (
    clk, hab, dir, reset : IN STD_LOGIC; -- reloj, enable/habilitación, dirección y reset asincrono
    LEDS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";  --salida a leds indicadores 
    cnt : OUT STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000" -- salida del contador binario de 4 bits
);
END contador_binario;
--declaracion de la arquitectura
ARCHITECTURE Behavioral OF contador_binario IS
    SIGNAL cont : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000"; -- señal de conteo
    SIGNAL contador_24 : INTEGER RANGE 1 TO 50000000 := 1; --contador para señal de reloj para el contador 1hz
    SIGNAL sal_1hz : STD_LOGIC;   --señal de reloj (salida) para el contador
BEGIN

    PROCESS (sal_1hz, hab, dir, cont, reset)
    BEGIN
        -- cada vez que existe un flanco de subida se realiza lo siguiente:
        -- si hab = '1' contar� seg�n dir
        -- si dir = '1' contar� hacia arriba, si dir = '0' contar� hacia abajo
        IF reset = '0' THEN
            IF sal_1hz'EVENT AND sal_1hz = '1' THEN

                IF hab = '1' AND dir = '1' THEN
                    cont <= cont + 1; -- cuenta ascendente
                ELSIF hab = '1' AND dir = '0' THEN
                    cont <= cont - 1; -- cuenta descendente
                ELSE
                    cont <= cont;
                END IF;
            END IF;
        ELSE
            cont <= "0000";
        END IF;
        cnt <= cont; -- se actualiza el contador cnt con la señal cont
        LEDS <= cont;
    END PROCESS; --fin del proceso

    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF (contador_24 = 24_999_999) THEN 
                sal_1hz <= NOT(sal_1hz); 
                contador_24 <= 1;
            ELSE
                contador_24 <= contador_24 + 1;
            END IF;
        END IF;
    END PROCESS;
END Behavioral; --fin de la arquitectura