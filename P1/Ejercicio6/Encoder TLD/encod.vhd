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
ENTITY ENC IS
	PORT (
		clk : IN STD_LOGIC;
		JA : IN STD_LOGIC_VECTOR (7 DOWNTO 4); -- to the lower row of connector JA
		an : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- controls the display digits
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- controls what digit to display
		Led : OUT STD_LOGIC_VECTOR (1 DOWNTO 0) -- Led indicates the direction the shaft
	);
END ENC;
ARCHITECTURE Behavioral OF ENC IS
	-- signals
	SIGNAL EncO : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL AO, BO : STD_LOGIC;
BEGIN

	U0 : ENTITY work.Debouncer
		PORT MAP(clk => clk, Ain => JA(4), Bin => JA(5), Aout => AO, Bout => BO);

	U1 : ENTITY work.Encoder
		PORT MAP(clk => clk, A => AO, B => BO, BTN => JA(6), EncOut => EncO, LED => Led);

	U2 : ENTITY work.DisplayController
		PORT MAP(clk => clk, SWT => JA(7), DispVal => EncO, anode => an, segOut => seg);

END Behavioral;