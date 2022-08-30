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
        dir, enable, clk, reset : IN STD_LOGIC;     --direccion, habilitador, reloj, reset
        SegDisp : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display
        An : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);      -- anodos del display
        LEDS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)     --salida a leds 
    );

END ENTITY TopContador;

--------------------------------------------------------------------------------
--declaracion de la arquitectura
ARCHITECTURE Behavioral OF TopContador IS
    --señales para el contador   
    SIGNAL valor_actual : STD_LOGIC_VECTOR (3 DOWNTO 0);
    -- Declaración de señales del divisor
    SIGNAL SAL_400Hz : STD_LOGIC; --salidas 2.5ms
BEGIN

    --------------------------------------------------------------------------------
    --Declaracion del contador binario 
    Contador : ENTITY WORK.contador_binario PORT MAP(
        hab => enable,
        dir => dir,
        clk => clk,
        reset => reset,     --reset asincrono
        cnt => valor_actual, --guarda el valor en el que se encuentra el contador
        LEDS => LEDS    --asigna la salida a los leds
        );
    --------------------------------------------------------------------------------

    --------------------------------------------------------------------------------
    --Declaracoin del controlador del display
    controlador : ENTITY WORK.DISPLAYS PORT MAP(
        cantidad => valor_actual,
        SAL_400Hz => SAL_400Hz, -- señal de reloj de 400hz
        CLK => CLK,
        DISPLAY => SegDisp, -- a segmentos del display
        AN => AN -- a ánodos del display
        );
    --------------------------------------------------------------------------------

    -- Declaración del componente de los divisores (1ms=1kHz, 2.5ms=400Hz)
        DIV : ENTITY WORK.DIV_CLK PORT MAP(
        CLK => CLK, -- a reloj 50MHz 
        SAL_400Hz => SAL_400Hz -- señal de reloj para controlador de display 
        );
    ----------------------------------------------------------------
END Behavioral;