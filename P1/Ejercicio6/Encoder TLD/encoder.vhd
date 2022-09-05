----------------------------------------------------------------------------------------------------------------------------------
-- Module Name: Encoder - Behavioral (Encoder.vhd), component C1
-- Project Name: PmodENC
-- Target Devices: Nexys 3
-- This module defines a component Encoder with a state machine that reads
-- the position of the shaft relative to the starting position.
----------------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Encoder IS
    PORT (
        clk : IN STD_LOGIC;
        -- signals from the pmod
        A : IN STD_LOGIC;
        B : IN STD_LOGIC;
        BTN : IN STD_LOGIC;
        -- position of the shaft
        EncOut : INOUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        -- direction indicator
        LED : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
END Encoder;
ARCHITECTURE Behavioral OF Encoder IS
    -- FSM states and signals
    TYPE stateType IS (idle, R1, R2, R3, L1, L2, L3, add, sub);
    SIGNAL curState, nextState : stateType;
BEGIN
    --clk and button
    clock : PROCESS (clk, BTN)
    BEGIN
        -- if the rotary button is pressed the count resets
        IF (BTN = '1') THEN
            curState <= idle;
            EncOut <= "00000";
        ELSIF (clk'event AND clk = '1') THEN
            -- detect if the shaft is rotated to right or left
            -- right: add 1 to the position at each click
            -- left: subtract 1 from the position at each click
            IF curState /= nextState THEN
                IF (curState = add) THEN
                    IF EncOut < "01111" THEN
                        EncOut <= EncOut + 1;
                    ELSE
                        EncOut <= "00000";
                    END IF;
                ELSIF (curState = sub) THEN
                    IF EncOut > "00000" THEN
                        EncOut <= EncOut - 1;
                    ELSE
                        EncOut <= "01111";
                    END IF;
                ELSE
                    EncOut <= EncOut;
                END IF;

            ELSE
                EncOut <= EncOut;
            END IF;
            curState <= nextState;
        END IF;
    END PROCESS;
    -----FSM process
    next_state : PROCESS (curState, A, B)
    BEGIN
        CASE curState IS
                --detent position
            WHEN idle =>
                LED <= "00";
                IF B = '0' THEN
                    nextState <= R1;
                ELSIF A = '0' THEN
                    nextState <= L1;
                ELSE
                    nextState <= idle;
                END IF;
                -- start of right cycle
                --R1
            WHEN R1 =>
                LED <= "01";
                IF B = '1' THEN
                    nextState <= idle;
                ELSIF A = '0' THEN
                    nextState <= R2;
                ELSE
                    nextState <= R1;
                END IF;
                --R2
            WHEN R2 =>
                LED <= "01";
                IF A = '1' THEN
                    nextState <= R1;
                ELSIF B = '1' THEN
                    nextState <= R3;
                ELSE
                    nextState <= R2;
                END IF;
                --R3
            WHEN R3 =>
                LED <= "01";
                IF B = '0' THEN
                    nextState <= R2;
                ELSIF A = '1' THEN

                    nextState <= add;
                ELSE
                    nextState <= R3;
                END IF;
            WHEN add =>
                LED <= "01";
                nextState <= idle;
                -- start of left cycle
                --L1
            WHEN L1 =>
                LED <= "10";
                IF A = '1' THEN
                    nextState <= idle;
                ELSIF B = '0' THEN
                    nextState <= L2;
                ELSE
                    nextState <= L1;
                END IF;
                --L2
            WHEN L2 =>
                LED <= "10";
                IF B = '1' THEN
                    nextState <= L1;
                ELSIF A = '1' THEN
                    nextState <= L3;
                ELSE
                    nextState <= L2;
                END IF;
                --L3
            WHEN L3 =>
                LED <= "10";
                IF A = '0' THEN
                    nextState <= L2;
                ELSIF B = '1' THEN
                    nextState <= sub;
                ELSE
                    nextState <= L3;
                END IF;
            WHEN sub =>
                LED <= "10";
                nextState <= idle;
            WHEN OTHERS =>
                LED <= "11";
                nextState <= idle;
        END CASE;
    END PROCESS;
END Behavioral;