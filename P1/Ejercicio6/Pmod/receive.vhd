----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:02:00 09/05/2022 
-- Design Name: 
-- Module Name:    receive - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity receive is
    GENERIC (
      --  N : INTEGER := 8; -- number of bit to serialize
        MAX : INTEGER := 333_333 -- number of us to sample
    );

    Port ( rst : in  STD_LOGIC;
          -- counter : in  STD_LOGIC;
            clkdiv : in  STD_LOGIC;
            temp_o : out STD_LOGIC_VECTOR(0 TO 15);
			CS : OUT STD_LOGIC; -- Pmod chip selec
            data : out STD_LOGIC_VECTOR (8 - 1 DOWNTO 0) := x"00"; -- received data
            SDO : in  STD_LOGIC
			  );
end receive;

architecture Behavioral of receive is
    SIGNAL counter : INTEGER RANGE 0 TO MAX := 0; -- control counter
    SIGNAL tempo : STD_LOGIC_VECTOR(0 TO 15) := x"0000"; -- save data
    
begin
--------------------------------------------------------------------------------
    cnter : PROCESS (rst, counter, clkdiv)
    BEGIN
        -- divisor 1MHz (1us)
        IF (rst = '1' OR counter = MAX) THEN
            counter <= 0;
        ELSIF (rising_edge(clkdiv)) THEN
            counter <= counter + 1;
        END IF;
    END PROCESS cnter;
    --------------------------------------------------------------------------------
    receive : PROCESS (clkdiv, counter, tempo, SDO, rst)
    BEGIN
        --
        IF (rst = '1') THEN
            tempo <= (OTHERS => '0');
        ELSIF (rising_edge(clkdiv)) THEN
            CASE counter IS
                WHEN 0 => CS <= '1';
                WHEN 1 => CS <= '1';
                WHEN 2 => CS <= '0';
                WHEN 3 => tempo(0) <= SDO; --0
                WHEN 4 => tempo(1) <= SDO; --0
                WHEN 5 => tempo(2) <= SDO; --0
                WHEN 6 => tempo(3) <= SDO; --DB7
                WHEN 7 => tempo(4) <= SDO; --DB6
                WHEN 8 => tempo(5) <= SDO; --DB5
                WHEN 9 => tempo(6) <= SDO; --DB4
                WHEN 10 => tempo(7) <= SDO; --DB3
                WHEN 11 => tempo(8) <= SDO; --DB2
                WHEN 12 => tempo(9) <= SDO; --DB1
                WHEN 13 => tempo(10) <= SDO; --DB0
                WHEN 14 => tempo(11) <= SDO; --0
                WHEN 15 => tempo(12) <= SDO; --0
                WHEN 16 => tempo(13) <= SDO; --0
                WHEN 17 => tempo(14) <= SDO; --0
                WHEN 18 => tempo(15) <= SDO; --tri state
                WHEN 19 => CS <= '1'; --
                WHEN OTHERS => CS <= '1'; --
            END CASE;
        END IF;
        data <= tempo (3 TO 10);
        temp_o <= tempo;
    END PROCESS receive;
--------------------------------------------------------------------------------

end Behavioral;

