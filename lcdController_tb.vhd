----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2024 12:48:21 PM
-- Design Name: 
-- Module Name: top_level - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lcdController_tb is
-- port();    
end lcdController_tb;

architecture Behavioral of lcdController_tb is


COMPONENT lcdController IS
	GENERIC (
		CONSTANT input_clock : integer := 125_000_000); 
	PORT(
		clk       : IN    STD_LOGIC;                     --system clock
		reset_n   : IN    STD_LOGIC;
		run_clk   : IN    STD_LOGIC;  --is the clock on
		adc_sel   : IN    STD_LOGIC_VECTOR(1 DOWNTO 0); 
		sda       : inout std_logic;                     --i2c data
		scl       : inout std_logic                      --i2c clock
    );                   
END COMPONENT;

-- general signals for tb
SIGNAL      clk       : STD_LOGIC := '0';            
SIGNAL		reset_n   : STD_LOGIC := '0';
SIGNAL		run_clk   : STD_LOGIC := '0'; 
SIGNAL		adc_sel   : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
SIGNAL		sda       : std_logic;                     
SIGNAL      scl       : std_logic;   




begin


DUT: lcdController 
	PORT MAP(
		clk       => clk,                             --system clock
		reset_n   => reset_n,
		run_clk   => run_clk,                             --is the clock on
		adc_sel   => adc_sel,                         -- STD_LOGIC_VECTOR(1 DOWNTO 0); 
		sda       => sda,                     
		scl       => scl		                      
    );                   

clk <= not clk after 4 ns; 

process
begin

    wait for 100 ns;
    reset_n <= '1';
    wait for 10 ms;
    
    
wait;
end process;



end Behavioral;
