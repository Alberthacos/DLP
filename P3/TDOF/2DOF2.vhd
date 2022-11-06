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

        XRin1 : IN STD_LOGIC; --XRin1 Xright
        XLin1 : IN STD_LOGIC; --XLin1 Xleft
        YUin1 : IN STD_LOGIC; --Yup
        YDin1 : IN STD_LOGIC; --YDown
        servomotor1, servomotor2 : OUT STD_LOGIC; --Salida a pwm para controlar posicion de servos 

        XRin2 : IN STD_LOGIC; --XRin1 Xright
        XLin2 : IN STD_LOGIC; --XLin1 Xleft
        YUin2 : IN STD_LOGIC; --Yup
        YDin2 : IN STD_LOGIC; --YDown
        servomotor11, servomotor22 : OUT STD_LOGIC; --Salida a pwm para controlar posicion de servos 

        LedLim1, LedLim2 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0); --Salida a leds indicadores del limite actual  
        LedLim11, LedLim22 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0); --Salida a leds indicadores del limite actual  

        reset : IN STD_LOGIC --Boton de reset asincrono

    );
END ENTITY TDOF;

ARCHITECTURE Behavioral OF TDOF IS
    --ssalida 1
    CONSTANT limMinS1 : INTEGER := 50000;
    CONSTANT limMaxS1 : INTEGER := 100000;

    CONSTANT limMinS2 : INTEGER := 24500;
    CONSTANT limMaxS2 : INTEGER := 120000;

    CONSTANT NoDivS1 : INTEGER := 60;
    CONSTANT NoDivS2 : INTEGER := 60;

    SIGNAL IncS1 : INTEGER;
    SIGNAL IncS2 : INTEGER;

    SIGNAL PWM_Count1 : INTEGER RANGE 1 TO Max;--500000;
    SIGNAL PWM_Count2 : INTEGER RANGE 1 TO Max;--500000;
    --------------------------------------------------------------------------------
    --Salida 2
    CONSTANT limMinS11 : INTEGER := 50000;
    CONSTANT limMaxS11 : INTEGER := 100000;

    CONSTANT limMinS22 : INTEGER := 24500;
    CONSTANT limMaxS22 : INTEGER := 120000;

    CONSTANT NoDivS11 : INTEGER := 60;
    CONSTANT NoDivS22 : INTEGER := 60;

    SIGNAL IncS11 : INTEGER;
    SIGNAL IncS22 : INTEGER;

    SIGNAL PWM_Count11 : INTEGER RANGE 1 TO Max;--500000;
    SIGNAL PWM_Count22 : INTEGER RANGE 1 TO Max;--500000;

    --------------------------------------------------------------------------------
    CONSTANT lim_deb : INTEGER := 8_999_999;

    --------------------------------------------------------------------------------
    --Encoder
    SIGNAL sclk : INTEGER RANGE 0 TO lim_deb := 0;--STD_LOGIC_VECTOR (8 DOWNTO 0); 
    --SALIDA 1
    SIGNAL sampledXR1, sampledXL1 : STD_LOGIC;
    SIGNAL XRout1, XLout1 : STD_LOGIC;
    SIGNAL sampledYU1, sampledYD1 : STD_LOGIC;
    SIGNAL YUout1, YDout1 : STD_LOGIC;

    SIGNAL lim1Salida1, lim2Salida1 : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
    SIGNAL limInt1Salida1, limInt2Salida1 : INTEGER RANGE 0 TO 59 := 0;
    SIGNAL Xs1, Ys1 : STD_LOGIC;

    --SALIDA 2

    SIGNAL sampledXR2, sampledXL2 : STD_LOGIC;
    SIGNAL XRout2, XLout2 : STD_LOGIC;
    SIGNAL sampledYU2, sampledYD2 : STD_LOGIC;
    SIGNAL YUout2, YDout2 : STD_LOGIC;

    SIGNAL lim1Salida2, lim2Salida2 : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
    SIGNAL limInt1Salida2, limInt2Salida2 : INTEGER RANGE 0 TO 59 := 0;
    SIGNAL Xs2, Ys2 : STD_LOGIC;

    SIGNAL conta_1250us : INTEGER RANGE 1 TO 5000000 := 1; -- pulso1 de 1250us@400Hz (0.25ms) 62500
    SIGNAL SAL_400Hz : STD_LOGIC; -- reloj de 400Hz

BEGIN
    --------------------------------------------------------------------------------
    --salida 1
    IncS1 <= (limMaxS1 - limMinS1)/NoDivS1;
    IncS2 <= (limMaxS2 - limMinS2)/NoDivS2;
    --salida 2
    IncS11 <= (limMaxS11 - limMinS11)/NoDivS11;
    IncS22 <= (limMaxS22 - limMinS22)/NoDivS22;

    --------------------------------------------------------------------------------
    GeneradorPWM1 : PROCESS (clk)
    BEGIN
        --------------------------------------------------------------------------------
        -- Lim = (180/3)=60
        -- min = 24100
        -- max = 110k
        -- inc = (24100-110000)/60=1432
        --------------------------------------------------------------------------------
        --SALIDA 1
        IF rising_edge(clk) THEN
            PWM_Count1 <= PWM_Count1 + 1;
            PWM_Count11 <= PWM_Count11 + 1;
        END IF;
        IF PWM_Count1 <= limMinS1 + (limInt1Salida1 * IncS1) THEN --min+(Lim*incremento) incremento = 7666
            servomotor1 <= '1';
        ELSE
            servomotor1 <= '0';
END IF;
        --SALIDA 2
        IF PWM_Count11 <= limMinS11 + (limInt1Salida2 * IncS11) THEN --min+(Lim*incremento) incremento = 7666
            servomotor11 <= '1';
        ELSE
            servomotor11 <= '0';
        END IF;

    END PROCESS GeneradorPWM1;
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    GeneradorPWM2 : PROCESS (clk)
    BEGIN
        --SALIDA 1
        IF rising_edge(clk) THEN
            PWM_Count2 <= PWM_Count2 + 1;
            PWM_Count22 <= PWM_Count22 + 1;
        END IF;
        IF PWM_Count2 <= limMinS2 + (limInt2Salida1 * IncS2) THEN --min+(Lim*incremento) incremento = 7666
            servomotor2 <= '1';
        ELSE
            servomotor2 <= '0';
        END IF;
        --SALIDA 
        IF PWM_Count22 <= limMinS22 + (limInt2Salida2 * IncS22) THEN --min+(Lim*incremento) incremento = 7666
            servomotor22 <= '1';
        ELSE
            servomotor22 <= '0';
        END IF;

    END PROCESS GeneradorPWM2;
    --------------------------------------------------------------------------------
    ControlLim : PROCESS (clk)
    BEGIN

        Xs1 <= XRout1 OR XLout1;
        Ys1 <= YDout1 OR YUout1;

        Xs2 <= XRout2 OR XLout2;
        Ys2 <= YDout2 OR YUout2;

        IF RESET = '0' THEN
            IF rising_edge(SAL_400Hz) THEN
                IF (Xs1 = '1') THEN
                    IF (XRin1 = '1' AND lim1Salida1 < "111100" AND limInt1Salida1 < 60) THEN --60
                        lim1Salida1 <= lim1Salida1 + '1';
                        limInt1Salida1 <= limInt1Salida1 + 1;
                    ELSIF (XLin1 = '1' AND lim1Salida1 >= "000001" AND limInt1Salida1 >= 1) THEN
                        lim1Salida1 <= lim1Salida1 - '1';
                        limInt1Salida1 <= limInt1Salida1 - 1;
                    END IF;
                END IF;
                IF (Ys1 = '1') THEN
                    IF (YUin1 = '1' AND lim2Salida1 < "111100" AND limInt2Salida1 < 60) THEN --60
                        lim2Salida1 <= lim2Salida1 + '1';
                        limInt2Salida1 <= limInt2Salida1 + 1;
                    ELSIF (YDin1 ='1' AND lim2Salida1 >= "000001" AND limInt2Salida1 >= 1) THEN
                        lim2Salida1 <= lim2Salida1 - '1';
                        limInt2Salida1 <= limInt2Salida1 - 1;
                    END IF;
                END IF;
            END IF;
            --salida 2

            IF (Xs2 = '1') THEN
                IF (XRin2 = '1' AND lim1Salida2 < "111100" AND limInt1Salida2 < 60) THEN --60
                    lim1Salida2 <= lim1Salida2 + '1';
                    limInt1Salida2 <= limInt1Salida2 + 1;
                ELSIF (XLin1 = '1' AND lim1Salida2 >= "000001" AND limInt1Salida2 >= 1) THEN
                    lim1Salida2 <= lim1Salida2 - '1';
                    limInt1Salida2 <= limInt1Salida2 - 1;
                END IF;
            END IF;
            IF (Ys2 = '1') THEN
                IF (YUin2 = '1' AND lim2Salida2 < "111100" AND limInt2Salida2 < 60) THEN --60
                    lim2Salida2 <= lim2Salida2 + '1';
                    limInt2Salida2 <= limInt2Salida2 + 1;
                ELSIF (YDin1 ='1' AND lim2Salida2 >= "000001" AND limInt2Salida2 >= 1) THEN
                    lim2Salida2 <= lim2Salida2 - '1';
                    limInt2Salida2 <= limInt2Salida2 - 1;
                END IF;
            END IF;

        ELSE
            lim1Salida1 <= "000000";
            limInt1Salida1 <= 0;
            lim2Salida1 <= "000000";
            limInt2Salida1 <= 0;
            
            lim1Salida2 <= "000000";
            limInt1Salida2 <= 0;
            lim2Salida2 <= "000000";
            limInt2Salida2 <= 0;

        END IF;

        LedLim1 <= lim1Salida1;
        LedLim2 <= lim2Salida1;

        LedLim11 <= lim1Salida2;
        LedLim22 <= lim2Salida2;

    END PROCESS;
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    debouncer_botones : PROCESS (clk, XRin1, XLin1) BEGIN

        IF clk'event AND clk = '1' THEN
            sampledXR1 <= XRin1;
            sampledXL1 <= XLin1;
            sampledYU1 <= YUin1;
            sampledYD1 <= YDin1;
            
            sampledXR2 <= XRin2;
            sampledXL2 <= XLin2;
            sampledYU2 <= YUin2;
            sampledYD2 <= YDin2;

            -- clock is divided to 1MHz
            -- samples every 1uS to check if the input is the same as the sample
            -- if the signal is stable, the debouncer should output the signal
            IF sclk = lim_deb THEN

                -- XRout1
                IF sampledXR1 = XRin1 THEN
                    XRout1 <= XRin1;
                END IF;
                --XLout1
                IF sampledXL1 = XLin1 THEN
                    XLout1 <= XLin1;
                END IF;
                -- YUout1
                IF sampledYU1 = YUin1 THEN
                    YUout1 <= YUin1;
                END IF;
                --YDout1
                IF sampledYD1 =
                    YDin1 THEN
                    YDout1 <= YDin1;
                END IF;
                
                -- XRout2
                IF sampledXR2 = XRin2 THEN
                    XRout2 <= XRin2;
                END IF;
                --XLout2
                IF sampledXL2 = XLin2 THEN
                    XLout2 <= XLin2;
                END IF;
                -- YUout2
                IF sampledYU2 = YUin2 THEN
                    YUout2 <= YUin2;
                END IF;
                --YDout2
                IF sampledYD2 = YDin2 THEN
                    YDout2 <= YDin2;
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