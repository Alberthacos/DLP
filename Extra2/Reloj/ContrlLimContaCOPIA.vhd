LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ControlLimConteo IS
    PORT (
        clk : IN STD_LOGIC; --Reloj 50 Mhz amiba 

        StartOUT : IN STD_LOGIC;
        PauseOUT : IN STD_LOGIC;
        SelLiMOUT : IN STD_LOGIC;
        SubOUT : IN STD_LOGIC;
        AddOUT : IN STD_LOGIC;
        StopOUT : IN STD_LOGIC;
        ResetOUT : IN STD_LOGIC;

        ContaSecOUT : OUT INTEGER RANGE 0 TO 59;
        ContaMinOUT : OUT INTEGER RANGE 0 TO 59;
        ContaHrOUT : OUT INTEGER RANGE 0 TO 59;

        LED : OUT STD_LOGIC --Pulsos de salida de 0.125ms y 1s
    );
END ENTITY ControlLimConteo;


ARCHITECTURE behaviour OF ControlLimConteo IS
    --signals 
    --SIGNAL LimSec : INTEGER RANGE 0 TO 60 := 0; --Limite
    --SIGNAL LimMin : INTEGER RANGE 0 TO 60 := 0; --Limite
    --SIGNAL LimHr : INTEGER RANGE 0 TO 60 := 0; --Limite

    SIGNAL contadors1 : INTEGER RANGE 1 TO 50_000_001 := 1; -- pulso de 1 segundo 
    SIGNAL SAL_250us1 : STD_LOGIC;

    --SIGNAL UniSec, DecSec : INTEGER RANGE 0 TO 9 := 0; --Unidades y decenas segundos 
    --SIGNAL UniMin, DecMin : INTEGER RANGE 0 TO 9 := 0; --Unidades y decenas minutos 
    --SIGNAL UniHr, DecHr : INTEGER RANGE 0 TO 9 := 0; --Unidades y decenas horas 

    SIGNAL ContaHr : INTEGER RANGE 0 TO 59 := 0;
    SIGNAL ContaMin : INTEGER RANGE 0 TO 59 := 0;
    SIGNAL ContaSec : INTEGER RANGE 0 TO 59 := 0;

    SIGNAL LimSecTot : INTEGER RANGE 0 TO 1_000_000 := 0;--LimHr * 3600 + LimMin * 60 + Limsec; --
    SIGNAL LimMinTot : INTEGER RANGE 0 TO 1_000_000 := 0;--LimHr * 60 + LimMin; --
    SIGNAL LimHrTot : INTEGER RANGE 0 TO 1_000_000 := 0;--LimHr; 

    SIGNAL clk_or : STD_LOGIC;
    SIGNAL Enc : STD_LOGIC := '0';

    SIGNAL ContadorSelLim : INTEGER RANGE 0 TO 4 := 0;
    --------------------------------------------------------------------------------
BEGIN
    LED <= Enc;
    ContaSecOUT <= ContaSec;
    ContaMinOUT <= ContaMin;
    ContaHrOUT <= ContaHr;
    
    PROCESS (SAL_250us1) BEGIN
        --Se presiona el boton de inicio (flanco ascendente)
        --Asigna los valores del limite al contador para que inicie el conteo 

        IF (StartOUT = '1' OR ENC = '1') AND PauseOUT = '0' THEN
            ENC <= '1';
        ELSE
            ENC <= '0';
        END IF;

        IF ENC = '1' THEN
            IF rising_edge(SAL_250us1) THEN --Flanco ascendente 
                --------------------------------------------------------------------------------
                --INICIO SEGUNDOS
                IF ContaSec = 0 THEN
                    --------------------------------------------------------------------------------
                    --INICIO Minutos
                    IF ContaMin = 0 THEN
                        --------------------------------------------------------------------------------
                        --INICIO Horas
                        IF ContaHr = 0 THEN
                            IF LimHrTot = 0 THEN
                                ContaHr <= 0;
                            ELSIF LimHrTot <= 59 AND LimHrTot > 0 THEN
                                ContaHr <= LimHrTot;
                            ELSE
                                ContaHr <= 59;
                            END IF;
                        ELSIF LimHrTot > 0 THEN
                            ContaHr <= ContaHr - 1;
                            -- LimHrTot <= LimHrTot - 1;
                        END IF;
                        --FIN HORAS
                        --------------------------------------------------------------------------------
                        IF LimMinTot = 0 THEN
                            ContaMin <= 0;
                        ELSIF LimMinTot <= 59 AND LimMinTot > 0 THEN
                            ContaMin <= LimMinTot;
                        ELSE
                            ContaMin <= 59;
                        END IF;

                    ELSIF LimMinTot > 0 THEN
                        ContaMin <= ContaMin - 1;
                        --LimMinTot <= LimMinTot - 1;
                    END IF;
                    --FIN MINUTOS
                    --------------------------------------------------------------------------------

                    IF LimSecTot = 0 THEN
                        ContaSec <= 0;
                    ELSIF LimSecTot <= 59 AND LimSecTot > 0 THEN
                        ContaSec <= LimSecTot;
                    ELSE
                        ContaSec <= 59;
                    END IF;

                ELSIF LimSecTot > 0 THEN
                    ContaSec <= ContaSec - 1; --Aumenta el contador de segundos
                    --LimSecTot <= LimSecTot - 1;
                END IF;
                --FIN SEGUNDOS
                --------------------------------------------------------------------------------
            END IF;
        ELSE
            --------------------------------------------------------------------------------
            clk_or <= AddOUT OR SubOUT;
            IF rising_edge(SelLimOUT) THEN --Se presiona boton que cambia entre secciones
                IF ContadorSelLim > 3 THEN
                    ContadorSelLim <= 1;
                ELSE
                    ContadorSelLim <= ContadorSelLim + 1;
                END IF;
            ELSE
                ContaHr <= ContaHr;
                ContaMin <= ContaMin;
                ContaSec <= ContaSec;
            END IF;
            CASE ContadorSelLim IS
                WHEN 1 =>
                    IF rising_edge(clk_or) THEN
                        IF (AddOUT = '1') THEN
                            ContaHr <= ContaHr + 1;
                        ELSIF (SubOUT = '1') THEN
                            ContaHr <= ContaHr - 1;
                        END IF;

                    END IF;
                WHEN 2 =>
                    IF rising_edge(clk_or) THEN
                        IF (AddOUT = '1') THEN
                            ContaMin <= ContaMin + 1;
                        ELSIF (SubOUT = '1') THEN
                            ContaMin <= ContaMin - 1;
                        END IF;

                    END IF;

                WHEN 3 =>
                    IF rising_edge(clk_or) THEN
                        IF (AddOUT = '1') THEN
                            ContaSec <= ContaSec + 1;
                        ELSIF (SubOUT = '1') THEN
                            ContaSec <= ContaSec - 1;
                        END IF;
                    END IF;
                WHEN OTHERS =>    ContaHr <= ContaHr;
                ContaMin <= ContaMin;
                ContaSec <= ContaSec;
            END CASE;
        END IF;
        --------------------------------------------------------------------------------
        LimHrTot <= ContaHr;
        LimMinTot <= ContaHr * 60 + ContaMin;
        LimSecTot <= ContaHr * 3600 + ContaMin * 60 + ContaSec;

        --Sacar valores de contasec
        --DecSec <= ContaSec/10;
        --UniSec <= ContaSec - DecSec * 10;
        --DecMin <= ContaMin/10;
        --UniMin <= ContaMin - DecMin * 10;
        --DecHr <= ContaHr/10;
        --UniHr <= ContaHr - DecHr * 10;

    END PROCESS;


    ---------------------Pulso de un segundo-------------
    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF (contadors1 = 25_000_000) THEN --20us*25_000_000=0.5s
                SAL_250us1 <= NOT(SAL_250us1); --genera un pulso de un segundo 
                contadors1 <= 1;
            ELSE
                contadors1 <= contadors1 + 1;
            END IF;
        END IF;
    END PROCESS;
    --------------------------------------------------------------------------------
END behaviour;