LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY Clks IS
    PORT (
        clk : IN STD_LOGIC; --Reloj 50 Mhz amiba 
        AN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        LimHr : IN INTEGER RANGE 0 TO 59;
        LimMin : IN INTEGER RANGE 0 TO 59;
        LimSec : IN INTEGER RANGE 0 TO 59;
        PauseOUT, StartOUT : IN STD_LOGIC;
        Enc : INOUT STD_LOGIC := '0';
        LED : OUT STD_LOGIC --Pulsos de salida de 0.125ms y 1s
    );
END Clks;

ARCHITECTURE behaviour OF Clks IS
    --signals 
    --------------------------------------------------------------------------------
    SIGNAL contadors : INTEGER RANGE 1 TO 6250 := 1; -- pulso de 0.25ms (pro. divisor ánodos)
    SIGNAL SEL : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";

    SIGNAL contadors1 : INTEGER RANGE 1 TO 50_000_001 := 1; -- pulso de 1 segundo 
    SIGNAL SAL_250us, SAL_250us1 : STD_LOGIC;
    SIGNAL D : INTEGER RANGE 0 TO 9;

    SIGNAL UniSec, DecSec : INTEGER RANGE 0 TO 9 := 0; --Unidades y decenas segundos 
    SIGNAL UniMin, DecMin : INTEGER RANGE 0 TO 9 := 0; --Unidades y decenas minutos 
    SIGNAL UniHr, DecHr : INTEGER RANGE 0 TO 9 := 0; --Unidades y decenas horas 

    SIGNAL ContaHr : INTEGER RANGE 0 TO 59 := 0; --Contador de horas
    SIGNAL ContaMin : INTEGER RANGE 0 TO 59 := 0; --Contador de minutos
    SIGNAL ContaSec : INTEGER RANGE 0 TO 59 := 0; --Contador de segundos

    --Limites totales para cada valor 
    SIGNAL LimSecTot : INTEGER RANGE 0 TO 1_000_000 := 0; --
    SIGNAL LimMinTot : INTEGER RANGE 0 TO 1_000_000 := 0; --
    SIGNAL LimHrTot : INTEGER RANGE 0 TO 59 := 0; --

    --------------------------------------------------------------------------------
BEGIN

    ---------------------Pulso de un segundo-------------------
    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF (contadors1 = 25_000_000) THEN --20us*25_000_000=0.5s
                SAL_250us1 <= NOT(SAL_250us1); --genera un pulso de un segundo 
                contadors1 <= 1;
            ELSE
                contadors1 <= contadors1 + 1;
            END IF;
        END IF;
    END PROCESS;
    ------------------------------------------------------------
    LED <= ENC;

    PROCESS (SAL_250us1) BEGIN

        IF rising_edge(StartOUT) THEN
            ContaHr <= LimHr;
            ContaMin <= LimMin;
            ContaSec <= LimSec;
            LimSecTot <= LimHr * 3600 + LimMin * 60 + Limsec;
            LimMinTot <= LimHr * 60 + LimMin;
            LimHrTot <= LimHr;
            IF StartOUT = '1' THEN
                ENC <= '1';
            END IF;
        END IF;
        IF PauseOUT = '1' THEN
            ENC <= '0';
        END IF;

        IF rising_edge(SAL_250us1) AND Enc = '1' THEN --Flanco ascendente 
            --------------------------------------------------------------------------------
            --INICIO SEGUNDOS
            IF ContaSec = 0 THEN
                --------------------------------------------------------------------------------
                --INICIO Minutos
                IF ContaMin = 0 THEN
                    --------------------------------------------------------------------------------
                    --INICIO Horas
                    IF ContaHr = 0 THEN
                        IF LimHrTot = 0 THEN
                            ContaHr <= 0;
                        ELSIF LimHrTot <= 59 AND LimHrTot > 0 THEN
                            ContaHr <= LimHrTot;
                        ELSE
                            ContaHr <= 59;
                        END IF;
                    ELSIF LimHrTot > 0 THEN
                        ContaHr <= ContaHr - 1;
                        LimHrTot <= LimHrTot - 1;
                    END IF;
                    --FIN HORAS
                    --------------------------------------------------------------------------------
                    IF LimMinTot = 0 THEN
                        ContaMin <= 0;
                    ELSIF LimMinTot <= 59 AND LimMinTot > 0 THEN
                        ContaMin <= LimMinTot;
                    ELSE
                        ContaMin <= 59;
                    END IF;

                ELSIF LimMinTot > 0 THEN
                    ContaMin <= ContaMin - 1;
                    LimMinTot <= LimMinTot - 1;
                END IF;
                --FIN MINUTOS
                --------------------------------------------------------------------------------

                IF LimSecTot = 0 THEN
                    ContaSec <= 0;
                ELSIF LimSecTot <= 59 AND LimSecTot > 0 THEN
                    ContaSec <= LimSecTot;
                ELSE
                    ContaSec <= 59;
                END IF;

            ELSIF LimSecTot > 0 THEN
                ContaSec <= ContaSec - 1; --Aumenta el contador de segundos
                LimSecTot <= LimSecTot - 1;
            END IF;
            --FIN SEGUNDOS
            --------------------------------------------------------------------------------
        END IF;

        IF ENC = '1' THEN
            DecSec <= LimSec/10;
            UniSec <= LimSec - DecSec * 10;
            DecMin <= LimMin/10;
            UniMin <= LimMin - DecMin * 10;
            DecHr <= LimHr/10;
            UniHr <= LimHr - DecHr * 10;
        ELSE
            DecSec <= ContaSec/10;
            UniSec <= ContaSec - DecSec * 10;
            DecMin <= ContaMin/10;
            UniMin <= ContaMin - DecMin * 10;
            DecHr <= ContaHr/10;
            UniHr <= ContaHr - DecHr * 10;
        END IF;
    END PROCESS;

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
    --------------------------------------------------------------------------------
END behaviour;