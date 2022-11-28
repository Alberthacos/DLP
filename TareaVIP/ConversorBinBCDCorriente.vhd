LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY binary_bcd IS
    GENERIC (N : POSITIVE := 16);
    PORT (
        clk, reset_n : IN STD_LOGIC;
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display--"abcdefgP"
        AN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111111"; -- ánodos del display
        binary_inV,binary_inI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        --bcd0, bcd1, bcd2, bcd3, bcd4 : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0) --salida a leds indicadores
    );
END binary_bcd;

ARCHITECTURE behaviour OF binary_bcd IS
    TYPE states IS (start, shift, done);
    SIGNAL state, state_next : states;

    SIGNAL binary, binary_next : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL bcds, bcds_reg, bcds_next : STD_LOGIC_VECTOR(19 DOWNTO 0);
    --output register keep output constant during conversion
    SIGNAL bcds_out_reg, bcds_out_reg_next : STD_LOGIC_VECTOR(19 DOWNTO 0);
    -- need to keep track of shifts
    SIGNAL shift_counter, shift_counter_next : NATURAL RANGE 0 TO N;
    --------------------------------------------------------------------------------
    SIGNAL contadors : INTEGER RANGE 1 TO 6250 := 1; -- pulso1 de 0.25ms (pro. divisor ánodos)
    SIGNAL contadorss,I : INTEGER RANGE 0 TO 5_000_000 := 1; -- pulso1 de 0.25ms (pro. divisor ánodos)
    

    -- Declaración de señales de la asignación de U-D-C-UM
    SIGNAL P : STD_LOGIC_VECTOR (19 DOWNTO 0); -- asigna UNI, DEC,CEN, MIL
    SIGNAL UNI, DEC, CEN, MIL, decMIL : INTEGER RANGE 0 TO 10; -- digitos unidades, decenas,millar, decenas millar
    SIGNAL UniV, decV, DecimasV : INTEGER RANGE 0 TO 20;
    SIGNAL Vo, vin : INTEGER RANGE 0 TO 500;
    -- centenas y unidad de millar
    SIGNAL NumeroBitsDecimal : INTEGER RANGE 0 TO 50_000_000;
    -- Declaración de señales de la multiplexación y asignación de U-D-C-UM al display
    SIGNAL SEL : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000"; -- selector de barrido
    SIGNAL D : INTEGER RANGE 0 TO 9;
    SIGNAL SAL_250us,SAL_250uss : STD_LOGIC;
    --------------------------------------------------------------------------------
BEGIN

    --PROCESS (clk, reset_n)
    --BEGIN
    --    IF reset_n = '0' THEN
    --        binary <= (OTHERS => '0');
    --        bcds <= (OTHERS => '0');
    --        state <= start;
    --        bcds_out_reg <= (OTHERS => '0');
    --        shift_counter <= 0;
    --    ELSIF falling_edge(clk) THEN
    --        binary <= binary_next;
    --        bcds <= bcds_next;
    --        state <= state_next;
    --        bcds_out_reg <= bcds_out_reg_next;
    --        shift_counter <= shift_counter_next;
    --    END IF;
    --END PROCESS;
--
    --convert :
    --PROCESS (state, binary, binary_in, bcds, bcds_reg, shift_counter)
    --BEGIN
    --    state_next <= state;
    --    bcds_next <= bcds;
    --    binary_next <= binary;
    --    shift_counter_next <= shift_counter;
--
    --    CASE state IS
    --        WHEN start =>
    --            state_next <= shift;
    --            binary_next <= '0' & binary_in(14 DOWNTO 0);
    --            bcds_next <= (OTHERS => '0');
    --            shift_counter_next <= 0;
    --        WHEN shift =>
    --            IF shift_counter = N THEN
    --                state_next <= done;
    --            ELSE
    --                binary_next <= binary(N - 2 DOWNTO 0) & 'L';
    --                bcds_next <= bcds_reg(18 DOWNTO 0) & binary(N - 1);
    --                shift_counter_next <= shift_counter + 1;
    --            END IF;
    --        WHEN done =>
    --            state_next <= start;
    --    END CASE;
    --END PROCESS;
--
    --bcds_reg(19 DOWNTO 16) <= bcds(19 DOWNTO 16) + 3 WHEN bcds(19 DOWNTO 16) > 4 ELSE
    --bcds(19 DOWNTO 16);
    --bcds_reg(15 DOWNTO 12) <= bcds(15 DOWNTO 12) + 3 WHEN bcds(15 DOWNTO 12) > 4 ELSE
    --bcds(15 DOWNTO 12);
    --bcds_reg(11 DOWNTO 8) <= bcds(11 DOWNTO 8) + 3 WHEN bcds(11 DOWNTO 8) > 4 ELSE
    --bcds(11 DOWNTO 8);
    --bcds_reg(7 DOWNTO 4) <= bcds(7 DOWNTO 4) + 3 WHEN bcds(7 DOWNTO 4) > 4 ELSE
    --bcds(7 DOWNTO 4);
    --bcds_reg(3 DOWNTO 0) <= bcds(3 DOWNTO 0) + 3 WHEN bcds(3 DOWNTO 0) > 4 ELSE
    --bcds(3 DOWNTO 0);
--
    --bcds_out_reg_next <= bcds WHEN state = done ELSE
    --    bcds_out_reg;
--
    --bcd4 <= bcds_out_reg(19 DOWNTO 16); --unidades
    --bcd3 <= bcds_out_reg(15 DOWNTO 12); --decenas
    --bcd2 <= bcds_out_reg(11 DOWNTO 8); --centenas
    --bcd1 <= bcds_out_reg(7 DOWNTO 4); --unidad de millar 
    --bcd0 <= bcds_out_reg(3 DOWNTO 0); --decenas de millar
--
    ---------------------DIVISOR ÁNODOS-------------------
    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF (contadors = 6250) THEN --cuenta 0.125ms (50MHz=6250)
                -- if (contadors = 12500) then --cuenta 0.125ms (100MHz=12500)
                SAL_250us <= NOT(SAL_250us); --genera un barrido de 0.25ms
                contadors <= 1;
            ELSE
                contadors <= contadors + 1;
            END IF;
        END IF;
    END PROCESS; -- fin del proceso Divisor Ánodos

    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF (contadorss = 4_000_000) THEN --cuenta 0.125ms (50MHz=6250)
                -- if (contadors _= 12500) then --cuenta 0.125ms (100MHz=12500)
                SAL_250uss <= NOT(SAL_250uss); --genera un barrido de 0.25ms
                contadorss <= 1;
            ELSE
                contadorss <= contadorss + 1;
            END IF;
        END IF;
    END PROCESS; -- fin del proceso Divisor Ánodos
    --------------------------------------------------------------------------------


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
            
            
            --DecMIL <= NumeroBitsDecimal/10_000; --decimas de millar
            --MIL <=  (NumeroBitsDecimal/1000)-(DecMIL*10); --millar
            --Cen <= (NumeroBitsDecimal/100)-(DecMIL*100)-(MIL*10);  ---centenas
            --Dec <= (NumeroBitsDecimal-DecMIL*10000-MIL*1000-Cen*100)/10; --decenas
            --Uni <= (NumeroBitsDecimal-DecMIL*10000-MIL*1000-Cen*100-Dec*10);    --unidades
            
     process(SAL_250uss)
       begin
        IF rising_edge(SAL_250uss) THEN 
        NumeroBitsDecimal <= TO_INTEGER(UNSIGNED(binary_in(14 DOWNTO 0)));--(decMIL * 10000) + (MIL * 1000) + (CEN * 100) + (DEC * 10) + UNI;
        Vo <= ((NumeroBitsDecimal * 5)/32768)*10_000; -- Vo <= ((NumeroBitsDecimal * 916_000)/1346200000);
        --Vin <= (Vo*(7500+30_000))/7500;
        I <= ((Vo-25000)/1);
        DecMIL <= Vo/1000; --millar [A] enteros
        MIL <= (vo-DecMil*1000)/100; --centenas
        Cen <= (Vo-DecMil*1000-MIL*100)/10;  --decenas
        Dec <= (Vo-DecMil*1000-MIL*100-Cen*10); --unidades mA
        Uni <= 0;    --unidades
        END IF;
       end process;
        
END behaviour;