
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY Final IS
    PORT (
        Binario : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        Reloj50mhz : IN STD_LOGIC;
        Catodos : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        Anodos : OUT STD_LOGIC_VECTOR (3 DOWNTO 0));
END Final;

ARCHITECTURE Behavioral OF Final IS
    SIGNAL XCen, XDec, XUni, XBCD : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL X1khz : STD_LOGIC;
    SIGNAL XQ : STD_LOGIC_VECTOR (1 DOWNTO 0);

    COMPONENT Conv_Bin_BCD
        PORT (
            Bin : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            Cen : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            Dec : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            Uni : OUT STD_LOGIC_VECTOR (3 DOWNTO 0));
    END COMPONENT;

    COMPONENT Mux_31
        PORT (
            C : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            D : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            U : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            Selectores : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
            Salidas : OUT STD_LOGIC_VECTOR (3 DOWNTO 0));
    END COMPONENT;

    COMPONENT Dec7seg
        PORT (
            BCD : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            led : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
    END COMPONENT;

    COMPONENT RELOJ1KHZ
        PORT (
            CLK50MHZ : IN STD_LOGIC;
            CLK1KHZ : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT Cont_0al2
        PORT (
            Clk : IN STD_LOGIC;
            Q : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0));
    END COMPONENT;

    COMPONENT Anodos_displays
        PORT (
            Input : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            Anodos : OUT STD_LOGIC_VECTOR (3 DOWNTO 0));
    END COMPONENT;

BEGIN

    paso1 : Conv_Bin_BCD PORT MAP(Binario, XCen, XDec, XUni);
    paso2 : Mux_31 PORT MAP(XCen, XDec, XUni, XQ, XBCD);
    paso3 : Dec7seg PORT MAP(XBCD, Catodos);
    paso4 : RELOJ1KHZ PORT MAP(Reloj50mhz, X1khz);
    paso5 : Cont_0al2 PORT MAP(X1khz, XQ);
    paso6 : Anodos_displays PORT MAP(XQ, Anodos);

END Behavioral;