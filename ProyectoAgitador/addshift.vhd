library IEEE; 

use IEEE.STD_LOGIC_1164.ALL; 

use IEEE.STD_LOGIC_ARITH.ALL; 

use IEEE.STD_LOGIC_UNSIGNED.ALL; 

  

entity pasaYSuma is port( 

    numero: in STD_LOGIC_VECTOR(8 downto 0); 

    unidades, decenas, centenas: out STD_LOGIC_VECTOR(3 downto 0) 

); 

end pasaYSuma; 

  

architecture Behavioral of pasaYSuma is 

    signal P: STD_LOGIC_VECTOR(11 downto 0); --asigna los valores 

begin 

  

process(numero) 

    variable C_D_U: STD_LOGIC_VECTOR(20 downto 0); 

begin 

  

    Inicializar : for i in 0 to 16 loop 

        C_D_U(i) := '0'; 

    end loop ; -- Inicializar 

  

    C_D_U(8 downto 0) := numero(8 downto 0); 

  

    --Ciclo de asignación 

  

    pasa_y_suma_3 : for i in 0 to 8 loop 

        --Unidades 

        if C_D_U(12 downto 9)>4 then 

            C_D_U(12 downto 9) := C_D_U(12 downto 9) + 3; 

        end if; 

        --Decenas 

        if C_D_U(16 downto 13)>4 then 

            C_D_U(16 downto 13) := C_D_U(16 downto 13) + 3; 

        end if; 

        --Centenas 

        if C_D_U(20 downto 17)>4 then 

            C_D_U(20 downto 17) := C_D_U(20 downto 17) + 3; 

        end if; 

  

        --Corrimiento 

        C_D_U(20 downto 1) := C_D_U(19 downto 0); 

    end loop; -- pasa_y_suma_3 

  

    P <= C_D_U(20 downto 9); 

end process; 

  

--Asignar unidades 

    Unidades    <=P(3 downto 0); 

    Decenas     <=P(7 downto 4); 

    Centenas    <=P(11 downto 8); 

  

end Behavioral;

