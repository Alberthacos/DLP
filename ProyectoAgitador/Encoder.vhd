LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Botonera IS
    GENERIC (Max : NATURAL := 500000);
    PORT (
        CLK : IN STD_LOGIC; --Reloj 50 MHz
        PB1, PB2 : IN STD_LOGIC; --Botones que seleccionan los estados
        EnableMotor : IN STD_LOGIC;
        Conta1 : INOUT INTEGER RANGE 0 TO 7 := 0 --Contador de estados

    );

END Botonera;

ARCHITECTURE Behavioral OF Botonera IS
    --Signals
    SIGNAL sclk : INTEGER RANGE 0 TO 20_000_000 := 0;

    SIGNAL sampledPB1, sampledPB2 : STD_LOGIC; --Señal de muestra para comparar despues del tiempo sclk*(20us)
    SIGNAL PB1_DEB, PB2_DEB : STD_LOGIC; --Señal de botones sin ruido, señal final
    SIGNAL PBS : STD_LOGIC; --Señal de botones sin ruido, señal fina
BEGIN
    --------------------------------------------------------------------------------
    --SELECTOR VELOCIDADES
    --------------------------------------------------------------------------------
    Controlvelocidades : PROCESS (PB1_DEB, Conta1, pbs, PB2_DEB)
    BEGIN

        --  IF (EnableMotor = '1') THEN --Esta habilitado el motor 
        PBS <= PB1_DEB OR PB2_DEB;

        IF EnableMotor = '1' THEN
            IF rising_edge(PBS) THEN
                IF (PB1_DEB = '1' AND conta1 < 6) THEN
                    conta1 <= conta1 + 1;
                ELSIF (PB2_DEB = '1' AND conta1 > 1) THEN
                    conta1 <= conta1 - 1;
                END IF;
            END IF;
        ELSE
            conta1 <= 0;
        END IF;
        --ELSE
        -- conta1 <= 0; --motor apagado 
        --END IF;

    END PROCESS Controlvelocidades;
    --------------------------------------------------------------------------------
    -- DEBOUNCER
    --------------------------------------------------------------------------------
    Deb : PROCESS (clk) IS
    BEGIN

        IF clk'event AND clk = '1' THEN --Flanco ascendente
            sampledPB1 <= PB1; --muestra de PB1
            sampledPB2 <= PB2; --muestra de PB2

            --clock IS divided TO 1MHz
            --samples every 1uS TO check IF the input IS the same as the sample
            --IF the SIGNAL IS stable, the debouncer should output the SIGNAL

            IF sclk = 3_000_000 THEN --Tiempo de prueba sclk*20us
                --PB1
                IF sampledPB1 = PB1 THEN --si cuenta con el mismo estado que cuando se presiono, entonces:
                    PB1_DEB <= PB1; --Se asigna el valor a la variable sin ruido 
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
    END PROCESS Deb;

END Behavioral;