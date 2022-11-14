-- Este código presenta una flecha en un display matricial de 8x8.
-- Los renglones van a resistencia y de ahi a los ánodos.
--LIBRARY IEEE;
--USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--
--
--ENTITY matrixArrow IS
--    GENERIC (N : INTEGER := 15); -- M: integer:=26); -- N valor de bits del divisor
--    PORT (
--        clk : IN STD_LOGIC; -- reloj de 50MHz
--        R, C : OUT STD_LOGIC_VECTOR (8 DOWNTO 1)); -- Renglones y Columnas
--END matrixArrow;
--
--
--ARCHITECTURE matrixArrow OF matrixArrow IS
--    -- Señales
--    --divisor de M+1 bits
--    SIGNAL clkdiv : STD_LOGIC_VECTOR (N DOWNTO 0);
--    --contador de tres bits que sirve para el barrido
--    SIGNAL barrido : STD_LOGIC_VECTOR (2 DOWNTO 0);
--    -- Arreglo (memoria)
--    --arreglo de datos para visualizar una flecha
--    TYPE arreglo IS ARRAY (1 TO 8) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
--    CONSTANT tabla : arreglo := (-- datos de flecha arriba
--    "00000000",
--    "00000100",
--    "00000110",
--    "11111111",
--    "11111111",
--    "00000110",
--    "00000100",
--    "00000000");
--
--    --signal tabla : arreglo;
--BEGIN
--    ----------------------------------------------------------------------------------
--    -- proceso del divisor cldiv
--    divisor : PROCESS (clk)
--    BEGIN
--        IF clk'event AND clk = '1' THEN
--            clkdiv <= clkdiv + 1;
--        END IF;
--    END PROCESS divisor;
--    ----------------------------------------------------------------------------------
--    --manda los datos del display
--    asigna : PROCESS (clkdiv(N - 1), barrido) --, clkdiv(M))
--    BEGIN
--        -- esta asignación funciona igual que clkdiv <= clkdiv + 1
--        barrido <= clkdiv(N DOWNTO N - 2);
--        --se mandan los datos a los renglones y las columnas con el contador de anillo (barrido)
--        CASE barrido IS -- para display de ánodo R se niega el contador de anillo
--            WHEN o"0" => R <= tabla(1);
--                C <= NOT"01111111"; -- C <= "01111111";
--            WHEN o"1" => R <= tabla(2);
--                C <= NOT"10111111"; -- C <= "10111111";
--            WHEN o"2" => R <= tabla(3);
--                C <= NOT"11011111"; -- C <= "11011111";
--            WHEN o"3" => R <= tabla(4);
--                C <= NOT"11101111"; -- C <= "11101111";
--            WHEN o"4" => R <= tabla(5);
--                C <= NOT"11110111"; -- C <= "11110111";
--            WHEN o"5" => R <= tabla(6);
--                C <= NOT"11111011"; -- C <= "11111011";
--            WHEN o"6" => R <= tabla(7);
--                C <= NOT"11111101"; -- C <= "11111101";
--            WHEN o"7" => R <= tabla(8);
--                C <= NOT"11111110"; -- C <= "11111110";
--            WHEN OTHERS => R <= tabla(1);
--                C <= NOT"00000000"; -- C <= "00000000";
--        END CASE;
--    END PROCESS asigna;
--END matrixArrow;
--E
-- Este código presenta una flecha en un display matricial
-- de 8x8.
-- Los renglones van a resistencia y de ahí a los ánodos.
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY matrixArrowMov IS
    GENERIC (
        N : INTEGER := 15;
        M : INTEGER := 24); -- M es para el divisor y N para el barrido
    PORT (
        clk, dir, hold, sonidoSW : IN STD_LOGIC; -- reloj de 50MHz, dirección, hold y
        
        sonidoOUT : OUT STD_LOGIC; --salida de sonido para una bocina de alta impedancia
        sonidoOUT2 : OUT STD_LOGIC; --salida de sonido para una bocina de alta impedancia
        R, C : OUT STD_LOGIC_VECTOR (8 DOWNTO 1)); -- Renglones y Columnas
END matrixArrowMov;
ARCHITECTURE matrixArrowMov OF matrixArrowMov IS
    --señales
    SIGNAL clkdiv : STD_LOGIC_VECTOR (M DOWNTO 0); --divisor de M+1 bits
    SIGNAL barrido : STD_LOGIC_VECTOR (2 DOWNTO 0); --contador de 3 bits para el barrido del
    
    TYPE arreglo IS ARRAY (1 TO 8) OF STD_LOGIC_VECTOR(7 DOWNTO 0); --declaración de la matriz 8x8
    SIGNAL tabla : arreglo; --señal que recibe las cuatro figuras (tabla1,2,3,4) para ciclarse
    --constantes
    CONSTANT tabla1 : arreglo := (-- datos de la flecha arriba
    "00011000", --"00000000",
    "00111100", --"00000100",
    "01111110", --"00000110",
    "00011000", --"01111111",
    "00011000", --"01111111",
    "00011000", --"00000110",
    "00011000", --"00000100",
    "00000000"); --"00000000");
    CONSTANT tabla2 : arreglo := (-- datos de la flecha arriba
    "00111100", --"00000000",
    "01111110", --"00000010",
    "00011000", --"00000011",
    "00011000", --"10111111",
    "00011000", --"10111111",
    "00011000", --"00000011",
    "00000000", --"00000010",
    "00011000"); --"00000000");
    CONSTANT tabla3 : arreglo := (-- datos de la flecha arriba
    "01111110", --"00000000",
    "00011000", --"00000001",
    "00011000", --"10000001",
    "00011000", --"11011111",
    "00011000", --"11011111",
    "00000000", --"10000001",
    "00011000", --"00000001",
    "00111100"); --"00000000");
    CONSTANT tabla4 : arreglo := (-- datos de la flecha arriba
    "00011000", --"00000000",
    "00011000", --"10000000",
    "00011000", --"11000000",
    "00011000", --"11101111",
    "00000000", --"11101111",
    "00011000", --"11000000",
    "00111100", --"10000000",
    "01111110"); --"00000000");
    CONSTANT tabla5 : arreglo := (-- datos de la flecha arriba
    "00011000", --"00000000",
    "00011000", --"01000000",
    "00011000", --"01100000",
    "00000000", --"11110111",
    "00011000", --"11110111",
    "00111100", --"01100000",
    "01111110", --"01000000",
    "00011000"); --"00000000");
    CONSTANT tabla6 : arreglo := (-- datos de la flecha arriba
    "00011000", --"00000000",
    "00011000", --"00100000",
    "00000000", --"00110000",
    "00011000", --"11111011",
    "00111100", --"11111011",
    "01111110", --"00110000",
    "00011000", --"00100000",
    "00011000"); --"00000000");
    CONSTANT tabla7 : arreglo := (-- datos de la flecha arriba
    "00011000", --"00000000",
    "00000000", --"00010000",
    "00011000", --"00011000",
    "00111100", --"11111101",
    "01111110", --"11111101",
    "00011000", --"00011000",
    "00011000", --"00010000",

    "00011000"); --"00000000");
    CONSTANT tabla8 : arreglo := (-- datos de la flecha arriba
    "00000000", --"00000000",
    "00011000", --"00001000",
    "00111100", --"00001100",
    "01111110", --"11111110",
    "00011000", --"11111110",
    "00011000", --"00001100",
    "00011000", --"00001000",
    "00011000"); --"00000000");
    CONSTANT tabla9 : arreglo := (-- datos de puntos en esquinas y cuadro
    "10000001", --"00000000",
    "00000000", --"00001000",
    "00111100", --"00001100",
    "00100100", --"11111110",
    "00100100", --"11111110",
    "00111100", --"00001100",
    "00000000", --"00001000",
    "10000001"); --"00000000");
    -- la señal tempo es un contador de 3 bits que asigna de forma temporal el valor
    -- de las 8 tablas
    SIGNAL tempo : STD_LOGIC_VECTOR(2 DOWNTO 0);--
    SIGNAL duracion : STD_LOGIC_VECTOR(1 DOWNTO 0); --contador para el sonido
BEGIN --comienza la arquitectura
    -- proceso del divisor cldiv
    divisor : PROCESS (clk)
    BEGIN
        IF clk'event AND clk = '1' THEN
            clkdiv <= clkdiv + 1; --contador de M bits
        END IF;
    END PROCESS divisor;
    --manda los datos del display
    asigna : PROCESS (clkdiv(M), barrido, dir, hold)
    BEGIN
        tempo <= clkdiv(M DOWNTO M - 2);
        -- esta asignación funciona igual que clkdiv <= clkdiv + 1
        barrido <= clkdiv(N DOWNTO N - 2);
        -- cambio de las figuras para la señal tabla
        IF tempo = o"0" THEN
            tabla <= tabla1;
        ELSIF tempo = o"1" THEN
            tabla <= tabla2;
        ELSIF tempo = o"2" THEN
            tabla <= tabla3;
        ELSIF tempo = o"3" THEN
            tabla <= tabla4;
        ELSIF tempo = o"4" THEN
            tabla <= tabla5;
        ELSIF tempo = o"5" THEN
            tabla <= tabla6;
        ELSIF tempo = o"6" THEN
            tabla <= tabla7;
        ELSE
            tabla <= tabla8;
        END IF;
        --se mandan los datos a los renglones y las columnas con el contador barrido
        IF hold = '1' THEN --manda cuadro con puntos en las esquinas
            CASE barrido IS
                WHEN o"0" => R <= tabla9(1);
                    C <= "11111110";
                WHEN o"1" => R <= tabla9(2);
                    C <= "11111101";
                WHEN o"2" => R <= tabla9(3);
                    C <= "11111011";
                WHEN o"3" => R <= tabla9(4);
                    C <= "11110111";
                WHEN o"4" => R <= tabla9(5);
                    C <= "11101111";
                WHEN o"5" => R <= tabla9(6);
                    C <= "11011111";
                WHEN o"6" => R <= tabla9(7);
                    C <= "10111111";
                WHEN o"7" => R <= tabla9(8);
                    C <= "01111111";
                WHEN OTHERS => R <= tabla9(1);
                    C <= "00000000";
            END CASE;
        ELSIF dir = '1' THEN
            CASE barrido IS
                WHEN o"0" => R <= tabla(1);
                    C <= "11111110";
                WHEN o"1" => R <= tabla(2);
                    C <= "11111101";
                WHEN o"2" => R <= tabla(3);
                    C <= "11111011";
                WHEN o"3" => R <= tabla(4);
                    C <= "11110111";
                WHEN o"4" => R <= tabla(5);
                    C <= "11101111";
                WHEN o"5" => R <= tabla(6);
                    C <= "11011111";
                WHEN o"6" => R <= tabla(7);
                    C <= "10111111";
                WHEN o"7" => R <= tabla(8);
                    C <= "01111111";
                WHEN OTHERS => R <= tabla(1);
                    C <= "00000000";
            END CASE;
        ELSE
            CASE barrido IS
                WHEN o"0" => R <= tabla(8);
                    C <= "11111110"; --"11111110";
                WHEN o"1" => R <= tabla(7);
                    C <= "11111101"; --"11111101";
                WHEN o"2" => R <= tabla(6);
                    C <= "11111011"; --"11111011";
                WHEN o"3" => R <= tabla(5);
                    C <= "11110111"; --"11110111";
                WHEN o"4" => R <= tabla(4);
                    C <= "11101111"; --"11101111";
                WHEN o"5" => R <= tabla(3);
                    C <= "11011111"; --"11011111";
                WHEN o"6" => R <= tabla(2);
                    C <= "10111111"; --"10111111";
                WHEN o"7" => R <= tabla(1);
                    C <= "01111111"; --"01111111";
                WHEN OTHERS => R <= tabla(1);
                    C <= "00000000"; --"00000000";
            END CASE;

        END IF;
    END PROCESS asigna;


    sonido : PROCESS (clkdiv(M), sonidoSW, dir, hold)
    BEGIN
        duracion <= clkdiv(M DOWNTO M - 1);
        IF sonidoSW = '0' OR hold = '1' THEN
            sonidoOUT <= '0';
            sonidoOUT2 <= '0'; --sin sonido
        ELSIF dir = '1' THEN
            CASE duracion IS
                WHEN "00" => sonidoOUT <= clkdiv(15);
                    sonidoOUT2 <= clkdiv(15);
                WHEN OTHERS => sonidoOUT <= '0';
                    sonidoOUT2 <= '0';
            END CASE;
        ELSE -- dir = '0' then
            CASE duracion IS
                WHEN "00" => sonidoOUT <= clkdiv(16);
                    sonidoOUT2 <= clkdiv(16);
                WHEN "01" => sonidoOUT <= '0';
                    sonidoOUT2 <= '0'; --clkdiv(15);
                WHEN "10" => sonidoOUT <= clkdiv(16);
                    sonidoOUT2 <= clkdiv(16);
                WHEN "11" => sonidoOUT <= '0';
                    sonidoOUT2 <= '0'; --clkdiv(13);
                WHEN OTHERS => sonidoOUT <= '0';
                    sonidoOUT2 <= '0';
            END CASE;
        END IF;
    END PROCESS sonido;
END matrixArrowMov;