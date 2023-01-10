LIBRARY IEEE;

use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

ENTITY sevenseg IS
    PORT (
        clk : IN STD_LOGIC; --Reloj 50 Mhz amiba 

        AN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        ContaSecOUT : IN INTEGER RANGE 0 TO 59;
        ContaMinOUT : IN INTEGER RANGE 0 TO 59;
        ContaHrOUT : IN INTEGER RANGE 0 TO 59
    );
END sevenseg;

ARCHITECTURE behaviour OF sevenseg IS

    SIGNAL contadors : INTEGER RANGE 1 TO 6250 := 1; -- pulso de 0.25ms (pro. divisor ánodos)
    SIGNAL SEL : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";

    SIGNAL contadors1 : INTEGER RANGE 1 TO 50_000_001 := 1; -- pulso de 1 segundo 
    SIGNAL SAL_250us, SAL_250us1 : STD_LOGIC;
    SIGNAL D : INTEGER RANGE 0 TO 9;

    SIGNAL UniSec, DecSec : INTEGER RANGE 0 TO 9 := 0; --Unidades y decenas segundos 
    SIGNAL UniMin, DecMin : INTEGER RANGE 0 TO 9 := 0; --Unidades y decenas minutos 
    SIGNAL UniHr, DecHr : INTEGER RANGE 0 TO 9 := 0; --Unidades y decenas horas 
BEGIN
    ------------------------------------------------------
    ---------------------DIVISOR ÁNODOS-------------------
    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF (contadors = 6250) THEN --cuenta 0.125ms (50MHz=6250) 20us*6250=0.125ms ????????????????????????????
                SAL_250us <= NOT(SAL_250us); --genera un barrido de 0.125ms
                contadors <= 1;
            ELSE
                contadors <= contadors + 1;
            END IF;
        END IF;
    END PROCESS; -- fin del proceso Divisor Ánodos
    ---------------------------------------------------

    --------------------MULTIPLEXOR---------------------
    PROCESS (SAL_250us, sel)
    BEGIN

        DecSec <= ContaSecOUT/10;
        UniSec <= ContaSecOUT - DecSec * 10;
        DecMin <= ContaMinOUT/10;
        UniMin <= ContaMinOUT - DecMin * 10;
        DecHr <= ContaHrOUT/10;
        UniHr <= ContaHrOUT - DecHr * 10;

        IF SAL_250us'EVENT AND SAL_250us = '1' THEN
            SEL <= SEL + '1';
            CASE(SEL) IS
                WHEN "000" => AN <= "01111111";
                D <= DecHr; -- Decenas horas
                WHEN "001" => AN <= "10111111";
                D <= UniHr; -- Unidades horas
                WHEN "010" => AN <= "11011111";
                D <= DecMin; -- Decenas minutos
                WHEN "011" => AN <= "11101111";
                D <= UniMin; -- Unidades minutos
                WHEN "100" => AN <= "11111101";
                D <= DecSec; -- Decenas segundos
                WHEN "101" => AN <= "11111110";
                D <= UniSec; -- Unidades segundos
                WHEN OTHERS => AN <= "11111111";
                D <= 0;
            END CASE;
        END IF;
    END PROCESS; -- fin del proceso Multiplexor
    --------------------------------------------------

    ----------------------DISPLAY---------------------
    PROCESS (D)
    BEGIN
        CASE(D) IS -- abcdefgP
            WHEN 0 => DISPLAY <= "00000011"; --0 
            WHEN 1 => DISPLAY <= "10011111"; --1
            WHEN 2 => DISPLAY <= "00100101"; --2
            WHEN 3 => DISPLAY <= "00001101"; --3
            WHEN 4 => DISPLAY <= "10011001"; --4
            WHEN 5 => DISPLAY <= "01001001"; --5
            WHEN 6 => DISPLAY <= "01000001"; --6
            WHEN 7 => DISPLAY <= "00011111"; --7
            WHEN 8 => DISPLAY <= "00000001"; --8
            WHEN 9 => DISPLAY <= "00001001"; --9
            WHEN OTHERS => DISPLAY <= "11111111"; --apagado
        END CASE;
    END PROCESS; -- fin del proceso Display
    --------------------------------------------------
END behaviour;