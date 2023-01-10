LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Deb IS
    PORT (
        CLK : IN STD_LOGIC; --reloj 50 Mhz

        --Botones de control general (ENTRADA)
        ButtonSub : IN STD_LOGIC;
        ButtonAdd : IN STD_LOGIC;
        ButtonPause : IN STD_LOGIC;
        ButtonStop : IN STD_LOGIC;
        ButtonReset : IN STD_LOGIC;
        ButtonStart : IN STD_LOGIC;
        ButtonSelLim : IN STD_LOGIC; --selector de seccion para limite
        --Botones de control general (SALIDA)
        PauseOUT : OUT STD_LOGIC;
        StartOUT : OUT STD_LOGIC;
        StopOUT : OUT STD_LOGIC;
        ResetOUT : OUT STD_LOGIC;
        AddOUT : OUT STD_LOGIC;
        SubOUT : OUT STD_LOGIC;
        SelLimOUT : OUT STD_LOGIC
        
    );
END ENTITY Deb;

ARCHITECTURE Behavioral OF Deb IS
    --signals 
    --DEBOUNCER
    CONSTANT lim_deb : INTEGER := 6_999_999;
    SIGNAL sclk : INTEGER RANGE 0 TO lim_deb := 0;
    SIGNAL sampledAdd, sampledSub, sampledPause, sampledStop, sampledReset, sampledStart,sampledSelLim : STD_LOGIC;

BEGIN

    --------------------Debouncer----------------------------------

    debouncer_botones : PROCESS (clk, ButtonAdd, ButtonSub) BEGIN

        IF clk'event AND clk = '1' THEN
            sampledAdd <= ButtonAdd;
            sampledSub <= ButtonSub;
            sampledPause <= ButtonPause;
            sampledStop <= ButtonStop;
            sampledReset <= ButtonReset;
            sampledStart <= ButtonStart;
            sampledSelLim <= ButtonSelLim;

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

                --SelLim OUT
                IF sampledSelLim = ButtonSelLim THEN
                    SelLimOUT <= ButtonSelLim;
                END IF;

                sclk <= 0;
            ELSE
                sclk <= sclk + 1;
            END IF;
        END IF;
    END PROCESS;
    --------------------------Fin debouncer-------------------------------

END ARCHITECTURE Behavioral;