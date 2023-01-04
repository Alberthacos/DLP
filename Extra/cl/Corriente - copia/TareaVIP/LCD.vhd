--CODIGO PARA CONTROLAR UN LCD CON LA TARJETA AMIBA 2 CON 8 BITS
--Texto a mostrar
--V=12.5v I=22.523A
--P=45.455w F=23Hz
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY LCD IS
    PORT (
        CLOCK : IN STD_LOGIC;
        =
        LCD_RS : OUT STD_LOGIC := '0'; --	Comando, escritura
        LCD_RW : OUT STD_LOGIC; -- LECTURA/ESCRITURA
        LCD_E : OUT STD_LOGIC; -- ENABLE
        DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"; -- PINES DATOS

    );
END LCD;

ARCHITECTURE Behavioral OF LCD IS
    -----SIGNALS FOR LCD---------------
    -- signal FSM --
    TYPE STATE_TYPE IS (
        RST, ST0, ST1, ST2, SET_DEFI, SHOW1, SHOW2, CLEAR, ENTRY, C, AA, L, M, O, E, T, R, N, I, S, X, BB, J,
        desplazamiento, Vacio, CambioFila, decen, unid, limpiarlCD, espacio, dos_puntos, D, Z);
    SIGNAL State, Next_State : STATE_TYPE;

    SIGNAL CONT1 : STD_LOGIC_VECTOR(23 DOWNTO 0) := X"000000"; -- 16,777,216 = 0.33554432 s MAX
    SIGNAL CONT2 : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000"; -- 32 = 0.64us
    SIGNAL RESET : STD_LOGIC := '0';
    SIGNAL READY : STD_LOGIC := '0';
    SIGNAL listo : STD_LOGIC := '0';
    SIGNAL unidades, decenas : INTEGER RANGE 0 TO 9 := 0;
    --signal LCD_numeros_Encoder
    SIGNAL numeroD, numeroU : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL As, Es, Ls, Cs, M_s, Rs, Espacios, Oos, Iss, Ts, SS, Js : INTEGER RANGE 0 TO 20 := 1;

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

    PROCESS (CONT1, CONT2, State, CLOCK, REINI, listo, E_direccion, direccion1, numeros_encoder)
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
                        IF E_direccion = '0' AND numeros_encoder = '1' THEN --Numeros controlados con encoder
                            Next_State <= C;--Contador
                        ELSIF ((E_direccion = numeros_encoder) OR (E_direccion = '1' AND numeros_encoder = '0')) AND listo = '0' THEN
                            Next_State <= AA; --Alexis
                        END IF;
                    ELSE
                        Next_State <= SHOW2;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN V => --Letra V (voltaje)
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "01000001"; -- V
                        Next_State <= AA;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';

                        Next_State <= igual;

                    ELSE
                        Next_State <= V;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                WHEN igual => -- signo igual =
                    IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
                        READY <= '1';
                        DATA <= "01000001"; -- signo igual = 
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
                        DATA <= numeroD; -- RECIBE NUMERO CORRESPONDIENTE A DECENAS del voltaje
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
                        DATA <= numeroU; -- RECIBE NUMERO CORRESPONDIENTE A DECENAS del voltaje
                        Next_State <= unidadesV;

                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        next_state <= Espacio;
                    ELSE
                        Next_State <= unidadesV;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

                    --------------------------------------------------------------------------------
                WHEN punto_decimal => --Punto decimal
                    IF CONT1 = X"0009C4" THEN --espera por 500ms 20ns*25,000,000=50ms 2500=9C4
                        READY <= '1';
                        DATA <= ""; -- punto decimal
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
                        DATA <= decimas; -- RECIBE NUMERO CORRESPONDIENTE A DECENAS del voltaje
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
                        DATA <= ""; -- valor numerico de las unidades de la I
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
                        DATA <= ""; -- valor numerico de las decimas de la corriente I
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
                        DATA <= ""; -- valor numerico de las centecimas de la corriente I
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
                        DATA <= ""; -- valor numerico de las milesimas de la corriente I
                        Next_State <= milesimasI;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '0' --comandos
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
                        DATA <= ""; -- P
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
                        DATA <= ""; -- valor numerico de las decenas de la potencia P 
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
                        DATA <= ""; -- valor numerico de las unidades de la potencia P
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
                        DATA <= ""; -- valor numerico de las decimas de la potencia P
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
                        DATA <= ""; -- valor numerico de las centecimas de la potenciaP
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
                        DATA <= ""; -- valor numerico de las milesimas de la potencia P
                        Next_State <= milesimasP;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        LCD_RS <= '0' --comandos
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
                        DATA <= ""; -- F mayuscula
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
                        DATA <= ""; -- valor numerico de las decenas de la frecuencia F 
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
                        DATA <= ""; -- valor numerico de las unidades de la frecuencia F
                        Next_State <= unidadesF;
                    ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
                        LCD_E <= '1';
                    ELSIF CONT2 = "1111" THEN
                        READY <= '0';
                        LCD_E <= '0';
                        Next_State <= vacio; --///////////////FIN 
                    ELSE
                        Next_State <= unidadesF;
                    END IF;
                    RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

            END ARCHITECTURE Behavioral;