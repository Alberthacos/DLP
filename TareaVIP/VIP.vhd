--Top level 
--Voltimetro y amperimetro con salida a display
--ADC por i2c

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY VIP IS
    PORT (
        CLK         : IN STD_LOGIC;
        ch          : IN STD_LOGIC; 
        SCL, SDA    :  INOUT STD_LOGIC;
        i2c_ack_err : OUT STD_LOGIC;
        reset_n     : IN STD_LOGIC;
        DISPLAY     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display--"abcdefgP"
        AN          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0):="11111111" -- ánodos del display
    );

END ENTITY VIP;

ARCHITECTURE Behavioral OF VIP IS
    SIGNAL Valor_temporal : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL BinUni, BinDec, BinCen, BinMil, BinDecMil : STD_LOGIC_VECTOR(3 DOWNTO 0); --cantidades en binario 

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
        Val => Valor_temporal --trama de 16 bits
        );
    --------------------------------------------------------------------------------

    --------------------------------------------------------------------------------
    --Declaracion del convertirdor binario a decimal con salida a display 7 segmentos 
    convertidor : ENTITY WORK.binary_bcd PORT MAP(
        clk => clk,
        reset_n => reset_n, --reset asincrono
        binary_in => Valor_temporal, --trama de 16 bits (entrada) para convertir a decimal 
        bcd0 => BinDecMil, --decenas de millar en binario
        bcd1 => BinMil, --unidades de millar en binario 
        bcd2 => BinCen, --centenas en binario 
        bcd3 => BinDec, --decenas en binario 
        bcd4 => BinUni, --unidades en binario
        DISPLAY => DISPLAY, --segmentos
        AN => AN --anodos
        );
    --------------------------------------------------------------------------------
END ARCHITECTURE Behavioral;