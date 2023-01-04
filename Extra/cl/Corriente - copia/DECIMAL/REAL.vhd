LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY binary_bcd IS
    GENERIC (N : POSITIVE := 16);
    PORT (
        clk, reset_n : IN STD_LOGIC;
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display--"abcdefgP"
        AN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111111"; -- ánodos del display
        binary_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        bcd0, bcd1, bcd2, bcd3, bcd4 : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0) --salida a leds indicadores
    );
END binary_bcd;

ARCHITECTURE behaviour OF binary_bcd IS
    TYPE states IS (start, shift, done);
    SIGNAL state, state_next : states;

    SIGNAL binary, binary_next : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL bcds, bcds_reg, bcds_next : STD_LOGIC_VECTOR(19 DOWNTO 0);
    --output register keep output constant during conversion
    SIGNAL bcds_out_reg, bcds_out_reg_next : STD_LOGIC_VECTOR(19 DOWNTO 0);
    -- need to keep track of shifts
    SIGNAL shift_counter, shift_counter_next : NATURAL RANGE 0 TO N;
    --------------------------------------------------------------------------------
    SIGNAL contadors : INTEGER RANGE 1 TO 6250 := 1; -- pulso1 de 0.25ms (pro. divisor ánodos)
    

    -- Declaración de señales de la asignación de U-D-C-UM
    SIGNAL P : STD_LOGIC_VECTOR (19 DOWNTO 0); -- asigna UNI, DEC,CEN, MIL
    SIGNAL UniV, decV, DecimasV : REAL ;--RANGE 0 TO 20;
    SIGNAL UNI, DEC, CEN, MIL, decMIL : REAL; --RANGE 0 TO 70_000_000; -- digitos unidades, decenas,millar, decenas millar
    SIGNAL Vo, vin : REAl;--RANGE 0 TO 100_000_000;
    -- centenas y unidad de millar
    SIGNAL NumeroBitsDecimal : INTEGER RANGE 0 TO 70_000_000;
    -- Declaración de señales de la multiplexación y asignación de U-D-C-UM al display
    SIGNAL SEL : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000"; -- selector de barrido
    SIGNAL D : REAL;--INTEGER RANGE 0 TO 9;
    SIGNAL SAL_250us : STD_LOGIC;
    --------------------------------------------------------------------------------
BEGIN

--
    ---------------------DIVISOR ÁNODOS-------------------
    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF (contadors = 6250) THEN --cuenta 0.125ms (50MHz=6250)
                -- if (contadors = 12500) then --cuenta 0.125ms (100MHz=12500)
                SAL_250us <= NOT(SAL_250us); --genera un barrido de 0.25ms
                contadors <= 1;
            ELSE
                contadors <= contadors + 1;
            END IF;
        END IF;
    END PROCESS; -- fin del proceso Divisor Ánodos
    --------------------------------------------------------------------------------



            
     process(SAL_250us)
       begin
        IF rising_edge(SAL_250us) THEN 
        NumeroBitsDecimal <= CONV_INTEGER((binary_in(14 DOWNTO 0)));--(decMIL * 10000) + (MIL * 1000) + (CEN * 100) + (DEC * 10) + UNI;
        Vin <=Real(NumeroBitsDecimal);--(NumeroBitsDecimal*18.75*6.33)/1255;
--        --Vin <=(NumeroBitsDecimal*1723)/18270;
--        
--        DecMIL <=Vin/10_000_000;--(NumeroBitsDecimal*1875*633)/1255000000; --decimas de millar
--        MIL <=0;-- (Vin-DecMil*1000)/100; --millar0
--        Cen <=0;-- (Vin-DecMil*1000-MIL*100)/10;  ---centenas
--        Dec <=0; --(Vin-DecMil*1000-MIL*100-Cen*10); --decenas
--        Uni <= 0;    --unidades
--		  
----		  --FUNCIONA REGULAR
----        Vo <= ((NumeroBitsDecimal * 5063)/53840);
----        DecMIL <=Vo/1000; --decimas de millar
----        MIL <= (vo-DecMil*1000)/100; --millar
----        Cen <= (Vo-DecMil*1000-MIL*100)/10;  ---centenas
----        Dec <= (Vo-DecMil*1000-MIL*100-Cen*10); --decenas
----        Uni <= 0;    --unidades
        END IF;
       end process;
END behaviour;