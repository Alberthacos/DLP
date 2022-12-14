
-- 
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ADCcompleto IS
  GENERIC(
    sys_clk_freq     : INTEGER := 50_000_000;                      --input clock speed from user logic in Hz
    temp_sensor_addr : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1001000"); --I2C address of the temp sensor pmod
  PORT(
    clk         : IN    STD_LOGIC;                                 --system clock
    reset_n     : IN    STD_LOGIC;                                 --asynchronous active-low reset
    scl         : INOUT STD_LOGIC;                                 --I2C serial clock
    sda         : INOUT STD_LOGIC;                                 --I2C serial data
    i2c_ack_err : OUT   STD_LOGIC;                                 --I2C slave acknowledge error flag
    val         : OUT   STD_LOGIC_VECTOR(15 DOWNTO 0));            --val value obtained
END ADCcompleto;

ARCHITECTURE behavior OF ADCcompleto IS
  TYPE machine IS(start, set_resolution, pause, read_data, output_result); --needed states
  SIGNAL state       : machine;                       --state machine
  SIGNAL i2c_ena     : STD_LOGIC;                     --i2c enable signal
  SIGNAL i2c_addr    : STD_LOGIC_VECTOR(6 DOWNTO 0);  --i2c address signal
  SIGNAL i2c_rw      : STD_LOGIC;                     --i2c read/write command signal
  SIGNAL i2c_data_wr : STD_LOGIC_VECTOR(7 DOWNTO 0);  --i2c write data
  SIGNAL i2c_data_rd : STD_LOGIC_VECTOR(7 DOWNTO 0);  --i2c read data
  SIGNAL i2c_busy    : STD_LOGIC;                     --i2c busy signal
  SIGNAL busy_prev   : STD_LOGIC;                     --previous value of i2c busy signal
  SIGNAL temp_data   : STD_LOGIC_VECTOR(31 DOWNTO 0); --val data buffer

  COMPONENT i2c_master IS
    GENERIC(
     input_clk : INTEGER;  --input clock speed from user logic in Hz
     bus_clk   : INTEGER); --speed the i2c bus (scl) will run at in Hz
    PORT(
     clk       : IN     STD_LOGIC;                    --system clock
     reset_n   : IN     STD_LOGIC;                    --active low reset
     ena       : IN     STD_LOGIC;                    --latch in command
     addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
     rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
     data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
     busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
     data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
     ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
     sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
     scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
  END COMPONENT;

BEGIN

  --instantiate the i2c master
  i2c_master_0:  i2c_master
    GENERIC MAP(input_clk => sys_clk_freq, bus_clk => 400_000)
    PORT MAP(clk => clk, reset_n => reset_n, ena => i2c_ena, addr => i2c_addr,
             rw => i2c_rw, data_wr => i2c_data_wr, busy => i2c_busy,
             data_rd => i2c_data_rd, ack_error => i2c_ack_err, sda => sda,
             scl => scl);

  PROCESS(clk, reset_n)
    VARIABLE busy_cnt : INTEGER RANGE 0 TO 3 := 0;               --counts the busy signal transistions during one transaction
    VARIABLE counter  : INTEGER RANGE 0 TO sys_clk_freq/10 := 0; --counts 100ms to wait before communicating
  BEGIN
    IF(reset_n = '0') THEN               --reset activated
      counter := 0;                        --clear wait counter
      i2c_ena <= '0';                      --clear i2c enable
      busy_cnt := 0;                       --clear busy counter
      val <= (OTHERS => '0');      --clear val result output
      state <= start;                      --return to start state
    ELSIF(clk'EVENT AND clk = '1') THEN  --rising edge of system clock
      CASE state IS                        --state machine
      
        --give temp sensor 100ms to power up before communicating
        WHEN start =>
          IF(counter < sys_clk_freq/10) THEN   --100ms not yet reached
            counter := counter + 1;              --increment counter
          ELSE                                 --100ms reached
            counter := 0;                        --clear counter
            state <= set_resolution;             --advance to setting the resolution
          END IF;
      
        --set the resolution of the val data to 16 bits
        WHEN set_resolution =>            
          busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
          IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
            busy_cnt := busy_cnt + 1;                    --counts the times busy has gone from low to high during transaction
          END IF;

          CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
            WHEN 0 =>                                    --no command latched in yet
              i2c_ena <= '1';                              --initiate the transaction
              i2c_addr <= temp_sensor_addr;                    --set the address of the ADC
              i2c_rw <= '0';                                 --command 0 is a write
              i2c_data_wr <= "00000001";   --acceso a config reg                --send the address (x03) of the Configuration Register, reg conversion
            WHEN 1 => 
                i2c_data_wr <= "11000000";   --config bits 15-8                --send the address (x03) of the Configuration Register, reg conversion
                  --(15-OS// 14-12 multiplexor // 11-9 ganancia // 8 modo operacion )
            WHEN 2 => 
              i2c_data_wr <= "00000011";   --config bits 7-0                --send the address (x03) of the Configuration Register, reg conversion
            WHEN 3 =>                                    --2nd busy high: command 2 latched
              i2c_ena <= '0';                         --deassert enable to stop transaction after command 2
              IF(i2c_busy = '0') THEN                      --transaction complete
              busy_cnt := 0;                               --reset busy_cnt for next transaction
              state <= read_data;  
              END IF;
            WHEN OTHERS => NULL;
          END CASE;
          
        --pause 1.3us between transactions
        WHEN pause =>
          IF(counter < sys_clk_freq/769_000) THEN  --1.3us not yet reached
            counter := counter + 1;                  --increment counter
          ELSE                                     --1.3us reached
            counter := 0;                            --clear counter
            state <= set_resolution;                      --reading val data
          END IF;
			 
        --read ambient val data
        WHEN read_data =>
          busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
          IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
            busy_cnt := busy_cnt + 1;                    --counts the times busy has gone from low to high during transaction
          END IF;

          CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on

          WHEN 0 =>                                    --no command latched in yet
          i2c_ena <= '1';                              --initiate the transaction
          i2c_addr <= temp_sensor_addr;                --set the address of the temp sensor
          i2c_rw <= '0';                               --command 1 is a write
          i2c_data_wr <= "00000000";                   --send the address (x00) of the Temperature Value MSB Register
          
          WHEN 1 =>
          i2c_rw <= '1';                               --command 1 is a write
                                                       --2nd busy high: command 2 latched, okay to issue command 3
          WHEN 2 =>                                    --2nd busy high: command 2 latched, okay to issue command 3
          IF(i2c_busy = '0') THEN                      --indicates data read in command 2 is ready
            temp_data(15 DOWNTO 8) <= i2c_data_rd;       --retrieve MSB data from command 2
          END IF;

          WHEN 3 =>                                    --3rd busy high: command 3 latched
          i2c_ena <= '0';                              --deassert enable to stop transaction after command 3
          IF(i2c_busy = '0') THEN                      --indicates data read in command 3 is ready
          temp_data(7 DOWNTO 0) <= i2c_data_rd;        --retrieve LSB data from command 3
          busy_cnt := 0;                               --reset busy_cnt for next transaction
          state <= output_result;                      --advance to output the result
          END IF;

            WHEN OTHERS => NULL;
          END CASE;

        --output the val data
        WHEN output_result => 
          val <= temp_data(15 DOWNTO 0);       --write val data to output
          state <= pause;                              --pause 1.3us before next transaction

        --default to start state
        WHEN OTHERS =>
          state <= start;

      END CASE;
    END IF;
  END PROCESS;   
END behavior;
