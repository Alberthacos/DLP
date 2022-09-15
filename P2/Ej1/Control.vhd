--------------------------------------------------------------------------------
-- Codigo para controlar acceso en un torniquete
-- Controla el paso de personas por el torniquete con un sensor de barrera infrarrojo 
-- A la salida:
-- Acciona un buzzer que hace un sonido cuando pasa una persona 
-- Enciende un foco de 120v 
-- Acciona un vibrador 
-- Indica la letra "A" en un display 
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Control IS
    PORT (
        sensor: in std_logic ;
        Foco: out std_logic;
        Vibrador: out std_logic;
        buzzer: out std_logic
    );

END ENTITY Control;

ARCHITECTURE Behavioral OF Control IS
--signals
BEGIN

Control_acceso: process(sensor)
 begin 

    if(sensor='1') then
        buzzer <= '1';
        vibrador <= '1';
        Foco <= '1';
    else  
        buzzer <= '0';
        vibrador <= '0';
        Foco <= '0';
end if;
--------------------------------------------------------------------------------
-- Agregar temporizador despues de un accionamiento 
--------------------------------------------------------------------------------
end process;

END ARCHITECTURE Behavioral;