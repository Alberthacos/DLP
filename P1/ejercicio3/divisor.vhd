--------------------------------------------------------------------------------------
-- Controlador del display de 4 digitos
--------------------------------------------------------------------------------------
Library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
----------------------------------------------------------------
-- Declaraci�n de la entidad
entity DISPLAYS is
Port (

	UNI,DEC,CEN,signo: in std_logic_vector (3 DOWNTO 0); -- digitos unidades, decenas,
	-- centenas y signo
	SAL_400Hz: in STD_LOGIC; -- reloj de 400Hz
	DISPLAY: out STD_LOGIC_VECTOR(7 DOWNTO 0); -- seg dsply "abcdefgP"
	AN: out STD_LOGIC_VECTOR(3 DOWNTO 0)); -- anodos del display

end DISPLAYS;

----------------------------------------------------------------
-- Declaraci�n de la arquitectura
architecture Behavioral of DISPLAYS is

-- Declaraci�n de se�ales de la multiplexaci�n y asignaci�n de U-D-C al disp
signal SEL: std_logic_vector (1 downto 0):="00"; -- selector de barrido
signal D: std_logic_vector (3 downto 0); -- almacena los valores del disp

BEGIN

--------------------MULTIPLEXOR---------------------
PROCESS(SAL_400Hz, sel, UNI, DEC,CEN)
BEGIN

		IF SAL_400Hz'EVENT and SAL_400Hz='1' THEN SEL <= SEL + '1';
		
		CASE(SEL) IS
			when "00" => AN <="1110"; D <= UNI; -- UNIDADES
			when "01" => AN <="1101"; D <= DEC; -- DECENAS
			when "10" => AN <="1011"; D <= CEN; -- CENTENAS
			when "11" => AN <="0111"; D <= SIGNO; -- signo
			when OTHERS=>AN <="1111"; D <= SIGNO; -- signo
		END CASE;
end if;

END PROCESS; -- fin del proceso Multiplexor

--------------------DISPLAY---------------------
PROCESS(D)
Begin
			case(D) is -- abcdefgP
			WHEN x"0" => DISPLAY <= "00000011"; --0
			WHEN x"1" => DISPLAY <= "10011111"; --1
			WHEN x"2" => DISPLAY <= "00100101"; --2
			WHEN x"3" => DISPLAY <= "00001101"; --3
			WHEN x"4" => DISPLAY <= "10011001"; --4
			WHEN x"5" => DISPLAY <= "01001001"; --5
			WHEN x"6" => DISPLAY <= "01000001"; --6
			WHEN x"7" => DISPLAY <= "00011111"; --7
			WHEN x"8" => DISPLAY <= "00000001"; --8
			WHEN x"9" => DISPLAY <= "00001001"; --9
			WHEN x"F" => DISPLAY <= "11111101"; --signo
			WHEN OTHERS => DISPLAY <= "11111111"; --apagado
			END CASE;
	
END PROCESS; -- fin del proceso Display
------------------------------------------------
end Behavioral; -- fin de la arquitectura