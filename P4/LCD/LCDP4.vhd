--CODIGO PARA CONTROLAR UN LCD CON LA TARJETA AMIBA 2 CON 8 BITS
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY LCD IS
	PORT (
		CLOCK : IN STD_LOGIC;
		LED : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- signals entrada para debouncer desde encoder fisico
		Ain : IN STD_LOGIC;
		Bin : IN STD_LOGIC;
		--boton para reinicio de contador con encoder.vhd
		BTN : IN STD_LOGIC; --reset

		--Entradas para LCD
		direccion1, E_direccion : IN STD_LOGIC; --sw que indica la direccion//sw que habilita el movimiento del display(texto completo)
		REINI : IN STD_LOGIC; --boton de reinicio (envia a home el texto)
		LCD_RS : OUT STD_LOGIC := '0'; --	Comando, escritura
		LCD_RW : OUT STD_LOGIC; -- LECTURA/ESCRITURA
		LCD_E : OUT STD_LOGIC; -- ENABLE
		DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"; -- PINES DATOS
		numeros_encoder : IN STD_LOGIC --boton para elegir encoder

	);
END LCD;

ARCHITECTURE Behavioral OF LCD IS
	---------------SIGNALS--------------------

	-----SIGNALS FOR DEBOUNCER-----------
	SIGNAL sclk : STD_LOGIC_VECTOR (6 DOWNTO 0);
	SIGNAL sampledA, sampledB : STD_LOGIC;

	-- debounced signals
	---salidas de debouncer util para encoder
	SIGNAL Aout : STD_LOGIC;
	SIGNAL Bout : STD_LOGIC;
	----------------------------------------------------------------

	------SIGNALS FOR ENCODER---------------
	-- signals from the pmod
	SIGNAL A : STD_LOGIC;
	SIGNAL B : STD_LOGIC;

	-- FSM states and signals
	TYPE stateType IS (idle, R1, R2, R3, L1, L2, L3, add, sub);
	SIGNAL curState, nextState : stateType;
	SIGNAL EncOut : INTEGER RANGE 0 TO 99 := 0;
	---------------------------------------

	-----SIGNALS FOR LCD---------------
	--signal FSM
	TYPE STATE_TYPE IS (
		RST, ST0, ST1, ST2, SET_DEFI, SHOW1, SHOW2, CLEAR, ENTRY, C, AA, L, M, O, E, T, R, N, I, S, X, BB, J,
		desplazamiento, Vacio, CambioFila, decen, unid, limpiarlCD, espacio, dos_puntos, D, Z);
	SIGNAL State, Next_State : STATE_TYPE;

	SIGNAL CONT1 : STD_LOGIC_VECTOR(23 DOWNTO 0) := X"000000"; -- 16,777,216 = 0.33554432 s MAX
	SIGNAL CONT2 : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000"; -- 32 = 0.64us
	SIGNAL RESET : STD_LOGIC := '0';
	SIGNAL READY : STD_LOGIC := '0';
	SIGNAL listo : STD_LOGIC := '0';
	SIGNAL unidades, decenas : INTEGER RANGE 0 TO 9 := 0;
	--signal LCD_numeros_Encoder
	SIGNAL numeroD, numeroU : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL As, Es, Ls, Cs, M_s, Rs, Espacios, Oos, Iss, Ts, SS, Js : INTEGER RANGE 0 TO 20 := 1;

	------------------------------------------------
BEGIN
	----------------D E B O U N C E R------------------------
	deb : PROCESS (clock, Aout, Bout)
	BEGIN

		IF clock'event AND clock = '1' THEN
			sampledA <= Ain;
			sampledB <= Bin;
			-- clock is divided to 1MHz
			-- samples every 1uS to check if the input is the same as the sample
			-- if the signal is stable, the debouncer should output the signal
			IF sclk = "1100100" THEN
				-- A	
				IF sampledA = Ain THEN
					Aout <= Ain;
				END IF;
				-- B
				IF sampledB = Bin THEN
					Bout <= Bin;
				END IF;

				sclk <= "0000000";
			ELSE
				sclk <= sclk + 1;
			END IF;
		END IF;
		A <= Aout;
		B <= Bout;
	END PROCESS;
	---------------------END DEBOUNCER------------------

	---------------------E N C O D E R----------------
	--clk and button
	reloj : PROCESS (clock, BTN)
	BEGIN
		-- if the rotary button is pressed the count resets
		IF (BTN = '1') THEN
			curState <= idle;
			EncOut <= 0;
		ELSIF (clock'event AND clock = '1') THEN
			-- detect if the shaft is rotated to right or left
			-- right: add 1 to the position at each click
			-- left: subtract 1 from the position at each click
			IF curState /= nextState THEN
				IF (curState = add) THEN
					IF EncOut < 63 THEN
						EncOut <= EncOut + 1;
					ELSE
						EncOut <= 0;
					END IF;

				ELSIF (curState = sub) THEN
					IF EncOut > 0 THEN
						EncOut <= EncOut - 1;
					ELSE
						EncOut <= 63;
					END IF;

				ELSE
					EncOut <= EncOut;
				END IF;

			ELSE
				EncOut <= EncOut;
			END IF;
			curState <= nextState;
		END IF;
	END PROCESS;

	-----FSM process
	nex_state : PROCESS (curState, A, B)
	BEGIN
		CASE curState IS

				--detent position
			WHEN idle =>
				LED <= "00";
				IF B = '0' THEN
					nextState <= R1;
				ELSIF A = '0' THEN
					nextState <= L1;
				ELSE
					nextState <= idle;
				END IF;

				-- start of right cycle
				--R1
			WHEN R1 =>
				LED <= "01";
				IF B = '1' THEN
					nextState <= idle;
				ELSIF A = '0' THEN
					nextState <= R2;
				ELSE
					nextState <= R1;
				END IF;

				--R2
			WHEN R2 =>
				LED <= "01";
				IF A = '1' THEN
					nextState <= R1;
				ELSIF B = '1' THEN
					nextState <= R3;
				ELSE
					nextState <= R2;
				END IF;

				--R3
			WHEN R3 =>
				LED <= "01";
				IF B = '0' THEN
					nextState <= R2;
				ELSIF A = '1' THEN
					nextState <= add;
				ELSE
					nextState <= R3;
				END IF;

			WHEN add =>
				LED <= "01";
				nextState <= idle;

				-- start of left cycle
				--L1
			WHEN L1 =>
				LED <= "10";
				IF A = '1' THEN
					nextState <= idle;
				ELSIF B = '0' THEN
					nextState <= L2;
				ELSE
					nextState <= L1;
				END IF;

				--L2
			WHEN L2 =>
				LED <= "10";
				IF B = '1' THEN
					nextState <= L1;
				ELSIF A = '1' THEN
					nextState <= L3;
				ELSE
					nextState <= L2;
				END IF;

				--L3
			WHEN L3 =>
				LED <= "10";
				IF A = '0' THEN
					nextState <= L2;
				ELSIF B = '1' THEN
					nextState <= sub;
				ELSE
					nextState <= L3;
				END IF;

			WHEN sub =>
				LED <= "10";
				nextState <= idle;

			WHEN OTHERS =>
				LED <= "11";
				nextState <= idle;
		END CASE;

	END PROCESS;
	---------------------END ENCODER------------------

	------------------LCD-----------------------
	-------------------------------------------------------------------
	--Contador de Retardos CONT1--
	PROCESS (CLOCK, RESET)
	BEGIN
		IF RESET = '1' THEN
			CONT1 <= (OTHERS => '0');
		ELSIF CLOCK'event AND CLOCK = '1' THEN
			CONT1 <= CONT1 + 1;
		END IF;
	END PROCESS;
	-------------------------------------------------------------------
	--Contador para Secuencias CONT2--
	PROCESS (CLOCK, READY)
	BEGIN
		IF CLOCK = '1' AND CLOCK'event THEN
			IF READY = '1' THEN
				CONT2 <= CONT2 + 1;
			ELSE
				CONT2 <= "00000";
			END IF;
		END IF;
	END PROCESS;
	-------------------------------------------------------------------
	--Actualizaci?n de estados--
	PROCESS (CLOCK, Next_State)
	BEGIN
		IF CLOCK = '1' AND CLOCK'event THEN
			State <= Next_State;
		END IF;
	END PROCESS;
	------------------------------------------------------------------
	PROCESS (CONT1, CONT2, State, CLOCK, REINI, listo, E_direccion, direccion1, numeros_encoder)
	BEGIN

		IF listo = '1' THEN --se puede habilitar el movimiento solo si ya se escribio la palabra 
			IF numeros_encoder = '0' THEN
				IF E_direccion = '0' THEN
					next_state <= vacio; --texto estatico
				ELSIF E_direccion = '1' THEN
					next_state <= desplazamiento;--marquesina con movimiento
				END IF;
			ELSIF numeros_encoder = '1' AND E_direccion = '0' THEN
				next_state <= CLEAR;
				--LCD_RS<='0';
			END IF;
		END IF;

		---CONTROL DE NUMEROS ENCODER

		IF REINI = '1' THEN
			Next_State <= RST;
		ELSIF CLOCK = '0' AND CLOCK'event THEN
			CASE State IS

				WHEN RST => -- Estado de reset
					IF CONT1 = X"000000"THEN --0s
						LCD_RS <= '0';
						LCD_RW <= '0';
						LCD_E <= '0';
						DATA <= x"00";
						Next_State <= ST0;
					ELSE
						Next_State <= ST0;
					END IF;

				WHEN ST0 => --Primer estado de espera por 25ms (20ms=0F4240=1000000)(15ms=0B71B0=750000)
					---SET 1
					IF CONT1 = X"2625A0" THEN -- 2,500,000=50ms
						READY <= '1';
						DATA <= "00110000"; -- FUNCTION SET 8BITS, 2 LINE, 5X7
						Next_State <= ST0;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN--rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						Next_State <= ST1;
					ELSE
						Next_State <= ST0;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

				WHEN ST1 => --Segundo estado de espera por 5ms --SET2
					IF CONT1 = X"03D090" THEN -- 250,000 = 5ms
						READY <= '1';
						DATA <= "00110000"; -- FUNCTION SET
						Next_State <= ST1;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						Next_State <= ST2;
					ELSE
						Next_State <= ST1;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
				WHEN ST2 => --Tercer estado de espera por 100us  SET 3
					IF CONT1 = X"0035E8" THEN -- 5000 = 100us  = x35E8)
						READY <= '1';
						DATA <= "00110000"; -- FUNCTION SET
						Next_State <= ST2;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						Next_State <= SET_DEFI;
					ELSE
						Next_State <= ST2;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

				WHEN SET_DEFI => --Cuarto paso, se asignan lineas logicas, modo de bits (8) y #caracteres(5x8)
					--SET DEFINITIVO
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "00111000"; -- FUNCTION SET(lineas,caracteres,bits)
						Next_State <= SET_DEFI;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						Next_State <= SHOW1;
						LCD_RS <= '0';
					ELSE
						Next_State <= SET_DEFI;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
				WHEN SHOW1 => --Quinto paso, se apaga el display por unica ocasion
					--SHOW _ APAGAR DISPLAY
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "00001000"; -- SHOW, APAGAR DISPLAY POR UNICA OCASION 
						Next_State <= SHOW1;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						-----CLEAR, LIMPIAR DISPLAY
						Next_State <= CLEAR;
					ELSE
						Next_State <= SHOW1;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

				WHEN CLEAR => --SEXTO PASO, SE LIMPIA EL DISPLAY 

				LCD_RS <= '0';
					IF CONT1 = X"4C4B40" THEN
						READY <= '1';
						DATA <= "00000001"; -- CLEAR
						Next_State <= CLEAR;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						Next_State <= ENTRY;
						listo <= '0';
						As <= 1;
						Es <= 1;
						Ls <= 1;
						Cs <= 1;
						Oos <= 1;
						M_s <= 1;
						Rs <= 1;
						Iss <= 1;
						Ts <= 1;
						Ss <= 1;
						Js <= 1;
						Espacios <= 1;

						--As, Es, Ls, Cs, M_s, Rs, Espacios, Oos, Iss, Ts, SS, Js
					ELSE
						Next_State <= CLEAR;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0

				WHEN ENTRY => --SEPTIMO PASO, CONFIGURAR MODO DE ENTRADA --ENTRY MODE
					IF CONT1 = X"3D090" THEN --espera por 5ms 250,000
						READY <= '1';
						DATA <= "00000110"; -- ENTRY MODE, se mueve a la derecha(escritura), no se desplaza(barrido)
						Next_State <= ENTRY;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						Next_State <= SHOW2;
					ELSE
						Next_State <= ENTRY;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN SHOW2 => --OCTAVO PASO, ENCENDER LA LCD Y CONFIGURAR CURSOR, PARPADEO
					---SHOW DEFINITIVO
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "00001111"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
						Next_State <= SHOW2;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						LCD_RS <= '1';
						IF E_direccion = '0' AND numeros_encoder = '1' THEN --Numeros controlados con encoder
							Next_State <= C;--Contador
						ELSIF ((E_direccion = numeros_encoder) OR (E_direccion = '1' AND numeros_encoder = '0')) AND listo = '0' THEN
							Next_State <= AA; --Alexis
						END IF;
					ELSE
						Next_State <= SHOW2;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN AA => --LETRA A mayuscula
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01000001"; -- A
						Next_State <= AA;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						IF E_direccion = '0' AND numeros_encoder = '1' THEN
							Next_State <= D; --contaDor
						ELSE
							IF As = 1 THEN ---
								Next_State <= L; --aLexis
							ELSIF As = 2 THEN
								Next_State <= L;--ALber1t
							ELSIF As = 3 THEN
								Next_State <= Espacio;--jose_cristia__laj  /espacio
							ELSIF As = 4 THEN
								Next_State <= J;--jose_cristia__laJ
							END IF;
						END IF;
						As <= As + 1; --aumenta numero de As escritas
					ELSE
						Next_State <= AA;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN L => --L MAYUSCULA
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01001100"; -- L MAYUSCULA aLexis
						Next_State <= L;

					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';

						IF Ls = 1 THEN ---//URGENTE// REINICIAR CONTADOR A 1 EN LA DECLARACION
							Next_State <= E; --alExis
						ELSIF Ls = 2 THEN
							Next_State <= BB;--alBert
						ELSIF Ls = 3 THEN
							Next_State <= AA;--alBert
						END IF;

						Ls <= Ls + 1; --aumenta numero de Ls escritas

					ELSE
						Next_State <= L;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN E => --E MAYUSCULA
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01000101"; -- E
						Next_State <= E;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';

						IF Es = 1 THEN ---//URGENTE// REINICIAR CONTADOR A 1 EN LA DECLARACION
							Next_State <= X; --aleXis
						ELSIF Es = 2 THEN
							Next_State <= R;--albeRt
						ELSIF Es = 3 THEN
							Next_State <= Espacio;--jose__cristian
						END IF;
						Es <= Es + 1; --aumenta numero de Es escritas

					ELSE
						Next_State <= E;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN X => --X MAYUSCULA
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01011000"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
						Next_State <= X;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						Next_State <= I;
					ELSE
						Next_State <= X;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					---------------------------------------------------------------------------------
				WHEN I => --I
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01001001"; -- alexIs
						Next_State <= I;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';

						IF Iss = 1 THEN
							Next_State <= S; --alexiS
						ELSIF Iss = 2 THEN
							Next_State <= S; --criStian
						ELSIF Iss = 3 THEN
							Next_State <= AA; --cristiAn
						END IF;
						Iss <= Iss + 1;

					ELSE
						Next_State <= I;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------					
				WHEN S => --S 
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01010011"; ---alexiS
						Next_State <= S;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';

						IF Ss = 1 THEN ---//URGENTE// REINICIAR CONTADOR AA 1 EN LA DECLARACION
							Next_State <= Espacio; --alexis_Albert
							LCD_RS <= '0'; --Enviar Comandos
						ELSIF Ss = 2 THEN
							LCD_RS <= '1'; --Enviar Datos
							Next_State <= E;--josE
						ELSIF Ss = 3 THEN
							LCD_RS <= '1'; --Enviar Datos
							Next_State <= T;--crisTian
						END IF;

						Ss <= Ss + 1; --aumenta numero de Ss escritas

					ELSE
						Next_State <= S;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN Espacio => --Espacio
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						LCD_RS <= '0';
						DATA <= "00010100"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
						Next_State <= Espacio;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						LCD_RS <= '1'; ---enviar datos

						IF Espacios = 1 THEN ---//URGENTE// REINICIAR CONTADOR AA 1 EN LA DECLARACION
							Next_State <= AA; --alexis_Albert
						ELSIF Espacios = 2 THEN
							Next_State <= C;--jose_Cristian
						ELSIF Espacios = 3 THEN
							Next_State <= L;--jose_cristia_Laj
						END IF;

						Espacios <= Espacios + 1; --aumenta numero de Espacios escritas
						--IF Espacios = 0 THEN
						--	Next_State <= M;------ M ora
						--ELSIF Espacios = 1 THEN
						--	Next_state <= L;
						--END IF;
						--Espacios <= Espacios + 1;
					ELSE
						Next_State <= Espacio;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN BB => --B mayuscula
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01000010"; -- B
						Next_State <= BB;

					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						LCD_RS <= '1';

						Next_State <= E; --albErt

					ELSE
						Next_State <= BB;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN R => --R mayuscula
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01010010"; -- R
						Next_State <= R;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						LCD_RS <= '1';
						IF E_direccion = '0' AND numeros_encoder = '1' THEN
							Next_State <= dos_puntos;
						ELSE
							IF Rs = 1 THEN
								Next_State <= T; --alberT
							ELSIF Rs = 2 THEN
								Next_State <= I; --cristIan
							END IF;
						END IF;
						Rs <= Rs + 1;
					ELSE
						Next_State <= R;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN T => --T mayuscula
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01010100"; -- T
						Next_State <= T;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						IF E_direccion = '0' AND numeros_encoder = '1' THEN
							Next_State <= AA;
						ELSE
							IF Ts = 1 THEN
								Next_State <= CambioFila; --alexis albert__
								LCD_RS <= '0'; --Envio de comandos
							ELSIF Ts = 2 THEN
								Next_State <= I; --cristIan
								LCD_RS <= '1'; --Envio de Datos
							END IF;
						END IF;
						Ts <= Ts + 1;

					ELSE
						Next_State <= T;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------

					--------------------------------------------------------------------------------
				WHEN J => --Jose 
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01001010"; -- Jose
						Next_State <= J;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';

						IF Js = 1 THEN
							Next_State <= O; --jOse
						ELSIF Js = 2 THEN
							Next_State <= Vacio; --Final de texto estatico 
							listo <= '1';
						END IF;
						Js <= Js + 1;
					ELSE
						Next_State <= J;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN O => --O jOse
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01001111"; -- jOse
						Next_State <= O;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						IF E_direccion = '0' AND numeros_encoder = '1' THEN
							IF oos = 1 THEN --DECLARAR
								Next_State <= N;
							ELSIF oos = 2 THEN
								Next_State <= R;
							END IF;
							oos <= oos + 1;
						ELSE
							Next_State <= S; --joSe
						END IF;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN C => --C Cristian
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01000011"; -- C
						Next_State <= C;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';

						IF E_direccion = '0' AND numeros_encoder = '1' THEN
							Next_State <= O;--decen
						ELSE
							Next_State <= R; --cRistian
						END IF;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
					--------------------------------------------------------------------------------
					-- 
					--------------------------------------------------------------------------------

				WHEN CambioFila => --Cambio Fila
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "11000000"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
						Next_State <= CambioFila;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						LCD_RS <= '1';
						Next_State <= J;
					ELSE
						Next_State <= CambioFila;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN Vacio => --Sin ordenes
					IF CONT1 = X"E4E1C0" THEN --espera por 500ms 20ns*25,000,000=50ms 2500=9C4
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns

					ELSIF CONT2 = "1111" THEN
					ELSE
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					LCD_RS <= '0';
					--------------------------------------------------------------------------------
				WHEN N => --Z mayuscula
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01001110"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
						Next_State <= N;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						LCD_RS <= '1';
						Next_State <= T; --
					ELSE
						Next_State <= N;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3);
					--------------------------------------------------------------------------------
				WHEN D => --D 
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "01000100"; --DDDDDD
						Next_State <= D;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						Next_State <= O; --contadOr
					ELSE
						Next_State <= D;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN dos_puntos => --:
					IF CONT1 = X"0009C4" THEN --espera por 50us 20ns*2500=50us 2500=9C4
						READY <= '1';
						DATA <= "00111010"; --DDDDDD
						Next_State <= dos_puntos;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						Next_State <= decen;
					ELSE
						Next_State <= dos_puntos;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN decen => --DECENAS
					IF CONT1 = X"0009C4" THEN --espera por 50ms 20ns*25,000,000=50ms 2500=9C4
						READY <= '1';
						DATA <= numeroD; -- RECIBE NUMERO CORRESPONDIENTE A DECENAS
						Next_State <= decen;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						Next_State <= unid;
					ELSE
						Next_State <= decen;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------
				WHEN unid => --UNIDADES
					IF CONT1 = X"0009C4" THEN --espera por 500ms 20ns*25,000,000=50ms 2500=9C4
						READY <= '1';
						DATA <= numeroU; -- RECIBE NUMERO CORRESPONDIENTE A DECENAS
						Next_State <= unid;
					ELSIF CONT2 > "00001" AND CONT2 < "01110" THEN --rango de 12*20ns=240ns
						LCD_E <= '1';
					ELSIF CONT2 = "1111" THEN
						READY <= '0';
						LCD_E <= '0';
						LCD_RS <= '0';
						next_state <= Clear;
						listo <= '0';
					ELSE
						Next_State <= unid;
					END IF;
					RESET <= CONT2(0)AND CONT2(1)AND CONT2(2)AND CONT2(3); -- CONT1 = 0
					--------------------------------------------------------------------------------		
					when desplazamiento => --desplazamiento
			if CONT1=X"E4E1C0" then --espera por 50ms 20ns*25,000,000=50ms 2500=9C4
				READY<='1';
				DATA<="00011"&direccion1&"00"; -- Envia direccion del desplazamiento
				Next_State<=desplazamiento;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				LCD_RS<='0';
				Next_State<=desplazamiento;
			else
				Next_State<=desplazamiento;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
				WHEN OTHERS => READY <= '0';
					LCD_E <= '0';
					LCD_RS <= '0';

			END CASE;
		END IF;
	END PROCESS;

	numbers : PROCESS (clock)
	BEGIN
		IF rising_edge(clock) THEN
			CASE decenas IS
				WHEN 0 => numeroD <= "00110000";
				WHEN 1 => numeroD <= "00110001";
				WHEN 2 => numeroD <= "00110010";
				WHEN 3 => numeroD <= "00110011";
				WHEN 4 => numeroD <= "00110100";
				WHEN 5 => numeroD <= "00110101";
				WHEN 6 => numeroD <= "00110110";
				WHEN 7 => numeroD <= "00110111";
				WHEN 8 => numeroD <= "00111000";
				WHEN 9 => numeroD <= "00111001";
					--		when others numeroU<="00000000"; numeroD<="00000000";
			END CASE;

			CASE unidades IS
				WHEN 0 => numeroU <= "00110000";
				WHEN 1 => numeroU <= "00110001";
				WHEN 2 => numeroU <= "00110010";
				WHEN 3 => numeroU <= "00110011";
				WHEN 4 => numeroU <= "00110100";
				WHEN 5 => numeroU <= "00110101";
				WHEN 6 => numeroU <= "00110110";
				WHEN 7 => numeroU <= "00110111";
				WHEN 8 => numeroU <= "00111000";
				WHEN 9 => numeroU <= "00111001";
					--		when others numeroU<="00000000"; numeroD<="00000000";
			END CASE;

			----------------------------------
			-----------------------------------
			IF EncOut <= 9 THEN
				decenas <= 0;
				unidades <= EncOut;
			ELSE
				decenas <= (EncOut/10);
				unidades <= (EncOut - (decenas * 10));
			END IF;
			------------------------------------
			--------------------------------------
		END IF;
	END PROCESS;

	-------------END LCD----------------------
END Behavioral;