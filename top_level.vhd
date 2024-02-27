library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity top_level is
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
		--to on board LCD
      LCD_EN      : out std_logic;
      LCD_RS      : out std_logic;
      LCD_DATA    : out std_logic_vector(7 downto 0);
		--should be tied to a value
		LCD_RW      : out std_logic:='0'; --low
      LCD_ON      : out std_logic:='1'; --high
      LCD_BACKLIGHT    : out std_logic:='0'; --high
		--PWM
		PWM_out : out std_logic
		);
end top_level;

architecture Structural of top_level is


	component univ_bin_counter is
		generic(N: integer := 8; N2: integer := 255; N1: integer := 0);
		port(
			clk, reset					: in std_logic;
			syn_clr, load, en, up	: in std_logic;
			clk_en 						: in std_logic := '1';			
			d								: in std_logic_vector(N-1 downto 0);
			max_tick, min_tick		: out std_logic;
			q								: out std_logic_vector(N-1 downto 0)		
		);
	end component;

	component clk_enabler is
		 GENERIC (
			 CONSTANT cnt_max : integer := 49999999);      --  1.0 Hz 	
		 PORT(	
			clock						: in std_logic;	 
			clk_en					: out std_logic
		);
	end component;
	

	component Reset_Delay IS	
		 PORT (
			  SIGNAL iCLK 		: IN std_logic;	
			  SIGNAL oRESET 	: OUT std_logic
				);	
	end component;	
	
	component btn_debounce_toggle is
		GENERIC(
			CONSTANT CNTR_MAX : std_logic_vector(15 downto 0) := X"FFFF");  
		Port( 
			BTN_I 	: in  STD_LOGIC;
         CLK 		: in  STD_LOGIC;
         BTN_O 	: out  STD_LOGIC;
         TOGGLE_O : out  STD_LOGIC;
		   PULSE_O  : out STD_LOGIC);
	end component;
	
	component State_Machine is 
		Port ( clk : in STD_LOGIC; 
           clk_en : in STD_LOGIC; 
           rst : in STD_LOGIC; 
			  BTN1: in std_logic;
			  BTN0: in std_logic;
           --keys : in STD_LOGIC_VECTOR(3 downto 0); 
           --data_valid_pulse : in STD_LOGIC; 
           counter : in STD_LOGIC_VECTOR(7 downto 0); 
           state : out STD_LOGIC_VECTOR(3 downto 0)
			  ); 
	end component; 
	
	component lcdController IS 
	PORT(
		clk       : IN    STD_LOGIC;                     --system clock
		reset_n   : IN    STD_LOGIC;
		run_clk   : IN integer range 0 to 2;
		adc_sel   : IN integer range 0 to 4;
		sda       : inout std_logic;                     --i2c data
		scl       : inout std_logic                      --i2c clock
    );                   
	END component;
	
--
--
--component LCD_Protocol is
--    generic( constant FREQ : integer:= 208335);
--  Port (
--  clk: in std_logic;     --system clock
--  reset: in std_logic;      --reset signal
--  InputData: in std_logic_vector(15 downto 0);
--  addrIN: in std_logic_vector(7 downto 0);
--  state: in std_logic_vector(2 downto 0);
--  freq_STATE: in std_logic_vector(1 downto 0);
--    Prev_state: out std_logic_vector(2 downto 0);
--  oLCD_data : out std_logic_vector(7 downto 0);
--  oLCD_en: out std_logic;
--  oLCD_rs: out std_logic;
--  oLCD_RW      : out std_logic:='0'; --low
--  oLCD_ON      : out std_logic:='1'; --high
--  oLCD_BACKLIGHT    : out std_logic:='1' --high
--   );
--end component;


--
--component PWM_Module is
--    Port ( clk : in STD_LOGIC;
--           reset: in STD_LOGIC;
--			  freq_state: in std_logic_vector(1 downto 0); --freq_select
--			  Data: in std_logic_vector(7 downto 0); 	--data in from sram/rom
--			  PWM_pulse: out STD_LOGIC
--			  );
--end component;
--
--component usr_logic is
--port( clk : 	in std_logic;
--		iData:   in std_logic_vector(15 downto 0); -- := X"abcd";
--
--		oSDA: 	inout Std_logic;
--		oSCL:		inout std_logic);
--
--end component;





	signal reset_d							: std_logic;
   signal Counter_Reset        		: std_logic;	
	signal clock_enable_60ns,clock_enable_60ns_D_FF,clock_enable_60ns_D_FF_2			: std_logic;
	signal clock_enable_1sec			: std_logic;
	signal KEY0_db,KEY1_db,KEY2_db,KEY3_db 						: std_logic;
	signal Qc								: std_logic_vector(7 downto 0); -- counter output
	signal Qr								: std_logic_vector(15 downto 0); -- Rom output
	signal mux_output_clken				: std_logic;
	signal mux_select_up					: std_logic_vector(1 downto 0);
	signal mux_output_up					: std_logic;
	signal mux_select_en					: std_logic;--: std_logic_vector(1 downto 0);
	signal mux_output_en					: std_logic;
	signal mux_select_clken				: std_logic_vector(1 downto 0);
	signal mux_select_pulse				: std_logic_vector(2 downto 0);
	signal mux_output_pulse				: std_logic;
	
	signal Qstate							: std_logic_vector(3 downto 0);
	
	signal OUTPUT_DATA_addrShift,OUTPUT_DATA_Datashift	: std_logic_vector(3 downto 0):= "0000";
	signal mux_select_RW					: std_logic;--: std_logic_vector(1 downto 0);
	signal mux_output_RW					: std_logic;
	signal sig_ceOUT, sig_ub, sig_lb: std_logic;
	signal mux_select_datain			: std_logic_vector(2 downto 0);
	signal mux_output_datain			: std_logic_vector(15 downto 0);
	signal NOT_KEY0_db 					: std_logic;
	signal AFTERSHIFT_DATA 				: std_LOGIC_VECTOR(15 downto 0);
	signal AFTERSHIFT_ADDR,mux_data_SRAM				: std_LOGIC_VECTOR(7 downto 0);
	signal AFTERSHIFT						: std_logic_vector(15 downto 0);
	signal clockEN5ms_sig,clockPulse5ms_sig,pulse_20ns_sig :  std_logic;
	signal OUTPUT_DATA : std_logic_vector(4 downto 0);
	signal clockEN5ms_sig_data,clockEN5ms_sig_addr: std_logic;
	signal mux_output_addrin,addr_from_DDS: std_logic_vector(7 downto 0);
	signal max_tick_sig: std_logic;
	signal SRAM_addr2SRAM_sig: std_logic_vector(19 downto 0);
	signal KeyMaster: std_lOGIC_VECTOR(3 downto 0);
	signal freq_select: std_logic_vector(1 downto 0);
	signal PWM_freq: std_logic;
	signal mux_output_I2C : std_logic_vector(15 downto 0);
	signal mux_output_select_input     : integer range 0 to 4;
	signal mux_output_select_run_clk   : integer range 0 to 2;
	
	begin
	
	KeyMaster<= not KEY3_db &  not KEY2_db & not KEY1_db &  KEY0_db;  --maybe create from the debounced signals
					--"3210"

	
--	
--	-- rw mux
--	mux_select_RW <= Qstate(2);
--	process(mux_select_RW,OUTPUT_DATA) 
--	begin 
--    case mux_select_RW is
--        when '0' =>
--            mux_output_RW <= '0'; --write
--        when '1' =>
--					mux_output_RW <= '1'; --reading
--		  when others =>
--            mux_output_RW <= '1'; --reading
--    end case;
--	end process;
	mux_select_en <= Qstate(1);

	mux_select_clken <= Qstate(2 downto 1);
	process(mux_select_clken) 
	begin 
    case mux_select_clken is
        when "01" =>
            mux_output_clken <= clock_enable_60ns;		--initializing and PWM moode
				--mux_output_I2C <= X"0000"; --display zeros to I2C when not in test mode
        when "11" =>
            mux_output_clken <= clock_enable_1sec; 	--test mode
				--mux_output_I2C<=disp_DATAOUT;--display SSRAM data to I2C when in test mode
        when others =>
            mux_output_clken <= '0';
    end case;
	end process;
--	

	
	

	process(Qstate) 
	begin 
    case Qstate is
        when "1001" =>		--LDR
				mux_output_select_input <= 0;
				mux_output_select_run_clk<= 0;
		  when "1010" =>		--TEMP
				mux_output_select_input <= 1;		
				mux_output_select_run_clk<= 0;
		  when "1011" =>		--POT
				mux_output_select_input <= 2;		
				mux_output_select_run_clk<= 0;
			when "1100" =>		--ANALOG
				mux_output_select_input <= 3;		
				mux_output_select_run_clk<= 0;
		   when others =>		
    end case;
	end process;
	
 Counter_Reset <= reset_d; --or max_tick_sig; -- or  not KEY0_db NEED TO RESET after intialization

			
	Inst_clk_Reset_Delay: Reset_Delay	
			port map(
			  iCLK 		=> iClk,	
			  oRESET    => reset_d
			);			

	Inst_clk_enabler1sec: clk_enabler
			generic map(
			cnt_max 		=> 49999999)
			port map( 
			clock 		=> iClk, 			--  from system clock
			clk_en 		=> clock_enable_1sec  
			);
			
	Inst_clk_enabler60ns: clk_enabler
			generic map(
			cnt_max 		=> 2) -- 833333 or 3000
			port map( 
			clock 		=> iClk, 			
			clk_en 		=> clock_enable_60ns  
			);	
			
	Inst_univ_bin_counter: univ_bin_counter
		generic map(N => 8, N2 => 255, N1 => 0)
		port map(
			clk 			=> iClk,
			reset 		=> Counter_Reset,
			syn_clr		=>  '0', 
			load			=> '0', 
			en				=> '1', --pause or stop
			up				=> '1', --up
			clk_en 		=> clock_enable_60ns, --mux_select_clken
			d				=> (others => '0'),
			max_tick		=> open, 
			min_tick 	=> open,
			q				=> Qc 
		);

	inst_KEY0: btn_debounce_toggle
		GENERIC MAP( CNTR_MAX => X"FFFF") -- use X"FFFF" for implementation
		Port Map(
			BTN_I => BTN0,
			CLK => iClk,
			BTN_O => open,
			TOGGLE_O => open,
			PULSE_O => KEY0_db);
	inst_KEY1: btn_debounce_toggle
		GENERIC MAP( CNTR_MAX => X"FFFF") -- use X"FFFF" for implementation
		Port Map(
			BTN_I => BTN1,
			CLK => iClk,
			BTN_O => open,
			TOGGLE_O => open,
			PULSE_O => KEY1_db);
--	inst_KEY2: btn_debounce_toggle
--		GENERIC MAP( CNTR_MAX => X"FFFF") -- use X"FFFF" for implementation
--		Port Map(
--			BTN_I => KEY2,
--			CLK => iClk,
--			BTN_O => open,
--			TOGGLE_O => open,
--			PULSE_O => KEY2_db);
--	inst_KEY3: btn_debounce_toggle
--		GENERIC MAP( CNTR_MAX => X"FFFF") -- use X"FFFF" for implementation
--		Port Map(
--			BTN_I => KEY3,
--			CLK => iClk,
--			BTN_O => open,
--			TOGGLE_O => open,
--			PULSE_O => KEY3_db);			

		
	Inst_State_Machine: State_Machine
		port map(
			 clk 			=> iClk,
          clk_en 		=> '1',
          rst 			=> Counter_Reset,
          BTN0  =>  not KEY0_db,
			 BTN1  =>  not KEY1_db,
          --data_valid_pulse => clockEN5ms_sig,
          state => Qstate,
			 counter => Qc	 
			);
			
	Inst_lcdController: lcdController
	PORT MAP(
		clk => iClk,                    --system clock
		reset_n => '1',
		run_clk => mux_output_select_run_clk,
		adc_sel => mux_output_select_input,
		sda  => SDA,                    --i2c data
		scl => SCL                --i2c clock
    );                   


--
--
--	--DETERMINE PWM freq state
--	 select_PWM_FREQ_STATE: process(iClk, Qstate)
--	 begin	
--			if rising_edge(iClk) then
--				if Qstate = "111" then
--				case freq_select is
--				when "00" => --60 Mhz
--					mux_data_SRAM<=disp_DATAOUT(15 downto 8);
--					if keyMaster(3)='0' then
--						freq_select <= "01"; -- to 120 Mhz
--					end if;
--				when "01" => --120 Mhz
--					mux_data_SRAM<=disp_DATAOUT(15 downto 8);
--					if keyMaster(3)='0' then
--						freq_select <= "10"; -- to 1000 Mhz
--					end if;
--				when "10" => --1000 Mhz
--					mux_data_SRAM<="00"&disp_DATAOUT(15 downto 10);
--					if keyMaster(3)='0' then
--						freq_select <= "00"; -- to 60 Mhz
--					end if;
--				when others =>
--					freq_select <= "00"; --60 Mhz
--			end case;
--				else 
--				freq_select<="00";
--			end if;
--			end if;
--		end process;
--
--Inst_LCD_Protocol: LCD_Protocol 
--    generic map(  FREQ => 208335)
--  Port map(
--  clk =>iCLK,
--  reset => reset_d,      --reset signal
--  InputData=> disp_DATAOUT, --data to display out
--  addrIN=>SRAM_addr2SRAM_sig(7 downto 0),
--  state => Qstate,
--  freq_STATE=>freq_select,
--  prev_state=> open,
--  oLCD_data=>LCD_DATA,
--  oLCD_en=> LCD_EN,
--  oLCD_rs=> LCD_RS,
--  oLCD_RW=> LCD_RW,
--  oLCD_ON=> LCD_ON,
--  oLCD_BACKLIGHT=> LCD_BACKLIGHT
--   );
--	
--
--			  
--Inst_PWM_Module: PWM_Module
--    Port map ( clk=>iCLK,
--           reset=>reset_d,
--			  freq_state=>freq_select,	--freq_select to show state of freqency
--			  Data=>mux_data_SRAM,	--data in from sram/rom truncated to 8 bits
--			  PWM_pulse=>PWM_out --to port
--			  );

	 

end Structural;
