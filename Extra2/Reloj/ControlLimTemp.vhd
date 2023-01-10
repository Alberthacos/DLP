LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ControlLIM IS
    PORT (
        CLK : IN STD_LOGIC; --reloj 50 Mhz
        ENC : IN STD_LOGIC;
        --Botones de control general (ENTRADA)
        ButtonSub : IN STD_LOGIC;
        ButtonAdd : IN STD_LOGIC;
        ButtonPause : IN STD_LOGIC;
        ButtonStop : IN STD_LOGIC;
        ButtonReset : IN STD_LOGIC;
        ButtonStart : IN STD_LOGIC;
        --Botones de control general (SALIDA)
        PauseOUT : OUT STD_LOGIC;
        StartOUT : OUT STD_LOGIC;
        --Valores del limite elegido
        LimHr : INOUT INTEGER RANGE 0 TO 59 := 0;
        LimMin : INOUT INTEGER RANGE 0 TO 59 := 0;
        LimSec : INOUT INTEGER RANGE 0 TO 59 := 2;
        --Selector de limite (Hora, minutos o segundos)
        SelectorLiM : IN STD_LOGIC
    );
END ENTITY ControlLIM;

ARCHITECTURE Behavioral OF ControlLIM IS
    --signals 
    --DEBOUNCER
    CONSTANT lim_deb : INTEGER := 6_999_999;
    SIGNAL sclk : INTEGER RANGE 0 TO lim_deb := 0;
    SIGNAL sampledAdd, sampledSub, sampledPause, sampledStop, sampledReset, sampledStart : STD_LOGIC;
    SIGNAL AddOUT, SubOUT, StopOUT, ResetOUT : STD_LOGIC;

    --Limites temporizador
    SIGNAL clk_or : STD_LOGIC;

    SIGNAL ContadorSelLim : INTEGER RANGE 0 TO 4 := 0;
BEGIN

    Selector_Seccion : PROCESS (SelectorLiM)
    BEGIN
        clk_or <= AddOUT OR SubOUT;
        IF ENC = '0' THEN
            IF rising_edge(SelectorLiM) THEN --Se presiona boton que cambia entre secciones
                IF ContadorSelLim = 4 THEN
                    ContadorSelLim <= 0;
                ELSE
                    ContadorSelLim <= ContadorSelLim + 1;
                END IF;
            END IF;

            CASE ContadorSelLim IS
                WHEN 1 =>
                    IF rising_edge(clk_or) THEN
                        IF (ButtonAdd = '1') THEN
                            LimHr <= LimHr + 1;
                        ELSIF (ButtonSub = '1') THEN
                            LimHr <= LimHr - 1;
                        END IF;
                    END IF;
                WHEN 2 =>
                    IF rising_edge(clk_or) THEN
                        IF (ButtonAdd = '1') THEN
                            LimMin <= LimMin + 1;
                        ELSIF (ButtonSub = '1') THEN
                            LimMin <= LimMin - 1;
                        END IF;
                    END IF;

                WHEN 3 =>
                    IF rising_edge(clk_or) THEN
                        IF (ButtonAdd = '1') THEN
                            LimSec <= LimSec + 1;
                        ELSIF (ButtonSub = '1') THEN
                            LimSec <= LimSec - 1;
                        END IF;
                    END IF;
                WHEN OTHERS => NULL;
            END CASE;
        ELSE 
        LimSec <= LimSec;
        LimMin <= LimMin;
        LimHr <= LimHr;
        END IF;
    END PROCESS;
    -------------

    --------------------Debouncer----------------------------------

    debouncer_botones : PROCESS (clk, ButtonAdd, ButtonSub) BEGIN

        IF clk'event AND clk = '1' THEN
            sampledAdd <= ButtonAdd;
            sampledSub <= ButtonSub;
            sampledPause <= ButtonPause;
            sampledStop <= ButtonStop;
            sampledReset <= ButtonReset;
            sampledStart <= ButtonStart;
            -- clock is divided to 1MHz
            -- samples every 1uS to check if the input is the same as the sample
            -- if the signal is stable, the debouncer should output the signal
            IF sclk = lim_deb THEN

                -- Add OUT
                IF sampledAdd = buttonAdd THEN
                    AddOUT <= buttonadd;
                END IF;

                --sub OUT
                IF sampledSub = ButtonSub THEN
                    SubOUT <= ButtonSub;
                END IF;

                --Pause OUT
                IF sampledPause = ButtonPause THEN
                    PauseOUT <= ButtonPause;
                END IF;

                --Pause OUT
                IF sampledStop = ButtonStop THEN
                    StopOUT <= ButtonStop;
                END IF;

                --Reset OUT
                IF sampledReset = ButtonReset THEN
                    ResetOUT <= ButtonReset;
                END IF;

                --Start OUT
                IF sampledStart = ButtonStart THEN
                    StartOUT <= ButtonStart;
                END IF;

                sclk <= 0;
            ELSE
                sclk <= sclk + 1;
            END IF;
        END IF;
    END PROCESS;
    --------------------------Fin debouncer-------------------------------

END ARCHITECTURE Behavioral;