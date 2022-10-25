------------------------------------------------------------------------------------------------------
-- Se presenta un generador de señal PWM para controlar un servomotor, utilizando un
-- encoder rotatorio mecánico para manipular su posición. El sentido de giro es CW y
-- CCW, tanto para el encoder como para el servomotor, teniendo un tope en ambos
-- sentidos. El tiempo en alto “high” se obtiene con la función Ta=K1+(conta*K2) o bien
-- high <= min + (cnt*inc), colocada como high = 15000 + (cnt * 3225).
-- Archivos: encoder.vhd y encoder.ucf
------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY encoder IS
    GENERIC (
        msb : INTEGER := 5; --número de bits del contador

        min : INTEGER := 18332; --valor mínimo del contador para el tiempo en alto
        max : INTEGER := 121686; --valor máximo del contador para el tiempo en alto
        inc : INTEGER := 3334; -- incremento para el tiempo en alto
        N : INTEGER := 15); --divisor

    PORT (
        --reloj de 50MHz de la nexys2
        clk : IN STD_LOGIC;
        --reset asíncrono en alto en la nexys2 (BTN0) y en el encoder (Push)
        resetB, resetP : IN STD_LOGIC;
        --señales A y B del encoder
        A, B : IN STD_LOGIC;
        --salida del contador de 5 bits cuando msb=5
        contador : OUT STD_LOGIC_VECTOR (msb - 1 DOWNTO 0);
        --salida a display de 7 segmentos + P
        display : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000001";
        --salida a los ánodos
        AN : OUT STD_LOGIC_VECTOR (0 TO 3);
        --salidas de pwm para el servomotor y un led testigo
        servomotor, servoLED : OUT STD_LOGIC

    );

END encoder;
ARCHITECTURE encoder OF encoder IS
    --se utiliza una FSM moore para leer el encoder
    TYPE edos IS (EA, EB, EC, ED);
    SIGNAL EP : edos := EA;
    --declaración de señales
    SIGNAL clkdiv : STD_LOGIC_VECTOR(N DOWNTO 0); --señal para el divisor
    SIGNAL AB : STD_LOGIC_VECTOR (1 TO 2); --señal que une las señales del encoder
    SIGNAL cntPWM : INTEGER RANGE 1 TO 500000 := 1; --contador de 10ms @ clk=50MHz

    -- o T=20ns
    SIGNAL cnt : INTEGER RANGE 0 TO 31 := 0; --contador de 0 a 31
    SIGNAL servo : STD_LOGIC; --señal de PWM para las salidas servos
    SIGNAL high : INTEGER RANGE min TO max := min; --duración del tiempo en alto de la

    -- señal PWM

    ------------ end signal declarations ------------
BEGIN
    AB <= a & b; --unión (concatenación) de las señales del encoder
    AN <= "1110"; --activación del ánodo del display uno
    divisor : --proceso del divisor
    PROCESS (clk, resetB, resetP)
    BEGIN
        IF resetB = '1' OR resetP = '1' THEN
            clkdiv <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            clkdiv <= clkdiv + 1;
        END IF;
    END PROCESS divisor;
    FSM : --proceso que detecta los giros del encoder y genera la variable cnt
    PROCESS (clkdiv(N), resetB, resetP, cnt)
    BEGIN
        IF resetB = '1' OR resetP = '1' THEN
            EP <= EA;
            cnt <= 0;
        ELSIF rising_edge(clkdiv(N)) THEN
            CASE EP IS
                WHEN EA =>
                    IF AB = "00" THEN
                        EP <= EA;
                        cnt <= cnt; --hold
                    ELSIF AB = "10" THEN
                        EP <= EB; --cw
                        IF cnt = 31 THEN
                            cnt <= 31;
                        ELSIF cnt < 31 THEN
                            cnt <= cnt + 1;
                        ELSE
                            cnt <= cnt;
                        END IF;

                    ELSIF AB = "01" THEN
                        EP <= ED; --ccw
                        IF cnt = 0 THEN
                            cnt <= 0;

                        ELSIF cnt > 0 THEN
                            cnt <= cnt - 1;
                        ELSE
                            cnt <= cnt;
                        END IF;

                    END IF;
                WHEN EB => cnt <= cnt; --hold
                    IF AB = "10" THEN
                        EP <= EB;
                    ELSIF AB = "11" THEN
                        EP <= EC;
                    ELSIF AB = "00" THEN
                        EP <= EA;
                    END IF;
                WHEN EC =>
                    IF AB = "11" THEN
                        EP <= EC;
                        cnt <= cnt; --hold
                    ELSIF AB = "01" THEN
                        EP <= ED; --cw
                        IF cnt = 31 THEN
                            cnt <= 31;
                        ELSIF cnt < 31 THEN
                            cnt <= cnt + 1;
                        ELSE
                            cnt <= cnt;
                        END IF;

                    ELSIF AB = "10" THEN
                        EP <= EB; --ccw
                        IF cnt = 0 THEN
                            cnt <= 0;
                        ELSIF cnt > 0 THEN
                            cnt <= cnt - 1;
                        ELSE
                            cnt <= cnt;
                        END IF;

                    END IF;
                WHEN ED => cnt <= cnt; --hold
                    IF AB = "01" THEN
                        EP <= ED;
                    ELSIF AB = "00" THEN
                        EP <= EA;
                    ELSIF AB = "11" THEN
                        EP <= EC;
                    END IF;
                WHEN OTHERS => NULL;
            END CASE;

        END IF;
    END PROCESS FSM;
    -- Proceso para generar la salida de PWM de 0.3 a 2.3 ms @ f=100Hz, cntPWM cuenta
    -- de 1 a 500,000 que equivale a un periodo de 10ms, con 16 posiciones, high va de
    -- min @ cnt=0 (0.3ms) hasta max @ cnt=15 (2.3ms).
    --
    -- Los valores de high para (cnt) con incrementos de 6666 son:
    -- 0.3ms (0), 0.4333ms (1), 0.5666ms (2), 0.7ms (3),
    -- 0.8333ms (4), 0.9666ms (5), 1.1ms (6), 1.2333ms (7),
    -- 1.3666ms (8), 1.5ms (9), 1.6333ms (10), 1.7666ms (11),
    -- 1.9ms (12), 2.0333ms (13), 2.1666ms (14), 2.3ms (15)
    --
    -- Con 32 posiciones high va de min @ cnt=0 (0.3ms) hasta max @ cnt=31 (2.3ms).
    -- Los valores de high para (cnt) con incrementos de 3225 son:
    -- 0.3ms (0), 0.365ms (1), 0.429ms (2), 0.494ms (3),
    -- 0.558ms (4), 0.623ms (5), 0.687ms (6), 0.752ms (7),
    -- 0.816ms (8), 0.881ms (9), 0.945ms (10), 1.01ms (11),
    -- 1.074s (12), 1.139ms (13), 1.203ms (14), 1.268ms (15)
    -- 1.332ms (16), 1.397ms (17), 1.467ms (18), 1.526ms (19),
    -- 1.59ms (20), 1.655ms (21), 1.719ms (22), 1.784ms (23),
    -- 1.848ms (24), 1.913ms (25), 1.977ms (26), 2.042ms (27),
    -- 2.106ms (28), 2.171ms (29), 2.235ms (30), 2.3ms (31)
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
            CASE cnt IS --orden: abcdefgP-ánodo común, contador = salida a leds
                WHEN 0 => display <= "00000011";
                    contador <= '0' & x"0"; -- 0 al display
                WHEN 1 => display <= "10011111";
                    contador <= '0' & x"1"; -- 1 al display
                WHEN 2 => display <= "00100101";
                    contador <= '0' & x"2"; -- 2 al display
                WHEN 3 => display <= "00001101";
                    contador <= '0' & x"3"; -- 3 al display
                WHEN 4 => display <= "10011001";
                    contador <= '0' & x"4"; -- 4 al display
                WHEN 5 => display <= "01001001";
                    contador <= '0' & x"5"; -- 5 al display
                WHEN 6 => display <= "01000001";
                    contador <= '0' & x"6"; -- 6 al display
                WHEN 7 => display <= "00011111";
                    contador <= '0' & x"7"; -- 7 al display
                WHEN 8 => display <= "00000001";
                    contador <= '0' & x"8"; -- 8 al display
                WHEN 9 => display <= "00001001";
                    contador <= '0' & x"9"; -- 9 al display
                WHEN 10 => display <= "00010001";
                    contador <= '0' & x"A"; -- A al display
                WHEN 11 => display <= "11000001";
                    contador <= '0' & x"B"; -- B al display
                WHEN 12 => display <= "01100011";
                    contador <= '0' & x"C"; -- C al display
                WHEN 13 => display <= "10000101";
                    contador <= '0' & x"D"; -- D al display
                WHEN 14 => display <= "01100001";
                    contador <= '0' & x"E"; -- E al display
                WHEN 15 => display <= "01110001";
                    contador <= '0' & x"F"; -- F al display
                WHEN 16 => display <= "00000010";
                    contador <= '1' & x"0"; -- 0. al display
                WHEN 17 => display <= "10011110";
                    contador <= '1' & x"1"; -- 1. al display
                WHEN 18 => display <= "00100100";
                    contador <= '1' & x"2"; -- 2. al display
                WHEN 19 => display <= "00001100";
                    contador <= '1' & x"3"; -- 3. al display
                WHEN 20 => display <= "10011000";
                    contador <= '1' & x"4"; -- 4. al display
                WHEN 21 => display <= "01001000";
                    contador <= '1' & x"5"; -- 5. al display
                WHEN 22 => display <= "01000000";
                    contador <= '1' & x"6"; -- 6. al display
                WHEN 23 => display <= "00011110";
                    contador <= '1' & x"7"; -- 7. al display
                WHEN 24 => display <= "00000000";
                    contador <= '1' & x"8"; -- 8. al display
                WHEN 25 => display <= "00001000";
                    contador <= '1' & x"9"; -- 9. al display
                WHEN 26 => display <= "00010000";
                    contador <= '1' & x"A"; -- A. al display
                WHEN 27 => display <= "11000000";
                    contador <= '1' & x"B"; -- B. al display
                WHEN 28 => display <= "01100010";
                    contador <= '1' & x"C"; -- C. al display
                WHEN 29 => display <= "10000100";
                    contador <= '1' & x"D"; -- D. al display
                WHEN 30 => display <= "01100000";
                    contador <= '1' & x"E"; -- E. al display
                WHEN 31 => display <= "01110000";
                    contador <= '1' & x"F"; -- F. al display
                WHEN OTHERS => display <= "11111101";
                    contador <= '0' & x"0";
            END CASE;
        END IF;
        servomotor <= servo; --salida de la señal PWM hacia el servomotor
        servoLED <= servo; --salida de la señal PWM del led testigo
    END PROCESS ModulPulso; -- fin del proceso
END encoder; -- fin de la arquitectura