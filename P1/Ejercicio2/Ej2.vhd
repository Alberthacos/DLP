-- Flip-flop tipo D
-- codigo en VHDL
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY ff_d IS PORT (
    clk : IN STD_LOGIC;
    d   : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    q, q_bar : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END ff_d;

ARCHITECTURE f_d OF ff_d IS
BEGIN
    --siempre que exista un flanco positivo en clk, se asigna d a q
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            q <= d;
            q_bar <= NOT d;
        END IF;
    END PROCESS; --fin del proceso
END f_d; --fin de la arquitectura

--library IEEE;
--use IEEE.std_logic_1164.all;
--
--entity eightBitsRegister is
--    port (
--        valueIn : in std_logic_vector (7 downto 0);
--        valueOut : out std_logic_vector (7 downto 0);
--        reset, clock : in std_logic
--    );
--end entity;
--
--architecture arch_eightBitsRegister of eightBitsRegister is
--begin
--
--    identifier : process (clock)
--    begin
--        if (rising_edge(clock)) then
--            if reset = '1' then
--                valueOut <= "00000000"; 
--            else
--                valueOut <= valueIn;
--            end if;
--        end if;
--    end process;
--
--end architecture;