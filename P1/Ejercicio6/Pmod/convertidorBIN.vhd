
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity convertidorBIN is
    Port ( tempo : in  STD_LOGIC_VECTOR (0 TO 15);
           UNI : out  STD_LOGIC_VECTOR (3 downto 0);
           DEC : out  STD_LOGIC_VECTOR (3 downto 0);
           CEN : out  STD_LOGIC_VECTOR (3 downto 0));
end convertidorBIN;

architecture Behavioral of convertidorBIN is
    SIGNAL P : STD_LOGIC_VECTOR (9 DOWNTO 0); -- asigna UNI,DEC,CEN
begin

    ----------- CONVERTIR DE BIN A BCD -----------------------------
    -- utilizando shift and add
    PROCESS (tempo(3 TO 10))
        VARIABLE C_D_U : STD_LOGIC_VECTOR(17 DOWNTO 0);
        --18 bits para separar las Centenas-Decenas-Unidades
    
    BEGIN
        --ciclo de inicializaci�n
        FOR I IN 0 TO 17 LOOP --
            C_D_U(I) := '0'; -- se inicializa con 0
        END LOOP;
        C_D_U(7 DOWNTO 0) := tempo (3 TO 10); --tempo de 8 bits
        --ciclo de asignaci�n C-D-U
        FOR I IN 0 TO 7 LOOP
            -- los siguientes condicionantes comparan (>=5) y suman 3
            IF C_D_U(11 DOWNTO 8) > 4 THEN -- U
                C_D_U(11 DOWNTO 8) := C_D_U(11 DOWNTO 8) + 3;
            END IF;
            IF C_D_U(15 DOWNTO 12) > 4 THEN -- D
                C_D_U(15 DOWNTO 12) := C_D_U(15 DOWNTO 12) + 3;
            END IF;
            IF C_D_U(17 DOWNTO 16) > 4 THEN -- C
                C_D_U(17 DOWNTO 16) := C_D_U(17 DOWNTO 16) + 3;
            END IF;
            -- realiza el corrimiento
            C_D_U(17 DOWNTO 1) := C_D_U(16 DOWNTO 0);
        END LOOP;
        P <= C_D_U(17 DOWNTO 8); -- guarda en P y en seguida se separan UM-C-D-U
    END PROCESS;
    --UNIDADES
    UNI <= P(3 DOWNTO 0);
    --DECENAS
    DEC <= P(7 DOWNTO 4);
    --CENTENAS
    CEN <= "00" & P(9 DOWNTO 8);

end Behavioral;

