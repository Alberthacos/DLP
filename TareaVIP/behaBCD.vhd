

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY Conv_Bin_BCD IS
    PORT (

        Binario : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        CLK50Mhz : IN STD_LOGIC;
        Catodos : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        Anodos : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
        );
END Conv_Bin_BCD;

ARCHITECTURE Behavioral OF Conv_Bin_BCD IS
--contador selector q
SIGNAL Q : STD_LOGIC_VECTOR (1 DOWNTO 0);
 --reloj
SIGNAL pulso : STD_LOGIC := '0';
SIGNAL Cen, Dec, Uni, BCD : STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL contador : INTEGER RANGE 0 TO 24999 := 0;
BEGIN

    PROCESS (Binario)
        VARIABLE Z : STD_LOGIC_VECTOR (19 DOWNTO 0);
    BEGIN

        FOR i IN 0 TO 19 LOOP
            Z(i) := '0';
        END LOOP;

        Z(10 DOWNTO 3) := Binario;
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

 
    PROCESS (Q, Cen, Dec, Uni)
    BEGIN
        CASE Q IS
            WHEN "00" => BCD <= Cen;
            WHEN "01" => BCD <= Dec;
            WHEN "10" => BCD <= Uni;
            WHEN OTHERS => BCD <= "0000";
        END CASE;
    END PROCESS;



    PROCESS (BCD)
    BEGIN
        CASE BCD IS
            WHEN "0000" => Catodos <= "0000001"; --0
            WHEN "0001" => Catodos <= "1001111"; --1
            WHEN "0010" => Catodos <= "0010010"; --2
            WHEN "0011" => Catodos <= "0000110"; --3
            WHEN "0100" => Catodos <= "1001100"; --4 
            WHEN "0101" => Catodos <= "0100100"; --5
            WHEN "0110" => Catodos <= "0100000"; --6
            WHEN "0111" => Catodos <= "0001111"; --7
            WHEN "1000" => Catodos <= "0000000"; --8
            WHEN "1001" => Catodos <= "0001100"; --9
            WHEN OTHERS => Catodos <= "0001100"; --9
        END CASE;
    END PROCESS;


    PROCESS (Q)
    BEGIN
        CASE Q IS
            WHEN "00" => Anodos <= "0111";
            WHEN "01" => Anodos <= "1011";
            WHEN "10" => Anodos <= "1101";
            WHEN OTHERS => Anodos <= "1111";
        END CASE;
        Anodos(0) <= '1';
    END PROCESS;


--contador para reloj 1khz
PROCESS (pulso)
BEGIN
    IF pulso = '1' AND pulso'event THEN
        IF Q = "11" THEN
            Q <= "00";
        ELSE
            Q <= Q + 1;
        END IF;
    END IF;
END PROCESS;
--reloj 1khz
PROCESS (CLK50Mhz)
BEGIN
    IF (CLK50Mhz'event AND CLK50Mhz = '1') THEN
        IF (contador = 24999) THEN
            pulso <= NOT(pulso);
            contador <= 0;
        ELSE
            contador <= contador + 1;
        END IF;
    END IF;
END PROCESS;
--CLK1KHZ <= pulso;

END Behavioral;