--------------------------------------------------------------------------------
-- Codigo que controla dos motorreductores
--  cuenta con 4 modoos o posibles estados 
--  estos se seleccionan con un boton para cada motor
--  al presionar una vez el boton: enciende el motor en velocidad minima
--  al presionar otra vez el boton: enciende el motor en velocidad media
--  al presionar otra vez el boton: enciende el motor en velocidad maxima 
--  al presionar otra vez el boton: se apaga el motor 
--  S1 -> Min // s2 => Media // s3 => Max // s4 => OFF
--  Cuenta con leds RGB que indican las velocidades:
--  G => Min // B => Media // R => Max 
-- Emite al menos dos sonidos que indican dos estados, por ejemplo:
-- en s1 => suena "velocidad minima" 
-- s3 => suena "velocidad maxima"
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY SpeedMotors IS
    GENERIC (Max : NATURAL := 500000);
    PORT (
        CLK : IN STD_LOGIC; --Reloj 50 MHz
        PB1, PB2 : IN STD_LOGIC; --Botones que seleccionan los estados
        M1, M2 : INOUT STD_LOGIC := '0'; --Salida PWM hacia los motores, salida a transistor
        SPK1_Min, SPK1_Max : OUT STD_LOGIC := '0'; --Salidas para sonido
        LedM1,LedM2 : OUT STD_LOGIC := '0'; 
        
        RGB1, RGB2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) --Salida a leds RGB que indican las velocidades
    );
END ENTITY SpeedMotors;

ARCHITECTURE Behavioral OF SpeedMotors IS
    --Signals
    SIGNAL sclk : INTEGER RANGE 0 TO 20_000_000 := 0;

    SIGNAL sampledPB1, sampledPB2 : STD_LOGIC; --Señal de muestra para comparar despues del tiempo sclk*(20us)
    SIGNAL PB1_DEB, PB2_DEB : STD_LOGIC; --Señal de botones sin ruido, señal final
    SIGNAL PBS : STD_LOGIC; --Señal de botones sin ruido, señal final
    SIGNAL Conta1, Conta2 : INTEGER RANGE 0 TO 5 := 0; --Contador de estados

    SIGNAL PWM_Count : INTEGER RANGE 1 TO Max;--500000;
BEGIN
    PBS <= PB1_DEB OR PB2_DEB;

    LedM1 <= M1;
    LedM2 <= M2;

    ContadorEstados : PROCESS (PB1_DEB, Conta1, pbs, conta2, PB2_DEB)
    BEGIN

        --IF rising_edge(PB1_DEB) THEN --Pulsacion de alguno de los botones
        --Contador1 para Motor 1

        IF rising_edge(PB1_DEB) THEN
            IF Conta1 = 3 THEN --Flanco ascendente en pulsador 1 y contador menor-igual a 2
                Conta1 <= 0;
            ELSE
                Conta1 <= Conta1 + 1; --se reinicia, vuelve al estado inicial
            END IF;
        END IF;

        --Contador2 para Motor 2
        IF rising_edge(PB2_DEB) THEN
            IF Conta2 = 3 THEN --Flanco ascendente en pulsador 2 y contador menor-igual a 2
                Conta2 <= 0; --se reinicia, vuelve al estado inicial
            ELSE
                Conta2 <= Conta2 + 1; --aumenta en uno 
            END IF;
        END IF;
        --END IF;

        CASE Conta1 IS

            WHEN 0 =>
                RGB1 <= "000"; --s1 apagado
            WHEN 1 =>
                RGB1 <= "010"; --s2 min VERDE
            WHEN 2 =>
                RGB1 <= "001"; --s3 med AZUL
            WHEN 3 =>
                RGB1 <= "100"; --s4 max ROJO

            WHEN OTHERS => RGB1 <= "000"; -- apagado

        END CASE;

        CASE Conta2 IS

            WHEN 0 =>
                RGB2 <= "000"; --s1 apagado
            WHEN 1 =>
                RGB2 <= "010"; --s2 min
            WHEN 2 =>
                RGB2 <= "001"; --s3 med
            WHEN 3 =>
                RGB2 <= "100"; --s4 max

            WHEN OTHERS => RGB2 <= "000"; -- apagado

        END CASE;

        IF conta1 = 1 OR Conta2 = 1 THEN --contador en estado 1, velocidad al minimo 
            SPK1_Min <= '0';
            SPK1_Max <= '1';
            
            ELSIF Conta1 = 3 OR Conta2 = 3 THEN --Contador en estado 3, velocidad al maximo 
            SPK1_Max <= '0';
            SPK1_Min <= '1';

        ELSE                --Contador en cualquier otro estado, no hay sonido 
            SPK1_Min <= '1';
            SPK1_Max <= '1';
        END IF;

    END PROCESS ContadorEstados;

    Deb : PROCESS (clk) IS
    BEGIN

        IF clk'event AND clk = '1' THEN --Flanco ascendente
            sampledPB1 <= PB1; --muestra de PB1
            sampledPB2 <= PB2; --muestra de PB2

            --clock IS divided TO 1MHz
            --samples every 1uS TO check IF the input IS the same as the sample
            --IF the SIGNAL IS stable, the debouncer should output the SIGNAL

            IF sclk = 3_000_000 THEN --Tiempo de prueba sclk*20us
                --PB1
                IF sampledPB1 = PB1 THEN --si cuenta con el mismo estado que cuando se presiono, entonces:
                    PB1_DEB <= PB1; --Se asigna el valor a la variable sin ruido 
                END IF;
                --PB2
                IF sampledPB2 = PB2 THEN
                    PB2_DEB <= PB2;
                END IF;

                sclk <= 0;
            ELSE
                sclk <= sclk + 1;
            END IF;
        END IF;
    END PROCESS Deb;

    PWMGen : PROCESS (clk, conta1, conta2, pwm_count)
        --Velocidades de PWM
        CONSTANT Speed1 : INTEGER := 90000;
        CONSTANT Speed2 : INTEGER := 150000;
        CONSTANT Speed3 : INTEGER := 250000;

    BEGIN

        IF rising_edge(clk) THEN
            PWM_Count <= PWM_Count + 1;
        END IF;

        --PWM1 PARA MOTOR 1
        CASE (Conta1) IS

            WHEN 0 => --con el contador en cero se mantiene apagado el motor1

                M1 <= '0'; --salida PWM del motor 1

            WHEN 1 => -- con el contador en 1 se enciende M1 a velocidad minima 

                IF PWM_Count <= Speed1 THEN
                    M1 <= '1';

                ELSE
                    M1 <= '0';

                END IF;

            WHEN 2 => -- con el contador en 2 aumenta a velocidad media M1

                IF PWM_Count <= Speed2 THEN
                    M1 <= '1';

                ELSE
                    M1 <= '0';

                END IF;
            WHEN 3 => -- Incrementa a la velocidad maxima M1

                IF PWM_Count <= speed3 THEN
                    M1 <= '1';

                ELSE
                    M1 <= '0';

                END IF;

            WHEN OTHERS => NULL;

        END CASE;

        --PWM1 PARA MOTOR 2
        CASE (Conta2) IS

            WHEN 0 => --con el contador en cero se mantiene apagado el motor1

                M2 <= '0'; --salida PWM del motor 1

            WHEN 1 => -- con el contador en 1 se enciende M2 a velocidad minima 

                IF PWM_Count <= Speed1 THEN
                    M2 <= '1';

                ELSE
                    M2 <= '0';

                END IF;

            WHEN 2 => -- con el contador en 2 aumenta a velocidad media M2

                IF PWM_Count <= Speed2 THEN
                    M2 <= '1';

                ELSE
                    M2 <= '0';

                END IF;

            WHEN 3 => -- Incrementa a la velocidad maxima M2

                IF PWM_Count <= speed3 THEN
                    M2 <= '1';

                ELSE
                    M2 <= '0';

                END IF;

            WHEN OTHERS => NULL;

        END CASE;
    END PROCESS PWMGen;

END Behavioral;