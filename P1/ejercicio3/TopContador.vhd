-- Top Level Design
-- Contador binario 4 bits 
-- con salida a display.
-----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
--------------------------------------------------------------------------------
--Declaracion de la entidad

ENTITY TopContador IS
    PORT (
        dir, enable, clk, reset : IN STD_LOGIC;
        SegDisp : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display
        An : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- anodos del display
        LEDS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );

END ENTITY TopContador;

--------------------------------------------------------------------------------
--declaracion de la arquitectura
ARCHITECTURE Behavioral OF TopContador IS
    --se�ales para el contador   
    SIGNAL valor_actual : STD_LOGIC_VECTOR (3 DOWNTO 0);
    -- Declaraci�n de se�ales de la asignaci�n de U-D-C-UM
    SIGNAL signoint : STD_LOGIC_VECTOR (3 DOWNTO 0); -- U D C signo
    -- Declaración de señales del divisor
    SIGNAL SAL_400Hz : STD_LOGIC; --salidas 2.5ms
BEGIN

    --------------------------------------------------------------------------------
    --Declaracion del contador binario 
    Contador : ENTITY WORK.contador_binario PORT MAP(
        hab => enable,
        dir => dir,
        clk => clk,
        reset => reset,
        cnt => valor_actual,
        LEDS => LEDS,
        signo => signoint
        );
    --------------------------------------------------------------------------------

    --------------------------------------------------------------------------------
    controlador : ENTITY WORK.DISPLAYS PORT MAP(
        cantidad => valor_actual,
        signo => signoint, -- a señal p/srm (U1)
        SAL_400Hz => SAL_400Hz, -- a señal p/div_clk (U4)
       CLK => CLK,
        DISPLAY => SegDisp, -- a segmentos del display
        AN => AN -- a ánodos del display
        );
    --------------------------------------------------------------------------------

    -- Declaración del componente de los divisores (1ms=1kHz, 2.5ms=400Hz)
    -- U4
    DIV : ENTITY WORK.DIV_CLK PORT MAP(
        CLK => CLK, -- a reloj 50MHz p/nexys2
        SAL_400Hz => SAL_400Hz -- a señal p/displays (U4)
        );
    ----------------------------------------------------------------
END Behavioral;