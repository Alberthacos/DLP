LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY Clks IS 
    PORT (
        clk                      : IN STD_LOGIC; --Reloj 50 Mhz amiba 
        SAL_250us, SAL_250us1    : INOUT STD_LOGIC --Pulsos de salida de 0.125ms y 1s
    );
END Clks;

ARCHITECTURE behaviour OF Clks IS
    --signals 
    --------------------------------------------------------------------------------
    SIGNAL contadors : INTEGER RANGE 1 TO 6250 := 1; -- pulso de 0.25ms (pro. divisor ánodos)
    SIGNAL contadors1 : INTEGER RANGE 1 TO 50_000_000 := 1; -- pulso de 1 segundo 
    --SIGNAL SAL_250us, SAL_250us1 : STD_LOGIC;
    --------------------------------------------------------------------------------
BEGIN

    ---------------------DIVISOR ÁNODOS-------------------
    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF (contadors = 6250) THEN --cuenta 0.125ms (50MHz=6250) 20us*6250=0.125ms ????????????????????????????
                SAL_250us <= NOT(SAL_250us); --genera un barrido de 0.25ms
                contadors <= 1;
            ELSE
                contadors <= contadors + 1;
            END IF;
        END IF;
    END PROCESS; -- fin del proceso Divisor Ánodos

    ---------------------Pulso de un segundo-------------------
    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF (contadors1 = 50_000_000) THEN  --20us*50_000_000=1s
                SAL_250us1 <= NOT(SAL_250us1); --genera un pulso de un segundo 
                contadors1 <= 1;
            ELSE
                contadors1 <= contadors1 + 1;
            END IF;
        END IF;
    END PROCESS; 
    ------------------------------------------------------------

END behaviour;

