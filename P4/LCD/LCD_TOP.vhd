--CODIGO PARA CONTROLAR UN LCD CON LA TARJETA AMIBA 2 CON 8 BITS
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity LCD is 
port (
	CLOCK			: in STD_LOGIC;
	LED			: OUT STD_LOGIC_VECTOR(1 downto 0);
	-- signals entrada para debouncer desde encoder fisico
	Ain 			: in STD_LOGIC; 
	Bin 			: in STD_LOGIC;
	--boton para reinicio de contador con encoder.vhd
   BTN 			: in STD_LOGIC; --reset

	--Entradas para LCD
	direccion1,E_direccion		: IN STD_LOGIC; --sw que indica la direccion//sw que habilita el movimiento del display(texto completo)
	REINI 							: IN STD_LOGIC; --boton de reinicio (envia a home el texto)
	LCD_RS 			   			: OUT STD_LOGIC;							--	Comando, escritura
	LCD_RW				    		: OUT STD_LOGIC;							-- LECTURA/ESCRITURA
	LCD_E 				   		: OUT STD_LOGIC;							-- ENABLE
	DATA 				   			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0):="00000000";  -- PINES DATOS
	numeros_encoder				: IN STD_LOGIC --boton para elegir encoder

);
end LCD;

architecture Behavioral of LCD is 
---------------SIGNALS--------------------

	-----SIGNALS FOR DEBOUNCER-----------
	signal sclk						: std_logic_vector (6 downto 0);
	signal sampledA, sampledB 	: std_logic;
	
		-- debounced signals
		---salidas de debouncer util para encoder
	signal 	Aout: STD_LOGIC;
	signal 	Bout: STD_LOGIC;
----------------------------------------------------------------

	------SIGNALS FOR ENCODER---------------
		-- signals from the pmod
	signal	A		   : STD_LOGIC;
	signal	B 			: STD_LOGIC;

	-- FSM states and signals
	type stateType is ( idle, R1, R2, R3, L1, L2, L3, add, sub);
	signal curState, nextState: stateType;
	signal EncOut: integer range 1 to 99:=1;
---------------------------------------

-----SIGNALS FOR LCD---------------
	--signal FSM
	type STATE_TYPE is (
		RST,ST0,ST1,ST2,SET_DEFI,SHOW1,SHOW2,CLEAR,ENTRY,C,A_A,L,M,O,E,T,R,N,I,S,
		desplazamiento,Vacio,CambioFila,decen,unid,limpiarlCD,espacio,dos_puntos,D,Z);
		signal State,Next_State : STATE_TYPE;

		signal CONT1 : STD_LOGIC_VECTOR(23 downto 0) := X"000000"; -- 16,777,216 = 0.33554432 s MAX
		signal CONT2 : STD_LOGIC_VECTOR(4 downto 0) :="00000"; -- 32 = 0.64us
		signal RESET : STD_LOGIC :='0';
		signal READY : STD_LOGIC :='0';
		signal listo : STD_LOGIC:='0';
		signal unidades, decenas: integer range 0 to 9  :=0;
		--signal LCD_numeros_Encoder
		signal numeroD,numeroU: std_logic_vector(7 downto 0);
		signal As,Es,Ls,Cs,Os,M_s,Rs,Espacios,oos	 	  : integer range 0 to 20:=0;

------------------------------------------------
begin


----------------D E B O U N C E R------------------------
deb: process(clock,Aout,Bout)
begin

if clock'event and clock = '1' then
	sampledA <= Ain;
	sampledB <= Bin;
	-- clock is divided to 1MHz
	-- samples every 1uS to check if the input is the same as the sample
	-- if the signal is stable, the debouncer should output the signal
	if sclk = "1100100" then
		-- A	
		if sampledA = Ain then
			Aout <= Ain;
		end if;
		-- B
		if sampledB = Bin then
			Bout <= Bin;
		end if;

		sclk <="0000000";
	else
		sclk <= sclk +1;
	end if;
end if;
A<=Aout;
B<=Bout;
end process;
---------------------END DEBOUNCER------------------

---------------------E N C O D E R----------------
--clk and button
reloj: process (clock, BTN)
begin
    -- if the rotary button is pressed the count resets
    if (BTN='1') then
        curState <= idle;
        EncOut <= 1;
    elsif (clock'event and clock = '1') then
            -- detect if the shaft is rotated to right or left
            -- right: add 1 to the position at each click
            -- left: subtract 1 from the position at each click
            if curState /= nextState then
               if (curState = add) then
                    if EncOut <99 then
                        EncOut <= EncOut+1;
                    else
                        EncOut <= 1;
                    end if;

                elsif (curState = sub) then
                    if EncOut > 1 then
                        EncOut <= EncOut-1;
                    else
                        EncOut <= 99;
                    end if;

                else
                    EncOut <= EncOut;
                end if;

            else
                EncOut <= EncOut;
            end if;
        curState <= nextState;
    end if;
end process;

    -----FSM process
nex_state: process (curState, A, B)
begin
case curState is

    --detent position
    when idle =>
	LED<= "00";
        if B = '0' then
            nextState <= R1;
        elsif A = '0' then
            nextState <= L1;
        else
             nextState <= idle;
        end if;
		  
    -- start of right cycle
    --R1
    when R1 =>
	LED<= "01";
        if B='1' then
            nextState <= idle;
        elsif A = '0' then
            nextState <= R2;
        else
            nextState <= R1;
        end if;

    --R2
    when R2 =>
	LED<= "01";
        if A ='1' then
            nextState <= R1;
        elsif B = '1' then
            nextState <= R3;
        else
            nextState <= R2;
        end if;

    --R3
    when R3 =>
	LED<= "01";     
        if B ='0' then
            nextState <= R2;
        elsif A = '1' then
            nextState <= add;
        else
            nextState <= R3;
        end if;

    when add =>
	LED<= "01"; 
        nextState <= idle;

        -- start of left cycle
        --L1
    when L1 =>
	LED<= "10";     
        if A ='1' then
            nextState <= idle;
        elsif B = '0' then
            nextState <= L2;
        else
            nextState <= L1;
        end if;
    
        --L2
    when L2 =>
	LED<= "10";  
        if B ='1' then
            nextState <= L1;
        elsif A = '1' then
            nextState <= L3;
        else
            nextState <= L2;
        end if;
    
         --L3
    when L3 =>
	LED<= "10";  
        if A ='0' then
            nextState <= L2;
        elsif B = '1' then
            nextState <= sub;
        else
            nextState <= L3;
        end if;

    when sub =>
	LED<= "10";
        nextState <= idle;

    when others =>
	LED<= "11";
        nextState <= idle;
end case;

end process;
---------------------END ENCODER------------------

------------------LCD-----------------------
-------------------------------------------------------------------
--Contador de Retardos CONT1--
process(CLOCK,RESET)
begin
	if RESET='1' then CONT1 <= (others => '0');
	elsif CLOCK'event and CLOCK='1' then CONT1 <= CONT1 + 1;
	end if;
end process;
-------------------------------------------------------------------
--Contador para Secuencias CONT2--
process(CLOCK,READY)
begin
	if CLOCK='1' and CLOCK'event then
		if READY='1' then CONT2 <= CONT2 + 1;
		else CONT2 <= "00000";
		end if;
	end if;
end process;
-------------------------------------------------------------------
--Actualizaci?n de estados--
process (CLOCK, Next_State)
begin
	if CLOCK='1' and CLOCK'event then State <= Next_State;
end if;
end process;
------------------------------------------------------------------
process(CONT1,CONT2,State,CLOCK,REINI,listo,E_direccion,direccion1,numeros_encoder)
begin

if listo = '1' then 	--se puede habilitar el movimiento solo si ya se escribio la palabra 
	if numeros_encoder = '0' then 
		if E_direccion ='0' then next_state<=vacio; --texto estatico
		elsif E_direccion = '1' then next_state<=desplazamiento;--marquesina con movimiento
		end if;
	elsif numeros_encoder='1' and E_direccion = '0' then 
		next_state<=clear;
		--LCD_RS<='0';
	end if; 
end if;

 ---CONTROL DE NUMEROS ENCODER

if REINI = '1' THEN Next_State <= RST;
elsif CLOCK='0' and CLOCK'event then
	case State is

		when RST => -- Estado de reset
			if CONT1=X"000000"then --0s
				LCD_RS<='0';
				LCD_RW<='0';
				LCD_E<='0';
				DATA<=x"00";
				Next_State<=ST0;
			else
				Next_State<=ST0;
			end if;
			
		when ST0 => --Primer estado de espera por 25ms (20ms=0F4240=1000000)(15ms=0B71B0=750000)
		---SET 1
			if CONT1=X"2625A0" then -- 2,500,000=50ms
				READY<='1';
				DATA<="00110000"; -- FUNCTION SET 8BITS, 2 LINE, 5X7
				Next_State<=ST0;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=ST1;
			else
				Next_State<=ST0;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when ST1 => --Segundo estado de espera por 5ms --SET2
			if CONT1=X"03D090" then -- 250,000 = 5ms
				READY<='1';
				DATA<="00110000"; -- FUNCTION SET
				Next_State<=ST1;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=ST2;
			else
				Next_State<=ST1;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0


		when ST2 => --Tercer estado de espera por 100us  SET 3
			if CONT1=X"0035E8" then -- 5000 = 100us  = x35E8)
				READY<='1';
				DATA<="00110000"; -- FUNCTION SET
				Next_State<=ST2;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=SET_DEFI;
			else
				Next_State<=ST2;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
				
		when SET_DEFI => --Cuarto paso, se asignan lineas logicas, modo de bits (8) y #caracteres(5x8)
			--SET DEFINITIVO
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="00111000"; -- FUNCTION SET(lineas,caracteres,bits)
				Next_State<=SET_DEFI;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=SHOW1;
				LCD_RS<='0';
			else
				Next_State<=SET_DEFI;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0


		when SHOW1 => --Quinto paso, se apaga el display por unica ocasion
		--SHOW _ APAGAR DISPLAY
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="00001000"; -- SHOW, APAGAR DISPLAY POR UNICA OCASION 
				Next_State<=SHOW1;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				-----CLEAR, LIMPIAR DISPLAY
				Next_State<=CLEAR;
			else
				Next_State<=SHOW1;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
				
		when CLEAR => --SEXTO PASO, SE LIMPIA EL DISPLAY 
		
			if CONT1=X"4C4B40" then 
				READY<='1';
				DATA<="00000001"; -- CLEAR
				Next_State<=CLEAR;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';				
				Next_State<=ENTRY;
				listo<='0';
				As<=0; Es<=0; Ls<=0; Cs<=0; Os<=0; M_s<=0; Rs<=0; Espacios<=0; oos<=0;
			else
				Next_State<=CLEAR;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when ENTRY => --SEPTIMO PASO, CONFIGURAR MODO DE ENTRADA
			--ENTRY MODE
			if CONT1=X"3D090" then --espera por 5ms 250,000
				READY<='1';
				DATA<="00000110"; -- ENTRY MODE, se mueve a la derecha(escritura), no se desplaza(barrido)
				Next_State<=ENTRY;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=SHOW2;
			else
				Next_State<=ENTRY;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
				
		when SHOW2 => --OCTAVO PASO, ENCENDER LA LCD Y CONFIGURAR CURSOR, PARPADEO
		---SHOW DEFINITIVO
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="00001111"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=SHOW2;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				LCD_RS<='1';
				if E_direccion = '0' and numeros_encoder ='1' then Next_State<=c;--decen
				elsif ((E_direccion = numeros_encoder) or( E_direccion = '1' and numeros_encoder ='0')) and listo='0' then 
				Next_State<=C; 
				end if;				
			else
				Next_State<=SHOW2;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
				
		when C => --LETRA C MAYUSCULA
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01000011"; -- C
				Next_State<=C;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				if E_direccion = '0' and numeros_encoder ='1' then Next_State<=O;--decen
				else 
					if Cs=0 then Next_State<=A_A;
					elsif Cs=1 then Next_state<=T;
					elsif Cs=2 then Next_state<=S;
					end if;
					Cs<=Cs+1;
				end if;
			else
				Next_State<=C;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
				
				
		when A_A => --A MAYUSCULA
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01000001"; -- A MAYUSCULA
				Next_State<=A_A;
				
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				if E_direccion = '0' and numeros_encoder ='1' then Next_State<=D;--decen
				else
					if As=0 then 
						Next_State<=L; --c A lamo
					elsif As=1 then 
						Next_State<=M; --calAmo
					elsif As=2 then 
						Next_state<=Espacio; --calamo mora
					elsif As=3 then 
						Next_State<=Z; --l A z
					end if;
					As<=As+1;
				end if;
			else
				Next_State<=A_A;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
				
		when L => --L MAYUSCULA
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01001100"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=L;
				
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';

					if Ls=0 then 
						Next_State<=A_A;	--ca L amo
					elsif Ls=1 then 
						Next_state<=A_A;	--Laz
					elsif Ls=2 then 
						Next_state<=E;	--e L ectronics
					end if;
					Ls<=Ls+1;
			else
				Next_State<=L;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0


		when M => --M MAYUSCULA
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01001101"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=M;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=O;		
			else
				Next_State<=M;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when O => --O MAYUSCULA
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01001111"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=O;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0'; 
				if E_direccion = '0' and numeros_encoder ='1' then 
					if oos = 0 then 	
						Next_State<=N;
					elsif oos =1 then 
						Next_State<=R;
					end if;
					oos<=oos+1;
				else
					if Os = 0 then 
						LCD_RS<='0';
						Next_State<=Espacio;
					elsif Os = 1 then 
						Next_State<=R;
						LCD_RS<='1';
					elsif Os = 2 then 
						Next_State<=n;
						LCD_RS<='1';
					end if;
					Os <= Os+1;
				end if;
			else
				Next_State<=O;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when Espacio => --Espacio
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				LCD_RS<='0';
				DATA<="00010100"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=Espacio;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				LCD_RS<='1'; ---enviar datos
				if Espacios = 0 then 
					Next_State<=M;------ M ora
				elsif Espacios = 1 then 
					Next_state<=L;
				end if;
				Espacios<=Espacios+1;
			else
				Next_State<=Espacio;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when CambioFila => --Cambio Fila
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="11000000"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=CambioFila;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				LCD_RS<='1';
				Next_State<=E;
			else
				Next_State<=CambioFila;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
				
		when E => --E mayuscula
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01000101"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=E;
				
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				LCD_RS<='1';
					if Es=0 then 
						Next_State<=L; -- E lectronics
					elsif Es=1 then 
						Next_State<=C; --el E ctronics
					end if;
					Es<=Es+1;
			else
				Next_State<=E;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when t => --T 
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01010100"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=t;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
					if E_direccion = '0' and numeros_encoder ='1' then Next_State<=A_A;--decen
					else	
					Next_State<=r; 
					end if;
			else
				Next_State<=t;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when r => --r minuscula
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01010010"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=r;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				LCD_RS<='1';
				if E_direccion = '0' and numeros_encoder ='1' then Next_State<=dos_puntos;--decen
				else	
					if Rs = 0 then 
						Next_State<=A_A; --o
					elsif Rs = 1 then 
						Next_State<=O;
					end if;
						Rs<=Rs+1;
				end if;
			else
				Next_State<=r;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0


		when n => --n minuscula
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01001110"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=n;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				if E_direccion = '0' and numeros_encoder ='1' then Next_State<=T;--decen
				else
					Next_State<=i; 
				end if;
			else
				Next_State<=n;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when i => --i
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01001001"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=i;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=c; --
			else
				Next_State<=i;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when s => --s 
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01010011"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=s;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				LCD_RS<='0';
				Next_State<=Vacio; --
				listo<='1';
			else
				Next_State<=s;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when Z => --Z mayuscula
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01011010"; -- SHOW DEFINITIVO, SE ENCIENDE DISPLAY Y CONFIURA CURSOR
				Next_State<=Z;
				
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				LCD_RS<='0';
				Next_State<=CambioFila; -- E lectronics
			else
				Next_State<=Z;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when D => --D 
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="01000100"; --DDDDDD
				Next_State<=D;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=O; 
			else
				Next_State<=D;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when dos_puntos => --:
			if CONT1=X"0009C4" then --espera por 50us 20ns*2500=50us 2500=9C4
				READY<='1';
				DATA<="00111010"; --DDDDDD
				Next_State<=dos_puntos;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=decen; 
			else
				Next_State<=dos_puntos;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		
		when desplazamiento => --desplazamiento
			if CONT1=X"E4E1C0" then --espera por 50ms 20ns*25,000,000=50ms 2500=9C4
				READY<='1';
				DATA<="00011"&direccion1&"00"; -- Envia direccion del desplazamiento
				Next_State<=desplazamiento;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				LCD_RS<='0';
				Next_State<=desplazamiento;
			else
				Next_State<=desplazamiento;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

	


			--modificar rs para enviar datos (1)
		when decen => --DECENAS
			if CONT1=X"0009C4" then --espera por 50ms 20ns*25,000,000=50ms 2500=9C4
				READY<='1';
				DATA<=numeroD; -- RECIBE NUMERO CORRESPONDIENTE A DECENAS
				Next_State<=decen;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=unid;
			else
				Next_State<=decen;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

		when unid => --UNIDADES
			if CONT1=X"0009C4" then --espera por 500ms 20ns*25,000,000=50ms 2500=9C4
				READY<='1';
				DATA<=numeroU; -- RECIBE NUMERO CORRESPONDIENTE A DECENAS
				Next_State<=unid;
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				LCD_RS<='0';
				next_state <= Clear;
				listo<='0';
			else
				Next_State<=unid;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
				
		when Vacio => --Sin ordenes
			if CONT1=X"E4E1C0" then --espera por 500ms 20ns*25,000,000=50ms 2500=9C4
			elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns

			elsif CONT2="1111" then
			else
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
				
		when others => READY<='0';
				LCD_E<='0';
				LCD_RS<='0';			
		end case;
end if;
end process;

numbers: process(clock)
begin
if rising_edge(clock) then 
	case decenas is
		when 0 => numeroD<="00110000";
		when 1 => numeroD<="00110001";
		when 2 => numeroD<="00110010";
		when 3 => numeroD<="00110011";
		when 4 => numeroD<="00110100";
		when 5 => numeroD<="00110101";
		when 6 => numeroD<="00110110";
		when 7 => numeroD<="00110111";
		when 8 => numeroD<="00111000";
		when 9 => numeroD<="00111001";
--		when others numeroU<="00000000"; numeroD<="00000000";
	end case;
	
	case unidades is
		when 0 => numeroU <="00110000";
		when 1 => numeroU <="00110001";
		when 2 => numeroU <="00110010";
		when 3 => numeroU <="00110011";
		when 4 => numeroU <="00110100";
		when 5 => numeroU <="00110101";
		when 6 => numeroU <="00110110";
		when 7 => numeroU <="00110111";
		when 8 => numeroU <="00111000";
		when 9 => numeroU <="00111001";
--		when others numeroU<="00000000"; numeroD<="00000000";
	end case;
	
	----------------------------------
	-----------------------------------
	if EncOut<=9 then 
		decenas <= 0;
		unidades<=EncOut;
	else 
		decenas<=(EncOut/10);
		unidades<=(EncOut-(decenas*10));
	end if;
	------------------------------------
	--------------------------------------
end if;
	end process;

-------------END LCD----------------------
end Behavioral;