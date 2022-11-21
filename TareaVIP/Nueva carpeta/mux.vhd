

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Mux_31 IS
    PORT (
        C : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        D : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        U : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        Selectores : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        Salidas : OUT STD_LOGIC_VECTOR (3 DOWNTO 0));
END Mux_31;

ARCHITECTURE Behavioral OF Mux_31 IS

BEGIN
    PROCESS (Selectores, C, D, U)
    BEGIN
        CASE Selectores IS
            WHEN "00" => Salidas <= C;
            WHEN "01" => Salidas <= D;
            WHEN "10" => Salidas <= U;
            WHEN OTHERS => Salidas <= "0000";
        END CASE;
    END PROCESS;

END Behavioral;