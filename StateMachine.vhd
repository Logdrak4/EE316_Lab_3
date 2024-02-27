library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity StateMachine is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        KEY1 : in std_logic;
        state_out : out std_logic_vector(1 downto 0); -- 2-bit state output
		  down : buffer std_logic := '0'
    );
end StateMachine;

architecture Behavioral of StateMachine is
    type State_Type is (AIN0, AIN1, AIN2, AIN3);
    signal state, next_state : State_Type;
	-- signal down : BOOLEAN := false;

begin
    -- State transition process
  

    -- Next state logic
    process(state, KEY1, clk, reset)
    begin
	 if reset = '0' then
        state <= AIN0;
	 elsif rising_edge(clk) then
		  if KEY1 = '1' then
				down <= '0';
		  end if;
		  state <= next_state;
        case state is
            when AIN0 =>
                if KEY1 = '0' and down = '0' then -- Assuming active low
                    next_state <= AIN1;
						  down <= '1';
                end if;
					 
            when AIN1 =>
                if KEY1 = '0' and down = '0' then
						  down <= '1';
                    next_state <= AIN2;
                end if;

            when AIN2 =>
                if KEY1 = '0' and down = '0' then
					 	  down <= '1';
                    next_state <= AIN3;
                end if;
				
				when AIN3 =>
					if KEY1 = '0' and down = '0' then
						  down <= '1';
                    next_state <= AIN0;
                -- PWM frequency adjustment logic goes here
                end if;					 
				
        end case;
		  end if;
    end process;

    -- State output logic
    process(state)
    begin
        case state is
            when AIN0 =>
                state_out <= "00";
            when AIN1 =>
                state_out <= "01";
            when AIN2 =>
                state_out <= "10";
            when AIN3 =>
                state_out <= "11";
        end case;
    end process;

end Behavioral;
