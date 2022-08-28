-- Declaracion de las funciones de la tabla 1.1
-- Autor: Juan Antonio Jaramillo Gomez
LIBRARY ieee; -- Declaracion de la biblioteca
USE ieee.std_logic_1164.ALL;
ENTITY funciones IS -- Declaracion de la Entidad
    PORT (
        a, b, c : IN STD_LOGIC; -- Declaracion de los puertos de entrada
        s1, s2, s3, s4, s5, s6 : OUT STD_LOGIC -- puertos de salidas
        --s4, s5, s6 : OUT std_logic -- salidas propuestas por el equipo
    );
END funciones; -- Fin de la entidad
-- La asignacion de los pines se realiza con el programa PlanAhead o
-- con un archivo de restricciones de usuario *.ucf, con el siguiente formato:
-- net "nombre_pin" loc = "pin_FPGA" ;#comentario
ARCHITECTURE a_func OF funciones IS --Declaracion de la Arquitectura
BEGIN
    -- process (a,b,c) --Inicia el proceso
    -- begin

    S1 <= a XOR b XOR c; --xor
    S2 <= a OR b OR c; --or
    S3 <= a XNOR b; --xnor
    S4 <= b NOR c; --asignar otras funciones
    S5 <= a NAND c; -- NOR B
    S6 <= a AND b; --
    -- end process; --Fin del proceso
END a_func; --Fin de la Arquitectura