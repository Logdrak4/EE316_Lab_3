--I2C User logic
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

	ENTITY i2c_usrLogic IS
	  PORT(
		 clk			: IN STD_LOGIC;
		 state : in std_logic_vector(1 downto 0);
		 pulse : in std_logic;
		 data_out 	: out std_logic_vector(7 downto 0);
		 scl			: INOUT STD_LOGIC;
		 sda			: INOUT STD_LOGIC;
		 reset_n : in std_logic
	);             
	END i2c_usrLogic;

-- -----------------------------------------------------------------------------------------------------------------------------------

architecture logic of i2c_usrLogic is

component i2c_master IS
  GENERIC(
    input_clk : INTEGER := 100_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz
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
END component;
-- -----------------------------------------------------------------------------------------------------------------------------------
--type state_type is (start, writing, stop);
--signal state		:state_type;
signal busy_count 		:integer RANGE 0 TO 7 := 0; 
signal i2c_addr: std_logic_vector(6 downto 0);
signal usr_data_wr: std_logic_vector(7 downto 0);
signal i2c_ena,oldBusy,rw  :std_logic;
signal usrbusy : std_logic;
signal control : std_logic_vector(7 downto 0);

-- -----------------------------------------------------------------------------------------------------------------------------------
begin

inst_i2cMaster: i2c_master
generic map(
	input_clk => 50_000_000, --input clock speed from user logic in Hz
	bus_clk 	 => 100_000) 	 --speed the i2c bus (scl) will run at in Hz
port map(
	 clk       =>clk,                   --system clock
    reset_n   =>reset_n,			 --active low reset
    ena       =>i2c_ena,			 --latch in command
    addr      =>i2c_addr, --address of target slave
    rw        =>rw,				--'0' is write, '1' is read (I am writing data ABCD)
    data_wr   =>usr_data_wr, --data to write to slave
    busy      =>usrbusy,--indicates transaction in progress
    data_rd   =>data_out,--data read from slave (e.g. a sensor)
    ack_error =>open,                    --flag if improper acknowledge from slave
    sda       =>sda,--serial data output of i2c bus
    scl       =>scl
);

process(clk)
begin 
if (clk'event and clk = '1') then 
	if reset_n = '0' or pulse = '1' then
		i2c_ena <= '0';
		busy_count <= 0;
		rw <= '0';
		control <= "000000" & state;
	else
		i2c_ena <= '1';
		if usrbusy = '0' and busy_count < 1 and oldBusy = '1' then
			i2c_addr <= "1001000";
			rw <= '0';
			usr_data_wr <= control;
			busy_count <= busy_count + 1;
		elsif usrbusy = '0' and busy_count >= 1 and oldBusy = '1' then	
			i2c_addr <= "1001000";
			rw <= '1';
		end if;
		oldBusy <= usrbusy;
		control <= "000000" & state;
	end if;
end if;
end process;	

end logic;