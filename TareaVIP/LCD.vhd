--CODIGO PARA CONTROLAR UN LCD CON LA TARJETA AMIBA 2 CON 8 BITS
--Texto a mostrar
--V=12.5v I=22.523A
--P=45.455w F=23Hz
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY LCD IS
    PORT (
        CLOCK : IN STD_LOGIC;
        LEDS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        LCD_RS : OUT STD_LOGIC := '0'; --	Comando, escritura
        LCD_RW : OUT STD_LOGIC; -- LECTURA/ESCRITURA
        LCD_E : OUT STD_LOGIC; -- ENABLE
        REINI : IN STD_LOGIC;
        Fre_input: in std_logic;
        DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"; -- PINES DATOS

        Valor_temporalV, Valor_temporalI : IN STD_LOGIC_VECTOR(15 DOWNTO 0)

        --UniI, DeciI, CenI, MileI : IN STD_LOGIC_VECTOR(7 DOWNTO 0)

    );
END LCD;

ARCHITECTURE ConrtlLCD OF LCD IS
    -----SIGNALS FOR LCD---------------
    -- signal FSM --
    TYPE STATE_TYPE IS (
        RST, ST0, ST1, ST2, SET_DEFI, SHOW1, SHOW2, CLEAR, ENTRY, C, unidadesF, L, M, O, E, T, R, N, S, X, BB, J,
        desplazamiento, Vacio, CambioFila, decen, unid, limpiarlCD, espacio, dos_puntos, D, Z, V, I, igual, unidadesI, decenasP, decenasV, unidadesV,
        punto_decimal, decimasV, decimasI, milesimasI, milesimasP, decenasF, decimasP, P, F, centecimasI, centecimasP, unidadesP);
    SIGNAL State, Next_State : STATE_TYPE;

    SIGNAL CONT1 : STD_LOGIC_VECTOR(23 DOWNTO 0) := X"000000"; -- 16,777,216 = 0.33554432 s MAX
    SIGNAL CONT2 : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000"; -- 32 = 0.64us
    SIGNAL RESET : STD_LOGIC := '0';
    SIGNAL READY : STD_LOGIC := '0';
    SIGNAL listo : STD_LOGIC := '0';
    --SIGNAL unidades, decenas : INTEGER RANGE 0 TO 9 := 0;
    SIGNAL ValorDecV, ValorUniV, ValorDeciV : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ValorUniI, ValorDeciI, ValorCenI, ValorMileI : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ValorUniP, ValorDecP, ValorDeciP, ValorCenP, ValorMileP : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ValorUniF, ValorDecF, ValorCenF, ValorMilF : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL SAL_250us : STD_LOGIC;
    SIGNAL contadors : INTEGER RANGE 1 TO 1_000_000 := 1; -- pulso1 de 0.25ms (pro. divisor ánodos)
    SIGNAL VoI, VoV, vin : INTEGER RANGE 0 TO 500;
    SIGNAL NumeroBitsDecimalV, NumeroBitsDecimalI : INTEGER RANGE 0 TO 50_000_000;
    SIGNAL DecV, UniV, DeciV : INTEGER RANGE 0 TO 20;
    SIGNAL UniI, DeciI, CentI, MileI : INTEGER RANGE 0 TO 20;
    SIGNAL UniF, DecF, CenF, MilF : INTEGER RANGE 0 TO 20;
    SIGNAL UniP, DecP, DeciP, CentP, MileP, IVal : INTEGER RANGE 0 TO 20;
    SIGNAL unidades, centenas, decenas, miles : INTEGER RANGE 0 TO 9 := 0;
    SIGNAL cont_Frec, contador : INTEGER RANGE 0 TO 50_000_000 := 0;
    --signal LCD_numeros_Encoder
    SIGNAL numeroD, numeroU : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL As, Es, Ls, Cs, M_s, Rs, Espacios, Oos, Iss, Ts, SS, Js, eqls, puntos : INTEGER RANGE 0 TO 20 := 1;
    SIGNAL A: real := 0.0; -- double
    ------------------------------------------------

BEGIN

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
    -- Actualizacion de estados --
    PROCESS (CLOCK, Next_State)
    BEGIN
        IF CLOCK = '1' AND CLOCK'event THEN
            State <= Next_State;
        END IF;
    END PROCESS;
    ------------------------------------------------------------------

    PROCESS (CONT1, CONT2, State, CLOCK, REINI, listo, UniV, ValorUniV)
    BEGIN
        IF REINI = '1' THEN
            Next_State <= RST;
        ELSIF CLOCK = '0' AND CLOCK'event THEN
            CASE State IS
                    --------------------------------------------------------------------------------
                WHEN RST => -- Estado de reset
                    IF CONT1 = X"000000"THEN --0s
                        LCD_RS <= '0';
                        LCD_RW <= '0';
                        LCD_E <= '0';
                        DATA <= x"00";
                        Next_State <= ST0;
                    ELSE
                        Next_State <= ST0;
                    END IF;

                    --------------------------------------------------------------------------------
                WHEN ST0 => --Primer estado de espera por 25ms (20ms=0F4240=1000000)(15ms=0B71B0=750000)
                    ---SET 1
                    IF CONT1 = X"2625A0" THEN -- 2,500,000=50ms
                        READY <= '1';
                        DATA <= "00110000"; -- FUNCTION SET 8BITS, 2 LINE, 5X7
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

                    --------------------------------------------------------------------------------			
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

                    --------------------------------------------------------------------------------
                WHEN ST2 => --Tercer estado de espera por 100us  SET 3
                    IF CONT1 = X"0035E8" THEN -- 5000 = 100us  = x35E8)
                        READY <= '1';
                        DATA <= "00110000"; -- FUNCTION SET
                        Next_State <= ST2;
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

                    --------------------------------------------------------------------------------
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

                    --------------------------------------------------------------------------------
                WHEN SHOW1 => --Quinto paso, se apaga el display por unica ocasion
                    --SHOW _ APAGAR DISPLAY
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

                    --------------------------------------------------------------------------------
                WHEN CLEAR => --SEXTO PASO, SE LIMPIA EL DISPLAY 
                    LCD_RS <= '0';
                    IF CONT1 = X"4C4B40" THEN
                        READY <= '1';
                        DATA <= "00000001"; -- CLEAR
                        Next_State <= CLEAR;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= ENTRY;
                        listo <= '0';
                        As <= 1;
                        Es <= 1;
                        Ls <= 1;
                        Cs <= 1;
                        Oos <= 1;
                        M_s <= 1;
                        Rs <= 1;
                        Iss <= 1;
                        Ts <= 1;
                        Ss <= 1;
                        Js <= 1;
                        Espacios <= 1;
                        eqls <= 1;
                        puntos <= 1;

                        --As, Es, Ls, Cs, M_s, Rs, Espacios, Oos, Iss, Ts, SS, Js
                    ELSE
                        Next_State <= CLEAR;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------					
                WHEN ENTRY => --SEPTIMO PASO, CONFIGURAR MODO DE ENTRADA --ENTRY MODE
                    IF CONT1 = X"3D090" THEN --espera por 5ms 250,000
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

                    --------------------------------------------------------------------------------
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
                        LCD_RS <= '1'; --datos
                        Next_State <= V;--V de voltaje

                    ELSE
                        Next_State <= SHOW2;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN V => --Letra V (voltaje)
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "01010110"; -- V
                        Next_State <= V;

                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= igual;
                        LCD_RS <= '1'; --datos
                    ELSE
                        Next_State <= V;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN igual => -- signo igual =
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "00111101"; -- signo igual = 
                        Next_State <= igual;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';

                        IF eqls = 1 THEN ---NOTA: Reiniciar contador
                            Next_State <= decenasV; --variable que imprime las decenas del voltaje
                        ELSIF eqls = 2 THEN
                            Next_State <= unidadesI; --variable que imprime las unidades de la corriente
                        ELSIF eqls = 3 THEN
                            Next_State <= decenasP; --variable que imprime las decenas de la potencia 
                        ELSIF eqls = 4 THEN
                            Next_State <= decenasF; --variable que imprime las decenas de la frecuencia 
                        END IF;
                        eqls <= eqls + 1; --aumenta numero de eqls escritas

                    ELSE
                        Next_State <= igual;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN decenasV => --Decenas del voltaje
                    IF CONT1 = X"0009C4" THEN --espera por 50ms 20ns*25,000,000=50ms 2500=9C4
                        READY <= '1';
                        DATA <= ValorDecV; -- RECIBE NUMERO CORRESPONDIENTE A DECENAS del voltaje
                        Next_State <= decenasV;

                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= unidadesV; --Unidades del voltaje
                    ELSE
                        Next_State <= decenasV;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN unidadesV => --UNIDADES del voltaje
                    IF CONT1 = X"0009C4" THEN --espera por 500ms 20ns*25,000,000=50ms 2500=9C4
                        READY <= '1';
                        DATA <= ValorUniV; -- RECIBE NUMERO CORRESPONDIENTE A DECENAS del voltaje
                        Next_State <= unidadesV;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        next_state <= punto_decimal; --cambio antes estaba espacio 
                    ELSE
                        Next_State <= unidadesV;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN punto_decimal => --Punto decimal
                    IF CONT1 = X"0009C4" THEN --espera por 500ms 20ns*25,000,000=50ms 2500=9C4
                        READY <= '1';
                        DATA <= "00101110"; -- punto decimal
                        Next_State <= punto_decimal;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';

                        IF puntos = 1 THEN ---NOTA: Reiniciar contador
                            next_state <= decimasV;
                        ELSIF puntos = 2 THEN
                            Next_State <= decimasI; --variable que imprime las decimas de la corriente
                        ELSIF puntos = 3 THEN
                            Next_State <= decimasP; --variable que imprime las decimas de la potencia
                        END IF;
                        puntos <= puntos + 1; --aumenta numero de puntos escritos

                    ELSE
                        Next_State <= punto_decimal;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN decimasV => --decimas del voltaje
                    IF CONT1 = X"0009C4" THEN --espera por 500ms 20ns*25,000,000=50ms 2500=9C4
                        READY <= '1';
                        DATA <= ValorDeciV; -- RECIBE NUMERO CORRESPONDIENTE A DECENAS del voltaje
                        Next_State <= decimasV;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '0'; --comandos
                        next_state <= Espacio;
                    ELSE
                        Next_State <= decimasV;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN Espacio => --Espacio
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        LCD_RS <= '0';
                        DATA <= "00010100"; -- comando para insertar un espacio 
                        Next_State <= Espacio;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '1'; ---enviar datos

                        IF Espacios = 1 THEN ---NOTA: Reiniciar contador
                            next_state <= I; --I mayuscula (corriente)
                        ELSIF Espacios = 2 THEN
                            Next_State <= F; --F mayuscula de frecuencia
                        END IF;
                        Espacios <= Espacios + 1; --aumenta numero de Espacios escritos

                    ELSE
                        Next_State <= Espacio;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN I => --I (corriente)
                    -- // signo igual
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "01001001"; -- letra I mayuscula
                        Next_State <= I;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= igual; --signo igual
                    ELSE
                        Next_State <= I;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN unidadesI => --unidadesI 
                    --// punto decimal
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= ValorUniI; -- valor numerico de las unidades de la I
                        Next_State <= unidadesI;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= punto_decimal;
                    ELSE
                        Next_State <= unidadesI;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN decimasI => --decimasI 
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= ValorDeciI; -- valor numerico de las decimas de la corriente I
                        Next_State <= decimasI;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= centecimasI;
                    ELSE
                        Next_State <= decimasI;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN centecimasI => --centecimasI 
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= ValorCenI; -- valor numerico de las centecimas de la corriente I
                        Next_State <= centecimasI;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= milesimasI;
                    ELSE
                        Next_State <= centecimasI;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN milesimasI => --milesimasI 
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= ValorMileI; -- valor numerico de las milesimas de la corriente I
                        Next_State <= milesimasI;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '0'; --comandos
                        Next_State <= CambioFila;
                    ELSE
                        Next_State <= milesimasI;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN CambioFila => --Cambio Fila
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "11000000"; -- comando cambio de fila 
                        Next_State <= CambioFila;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '1';--envio de datos
                        Next_State <= P; --letra p mayuscula de potencia
                    ELSE
                        Next_State <= CambioFila;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN P => --P (potencia) 
                    --// signo igual 
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "01010000"; -- P
                        Next_State <= P;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= igual; --signo igual 

                    ELSE
                        Next_State <= P;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN decenasP => --decenasP 
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= ValorDecP; -- valor numerico de las decenas de la potencia P 
                        Next_State <= decenasP;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= unidadesP; --signo igual 

                    ELSE
                        Next_State <= decenasP;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN unidadesP => --unidadesP 
                    --// punto decimal
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= ValorUniP; -- valor numerico de las unidades de la potencia P
                        Next_State <= unidadesP;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= punto_decimal; --punto decimal
                    ELSE
                        Next_State <= unidadesP;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN decimasP => --decimasP 
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= ValorDeciP; -- valor numerico de las decimas de la potencia P
                        Next_State <= decimasP;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= centecimasP;
                    ELSE
                        Next_State <= decimasP;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN centecimasP => --centecimasP 
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= ValorCenP; -- valor numerico de las centecimas de la potenciaP
                        Next_State <= centecimasP;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= milesimasP;
                    ELSE
                        Next_State <= centecimasP;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN milesimasP => --milesimasP 
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= ValorMileP; -- valor numerico de las milesimas de la potencia P
                        Next_State <= milesimasP;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '0'; --comandos
                        Next_State <= Espacio;
                    ELSE
                        Next_State <= milesimasP;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN F => --F (frecuencia) 
                    --// signo igual
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "01000110"; -- F mayuscula
                        Next_State <= F;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '1';
                        Next_State <= igual; --signo igual
                    ELSE
                        Next_State <= F;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN decenasF => --decenasF
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= ValorDecF; -- valor numerico de las decenas de la frecuencia F 
                        Next_State <= decenasF;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= unidadesF; --signo igual 

                    ELSE
                        Next_State <= decenasF;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN unidadesF => --unidadesF 
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= ValorUniF; -- valor numerico de las unidades de la frecuencia F
                        Next_State <= unidadesF;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= CLEAR; --///////////////FIN 
                    ELSE
                        Next_State <= unidadesF;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
                WHEN OTHERS => READY <= '0';
                    LCD_E <= '0';
                    LCD_RS <= '0';
            END CASE;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------------------
    -- ----
    --------------------------------------------------------------------------------

    ---------------------DIVISOR ÁNODOS-------------------
    PROCESS (CLocK) BEGIN
        IF rising_edge(CLocK) THEN
            IF (contadors = 1_000_000) THEN --cuenta 0.125ms (50MHz=6250)
                -- if (contadors = 12500) then --cuenta 0.125ms (100MHz=12500)
                SAL_250us <= NOT(SAL_250us); --genera un barrido de 0.25ms
                contadors <= 1;
            ELSE
                contadors <= contadors + 1;
            END IF;
        END IF;
    END PROCESS; -- fin del proceso Divisor Ánodos

    --------------------------------------------------------------------------------
    PROCESS (SAL_250us)
    BEGIN
        IF rising_edge(SAL_250us) THEN

            --OPERACIONES VOLTAJE
            NumeroBitsDecimalV <= TO_INTEGER(UNSIGNED(Valor_temporalV(14 DOWNTO 0)));

            --IF ch = '0' THEN --hace operaciones para voltaje 
            VoV <= ((NumeroBitsDecimalV * 5060)/538400);--2687900 --534800
            DecV <= VoV/100; --Decimas Voltaje  decmil
            UniV <= (VoV - DecV * 100)/10; --Unidades voltaje mil
            DeciV <= (VoV - DecV * 100 - UniV * 10); --decimas voltaje  cen

            --OPERACIONES CORRIENTE
            NumeroBitsDecimalI <= TO_INTEGER(UNSIGNED(Valor_temporalI(14 DOWNTO 0)));--(decMIL * 10000) + (MIL * 1000) + (CEN * 100) + (DEC * 10) + UNI;
            VoI <= ((NumeroBitsDecimalI * 25_200_000)/1351900); -- Vo <= ((NumeroBitsDecimal * 916_000)/1346200000);
            --50_600_000//2663400 
            IVal <= (((VoI - 251_000)*960)/10000);

            UniI <= IVal/1000;
            DeciI <= (IVal - UniI * 1000)/100; --millar [A] enteros
            CentI <= (IVal - UniI * 1000 - DeciI * 100)/10; --centecimas
            MileI <= (IVal - UniI * 1000 - DeciI * 100 - CentI * 10); --decenas

            --Operaciones potencia            DecP <= (VoV * Ival)/10_000;
            UniP <= ((VoV * Ival) - DecP * 10000)/1000;
            DeciP <= ((VoV * Ival) - DecP * 1000 - UniP * 1000)/100;
            CentP <= ((VoV * Ival) - DecP * 10000 - UniP * 1000 - DeciP * 1000)/10;
            MileP <= ((VoV * Ival) - DecP * 10000 - UniP * 1000 - DeciP * 100 - CentP * 10);

        END IF;
        --VOLTAJE
        CASE(DecV) IS -- abcdefgP 
            WHEN 0 => ValorDecV <= "00110000"; --0 
            WHEN 1 => ValorDecV <= "00110001"; --1
            WHEN 2 => ValorDecV <= "00110010"; --2
            WHEN 3 => ValorDecV <= "00110011"; --3
            WHEN 4 => ValorDecV <= "00110100"; --4
            WHEN 5 => ValorDecV <= "00110101"; --5
            WHEN 6 => ValorDecV <= "00110110"; --6
            WHEN 7 => ValorDecV <= "00110111"; --7
            WHEN 8 => ValorDecV <= "00111000"; --8
            WHEN 9 => ValorDecV <= "00111001"; --9
            WHEN OTHERS => ValorDecV <= "00000000"; --apagado
        END CASE;

        CASE(UniV) IS -- abcdefgP
            WHEN 0 => ValorUniV <= "00110000"; --0 
            WHEN 1 => ValorUniV <= "00110001"; --1
            WHEN 2 => ValorUniV <= "00110010"; --2
            WHEN 3 => ValorUniV <= "00110011"; --3
            WHEN 4 => ValorUniV <= "00110100"; --4
            WHEN 5 => ValorUniV <= "00110101"; --5
            WHEN 6 => ValorUniV <= "00110110"; --6
            WHEN 7 => ValorUniV <= "00110111"; --7
            WHEN 8 => ValorUniV <= "00111000"; --8
            WHEN 9 => ValorUniV <= "00111001"; --9
            WHEN OTHERS => ValorUniV <= "00000000"; --apagado
        END CASE;

        CASE(DeciV) IS -- abcdefgP
            WHEN 0 => ValorDeciV <= "00110000"; --0 
            WHEN 1 => ValorDeciV <= "00110001"; --1
            WHEN 2 => ValorDeciV <= "00110010"; --2
            WHEN 3 => ValorDeciV <= "00110011"; --3
            WHEN 4 => ValorDeciV <= "00110100"; --4
            WHEN 5 => ValorDeciV <= "00110101"; --5
            WHEN 6 => ValorDeciV <= "00110110"; --6
            WHEN 7 => ValorDeciV <= "00110111"; --7
            WHEN 8 => ValorDeciV <= "00111000"; --8
            WHEN 9 => ValorDeciV <= "00111001"; --9
            WHEN OTHERS => ValorDeciV <= ValorDeciV; --apagado
        END CASE;
        --------------------------------------------------------------------------------
        -- ASIGNACION VALORES ASCII PARA POTENCIA
        --------------------------------------------------------------------------------
        --POTENCIA
        CASE(UniP) IS -- abcdefgP 
            WHEN 0 => ValorUniP <= "00110000"; --0 
            WHEN 1 => ValorUniP <= "00110001"; --1
            WHEN 2 => ValorUniP <= "00110010"; --2
            WHEN 3 => ValorUniP <= "00110011"; --3
            WHEN 4 => ValorUniP <= "00110100"; --4
            WHEN 5 => ValorUniP <= "00110101"; --5
            WHEN 6 => ValorUniP <= "00110110"; --6
            WHEN 7 => ValorUniP <= "00110111"; --7
            WHEN 8 => ValorUniP <= "00111000"; --8
            WHEN 9 => ValorUniP <= "00111001"; --9
            WHEN OTHERS => ValorUniP <= ValorUniP; --apagado
        END CASE;

        CASE(DecP) IS -- abcdefgP
            WHEN 0 => ValorDecP <= "00110000"; --0 
            WHEN 1 => ValorDecP <= "00110001"; --1
            WHEN 2 => ValorDecP <= "00110010"; --2
            WHEN 3 => ValorDecP <= "00110011"; --3
            WHEN 4 => ValorDecP <= "00110100"; --4
            WHEN 5 => ValorDecP <= "00110101"; --5
            WHEN 6 => ValorDecP <= "00110110"; --6
            WHEN 7 => ValorDecP <= "00110111"; --7
            WHEN 8 => ValorDecP <= "00111000"; --8
            WHEN 9 => ValorDecP <= "00111001"; --9
            WHEN OTHERS => ValorDecP <= ValorDecP; --apagado
        END CASE;

        CASE(DeciP) IS -- abcdefgP
            WHEN 0 => ValorDeciP <= "00110000"; --0 
            WHEN 1 => ValorDeciP <= "00110001"; --1
            WHEN 2 => ValorDeciP <= "00110010"; --2
            WHEN 3 => ValorDeciP <= "00110011"; --3
            WHEN 4 => ValorDeciP <= "00110100"; --4
            WHEN 5 => ValorDeciP <= "00110101"; --5
            WHEN 6 => ValorDeciP <= "00110110"; --6
            WHEN 7 => ValorDeciP <= "00110111"; --7
            WHEN 8 => ValorDeciP <= "00111000"; --8
            WHEN 9 => ValorDeciP <= "00111001"; --9
            WHEN OTHERS => ValorDeciP <= ValorDeciP; --apagado
        END CASE;

        CASE(CentP) IS -- abcdefgP
            WHEN 0 => ValorCenP <= "00110000"; --0 
            WHEN 1 => ValorCenP <= "00110001"; --1
            WHEN 2 => ValorCenP <= "00110010"; --2
            WHEN 3 => ValorCenP <= "00110011"; --3
            WHEN 4 => ValorCenP <= "00110100"; --4
            WHEN 5 => ValorCenP <= "00110101"; --5
            WHEN 6 => ValorCenP <= "00110110"; --6
            WHEN 7 => ValorCenP <= "00110111"; --7
            WHEN 8 => ValorCenP <= "00111000"; --8
            WHEN 9 => ValorCenP <= "00111001"; --9
            WHEN OTHERS => ValorCenP <= ValorCenP; --apagado
        END CASE;

        CASE(MileP) IS -- abcdefgP
            WHEN 0 => ValorMileP <= "00110000"; --0 
            WHEN 1 => ValorMileP <= "00110001"; --1
            WHEN 2 => ValorMileP <= "00110010"; --2
            WHEN 3 => ValorMileP <= "00110011"; --3
            WHEN 4 => ValorMileP <= "00110100"; --4
            WHEN 5 => ValorMileP <= "00110101"; --5
            WHEN 6 => ValorMileP <= "00110110"; --6
            WHEN 7 => ValorMileP <= "00110111"; --7
            WHEN 8 => ValorMileP <= "00111000"; --8
            WHEN 9 => ValorMileP <= "00111001"; --9
            WHEN OTHERS => ValorMileP <= ValorMileP; --apagado
        END CASE;
        --------------------------------------------------------------------------------
        -- ASIGNACION VALORES ASCII PARA CORRIENTE
        --------------------------------------------------------------------------------
        --CORRIENTE
        CASE(UniI) IS -- abcdefgP 
            WHEN 0 => ValorUniI <= "00110000"; --0 
            WHEN 1 => ValorUniI <= "00110001"; --1
            WHEN 2 => ValorUniI <= "00110010"; --2
            WHEN 3 => ValorUniI <= "00110011"; --3
            WHEN 4 => ValorUniI <= "00110100"; --4
            WHEN 5 => ValorUniI <= "00110101"; --5
            WHEN 6 => ValorUniI <= "00110110"; --6
            WHEN 7 => ValorUniI <= "00110111"; --7
            WHEN 8 => ValorUniI <= "00111000"; --8
            WHEN 9 => ValorUniI <= "00111001"; --9
            WHEN OTHERS => ValorUniI <= "00110000"; --apagado
        END CASE;

        CASE(DeciI) IS -- abcdefgP
            WHEN 0 => ValorDeciI <= "00110000"; --0 
            WHEN 1 => ValorDeciI <= "00110001"; --1
            WHEN 2 => ValorDeciI <= "00110010"; --2
            WHEN 3 => ValorDeciI <= "00110011"; --3
            WHEN 4 => ValorDeciI <= "00110100"; --4
            WHEN 5 => ValorDeciI <= "00110101"; --5
            WHEN 6 => ValorDeciI <= "00110110"; --6
            WHEN 7 => ValorDeciI <= "00110111"; --7
            WHEN 8 => ValorDeciI <= "00111000"; --8
            WHEN 9 => ValorDeciI <= "00111001"; --9
            WHEN OTHERS => ValorDeciI <= "00000000"; --apagado
        END CASE;

        CASE(CentI) IS -- abcdefgP
            WHEN 0 => ValorCenI <= "00110000"; --0 
            WHEN 1 => ValorCenI <= "00110001"; --1
            WHEN 2 => ValorCenI <= "00110010"; --2
            WHEN 3 => ValorCenI <= "00110011"; --3
            WHEN 4 => ValorCenI <= "00110100"; --4
            WHEN 5 => ValorCenI <= "00110101"; --5
            WHEN 6 => ValorCenI <= "00110110"; --6
            WHEN 7 => ValorCenI <= "00110111"; --7
            WHEN 8 => ValorCenI <= "00111000"; --8
            WHEN 9 => ValorCenI <= "00111001"; --9
            WHEN OTHERS => ValorCenI <= ValorCenI; --apagado
        END CASE;

        CASE(MileI) IS -- abcdefgP
            WHEN 0 => ValorMileI <= "00110000"; --0 
            WHEN 1 => ValorMileI <= "00110001"; --1
            WHEN 2 => ValorMileI <= "00110010"; --2
            WHEN 3 => ValorMileI <= "00110011"; --3
            WHEN 4 => ValorMileI <= "00110100"; --4
            WHEN 5 => ValorMileI <= "00110101"; --5
            WHEN 6 => ValorMileI <= "00110110"; --6
            WHEN 7 => ValorMileI <= "00110111"; --7
            WHEN 8 => ValorMileI <= "00111000"; --8
            WHEN 9 => ValorMileI <= "00111001"; --9
            WHEN OTHERS => ValorMileI <= ValorMileI; --apagado
        END CASE;

        LEDS(15 DOWNTO 8) <= ValorDecV;
        LEDS(7 DOWNTO 0) <= ValorUniV;--ValorUniV;
    END PROCESS;
    PROCESS (CLocK, Fre_input)
    BEGIN

        IF rising_edge(CLocK) THEN
            cont_Frec <= cont_Frec + 1;

            IF cont_Frec < 49_999_999 THEN

                IF (Fre_input'event AND Fre_input = '1') THEN
                    contador <= contador + 1;
                END IF;

            ELSIF cont_Frec >= 50_000_000 THEN
                --			if contador < 100 then
                --			
                --			elsif contador <= 9 then
                --				unidades <= contador;
                --				contador <=0;
                --			end if;
                MilF <= contador/1000;
                CenF <= (contador - (miles * 1000))/100;
                DecF <= (contador - (miles * 1000 + centenas * 100))/10;
                UniF <= contador - (miles * 1000 + centenas * 100 + decenas * 10);

                contador <= 0;
                cont_Frec <= 0;
            END IF;

        END IF;

        CASE(UniF) IS -- abcdefgP 
            WHEN 0 => ValorUniF <= "00110000"; --0 
            WHEN 1 => ValorUniF <= "00110001"; --1
            WHEN 2 => ValorUniF <= "00110010"; --2
            WHEN 3 => ValorUniF <= "00110011"; --3
            WHEN 4 => ValorUniF <= "00110100"; --4
            WHEN 5 => ValorUniF <= "00110101"; --5
            WHEN 6 => ValorUniF <= "00110110"; --6
            WHEN 7 => ValorUniF <= "00110111"; --7
            WHEN 8 => ValorUniF <= "00111000"; --8
            WHEN 9 => ValorUniF <= "00111001"; --9
            WHEN OTHERS => ValorUniF <= ValorUniF; --apagado
        END CASE;

        CASE(DecF) IS -- abcdefgP
            WHEN 0 => ValorDecF <= "00110000"; --0 
            WHEN 1 => ValorDecF <= "00110001"; --1
            WHEN 2 => ValorDecF <= "00110010"; --2
            WHEN 3 => ValorDecF <= "00110011"; --3
            WHEN 4 => ValorDecF <= "00110100"; --4
            WHEN 5 => ValorDecF <= "00110101"; --5
            WHEN 6 => ValorDecF <= "00110110"; --6
            WHEN 7 => ValorDecF <= "00110111"; --7
            WHEN 8 => ValorDecF <= "00111000"; --8
            WHEN 9 => ValorDecF <= "00111001"; --9
            WHEN OTHERS => ValorDecF <= ValorDecF; --apagado
        END CASE;

        CASE(CenF) IS -- abcdefgP
            WHEN 0 => ValorCenF <= "00110000"; --0 
            WHEN 1 => ValorCenF <= "00110001"; --1
            WHEN 2 => ValorCenF <= "00110010"; --2
            WHEN 3 => ValorCenF <= "00110011"; --3
            WHEN 4 => ValorCenF <= "00110100"; --4
            WHEN 5 => ValorCenF <= "00110101"; --5
            WHEN 6 => ValorCenF <= "00110110"; --6
            WHEN 7 => ValorCenF <= "00110111"; --7
            WHEN 8 => ValorCenF <= "00111000"; --8
            WHEN 9 => ValorCenF <= "00111001"; --9
            WHEN OTHERS => ValorCenF <= ValorCenF; --apagado
        END CASE;

        CASE(MilF) IS -- abcdefgP
            WHEN 0 => ValorMilF <= "00110000"; --0 
            WHEN 1 => ValorMilF <= "00110001"; --1
            WHEN 2 => ValorMilF <= "00110010"; --2
            WHEN 3 => ValorMilF <= "00110011"; --3
            WHEN 4 => ValorMilF <= "00110100"; --4
            WHEN 5 => ValorMilF <= "00110101"; --5
            WHEN 6 => ValorMilF <= "00110110"; --6
            WHEN 7 => ValorMilF <= "00110111"; --7
            WHEN 8 => ValorMilF <= "00111000"; --8
            WHEN 9 => ValorMilF <= "00111001"; --9
            WHEN OTHERS => ValorMilF <= ValorMilF; --apagado
        END CASE;

    END PROCESS;

END ConrtlLCD;