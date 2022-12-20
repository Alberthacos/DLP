
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

    );
END ENTITY SpeedMotors;

ARCHITECTURE Behavioral OF SpeedMotors IS
    --Signals
    SIGNAL sclk : INTEGER RANGE 0 TO 20_000_000 := 0;

    SIGNAL sampledPB1, sampledPB2 : STD_LOGIC; --Señal de muestra para comparar despues del tiempo sclk*(20us)
    SIGNAL PB1_DEB, PB2_DEB : STD_LOGIC; --Señal de botones sin ruido, señal final
    SIGNAL PBS : STD_LOGIC; --Señal de botones sin ruido, señal final
    SIGNAL Conta1, Conta2 : INTEGER RANGE 0 TO 6 := 0; --Contador de estados
    SIGNAL PWM_Count : INTEGER RANGE 1 TO Max;--500000;
BEGIN
    PBS <= PB1_DEB OR PB2_DEB;

    Controlvelocidades : PROCESS (PB1_DEB, Conta1, pbs, conta2, PB2_DEB)
    BEGIN

        IF (EnableMotor = '1') THEN --Esta habilitado el motor 

            IF rising_edge(PBS) THEN --se detecta unflanco ascendente de los botones

                IF PB1_DEB = '1' THEN --Se verifica si se presiona boton uno, para aumentar 

                    IF Conta1 = 6 THEN -- Se llega al limite, vuelve a la primer velocidad
                        Conta1 <= 1;
                    ELSE --No se ha alcanzado el limite, se suma uno
                        Conta1 <= Conta1 + 1; --
                    END IF;

                ELSE --sino, se activo el boton 2, para disminuir una velocidad

                    IF Conta1 > 1 THEN --El numero de velocidad es mayor a la primera 
                        Conta1 <= Conta1 - 1; --se disminuye una velocidad
                    END IF;

                END IF;
            END IF;
        ELSE
            conta1 <= 0; --motor apagado 
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
        CONSTANT Speed2 : INTEGER := 120000;
        CONSTANT Speed3 : INTEGER := 150000;
        CONSTANT Speed4 : INTEGER := 180000;
        CONSTANT Speed5 : INTEGER := 210000;
        CONSTANT Speed6 : INTEGER := 250000;

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

            WHEN 4 => -- Incrementa a la velocidad maxima M1

                IF PWM_Count <= speed4 THEN
                    M1 <= '1';

                ELSE
                    M1 <= '0';

                END IF;
            WHEN 5 => -- Incrementa a la velocidad maxima M1

                IF PWM_Count <= speed5 THEN
                    M1 <= '1';

                ELSE
                    M1 <= '0';

                END IF;

            WHEN 6 => -- Incrementa a la velocidad maxima M1

                IF PWM_Count <= speed6 THEN
                    M1 <= '1';

                ELSE
                    M1 <= '0';

                END IF;

            WHEN OTHERS => NULL;

        END CASE;


    END PROCESS PWMGen;

END Behavioral;