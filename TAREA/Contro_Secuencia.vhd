
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SeqCtrl IS
    PORT (
        SQ1 : IN STD_LOGIC;
        SQ2 : IN STD_LOGIC;
        CLK : IN STD_LOGIC;
        SeqNum : INOUT INTEGER RANGE 0 TO 5
    );
END SeqCtrl;

ARCHITECTURE Behavioral OF SeqCtrl IS
    --SIGNALS
    SIGNAL Sensors : STD_LOGIC;
    SIGNAL CountCycles : INTEGER RANGE 1 TO 50_000_000 := 1;
    SIGNAL NumCycles : INTEGER RANGE 0 TO 20 := 1;
    SIGNAL EnableCount : STD_LOGIC := '0';

BEGIN
    Sensors <= SQ1 OR SQ2;

    Asignacion : PROCESS (SQ1, Sensors, SQ2)
    BEGIN
        IF rising_edge(CLK) THEN
            --IF rising_edge(Sensors) and EnableCount = '0' THEN --por confirmar
            IF SQ1 = '1' AND EnableCount = '0' THEN --Detecta sensor 1, asigna el numero
                SeqNum <= 1; -- de secuencia a la variable  
                EnableCount <= '1';
            ELSIF SQ2 = '1' AND EnableCount = '0' THEN --Detecta sensor 2, asigna el numero
                SeqNum <= 2; -- de secuencia a la variable  
                EnableCount <= '1';
            END IF;

            --END IF;
            IF EnableCount = '1' THEN
                IF (CountCycles = 30_000_000) THEN --cuenta 1250ms (50MHz=62500) 62500*20us = 1.25ms 1/(2*1.25ms)=400Hz
                    IF NumCycles = 20 THEN
                        SeqNum <= 3;
                        NumCycles <= 1;
                        EnableCount <= '0';
                    ELSE
                        NumCycles <= NumCycles + 1;
                    END IF;
                    CountCycles <= 1;
                ELSE
                    CountCycles <= CountCycles + 1;
                END IF;
            END IF;
        END IF;

    END PROCESS Asignacion;
END Behavioral;