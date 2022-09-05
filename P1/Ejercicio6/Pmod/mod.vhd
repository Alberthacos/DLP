-- PmodALS Ambient Light Sensor
-- SPI CONTROLLER
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY SPI_ctrl_ALS IS
    GENERIC (
        N : INTEGER := 8; -- number of bit to serialize
        MAX : INTEGER := 333_333 -- number of us to sample
    );
    PORT (
        --FPGA clock and button
        clk : IN STD_LOGIC; -- 50MHz
        rst : IN STD_LOGIC; -- reset
        --PmodALS
        CS : OUT STD_LOGIC; -- Pmod chip selec
        SDO : IN STD_LOGIC; -- Pmod Serial Data Output
        SCK : OUT STD_LOGIC; -- Pmod Serial Clock
        -- led output
        data : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := x"00"; -- received data
        -- Display "abcdefgP"
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display
        AN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111" -- �nodos del display

    );
END SPI_ctrl_ALS;
--------------------------------------------------------------------------------
ARCHITECTURE behav OF SPI_ctrl_ALS IS
    --Declaraci�n de se�ales para SPI
    SIGNAL clkdiv : STD_LOGIC; -- divisor
    SIGNAL counter : INTEGER RANGE 0 TO MAX := 0; -- control counter
    SIGNAL cnt : STD_LOGIC_VECTOR(4 DOWNTO 0); -- divisor counter
    SIGNAL tempo : STD_LOGIC_VECTOR(0 TO 15) := x"0000"; -- save data
    --Declaraci�n de se�ales de la asignaci�n de U-D-C
    SIGNAL P : STD_LOGIC_VECTOR (9 DOWNTO 0); -- asigna UNI,DEC,CEN
    SIGNAL UNI, DEC, CEN : STD_LOGIC_VECTOR (3 DOWNTO 0); -- unidades, decenas, centenas
    -- Declaraci�n de se�ales de la multiplexaci�n y asignaci�n de U-D-C-UM al display
    SIGNAL SEL : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00"; -- selector de barrido
    SIGNAL D : STD_LOGIC_VECTOR (3 DOWNTO 0); -- sirve para almacenar los valores del display
    -- Declaraci�n de se�ales de los divisores
    SIGNAL contadors : INTEGER RANGE 1 TO 6250 := 1; -- pulso1 de 0.25ms (pro. divisor �nodos)
    -- para la nexys 2 6250, si se usa la nexys 3 cambiar a 12500
    SIGNAL SAL_250us : STD_LOGIC; --
BEGIN
    --------------------------------------------------------------------------------
    div : PROCESS (rst, clk, clkdiv)
    BEGIN
        -- divisor 1MHz (1us)
        IF (rst = '1') THEN
            clkdiv <= '0';
        ELSIF (rising_edge(clk)) THEN
            IF cnt = "11000" THEN
                cnt <= "00000"; -- 0 a 24

                clkdiv <= NOT clkdiv; -- 0.5us alto, 0.5us bajo

            ELSE
                cnt <= cnt + '1';
            END IF;
        END IF;
        SCK <= clkdiv;
    END PROCESS div;
    --------------------------------------------------------------------------------
    cnter : PROCESS (rst, counter, clkdiv)
    BEGIN
        -- divisor 1MHz (1us)
        IF (rst = '1' OR counter = MAX) THEN
            counter <= 0;
        ELSIF (rising_edge(clkdiv)) THEN
            counter <= counter + 1;
        END IF;
    END PROCESS cnter;
    --------------------------------------------------------------------------------
    receive : PROCESS (clkdiv, counter, tempo, SDO, rst)
    BEGIN
        --
        IF (rst = '1') THEN
            tempo <= (OTHERS => '0');
        ELSIF (rising_edge(clkdiv)) THEN
            CASE counter IS
                WHEN 0 => CS <= '1';
                WHEN 1 => CS <= '1';
                WHEN 2 => CS <= '0';
                WHEN 3 => tempo(0) <= SDO; --0
                WHEN 4 => tempo(1) <= SDO; --0
                WHEN 5 => tempo(2) <= SDO; --0
                WHEN 6 => tempo(3) <= SDO; --DB7
                WHEN 7 => tempo(4) <= SDO; --DB6
                WHEN 8 => tempo(5) <= SDO; --DB5
                WHEN 9 => tempo(6) <= SDO; --DB4
                WHEN 10 => tempo(7) <= SDO; --DB3
                WHEN 11 => tempo(8) <= SDO; --DB2
                WHEN 12 => tempo(9) <= SDO; --DB1
                WHEN 13 => tempo(10) <= SDO; --DB0
                WHEN 14 => tempo(11) <= SDO; --0
                WHEN 15 => tempo(12) <= SDO; --0
                WHEN 16 => tempo(13) <= SDO; --0
                WHEN 17 => tempo(14) <= SDO; --0
                WHEN 18 => tempo(15) <= SDO; --tri state
                WHEN 19 => CS <= '1'; --
                WHEN OTHERS => CS <= '1'; --
            END CASE;
        END IF;
        data <= tempo (3 TO 10);
    END PROCESS receive;
    ----------- CONVERTIR DE BIN A BCD -----------------------------
    -- utilizando shift and add
    PROCESS (tempo(3 TO 10))
        VARIABLE C_D_U : STD_LOGIC_VECTOR(17 DOWNTO 0);
        --18 bits para separar las Centenas-Decenas-Unidades
    BEGIN
        --ciclo de inicializaci�n
        FOR I IN 0 TO 17 LOOP --
            C_D_U(I) := '0'; -- se inicializa con 0
        END LOOP;
        C_D_U(7 DOWNTO 0) := tempo (3 TO 10); --tempo de 8 bits
        --ciclo de asignaci�n C-D-U
        FOR I IN 0 TO 7 LOOP
            -- los siguientes condicionantes comparan (>=5) y suman 3
            IF C_D_U(11 DOWNTO 8) > 4 THEN -- U
                C_D_U(11 DOWNTO 8) := C_D_U(11 DOWNTO 8) + 3;
            END IF;
            IF C_D_U(15 DOWNTO 12) > 4 THEN -- D
                C_D_U(15 DOWNTO 12) := C_D_U(15 DOWNTO 12) + 3;
            END IF;
            IF C_D_U(17 DOWNTO 16) > 4 THEN -- C
                C_D_U(17 DOWNTO 16) := C_D_U(17 DOWNTO 16) + 3;
            END IF;
            -- realiza el corrimiento
            C_D_U(17 DOWNTO 1) := C_D_U(16 DOWNTO 0);
        END LOOP;
        P <= C_D_U(17 DOWNTO 8); -- guarda en P y en seguida se separan UM-C-D-U
    END PROCESS;
    --UNIDADES
    UNI <= P(3 DOWNTO 0);
    --DECENAS
    DEC <= P(7 DOWNTO 4);
    --CENTENAS
    CEN <= "00" & P(9 DOWNTO 8);
    ------------------- DIVISOR �NODOS ----------------------------------------
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
    END PROCESS; -- fin del proceso Divisor �nodos
    -------------------- MULTIPLEXOR ------------------------------------------
    PROCESS (SAL_250us, sel, UNI, DEC, CEN)
    BEGIN
        IF SAL_250us'EVENT AND SAL_250us = '1' THEN
            SEL <= SEL + '1';
            CASE(SEL) IS
                WHEN "00" => AN <= "0111";
                D <= UNI; -- UNIDADES
                WHEN "01" => AN <= "1011";
                D <= DEC; -- DECENAS
                WHEN "10" => AN <= "1101";
                D <= CEN; -- CENTENAS
                WHEN OTHERS => AN <= "1111"; -- OFF
            END CASE;
        END IF;
    END PROCESS; -- fin del proceso Multiplexor
    -------------------- DISPLAY ------------------------------------------
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
    ------------------------------------------------------------------------------------------
END behav;