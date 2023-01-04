

--LIBRARY IEEE;
--USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--ENTITY Conv_Bin_BCD IS
--    PORT (
--
--        Binario : IN STD_LOGIC_VECTOR (13 DOWNTO 0); --bits
--        CLK50Mhz : IN STD_LOGIC;
--        Catodos : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
--        Anodos : OUT STD_LOGIC_VECTOR (3 DOWNTO 0) --max num 1024
--    );
--END Conv_Bin_BCD;
--
--ARCHITECTURE Behavioral OF Conv_Bin_BCD IS
--    --contador selector q
--    SIGNAL Q : STD_LOGIC_VECTOR (1 DOWNTO 0); --revisar
--    --reloj
--    SIGNAL pulso : STD_LOGIC := '0';
--    SIGNAL Cen, Dec, Uni, Mil, BCD : STD_LOGIC_VECTOR (3 DOWNTO 0);
--    SIGNAL contador : INTEGER RANGE 0 TO 50000000 := 0;
--BEGIN
--
--    PROCESS (Binario)
--        VARIABLE Z : STD_LOGIC_VECTOR (29 DOWNTO 0);
--    BEGIN
--
--        --        FOR i IN 0 TO 25 LOOP
--        --            Z(i) := '0';
--        --        END LOOP;
--        --
--        --        Z(12 DOWNTO 3) := Binario;
--        --        FOR i IN 0 TO 4 LOOP
--        --        
--        --            IF Z(13 DOWNTO 10) > 4 THEN
--        --                Z(13 DOWNTO 10) := Z(13 DOWNTO 10) + 3;   --
--        --            END IF;
--        --
--        --            IF Z(17 DOWNTO 14) > 4 THEN
--        --                Z(17 DOWNTO 14) := Z(17 DOWNTO 14) + 3;   --decenas
--        --            END IF;
--        --
--        --            IF Z(21 DOWNTO 18) > 4 THEN
--        --                Z(21 DOWNTO 18) := Z(21 DOWNTO 18) + 3; --centenas
--        --            END IF;
--        --
--        --            Z(25 DOWNTO 1) := Z(24 DOWNTO 0);
--        --
--        --        END LOOP;
--        --        Mil <= Z(25 DOWNTO 22);
--        --        Cen <= Z(21 DOWNTO 18);
--        --        Dec <= Z(17 DOWNTO 14);
--        --        Uni <= Z(13 DOWNTO 10);
--        FOR i IN 0 TO 29 LOOP --
--            z(i) := '0'; -- se inicializa con 0
--        END LOOP;
--
--        Z(13 DOWNTO 0) := Binario; --contador de 14 bits
--        -- UM_C_D_U(17 DOWNTO 4):=CONT(13 downto 0); --contador de 14 bits, carga desde
--
--        -- el shift4
--
--        --ciclo de asignación UM-C-D-U
--        FOR I IN 0 TO 13 LOOP
--            -- FOR I IN 0 TO 9 LOOP -- si carga desde shift4 solo hace 10 veces el ciclo shift add
--            -- los siguientes condicionantes comparan (>=5) y suman 3
--            IF Z(17 DOWNTO 14) > 4 THEN -- U
--                Z(17 DOWNTO 14) := Z(17 DOWNTO 14) + 3;
--            END IF;
--            IF Z(21 DOWNTO 18) > 4 THEN -- D
--                Z(21 DOWNTO 18) := Z(21 DOWNTO 18) + 3;
--            END IF;
--            IF Z(25 DOWNTO 22) > 4 THEN -- C
--                Z(25 DOWNTO 22) := Z(25 DOWNTO 22) + 3;
--            END IF;
--            IF Z(29 DOWNTO 26) > 4 THEN -- UM
--                Z(29 DOWNTO 26) := Z(29 DOWNTO 26) + 3;
--            END IF;
--            -- realiza el corrimiento
--            Z(29 DOWNTO 1) := Z(28 DOWNTO 0);
--        END LOOP;
--        --P <= Z(29 DOWNTO 14); -- guarda en P y en seguida se separan UM-C-D-U
--
--    --UNIDADES
--    UNI <= Z(17 DOWNTO 14);
--    --DECENAS
--    DEC <= Z(21 DOWNTO 18);
--    --CENTENAS
--    CEN <= Z(25 DOWNTO 22);
--    --MILLARES
--    MIL <= Z(29 DOWNTO 26);
--
--END PROCESS;
--
--PROCESS (Q, MIl, Cen, Dec, Uni)
--BEGIN
--    CASE Q IS
--        WHEN "00" => BCD <= Mil;
--        WHEN "01" => BCD <= Cen;
--        WHEN "10" => BCD <= Dec;
--        WHEN "11" => BCD <= dec;
--        WHEN OTHERS => BCD <= "0000";
--    END CASE;
--END PROCESS;
--
--PROCESS (BCD)
--BEGIN
--    CASE BCD IS
--        WHEN "0000" => Catodos <= "0000001"; --0
--        WHEN "0001" => Catodos <= "1001111"; --1
--        WHEN "0010" => Catodos <= "0010010"; --2
--        WHEN "0011" => Catodos <= "0000110"; --3
--        WHEN "0100" => Catodos <= "1001100"; --4 
--        WHEN "0101" => Catodos <= "0100100"; --5
--        WHEN "0110" => Catodos <= "0100000"; --6
--        WHEN "0111" => Catodos <= "0001111"; --7
--        WHEN "1000" => Catodos <= "0000000"; --8
--        WHEN "1001" => Catodos <= "0001100"; --9
--        WHEN OTHERS => Catodos <= "0001100"; --9
--    END CASE;
--END PROCESS;
--PROCESS (Q)
--BEGIN
--    CASE Q IS
--        WHEN "00" => Anodos <= "0111";
--        WHEN "01" => Anodos <= "1011";
--        WHEN "10" => Anodos <= "1101";
--        WHEN "11" => Anodos <= "1110";
--        WHEN OTHERS => Anodos <= "1111";
--    END CASE;
--    Anodos(0) <= '1';
--END PROCESS;
----contador para reloj 1khz
--PROCESS (pulso)
--BEGIN
--    IF pulso = '1' AND pulso'event THEN
--
--        IF Q = "11" THEN
--            Q <= "00";
--        ELSE
--            Q <= Q + '1';
--        END IF;
--    END IF;
--END PROCESS;
----reloj 1khz
--PROCESS (CLK50Mhz)
--BEGIN
--    IF (CLK50Mhz'event AND CLK50Mhz = '1') THEN
--        IF (contador = 4999999) THEN --24999
--            pulso <= NOT(pulso);
--            contador <= 0;
--        ELSE
--            contador <= contador + 1;
--        END IF;
--    END IF;
--END PROCESS;
----CLK1KHZ <= pulso;
--
--END Behavioral;
--------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------

-- Contador de ms ascendente y descendente, con reset asíncrono
-- y pwm manual con período de 10s con salida a un led como indicador visual.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- Declaración de la entidad

ENTITY Contador IS
    PORT (
        Binario : IN STD_LOGIC_VECTOR (15 DOWNTO 0); --bits
        UpDown : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- botones para subir y bajar los
        CLK : IN STD_LOGIC; -- reloj de 50MHz para la nexys 2 y 100MHz para nexys 3
        RESET : IN STD_LOGIC; -- reset
        SALED : OUT STD_LOGIC; -- salida del led testigo
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display
        --"abcdefgP"
        AN : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)); -- ánodos del display

END Contador;

-- Declaración de la arquitectura
ARCHITECTURE Behavioral OF Contador IS

    -- Declaración de señales de los divisores
    SIGNAL contadors : INTEGER RANGE 1 TO 6250 := 1; -- pulso1 de 0.25ms (pro. divisor ánodos)

    -- Declaración de señales de la asignación de U-D-C-UM
    SIGNAL P : STD_LOGIC_VECTOR (19 DOWNTO 0); -- asigna UNI, DEC,CEN, MIL
    SIGNAL UNI, DEC, CEN, MIL, decMIL : STD_LOGIC_VECTOR (3 DOWNTO 0); -- digitos unidades, decenas,millar, decenas millar
    -- centenas y unidad de millar
    -- Declaración de señales de la multiplexación y asignación de U-D-C-UM al display
    SIGNAL SEL : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000"; -- selector de barrido
    SIGNAL D : STD_LOGIC_VECTOR (3 DOWNTO 0); -- sirve para almacenar los valores del display
    SIGNAL SAL_250us : STD_LOGIC;

BEGIN
    -----------CONVERTIR DE BIN A BCD------------------
    -- Este proceso contiene un algoritmo recorre y suma 3 para convertir un número binario a
    -- bcd, que se manda a los displays.
    -- El algoritmo consiste en desplazar (shift) el vector inicial (en binario) el número de veces
    -- según sea el número de bits, y cuando alguno de los bloques de 4 bits (U-D-C-UM, que
    -- es el número de bits necesarios para que cuente de 0 a 9 por cifra) sea igual o mayor a 5
    -- (por eso el >4) se le debe sumar 3 a ese bloque, después se continua desplazando hasta
    -- que otro (o el mismo) bloque cumpla con esa condición y se le sumen 3.
    -- Inicialmente se rota 3 veces porque es el número mínimo de bits que debe tener para que
    -- sea igual o mayor a 5.
    -- Finalmente se asigna a otro vector, el vector ya convertido, que cuenta con 4 bloques para
    -- las 4 cifras de 4 bits cada una.
    PROCESS (CLK)
        VARIABLE UM_C_D_U : STD_LOGIC_VECTOR(35 DOWNTO 0);
        --30 bits para separar las U.Millar-Centenas-Decenas-Unidades 14y16=30 16y20=36
    BEGIN

        --ciclo de inicialización
        FOR I IN 0 TO 29 LOOP --
            UM_C_D_U(I) := '0'; -- se inicializa con 0
        END LOOP;

        UM_C_D_U(15 DOWNTO 0) := BINARIO; --contador de 14 bits
        -- UM_C_D_U(17 DOWNTO 4):=CONT(13 downto 0); --contador de 14 bits, carga desde

        -- el shift4

        --ciclo de asignación UM-C-D-U
        FOR I IN 0 TO 15 LOOP
            -- FOR I IN 0 TO 9 LOOP -- si carga desde shift4 solo hace 10 veces el ciclo shift add
            -- los siguientes condicionantes comparan (>=5) y suman 3
            --IF UM_C_D_U(19 DOWNTO 16) > 4 THEN -- U
            --    UM_C_D_U(19 DOWNTO 16) := UM_C_D_U(19 DOWNTO 16) + 3;
            --END IF;
            --IF UM_C_D_U(23 DOWNTO 20) > 4 THEN -- D
            --    UM_C_D_U(23 DOWNTO 20) := UM_C_D_U(23 DOWNTO 20) + 3;
            --END IF;
            --IF UM_C_D_U(27 DOWNTO 24) > 4 THEN -- C
            --    UM_C_D_U(27 DOWNTO 24) := UM_C_D_U(27 DOWNTO 24) + 3;
            --END IF;
            --IF UM_C_D_U(31 DOWNTO 28) > 4 THEN -- UM
            --    UM_C_D_U(31 DOWNTO 28) := UM_C_D_U(31 DOWNTO 28) + 3;
            --END IF;
            --
            --IF UM_C_D_U(35 DOWNTO 32) > 4 THEN -- DM
            --    UM_C_D_U(35 DOWNTO 32) := UM_C_D_U(35 DOWNTO 32) + 3;
            --END IF;
            IF UM_C_D_U(34 DOWNTO 31) > 4 THEN
                UM_C_D_U(35 DOWNTO 31) := UM_C_D_U(35 DOWNTO 31) + 3;
            END IF;

            IF UM_C_D_U(31 DOWNTO 28) > 4 THEN
                UM_C_D_U(35 DOWNTO 28) := UM_C_D_U(35 DOWNTO 28) + 3;
            END IF;

            IF UM_C_D_U(27 DOWNTO 24) > 4 THEN
                UM_C_D_U(35 DOWNTO 24) := UM_C_D_U(35 DOWNTO 24) + 3;
            END IF;

            IF UM_C_D_U(23 DOWNTO 20) > 4 THEN
                UM_C_D_U(35 DOWNTO 20) := UM_C_D_U(35 DOWNTO 20) + 3;
            END IF;

            IF UM_C_D_U(19 DOWNTO 16) > 4 THEN
                UM_C_D_U(35 DOWNTO 16) := UM_C_D_U(35 DOWNTO 16) + 3;
            END IF;
            -- realiza el corrimiento
            UM_C_D_U(35 DOWNTO 1) := UM_C_D_U(34 DOWNTO 0);
            UM_C_D_U(0) := '0';
        END LOOP;
        --P <= UM_C_D_U(35 DOWNTO 16); -- guarda en P y en seguida se separan UM-C-D-U
        --UNIDADES
        UNI <= UM_C_D_U(19 DOWNTO 16);--P(3 DOWNTO 0);
        --DECENAS
        DEC <= UM_C_D_U(23 DOWNTO 20);--P(7 DOWNTO 4);
        --CENTENAS
        CEN <= UM_C_D_U(27 DOWNTO 24);--P(11 DOWNTO 8);
        --MILLARES
        MIL <= UM_C_D_U(31 DOWNTO 28);--P(15 DOWNTO 12);
        --unidades de MILLAR
        decMIL <= UM_C_D_U(35 DOWNTO 32);--P(19 DOWNTO 16);
    END PROCESS;
    -------------------DIVISOR ÁNODOS-------------------
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

    --------------------MULTIPLEXOR---------------------
    PROCESS (SAL_250us, sel, UNI, DEC, CEN, MIL)
    BEGIN
        IF SAL_250us'EVENT AND SAL_250us = '1' THEN
            SEL <= SEL + '1';
            CASE(SEL) IS
                WHEN "000" => AN <= "01111";
                D <= UNI; -- UNIDADES
                WHEN "001" => AN <= "10111";
                D <= DEC; -- DECENAS
                WHEN "010" => AN <= "11011";
                D <= CEN; -- CENTENAS
                WHEN "011" => AN <= "11101";
                D <= mil; -- UNIDAD DE MILLAR
                WHEN "100" => AN <= "11110";
                D <= decMIL; -- decenas DE MILLAR

                WHEN OTHERS => AN <= "11110";
                D <= decMIL; -- UNIDAD DE MILLAR
            END CASE;
        END IF;
    END PROCESS; -- fin del proceso Multiplexor

    --------------------DISPLAY---------------------
    PROCESS (D)
    BEGIN
        CASE(D) IS -- abcdefgP
            WHEN "0000" => DISPLAY <= "00000011"; --0
            WHEN "0001" => DISPLAY <= "10011111"; --1
            WHEN "0010" => DISPLAY <= "00100101"; --2
            WHEN "0011" => DISPLAY <= "00001101"; --3
            WHEN "0100" => DISPLAY <= "10011001"; --4
            WHEN "0101" => DISPLAY <= "01001001"; --5
            WHEN "0110" => DISPLAY <= "01000001"; --6
            WHEN "0111" => DISPLAY <= "00011111"; --7
            WHEN "1000" => DISPLAY <= "00000001"; --8
            WHEN "1001" => DISPLAY <= "00001001"; --9
            WHEN OTHERS => DISPLAY <= "11111111"; --apagado
        END CASE;
    END PROCESS; -- fin del proceso Display
    ------------------------------------------------
END Behavioral; -- fin de la arquitectura