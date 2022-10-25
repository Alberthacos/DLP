--codigo para controlar los pasos de un motor PAP a traves de un encoder mecanico
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY motor_encoder IS PORT(

		CLK: in STD_LOGIC; -- reloj de 50MHz para la amiba2
		Sensor1,Sensor2 : IN STD_LOGIC;
		Buzzer : OUT STD_LOGIC;
		Entradas : in STD_LOGIC_VECTOR (5 downto 4); -- Primeras dos entradas de amiba 2
		puertos,leds : OUT std_logic_vector (1 to 4); --leds testigos y salida al puerto para el motor, representa el encdedido de las bobinas
		LED: out STD_LOGIC_VECTOR (1 downto 0) -- Led indicates the direction the shaft (encoder)
);
END motor_encoder;

architecture Behavioral of motor_encoder is
-- signals
		 signal EncO : std_logic_vector (4 downto 0);
		 signal AO, BO: std_logic;
begin

C0: entity work.Debouncer
port map ( 
		clk=>clk, 
		Ain=>Entradas(4), 
		Bin=>Entradas(5), 
		Aout=> AO, 
		Bout=> BO);
		
C1: entity work.Encoder
port map ( 
		clk=>clk, 
		Sensor1 => Sensor1,
		Sensor2 => Sensor2,
		Buzzer => Buzzer,
		A=>AO, 
		B=>BO, 
		puertos => puertos,
		leds => leds,
		LED=>LED
		);
		
end Behavioral;

