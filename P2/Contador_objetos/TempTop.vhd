LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY TempTop IS
    PORT (
        clk : IN STD_LOGIC; --Reloj 50 Mhz amiba 
        ButtonSub : IN STD_LOGIC;
        ButtonAdd : IN STD_LOGIC;
        ButtonPause : IN STD_LOGIC;
        ButtonStop : IN STD_LOGIC;
        ButtonReset : IN STD_LOGIC;
        ButtonStart : IN STD_LOGIC;

        AN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        LED : OUT STD_LOGIC --Pulsos de salida de 0.125ms y 1s

    );
END ENTITY TempTop;

ARCHITECTURE Behavioral OF TempTop IS

BEGIN
    --------------------------------------------------------------------------------
    --Declaracion del ADC
    ADC : ENTITY WORK.ControlLIM PORT MAP(

        clk => clk, --reloj 50 mhz
        ButtonSub => ButtonSub,
        ButtonAdd => ButtonAdd,
        ButtonPause => ButtonPause,
        ButtonStop => ButtonStop,
        ButtonReset => ButtonReset,
        ButtonStart => ButtonStart,
        LimHr => LimHr,
        LimMin => LimMin,
        Limsec => Limsec
        );
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --Declaracion del generador y calculo
    ADC : ENTITY WORK.Clks PORT MAP(

        clk => clk, --reloj 50 mhz
        AN => AN,
        DISPLAY => DISPLAY,
        LED => LED
        );
    --------------------------------------------------------------------------------
END ARCHITECTURE Behavioral;