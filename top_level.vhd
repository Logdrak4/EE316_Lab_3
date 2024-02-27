LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

entity top_level is
	port(
		iClk : in std_logic;
		iReset_n : in std_logic;
		iBTN1 : in std_logic;
		ioSCL, ioSDA : inout std_logic;
		oCLOCK : out std_logic;
		oADC : out std_logic_vector(7 downto 0);
		HEX0        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);		-- Seven Segment Digit 0
      HEX1        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);		-- Seven Segment Digit 1
      HEX2        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
 	);
end top_level;	
	
architecture behavioral of top_level is
	
component i2c_usrLogic IS
  PORT(
	 clk			: IN STD_LOGIC;
	 data_out 	: out std_logic_vector(7 downto 0);
	 state : in std_logic_vector(1 downto 0);
	 pulse : in std_logic;
	 scl			: INOUT STD_LOGIC;
	 sda			: INOUT STD_LOGIC;
	 reset_n : in std_logic
);             
END component;

component BinTo7Seg is
    Port ( iCLK   : in  STD_LOGIC;
           iRST_n   : in  STD_LOGIC;
           iDATA  : in  STD_LOGIC_VECTOR(7 downto 0);
           oSEG0  : out STD_LOGIC_VECTOR(6 downto 0);
           oSEG1  : out STD_LOGIC_VECTOR(6 downto 0);
           oSEG2  : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component StateMachine is
    Port (         
		  clk : in std_logic;
        reset : in std_logic;
        KEY1 : in std_logic;
        state_out : out std_logic_vector(1 downto 0); -- 2-bit state output
		  down : buffer std_logic := '0'
		  );
end component;

component AdjustableClock is
    Port (
        clk_in : in std_logic; -- System clock input (50 MHz)
        data_in : in std_logic_vector(7 downto 0); -- 8-bit input value
        clk_out : out std_logic -- Output clock signal
    );
end component;


signal adc_data : std_logic_vector(7 downto 0);
signal top_state : std_logic_vector(1 downto 0);
signal top_state_pulse : std_logic;

begin

inst_clockgen : AdjustableClock
	port map(
		clk_in => iClk,
		data_in => adc_data,
		clk_out => oCLOCK
	);

inst_i2c_usrLogic : i2c_usrLogic
	port map(
		clk => iClk,
		data_out => adc_data,
		state => top_state,
		pulse => top_state_pulse,
		scl => ioSCL,
		sda => ioSDA,
		reset_n => iReset_n
	);
	
inst_7seg : BinTo7Seg
	port map(
		iCLK => iClk,
		iRST_n => iReset_n,
		iDATA => adc_data,
		oSEG0 => HEX0,
		oSEG1 => HEX1,
		oSEG2 => HEX2
		);
			
inst_sm : StateMachine
	port map(
		clk => iClk,
		reset => iReset_n,
		KEY1 => iBTN1,
		state_out => top_state,
		down => top_state_pulse
	);
	
	
		oADC <= adc_data;
	
end behavioral;
