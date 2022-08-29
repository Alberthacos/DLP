--------------------------------------------------------------------------------------
-- Controlador del display de 4 digitos
--------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
----------------------------------------------------------------
-- Declaracion de la entidad
ENTITY DISPLAYS IS
    PORT (

        signo, cantidad : IN STD_LOGIC_VECTOR (3 DOWNTO 0); -- digitos unidades, decenas,
        SAL_400Hz : IN STD_LOGIC; -- reloj de 400Hz
        CLK : IN STD_LOGIC;
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- seg dsply "abcdefgP"
        AN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)); -- anodos del display

END DISPLAYS;

ARCHITECTURE disp OF DISPLAYS IS
    SIGNAL UNI, DEC : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL SEL : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00"; -- selector de barrido
    SIGNAL D : STD_LOGIC_VECTOR (3 DOWNTO 0); -- almacena los valores del disp

BEGIN
    PROCESS (cantidad, SAL_400Hz, sel, UNI, DEC) BEGIN
        IF (cantidad < "1010") THEN
            UNI <= cantidad;
            DEC <= x"0";
        ELSE
            UNI <= cantidad-"1010";
            dec <= "0001";
        END IF;

        IF SAL_400Hz'EVENT AND SAL_400Hz = '1' THEN
            SEL <= SEL + '1';

            CASE(SEL) IS
                WHEN "00" => AN <= "1110";
                D <= UNI; -- UNIDADES
                WHEN "01" => AN <= "1101";
                D <= DEC; -- DECENAS
                WHEN "11" => AN <= "1011";
                D <= SIGNO; -- signo

                WHEN OTHERS => AN <= "1111";
                D <= SIGNO; -- signo
            END CASE;
        END IF;
    END PROCESS;

    --------------------MULTIPLEXOR---------------------
    PROCESS (D)
    BEGIN
        CASE(D) IS -- abcdefgP
            WHEN x"0" => DISPLAY <= "00000011"; --0
            WHEN x"1" => DISPLAY <= "10011111"; --1
            WHEN x"2" => DISPLAY <= "00100101"; --2
            WHEN x"3" => DISPLAY <= "00001101"; --3
            WHEN x"4" => DISPLAY <= "10011001"; --4
            WHEN x"5" => DISPLAY <= "01001001"; --5
            WHEN x"6" => DISPLAY <= "01000001"; --6
            WHEN x"7" => DISPLAY <= "00011111"; --7
            WHEN x"8" => DISPLAY <= "00000001"; --8
            WHEN x"9" => DISPLAY <= "00001001"; --9
            WHEN x"F" => DISPLAY <= "11111101"; --signo
            WHEN OTHERS => DISPLAY <= "11111111"; --apagado
        END CASE;
    END PROCESS; -- fin del proceso Display
    ------------------------------------------------

END ARCHITECTURE disp;