LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Tarea IS
    PORT (
        --Servos que controlan el movimiento de los ojos, arriba abajo, izquierda derecha, su salida es pwm 
        Srv_eyes_UD : OUT STD_LOGIC;
        Srv_eyes_LR : OUT STD_LOGIC;

        --Motor que controla la rotacion de la cabeza Con salida a pwm 
        --Sensores magneticos que limitan la rotacion de la cabeza
        Motor_headPWM : OUT STD_LOGIC;
        Motor_RelayL : OUT STD_LOGIC;
        Motor_RelayR : OUT STD_LOGIC;
        LS_HL : IN STD_LOGIC;
        LS_HR : IN STD_LOGIC;
        LS_HC : IN STD_LOGIC;
        
        --Servos que controlan el movimiento de los brazos 
        Srv_ArmL : OUT STD_LOGIC;
        Srv_ArmR : OUT STD_LOGIC;

        --Leds 
        LEDS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

        --Reloj de 50MHz
        CLK : IN STD_LOGIC;

        --Sensores que controlan la secuencia a activar
        SQ1 : IN STD_LOGIC;
        SQ2 : IN STD_LOGIC

    );
END ENTITY Tarea;

ARCHITECTURE TpTarea OF Tarea IS
    --signals
    SIGNAL SeqNum : integer range 0 to 5;
BEGIN

    A0 : ENTITY work.SeqCtrl
        PORT MAP(
            SeqNum => SeqNum, --Escritura
            CLK => CLK,
            SQ1 => SQ1,
            SQ2 => SQ2
        );
    A1 : ENTITY work.Mov_eyes
        PORT MAP(
            clk => clk,
            SeqNum => SeqNum, --Solo lectura
            Servo1 => Srv_eyes_LR,
            Servo2 => Srv_eyes_UD 
        );

    A2 : ENTITY work.MovArms
        PORT MAP(
            clk => clk,
            SeqNum => SeqNum, --Solo lectura
            ServoL => Srv_ArmL,
            Servor => Srv_ArmR
        );

    A3 : ENTITY work.MovH
        PORT MAP(
            clk => clk,
            SeqNum => SeqNum, --Solo lectura
            Motor_headPWM => Motor_headPWM,
            Motor_RelayL => Motor_RelayL,
            Motor_RelayR => Motor_RelayR,
            LS_C => LS_HC,
            LS_R => LS_HR, 
            LS_L => LS_HL 
        );

--    
--    A4 : ENTITY work.Leds
--        PORT MAP(
--            clk => clk,
--            Srv_eyes_LR
--        );
--    
--        

END TpTarea;