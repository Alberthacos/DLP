----------------------------------------------------------------
-- CONVERTIDOR SHIFT AND ADD 3
----------------------------------------------------------------
Library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
----------------------------------------------------------------
-- Declaraci�n de la entidad
entity SHIFT_ADD is
Port (

					C: in std_logic_vector (3 DOWNTO 0):=(others=>'0'); -- 4 bits
					UNI,DEC,CEN: out std_logic_vector (3 DOWNTO 0) -- digitos unidades,
					); -- decenas y centenas

end SHIFT_ADD;

----------------------------------------------------------------
-- Declaraci�n de la arquitectura
architecture Behavioral of SHIFT_ADD is

-- Declaraci�n de se�ales de la asignaci�n de U-D-C
signal P: std_logic_vector (11 DOWNTO 0); -- asigna UNI, DEC, CEN
BEGIN

-----------CONVERTIR DE BIN A BCD------------------
-- Este proceso contiene un algoritmo recorre y suma 3 para
-- convertir un n�mero binario abcd, que se manda a los displays.
-- El algoritmo consiste en desplazar (shift) el vector inicial
-- (en binario) el n�mero de veces seg�n sea el n�mero de bits,
-- y cuando alguno de los bloques de 4 bits (U-D-C-UM, que es el
-- n�mero de bits necesarios para que cuente de 0 a 9 por cifra)
-- sea igual o mayor a 5 (por eso el >4) se le debe sumar 3
-- a ese bloque, despu�s se continua desplazando hasta que otro
-- (o el mismo) bloque cumpla con esa condici�n y se le sumen 3.
-- Inicialmente se rota 3 veces porque es el n�mero m�nimo de bits
-- que debe tener para que sea igual o mayor a 5.
-- Finalmente se asigna a otro vector, el vector ya convertido,
-- que cuenta con 3 bloques para las 3 cifras de 4 bits cada una.

PROCESS(C)
		--20 bits para separar las Centenas-Decenas-Unidades
		VARIABLE C_D_U:STD_LOGIC_VECTOR(19 DOWNTO 0);
BEGIN

--ciclo de inicializaci�n-------------------------------
			FOR I IN 0 TO 19 LOOP -- manda ceros a los 18 bits +2
						C_D_U(I):='0'; -- se inicializa con 0
			END LOOP;

C_D_U(3 DOWNTO 0):=C(3 downto 0); --c del SRM de 8 bits

--ciclo de asignaci�n C-D-U--------------------------
FOR I IN 0 TO 3 LOOP -- hace 4 veces el ciclo shift-add3

				IF C_D_U(11 DOWNTO 8) > 4 THEN -- U --
				C_D_U(11 DOWNTO 8):= C_D_U(11 DOWNTO 8)+3;
				END IF;
				IF C_D_U(15 DOWNTO 12) > 4 THEN -- D --
				C_D_U(15 DOWNTO 12):= C_D_U(15 DOWNTO 12)+3;
				END IF;
				IF C_D_U(19 DOWNTO 16) > 4 THEN -- C --
				C_D_U(19 DOWNTO 16):= C_D_U(19 DOWNTO 16)+3;
				END IF;
				-- shift -- realiza el corrimiento -----------
				C_D_U(19 DOWNTO 1):= C_D_U(18 DOWNTO 0);
END LOOP;

P<=C_D_U(19 DOWNTO 8); -- guarda en P y en seguida se separan C-D-U

END PROCESS; -- fin del proceso Display

-- separa C-D-U --
-- UNIDADES --
		UNI<=P(3 DOWNTO 0);
-- DECENAS --
		DEC<=P(7 DOWNTO 4);
-- CENTENAS --
		CEN<=P(11 DOWNTO 8);
------------------------------------------------

end Behavioral; -- fin de la arquitectura