--Top level 
--Voltimetro y amperimetro con salida a display
--ADC por i2c

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY VIP IS
    PORT (
        CLK         : IN STD_LOGIC;
        SCL, SDA    :  INOUT STD_LOGIC;
        i2c_ack_err : OUT STD_LOGIC;
        reset_n     : IN STD_LOGIC;
		  HLD : IN STD_LOGIC;
        DISPLAY     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display--"abcdefgP"
        AN          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0):="11111111" -- ánodos del display
    );

END ENTITY VIP;

ARCHITECTURE Behavioral OF VIP IS
    SIGNAL Valor_temporal : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL SAL_250us, SAL_250us1 : STD_LOGIC;
BEGIN
    --------------------------------------------------------------------------------
    --Declaracion del ADC
    ADC : ENTITY WORK.ADCCompleto PORT MAP(
        SCL => SCL,
        SDA => SDA,
        clk => clk, --reloj 50 mhz
        reset_n => reset_n, --reset asincrono
        i2c_ack_err => i2c_ack_err, --Led indicador de error en comunicacion i2c
        Val => Valor_temporal --trama de 16 bits
        );
    --------------------------------------------------------------------------------

    --------------------------------------------------------------------------------
    --Declaracion del convertidor binario a decimal y realiza las operaciones necesarias
    convertidor : ENTITY WORK.binary_bcd PORT MAP(
        clk => clk,
        reset_n => reset_n, --reset asincrono
        binary_in => Valor_temporal, --trama de 16 bits (entrada) para convertir a decimal 
        DISPLAY => DISPLAY, --segmentos
		  HLD => HLD, --Boton hold
        SAL_250us => SAL_250us, --Pulso para display 7 segmentos
        SAL_250us1 => SAL_250us1, --Pulso de un segundo 
        AN => AN --anodos
        );
    --------------------------------------------------------------------------------

    --------------------------------------------------------------------------------
    --Declaracion de los divisores de frecuencia para el display y calculo de voltaje 
    Divisores_frecuencia  : ENTITY WORK.Clks PORT MAP(
        clk => clk,
        SAL_250us => SAL_250us,
        SAL_250us1 => SAL_250us1
        );
    --------------------------------------------------------------------------------
END ARCHITECTURE Behavioral;