library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AdjustableClock is
    Port (
        clk_in : in std_logic; -- System clock input (50 MHz)
        data_in : in std_logic_vector(7 downto 0); -- 8-bit input value
        clk_out : out std_logic -- Output clock signal
    );
end AdjustableClock;

architecture Behavioral of AdjustableClock is
    signal counter : integer := 0;
    signal clk_enable : std_logic := '0';
    signal target_count, target_ratio : integer;
	 constant highClock : integer := 66_667; --50,000,000 / 1500 Hz  100_000 - 33_333
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            -- Calculate target count based on input data
            -- Linear interpolation from 500 Hz to 1500 Hz
            --target_ratio <= to_integer(unsigned(data_in));
            --target_ratio <= target_ratio / 255;
				target_count <= 100_000 - to_integer(unsigned(data_in)) * (highClock / 256);
            if counter >= target_count then
                counter <= 0;
                clk_enable <= not clk_enable; -- Toggle the output clock
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk_out <= clk_enable when clk_enable = '1' else '0';
    
end Behavioral;
