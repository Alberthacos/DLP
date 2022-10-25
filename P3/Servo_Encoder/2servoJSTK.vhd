--Challenge 2 (substitute the points 4 and 5).
--Implement a 2DOF camera (laser, water weapon, etc.) positioner using 2 servomotors and
--a joystick (analog or digital). Report codes (HDL and UCF), photos and video.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY TDOF IS
    GENERIC (
        Max : NATURAL := 500000
        min : INTEGER := 18332; --valor mínimo del contador para el tiempo en alto
        max : INTEGER := 121686; --valor máximo del contador para el tiempo en alto
        inc : INTEGER := 3334; -- incremento para el tiempo en alto
    );
    PORT (
        servomotor, servoLED : OUT STD_LOGIC; --Salida a pwm para controlar posicion de servos 
        JSTK : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --Entradas del joystick (XL,XR,YU,YD)
        RESET : IN STD_LOGIC; --Boton reset en placa 
        LIM1, LIM2 : IN STD_LOGIC --Sensores de limite

    );
END ENTITY TDOF;

ARCHITECTURE Behavioral OF TDOF IS
    SIGNAL PWM_Count : INTEGER RANGE 1 TO Max;--500000;

    SIGNAL cntPWM : INTEGER RANGE 1 TO 500000 := 1; --contador de 10ms @ clk=50MHz

    -- o T=20ns
    SIGNAL cnt : INTEGER RANGE 0 TO 31 := 0; --contador de 0 a 31
    SIGNAL servo : STD_LOGIC; --señal de PWM para las salidas servos
    SIGNAL high : INTEGER RANGE min TO max := min; --duración del tiempo en alto de la
    SIGNAL X : STD_LOGIC;
BEGIN
    Generacion_pwm : PROCESS (CLK, PWM_Count)

        --IF rising_edge(clk) THEN
        --    PWM_Count <= PWM_Count + 1;
        --
        --END IF;
        --
        --IF PWM_Count <= pos1 THEN
        --    PWM <= '1';
        --
        --ELSE
        --    PWM <= '0';

        --END IF;

        --END PROCESS Generacion_pwm;

        Control_contador : PROCESS (sensitivity_list)
        BEGIN
            X <= JSTK(3 DOWNTO 2);
            IF rising_edge(X) THEN
                IF (JSTK(3) = '1' AND cnt < 15) THEN
                    cnt <= cnt + 1;
                ELSIF (JSTK(2) = '1' AND cnt > 1) THEN
                    cnt <= cnt - 1;

                END IF;
            END IF;
        END PROCESS Control_contador;

        ModulPulso : --proceso que genera el pulso de salida e indica en el display un valor
        PROCESS (clk, servo)
        BEGIN
            IF rising_edge(clk) THEN
                cntPWM <= cntPWM + 1; --contador de 1 a 500,000
                high <= min + ((cnt) * (inc));
                IF cntPWM <= high THEN
                    servo <= '1';
                ELSE
                    servo <= '0';
                END IF;
            END IF;
            servomotor <= servo; --salida de la señal PWM hacia el servomotor
            servoLED <= servo; --salida de la señal PWM del led testigo
        END PROCESS ModulPulso; -- fin del proceso

    END ARCHITECTURE Behavioral;