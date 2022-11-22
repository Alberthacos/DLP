library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity binary_bcd is
    generic(N: positive := 16);
    port(
        clk, reset: in std_logic;
        DISPLAY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- segmentos del display--"abcdefgP"
        AN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0):="11111111"; -- ánodos del display
        binary_in: in std_logic_vector(0 TO N-1);
        bcd0, bcd1, bcd2, bcd3, bcd4: inout std_logic_vector(3 downto 0)
    );
end binary_bcd ;
 
architecture behaviour of binary_bcd is
    type states is (start, shift, done);
    signal state, state_next: states;
 
    signal binary, binary_next: std_logic_vector(N-1 downto 0);
    signal bcds, bcds_reg, bcds_next: std_logic_vector(19 downto 0);
    --output register keep output constant during conversion
    signal bcds_out_reg, bcds_out_reg_next: std_logic_vector(19 downto 0);
    -- need to keep track of shifts
    signal shift_counter, shift_counter_next: natural range 0 to N;
    --------------------------------------------------------------------------------
    SIGNAL contadors : INTEGER RANGE 1 TO 6250 := 1; -- pulso1 de 0.25ms (pro. divisor ánodos)

    -- Declaración de señales de la asignación de U-D-C-UM
    SIGNAL P : STD_LOGIC_VECTOR (19 DOWNTO 0); -- asigna UNI, DEC,CEN, MIL
    SIGNAL UNI, DEC, CEN, MIL, decMIL : STD_LOGIC_VECTOR (3 DOWNTO 0); -- digitos unidades, decenas,millar, decenas millar
    -- centenas y unidad de millar
    -- Declaración de señales de la multiplexación y asignación de U-D-C-UM al display
    SIGNAL SEL : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000"; -- selector de barrido
    SIGNAL D : STD_LOGIC_VECTOR (3 DOWNTO 0); -- sirve para almacenar los valores del display
    SIGNAL SAL_250us : STD_LOGIC;
--------------------------------------------------------------------------------
begin
 
    process(clk, reset)
    begin
        if reset = '1' then
            binary <= (others => '0');
            bcds <= (others => '0');
            state <= start;
            bcds_out_reg <= (others => '0');
            shift_counter <= 0;
        elsif falling_edge(clk) then
            binary <= binary_next;
            bcds <= bcds_next;
            state <= state_next;
            bcds_out_reg <= bcds_out_reg_next;
            shift_counter <= shift_counter_next;
        end if;
    end process;
 
    convert:
    process(state, binary, binary_in, bcds, bcds_reg, shift_counter)
    begin
        state_next <= state;
        bcds_next <= bcds;
        binary_next <= binary;
        shift_counter_next <= shift_counter;
 
        case state is
            when start =>
                state_next <= shift;
                binary_next <= binary_in;
                bcds_next <= (others => '0');
                shift_counter_next <= 0;
            when shift =>
                if shift_counter = N then
                    state_next <= done;
                else
                    binary_next <= binary(N-2 downto 0) & 'L';
                    bcds_next <= bcds_reg(18 downto 0) & binary(N-1);
                    shift_counter_next <= shift_counter + 1;
                end if;
            when done =>
                state_next <= start;
        end case;
    end process;
 
    bcds_reg(19 downto 16) <= bcds(19 downto 16) + 3 when bcds(19 downto 16) > 4 else
                              bcds(19 downto 16);
    bcds_reg(15 downto 12) <= bcds(15 downto 12) + 3 when bcds(15 downto 12) > 4 else
                              bcds(15 downto 12);
    bcds_reg(11 downto 8) <= bcds(11 downto 8) + 3 when bcds(11 downto 8) > 4 else
                             bcds(11 downto 8);
    bcds_reg(7 downto 4) <= bcds(7 downto 4) + 3 when bcds(7 downto 4) > 4 else
                            bcds(7 downto 4);
    bcds_reg(3 downto 0) <= bcds(3 downto 0) + 3 when bcds(3 downto 0) > 4 else
                            bcds(3 downto 0);
 
    bcds_out_reg_next <= bcds when state = done else
                         bcds_out_reg;
 
    bcd4 <= bcds_out_reg(19 downto 16);
    bcd3 <= bcds_out_reg(15 downto 12);
    bcd2 <= bcds_out_reg(11 downto 8);
    bcd1 <= bcds_out_reg(7 downto 4);
    bcd0 <= bcds_out_reg(3 downto 0);
 





   -------------------DIVISOR ÁNODOS-------------------
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
END PROCESS; -- fin del proceso Divisor Ánodos

--------------------MULTIPLEXOR---------------------
PROCESS (SAL_250us, sel, UNI, DEC, CEN, MIL)
BEGIN
   IF SAL_250us'EVENT AND SAL_250us = '1' THEN
       SEL <= SEL + '1';
       CASE(SEL) IS
           WHEN "000" => AN <= "01111111"; D <= bcd4; -- UNIDADES
           WHEN "001" => AN <= "10111111"; D <= bcd3; -- DECENAS
           WHEN "010" => AN <= "11011111"; D <= bcd2; -- CENTENAS
           WHEN "011" => AN <= "11101111"; D <= bcd1; -- UNIDAD DE MILLAR
           WHEN "100" => AN <= "11110111"; D <= bcd0; -- decenas DE MILLAR

           WHEN OTHERS => AN <= "11110111"; D <= bcd0; -- UNIDAD DE MILLAR
       END CASE;
   END IF;
END PROCESS; -- fin del proceso Multiplexor

--------------------DISPLAY---------------------
PROCESS (D)
BEGIN
   CASE(D) IS -- abcdefgP
       WHEN "0000" => DISPLAY <= "00000011"; --0
       WHEN "0001" => DISPLAY <= "10011111"; --1
       WHEN "0010" => DISPLAY <= "00100101"; --2
       WHEN "0011" => DISPLAY <= "00001101"; --3
       WHEN "0100" => DISPLAY <= "10011001"; --4
       WHEN "0101" => DISPLAY <= "01001001"; --5
       WHEN "0110" => DISPLAY <= "01000001"; --6
       WHEN "0111" => DISPLAY <= "00011111"; --7
       WHEN "1000" => DISPLAY <= "00000001"; --8
       WHEN "1001" => DISPLAY <= "00001001"; --9
       WHEN OTHERS => DISPLAY <= "11111111"; --apagado
   END CASE;
END PROCESS; -- fin del proceso Display
------------------------------------------------













end behaviour;
