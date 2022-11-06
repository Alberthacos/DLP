----Challenge 2 (substitute the points 4 and 5).
----Implement a 2DOF camera (laser, water weapon, etc.) positioner using 2 servomotors and
----a joystick (analog or digital). Report codes (HDL and UCF), photos and video.
--
--LIBRARY IEEE;
--USE IEEE.std_logic_1164.ALL;
--USE IEEE.numeric_std.ALL;
--
--ENTITY TDOF IS
--    GENERIC (
--        --Max : NATURAL := 500000;
--        min : INTEGER := 18332; --valor mínimo del contador para el tiempo en alto
--        max : INTEGER := 121686; --valor máximo del contador para el tiempo en alto
--        inc : INTEGER := 3334 -- incremento para el tiempo en alto
--    );
--    PORT (
--        CLK : IN STD_LOGIC;
--        display : out STD_LOGIC_VECTOR(3 DOWNTO 0);
--        servomotor, servoLED : OUT STD_LOGIC; --Salida a pwm para controlar posicion de servos 
--        JSTK : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --Entradas del joystick (XL,XR,YU,YD)
--        RESET : IN STD_LOGIC; --Boton reset en placa 
--        LIM1, LIM2 : IN STD_LOGIC --Sensores de limite
--
--    );
--END ENTITY TDOF;
--
--ARCHITECTURE Behavioral OF TDOF IS
--    SIGNAL PWM_Count : INTEGER RANGE 1 TO Max;--500000;
--
--    SIGNAL cntPWM : INTEGER RANGE 1 TO 500000 := 1; --contador de 10ms @ clk=50MHz
--
--    -- o T=20ns
--    SIGNAL cnt : INTEGER RANGE 0 TO 31 := 0; --contador de 0 a 31
--    SIGNAL servo : STD_LOGIC; --señal de PWM para las salidas servos
--    SIGNAL high : INTEGER RANGE min TO max := min; --duración del tiempo en alto de la
--    SIGNAL X : STD_LOGIC;
--    CONSTANT lim_deb : INTEGER := 6_999_999;
--    SIGNAL sampledXL, sampledXR : STD_LOGIC;
--    SIGNAL XL, XR : STD_LOGIC;
--    SIGNAL sclk : INTEGER RANGE 0 TO lim_deb := 0;--STD_LOGIC_VECTOR (8 DOWNTO 0); 
--BEGIN
--    --Generacion_pwm : PROCESS (CLK, PWM_Count)
--
--    --IF rising_edge(clk) THEN
--    --    PWM_Count <= PWM_Count + 1;
--    --
--    --END IF;
--    --
--    --IF PWM_Count <= pos1 THEN
--    --    PWM <= '1';
--    --
--    --ELSE
--    --    PWM <= '0';
--
--    --END IF;
--
--    --END PROCESS Generacion_pwm;
--
--    Control_contador : PROCESS (JSTK, x)
--    BEGIN
--        X <= XL OR XR;
--        if reset ='0' then 
--        IF rising_edge(X) THEN
--            IF (XL = '1' AND cnt < 15) THEN
--                cnt <= cnt + 1;
--            ELSIF (XR = '1' AND cnt > 1) THEN
--                cnt <= cnt - 1;
--            END IF;
--        END IF;
--        else cnt <= cnt;
--        end if;
--
--        CASE cnt IS --orden: abcdefgP-ánodo común, contador = salida a leds
--            WHEN 0 => display <= "0000";-- 0 al display
--            WHEN 1 => display <= "0001";-- 1 al display
--            WHEN 2 => display <= "0010";-- 2 al display
--            WHEN 3 => display <= "0011";-- 3 al display
--            WHEN 4 => display <= "0100";-- 4 al display
--            WHEN 5 => display <= "0101";-- 5 al display
--            WHEN 6 => display <= "0110";-- 6 al display
--            WHEN 7 => display <= "0111";-- 7 al display
--            WHEN 8 => display <= "1000";-- 8 al display
--            WHEN 9 => display <= "1001";-- 9 al display
--            WHEN 10 => display <="1010";-- A al display
--            WHEN 11 => display <="1011";-- B al display
--            WHEN 12 => display <="1100";-- C al display
--            WHEN 13 => display <="1101";-- D al display
--            WHEN 14 => display <="1110";-- E al display
--            WHEN 15 => display <="1111";-- F al display
--            WHEN OTHERS => display <= "0000";
--        END CASE;
--    END PROCESS Control_contador;
--
--    ModulPulso : --proceso que genera el pulso de salida e indica en el display un valor
--    PROCESS (CLK, servo)
--    BEGIN
--        IF rising_edge(clk) THEN
--            cntPWM <= cntPWM + 1; --contador de 1 a 500,000
--            high <= min + ((cnt) * (inc));
--            IF cntPWM <= high THEN
--                servo <= '1';
--            ELSE
--                servo <= '0';
--            END IF;
--        END IF;
--        servomotor <= servo; --salida de la señal PWM hacia el servomotor
--        servoLED <= servo; --salida de la señal PWM del led testigo
--    END PROCESS ModulPulso; -- fin del proceso
--    --------------------------------------------------------------------------------
--    debouncer_botones : PROCESS (clk) BEGIN
--
--        IF clk'event AND clk = '1' THEN
--            sampledXL <= JSTK(3);
--            sampledXR <= JSTK(2);
--
--            -- clock is divided to 1MHz
--            -- samples every 1uS to check if the input is the same as the sample
--            -- if the signal is stable, the debouncer should output the signal
--            IF sclk = lim_deb THEN
--
--                -- Aout
--                IF sampledXL = JSTK(3) THEN
--                    XL <= JSTK(3);
--                END IF;
--                --Bout
--                IF sampledXR = JSTK(2) THEN
--                    XR <= JSTK(2);
--                END IF;
--
--                sclk <= 0;
--            ELSE
--                sclk <= sclk + 1;
--            END IF;
--        END IF;
--    END PROCESS;
--    --------------------------------------------------------------------------------
--
--END ARCHITECTURE Behavioral;



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
        --Encoder
        CLK : IN STD_LOGIC; --reloj 50 Mhz
        ButtonSub : IN STD_LOGIC;
        ButtonAdd : IN STD_LOGIC;
        LedLim : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);

        
        reset : IN STD_LOGIC --Boton de reset 
      
    );

END ENTITY Control;

ARCHITECTURE Behavioral OF Control IS
    --signals
    CONSTANT lim_deb : INTEGER := 6_999_999;
    SIGNAL Contador : INTEGER RANGE 0 TO 20 := 0; --Contador para el numero de objetos detectados 
    --CONSTANT limite : INTEGER := 15; --limite numero de obj que pueden pasar hasta que se interrumpa el acceso 
    SIGNAL conta_1250us : INTEGER RANGE 1 TO 10_000_000 := 1; -- pulso1 de 1250us@400Hz (0.25ms)
    SIGNAL SAL_400Hz : STD_LOGIC; --salida 2.5ms,
    SIGNAL DispVal : INTEGER RANGE 0 TO 25; -- almacena los valores del display 
    SIGNAL SEL : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00"; -- selector de barrido display
    --------------------------------------------------------------------------------
    --Servomotor
    SIGNAL selector : STD_LOGIC := '0'; --selector para el estado del servo, 0° o 90°
    SIGNAL PWM_Count : INTEGER RANGE 1 TO 500000; --500000 // contador para pwm 
    --------------------------------------------------------------------------------
    --Encoder
    SIGNAL sclk : INTEGER RANGE 0 TO lim_deb := 0;--STD_LOGIC_VECTOR (8 DOWNTO 0); 
    SIGNAL sampledA, sampledB, sampledS : STD_LOGIC;
    SIGNAL Aout, Bout, Sout : STD_LOGIC;

    SIGNAL lim : INTEGER RANGE 1 TO 21 := 10;
    SIGNAL salida, q, clk_or : STD_LOGIC;

BEGIN
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------

    --------------------------------------------------------------------------------
    PROCESS (clk, salida)
    BEGIN
        IF (clk'event AND clk = '1') THEN-- si no existe un reset y el cambio de clk=1
            q <= Aout;-- funcionamiento normal del ffd
        END IF;

        clk_or <= Aout OR Bout;

        IF RESET = '0' THEN
            IF rising_edge(clk_or) THEN
                IF (buttonAdd = '1' AND lim < 20) THEN
                    lim <= lim + 1;
                ELSIF (ButtonSub = '1' AND lim > 1) THEN
                    lim <= lim - 1;
                    --ELSIF (buttonadd = '1' AND lim = 20) THEN 
                    --    lim <= 1;
                    --ELSIF (ButtonSub = '1' and lim = 1) THEN
                    --    lim <= 20;

                END IF;
            END IF;
        ELSE
            lim <= 10;
        END IF;

        CASE (lim) IS
            WHEN 1 => LedLim <= "00001";
            WHEN 2 => LedLim <= "00010";
            WHEN 3 => LedLim <= "00011";
            WHEN 4 => LedLim <= "00100";
            WHEN 5 => LedLim <= "00101";
            WHEN 6 => LedLim <= "00110";
            WHEN 7 => LedLim <= "00111";
            WHEN 8 => LedLim <= "01000";
            WHEN 9 => LedLim <= "01001";
            WHEN 10 => LedLim <= "01010";
            WHEN 11 => LedLim <= "01011";
            WHEN 12 => LedLim <= "01100";
            WHEN 13 => LedLim <= "01101";
            WHEN 14 => LedLim <= "01110";
            WHEN 15 => LedLim <= "01111";
            WHEN 16 => LedLim <= "10000";
            WHEN 17 => LedLim <= "10001";
            WHEN 18 => LedLim <= "10010";
            WHEN 19 => LedLim <= "10011";
            WHEN 20 => LedLim <= "10100";
            WHEN OTHERS => LedLim <= "11111";
        END CASE;

    END PROCESS;
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    debouncer_botones : PROCESS (clk, ButtonAdd, ButtonSub) BEGIN

        IF clk'event AND clk = '1' THEN
            sampledA <= ButtonAdd;
            sampledB <= ButtonSub;
     
            -- clock is divided to 1MHz
            -- samples every 1uS to check if the input is the same as the sample
            -- if the signal is stable, the debouncer should output the signal
            IF sclk = lim_deb THEN

                -- Aout
                IF sampledA = buttonAdd THEN
                    Aout <= buttonadd;
                END IF;
                --Bout
                IF sampledB = ButtonSub THEN
                    Bout <= ButtonSub;
                END IF;
                --Sout
                

                sclk <= 0;
            ELSE
                sclk <= sclk + 1;
            END IF;
        END IF;
    END PROCESS;
    --------------------------------------------------------------------------------

    --------------------------------------------------------------------------------

    --------------------------------------------------------------------------------
END Behavioral;

