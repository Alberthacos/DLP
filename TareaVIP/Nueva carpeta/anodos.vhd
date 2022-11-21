LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Anodos_displays IS
    PORT (
        Input : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        Anodos : OUT STD_LOGIC_VECTOR (3 DOWNTO 0));
END Anodos_displays;

ARCHITECTURE Behavioral OF Anodos_displays IS

BEGIN
    PROCESS (Input)
    BEGIN
        CASE Input IS
            WHEN "00" => Anodos <= "0111";
            WHEN "01" => Anodos <= "1011";
            WHEN "10" => Anodos <= "1101";
            WHEN OTHERS => Anodos <= "1111";
        END CASE;
        Anodos(0) <= '1';
    END PROCESS;

END Behavioral;