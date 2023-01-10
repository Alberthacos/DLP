LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ControlLIM IS
    PORT (
        CLK : IN STD_LOGIC; --reloj 50 Mhz
        ButtonSub : IN STD_LOGIC;
        ButtonAdd : IN STD_LOGIC;
        ButtonPause : IN STD_LOGIC;
        ButtonStop : IN STD_LOGIC;
        ButtonReset : IN STD_LOGIC;
        ButtonStart : IN STD_LOGIC;
    );
END ENTITY ControlLIM;

ARCHITECTURE Behavioral OF ControlLIM IS
    --signals 
    --DEBOUNCER
    CONSTANT lim_deb : INTEGER := 6_999_999;
    SIGNAL sclk : INTEGER RANGE 0 TO lim_deb := 0;
    SIGNAL sampledA, sampledB, sampledS : STD_LOGIC;
    SIGNAL Aout, Bout, Sout : STD_LOGIC;
    --Limites temporizador
    SIGNAL lim : INTEGER RANGE 1 TO 21 := 10;
    SIGNAL clk_or : STD_LOGIC;
BEGIN
    PROCESS (clk)
    BEGIN
        clk_or <= AddOUT OR SubOUT;
            IF rising_edge(clk_or) THEN
                IF (ButtonAdd = '1') THEN
                    LimCh <= LimCh + 1;
                ELSIF (ButtonSub = '1') THEN
                    LimCh <= LimCh - 1;
                END IF;
            END IF;
    END PROCESS;
    -------------

    case '1' is
        when Hr => LimCh <= LimHr;
        when Min => LimCh <= LiMMin;
        when Sec => LimCh <= Limsec;
        when others => NUll;    
    end case;

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