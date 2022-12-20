LIBRARY IEEE;

USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY GeneradorPWM IS PORT (
    clk : IN STD_LOGIC;  --RELOJ 
    Conta1 : IN INTEGER RANGE 0 TO 7;   --CONTADOR QUE SELECCIONA LA VELOCIDAD 
    Motor : OUT STD_LOGIC --SALIDA PWM A MOTOR
    ); 
END GeneradorPWM;

ARCHITECTURE Behavioral OF GeneradorPWM IS

SIGNAL PWM_Count : INTEGER RANGE 1 TO 500000;--500000;
BEGIN


    --------------------------------------------------------------------------------
    --GENERADOR PWM 
    ---------------------------------------------------------------------------------

    PWMGen : PROCESS (clk, conta1, pwm_count)
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

                Motor <= '0'; --salida PWM del motor 1

            WHEN 1 => -- con el contador en 1 se enciende Motor a velocidad minima 

                IF PWM_Count <= Speed1 THEN
                    Motor <= '1';
                ELSE
                    Motor <= '0';
                END IF;

            WHEN 2 => -- con el contador en 2 aumenta a velocidad media Motor

                IF PWM_Count <= Speed2 THEN
                    Motor <= '1';
                ELSE
                    Motor <= '0';
                END IF;
            WHEN 3 => -- Incrementa a la velocidad maxima Motor

                IF PWM_Count <= speed3 THEN
                    Motor <= '1';
                ELSE
                    Motor <= '0';
                END IF;

            WHEN 4 => -- Incrementa a la velocidad maxima Motor

                IF PWM_Count <= speed4 THEN
                    Motor <= '1';
                ELSE
                    Motor <= '0';
                END IF;

            WHEN 5 => -- Incrementa a la velocidad maxima Motor

                IF PWM_Count <= speed5 THEN
                    Motor <= '1';
                ELSE
                    Motor <= '0';
                END IF;

            WHEN 6 => -- Incrementa a la velocidad maxima Motor

                IF PWM_Count <= speed6 THEN
                    Motor <= '1';
                ELSE
                    Motor <= '0';
                END IF;

            WHEN OTHERS => NULL;

        END CASE;
    END PROCESS PWMGen;
    --------------------------------------------------------------------------------


END Behavioral;