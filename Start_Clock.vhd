

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;




entity Start_Clock is
 Port (
        clock_out_pulse1: out std_logic;
        clock_in: in std_logic 
         );
end Start_Clock;

architecture Behavioral of Start_Clock is
signal counter, counter_prev: unsigned(15 downto 0):=x"0000";
signal clock_pulse_sig: std_logic:='0';
begin

process(clock_in)
begin
    if rising_edge(clock_in) then
            if counter = x"0000" and counter_prev = x"FFFF" then 
                clock_pulse_sig<= not clock_pulse_sig;
                counter <= (others=>'0');
            else
                clock_pulse_sig<= clock_pulse_sig;
                counter <= counter + 1;
            end if;
    end if;
 end process;
 
 clock_out_pulse1<=clock_pulse_sig;
 
end Behavioral;
