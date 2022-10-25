--Código para controlar 4 posiciones para un servomotor Futaba

--implementado en la nexys2.

--Se considera una frec. de 100Hz (periodo de 10ms) del PWM.

LIBRARY IEEE;

USE IEEE.STD_LOGIC_1164.ALL;

USE IEEE.STD_LOGIC_ARITH.ALL;

USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY PWM IS

   GENERIC (Max : NATURAL := 500000);

   PORT (
      clk : IN STD_LOGIC;--reloj de 50MHz
      enable : IN STD_LOGIC;
      -- selector : IN STD_LOGIC_VECTOR (1 DOWNTO 0);--selecciona las 4 posiciones
      entrada : IN STD_LOGIC;
      PWM : OUT STD_LOGIC);--terminal donde sale la señal de PWM

END PWM;

ARCHITECTURE PWM OF PWM IS

   SIGNAL PWM_Count : INTEGER RANGE 1 TO Max;--500000;
   SIGNAL selector : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
   SIGNAL conta_1250us : INTEGER RANGE 1 TO 20000000 := 1; -- pulso1 de 1250us@400Hz (0.25ms)
   SIGNAL SAL_400Hz : STD_LOGIC := '0';
BEGIN

   generacion_PWM :

   PROCESS (clk, selector, PWM_Count)
      ----Para engranes metalicos
      CONSTANT pos1 : INTEGER := 25000; --representa a 1.00ms = 0 // 0.5ms 0 deg 24000
      CONSTANT pos2 : INTEGER := 44750;
      CONSTANT pos3 : INTEGER := 65000; --representa a 1.25ms = 45 // 1.5 90 deg  65000
      CONSTANT pos4 : INTEGER := 85250;
      CONSTANT pos5 : INTEGER := 110000; --representa a 1.50ms = 90 // 2.5 180 deg  110000

      --Para engranes plasticos MOT100
      --CONSTANT pos1 : INTEGER := 24000; --representa a 1.00ms = 0 // 0.5ms 0 deg
      --CONSTANT pos2 : INTEGER := 68500; --representa a 1.25ms = 45 // 1.5 90 deg
      --CONSTANT pos3 : INTEGER := 120000; --representa a 1.50ms = 90 // 2.5 180 deg
   BEGIN

      IF rising_edge(clk) THEN
         PWM_Count <= PWM_Count + 1;

      END IF;
      IF (ENABLE = '1') THEN
         IF (SAL_400Hz'EVENT AND SAL_400Hz = '1') THEN
            IF selector <= "100" THEN
               selector <= selector + '1';
            ELSE
               selector <= "000";
            END IF;
         END IF;
      END IF;

      CASE (selector) IS

         WHEN "000" => --con el selector en 00 se posiciona en servo en 0°

            IF PWM_Count <= pos1 THEN
               PWM <= '1';

            ELSE
               PWM <= '0';

            END IF;

         WHEN "001" => -- con el selector en 01 se posiciona en servo en 45°

            IF PWM_Count <= pos2 THEN
               PWM <= '1';

            ELSE
               PWM <= '0';

            END IF;

         WHEN "010" => -- con el selector en 11 se posiciona en servo en 90°

            IF PWM_Count <= pos3 THEN
               PWM <= '1';

            ELSE
               PWM <= '0';

            END IF;
         WHEN "011" => -- con el selector en 11 se posiciona en servo en 135°

            IF PWM_Count <= pos4 THEN
               PWM <= '1';

            ELSE
               PWM <= '0';

            END IF;
         WHEN "100" => -- con el selector en 11 se posiciona en servo en 180°

            IF PWM_Count <= pos5 THEN
               PWM <= '1';

            ELSE
               PWM <= '0';

            END IF;
         WHEN OTHERS => NULL;

      END CASE;

      IF rising_edge(CLK) THEN
         IF (conta_1250us = 20000000) THEN --cuenta 1250us (50MHz=62500)
            -- if (conta_1250us = 125000) then --cuenta 1250us (100MHz=125000)
            SAL_400Hz <= NOT(SAL_400Hz); --genera un barrido de 2.5ms
            conta_1250us <= 1;
         ELSE
            conta_1250us <= conta_1250us + 1;
         END IF;
      END IF;
   END PROCESS generacion_PWM;

END PWM;