
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY MovArms IS
    GENERIC (Max : NATURAL := 500000);
    PORT (
        ServoL : OUT STD_LOGIC;
        ServoR : OUT STD_LOGIC;
        Clk : IN STD_LOGIC;
        SeqNum : IN INTEGER RANGE 0 TO 5
    );
END MovArms;

ARCHITECTURE Behavioral OF MovArms IS
    SIGNAL PWM_Count : INTEGER RANGE 1 TO Max;--500000;
    SIGNAL selector : STD_LOGIC := '0';
    SIGNAL Conta250 : INTEGER RANGE 1 TO 250_000_000 := 1;

    CONSTANT posU : INTEGER := 50000; --representa a 1.50ms = 90° 50k
    CONSTANT posD : INTEGER := 900000; --representa a 2.00ms = 180°

BEGIN
    PROCESS (PWM_Count, selector, SeqNum)
    BEGIN

        IF SeqNum = 1 THEN
            CASE (selector) IS

                WHEN '0' => --caso 1, brazo izquierdo arriba, brazo derecho abajo 
                    IF PWM_Count <= posU THEN
                        ServoL <= '1';
                    ELSE
                        ServoL <= '0';
                    END IF;

                    IF PWM_Count <= posD THEN
                        ServoR <= '1';
                    ELSE
                        ServoR <= '0';
                    END IF;
                WHEN '1' => --caso 2, brazo izquierdo abajo, brazo derecho arriba
                    IF PWM_Count <= posD THEN
                        ServoL <= '1';
                    ELSE
                        ServoL <= '0';
                    END IF;

                    IF PWM_Count <= posU THEN
                        ServoR <= '1';
                    ELSE
                        ServoR <= '0';
                    END IF;

                WHEN OTHERS => NULL;

            END CASE;

        ELSIF SeqNum = 2 THEN

            CASE (selector) IS

                WHEN '0' => --caso 1, brazo izquierdo y derecho arriba 
                    IF PWM_Count <= posU THEN
                        ServoL <= '1';
                        ServoR <= '1';

                    ELSE
                        ServoL <= '0';
                        ServoR <= '0';
                    END IF;

                WHEN '1' => --caso 2, brazo izquierdo y derecho abajo
                    IF PWM_Count <= posD THEN
                        ServoL <= '1';
                        ServoR <= '1';
                    ELSE
                        ServoL <= '0';
                        ServoR <= '0';
                    END IF;
                WHEN OTHERS => NULL;

            END CASE;
        END IF;

    END PROCESS;

    conteo : PROCESS (clk)
    BEGIN

        IF rising_edge(clk) AND (SeqNum = 1 OR SeqNum = 2) THEN
            PWM_Count <= PWM_Count + 1;

            IF (Conta250 = 20_000_000) THEN --cuenta 1250ms (50MHz=62500) 62500*20us = 1.25ms 1/(2*1.25ms)=400Hz
                selector <= NOT(selector);
                Conta250 <= 1;
            ELSE
                Conta250 <= Conta250 + 1;
            END IF;

        END IF;
    END PROCESS conteo;

END Behavioral;