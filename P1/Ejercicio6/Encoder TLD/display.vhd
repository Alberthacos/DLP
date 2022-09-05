----------------------------------------------------------------------------------------------------------------------------------
-- Module Name: DisplayController - Behavioral (DisplayController.vhd), component C2
-- Project Name: PmodENC
-- Target Devices: Nexys 3
-- This module defines a DisplayController that controls the seven segments display to work with
-- the output of the Encoder
----------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY DisplayController IS
    PORT (
        clk : IN STD_LOGIC;
        --signal from the Pmod
        SWT : IN STD_LOGIC;
        --output from the Encoder
        DispVal : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        --controls the display digits
        anode : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        --controls which digit to display
        segOut : OUT STD_LOGIC_VECTOR (6 DOWNTO 0));
END DisplayController;
ARCHITECTURE Behavioral OF DisplayController IS
    -- signals
    SIGNAL sclk : STD_LOGIC_VECTOR (17 DOWNTO 0);
    SIGNAL seg : STD_LOGIC_VECTOR (6 DOWNTO 0);
BEGIN
    PROCESS (clk, SWT)
    BEGIN
        -- turns off the seven segments display when the switch is off
        --or else turn on the seven segments display
        IF (SWT = '0') THEN
            anode <= "1111";
            --refresh each digit
        ELSIF clk'event AND clk = '1' THEN
            -- 0ms refersh digit 0
            IF sclk = "000000000000000000" THEN
                anode <= "1110";
                segOut <= seg;
                sclk <= sclk + 1;
                -- 1ms refresh digit 1
            ELSIF sclk = "011000011010100000" THEN
                -- display a 1 on the tenth digit if the number is greater than 9

                IF DispVal > "01001" THEN
                    segOut <= "1111001";
                    anode <= "1101";
                END IF;
                sclk <= sclk + 1;
                -- 2ms
            ELSIF sclk = "110000110101000000" THEN
                sclk <= "000000000000000000";
            ELSE
                sclk <= sclk + 1;
            END IF;
        END IF;
    END PROCESS;
    WITH DispVal SELECT
        -- gfedcba
        seg <= "1000000" WHEN "00000", --0
        "1111001" WHEN "00001", --1
        "0100100" WHEN "00010", --2
        "0110000" WHEN "00011", --3
        "0011001" WHEN "00100", --4
        "0010010" WHEN "00101", --5
        "0000010" WHEN "00110", --6
        "1111000" WHEN "00111", --7
        "0000000" WHEN "01000", --8
        "0010000" WHEN "01001", --9
        "1000000" WHEN "01010", --10
        "1111001" WHEN "01011", --11
        "0100100" WHEN "01100", --12
        "0110000" WHEN "01101", --13
        "0011001" WHEN "01110", --14
        "0010010" WHEN "01111", --15
        "0000010" WHEN "10000", --16
        "1111000" WHEN "10001", --17
        "0000000" WHEN "10010", --18
        "0010000" WHEN "10011", --19
        "0111111" WHEN OTHERS;

END Behavioral;