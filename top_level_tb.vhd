library ieee;
use ieee.std_logic_1164.all;

entity top_level_TB is
end top_level_TB;

architecture testbench of top_level_TB is
    -- Constants
    constant CLK_PERIOD : time := 10 ns;

    -- Signals
    signal iClk       : std_logic := '0';
    signal BTN0     : std_logic;
    signal BTN1     : std_logic;
    signal SCL     :  std_logic;
    signal SDA     :  std_logic;


    -- Component instantiation
    component top_level
        port (
		iClk					: in std_logic;
		--KEY INPUTS
      BTN0 					: in STD_LOGIC;
		BTN1					: in STD_LOGIC;
		--FOR TESTING
		--disp_DATAOUT: buffer std_logic_vector(15 downto 0);
		--to seven segment using IC2
		SDA : inout std_logic;
      SCL : inout std_logic;
		--PWM
		PWM_out : out std_logic
        );
    end component;

begin
    -- DUT instantiation
    uut : top_level
        port map (
 		iClk => iClk,
		--KEY INPUTS
      BTN0 => BTN0,
		BTN1=> BTN1,
		--FOR TESTING
		--disp_DATAOUT: buffer std_logic_vector(15 downto 0);
		--to seven segment using IC2
		SDA => SDA,
      SCL => SCL,
		--PWM
		PWM_out =>open
        );

    -- Clock process
    clk_process : process
    begin
        while now < 1000 ns loop
            iClk <= '0';
            wait for CLK_PERIOD / 2;
            iClk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stimulus : process
    begin
	 
        BTN0 <= '1';
        wait for 20 ns;
        BTN0 <= '0';
        wait for 100 ns;  
		  BTN1<='1';
		  wait for clk_period * 2;
		  --BTN1<='0';
        wait for clk_period * 5;
		  --BTN1<='1';
        wait for clk_period * 5;
		  --BTN1<='0';
		  wait for clk_period * 2;
		  --BTN1<='1';
        wait for clk_period * 5;
		  --BTN1<='0';
        wait for clk_period * 5;

        
        wait;
    end process;

end testbench;
