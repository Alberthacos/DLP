-------------------------------------------------------------------------------------
-- Divisor de 2.5ms (400Hz)
-------------------------------------------------------------------------------------
Library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
----------------------------------------------------------------
-- Declaraci�n de la entidad
entity DIV_CLK is
Port (

	CLK: in STD_LOGIC; -- reloj de 50MHz para la nexys 2 y 100MHz para nexys 3
	SAL_400Hz: inout STD_LOGIC); --salida 2.5ms,

end DIV_CLK;

----------------------------------------------------------------
-- Declaraci�n de la arquitectura
architecture Behavioral of DIV_CLK is

-- Declaraci�n de se�ales de los divisores
signal conta_1250us: integer range 1 to 62_500:=1; -- pulso1 de 1250us@400Hz (0.25ms)
BEGIN

-----------------DIVISOR 2.5ms=400Hz----------------
-------------------DIVISOR �NODOS-------------------
process (CLK) begin
	if rising_edge(CLK) then
				if (conta_1250us = 62_500) then --cuenta 1250us (50MHz=62500)
					-- if (conta_1250us = 125000) then --cuenta 1250us (100MHz=125000)
					SAL_400Hz <= NOT(SAL_400Hz); --genera un barrido de 2.5ms
					conta_1250us <= 1;
	else
					conta_1250us <= conta_1250us + 1;
	end if;
end if;

end process; -- fin del proceso Divisor �nodos
------------------------------------------------
end Behavioral; -- fin de la arquitectura