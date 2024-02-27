		library IEEE; 

use IEEE.STD_LOGIC_1164.ALL; 

use IEEE.STD_LOGIC_ARITH.ALL; 

use IEEE.STD_LOGIC_UNSIGNED.ALL; 

 

entity State_Machine is 

    Port ( clk : in STD_LOGIC; 
           clk_en : in STD_LOGIC:='1'; 
           rst : in STD_LOGIC; 
			  BTN1: in std_logic;
			  BTN0: in std_logic;
           --keys : in STD_LOGIC_VECTOR(3 downto 0); 
           --data_valid_pulse : in STD_LOGIC; 
           counter : in STD_LOGIC_VECTOR(7 downto 0); 
           state : out STD_LOGIC_VECTOR(3 downto 0)
			  ); 

end State_Machine; 

architecture Behavioral of State_Machine is 

    type states is (INIT,LDR,TEMP,POT,ANALOG,PWM_Generation); 

    signal current_state, next_state : states; 

    signal state_value : STD_LOGIC_VECTOR(3 downto 0); 
	 
    signal counter_prev : STD_LOGIC_VECTOR(7 downto 0); 	 
	signal power_on_flag: std_logic:='0';
begin 


    process(clk) 

    begin 
    if rising_edge(clk) then 
	 counter_prev <= counter;
	 end if;
	 end process;
 

    process(clk, rst, counter) 

    begin 

        if rst = '1' then 
            current_state <= INIT; 
				power_on_flag<='1';
 
        elsif counter = X"00" and counter_prev = X"FF" then 	--Maybe  why doesnt start at one?
				if power_on_flag = '1' then
					current_state <= LDR; 
					power_on_flag<='0';
				elsif  BTN0='0' then
					current_state <= LDR;
				end if;
	
        elsif rising_edge(clk) and clk_en = '1' then 
		  
        case current_state is 

            when LDR => 
					 if BTN1='0' then 
                    current_state <= TEMP; 
                end if; 
            when TEMP => 
						if BTN1='0'  then 
                    current_state <= POT;
                end if; 
			   when POT => 
						if BTN1='0'  then 
                    current_state <= ANALOG;
                end if; 
				when ANALOG => 
						if BTN1='0'  then 
                    current_state <= LDR;
                end if; 
            when PWM_Generation => 
					--if keys(0)='0' then 
                    --current_state <= INIT;
					--elsif keys(2)='0'  then 
                  --  current_state <= Test;
                --end if; 
            when others => 
                current_state <= INIT;  -- Reset to INIT state if in an unknown state 
        end case; 
        end if;
    end process; 

 

 with current_state select 

    state_value <= "0111" when INIT, 

                   "1001" when LDR, 

                   "1010" when TEMP, 
						 
						 "1011" when POT, 
							
                   "1100" when ANALOG, 

                   "0000" when others;  -- Default value for unknown states 

    state <= state_value;
 

end Behavioral; 

