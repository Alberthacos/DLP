--------------------------------------------------------------------------------
-- Codigo para controlar el llenado de un tinaco  con una bomba 
-- desde una cisterna con 3 sensores en la cisterna 
-- y 3 sensores en el tinaco 
-- El nivel de cada contenedor se muestra en un vummer de LEDs
-- 
-- Amiba 2 
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY LLenadoTinaco IS
    PORT (
        Level_Leds : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        Sensor_Nivel_Tinaco : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Sensor_Nivel_Cisterna : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Water_Pump : OUT STD_LOGIC;
        Enb : IN STD_LOGIC
    );
END ENTITY LLenadoTinaco;

ARCHITECTURE Behavioral OF LLenadoTinaco IS
    SIGNAL TinacoSinAgua : STD_LOGIC;
BEGIN
    Level_Leds <= NOT(Sensor_Nivel_Tinaco) & Sensor_Nivel_Cisterna;
    Control : PROCESS (Sensor_Nivel_Tinaco)
    BEGIN
        IF (Enb = '0') THEN
            IF (Sensor_Nivel_Tinaco(2) = '1' OR Sensor_Nivel_Tinaco(1) = '1' OR Sensor_Nivel_Tinaco(0) = '1') THEN
                TinacoSinAgua <= '1';
            ELSE
                TinacoSinAgua <= '0';
            END IF;
            IF Sensor_Nivel_Cisterna >= "001" AND TinacoSinAgua = '1' THEN
                Water_Pump <= '1';
            ELSE
                Water_Pump <= '0';
            END IF;
        ELSE
            Water_Pump <= '0';
        END IF;

    END PROCESS Control;
END ARCHITECTURE Behavioral;