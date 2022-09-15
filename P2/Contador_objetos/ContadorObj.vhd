--------------------------------------------------------------------------------
-- Codigo para contar objetos que caen en una rampa (1 a 20)
-- El numero de objetos a contar se puede modificar por el usuario
-- mediante un encoder o teclado (por definir)
-- Cuanto se alcanza el limite de objetos se interrumpe el paso hacia la 
-- rampa y se activa una musica  
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY Control IS
    PORT (
        sensor : IN STD_LOGIC; --entrada del sensor infrarrojo
        Motor_Interrupcion : OUT STD_LOGIC; --salida a led indicador de la interrupcion 
        Seg_Display : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --segmentos del display 
        reset : IN STD_LOGIC; --Boton de reset 
        CLK : IN STD_LOGIC; --reloj 50 Mhz
        PWM : OUT STD_LOGIC; --salida a servomotor
        An : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) --anodos del display 
    );

END ENTITY Control;

ARCHITECTURE Behavioral OF Control IS
    --signals
    SIGNAL Contador : INTEGER RANGE 0 TO 20 := 0; --Contador para el numero de objetos detectados 
    SIGNAL Conta_aux : INTEGER RANGE 0 TO 20 := 0; --Contador para el numero de objetos detectados 
    CONSTANT limite : INTEGER := 15; --limite numero de obj que pueden pasar hasta que se interrumpa el acceso 
    SIGNAL conta_1250us : INTEGER RANGE 1 TO 10_000_000 := 1; -- pulso1 de 1250us@400Hz (0.25ms)
    SIGNAL SAL_400Hz : STD_LOGIC; --salida 2.5ms,
    SIGNAL habilitador : STD_LOGIC := '0'; --habilita o deshabilita el sistema de conteo (stand by) 
    SIGNAL D : INTEGER RANGE 0 TO 25; -- almacena los valores del display 
    SIGNAL OP1, OP2, OP3, OP_DATA : STD_LOGIC;
    SIGNAL SEL : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00"; -- selector de barrido
    SIGNAL contador_disp : INTEGER RANGE 0 TO limite := 0;
    --------------------------------------------------------------------------------
    SIGNAL selector : STD_LOGIC := '0'; --Selector para el estado del servo, 0° o 90°
    SIGNAL PWM_Count : INTEGER RANGE 1 TO 500000; --500000;

    SIGNAL count : INTEGER := 0;
    TYPE state_type IS (idle, wait_time); --state machine
    SIGNAL state : state_type := idle;

BEGIN

    --------------------------------------------------------------------------------
    Conteo : PROCESS (OP_DATA, SAL_400Hz, reset) BEGIN

        IF (reset = '0') THEN --No se presiona el boton de reset
            IF rising_edge(OP_DATA) AND contador /= limite THEN --flanco ascendente del sensor (Deteccion de un obj)
                Contador <= Contador + 1; --Aumenta en uno el contador por cada deteccion
            END IF;

            --IF (Contador <= limite) THEN --si el contador es igual al limite configurado se:
            --    Motor_Interrupcion <= '1'; --Se activa el led indicador de la interrupcion
            --    selector <= '1'; --Se asigna '1' al selector para mover el servo 90°
            --    --contador <= Contador; --No se modifica el valor del contador, se mantiene en el limite 
            --    Conta_aux <= limite;
            --
            --ELSE --Si el contador es menor al limite se:
            --    selector <= '0'; --Se asigna '0' al selector para mantener el servo en 0°
            --    Motor_Interrupcion <= '0'; --Se mantiene deshabilitado el led indicador de la interrupcion
            --    Conta_aux <= contador;
            --END IF;
            IF (contador < limite) THEN
                selector <= '0';
                Motor_Interrupcion <= '0'; --Se mantiene deshabilitado el led indicador de la interrupcion
                --Conta_aux <= contador;
            ELSE
                Motor_Interrupcion <= '1'; --Se activa el led indicador de la interrupcion
                selector <= '1'; --Se asigna '1' al selector para mover el servo 90°--contador <= Contador; --No se modifica el valor del contador, se mantiene en el limite 
                --Conta_aux <= limite;
            END IF;
            
        ELSE --Se presiona el boton de reset 
            Contador <= 0; -- el contador se reinicia a 0  
            --Conta_aux <= 0;
            Motor_Interrupcion <= '0'; --Se desactiva el led indicador de la interrupcion 
            selector <= '0'; --Se asigna '0' al selector para mantener el servo en 0°
        END IF;
    END PROCESS;
    --------------------------------------------------------------------------------
    Debouncer : PROCESS (CLK) BEGIN

        IF rising_edge(CLK) THEN

            OP1 <= sensor;

            OP2 <= OP1;

            OP3 <= OP2;

        END IF;
    END PROCESS;
    OP_DATA <= OP1 AND OP2 AND OP3;
    --------------------------------------------------------------------------------
    CLK_400 : PROCESS (CLK) BEGIN
        IF (rising_edge(CLK)) THEN
            IF (conta_1250us = 62_500) THEN --cuenta 1250us (50MHz=62500)
                -- if (conta_1250us = 125000) then --cuenta 1250us (100MHz=125000)
                SAL_400Hz <= NOT(SAL_400Hz); --genera un barrido de 2.5ms
                conta_1250us <= 1;
            ELSE
                conta_1250us <= conta_1250us + 1;
            END IF;
        END IF;
    END PROCESS;
    --------------------------------------------------------------------------------
    PROCESS (SAL_400Hz, sel, conta_aux) BEGIN

        IF SAL_400Hz'EVENT AND SAL_400Hz = '1' THEN
            SEL <= SEL + '1';

            IF (contador <= 9) THEN
                CASE(SEL) IS
                    WHEN "00" => AN <= "1110"; D <= contador; -- UNIDADES
                    WHEN "01" => AN <= "1101"; D <= 0; -- DECENAS
                    WHEN OTHERS => AN <= "1111"; D <= 0; -- signo
                END CASE;
            ELSE
                CASE(SEL) IS
                    WHEN "00" => AN <= "1110"; D <= contador - 10; -- UNIDADES
                    WHEN "01" => AN <= "1101"; D <= 1; -- DECENAS
                    WHEN OTHERS => AN <= "1111"; D <= 0; -- signo
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    --------------------MULTIPLEXOR---------------------
    PROCESS (D) BEGIN
        CASE(D) IS -- abcdefgP
            WHEN 0 => Seg_Display <= "00000011"; --0
            WHEN 1 => Seg_Display <= "10011111"; --1
            WHEN 2 => Seg_Display <= "00100101"; --2
            WHEN 3 => Seg_Display <= "00001101"; --3
            WHEN 4 => Seg_Display <= "10011001"; --4
            WHEN 5 => Seg_Display <= "01001001"; --5
            WHEN 6 => Seg_Display <= "01000001"; --6
            WHEN 7 => Seg_Display <= "00011111"; --7
            WHEN 8 => Seg_Display <= "00000001"; --8
            WHEN 9 => Seg_Display <= "00001001"; --9
            WHEN OTHERS => Seg_Display <= "11111111"; --apagado
        END CASE;
    END PROCESS; -- fin del proceso Display
    --    -----------------------------------------------

    servomotor : PROCESS (clk)
        CONSTANT pos1 : INTEGER := 24000; --representa a 1.00ms = 0 // 0.5ms 0 deg
        CONSTANT pos2 : INTEGER := 68500; --representa a 1.25ms = 45 // 1.5 90 deg
        --        CONSTANT Max : NATURAL := 500000;

    BEGIN

        IF rising_edge(clk) THEN --reloj para pwm, realiza el conteo 
            PWM_Count <= PWM_Count + 1;
        END IF;

        CASE (selector) IS

            WHEN '0' => --con el selector en 0 se posiciona en servo en 0°
                IF PWM_Count <= pos1 THEN
                    PWM <= '1';
                ELSE
                    PWM <= '0';
                END IF;

            WHEN '1' => -- con el selector en 1 se posiciona en servo en 90°
                IF PWM_Count <= pos2 THEN
                    PWM <= '1';
                ELSE
                    PWM <= '0';
                END IF;

            WHEN OTHERS => NULL;

        END CASE;

    END PROCESS;
END Behavioral;