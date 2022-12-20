LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.COMANDOS_LCD_REVD.ALL;

ENTITY LIB_LCD_INTESC_REVD IS

    GENERIC (
        FPGA_CLK : INTEGER := 50_000_000
    );

    PORT (
        CLK : IN STD_LOGIC;
        RS : OUT STD_LOGIC; -- 
        RW : OUT STD_LOGIC; -- 
        ENA : OUT STD_LOGIC; -- 
        DATA_LCD : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- 
        --------------ABAJO ESCRIBE TUS PUERTOS-------------------- 
        Temp : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        conta1 : IN INTEGER RANGE 0 TO 7

    );

END LIB_LCD_INTESC_REVD;

ARCHITECTURE Behavioral OF LIB_LCD_INTESC_REVD IS

    CONSTANT NUM_INSTRUCCIONES : INTEGER := 30; --INDICAR EL NÚMERO DE INSTRUCCIONES PARA LA LCD 

    -------------------------SEÑALES DE LA LCD (NO BORRAR)-------------------------- 

    COMPONENT PROCESADOR_LCD_REVD IS -- 

        -- 

        GENERIC (-- 
            FPGA_CLK : INTEGER := 50_000_000; -- 
            NUM_INST : INTEGER := 1 -- 
        ); -- 

        PORT (
            CLK : IN STD_LOGIC; -- 
            VECTOR_MEM : IN STD_LOGIC_VECTOR(8 DOWNTO 0); -- 
            C1A, C2A, C3A, C4A : IN STD_LOGIC_VECTOR(39 DOWNTO 0); -- 
            C5A, C6A, C7A, C8A : IN STD_LOGIC_VECTOR(39 DOWNTO 0); -- 
            RS : OUT STD_LOGIC; -- 
            RW : OUT STD_LOGIC; -- 
            ENA : OUT STD_LOGIC; -- 
            BD_LCD : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- 
            DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- 
            DIR_MEM : OUT INTEGER RANGE 0 TO NUM_INSTRUCCIONES -- 
        ); -- 

        -- 

    END COMPONENT PROCESADOR_LCD_REVD; -- 


    COMPONENT CARACTERES_ESPECIALES_REVD IS -- 
        PORT (
            C1, C2, C3, C4 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0); -- 

            C5, C6, C7, C8 : OUT STD_LOGIC_VECTOR(39 DOWNTO 0) -- 

        ); -- 

        -- 

    END COMPONENT CARACTERES_ESPECIALES_REVD; -- 

    CONSTANT CHAR1 : INTEGER := 1; -- 
    CONSTANT CHAR2 : INTEGER := 2; -- 
    CONSTANT CHAR3 : INTEGER := 3; -- 
    CONSTANT CHAR4 : INTEGER := 4; -- 
    CONSTANT CHAR5 : INTEGER := 5; -- 
    CONSTANT CHAR6 : INTEGER := 6; -- 
    CONSTANT CHAR7 : INTEGER := 7; -- 
    CONSTANT CHAR8 : INTEGER := 8; -- 

    TYPE ram IS ARRAY (0 TO NUM_INSTRUCCIONES) OF STD_LOGIC_VECTOR(8 DOWNTO 0); -- 

    SIGNAL INST : ram := (OTHERS => (OTHERS => '0')); -- 

    SIGNAL blcd : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --                                                                                                      
    SIGNAL vector_mem : STD_LOGIC_VECTOR(8 DOWNTO 0) := (OTHERS => '0'); -- 
    SIGNAL c1s, c2s, c3s, c4s : STD_LOGIC_VECTOR(39 DOWNTO 0) := (OTHERS => '0'); -- 
    SIGNAL c5s, c6s, c7s, c8s : STD_LOGIC_VECTOR(39 DOWNTO 0) := (OTHERS => '0'); -- 
    SIGNAL dir_mem : INTEGER RANGE 0 TO NUM_INSTRUCCIONES := 0; -- 


    ---------------------------AGREGA TUS SEÑALES AQUÍ------------------------------ 

SIGNAL Temperatura : INTEGER RANGE 0 TO 50_000;
SIGNAL UNImil,DECmil,cen : INTEGER RANGE 0 TO 9;

    -------------------------------------------------------------------------------- 

BEGIN

    --------------------------------------------------------------- 

    -------------------COMPONENTES PARA LCD------------------------ 

    u1 : PROCESADOR_LCD_REVD -- 

    GENERIC MAP(
        FPGA_CLK => FPGA_CLK, -- 

        NUM_INST => NUM_INSTRUCCIONES) -- 

    PORT MAP(
        CLK, VECTOR_MEM, C1S, C2S, C3S, C4S, C5S, C6S, C7S, C8S, RS, -- 

        RW, ENA, BLCD, DATA_LCD, DIR_MEM); -- 

        U2 : CARACTERES_ESPECIALES_REVD -- 
    PORT MAP(C1S, C2S, C3S, C4S, C5S, C6S, C7S, C8S); --                                                                                  -- 
    VECTOR_MEM <= INST(DIR_MEM); -- 


    ---------------ESCRIBE TU CÓDIGO PARA LA LCD----------------------- 

    INST(0) <= LCD_INI("00"); -- INICIALIZAMOS LCD, CURSOR A HOME, CURSOR OFF, PARPADEO OFF. 

    INST(1) <= POS(1, 1); -- Ubicar el cursor 

    INST(2) <= CHAR(Mt); -- T 

    INST(3) <= CHAR(e); -- e 

    INST(4) <= CHAR(m); -- m 

    INST(5) <= CHAR(p); -- p 

    INST(6) <= CHAR_ASCII(x"3A"); -- : 

    INST(7) <= CHAR_ASCII(x"20"); -- space 

    INST(8) <= POS(2, 1); -- Ubicar el cursor 

    INST(9) <= CHAR(Mv); -- V 
    INST(10) <= CHAR(e); -- e 
    INST(11) <= CHAR(l); -- l 
    INST(12) <= CHAR(o); -- o 
    INST(13) <= CHAR(c); -- c
    INST(14) <= CHAR(i); -- i 
    INST(15) <= CHAR(d); -- d
    INST(16) <= CHAR(a); -- a 
    INST(17) <= CHAR(d); -- d 
    INST(18) <= CHAR_ASCII(x"3A"); -- : 

    INST(19) <= POS(1, 10); -- Ubicar el cursor 
    INST(20) <= CHAR(MC); -- C (Grados C) 
    INST(21) <= POS(2, 9); -- Ubicar el cursor 

--------------------------------------------------------------------------------
--                  Bucle

    INST(22) <= BUCLE_INI(1);
    INST(23) <= POS(2, 11);
    INST(24) <= INT_NUM((conta1)); --velocidad seleccionada
    INST(25) <= POS(1, 6); 
    INST(26) <= INT_NUM(DECmil); --CHAR_ASCII(CEN_ascii_T);
    INST(27) <= INT_NUM(UNImil); --CHAR_ASCII(dec_ascii_T);
    INST(28) <= INT_NUM(cen); --CHAR_ASCII(uni_ascii_T);
    INST(29) <= BUCLE_FIN(1);
    INST(30) <= CODIGO_FIN(1);

Temperaturascontrol: process(temp)
begin
    Temperatura <= CONV_INTEGER(Temp(14 DOWNTO 0));

    DECmil <= Temperatura/10_000;
    UNImil <= (Temperatura-DECmil*10_000)/1000;
    cen <= (Temperatura-DECmil*10_000-UNImil*1000)/100;

    
end process Temperaturascontrol;

END Behavioral;