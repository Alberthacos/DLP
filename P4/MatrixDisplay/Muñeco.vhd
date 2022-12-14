
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
    "00011100", --"00000000",
    "00111110", --"00000100",
    "00011100", --"00000110",
    "00001000", --"01111111",
    "00011100", --"01111111",
    "00101010", --"00000110",
    "00010100", --"00000100",
    "00010100"); --"00000000");
    CONSTANT tabla2 : arreglo := (-- datos de la flecha arriba
    "00011100", --"00000000",
    "00111110", --"00000010",
    "00011100", --"00000011",
    "00001000", --"10111111",
    "00111110", --"10111111",
    "00001000", --"00000011",
    "00010100", --"00000010",
    "00100010"); --"00000000");
    CONSTANT tabla3 : arreglo := (-- datos de la flecha arriba
    "00011100", --"00000000",
    "00111110", --"00000001",
    "00011100", --"10000001",
    "00101010", --"11011111",
    "00011100", --"11011111",
    "00111110", --"10000001",
    "00000000", --"00000001",
    "00000000"); --"00000000");
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
    SIGNAL tempo : integer range 0 to 5 := 0;--
    SIGNAL duracion : STD_LOGIC_VECTOR(1 DOWNTO 0); --contador para el sonido
    SIGNAL conta_1250us : INTEGER RANGE 1 TO 20000000 := 1; -- pulso1 de 1250us@400Hz (0.25ms)
    SIGNAL SAL_400Hz : STD_LOGIC := '0';

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

        IF rising_edge(CLK) THEN
            IF (conta_1250us = 10_000_000) THEN --cuenta 1250us (50MHz=62500)
                -- if (conta_1250us = 125000) then --cuenta 1250us (100MHz=125000)
                SAL_400Hz <= NOT(SAL_400Hz); --genera un barrido de 2.5ms
                conta_1250us <= 1;
            ELSE
                conta_1250us <= conta_1250us + 1;
            END IF;
        END IF;

        IF (SAL_400Hz'EVENT AND SAL_400Hz = '1') THEN
            IF tempo <= 3 THEN
                tempo <= tempo + 1;
            ELSE
                tempo <= 0;
            END IF;
        END IF;

        -- esta asignación funciona igual que clkdiv <= clkdiv + 1
        barrido <= clkdiv(N DOWNTO N - 2);
        -- cambio de las figuras para la señal tabla
        IF tempo = 1 THEN
            tabla <= tabla1;
        ELSIF tempo = 2 THEN
            tabla <= tabla2;
        ELSIF tempo = 3 THEN
            tabla <= tabla3;
        ELSE
            tabla <= tabla2;
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