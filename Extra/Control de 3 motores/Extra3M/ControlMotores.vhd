--Control para de 3 motores con 3 botones y un reset
--Al presionar cualquiera de los 3 botones se enciende el motor correspondiente 
--al numero de boton 
--si se presiona pb1, se enciende el motor 1, etc.
--La unica forma de apagar el motor que se encuentre encendido es mediante un reset 
--que los enviara al estado inicial (motores apagados)

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_signed.ALL;

ENTITY ControlM IS
	PORT (
		CLOCK : IN STD_LOGIC; --reloj 50 mhz de miba2
		PB1 : IN STD_LOGIC; --boton pulsador 1
		PB2 : IN STD_LOGIC; --boton pulsador 2
		PB3 : IN STD_LOGIC; --boton pulsador 3
		Rest : IN STD_LOGIC; --Reset sincrono
		--Salida a leds indicadores, muestra el estado de los motores, el primer bit es un led verde y el ultimo es rojo
		M1 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		M2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		M3 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		Rels : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); --Salida para relevadores que controlan los 3 motores
		BEEP : OUT STD_LOGIC;
		EstadosM : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) --Muestra el estado de los motores para controlar la LCD

	);
END ControlM;

ARCHITECTURE behavioral OF ControlM IS

	-- BINARY ENCODED state machine: Sreg0
	ATTRIBUTE ENUM_ENCODING : STRING;
	TYPE Sreg0_type IS (
		S1, S2, S3, S4
	);
	ATTRIBUTE ENUM_ENCODING OF Sreg0_type : TYPE IS
	"00 " & -- S1
	"01 " & -- S2
	"10 " & -- S3
	"11"; -- S4

	SIGNAL Sreg0, NextState_Sreg0 : Sreg0_type;
	SIGNAL EstadosMotores : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL PWM_Count : INTEGER RANGE 0 TO 20_000_000 := 0;
	SIGNAL Ebeep : STD_LOGIC := '0';
	CONSTANT LIMITE : INTEGER := 16_650_000;
BEGIN

	--------------------------------------------------------------------------------
	-- Maquina de estados 
	--------------------------------------------------------------------------------
	Sreg0_NextState : PROCESS (PB1, PB2, PB3, Sreg0)
	BEGIN
		NextState_Sreg0 <= Sreg0;
		-- asigna valores por defecto al inicio de la secuencia 
		
		IF ((PB1 = '1' AND PB2 = '1') OR (PB2 = '1' AND PB3 = '1') OR (PB1 = '1' AND PB3 = '1') OR (PB1='1' AND PB2= '1' AND PB3 ='1'))THEN
			M1 <= "01";
			M2 <= "01";
			M3 <= "01";
			EstadosMotores <= "000";
		ELSE
		M1 <= "01";
		M2 <= "01";
		M3 <= "01";
			CASE Sreg0 IS --casos de la maquina de estados
				WHEN S1 => --Estado inicial o reset donde todos los motores estan apagados 
					M1 <= "01";
					M2 <= "01";
					M3 <= "01";
					EstadosMotores <= "000";
					IF PB1 = '1' THEN -- presiona el boton correspondiente al motor 1
						NextState_Sreg0 <= S2; --Encender motor 1

					ELSIF PB2 = '1' THEN -- presiona el boton correspondiente al motor 2
						NextState_Sreg0 <= S3; --Encender motor 2

					ELSIF PB3 = '1' THEN -- presiona el boton correspondiente al motor 3
						NextState_Sreg0 <= S4; --Encender motor 3
					END IF;

				WHEN S2 => --Enciende el motor 1
					M1 <= "10";
					M2 <= "01";
					M3 <= "01";
					EstadosMotores <= "100";
					IF PB2 = '1' THEN -- presiona el boton correspondiente al motor 2
						NextState_Sreg0 <= S3;
					ELSIF PB3 = '1' THEN -- presiona el boton correspondiente al motor 3
						NextState_Sreg0 <= S4;
					END IF;

				WHEN S3 => --enciende el motor 2
					M1 <= "01";
					M2 <= "10";
					M3 <= "01";
					EstadosMotores <= "010";
					IF PB1 = '1' THEN
						NextState_Sreg0 <= S2;
					ELSIF PB3 = '1' THEN
						NextState_Sreg0 <= S4;
					END IF;

				WHEN S4 => --enciende el motor 3
					M1 <= "01";
					M2 <= "01";
					M3 <= "10";
					EstadosMotores <= "001";
					IF PB2 = '1' THEN
						NextState_Sreg0 <= S3;
					ELSIF PB1 = '1' THEN
						NextState_Sreg0 <= S2;
					END IF;

				WHEN OTHERS =>
					NULL;

			END CASE;
		END IF;
		IF Rest = '1' THEN
			Sreg0 <= S1;
		ELSE
			Sreg0 <= NextState_Sreg0;
		END IF;
	END PROCESS;

	Sonido : PROCESS (CLOCK)
	BEGIN
		IF rising_edge(Rest) THEN
			Ebeep <= '1';
		END IF;

		IF Ebeep = '1' THEN
			IF rising_edge(clock) THEN
				PWM_Count <= PWM_Count + 1;
			END IF;

			IF PWM_Count <= LIMITE THEN -- 1/3s 20ns(16_650_00)=333ms
				BEEP <= '1';
			ELSE
				BEEP <= '0';
			END IF;

			IF PWM_Count = LIMITE + 1 THEN
				Ebeep <= '0';
			END IF;
		ELSE
			PWM_Count <= 0;

		END IF;
	END PROCESS Sonido;
	Rels <= EstadosMotores; --Salida a relevadores que controlan el encendido y apagado de los motores
	EstadosM <= EstadosMotores; --Salida a una señal que se utiliza para el control de la LCD, indica el estado de los motores

END behavioral;