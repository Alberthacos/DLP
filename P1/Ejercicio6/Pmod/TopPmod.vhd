----------------------------------------------------------------------------------------------------------------------------------
-- Project Name: PmodENC (PmodENC.vhd)
-- Target Devices: Nexys3
-- This project changes the seven segments display when the position of rotary shaft is changed.
-- The number on the 7 segments display is relative to the start position. When the rotary button
-- is pressed, the program resets. The switch controls whether the 7segments display turns on
-- or off. LED 0 and 1 indicated the direction the rotary shaft is turned. LED 0 is on when the shaft
-- is turned right, LED 1 is on when the shaft is turned left.
----------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY SPI_ctrl_ALS IS
    GENERIC (
        N : INTEGER := 8; -- number of bit to serialize
        MAX : INTEGER := 333_333 -- number of us to sample
    );
    PORT (
        --FPGA clock and button
        clk : IN STD_LOGIC; -- 50MHz
        rst : IN STD_LOGIC; -- reset
        --PmodALS
        CS : OUT STD_LOGIC; -- Pmod chip selec
        SDO : IN STD_LOGIC; -- Pmod Serial Data Output
        SCK : OUT STD_LOGIC; -- Pmod Serial Clock
        -- led output
        data : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := x"00"; -- received data
        -- Display "abcdefgP"
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display
        AN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111" -- �nodos del display

    );
END SPI_ctrl_ALS;


ARCHITECTURE Behavioral OF SPI_ctrl_ALS IS
	-- signals
	SIGNAL EncO : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL SalidaReloj : STD_LOGIC;
	SIGNAL tiempo : STD_LOGIC_VECTOR(0 TO 15);
	SIGNAL Unidades, decenas, centenas : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
	SCK <= SalidaReloj;
	U0 : ENTITY work.Clk_div
		PORT MAP(
			clk => clk, 
			rst => rst, 
			--clkdiv => SCK, 
			clkdiv => SalidaReloj
			);

	U1 : ENTITY work.receive
		PORT MAP(
			rst => rst, 
			clkdiv => SalidaReloj, --o SalidaReloj
			SDO => SDO,
			cs => cs,
			temp_o => tiempo, 
			data => data
			);

	U2 : ENTITY work.convertidorBIN
		PORT MAP(
			tempo => tiempo,  
			UNI => unidades, 
			DEC => decenas,
			CEN => Centenas
			);
	U3 : ENTITY work.Display
		PORT MAP(
			UNI => unidades, 
			DEC => Decenas, 
			CEN => centenas,
			DISP => DISPLAY, 
			an => AN,
			clk => clk
			);
		

END Behavioral;