--EXTRA
--Codigo Para controlar tres motores y muestra su estado en una LCD 
--Solo se enciende un motor a la vez
--Se apagan solo con un boton de reset
--Hay 3 opciones, se enciende M1 o M2 o M3, pero todos se apagan con reset
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY LCD IS
    PORT (
        CLOCK : IN STD_LOGIC; --Reloj 50MHz amiba
        --BOTONES 
        --IN_ButtonM1, IN_ButtonM2, IN_ButtonM3 : IN STD_LOGIC;
        PB1, PB2, PB3 : IN STD_LOGIC;

        --btn_in, btn_in1 : IN STD_LOGIC; --Botones (entrada)
        --btn_out, btn1_out : INOUT STD_LOGIC; --Se�al de salida botones       
        ---MOTORES
        M1, M2, M3 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --Salidas a leds indicadores
        ReleM1, ReleM2, ReleM3 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --Salida para relevadores que controlan los motores

        --Pines para LCD
        LCD_RS : OUT STD_LOGIC; --	Comando, escritura
        LCD_RW : OUT STD_LOGIC := '0'; -- LECTURA/ESCRITURA
        LCD_E : OUT STD_LOGIC; -- ENABLE
        DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"; -- PINES DATOS

        Rest : IN STD_LOGIC --Reset general
    );
END LCD;
ARCHITECTURE Behavioral OF LCD IS
    -----SIGNALS FOR LCD--------------
    --signal FSM
    TYPE STATE_TYPE IS (
        RST, ST0, ST1, ST2, SET_DEFI, SHOW1, SHOW2, CLEAR, ENTRY, n, o, vacio, M, uno, F, FF,
        Espacio, Estados, CambioFila, dos, tres, espacio2, DosPuntos
    );
    SIGNAL State, Next_State : STATE_TYPE;

    SIGNAL CONT1 : STD_LOGIC_VECTOR(23 DOWNTO 0) := X"000000"; -- 16,777,216 = 0.335s MAX
    SIGNAL CONT2 : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000"; -- 32 = 0.64us
    SIGNAL RESET : STD_LOGIC := '0';
    SIGNAL READY : STD_LOGIC := '0';
    --contadores para reutilizar letras
    SIGNAL Ms : INTEGER RANGE 0 TO 20 := 0;
    --------------------------------
    SIGNAL BTN0_REG1, BTN0_REG2, PULSO_BTN0, Q_T, BTN1_REG1, BTN1_REG2, PULSO_BTN1, Q_T1 : STD_LOGIC;
    CONSTANT CNT_SIZE : INTEGER := 19;
    SIGNAL btn_prev, btn_prev1 : STD_LOGIC := '0';
    SIGNAL counter, counter1 : STD_LOGIC_VECTOR(CNT_SIZE DOWNTO 0) := (OTHERS => '0');
    SIGNAL btn0, btn1 : STD_LOGIC;
    SIGNAL EstadosM : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    --DEBOUNCER
    CONSTANT lim_deb : INTEGER := 6_999_999;
    SIGNAL sclk : INTEGER RANGE 0 TO lim_deb := 0;--STD_LOGIC_VECTOR (8 DOWNTO 0); 
    SIGNAL sampledBM1, sampledBM2, sampledBM3 : STD_LOGIC;
    SIGNAL OUT_ButtonM1, OUT_ButtonM2, OUT_ButtonM3 : STD_LOGIC;

    SIGNAL listo : STD_LOGIC := '0';

    SIGNAL conta_1250us : INTEGER RANGE 0 TO 50000000 := 0;

    --MAQUINA DE ESTADOS HDL
    -- BINARY ENCODED state machine: Sreg0
    ATTRIBUTE ENUM_ENCODING : STRING;
    TYPE Sreg0_type IS (
        S1, S2, S3, S4
    );
    ATTRIBUTE ENUM_ENCODING OF Sreg0_type : TYPE IS
    "00 " & -- S1
    "01 " & -- S2
    "10 " & -- S3
    "11"; -- S4

    SIGNAL Sreg0, NextState_Sreg0 : Sreg0_type;

BEGIN
    -----------------LCD-----------------------
    -------------------------------------------------------------------
    --Contador de Retardos CONT1--
    PROCESS (CLOCK, RESET)
    BEGIN
        IF RESET = '1' THEN
            CONT1 <= (OTHERS => '0');
        ELSIF CLOCK'event AND CLOCK = '1' THEN
            CONT1 <= CONT1 + 1;
        END IF;
    END PROCESS;
    -------------------------------------------------------------------
    --Contador para Secuencias CONT2--
    PROCESS (CLOCK, READY)
    BEGIN
        IF CLOCK = '1' AND CLOCK'event THEN
            IF READY = '1' THEN
                CONT2 <= CONT2 + 1;
            ELSE
                CONT2 <= "00000";
            END IF;
        END IF;
    END PROCESS;
    -------------------------------------------------------------------
    --Actualizaci?n de estados--
    act_Estados : PROCESS (CLOCK, Next_State)
    BEGIN
        IF CLOCK = '1' AND CLOCK'event THEN
            State <= Next_State;
        END IF;
    END PROCESS;
    ------------------------------------------------------------------
    lcd_estados : PROCESS (CONT1, CONT2, State, CLOCK, Rest)
    BEGIN

        IF Rest = '1' THEN
            Next_State <= RST;
        ELSIF CLOCK = '0' AND CLOCK'event THEN
            CASE State IS

                WHEN RST => -- Estado de reset
                    IF CONT1 = X"000000"THEN --0s
                        LCD_RS <= '0';
                        LCD_E <= '0';

                        Next_State <= clear;
                        listo <= '0';
                        Ms <= 0;
                    ELSE
                        Next_State <= clear;
                        listo <= '0';
                        Ms <= 0;
                    END IF;

                WHEN ST0 => --Primer estado de espera por 25ms (20ms=0F4240=1000000)(15ms=0B71B0=750000) --SET 1
                    IF CONT1 = X"2625A0" THEN -- 2,500,000=50ms
                        READY <= '1';
                        DATA <= "00110000"; -- FUNCTION SET 8BITS, 2 LINEAS, 5X7
                        Next_State <= ST0;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN--rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= ST1;
                    ELSE
                        Next_State <= ST0;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN ST1 => --Segundo estado de espera por 5ms --SET2
                    IF CONT1 = X"03D090" THEN -- 250,000 = 5ms
                        READY <= '1';
                        DATA <= "00110000"; -- FUNCTION SET
                        Next_State <= ST1;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= ST2;
                    ELSE
                        Next_State <= ST1;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
                WHEN ST2 => --Tercer estado de espera por 100us  SET 3
                    IF CONT1 = X"0035E8" THEN -- 5000 = 100us  = x35E8)
                        READY <= '1';
                        DATA <= "00110000"; -- FUNCTION SET
                        Next_State <= ST2;
                        --BTN_OUT<='1';
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= SET_DEFI;
                    ELSE
                        Next_State <= ST2;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN SET_DEFI => --Cuarto paso, se asignan lineas logicas, modo de bits (8) y #caracteres(5x8)
                    --SET DEFINITIVO
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "00111000"; -- FUNCTION SET(lineas,caracteres,bits)
                        Next_State <= SET_DEFI;

                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= SHOW1;
                        LCD_RS <= '0';
                    ELSE
                        Next_State <= SET_DEFI;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
                WHEN SHOW1 => --Quinto paso, se apaga el display por unica ocasion
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "00001000"; -- SHOW, APAGAR DISPLAY POR UNICA OCASION 
                        Next_State <= SHOW1;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        -----CLEAR, LIMPIAR DISPLAY
                        Next_State <= CLEAR;
                    ELSE
                        Next_State <= SHOW1;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN CLEAR => --SEXTO PASO, SE LIMPIA EL DISPLAY 

                    IF CONT1 = X"FFFFFF" THEN -- 
                        READY <= '1';
                        LCD_RS <= '0';
                        DATA <= "00000001"; -- CLEAR
                        Next_State <= CLEAR;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= ENTRY;
                    ELSE
                        Next_State <= CLEAR;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN ENTRY => --SEPTIMO PASO, CONFIGURAR MODO DE ENTRADA
                    --ENTRY MODE
                    IF CONT1 = X"3D090" THEN --espera por 5ms 250,000  3D090   E4E1C0
                        READY <= '1';
                        DATA <= "00000110"; -- ENTRY MODE, se mueve a la derecha(escritura), no se desplaza(barrido)
                        Next_State <= ENTRY;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= SHOW2;
                    ELSE
                        Next_State <= ENTRY;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN SHOW2 => --OCTAVO PASO, ENCENDER LA LCD Y CONFIGURAR CURSOR, PARPADEO
                    ---SHOW DEFINITIVO
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "00001111"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
                        Next_State <= SHOW2;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '1';
                        Next_State <= M;
                        Ms <= 0;
                    ELSE
                        Next_State <= SHOW2;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --MOTOR
                WHEN M => --M Mayuscula
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "01001101"; -- M mayuscula
                        Next_State <= M;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';

                        IF Ms = 0 THEN --NOTA Declarar Ms y Estados de los motores
                            Next_State <= uno;
                        ELSIF Ms = 1 THEN
                            Next_State <= dos;
                        ELSIF Ms = 2 THEN
                            Next_State <= tres;
                        END IF;
                        Ms <= Ms + 1;
                    ELSE
                        Next_State <= M;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN O => --O Mayuscula
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "01001111"; -- O Mayuscula
                        Next_State <= O;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';

                        CASE (Ms - 1) IS
                            WHEN 0 => --Se ha Mostrado la M del Motor uno 
                                IF EstadosM = "100" THEN --Motor 1 encendido 
                                    Next_State <= N; --ON 
                                ELSE
                                    Next_State <= F; --OFF
                                END IF;
                            WHEN 1 => --Se ha Mostrado la M del Motor dos
                                IF EstadosM = "010" THEN --Motor 2 encendido 
                                    Next_State <= N; --ON 
                                ELSE
                                    Next_State <= F; --OFF
                                END IF;
                            WHEN 2 => --Se ha Mostrado la M del Motor tres
                                IF EstadosM = "001" THEN --Motor 3 encendido 
                                    Next_State <= N; --ON 
                                ELSE
                                    Next_State <= F; --OFF
                                END IF;

                            WHEN OTHERS => Next_State <= O;
                        END CASE;

                    ELSE
                        Next_State <= O;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN N => --N Mayuscula
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "01001110"; -- N Mayuscula
                        Next_State <= N;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';

                        CASE (Ms - 1) IS

                            WHEN 0 => --Se ha Mostrado el estado del motor uno
                                Next_State <= Espacio2; --Espacio entre estado M1 y M2

                            WHEN 1 => --Se ha Mostrado la M del Motor dos
                                Next_State <= CambioFila; --ON 

                            WHEN 2 => --Se ha Mostrado la M del Motor tres
                                Next_State <= clear; --ON 

                            WHEN OTHERS =>
                        END CASE;
                    ELSE
                        Next_State <= N;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN F => --F mayuscula
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "01000110"; -- primera F de OFF
                        Next_State <= F;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= FF;
                    ELSE
                        Next_State <= F;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN FF => --F mayuscula
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "01000110"; -- segunda F de OFF
                        Next_State <= FF;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';

                        CASE (Ms - 1) IS
                            WHEN 0 => --Se ha Mostrado el estado del motor uno
                                Next_State <= Espacio2; --Espacio entre estado M1 y M2

                            WHEN 1 => --Se ha Mostrado la M del Motor dos
                                Next_State <= CambioFila; --Salta a fila 2 para mostrar el estado de M3

                            WHEN 2 => --Se ha Mostrado la M del Motor tres
                                Next_State <= clear; --Limpia la pantalla para recibir nuevos estados

                            WHEN OTHERS =>
                        END CASE;

                    ELSE
                        Next_State <= FF;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    -------------------------------------------------------------------------

                WHEN Espacio => --Espacio entre caracteres
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        LCD_RS <= '0';
                        DATA <= "00010100";
                        Next_State <= Espacio;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '1'; ---enviar datos
                        Next_State <= O;
                    ELSE
                        Next_State <= Espacio;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN Espacio2 => --Espacio entre estado de M1 y M2
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        LCD_RS <= '0';
                        DATA <= "00010100";
                        Next_State <= Espacio2;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '1'; ---enviar datos
                        Next_State <= M;
                    ELSE
                        Next_State <= Espacio2;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN CambioFila => --Cambio Fila
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        LCD_RS <= '0';
                        DATA <= "11000000"; -- Cambia de fila 
                        Next_State <= CambioFila;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '1';
                        Next_State <= M;
                    ELSE
                        Next_State <= CambioFila;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN DosPuntos => --Dos puntos
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "00111010"; -- numero DosPuntos
                        Next_State <= DosPuntos;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '0'; --comandos
                        Next_State <= Espacio;
                    ELSE
                        Next_State <= DosPuntos;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
                    ---------------------------------------------	NUMEROS	----------------------------
                WHEN uno => --NUMERO 1
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "00110001"; -- numero uno
                        Next_State <= uno;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= DosPuntos;
                    ELSE
                        Next_State <= uno;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN dos => --NUMERO 2
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "00110010"; -- numero dos
                        Next_State <= dos;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= DosPuntos;
                        LCD_RS <= '1';
                    ELSE
                        Next_State <= dos;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN tres => --NUMERO 3
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "00110010"; -- numero tres
                        Next_State <= tres;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= DosPuntos;
                        LCD_RS <= '1';
                    ELSE
                        Next_State <= tres;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    ---------------------------------------------------------------------------
                WHEN OTHERS => READY <= '0';
                    LCD_E <= '0';
                    LCD_RS <= '0';
            END CASE;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------------------
    -- CODIGO MAQUINA DE ESTADOS
    --------------------------------------------------------------------------------
    Sreg0_NextState : PROCESS (PB1, PB2, PB3, Sreg0)
    BEGIN
        NextState_Sreg0 <= Sreg0;
        -- Set default values for outputs and signals
        M1 <= "01";
        M2 <= "01";
        M3 <= "01";
        CASE Sreg0 IS
            WHEN S1 => --Estado inicial o de reset donde todos los motores estan apagados 
                M1 <= "01";
                M2 <= "01";
                M3 <= "01";
                EstadosM <= "000";
                IF PB1 = '1' THEN --se presiona el boton correspondiente al motor 1
                    NextState_Sreg0 <= S2; --Encender motor 1

                ELSIF PB2 = '1' THEN --se presiona el boton correspondiente al motor 2
                    NextState_Sreg0 <= S3; --Encender motor 2

                ELSIF PB3 = '1' THEN --se presiona el boton correspondiente al motor 3
                    NextState_Sreg0 <= S4; --Encender motor 3
                END IF;

            WHEN S2 => --Enciende el motor 1
                M1 <= "10";
                M2 <= "01";
                M3 <= "01";
                EstadosM <= "100";
                IF PB2 = '1' THEN --se presiona el boton correspondiente al motor 2
                    NextState_Sreg0 <= S3;
                ELSIF PB3 = '1' THEN --se presiona el boton correspondiente al motor 3
                    NextState_Sreg0 <= S4;
                END IF;

            WHEN S3 => --Enciende el motor 2
                M1 <= "01";
                M2 <= "10";
                M3 <= "01";
                EstadosM <= "010";
                IF PB1 = '1' THEN
                    NextState_Sreg0 <= S2;
                ELSIF PB3 = '1' THEN
                    NextState_Sreg0 <= S4;
                END IF;

            WHEN S4 => --Enciende el motor 3
                M1 <= "01";
                M2 <= "01";
                M3 <= "10";
                EstadosM <= "001";
                IF PB2 = '1' THEN
                    NextState_Sreg0 <= S3;
                ELSIF PB1 = '1' THEN
                    NextState_Sreg0 <= S2;
                END IF;
                --vhdl_cover_off
            WHEN OTHERS =>
                NULL;
                --vhdl_cover_on
        END CASE;
    END PROCESS;

    ------------------------------------
    -- Current State Logic (sequential)
    ------------------------------------
    Sreg0_CurrentState : PROCESS (CLOCK)
    BEGIN
        IF CLOCK'event AND CLOCK = '1' THEN
            IF Rest = '1' THEN
                Sreg0 <= S1;
            ELSE
                Sreg0 <= NextState_Sreg0;
            END IF;
        END IF;
    END PROCESS;
    --------------------------------------------------------------------------------
    -- FINAL MAQUINA DE ESTADOS 
    --------------------------------------------------------------------------------

END Behavioral;