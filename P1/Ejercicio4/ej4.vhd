LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY musicVHDL IS -- Police Siren
    PORT (
        clk : IN STD_LOGIC; --clock
        speaker : OUT STD_LOGIC --speaker
    );
END musicVHDL;
ARCHITECTURE music OF musicVHDL IS
    --SIGNALS
    SIGNAL spkr : STD_LOGIC;
    SIGNAL tone : STD_LOGIC_VECTOR(22 DOWNTO 0);
    SIGNAL ramp : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL clkdivider : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL counter : STD_LOGIC_VECTOR(22 DOWNTO 0);
BEGIN -- begin architecture ------------------------------------
    -- tono --
    PROCESS (clk)
    BEGIN
        IF clk'event AND clk = '1' THEN

            tone <= tone + '1';

        END IF;
    END PROCESS;
    -- rampa y divisor --
    PROCESS (tone)
    BEGIN
        IF tone(22) = '1' THEN
            ramp <= tone(21 DOWNTO 15);
        ELSE
            ramp <= NOT(tone(21 DOWNTO 15));
        END IF;
        clkdivider <= "01" & ramp & "000000";
    END PROCESS;
    --contador up-down --
    PROCESS (clk)
    BEGIN
        IF clk'event AND clk = '1' THEN
            IF counter = x"00000" & "00" THEN
                counter <= "00000000" & clkdivider;
            ELSE
                counter <= counter - '1';
            END IF;
        END IF;
    END PROCESS;
    --contador up-down --
    PROCESS (clk, spkr)
    BEGIN
        IF clk'event AND clk = '1' THEN
            IF (counter = x"00000" & "00") THEN
                spkr <= NOT spkr;

            END IF;
        END IF;
        speaker <= spkr;
    END PROCESS;
END music;