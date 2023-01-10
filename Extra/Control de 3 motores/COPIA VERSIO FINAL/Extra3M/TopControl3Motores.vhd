--Codigo para controlar 3 motores, muestra su estado en una LCD 
--Cuenta con 4 botones, uno para cada motor y otro para el reset
--se apaga el motor que se encuentre encendido hasta que se presione el boton de reset
--Mientras no se presione este, solo se podra cambiar entre motores, pero no apagarlos
--Tiene salidas a leds que muestran el estado de cada motor, rojo para cuando esta apagado 
--y verde para cuando esta encendido  
library IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

entity Extra3Motores is
    port (
        CLOCK : IN STD_LOGIC; --Reloj 50MHz amiba2 
        --BOTONES 
        PB1, PB2, PB3 : IN STD_LOGIC;
        Rest : IN STD_LOGIC; --Reset general
   
        ---MOTORES
        M1, M2, M3 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --Salidas a leds indicadores
        Rels       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); --Salida para relevadores que controlan los motores

        --Pines para LCD
        LCD_RS : OUT STD_LOGIC; --	Comando, Datos
        LCD_RW : OUT STD_LOGIC := '0'; -- LECTURA/ESCRITURA
        LCD_E : OUT STD_LOGIC; -- ENABLE
        DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"; -- PINES DATOS

        BEEP : OUT STD_LOGIC --Salida a buzzer

    );
end entity Extra3Motores;

architecture behavioral of Extra3Motores is
    --Guarda el  estado de los 3 motores, se utiiliza para el control de la LCD
    SIGNAL EstadosM : STD_LOGIC_VECTOR(2 DOWNTO 0); 
BEGIN

    ControlMotores : ENTITY WORK.ControlM PORT MAP(
        CLOCK => CLOCK, --Reloj 50 Mhz
        --Botones pulsadores que corresponden a cada motor 
        --Por ejemplo, PB1 activa el motor 1
        PB1 => PB1, 
        PB2 => PB2,
        PB3 => PB3,
        --Salidas a leds que indican el estado de cada motor, ON o OFF
        M1  => M1,
        M2  => M2,
        M3  => M3,
        --Salida a relevadores 
        Rels => Rels,
        --Almacena el estado de cada motor para utilizar en el control de la LCD
        EstadosM => EstadosM,
        --Buzzer
        BEEP => BEEP,
        Rest => Rest
        );

    ControlLCD : ENTITY WORK.LCD PORT MAP(
        CLOCK => CLOCK, --Reloj 50 Mhz 
        LCD_RS => LCD_RS, --Comando/Datos
        LCD_RW => LCD_RW, --Lectura/Escritura
        LCD_E  => LCD_E, --Enable
        DATA   => DATA, --Pines de datos
        EstadosM => EstadosM, --Recibe el estado de cada motor
        Rest  => Rest  --Reset 
        );

end architecture behavioral;