----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:06:28 09/05/2022 
-- Design Name: 
-- Module Name:    Display - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Display is
    Port ( UNI : in  STD_LOGIC_VECTOR (3 downto 0);
           DEC : in  STD_LOGIC_VECTOR (3 downto 0);
           CEN : in  STD_LOGIC_VECTOR (3 downto 0);
           AN : out  STD_LOGIC_VECTOR (3 downto 0);
           DISP: out STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC
           );
end Display;

architecture Behavioral of Display is
    SIGNAL contadors : INTEGER RANGE 1 TO 6250 := 1; -- pulso1 de 0.25ms (pro. divisor �nodos)
    SIGNAL SAL_250us : STD_LOGIC; --
    SIGNAL SEL : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00"; -- selector de barrido
    SIGNAL D : STD_LOGIC_VECTOR (3 DOWNTO 0); -- sirve para almacenar los valores del display
    
begin
------------------- DIVISOR �NODOS ----------------------------------------
PROCESS (CLK) BEGIN
IF rising_edge(CLK) THEN
    IF (contadors = 6250) THEN --cuenta 0.125ms (50MHz=6250)
        -- if (contadors = 12500) then --cuenta 0.125ms (100MHz=12500)
        SAL_250us <= NOT(SAL_250us); --genera un barrido de 0.25ms
        contadors <= 1;
    ELSE
        contadors <= contadors + 1;
    END IF;
END IF;
END PROCESS; -- fin del proceso Divisor �nodos
-------------------- MULTIPLEXOR ------------------------------------------
PROCESS (SAL_250us, sel, UNI, DEC, CEN)
BEGIN
IF SAL_250us'EVENT AND SAL_250us = '1' THEN
    SEL <= SEL + '1';
    CASE(SEL) IS
        WHEN "00" => AN <= "0111";
        D <= UNI; -- UNIDADES
        WHEN "01" => AN <= "1011";
        D <= DEC; -- DECENAS
        WHEN "10" => AN <= "1101";
        D <= CEN; -- CENTENAS
        WHEN OTHERS => AN <= "1111"; -- OFF
    END CASE;
END IF;
END PROCESS; -- fin del proceso Multiplexor
-------------------- DISPLAY ------------------------------------------
PROCESS (D)
BEGIN
CASE(D) IS -- abcdefgP
    WHEN "0000" => DISP <= "00000011"; --0
    WHEN "0001" => DISP <= "10011111"; --1
    WHEN "0010" => DISP <= "00100101"; --2
    WHEN "0011" => DISP <= "00001101"; --3
    WHEN "0100" => DISP <= "10011001"; --4
    WHEN "0101" => DISP <= "01001001"; --5
    WHEN "0110" => DISP <= "01000001"; --6
    WHEN "0111" => DISP <= "00011111"; --7
    WHEN "1000" => DISP <= "00000001"; --8
    WHEN "1001" => DISP <= "00001001"; --9
    WHEN OTHERS => DISP <= "11111111"; --apagado
END CASE;
END PROCESS; -- fin del proceso Display
------------------------------------------------------------------------------------------

end Behavioral;

