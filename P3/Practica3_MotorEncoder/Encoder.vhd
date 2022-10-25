---------------------------------------------------------------------------------------------------------------------
-------------
-- Module Name: Encoder - Behavioral (Encoder.vhd), component C1
-- Project Name: motor_encoder
--angulo de paso: 5.625�
-- This module defines a component Encoder with a state machine that reads
-- the position of the shaft relative to the starting position.and send a signal to the driver module 
---------------------------------------------------------------------------------------------------------------------
-------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Encoder IS
	PORT (
		clk : IN STD_LOGIC;
		puertos, leds : OUT STD_LOGIC_VECTOR (1 TO 4); --leds testigos y salida al puerto para el  motor, representa el encdedido de las bobinas
		-- signals from the pmod

		A, B : IN STD_LOGIC;
		S1, S2 : IN STD_LOGIC;
		BUZZ : OUT STD_LOGIC;
		-- position of the shaft
		-- direction indicator
		LED : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END Encoder;

ARCHITECTURE Behavioral OF Encoder IS
	-- FSM states and signals
	TYPE stateType IS (idle, R1, R2, R3, L1, L2, L3, add, sub);
	SIGNAL curState, nextState : stateType;
	SIGNAL conter : INTEGER RANGE 1 TO 3 := 3;
	SIGNAL ciclo1, ciclo2 : INTEGER RANGE 0 TO 25 := 0;
	SIGNAL conta_1250us : INTEGER RANGE 1 TO 55000 := 1; -- pulso1 de 1250us@400Hz (0.25ms) 62500
	SIGNAL SAL_400Hz : STD_LOGIC; -- reloj de 400Hz
	SIGNAL sw1, sw2 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	SIGNAL sd1, sd2 : STD_LOGIC := '0';
	SIGNAL limite : INTEGER := 15;

	SIGNAL SS : STD_LOGIC;
	SIGNAL SScontrol : INTEGER RANGE 0 TO 5 := 0;
BEGIN
	limite <= 15; --lmite de pasos (por 4)

	next_state : PROCESS (curState, A, B)
	BEGIN
		curState <= nextState;

		CASE curState IS

				--detent position 
			WHEN idle => conter <= 3;
				LED <= "00";
				IF B = '0' THEN
					nextState <= R1;
					conter <= 1;
				ELSIF A = '0' THEN
					nextState <= L1;
					conter <= 2;
				ELSE
					nextState <= idle;
				END IF;

				-- start of right cycle
				--R1
			WHEN R1 => conter <= 1;
				LED <= "01";
				IF B = '1' THEN
					nextState <= idle;
				ELSIF A = '0' THEN
					nextState <= R2;
				ELSE
					nextState <= R1;
				END IF;

				--R2
			WHEN R2 => conter <= 1;
				LED <= "01";
				IF A = '1' THEN
					nextState <= R1;
				ELSIF B = '1' THEN
					nextState <= R3;
				ELSE
					nextState <= R2;
				END IF;

				--R3
			WHEN R3 => conter <= 1;
				LED <= "01";
				IF B = '0' THEN
					nextState <= R2;
				ELSIF A = '1' THEN
					nextState <= add;
				ELSE
					nextState <= R3;
				END IF;

			WHEN add => conter <= 1;
				LED <= "01";
				nextState <= idle;

				-- start of left cycle
				--L1
			WHEN L1 => conter <= 2;
				LED <= "10";
				IF A = '1' THEN
					nextState <= idle;
				ELSIF B = '0' THEN
					nextState <= L2;
				ELSE
					nextState <= L1;
				END IF;

				--L2
			WHEN L2 => conter <= 2;
				LED <= "10";
				IF B = '1' THEN
					nextState <= L1;
				ELSIF A = '1' THEN
					nextState <= L3;
				ELSE
					nextState <= L2;
				END IF;

				--L3
			WHEN L3 => conter <= 2;
				LED <= "10";
				IF A = '0' THEN
					nextState <= L2;
				ELSIF B = '1' THEN
					nextState <= sub;
				ELSE
					nextState <= L3;
				END IF;
			WHEN sub => conter <= 2;
				LED <= "10";
				nextState <= idle;
			WHEN OTHERS =>
				LED <= "11";
				nextState <= idle;
		END CASE;
	END PROCESS;
	puerto : PROCESS (CLK, conter) BEGIN
		IF rising_edge(CLK) THEN
			IF (conta_1250us = 55000) THEN --cuenta 1250us (50MHz=62500)
				-- if (conta_1250us = 125000) then --cuenta 1250us (100MHz=125000)
				SAL_400Hz <= NOT(SAL_400Hz); --genera un barrido de 2.5ms
				conta_1250us <= 1;
			ELSE
				conta_1250us <= conta_1250us + 1;
			END IF;
		END IF;
		IF rising_edge(SAL_400Hz) THEN
			--IF SS = '0' THEN 
			IF (conter = 1 OR sd1 = '1') AND sd2 = '0' AND S2 = '0' THEN --conter <= sentido de rotacion sd1
				IF sw1 /= "0100" AND ciclo1 /= limite THEN
					sw1 <= sw1 + '1';
					CASE sw1 IS
						WHEN "0000" => leds <= "1100";
							puertos <= "1100";
							sd1 <= '1';
						WHEN "0001" => leds <= "0110";
							puertos <= "0110";
							sd1 <= '1';
						WHEN "0010" => leds <= "0011";
							puertos <= "0011";
							sd1 <= '1';
						WHEN OTHERS => leds <= "1001";
							puertos <= "1001";
							sd1 <= '1';
							ciclo1 <= ciclo1 + 1;
							sw1 <= "0000";
							sd1 <= '1';--leds <= "0000"; puertos <= "0000"; 
					END CASE;
				END IF;
			ELSIF (conter = 2 OR sd2 = '1') AND sd1 = '0' THEN
				IF sw2 /= "0100" AND ciclo2 /= limite AND S1 = '0' THEN
					sw2 <= sw2 + '1';
					CASE sw2 IS
						WHEN "0000" => leds <= "1001";
							puertos <= "1001";
							sd2 <= '1';--1001
						WHEN "0001" => leds <= "0011";
							puertos <= "0011";
							sd2 <= '1';--0011
						WHEN "0010" => leds <= "0110";
							puertos <= "0110";
							sd2 <= '1';--0110
						WHEN OTHERS => leds <= "1100";
							puertos <= "1100";
							sd2 <= '1';
							ciclo2 <= ciclo2 + 1;
							sw2 <= "0000";
							sd2 <= '1'; --leds <= "0000"; puertos <= "0000"; --1100 
					END CASE;
				END IF;
			ELSE
				sw1 <= "0000";
				ciclo1 <= 0;
				sw2 <= "0000";
				ciclo2 <= 0;-- leds<="0000"; puertos<="0000";
			END IF;

			IF (ciclo1 = limite OR ciclo2 = limite) THEN
				leds <= "0000";
				puertos <= "0000";
				sd1 <= '0';
				sd2 <= '0';
			END IF;
		END IF;

		--IF (S1 = '1' OR S2 = '1' )THEN
		--	BUZZ <= '1';
		--ELSE
		--	BUZZ <= '0';
		--	END IF;
		END PROCESS;
	END Behavioral;