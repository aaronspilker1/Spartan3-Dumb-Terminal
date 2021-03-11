----------------------------------------------------------------------------------
-- Company: Weber State
-- Engineer: Aaron Spilker
-- Module Name:    Cursor_Control - Behavioral 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Cursor_Control is
	port ( clk: in std_logic;
			reset: in std_logic;
			ready : in std_logic;
			clear : out std_logic;
			scroll : out std_logic;
			write_char : out std_logic; 
			row : out std_logic_vector(5 downto 0);
			col : out std_logic_vector(6 downto 0);
			ascii : out std_logic_vector(7 downto 0);
			ascii_data : in std_logic_vector(7 downto 0));
end Cursor_Control;

architecture Behavioral of Cursor_Control is

signal cursor_row: integer range 0 to 47 := 0;
signal cursor_col: integer range 0 to 92 := 0;
constant BS: std_logic_vector(7 downto 0) := "00001000"; --08
constant LF: std_logic_vector(7 downto 0) := "00001010"; --0A
constant FF: std_logic_vector(7 downto 0) := "00001100"; --0C
constant CR: std_logic_vector(7 downto 0) := "00001101"; --0D


begin
ascii <= ascii_data;
scroll <= '1' when ready = '1' and ascii_data = LF and cursor_row = 47 else '0';
clear  <= '1' when ready = '1' and ascii_data = FF else '0';
write_char <= '1' when ready = '1' and ascii_data(7 downto 5) /= "000" else '0';

row <= std_logic_vector(to_unsigned(cursor_row, 6));
col <= std_logic_vector(to_unsigned(cursor_col, 7));

--Cursor Row
process(clk, reset)
begin
	if reset = '1' then
		cursor_row <= 0;
	elsif rising_edge(clk) then
		if ready = '1' then
			if ascii_data = FF then
				cursor_row <= 0;
			elsif ascii_data = LF then
				if cursor_row /= 47 then
					cursor_row <= cursor_row + 1;
				end if;
			end if;
		end if;
	end if;
end process;

--Cursor Col
process(clk, reset)
begin
	if reset = '1' then
		cursor_col <= 0;
	elsif rising_edge(clk) then
		if ready = '1' then
			if ascii_data = FF then
				cursor_col <= 0;
			elsif ascii_data = CR then
				cursor_col <= 0;
			elsif ascii_data = BS and cursor_col /= 0 then
				cursor_col <= cursor_col - 1;
			elsif ascii_data(7 downto 5) /= "000" and cursor_col /= 92 then
				cursor_col <= cursor_col + 1;
			end if;
		end if;
	end if;
end process;

end Behavioral;

