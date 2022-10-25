------------------------------------------------------------------------------------------
-- Contador de ms ascendente y descendente, con reset as�ncrono 
-- y pwm manual con per�odo de 10s con salida a un led como indicador visual.
------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
-- Declaraci�n de la entidad
ENTITY Contador IS
    GENERIC (freq : INTEGER := 15);
    PORT (
        UpDown : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- botones para subir y bajar los ms
        CLK : IN STD_LOGIC; -- reloj de 50MHz para la nexys 2 y 100MHz para nexys 3
        RESET : IN STD_LOGIC; -- reset
        SALED : OUT STD_LOGIC; -- salida del led testigo
        -- "abcdefgP"
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display 
        AN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- �nodos del display
        RGB : OUT STD_LOGIC_VECTOR(1 TO 3); -- salida a leds RGB
        BEEPtest : IN STD_LOGIC; -- bot�n de prueba para la salida a bocina
        BEEP : OUT STD_LOGIC -- salida a bocina
    );
END Contador;
-- Declaraci�n de la arquitectura
ARCHITECTURE Behavioral OF Contador IS
    -- Declaraci�n de se�ales de los divisores
    SIGNAL Conta_500us : INTEGER RANGE 1 TO 25_000 := 1; -- uso en el pulso de 1ms (pro. divisor 1ms)
    -- para la nexys 2 25000, si se usa la nexys 3 cambiar a 50000.
    SIGNAL contadors : INTEGER RANGE 1 TO 6_250 := 1; -- pulso1 de 0.25ms (pro. divisor �nodos) 
    -- para la nexys 2 6250, si se usa la nexys 3 cambiar a 1250
    SIGNAL SAL_1ms, SAL_250us : STD_LOGIC := '0'; --igual que pulso y pulso1, respectivamente
    -- Declaraci�n de se�ales de los contadores
    SIGNAL CONT : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0'); -- 16 bits (proc. conteo)
    SIGNAL CONT2 : INTEGER := 0; -- cambia cont de 16 bits a entero (proc. conteo)
    -- Declaraci�n de se�ales de la asignaci�n de U-D-C-UM
    SIGNAL P : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0'); -- asigna UNI, DEC,CEN, MIL
    SIGNAL UNI, DEC, CEN, MIL : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0'); -- digitos unidades, decenas,
    -- centenas y unidad de millar
    -- Declaraci�n de se�ales de la multiplexaci�n y asignaci�n de U-D-C-UM al display
    SIGNAL SEL : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00"; -- selector de barrido
    SIGNAL D : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0'); -- sirve para almacenar los valores del display
    -- Declaraci�n de se�ales de la base de tiempo
    SIGNAL PERIOD : INTEGER RANGE 0 TO 2499 := 0; -- periodo de 2.5 segundos (base de tiempo en ms para el PWM) 
    -- Declaraci�n de se�al para el BEEP
    SIGNAL sound : STD_LOGIC_VECTOR (freq DOWNTO 0) := (OTHERS => '0'); -- vector para la generaci�n del sonido beep 
BEGIN
    ---------------------DIVISOR 1ms------------------------------------
    -- en este proceso se genera una se�al "SAL_1ms" de 1ms de periodo para el conteo de ms
    PROCESS (reset, CLK)
    BEGIN
        IF reset = '1' THEN
            Conta_500us <= 1; -- se reinicializa
        ELSIF (CLK'event AND CLK = '1') THEN
            IF (Conta_500us = 25_000) THEN -- pregunta si ya se alcanz� 0.5ms (nexys2)
                --if(Conta_500us = 50000) then -- pregunta si ya se alcanz� 0.5ms (nexys3)
                SAL_1ms <= NOT SAL_1ms; --se genera 0.5ms en bajo y 0.5ms en alto
                Conta_500us <= 1; --reinicia el Contador a 1
            ELSE
                Conta_500us <= Conta_500us + 1;
            END IF;
        END IF;
    END PROCESS; --termina el proceso de generaci�n de se�al 1ms
    --------------------------------CONTEO-----------------------------------
    -- con Up se incrementa y Down decrementa en el rango 0 < CONT < 9999
    PROCESS (RESET, SAL_1ms, UpDown, CONT)
    BEGIN
        IF RESET = '1' THEN
            CONT <= (OTHERS => '0');
        ELSE
            IF (SAL_1ms'EVENT AND SAL_1ms = '1') THEN -- reloj SAL de 1ms
                IF UpDown = "01" THEN -- decrementa (Down)
                    IF (CONT = x"0000") THEN -- compara contra 0
                        CONT <= CONT; -- si lleg� a cero mantiene el cero
                    ELSE
                        CONT <= CONT - '1'; -- sino decrementa
                    END IF;
                ELSIF UpDown = "10" THEN --incrementa
                    IF (CONT >= "0010011100001111") THEN -- compara contra 9,999 
                        -- (270F hex)
                        CONT <= CONT; -- si llego a 9999 mantiene 9999
                    ELSE
                        CONT <= CONT + '1'; -- sino incrementa
                    END IF;
                ELSE --cubre UpDown="00" y UpDown="11"
                    CONT <= CONT;
                END IF;
            END IF;
        END IF;
        CONT2 <= CONV_INTEGER(CONT); --se convierte CONT a entero
    END PROCESS;
    -----------------------------RGB--------------------------------------
    -- 0< R <3333 3333< G <6666 6666< B <9999
    PROCESS (CONT2)
    BEGIN
        -- RGB
        IF CONT2 >= 0 AND CONT2 <= 3333 THEN
            RGB <= "100";

        ELSIF CONT2 > 3333 AND CONT2 <= 6666 THEN
            RGB <= "010";
        ELSIF CONT2 > 6666 AND CONT2 <= 9999 THEN
            RGB <= "001";
        ELSE
            RGB <= "000";
        END IF;
    END PROCESS;
    -----------------------------sound2BEEP-------------------------------
    -- BEEP <= sound(15)
    PROCESS (clk, sound(freq), BEEPtest, CONT2)
    BEGIN
        -- RGB
        IF (CLK'event AND CLK = '1') THEN
            sound <= sound + '1';
        END IF;
        -- BEEP
        IF (CONT2 >= 3325 AND CONT2 <= 3341) OR (CONT2 >= 6658 AND CONT2 <= 6674) OR (CONT2 >= 6658 AND CONT2 <= 6674)) THEN
            BEEP <= sound(freq);
        ELSE
            BEEP <= '0';
        END IF;
    END PROCESS;

    --------------------PWM CONTROLADO POR CONTADOR DE ms/4------------------------
    PROCESS (RESET, SAL_1ms, PERIOD)
    BEGIN
        IF (RESET = '1' OR PERIOD >= 2_499) THEN --9999="0010011100001111"
            PERIOD <= 0; --(others=>'0');
        ELSIF (SAL_1ms'EVENT AND SAL_1ms = '1') THEN -- reloj SAL_1ms de 1ms
            PERIOD <= PERIOD + 1;
            IF (PERIOD < CONT2/4) THEN
                SALED <= '1'; -- Salida a led testigo
                -- if (PERIOD <= CONT) then SALED <='1'; -- Salida a led testigo
            ELSE
                SALED <= '0';
            END IF;
        END IF;
    END PROCESS; --fin del proceso PWM
    -----------CONVERTIR DE BIN A BCD------------------
    -- Este proceso contiene un algoritmo recorre y suma 3 para convertir un n�mero binario a bcd, que se manda a
    -- los displays. El algoritmo consiste en desplazar (shift) el vector inicial (en binario) el n�mero de veces seg�n sea
    -- el n�mero de bits, y cuando alguno de los bloques de 4 bits (U-D-C-UM, que es el n�mero de bits necesarios 
    -- para que cuente de 0 a 9 por cifra) sea igual o mayor a 5 (por eso el >4) se le debe sumar 3 a ese bloque, 
    -- despu�s se continua desplazando hasta que otro (o el mismo) bloque cumpla con esa condici�n y se le sumen 3.
    -- Inicialmente se rota 3 veces porque es el n�mero m�nimo de bits que debe tener para que sea igual o mayor a 5.
    -- Finalmente se asigna a otro vector, el vector ya convertido, que cuenta con 4 bloques para las 4 cifras de 4 bits 
    -- cada una.
    PROCESS (CONT)
        VARIABLE UM_C_D_U : STD_LOGIC_VECTOR(29 DOWNTO 0);
        --30 bits para separar las U.Millar-Centenas-Decenas-Unidades
    BEGIN
        --ciclo de inicializaci�n
        FOR I IN 0 TO 29 LOOP --
            UM_C_D_U(I) := '0'; -- se inicializa con 0
        END LOOP;
        UM_C_D_U(13 DOWNTO 0) := CONT(13 DOWNTO 0); --contador de 14 bits
        -- UM_C_D_U(17 DOWNTO 4):=CONT(13 downto 0); --contador de 14 bits, carga desde
        -- el shift4
        --ciclo de asignaci�n UM-C-D-U
        FOR I IN 0 TO 13 LOOP
            -- FOR I IN 0 TO 9 LOOP -- si carga desde shift4 solo hace 10 veces el ciclo shift add
            -- los siguientes condicionantes comparan (>=5) y suman 3
            IF UM_C_D_U(17 DOWNTO 14) > 4 THEN -- U 
                UM_C_D_U(17 DOWNTO 14) := UM_C_D_U(17 DOWNTO 14) + 3;
            END IF;
            IF UM_C_D_U(21 DOWNTO 18) > 4 THEN -- D
                UM_C_D_U(21 DOWNTO 18) := UM_C_D_U(21 DOWNTO 18) + 3;
            END IF;
            IF UM_C_D_U(25 DOWNTO 22) > 4 THEN -- C
                UM_C_D_U(25 DOWNTO 22) := UM_C_D_U(25 DOWNTO 22) + 3;
            END IF;

            IF UM_C_D_U(29 DOWNTO 26) > 4 THEN -- UM
                UM_C_D_U(29 DOWNTO 26) := UM_C_D_U(29 DOWNTO 26) + 3;
            END IF;
            -- realiza el corrimiento
            UM_C_D_U(29 DOWNTO 1) := UM_C_D_U(28 DOWNTO 0);
        END LOOP;
        P <= UM_C_D_U(29 DOWNTO 14); -- guarda en P y en seguida se separan UM-C-D-U
    END PROCESS;
    --UNIDADES 
    UNI <= P(3 DOWNTO 0);
    --DECENAS 
    DEC <= P(7 DOWNTO 4);
    --CENTENAS
    CEN <= P(11 DOWNTO 8);

    --MILLARES 
    MIL <= P(15 DOWNTO 12);
    -------------------DIVISOR �NODOS-------------------
    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF (contadors = 6250) THEN --cuenta 0.125ms (50MHz=6250)
                -- if (contadors = 12500) then --cuenta 0.125ms (100MHz=12500)
                SAL_250us <= NOT(SAL_250us); --genera un barrido de 0.25ms
                contadors <= 1;
            ELSE
                contadors <= contadors + 1;
            END IF;
        END IF;
    END PROCESS; -- fin del proceso Divisor �nodos
    --------------------MULTIPLEXOR---------------------
    PROCESS (SAL_250us, sel, UNI, DEC, CEN, MIL)
    BEGIN
        IF SAL_250us'EVENT AND SAL_250us = '1' THEN
            SEL <= SEL + '1';
            CASE(SEL) IS
                WHEN "00" => AN <= "0111";
                D <= UNI; -- UNIDADES
                WHEN "01" => AN <= "1011";
                D <= DEC; -- DECENAS
                WHEN "10" => AN <= "1101";
                D <= CEN; -- CENTENAS
                WHEN "11" => AN <= "1110";
                D <= MIL; -- UNIDAD DE MILLAR
                WHEN OTHERS => AN <= "1110";
                D <= MIL; -- UNIDAD DE MILLAR
            END CASE;
        END IF;
    END PROCESS; -- fin del proceso Multiplexor
    --------------------DISPLAY---------------------
    PROCESS (D)
    BEGIN
        CASE(D) IS -- abcdefgP
            WHEN "0000" => DISPLAY <= "00000011"; --0
            WHEN "0001" => DISPLAY <= "10011111"; --1
            WHEN "0010" => DISPLAY <= "00100101"; --2
            WHEN "0011" => DISPLAY <= "00001101"; --3
            WHEN "0100" => DISPLAY <= "10011001"; --4
            WHEN "0101" => DISPLAY <= "01001001"; --5
            WHEN "0110" => DISPLAY <= "01000001"; --6
            WHEN "0111" => DISPLAY <= "00011111"; --7
            WHEN "1000" => DISPLAY <= "00000001"; --8
            WHEN "1001" => DISPLAY <= "00001001"; --9
            WHEN OTHERS => DISPLAY <= "11111111"; --apagado
        END CASE;
    END PROCESS; -- fin del proceso Display
    ------------------------------------------------
END Behavioral; -- fin de la arquitectura