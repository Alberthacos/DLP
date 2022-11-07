
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Mov_eyes IS
    GENERIC (Max : NATURAL := 500000);
    PORT (
        Servo1 : OUT STD_LOGIC;
        Servo2 : OUT STD_LOGIC;
        Clk : IN STD_LOGIC;
        SeqNum : IN INTEGER RANGE 0 TO 5
    );
END Mov_eyes;
ARCHITECTURE Behavioral OF Mov_eyes IS


    SIGNAL PWM_Count : INTEGER RANGE 1 TO Max;--500000;
    SIGNAL selector : STD_LOGIC := '0';
    SIGNAL Conta250 : INTEGER RANGE 1 TO 250_000_000 := 1;

    CONSTANT posL : INTEGER := 50000; --representa a 1.00ms = 0°
    CONSTANT posR : INTEGER := 80000; --representa a 1.25ms = 45°

    CONSTANT posU : INTEGER := 70000; --representa a 1.50ms = 90°
    CONSTANT posD : INTEGER := 90000; --representa a 2.00ms = 180°

BEGIN
    PROCESS (PWM_Count, selector, SeqNum)
    BEGIN

        IF SeqNum = 1 THEN
            CASE (selector) IS

                WHEN '0' => --caso 1, ojos izquierda
                    IF PWM_Count <= posL THEN
                        Servo1 <= '1';
                    ELSE
                        Servo1 <= '0';
                    END IF;

                WHEN '1' => --caso 2, ojos derecha
                    IF PWM_Count <= posR THEN
                        Servo1 <= '1';
                    ELSE
                        Servo1 <= '0';
                    END IF;

                WHEN OTHERS => NULL;

            END CASE;

        ELSIF SeqNum = 2 THEN

            CASE (selector) IS

                WHEN '0' => --caso 0, ojos arriba
                    IF PWM_Count <= posU THEN
                        Servo2 <= '1';
                    ELSE
                        Servo2 <= '0';
                    END IF;

                WHEN '1' => --caso 1, ojos abajo
                    IF PWM_Count <= posD THEN
                        Servo2 <= '1';
                    ELSE
                        Servo2 <= '0';
                    END IF;

                WHEN OTHERS => NULL;

            END CASE;
        END IF;

    END PROCESS;

    conteo : PROCESS (clk)
    BEGIN

        IF rising_edge(clk) and (SeqNum =1 or SeqNum=2) THEN
            PWM_Count <= PWM_Count + 1;

            IF (Conta250 = 20_000_000) THEN --cuenta 1250ms (50MHz=62500) 62500*20us = 1.25ms 1/(2*1.25ms)=400Hz
                        selector <=NOT(selector);
                Conta250 <= 1;
            ELSE
                Conta250 <= Conta250 + 1;
            END IF;

        END IF;
    END PROCESS conteo;

END Behavioral;