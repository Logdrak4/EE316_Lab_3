library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BinTo7Seg is
    Port ( iCLK   : in  STD_LOGIC;
           iRST_n   : in  STD_LOGIC;
           iDATA  : in  STD_LOGIC_VECTOR(7 downto 0);
           oSEG0  : out STD_LOGIC_VECTOR(6 downto 0);
           oSEG1  : out STD_LOGIC_VECTOR(6 downto 0);
           oSEG2  : out STD_LOGIC_VECTOR(6 downto 0));
end BinTo7Seg;

architecture Behavioral of BinTo7Seg is
    signal iData_integer : integer range 0 to 255;
    signal digit0, digit1, digit2 : integer range 0 to 9;
    signal one_second_counter : integer := 0; -- Counter to track 1 second
    constant one_second_value : integer := 10000000; -- 50 MHz clock for 1 second
begin
    process(iCLK, iRST_n)
    begin
        if rising_edge(iCLK) then
            if iRST_n = '0' then
                one_second_counter <= 0;
                iData_integer <= 0;
                digit0 <= 0;
                digit1 <= 0;
                digit2 <= 0;
            else
                if one_second_counter < one_second_value then
                    one_second_counter <= one_second_counter + 1;
                else
                    one_second_counter <= 0; -- Reset counter after 1 second
                    -- Convert binary to integer
                    iData_integer <= to_integer(unsigned(iDATA));
                    -- Extract individual digits
                    digit0 <= iData_integer mod 10;
                    digit1 <= (iData_integer / 10) mod 10;
                    digit2 <= (iData_integer / 100) mod 10;
                end if;
            end if;
        end if;
    end process;
	 
	 oSEG0 <= "1000000" when digit0 = 0 else --0
					"1001111" when digit0 = 1 else --1
					"0100100" when digit0 = 2 else --2
					"0110000" when digit0 = 3 else --3
					"0011001" when digit0 = 4 else --4
					"0010010" when digit0 = 5 else --5
					"0000010" when digit0 = 6 else --6
					"1111000" when digit0 = 7 else --7
					"0000000" when digit0 = 8 else --8
					"0010000" when digit0 = 9 else --9
					"0000000";
					
	 oSEG1 <= "1000000" when digit1 = 0 else --0
					"1001111" when digit1 = 1 else --1
					"0100100" when digit1 = 2 else --2
					"0110000" when digit1 = 3 else --3
					"0011001" when digit1 = 4 else --4
					"0010010" when digit1 = 5 else --5
					"0000010" when digit1 = 6 else --6
					"1111000" when digit1 = 7 else --7
					"0000000" when digit1 = 8 else --8
					"0010000" when digit1 = 9 else --9
					"0000000";
					
	oSEG2 <= "1000000" when digit2 = 0 else --0
					"1001111" when digit2 = 1 else --1
					"0100100" when digit2 = 2 else --2
					"0110000" when digit2 = 3 else --3
					"0011001" when digit2 = 4 else --4
					"0010010" when digit2 = 5 else --5
					"0000010" when digit2 = 6 else --6
					"1111000" when digit2 = 7 else --7
					"0000000" when digit2 = 8 else --8
					"0010000" when digit2 = 9 else --9
					"0000000";

end Behavioral;
