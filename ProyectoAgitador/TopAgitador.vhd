LIBRARY IEEE;

USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ControladorTOP IS PORT (

    RS : OUT STD_LOGIC; -- 
    RW : OUT STD_LOGIC; -- 
    ENA : OUT STD_LOGIC; -- 
    DATA_LCD : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    CLK : IN STD_LOGIC; --reloj amiba 50hz
    PB1, PB2 : IN STD_LOGIC; --botones selectores de velocidad
    Motor : OUT STD_LOGIC; --salida pwm motor
    EnableMotor : IN STD_LOGIC;
    --i2c
    SCL, SDA    :  INOUT STD_LOGIC;
    i2c_ack_err : OUT STD_LOGIC;
    reset_n     : IN STD_LOGIC

);

END ControladorTOP;

ARCHITECTURE Behavioral OF ControladorTOP IS

    --------------------------------------------------------------------------------
    --my signals
    SIGNAL conta1 : INTEGER RANGE 0 TO 7; --signal contador selector de velocidad 
    SIGNAL Valor_temporal : STD_LOGIC_VECTOR(15 DOWNTO 0);
    --signal Temperatura: STD_LOGIC_VECTOR(8 DOWNTO 0); 

BEGIN

    C1 : ENTITY work.Botonera PORT MAP(
        CLK => CLK, --RELOJ
        PB1 => PB1, --BOTON 1 PARA INCREMENTAR LA VELOCIDAD
        PB2 => PB2, --BOTON 2 PARA DISMINUIR LA VELOCIDAD
        EnableMotor => EnableMotor,
        conta1 => conta1 --Selector de velocidad
        );

    C2 : ENTITY work.LIB_LCD_INTESC_REVD PORT MAP(

        clk => clk, --reloj
        RS => RS, 
        RW => RW,
        ENA => ENA,
        DATA_LCD => DATA_LCD,
        Temp => Valor_temporal,
        conta1 =>  conta1 --selector de velocidad
         );

    C3 : ENTITY work.GeneradorPWM PORT MAP(
        clk => clk,
        Motor => Motor, --salida pwm a motor
        conta1 => conta1 --selector de velocidad
        );

    C4 : ENTITY work.ADCcompleto PORT MAP(
        SCL => SCL,
        SDA => SDA,
        clk => clk, --reloj 50 mhz
        reset_n => reset_n, --reset asincrono
        i2c_ack_err => i2c_ack_err,
        Val => Valor_temporal --trama de 16 bits
        );


END Behavioral;