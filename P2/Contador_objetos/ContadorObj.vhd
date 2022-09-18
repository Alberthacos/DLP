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

        sensor : IN STD_LOGIC; --entrada del sensor infrarrojo
        Motor_Interrupcion : OUT STD_LOGIC; --salida a led indicador de la interrupcion 
        Seg_Display : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --segmentos del display 
        reset : IN STD_LOGIC; --Boton de reset 
        PWM : OUT STD_LOGIC; --salida a servomotor
        An : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) --anodos del display 
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
    Conteo : PROCESS (contador, lim, Sout) BEGIN

        IF (reset = '0') THEN --No se presiona el boton de reset
            IF rising_edge(Sout) AND contador < lim THEN --flanco ascendente del sensor (Deteccion de un obj)
                Contador <= Contador + 1; --Aumenta en uno el contador por cada deteccion
            END IF;

            IF (contador < lim) THEN
                selector <= '0';
                Motor_Interrupcion <= '0'; --Se mantiene deshabilitado el led indicador de la interrupcion
            ELSE
                Motor_Interrupcion <= '1'; --Se activa el led indicador de la interrupcion
                selector <= '1'; --Se asigna '1' al selector para mover el servo 90°--contador <= Contador; --No se modifica el valor del contador, se mantiene en el limite 
            END IF;

        ELSE --Se presiona el boton de reset 
            Contador <= 0; -- el contador se reinicia a 0  
            Motor_Interrupcion <= '0'; --Se desactiva el led indicador de la interrupcion 
            selector <= '0'; --Se asigna '0' al selector para mantener el servo en 0°
        END IF;
    END PROCESS;
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
                ELSIF (ButtonSub = '1' AND lim > 1 AND lim > contador) THEN
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
            sampledS <= sensor;
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
                IF sampledS = Sensor THEN
                    Sout <= sensor;
                END IF;

                sclk <= 0;
            ELSE
                sclk <= sclk + 1;
            END IF;
        END IF;
    END PROCESS;
    --------------------------------------------------------------------------------

    --------------------------------------------------------------------------------
    CLK_400 : PROCESS (CLK) BEGIN
        IF (rising_edge(CLK)) THEN
            IF (conta_1250us = 62_500) THEN --cuenta 1250ms (50MHz=62500) 62500*20us = 1.25ms 1/(2*1.25ms)=400Hz
                SAL_400Hz <= NOT(SAL_400Hz); --genera un barrido de 2.5ms
                conta_1250us <= 1;
            ELSE
                conta_1250us <= conta_1250us + 1;
            END IF;
        END IF;
    END PROCESS;
    --------------------------------------------------------------------------------

    --------------------------------------------------------------------------------
    ControlDispConta : PROCESS (SAL_400Hz, sel) BEGIN
        IF SAL_400Hz'EVENT AND SAL_400Hz = '1' THEN
            SEL <= SEL + '1';

            -- IF (contador <= 9) THEN
            CASE(SEL) IS
                WHEN "00" => AN <= "10111111"; -- UNIDADES DEL CONTADOR
                IF contador <= 9 THEN
                    DispVal <= contador; --Unidades cuando es menor a 10
                ELSIF contador = 20 THEN
                    DispVal <= 0; --Unidades son 0 cuando es 20
                ELSE
                    DispVal <= contador - 10; --Unidades cuando es mayor a 10, se resta una decena 
                END IF;

                WHEN "01" => AN <= "01111111"; --DECENAS DEL CONTADOR
                IF contador <= 9 THEN
                    DispVal <= 0; --Decenas cuando es menor a 10
                ELSIF contador = 20 THEN
                    DispVal <= 2; --Decenas son 2 cuando es 20
                ELSE
                    DispVal <= 1; --Decenas cuando es mayor a 9 
                END IF;

                WHEN "10" => AN <= "11111110"; --UNIDADES DEL LIMITE 
                IF lim <= 9 THEN
                    DispVal <= lim; --Unidades cuando es menor a 10
                ELSIF lim = 20 THEN
                    DispVal <= 0; --Unidades son 0 cuando es 20
                ELSE
                    DispVal <= lim - 10; --Unidades cuando es mayor a 10, se resta una decena 
                END IF;

                WHEN "11" => AN <= "11111101"; --DECENAS DEL CONTADOR
                IF lim <= 9 THEN
                    DispVal <= 0; --Decenas cuando es menor a 10
                ELSIF lim = 20 THEN
                    DispVal <= 2; --Decenas son 2 cuando es 20
                ELSE
                    DispVal <= 1; --Decenas cuando es mayor a 9 
                END IF;


                WHEN OTHERS => AN <= "11111111";
                DispVal <= 0; -- signo
            END CASE;

        END IF;

        CASE(DispVal) IS -- abcdefgP
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
            WHEN OTHERS => Seg_Display <= "10101010"; --apagado
        END CASE;
    END PROCESS;
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    servomotor : PROCESS (clk, pwm_count, Selector)
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
    --------------------------------------------------------------------------------
END Behavioral;

