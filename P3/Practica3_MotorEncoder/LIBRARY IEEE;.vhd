LIBRARY IEEE;

USE IEEE.STD_LOGIC_1164.ALL;

USE IEEE.STD_LOGIC_ARITH.ALL;

USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Encoder IS PORT (

    Enc1, Enc2 : IN STD_LOGIC;
    SWITCH : IN STD_LOGIC;
    clk : IN STD_LOGIC;
    ControlVelocidad : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    salida : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
);

END Encoder;

ARCHITECTURE Behavioral OF Encoder IS

    SIGNAL numeroEncoder : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL clk_filtro : STD_LOGIC;
    SIGNAL Switch_filtrado : STD_LOGIC;
    SIGNAL delay1, delay2, delay3 : STD_LOGIC;
    TYPE Estados IS (Idle, Def, edo1, edo2, reg);
    SIGNAL Edo_Actual, Next_State : Estados := Idle;

    SIGNAL VelocidadReg : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL TemperaturaReg : STD_LOGIC_VECTOR(2 DOWNTO 0);

    CONSTANT LIMITE_MAXIMO : STD_LOGIC_VECTOR(2 DOWNTO 0) := "101";
    CONSTANT LIMITE_MINIMO : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";

BEGIN
    divFrec : PROCESS (clk)

        VARIABLE contador : INTEGER := 0;

    BEGIN

        IF clk'event AND clk = '1' THEN
            IF contador = 62_499 THEN
                contador := 0;
                clk_filtro <= NOT clk_filtro;
            ELSE
                contador := contador + 1;
            END IF;
        END IF;

    END PROCESS; -- divFrec 

    -- 

    --          SWITCH ENCODER 

    -- 

    PROCESS (clk_filtro)

    BEGIN

        IF clk_filtro'event AND clk_filtro = '1' THEN
            delay1 <= SWITCH;
            delay2 <= delay1;
            delay3 <= delay2;
        END IF;

    END PROCESS;

 --   Switch_filtrado <= delay1 AND delay2 AND delay3;
--
--    --Parte combinacional 
--
--    PROCESS (Enc1, Enc2, Edo_Actual, numeroEncoder) BEGIN
--
--        CASE Edo_Actual IS
--
--                --Estado de espera 
--            WHEN Idle =>
--
--                IF (Enc1 = '1') THEN
--                    Next_State <= Def; --Se manda al estado de definición 
--                ELSE
--                    Next_State <= Idle;
--                END IF;
--
--                --Estado de definicion          
--
--            WHEN Def =>
--
--                IF (Enc2 = '0') THEN
--                    Next_State <= edo1;
--                ELSE
--                    Next_State <= edo2;
--                END IF;
--
--            WHEN edo1 =>
--                Next_State <= reg;
--
--            WHEN edo2 =>
--                Next_State <= reg;
--
--            WHEN reg =>
--
--                IF (Enc1 = '0' AND Enc2 = '0') THEN
--                    Next_State <= Idle;
--                ELSE
--                    Next_State <= reg;
--                END IF;
--
--        END CASE;
--
--    END PROCESS;
--    --Parte Secuencial 
--
--END PROCESS;

salida <= "000";

---------------------------------
-----------------------------
----------------------------------------

PBS <= PB1_DEB OR PB2_DEB;
Deb : PROCESS (clk) IS
BEGIN

    IF clk'event AND clk = '1' THEN --Flanco ascendente
        sampledPB1 <= Enc1; --muestra de Enc1
        sampledPB2 <= PB2; --muestra de PB2

        --clock IS divided TO 1MHz
        --samples every 1uS TO check IF the input IS the same as the sample
        --IF the SIGNAL IS stable, the debouncer should output the SIGNAL

        IF sclk = 3_000_000 THEN --Tiempo de prueba sclk*20us
            --Enc1
            IF sampledPB1 = Enc1 THEN --si cuenta con el mismo estado que cuando se presiono, entonces:
                PB1_DEB <= Enc1; --Se asigna el valor a la variable sin ruido 
            END IF;
            --PB2
            IF sampledPB2 = PB2 THEN
                PB2_DEB <= PB2;
            END IF;

            sclk <= 0;
        ELSE
            sclk <= sclk + 1;
        END IF;
    END IF;

    IF rising_edge(PB1_DEB) THEN
        IF VelocidadReg = "100" THEN --Flanco ascendente en pulsador 1 y contador menor-igual a 2
            --Conta1 <= 0;
            VelocidadReg <= "000";
        ELSE
            VelocidadReg <= VelocidadReg + '1';
            --Conta1 <= Conta1 + 1; --se reinicia, vuelve al estado inicial
        END IF;
    END IF;
END PROCESS Deb;

ControlVelocidad <= VelocidadReg;

END Behavioral;