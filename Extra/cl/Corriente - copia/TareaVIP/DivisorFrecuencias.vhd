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


    ------------------------------------------------------------

END behaviour;

