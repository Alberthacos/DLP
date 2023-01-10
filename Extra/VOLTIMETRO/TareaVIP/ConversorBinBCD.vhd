LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY binary_bcd IS
    PORT (
        clk : IN STD_LOGIC; --Reloj 50Mhz amiba 2
        reset_n : IN STD_LOGIC; --Boton reset
        HLD : IN STD_LOGIC;
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display--"abcdefgP"
        AN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111111"; -- ánodos del display
        SAL_250us : IN STD_LOGIC;
        SAL_250us1 : IN STD_LOGIC;
        binary_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0) --Binario recibido desde el adc 16 bits
    );
END binary_bcd;

ARCHITECTURE behaviour OF binary_bcd IS
    --------------------------------------------------------------------------------
    -- Declaración de señales de la asignación de U-D-C-UM
    SIGNAL UNI, DEC, CEN, MIL, decMIL : INTEGER RANGE 0 TO 70_000_000; -- digitos unidades, decenas,millar, decenas millar
    SIGNAL vin : INTEGER RANGE 0 TO 100_000_000;
    SIGNAL Vdisp : INTEGER RANGE 0 TO 100_000_000;

    SIGNAL NumeroBitsDecimal : INTEGER RANGE 0 TO 70_000_000;
    -- Declaración de señales de la multiplexación y asignación de U-D-C-UM al display
    SIGNAL SEL : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000"; -- selector de barrido
    SIGNAL D : INTEGER RANGE 0 TO 9;

    --------------------------------------------------------------------------------
BEGIN

    --------------------MULTIPLEXOR---------------------
    PROCESS (SAL_250us, sel)
    BEGIN
        IF SAL_250us'EVENT AND SAL_250us = '1' THEN
            SEL <= SEL + '1';
            CASE(SEL) IS
                WHEN "000" => AN <= "01111111"; D <= DecMIL; -- UNIDADES
                WHEN "001" => AN <= "10111111"; D <= MIL; -- DECENAS
                WHEN "010" => AN <= "11011111"; D <= Cen; -- CENTENAS
                WHEN "011" => AN <= "11101111"; D <= Dec; -- UNIDAD DE MILLAR
                WHEN "100" => AN <= "11110111"; D <= UNI; -- DECENAS DE MILLAR
                WHEN OTHERS => AN <= "11110111"; D <= 0; -- DECENAS DE MILLAR
            END CASE;
        END IF;
    END PROCESS; -- fin del proceso Multiplexor

    ----------------------DISPLAY---------------------
    PROCESS (D,SEL)
    BEGIN
        IF SEL = "010" THEN
            CASE(D) IS -- abcdefgP
                WHEN 0 => DISPLAY <= "00000010"; --0 
                WHEN 1 => DISPLAY <= "10011110"; --1
                WHEN 2 => DISPLAY <= "00100100"; --2
                WHEN 3 => DISPLAY <= "00001100"; --3
                WHEN 4 => DISPLAY <= "10011000"; --4
                WHEN 5 => DISPLAY <= "01001000"; --5
                WHEN 6 => DISPLAY <= "01000000"; --6
                WHEN 7 => DISPLAY <= "00011110"; --7
                WHEN 8 => DISPLAY <= "00000000"; --8
                WHEN 9 => DISPLAY <= "00001000"; --9
                WHEN OTHERS => DISPLAY <= "11111111"; --apagado
            END CASE;
        ELSIF SEL ="101" THEN 
        DISPLAY <= "10000011";
        ELSE
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
        END IF;
    END PROCESS; -- fin del proceso Display
    --------------------------------------------------
    --------------------------------------------------

    PROCESS (SAL_250us1)
    BEGIN
        IF SAL_250us'event AND SAL_250us = '1' THEN
            --Conversion Bits a decimal 
            NumeroBitsDecimal <= TO_INTEGER(UNSIGNED(binary_in(14 DOWNTO 0)));
            --Calculo de voltaje, relacion voltaje - bits
            Vin <= (NumeroBitsDecimal * 1723)/18270;

            IF HLD = '0' THEN --No se presiona HOLD
                Vdisp <= Vin; --Asigna valores calculados
            ELSE
                Vdisp <= Vdisp; --Mantiene el valor calculado hasta que se suelte el boton 
            END IF;

            DecMIL <= Vdisp/1000;--(NumeroBitsDecimal*1875*633)/1255000000; --decimas de millar
            MIL <= (Vdisp - DecMil * 1000)/100; --millar0
            Cen <= (Vdisp - DecMil * 1000 - MIL * 100)/10; ---centenas
            Dec <= (Vdisp - DecMil * 1000 - MIL * 100 - Cen * 10); --decenas
            Uni <= 0; --unidades

        END IF;
    END PROCESS;
END behaviour;