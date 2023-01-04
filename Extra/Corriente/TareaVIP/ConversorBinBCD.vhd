LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY binary_bcd IS
    PORT (
        clk : IN STD_LOGIC; --Reloj 50 Mhz amiba 
        reset_n : IN STD_LOGIC; --Boton reset
        HLD : IN STD_LOGIC; --Boton hold, mantiene la lectura que se muestra en el display
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display--"abcdefgP"
        AN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111111"; -- ánodos del display
        SAL_250us : IN STD_LOGIC; --Pulsos de salida de 0.125ms y 1s
        SAL_250us1 : IN STD_LOGIC;--Pulsos de salida de 0.125ms y 1s
        binary_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0) --Valor recibido desde el ADC 
    );
END binary_bcd;

ARCHITECTURE behaviour OF binary_bcd IS
    --signals 
    --------------------------------------------------------------------------------
    SIGNAL contadors : INTEGER RANGE 1 TO 6250 := 1; -- pulso de 0.25ms (pro. divisor ánodos)
    SIGNAL contadors1 : INTEGER RANGE 1 TO 50_000_000 := 1; -- pulso de 1 segundo 
    SIGNAL UNI, DEC, CEN, MIL, decMIL : INTEGER RANGE 0 TO 9; -- digitos: unidades, decenas, millar, decenas millar
    SIGNAL Iin, Idisp : INTEGER RANGE 0 TO 1_000_000; -- Voltaje calculado
    SIGNAL NumeroBitsDecimal : INTEGER RANGE 0 TO 40_000; --Recibe la conversion de bits a decimal 
    -- Declaración de señales de la multiplexación y asignación de U-D-C-UM al display
    SIGNAL SEL : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000"; -- selector de barrido
    SIGNAL D : INTEGER RANGE 0 TO 9;
    --SIGNAL SAL_250us, SAL_250us1 : STD_LOGIC;
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
    -----------------------------------------------------

    ----------------------DISPLAY---------------------
    PROCESS (D)
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

    -----------------------Calculo corriente----------
    PROCESS (SAL_250us1)
    BEGIN
        IF rising_edge(SAL_250us1) THEN
            --Convierte los 15 bits a decimal,el primer bit es el signo, por lo tanto no se toma en cuenta  
            NumeroBitsDecimal <= CONV_INTEGER((binary_in(14 DOWNTO 0)));

            --Calcula la corriente con base en las especificaciones del acs712
            Iin <= 178385 * (NumeroBitsDecimal - 13499)/100_000;

            IF HLD = '0' THEN --No se presiona HOLD
                Idisp <= Iin; --Asigna valores calculados
            ELSE
                Idisp <= Idisp; --Mantiene el valor calculado hasta que se suelte el boton 
            END IF;

            DecMIL <= Idisp/10_000; --Decenas (entero)
            MIL <= (Idisp - DecMil * 10_000)/1000; --Unidades(entero)
            Cen <= (Idisp - DecMil * 10_000 - MIL * 1000)/100; --Decimas 
            Dec <= (Idisp - DecMil * 10_000 - MIL * 1000 - Cen * 100)/10; --Centesimas
            Uni <= (Idisp - DecMil * 10_000 - MIL * 1000 - Cen * 100 - Dec * 10); --Milesimas

            --FUNCIONA REGULAR CORRIENTE 
            --  Iin <=((NumeroBitsDecimal-13493)*10_000)/5333;
            --  Iin <=(1875*(NumeroBitsDecimal-13498))/1000;
            --  
            --  decmil --(NumeroBitsDecimal*1875*633)/1255000000; --decimas de millar
            --  DecMIL<=Iin/1000;--(NumeroBitsDecimal*1875*633)/1255000000; --decimas de millar
            --  MIL <=(Iin-DecMil*1_000)/100; --millar0
            --  Cen <=(Iin-DecMil*1_000-MIL*100)/10;  ---centenas
            --  Dec <=(Iin-DecMil*1_000-MIL*100-Cen*10); --decenas
            --  Uni <=0 ;    --unidades
        END IF;
    END PROCESS;
END behaviour;