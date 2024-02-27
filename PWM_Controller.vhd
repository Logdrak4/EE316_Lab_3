LIBRARY ieee;
   USE ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_unsigned.all;
	
entity PWM_Controller is 
generic (
	N: integer := 8;
	PWM_COUNTER_MAX : integer := 256
 );
port (
	clk : in std_logic;
--	frequencyM : in integer:=0; 
--	PWMstate : in std_logic_vector(3 downto 0);
	iData : in std_logic_vector(N-1 downto 0); -- 8-6 bit data from SRAMtrunc
	rst : in std_logic;
	PWMSCL : out std_logic
);
end PWM_Controller;

Architecture Behavioral OF PWM_Controller is

signal counter : integer := 0;
signal PWMwidth : integer := 0;
--signal PWMstatesig : std_logic_vector(3 downto 0);

begin

process(clk)
begin
if rising_edge(Clk) then
	PWMwidth <= to_integer(unsigned(iData));
	if counter >= 255 - PWMwidth and counter < PWM_COUNTER_MAX then
		PWMSCL <= '1';
		counter <= counter + 1;
	elsif counter >= 255 - PWMwidth and counter >= PWM_COUNTER_MAX then
		PWMSCL <= '0';
		counter <= 0;
	elsif counter < 255 - PWMwidth then
		PWMSCL <= '0';
		counter <= counter + 1;
	end if;
end if;
end process;

end Behavioral;
