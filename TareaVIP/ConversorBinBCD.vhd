LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY binary_bcd IS
    GENERIC (N : POSITIVE := 16);
    PORT (
        clk,: IN STD_LOGIC;
        --DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display--"abcdefgP"
        --AN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111111"; -- ánodos del display
        Valor_temporalV, Valor_temporalI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
       
        DecenasVoltaje, UnidadesVoltaje, DecimasVoltaje : OUT INTEGER RANGE 0 TO 20;
        UnidadesI, DecimasI, centesimasI, milesimasI : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        --salida a leds indicadores
    );
END binary_bcd;

ARCHITECTURE behaviour OF binary_bcd IS

    --------------------------------------------------------------------------------
    SIGNAL contadors : INTEGER RANGE 1 TO 1_000_000 := 1; -- pulso1 de 0.25ms (pro. divisor ánodos)
    -- Declaración de señales de la asignación de U-D-C-UM
    SIGNAL P : STD_LOGIC_VECTOR (19 DOWNTO 0); -- asigna UNI, DEC,CEN, MIL
    SIGNAL UNI, DEC, CEN, MIL, decMIL : INTEGER RANGE 0 TO 10; -- digitos unidades, decenas,millar, decenas millar
    SIGNAL UniV, DecV, DeciV : INTEGER RANGE 0 TO 20;
    SIGNAL Vo, vin : INTEGER RANGE 0 TO 500;
    SIGNAL I : INTEGER RANGE 0 TO 5_000_000;
    -- centenas y unidad de millar
    SIGNAL NumeroBitsDecimal : INTEGER RANGE 0 TO 50_000_000;
    -- Declaración de señales de la multiplexación y asignación de U-D-C-UM al display
    SIGNAL SEL : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000"; -- selector de barrido
    SIGNAL D : INTEGER RANGE 0 TO 9;
    SIGNAL SAL_250us : STD_LOGIC;
    --------------------------------------------------------------------------------
BEGIN
    ---------------------DIVISOR ÁNODOS-------------------
    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF (contadors = 1_000_000) THEN --cuenta 0.125ms (50MHz=6250)
                -- if (contadors = 12500) then --cuenta 0.125ms (100MHz=12500)
                SAL_250us <= NOT(SAL_250us); --genera un barrido de 0.25ms
                contadors <= 1;
            ELSE
                contadors <= contadors + 1;
            END IF;
        END IF;
    END PROCESS; -- fin del proceso Divisor Ánodos

--------------------------------------------------------------------------------
    PROCESS (SAL_250us)
    BEGIN
        IF rising_edge(SAL_250us) THEN

            NumeroBitsDecimal <= TO_INTEGER(UNSIGNED(Valor_temporalV(14 DOWNTO 0)));
  
            --IF ch = '0' THEN --hace operaciones para voltaje 
                Vo <= ((NumeroBitsDecimal * 5060)/538400);
                --Vin <= (Vo*(7500+30_000))/7500;
                DecV <= Vo/100; --Decimas Voltaje  decmil
                UniV <= (vo - DecV * 100)/10; --Unidades voltaje mil
                DeciV <= (Vo - DecV * 100 - UniV * 10); --decimas voltaje  cen

                --Dec <= 0; --decenas
                --Uni <= 0; --unidades
                DecenasVoltaje <= DecV;
                UnidadesVoltaje <=UniV;
                DecimasVoltaje <= DeciV;

           -- ELSE --operaciones corriente 
               -- NumeroBitsDecimal <= TO_INTEGER(UNSIGNED(binary_inI(14 DOWNTO 0)));--(decMIL * 10000) + (MIL * 1000) + (CEN * 100) + (DEC * 10) + UNI;
               -- Vo <= ((NumeroBitsDecimal * 5)/32768)*10_000; -- Vo <= ((NumeroBitsDecimal * 916_000)/1346200000);
               
               -- --Vin <= (Vo*(7500+30_000))/7500;
               
               -- UniI <= ((Vo-25000)/1);
               -- DeciI <= Vo/1000; --millar [A] enteros
               -- CentI <= (vo-DecMil*1000)/100; --centecimas
               -- MileI <= (Vo-DecMil*1000-MIL*100)/10;  --decenas
               -- 
               -- Dec <= (Vo-DecMil*1000-MIL*100-Cen*10); --unidades mA
               -- Uni <= 0;    --unidades

                UnidadesI <= "00000000"; 
                DecimasI <= "00000000";
                centesimasI <= "00000000"; 
                milesimasI <= "00000000";

            --END IF;         
            
        END IF;
       
    END PROCESS;

END behaviour;