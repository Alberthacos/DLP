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
        ButtonSelLim : IN STD_LOGIC;

        AN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        Sonido : OUT STD_LOGIC;

        LED : OUT STD_LOGIC --Pulsos de salida de 0.125ms y 1s

    );
END ENTITY TempTop;

ARCHITECTURE Behavioral OF TempTop IS

    SIGNAL PauseOUT, StartOUT, StopOUT,ResetOUT,SelLimOUT,AddOUT,SubOUT : STD_LOGIC;

    SIGNAL ContaSecOUT, ContaMinOUT, ContaHrOUT : INTEGER RANGE 0 TO 59;

BEGIN
    --------------------------------------------------------------------------------
    --Declaracion del ADC
    U1 : ENTITY WORK.ControlLimConteo PORT MAP(

        clk => clk, --reloj 50 mhz
        LED => LED,
        --Botones (Entrada sin ruido)
        PauseOUT => PauseOUT,
        StartOUT => StartOUT,
        StopOUT => StopOUT,
        ResetOUT => ResetOUT,
        AddOUT => AddOUT,
        SubOUT => SubOUT,
        SelLimOUT => SelLimOUT,

        Sonido => Sonido,

        ContaSecOUT => ContaSecOUT, 
        ContaMinOUT => ContaMinOUT, 
        ContaHrOUT => ContaHrOUT 

        );
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --Declaracion del controlador para 7 segmentos
    U2 : ENTITY WORK.Sevenseg PORT MAP(

        clk => clk, --reloj 50 mhz
        AN => AN,
        DISPLAY => DISPLAY,
        ContaSecOUT => ContaSecOUT, 
        ContaMinOUT => ContaMinOUT, 
        ContaHrOUT => ContaHrOUT 
        );
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --Declaracion del controlador para 7 segmentos
    U3 : ENTITY WORK.Deb PORT MAP(

        clk => clk, --reloj 50 mhz
        --Botones entrada
        ButtonSub => ButtonSub,
        ButtonAdd => ButtonAdd,
        ButtonPause => ButtonPause,
        ButtonStop => ButtonStop,
        ButtonReset => ButtonReset,
        ButtonStart => ButtonStart,
        ButtonSelLim => ButtonSelLim,
        --Botones de salida 
        PauseOUT => PauseOUT,
        StartOUT => StartOUT,
        StopOUT => StopOUT,
        ResetOUT => ResetOUT,
        AddOUT => AddOUT,
        SubOUT => SubOUT,
        SelLimOUT => SelLimOUT
        );
    --------------------------------------------------------------------------------
END ARCHITECTURE Behavioral;