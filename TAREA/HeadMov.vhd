----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY MovH IS
    GENERIC (Max : NATURAL := 500000);
    PORT (
        Motor_headPWM : OUT STD_LOGIC; --Alimentacion del motor DC pwm para controlar la velocidad
        Motor_RelayL : OUT STD_LOGIC := '1'; --Activa el relay que permite el avance en sentido hacia horario
        Motor_RelayR : OUT STD_LOGIC := '1'; --Activa el relay que permite el avance en sentido hacia antihorario

        LS_L : IN STD_LOGIC; --SENSOR DE LIMITE IZQUIERDO 
        LS_R : IN STD_LOGIC; --SENSOR DE LIMITE DERECHO 
        LS_C : IN STD_LOGIC; --SENSOR DE LIMITE central

        CLK : IN STD_LOGIC;
        SeqNum : IN INTEGER RANGE 0 TO 5
    );
END MovH;

ARCHITECTURE Behavioral OF MovH IS
    SIGNAL PWM_Count : INTEGER RANGE 1 TO Max;--500000;
    SIGNAL Conta250 : INTEGER RANGE 1 TO 250_000_000 := 1;

    SIGNAL sel : INTEGER RANGE 0 TO 10 := 1;
    SIGNAL ENC : INTEGER RANGE 0 TO 10 := 0;
    SIGNAL lft, central : INTEGER RANGE 0 TO 10 := 0;

    CONSTANT Speed1 : INTEGER := 100000; --representa a 1.50ms = 90°
    CONSTANT Speed2 : INTEGER := 200000; --representa a 2.00ms = 180°

BEGIN
    PROCESS (PWM_Count, sel, SeqNum)
    BEGIN
        IF SeqNum = 1 OR ENC = 1 THEN --secuencia uno 

            IF PWM_Count <= Speed1 THEN --velocidad de secuencia uno 
                Motor_headPWM <= '1';
            ELSE
                Motor_headPWM <= '0';
            END IF;
            ENC <= 1;

            CASE sel IS
                WHEN 1 =>
                    IF LS_C = '0' THEN --Detecta cabeza en el centro, listo para iniciar
                        Motor_RelayR <= '1'; --Apaga rele derecho 
                        Motor_RelayL <= '0'; --Inicia a la izquierda
                        sel <= 2; --cambia al siguiente estado (sensor izquierda)
                    END IF;
                WHEN 2 =>
                    IF LS_L = '0' THEN --Llega al limite izquierdo 
                        Motor_RelayL <= '1'; --Apaga rele sentido izquierdo 
                        Motor_RelayR <= '0'; --Enciede rele sentido derecho 
                        IF lft < 1 THEN --si ha pasado menos de una vez
                            lft <= lft + 1; --aumenta en uno el contador 
                            sel <= 3; --Pasa al estado que lo detiene en el centro 
                        ELSE
                            sel <= 4; --excede el limite, pasa al estado que lo detiene en el lado derecho 
                        END IF;
                    END IF;

                WHEN 3 =>
                    IF LS_C = '0' THEN --llega al limite central
                        Motor_RelayL <= '0'; --Enciende rele sentido Izquierdo 
                        Motor_RelayR <= '1'; --Apaga rele sentido derecho 
                        sel <= 2;
                    END IF;
                WHEN 4 =>
                    IF LS_R = '1' THEN --llega al limite derecho 
                        Motor_RelayR <= '1'; --Apaga rele sentido derecho 
                        Motor_RelayL <= '0'; --Enciende rele sentido Izquierdo 
                        sel <= 5;
                    END IF;

                WHEN 5 =>
                    IF LS_C = '0' THEN --llega al limite central
                        IF central < 1 THEN --si ha pasado por el centro menos de 2 veces 
                            central <= central + 1; --suma el contador para seguir recorriendo 
                            Motor_RelayL <= '1'; --Apaga rele sentido Izquierdo 
                            Motor_RelayR <= '0'; --Enciende rele sentido derecho 
                            sel <= 4; --avanza al sigiuente estado
                        ELSE
                            Motor_RelayL <= '1'; --Apaga rele sentido Izquierdo 
                            Motor_RelayR <= '1'; --Aapaga rele sentido derecho 
                            lft <= 0; --reinicia contador a cero
                            ENC <= 0;
                            central <= 0;
                        END IF;
                    END IF;

                WHEN OTHERS => NULL;
            END CASE;
        ELSIF SeqNum = 2 OR ENC = 2 THEN

            ENC <= 2;
            IF PWM_Count <= Speed2 THEN --velocidad de secuencia uno 
                Motor_headPWM <= '1';
            ELSE
                Motor_headPWM <= '0';
            END IF;

            CASE sel IS
                WHEN 1 =>
                    IF LS_C = '0' THEN --Detecta cabeza en el centro, listo para iniciar
                        Motor_RelayR <= '0'; --Enciende rele derecho 
                        Motor_RelayL <= '1'; --Apaga a la izquierda
                        sel <= 2; --cambia al estado limite derecho
                    END IF;

                WHEN 2 =>
                    IF LS_R = '0'  THEN --Llega al limite derecho 
                        Motor_RelayR <= '1'; --Apaga rele sentido derecho 
                        Motor_RelayL <= '0'; --Enciende rele sentido izquierdo 
                        sel <= 3;
                    END IF;

                WHEN 3 =>
                    IF LS_L = '0' THEN --llega al limite izquierdo
                        Motor_RelayL <= '1'; --Apaga rele sentido Izquierdo 
                        Motor_RelayR <= '0'; --Enciende rele sentido derecho 
                        sel <= 4;
                    END IF;

                WHEN 4 =>
                    IF LS_R = '0' THEN --Llega al limite derecho 
                        Motor_RelayR <= '1'; --Apaga rele sentido derecho 
                        Motor_RelayL <= '0'; --Enciende rele sentido izquierdo 
                        sel <= 5;
                    END IF;
                WHEN 5 =>
                    IF LS_L = '0' THEN --llega al limite izquierdo
                        Motor_RelayL <= '1'; --Apaga rele sentido Izquierdo 
                        Motor_RelayR <= '0'; --Enciende rele sentido derecho 
                        sel <= 6;
                    END IF;
                WHEN 6 =>
                    IF LS_C = '0' THEN --llega al limite central
                        Motor_RelayL <= '1'; --Apaga rele sentido Izquierdo 
                        Motor_RelayR <= '1'; --APAGA rele sentido derecho 
                        lft <= 0; --reinciia contador a cero
                        ENC <= 0;
                    END IF;

                WHEN OTHERS => NULL;
            END CASE;
            --ELSE

            --sel <= 1;
            -- Motor_headPWM <= '0';
        END IF;

        IF ENC = 0 THEN
            SEL <= 1;
            Motor_RelayL <= '0';
            Motor_RelayR <= '0';

        END IF;
    END PROCESS;

    conteo : PROCESS (clk)
    BEGIN

        IF rising_edge(clk) AND (ENC = 1 OR ENC = 2) THEN
            PWM_Count <= PWM_Count + 1;
        END IF;
    END PROCESS conteo;

END Behavioral;