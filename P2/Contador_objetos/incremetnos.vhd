LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--USE IEEE.numeric_std.ALL;
--USE ieee.std_logic_arith.ALL;
--USE ieee.std_logic_unsigned.ALL;
ENTITY incrementos IS
    PORT (
        CLK : IN STD_LOGIC; --reloj 50 Mhz
        ButtonSub : IN STD_LOGIC;
        ButtonAdd : IN STD_LOGIC;
        reset : IN STD_LOGIC; --Boton de reset 
        LedLim : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)

    );
END ENTITY incrementos;

ARCHITECTURE cont OF incrementos IS
    CONSTANT lim_deb : INTEGER := 6_999_999;
    SIGNAL sclk : INTEGER RANGE 0 TO lim_deb := 0;--STD_LOGIC_VECTOR (8 DOWNTO 0); 
    SIGNAL sampledA, sampledB, sampledS : STD_LOGIC;
    SIGNAL Aout, Bout, Sout : STD_LOGIC;
    SIGNAL lim : INTEGER RANGE 1 TO 21 := 5;
    SIGNAL salida, salida1, q, q1 : STD_LOGIC;
    signal cjk : STD_LOGIC;
BEGIN
    conteo : PROCESS (clk, sclk, sampledA, sampledB, reset, salida, q, lim)
    BEGIN

        IF clk'event AND clk = '1' THEN
            sampledA <= ButtonAdd;
            sampledB <= ButtonSub;
            -- clock is divided to 1MHz
            -- samples every 1uS to check if the input is the same as the sample
            -- if the signal is stable, the debouncer should output the signal
            IF sclk = lim_deb THEN

                -- Aout
                IF sampledA = buttonAdd THEN
                    Aout <= buttonadd;
                END IF;

                --Bout
                IF sampledB = ButtonSub THEN
                    Bout <= ButtonSub;
                END IF;

                sclk <= 0;
            ELSE
                sclk <= sclk + 1;
            END IF;

            q <= Aout;-- funcionamiento normal del ffd
            q1 <= Bout;
        END IF;

        --IF (clk'event AND clk = '1') THEN-- si no existe un reset y el cambio de clk=1
        --    q <= Aout;-- funcionamiento normal del ffd
        --END IF;
        salida <= q AND(NOT Aout);
        salida1 <= q1 AND (NOT Bout);

        cjk <= salida OR salida1;
        IF RESET = '0' THEN
            IF rising_edge(cjk) THEN
                IF (q = '1') THEN
                    lim <= lim + 1;
                ELSIF (q1 = '1') THEN
                    lim <= lim - 1;
                END IF;
            END IF;

        ELSE
            lim <= 5;
        END IF;
        CASE (lim) IS
            WHEN 1 => LedLim <= "00001";
            WHEN 2 => LedLim <= "00010";
            WHEN 3 => LedLim <= "00011";
            WHEN 4 => LedLim <= "00100";
            WHEN 5 => LedLim <= "00101";
            WHEN 6 => LedLim <= "00110";
            WHEN 7 => LedLim <= "00111";
            WHEN 8 => LedLim <= "01000";
            WHEN 9 => LedLim <= "01001";
            WHEN 10 => LedLim <= "01010";
            WHEN 11 => LedLim <= "01011";
            WHEN 12 => LedLim <= "01100";
            WHEN 13 => LedLim <= "01101";
            WHEN 14 => LedLim <= "01110";

            WHEN 15 => LedLim <= "01111";
            WHEN 16 => LedLim <= "10000";
            WHEN 17 => LedLim <= "10001";
            WHEN 18 => LedLim <= "10010";
            WHEN 19 => LedLim <= "10011";
            WHEN 20 => LedLim <= "10100";
            WHEN OTHERS => LedLim <= "11111";
        END CASE;

    END PROCESS conteo;
END ARCHITECTURE cont;