LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY TDOF IS
    GENERIC (
        Max : NATURAL := 500000
        --min : INTEGER := 18332; --valor mínimo del contador para el tiempo en alto
        --max : INTEGER := 121686; --valor máximo del contador para el tiempo en alto
        --inc : INTEGER := 3334 -- incremento para el tiempo en alto
    );
    PORT (
        --Encoder
        CLK : IN STD_LOGIC; --reloj 50 Mhz
        XRin : IN STD_LOGIC; --XRin Xright
        XLin : IN STD_LOGIC; --XLin Xleft
        YUin : IN STD_LOGIC; --Yup
        YDin : IN STD_LOGIC; --YDown
        servomotor1, servomotor2 : OUT STD_LOGIC; --Salida a pwm para controlar posicion de servos 

        LedLim1, LedLim2 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0); --Salida a leds indicadores del limite actual        
        reset : IN STD_LOGIC --Boton de reset asincrono

    );
END ENTITY TDOF;

ARCHITECTURE Behavioral OF TDOF IS
    --signals
    --s
    CONSTANT limMinS1 : INTEGER :=50000;
    CONSTANT limMaxS1 : INTEGER :=100000;

    CONSTANT limMinS2 : INTEGER :=24500;
    CONSTANT limMaxS2 : INTEGER :=120000;
    
    CONSTANT NoDivS1 : INTEGER :=70;
    CONSTANT NoDivS2 : INTEGER :=60;

    Signal IncS1 : INTEGER;
    Signal IncS2 : INTEGER;


    SIGNAL PWM_Count1 : INTEGER RANGE 1 TO Max;--500000;
    SIGNAL PWM_Count2 : INTEGER RANGE 1 TO Max;--500000;

    --------------------------------------------------------------------------------
    CONSTANT lim_deb : INTEGER := 8_999_999;

    --------------------------------------------------------------------------------
    --Encoder
    SIGNAL sclk : INTEGER RANGE 0 TO lim_deb := 0;--STD_LOGIC_VECTOR (8 DOWNTO 0); 
    SIGNAL sampledXR, sampledXL : STD_LOGIC;
    SIGNAL XRout, XLout : STD_LOGIC;
    SIGNAL sampledYU, sampledYD : STD_LOGIC;
    SIGNAL YUout, YDout : STD_LOGIC;
    SIGNAL lim1, lim2 : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
    SIGNAL limInt1, limInt2 : INTEGER RANGE 0 TO 59 := 0;
    SIGNAL q, Xs, Ys : STD_LOGIC;

    SIGNAL conta_1250us : INTEGER RANGE 1 TO 5000000 := 1; -- pulso1 de 1250us@400Hz (0.25ms) 62500
    SIGNAL SAL_400Hz : STD_LOGIC; -- reloj de 400Hz

BEGIN
    --------------------------------------------------------------------------------
    IncS1 <= (limMaxS1-limMinS1)/NoDivS1;
    IncS2 <= (limMaxS2-limMinS2)/NoDivS2;
    
    --------------------------------------------------------------------------------
    GeneradorPWM1 : PROCESS (clk)
    BEGIN
    --------------------------------------------------------------------------------
    -- Lim = (180/3)=60
    -- min = 24100
    -- max = 110k
    -- inc = (24100-110000)/60=1432
    --------------------------------------------------------------------------------
        IF rising_edge(clk) THEN
            PWM_Count1 <= PWM_Count1 + 1;
        END IF;

        IF PWM_Count1 <= limMinS1 + (limInt1 * IncS1) THEN --min+(Lim*incremento) incremento = 7666
            servomotor1 <= '1';

        ELSE
            servomotor1 <= '0';
        

        END IF;

    END PROCESS GeneradorPWM1;
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    GeneradorPWM2 : PROCESS (clk)
    BEGIN

        IF rising_edge(clk) THEN
            PWM_Count2 <= PWM_Count2 + 1;
        END IF;

        IF PWM_Count2 <= limMinS2 + (limInt2 * IncS2) THEN --min+(Lim*incremento) incremento = 7666
            servomotor2 <= '1';

        ELSE
            servomotor2 <= '0';

        END IF;

    END PROCESS GeneradorPWM2;
    --------------------------------------------------------------------------------
    ControlLim : PROCESS (clk)
    BEGIN
        IF (clk'event AND clk = '1') THEN-- si no existe un reset y el cambio de clk=1
            q <= XRout;-- funcionamiento normal del ffd
        END IF;

        Xs <= XRout OR XLout;
        Ys <= YDout OR YUout;

        IF RESET = '0' THEN
            IF rising_edge(SAL_400Hz) then 
                IF (Xs = '1') THEN
                    IF (XRin = '1' AND lim1 < "111100" AND limInt1 < 60) THEN --60
                        lim1 <= lim1 + '1';
                        limInt1 <= limInt1 + 1;
                    ELSIF (XLin = '1' AND lim1 >= "000001" AND limInt1 >= 1) THEN
                        lim1 <= lim1 - '1';
                        limInt1 <= limInt1 - 1;
                    END IF;
                END IF;
                IF (Ys = '1') THEN
                    IF (YUin = '1' AND lim2 < "111100" AND limInt2 < 60) THEN --60
                        lim2 <= lim2 + '1';
                        limInt2 <= limInt2 + 1;
                    ELSIF (YDin = '1' AND lim2 >= "000001" AND limInt2 >= 1) THEN
                        lim2 <= lim2 - '1';
                        limInt2 <= limInt2 - 1;
                    END IF;
                END IF;
            END IF;
        ELSE
            lim1 <= "000000";
            limInt1 <= 0;
            lim2 <= "000000";
            limInt2 <= 0;
        END IF;

        LedLim1 <= lim1;
        LedLim2 <= lim2;

    END PROCESS;
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    debouncer_botones : PROCESS (clk, XRin, XLin) BEGIN

        IF clk'event AND clk = '1' THEN
            sampledXR <= XRin;
            sampledXL <= XLin;
            sampledYU <= YUin;
            sampledYD <= YDin;

            -- clock is divided to 1MHz
            -- samples every 1uS to check if the input is the same as the sample
            -- if the signal is stable, the debouncer should output the signal
            IF sclk = lim_deb THEN

                -- XRout
                IF sampledXR = XRin THEN
                    XRout <= XRin;
                END IF;
                --XLout
                IF sampledXL = XLin THEN
                    XLout <= XLin;
                END IF;
                -- YUout
                IF sampledYU = YUin THEN
                    YUout <= YUin;
                END IF;
                --YDout
                IF sampledYD = YDin THEN
                    YDout <= YDin;
                END IF;

                sclk <= 0;
            ELSE
                sclk <= sclk + 1;
            END IF;
        END IF;
    END PROCESS;
    --------------------------------------------------------------------------------

    CLK_400 : PROCESS (CLK) BEGIN
        IF (rising_edge(CLK)) THEN
            IF (conta_1250us = 2000000) THEN --cuenta 1250ms (50MHz=62500) 62500*20us = 1.25ms 1/(2*1.25ms)=400Hz
                SAL_400Hz <= NOT(SAL_400Hz); --genera un barrido de 2.5ms
                conta_1250us <= 1;
            ELSE
                conta_1250us <= conta_1250us + 1;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;