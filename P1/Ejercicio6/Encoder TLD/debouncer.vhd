----------------------------------------------------------------------------------------------------------------------------------
-- Module Name: debouncer - Behavioral (Debouncer.vhd), component C0
-- Project Name: PmodENC
-- Target Devices: Nexys 3
-- This file defines a debouncer for eliminating the logic noise presented when the shaft is rotated.
----------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Debouncer IS
	PORT (
		clk : IN STD_LOGIC;
		-- signals from the pmod
		Ain : IN STD_LOGIC;
		Bin : IN STD_LOGIC;
		-- debounced signals
		Aout : OUT STD_LOGIC;
		Bout : OUT STD_LOGIC
	);
END Debouncer;

ARCHITECTURE Behavioral OF Debouncer IS
	-- signals
	SIGNAL sclk : STD_LOGIC_VECTOR (6 DOWNTO 0);
	SIGNAL sampledA, sampledB : STD_LOGIC;
BEGIN

	PROCESS (clk)
	BEGIN

		IF clk'event AND clk = '1' THEN
			sampledA <= Ain;
			sampledB <= Bin;
			-- clock is divided to 1MHz
			-- samples every 1uS to check if the input is the same as the sample
			-- if the signal is stable, the debouncer should output the signal
			IF sclk = "1100100" THEN
				-- A
				IF sampledA = Ain THEN
					Aout <= Ain;
				END IF;
				-- B
				IF sampledB = Bin THEN
					Bout <= Bin;
				END IF;
				sclk <= "0000000";
			ELSE
				sclk <= sclk + 1;
			END IF;
		END IF;
	END PROCESS;
END Behavioral;