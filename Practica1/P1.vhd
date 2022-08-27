-- Declaración de las funciones de la tabla 1.1
-- Autor: Juan Antonio Jaramillo Gómez
library ieee; -- Declaración de la biblioteca
use ieee.std_logic_1164.all;
entity funciones is -- Declaración de la Entidad
port ( a,b,c: in std_logic; -- Declaración de los puertos de entrada
s1,s2,s3: out std_logic -- puertos de salidas
-- s4,s5,s6: OUT std_logic -- salidas propuestas por el equipo
);
end funciones; -- Fin de la entidad
-- La asignación de los pines se realiza con el programa PlanAhead o
-- con un archivo de restricciones de usuario *.ucf, con el siguiente formato:
-- net "nombre_pin" loc = "pin_FPGA" ;#comentario
Architecture a_func OF funciones IS --Declaración de la Arquitectura
begin
-- process (a,b,c) --Inicia el proceso
-- begin

S1 <= a xor b xor c; --xor
S2 <= a or b or c; --or
S3 <= a xnor b; --xnor
-- S4 <= ...; --asignar otras funciones
-- S5 <= ...; --
-- S6 <= ...; --
-- end process; --Fin del proceso
end a_func; --Fin de la Arquitectura