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
        buttonAdd : IN STD_LOGIC;
        buttonDown : IN STD_LOGIC;
        --LED : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        Conte : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);

        sensor : IN STD_LOGIC; --entrada del sensor infrarrojo
        Motor_Interrupcion : OUT STD_LOGIC; --salida a led indicador de la interrupcion 
        Seg_Display : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --segmentos del display 
        reset : IN STD_LOGIC; --Boton de reset 
        CLK : IN STD_LOGIC; --reloj 50 Mhz
        PWM : OUT STD_LOGIC; --salida a servomotor
        An : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) --anodos del display 
    );

END ENTITY Control;

ARCHITECTURE Behavioral OF Control IS
    --signals
    SIGNAL Contador : INTEGER RANGE 0 TO 20 := 0; --Contador para el numero de objetos detectados 
    --CONSTANT limite : INTEGER := 15; --limite numero de obj que pueden pasar hasta que se interrumpa el acceso 
    SIGNAL conta_1250us : INTEGER RANGE 1 TO 10_000_000 := 1; -- pulso1 de 1250us@400Hz (0.25ms)
    SIGNAL SAL_400Hz : STD_LOGIC; --salida 2.5ms,
    SIGNAL DispVal : INTEGER RANGE 0 TO 25; -- almacena los valores del display 
    SIGNAL OP1, OP2, OP3, OP_DATA : STD_LOGIC;
    SIGNAL SEL : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00"; -- selector de barrido display
    --------------------------------------------------------------------------------
    --Servomotor
    SIGNAL EncOut : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
    SIGNAL selector : STD_LOGIC := '0'; --Selector para el estado del servo, 0° o 90°
    SIGNAL PWM_Count : INTEGER RANGE 1 TO 500000; --500000 // contador para pwm 
    --------------------------------------------------------------------------------
    --Encoder
    SIGNAL sclk : STD_LOGIC_VECTOR (6 DOWNTO 0);
    SIGNAL sampledA, sampledB : STD_LOGIC;
    SIGNAL Aout, Bout : STD_LOGIC;
    SIGNAL lim : INTEGER RANGE 0 TO 21 := 1;
    TYPE stateType IS (idle, R1, R2, R3, L1, L2, L3, add, sub);
    SIGNAL curState, nextState : stateType;
BEGIN
    Conte <= EncOut;
    --------------------------------------------------------------------------------
    Conteo : PROCESS (OP_DATA, SAL_400Hz, reset, contador) BEGIN

        IF (reset = '0') THEN --No se presiona el boton de reset
            IF rising_edge(OP_DATA) AND contador /= lim THEN --flanco ascendente del sensor (Deteccion de un obj)
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
    Debouncer : PROCESS (CLK) BEGIN

        IF rising_edge(CLK) THEN
            OP1 <= sensor;
            OP2 <= OP1;
            OP3 <= OP2;
        END IF;
    END PROCESS;
    OP_DATA <= OP1 AND OP2 AND OP3;
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
    PROCESS (SAL_400Hz, sel) BEGIN

        IF SAL_400Hz'EVENT AND SAL_400Hz = '1' THEN
            SEL <= SEL + '1';

            IF (contador <= 9) THEN
                CASE(SEL) IS
                    WHEN "00" => AN <= "1110";
                    DispVal <= contador; -- UNIDADES
                    WHEN "01" => AN <= "1101";
                    DispVal <= 0; -- DECENAS
                    WHEN OTHERS => AN <= "1111";
                    DispVal <= 0; -- signo
                END CASE;
            ELSE
                CASE(SEL) IS
                    WHEN "00" => AN <= "1110";
                    DispVal <= contador - 10; -- UNIDADES
                    WHEN "01" => AN <= "1101";
                    DispVal <= 1; -- DECENAS
                    WHEN OTHERS => AN <= "1111";
                    DispVal <= 0; -- signo
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    --------------------MULTIPLEXOR---------------------
    PROCESS (DispVal) BEGIN
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
            WHEN OTHERS => Seg_Display <= "11111111"; --apagado
        END CASE;
    END PROCESS; -- fin del proceso Display
    --    -----------------------------------------------

    servomotor : PROCESS (clk, pwm_count, selector)
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

    Incrementos : PROCESS (lim, buttonAdd, buttonDown)
    BEGIN

        IF (buttonAdd'EVENT AND buttonAdd = '1') THEN

            IF (lim < 20) THEN
                lim <= lim + 1;
                EncOut <= EncOut + '1';
            ELSE
                lim <= lim;
            END IF;
        END IF;

         IF (buttonDown'EVENT AND buttonDown = '1') then 
            IF (lim > 1 AND lim > contador) THEN
                lim <= lim - 1;
                EncOut <= EncOut - '1';
            ELSE
                lim <= lim;
            END IF;
        END IF;
    END PROCESS;
    --    debouncer_encoder : PROCESS (clk)
    --    BEGIN
    --        IF clk'event AND clk = '1' THEN
    --            sampledA <= Ain;
    --            sampledB <= Bin;
    --            -- clock is divided to 1MHz
    --            -- samples every 1uS to check if the input is the same as the sample
    --            -- if the signal is stable, the debouncer should output the signal
    --            IF sclk = "1100100" THEN
    --                -- Aout
    --                IF sampledA = Ain THEN
    --                    Aout <= Ain;
    --                END IF;
    --                -- Bout
    --                IF sampledB = Bin THEN
    --                    Bout <= Bin;
    --                END IF;
    --                sclk <= "0000000";
    --            ELSE
    --                sclk <= sclk + 1;
    --            END IF;
    --        END IF;
    --    END PROCESS;
    --clk and button
    --    clock : PROCESS (clk, reset)
    --    BEGIN
    --        -- if the rotary button is pressed the count resets
    --        IF (reset = '1') THEN
    --            curState <= idle;
    --            EncOut <= "00000";
    --        ELSIF (clk'event AND clk = '1') THEN
    --            -- detect if the shaft is rotated to right or left
    --            -- right: add 1 to the position at each click
    --            -- left: subtract 1 from the position at each click
    --            IF curState /= nextState THEN
    --                IF (curState = add) THEN
    --                    IF EncOut < "01111" THEN
    --                        EncOut <= EncOut + 1;
    --                        IF (lim < 20 ) THEN
    --                            lim <= lim + 1;
    --                        ELSE
    --                            lim <= lim;
    --                        END IF;
    --
    --                    ELSE
    --                        EncOut <= "00000";
    --                    END IF;
    --                ELSIF (curState = sub) THEN
    --                    IF EncOut > "00000" THEN
    --                        EncOut <= EncOut - 1;
    --                        IF (lim > 1 and lim >= contador ) THEN
    --                            lim <= lim - 1;
    --                        ELSE
    --                            lim <= lim;
    --                        END IF;
    --
    --                    ELSE
    --                        EncOut <= "01111";
    --                    END IF;
    --                ELSE
    --                    EncOut <= EncOut;
    --                END IF;
    --
    --            ELSE
    --                EncOut <= EncOut;
    --            END IF;
    --            curState <= nextState;
    --        END IF;
    --    END PROCESS;
    --    -----FSM process
    --    next_state : PROCESS (curState, Aout, Bout)
    --    BEGIN
    --        CASE curState IS
    --                --detent position
    --            WHEN idle =>
    --                LED <= "00";
    --                IF Bout = '0' THEN
    --                    nextState <= R1;
    --                ELSIF Aout = '0' THEN
    --                    nextState <= L1;
    --                ELSE
    --                    nextState <= idle;
    --                END IF;
    --                -- start of right cycle
    --                --R1
    --            WHEN R1 =>
    --                LED <= "01";
    --                IF Bout = '1' THEN
    --                    nextState <= idle;
    --                ELSIF Aout = '0' THEN
    --                    nextState <= R2;
    --                ELSE
    --                    nextState <= R1;
    --                END IF;
    --                --R2
    --            WHEN R2 =>
    --                LED <= "01";
    --                IF Aout = '1' THEN
    --                    nextState <= R1;
    --                ELSIF Bout = '1' THEN
    --                    nextState <= R3;
    --                ELSE
    --                    nextState <= R2;
    --                END IF;
    --                --R3
    --            WHEN R3 =>
    --                LED <= "01";
    --                IF Bout = '0' THEN
    --                    nextState <= R2;
    --                ELSIF Aout = '1' THEN
    --
    --                    nextState <= add;
    --                ELSE
    --                    nextState <= R3;
    --                END IF;
    --            WHEN add =>
    --                LED <= "01";
    --                nextState <= idle;
    --                -- start of left cycle
    --                --L1
    --            WHEN L1 =>
    --                LED <= "10";
    --                IF Aout = '1' THEN
    --                    nextState <= idle;
    --                ELSIF Bout = '0' THEN
    --                    nextState <= L2;
    --                ELSE
    --                    nextState <= L1;
    --                END IF;
    --                --L2
    --            WHEN L2 =>
    --                LED <= "10";
    --                IF Bout = '1' THEN
    --                    nextState <= L1;
    --                ELSIF Aout = '1' THEN
    --                    nextState <= L3;
    --                ELSE
    --                    nextState <= L2;
    --                END IF;
    --                --L3
    --            WHEN L3 =>
    --                LED <= "10";
    --                IF Aout = '0' THEN
    --                    nextState <= L2;
    --                ELSIF Bout = '1' THEN
    --                    nextState <= sub;
    --                ELSE
    --                    nextState <= L3;
    --                END IF;
    --            WHEN sub =>
    --                LED <= "10";
    --                nextState <= idle;
    --            WHEN OTHERS =>
    --                LED <= "11";
    --                nextState <= idle;
    --        END CASE;
    --    END PROCESS;

END Behavioral;