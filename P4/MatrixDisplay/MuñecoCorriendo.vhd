
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY matrixArrowMov IS
    GENERIC (
        N : INTEGER := 15;
        M : INTEGER := 24); --
    PORT (
        clk, hold : IN STD_LOGIC; -- reloj de 50MHz, hold

        sonidoOUT : OUT STD_LOGIC:='Z'; --

        R, C : OUT STD_LOGIC_VECTOR (8 DOWNTO 1)); -- Renglones y Columnas
END matrixArrowMov;

ARCHITECTURE matrixArrowMov OF matrixArrowMov IS
    --señales
    SIGNAL clkdiv : STD_LOGIC_VECTOR (M DOWNTO 0); 
    SIGNAL barrido : STD_LOGIC_VECTOR (2 DOWNTO 0); 

    TYPE arreglo IS ARRAY (1 TO 8) OF STD_LOGIC_VECTOR(7 DOWNTO 0); 
    SIGNAL tabla : arreglo; 
    --constantes
    CONSTANT tabla1 : arreglo := (
    "00110000", 
    "00110000", 
    "00011000", 
    "00011000", 
    "00011000", 
    "00011000", 
    "00011000", 
    "00001000"); 

    CONSTANT tabla2 : arreglo := (
    "00110000", 
    "00110000", 
    "00011000", 
    "00011100", 
    "00111100", 
    "00111000", 
    "00100100", 
    "00000100"); 

    CONSTANT tabla3 : arreglo := (
    "00110000", 
    "00110000", 
    "00011100", 
    "01111010", 
    "00011000", 
    "00100100", 
    "00100010", 
    "00100000");

    CONSTANT tabla4 : arreglo := (
    "00110000", 
    "00110000", 
    "00011000", 
    "00011000", 
    "00111000", 
    "00011000", 
    "00011100", 
    "00010000");
    CONSTANT tabla9 : arreglo := (
    "10000001", 
    "01000010", 
    "00111100", 
    "00100100", 
    "00100100", 
    "00111100", 
    "01000010", 
    "10000001");

 
    SIGNAL tempo : INTEGER RANGE 0 TO 15 := 1;--
    SIGNAL duracion : STD_LOGIC_VECTOR(1 DOWNTO 0); --contador para el sonido
    SIGNAL conta_1250us : INTEGER RANGE 1 TO 20000000 := 1; 
    SIGNAL SAL_400Hz : STD_LOGIC := '0';

BEGIN --comienza la arquitectura
    -- proceso del divisor cldiv
    divisor : PROCESS (clk)
    BEGIN
        IF clk'event AND clk = '1' THEN
            clkdiv <= clkdiv + 1;
        END IF;
    END PROCESS divisor;

    asigna : PROCESS (clkdiv(M), barrido, hold)
    BEGIN

        IF rising_edge(CLK) THEN
            IF (conta_1250us = 5_000_000) THEN 

                SAL_400Hz <= NOT(SAL_400Hz); 
                conta_1250us <= 1;
            ELSE
                conta_1250us <= conta_1250us + 1;
            END IF;
        END IF;

        IF (SAL_400Hz'EVENT AND SAL_400Hz = '1') THEN
            IF tempo <= 3 THEN
                tempo <= tempo + 1;
            ELSE
                tempo <= 1;
            END IF;
        END IF;


        barrido <= clkdiv(N DOWNTO N - 2);

        IF tempo = 1 THEN
            tabla <= tabla1;
        ELSIF tempo = 2 THEN
            tabla <= tabla2;
        ELSIF tempo = 3 THEN
            tabla <= tabla3;
        ELSE
            tabla <= tabla4;
        END IF;

        IF hold = '0' THEN 
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
            sonidoOUT <= 'Z';
        ELSE 
            sonidoOUT <= '0';
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
                WHEN OTHERS => R <= tabla(8);
                    C <= "00000000";
            END CASE;
            
        END IF;

    END PROCESS asigna;

END matrixArrowMov;