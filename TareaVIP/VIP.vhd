--Top level 
--Voltimetro y amperimetro con salida a display
--ADC por i2c

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY VIP IS
    PORT (
        CLK         : IN STD_LOGIC;
        LEDS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        SCL, SDA    :  INOUT STD_LOGIC;
        i2c_ack_err : OUT STD_LOGIC;
        reset_n     : IN STD_LOGIC;
        LCD_RS : OUT STD_LOGIC := '0'; --	Comando, escritura
        LCD_RW : OUT STD_LOGIC; -- LECTURA/ESCRITURA
        LCD_E : OUT STD_LOGIC; -- ENABLE
		REINI : IN STD_LOGIC;
        DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- PINES DATOS

        --DISPLAY     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display--"abcdefgP"
        --AN          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0):="11111111" -- ánodos del display
    );

END ENTITY VIP;

ARCHITECTURE Behavioral OF VIP IS
    SIGNAL Valor_temporalV, Valor_temporalI : STD_LOGIC_VECTOR(15 DOWNTO 0):="0000000000000000";
--    SIGNAL BinUni, BinDec, BinCen, BinMil, BinDecMil : STD_LOGIC_VECTOR(3 DOWNTO 0); --cantidades en binario 
    SIGNAL Decv, UniV, DeciV : INTEGER RANGE 0 TO 20; --Valores del voltaje
    --SIGNAL UniI, DeciI, CenI, MileI : STD_LOGIC_VECTOR(7 DOWNTO 0); --Valores del voltaje
	 SIGNAL ch : std_logic;
BEGIN
    --------------------------------------------------------------------------------
    --Declaracion del ADC
    ADC : ENTITY WORK.ADCCompleto PORT MAP(
        SCL => SCL,
        SDA => SDA,
        clk => clk, --reloj 50 mhz
        ch => ch,
        reset_n => reset_n, --reset asincrono
        i2c_ack_err => i2c_ack_err,
        ValV => Valor_temporalV, --trama de 16 bits del voltaje
        ValI => Valor_temporalI --trama de 16 bits de la corriente

        );
    --------------------------------------------------------------------------------

    --------------------------------------------------------------------------------
    --Declaracion del convertirdor binario a decimal con salida a display 7 segmentos 
    --convertidor : ENTITY WORK.binary_bcd PORT MAP(
    --    clk => clk,
	--	  ch => ch,
    --    reset_n => reset_n, --reset asincrono
    --    Valor_temporalV => Valor_temporalV, --trama de 16 bits (entrada) para convertir a decimal el voltaje
    --    Valor_temporalI => Valor_temporalI, --trama de 16 bits (entrada) para convertir a decimal la corriente
    --    --DISPLAY => DISPLAY, --segmentos
    --    DecenasVoltaje  =>  DecV,
    --    UnidadesVoltaje =>  UniV,
    --    DecimasVoltaje  =>  DeciV,
--
    --    UnidadesI   => UniI, 
    --    DecimasI    => DeciI, 
    --    centesimasI => CenI, 
    --    milesimasI  => MileI
    --    --AN => AN --anodos
    --    );
    ----------------------------------------------------------------------------------

    ControlLCD : ENTITY WORK.Lcd PORT MAP (
        CLOCK => CLK,
        LCD_RS => LCD_RS,
        LCD_RW => LCD_RW,
        LCD_E => LCD_E,
        LEDS => LEDS,

		REINI => REINI,
        --valores del voltaje
        Valor_temporalV => Valor_temporalV,
        Valor_temporalI => Valor_temporalI,
        --valores hacia la LCD
        DATA => DATA
    );


END ARCHITECTURE Behavioral;