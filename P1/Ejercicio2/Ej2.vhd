---- Flip-flop tipo D
---- codigo en VHDL
--LIBRARY ieee;
--USE ieee.std_logic_1164.ALL;
--USE ieee.std_logic_arith.ALL;
--USE ieee.std_logic_unsigned.ALL;
--ENTITY ff_d IS PORT (
--    clk : IN STD_LOGIC;
--    d1 : IN STD_LOGIC;
--    q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
--END ff_d;
--
--ARCHITECTURE f_d OF ff_d IS
--    --signal qq1,qq2,qq3,qq4,qq5,qq6,qq7,qq8 : std_logic; 
--    SIGNAL aux : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
--    -- Declaraci�n de se�ales de los divisores
--    SIGNAL conta_1250us : INTEGER RANGE 1 TO 15000000 := 1; -- pulso1 de 1250us@400Hz (0.25ms)
--    SIGNAL SAL_400Hz : std_logic; -- pulso1 de 1250us@400Hz (0.25ms)
--
--BEGIN
--    q <= aux;
--    --siempre que exista un flanco positivo en clk, se asigna d a q
--    PROCESS (SAL_400Hz)
--    BEGIN
--        IF SAL_400Hz'EVENT AND SAL_400Hz = '1' THEN
--            aux <= d1 & aux(7 DOWNTO 1);
--            --q_bar <= NOT d;
--        END IF;
--    END PROCESS; --fin del proceso
--
--   PROCESS (CLK) BEGIN
--        IF rising_edge(CLK) THEN
--            IF (conta_1250us = 15_000_000) THEN --cuenta 1250us (50MHz=62500)
--                -- if (conta_1250us = 125000) then --cuenta 1250us (100MHz=125000)
--                SAL_400Hz <= NOT(SAL_400Hz); --genera un barrido de 2.5ms
--                conta_1250us <= 1;
--            ELSE
--                conta_1250us <= conta_1250us + 1;
--            END IF;
--        END IF;
--    END PROCESS;
--END f_d; --fin de la arquitectura

library IEEE;
use IEEE.std_logic_1164.all;

entity ff_D is
    port (
        d : in std_logic_vector (7 downto 0);
        q : out std_logic_vector (7 downto 0);
        reset, CLK : in std_logic
    );
end entity;

architecture eightff_d of ff_D is
begin

    identifier : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if reset = '1' then
                q <= "00000000"; 
            else
                q <= d;
            end if;
        end if;
    end process;

end eightff_d;