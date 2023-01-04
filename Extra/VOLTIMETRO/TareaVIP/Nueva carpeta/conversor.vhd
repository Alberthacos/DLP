

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY Conv_Bin_BCD IS
    PORT (
        Bin : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        Cen : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        Dec : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        Uni : OUT STD_LOGIC_VECTOR (3 DOWNTO 0));
END Conv_Bin_BCD;

ARCHITECTURE Behavioral OF Conv_Bin_BCD IS

BEGIN

    PROCESS (Bin)
        VARIABLE Z : STD_LOGIC_VECTOR (19 DOWNTO 0);
    BEGIN

        FOR i IN 0 TO 19 LOOP
            Z(i) := '0';
        END LOOP;

        Z(10 DOWNTO 3) := Bin;
        FOR i IN 0 TO 4 LOOP

            IF Z(11 DOWNTO 8) > 4 THEN
                Z(11 DOWNTO 8) := Z(11 DOWNTO 8) + 3;
            END IF;

            IF Z(15 DOWNTO 12) > 4 THEN
                Z(15 DOWNTO 12) := Z(15 DOWNTO 12) + 3;
            END IF;

            Z(17 DOWNTO 1) := Z(16 DOWNTO 0);
        END LOOP;

        Cen <= Z(19 DOWNTO 16);
        Dec <= Z(15 DOWNTO 12);
        Uni <= Z(11 DOWNTO 8);
    END PROCESS;
END Behavioral;