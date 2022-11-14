----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY MovH IS
    GENERIC (Max : NATURAL := 500000);
    PORT (
        Motor_headPWM : OUT STD_LOGIC; --Alimentacion del motor DC pwm para controlar la velocidad
        Motor_RelayL : INOUT STD_LOGIC := '1'; --Activa el relay que permite el avance en sentido hacia horario
        Motor_RelayR : INOUT STD_LOGIC := '1'; --Activa el relay que permite el avance en sentido hacia antihorario

        LS_L : IN STD_LOGIC; --SENSOR DE LIMITE IZQUIERDO 
        LS_R : IN STD_LOGIC; --SENSOR DE LIMITE DERECHO 
        LS_C : IN STD_LOGIC; --SENSOR DE LIMITE central

        CLK : IN STD_LOGIC;

        LEDS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";

        selector : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END MovH;

ARCHITECTURE Behavioral OF MovH IS
    SIGNAL sclk : INTEGER RANGE 0 TO 20_000_000 := 0;

    SIGNAL sampledLS_L : STD_LOGIC;
    SIGNAL LS_LDEB : STD_LOGIC;

    SIGNAL sampledLS_R : STD_LOGIC;
    SIGNAL LS_RDEB : STD_LOGIC;

    SIGNAL sampledLS_C : STD_LOGIC;
    SIGNAL LS_CDEB : STD_LOGIC;

    SIGNAL MR : STD_LOGIC := '0';
    SIGNAL ML : STD_LOGIC := '0';
    SIGNAL MC : STD_LOGIC := '0';

    SIGNAL NumL : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL NumR : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL Numc : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";


    SIGNAL PWM_Count : INTEGER RANGE 1 TO Max;--500000;
    SIGNAL Conta250 : INTEGER RANGE 1 TO 250_000_000 := 1;


    SIGNAL ENC : INTEGER RANGE 0 TO 10 := 0;
    SIGNAL seqnum : INTEGER RANGE 0 TO 50 := 0;

    CONSTANT Speed1 : INTEGER := 80000; --representa a 1.50ms = 90°
    CONSTANT Speed2 : INTEGER := 100000; --representa a 2.00ms = 180°
BEGIN
    PROCESS (PWM_Count, SeqNum, SELECTOR, ls_l, ls_r)
    BEGIN

        IF SELECTOR = "01" THEN
            seqnum <= 1;
        ELSIF Selector = "10" THEN
            seqnum <= 2;
        ELSE
            seqnum <= 3;
        END IF;

        IF SeqNum = 1 THEN --secuencia uno // Lado a lado x veces

            IF PWM_Count <= Speed2 THEN --velocidad de secuencia uno 
                Motor_headPWM <= '1';
            ELSE
                Motor_headPWM <= '0';
            END IF;

            --PARO ES UN CONTADOR 
            -- para iniciar el proceso, se debe seleccionar la secuencia uno y debe estar la cabeza en el centro
            -- Y el sensor del lado izquierdo no debe estar detectando nada, ni activado el relevador de la salida en sentido
            -- derecho y estar por debajo del limite de 10 
            -- para continuar con el "enclave" se debe activar la variable MR, o tocar el LS del lado izquierdo 
            IF (LS_L = '0' OR MR = '1' OR (seqnum = 1 AND LS_C = '0')) AND LS_R = '1' AND ML = '0' AND NumL <= 5 THEN
                MR <= '1';
                Motor_RelayR <= '0';
            ELSE
                Motor_RelayR <= '1';
                MR <= '0';
            END IF;

            IF (LS_R = '0' OR ML = '1') AND LS_L = '1' AND MR <= '0' THEN
                ML <= '1';
                Motor_RelayL <= '0';
            ELSE
                Motor_RelayL <= '1';
                ML <= '0';
            END IF;

        ELSIF SeqNum = 2 THEN --2 veces a cada lado

            IF NumL = 2 THEN --checar limites, modificar eeste o en el primer if 
                --sentido izquierdo
                --para activar debe estar la cabeza en el centro y haber elegido la secuencia 2 
                --Y el sensor LS del lado izquierdo no debe estar detectando nada, ni debe estar 
                --Y activado el relevador de la salida derecha(MC) y debe estar por debajo del limite
                --de veces que se ha pasado por el centro (izquierda a centro)

                --2 veces al lado izquierdo
                IF ((LS_C = '0' AND seqnum = 2) OR ML = '1' OR LS_C = '0') AND LS_L = '1' AND MC = '0' AND NumL < 2 THEN
                    ML <= '1'; --Se activa
                    Motor_RelayL <= '0';
                ELSE
                    ML <= '0'; --Se activa
                    Motor_RelayL <= '1';
                END IF;
                --sentido derecho (hacia el centro)
                IF (LS_L = '0' OR MC = '1') AND LS_C = '1' AND ML = '0' THEN
                    MC <= '1';`
                    Motor_RelayR <= '0';
                ELSE
                    MC <= '0';
                    Motor_RelayR <= '0';
                END IF;

                --TEST
                IF (NumL = 2) THEN
                    seqnum <= 3;
                END IF;

            ELSE
                --2 Veces al lado derecho 
                --sentido derecha
                --s
                IF ((LS_C = '0' AND seqnum = 2) OR MR = '1' OR LS_C = '0') AND LS_R = '1' AND MC = '0' AND NumR < 2 THEN
                    MR <= '1'; --Se activa
                    Motor_RelayR <= '0';
                ELSE
                    MR <= '0'; --Se desactiva
                    Motor_RelayR <= '1';
                END IF;
                --sentido izquierdo
                IF (LS_R = '0' OR MC = '1') AND LS_C = '1' AND ML = '0' THEN
                    MC <= '1';
                    Motor_RelayL <= '0';
                ELSE
                    MC <= '0';
                    Motor_RelayL <= '0';
                END IF;

                --TEST
                IF (NumL = 2 and NumR = 2) THEN
                    seqnum <= 3;
                END IF;

            END IF;
        ELSE
            Motor_RelayL <= '1';
            Motor_RelayR <= '1';
            --aqui se pueden reiniciar los limites 

        END IF;

    END PROCESS;

    conteo : PROCESS (clk, enc)
    BEGIN

        IF rising_edge(clk) AND (ENC = 1 OR ENC = 2) THEN
            PWM_Count <= PWM_Count + 1;
        END IF;
    END PROCESS conteo;
    PROCESS (clk)
    BEGIN

        IF clk'event AND clk = '1' THEN
            sampledLS_L <= LS_L;
            sampledLS_R <= LS_R;
            sampledLS_C <= LS_C;

            -- clock is divided to 1MHz
            -- samples every 1uS to check if the input is the same as the sample
            -- if the signal is stable, the debouncer should output the signal
            IF sclk = 8_000_000 THEN
                -- LS_L
                IF sampledLS_L = LS_L THEN
                    LS_LDEB <= LS_L;
                END IF;

                --LS_R
                IF sampledLS_R = LS_R THEN
                    LS_RDEB <= LS_R;
                END IF;

                --LS_C
                IF sampledLS_C = LS_C THEN
                    LS_CDEB <= LS_C;
                END IF;
                sclk <= 0;
            ELSE
                sclk <= sclk + 1;
            END IF;
        END IF;
        
--Checar contadores en binario o decimal
        IF seqnum = 3 THEN
            NumL <= "0000";
            NumR <= "0000";
            NumC <= "0000";
        ELSE
            IF rising_edge(LS_LDEB) THEN
                NumL <= NumL + '1';
            ELSE
                NumL <= "0000";
            END IF;

            IF rising_edge(LS_RDEB) THEN
                NumR <= NumR + '1';
            ELSE
                NumR <= "0000";
            END IF;

            IF rising_edge(LS_CDEB) THEN
                NumC <= NumC + '1';
            ELSE
                NumC <= "0000";
            END IF;
        END IF;

    END PROCESS;

    LEDS <= NumL;

END Behavioral;


