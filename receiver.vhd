--------------------------------------------------------------------------------
-- Company: Weber State
-- Engineer: Aaron Spilker 
-- Module Name:   Y:/Desktop/3610/Lab1/Lab1/receiver.vhd
-- VHDL Test Bench Created by ISE for module: receiver
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity receiver is
port ( clk : in std_logic;                -- clock input, f=50MHz
reset : in std_logic;                     -- reset, active high
sdata : in std_logic;                     -- serial data in
pdata : out std_logic_vector(7 downto 0); -- parallel data out
ready : out std_logic);                   -- ready strobe, active high-
end receiver;

architecture Behavioral of receiver is

signal timeout: std_logic;
signal half,full,CE,s: std_logic;
signal Q: integer range 0 to 6770;
signal Qp: std_logic_vector(7 downto 0);
type state_type is (idle, start_bit, b0, b1, b2, b3, b4, b5, b6, b7, stop_bit, frame_err);
signal nxt, cur: state_type;

begin
pdata <= Qp;
timeout <= '0' when Q /= 0 else '1';

--timer model
process(clk)
begin
	if rising_edge(clk) then
		if half='1' then 
			Q<= 3385;
		elsif full = '1' then
			Q<= 6770;
		else  
			Q<= Q-1;
		end if;
	end if;
end process;

--shift register model
process(clk)
begin
	if rising_edge(clk) then
		s <= sdata;           ----synchronizing flip flop
		if CE='1' then
			Qp<= s & Qp(7 downto 1);
		end if;
	end if;
end process;

--state register
process(clk, reset)
begin
	if reset = '1' then
		cur <= idle;
	elsif rising_edge(clk) then
		cur <= nxt;
	end if;
end process;

--next state & output decoder
process (cur, s, timeout)
begin
--do these assignments to avoid making a latch (set all outputs to a default)
half <= '0';
full <= '0';
CE   <= '0';
ready <= '0';
nxt  <= idle;
	case cur is
		when idle => 
			if s ='1' then
				nxt <= idle;
			else
				nxt  <= start_bit;
				half <= '1';
			end if;
		when start_bit =>
			if timeout = '0' then
				nxt <= start_bit;
			elsif s = '1' then
				nxt <= idle;
			else
				nxt  <= b0;
				full <= '1';
			end if;
		when b0 =>
			if timeout = '0' then
				nxt <= b0;
			else
				nxt  <= b1;
				CE   <= '1';
				full <= '1';
			end if;
		when b1 =>
			if timeout = '0' then
				nxt  <= b1;
			else
				nxt  <= b2;
				CE   <= '1';
				full <= '1';
			end if;
		when b2 =>
			if timeout = '0' then
				nxt  <= b2;
			else
				nxt  <= b3;
				CE   <= '1';
				full <= '1';
			end if;
		when b3 =>
			if timeout = '0' then
				nxt  <= b3;
			else
				nxt  <= b4;
				CE   <= '1';
				full <= '1';
			end if;
		when b4 =>
			if timeout = '0' then
				nxt  <= b4;
			else
				nxt  <= b5;
				CE   <= '1';
				full <= '1';
			end if;
		when b5 =>
			if timeout = '0' then
				nxt  <= b5;
			else
				nxt  <= b6;
				CE   <= '1';
				full <= '1';
			end if;
		when b6 =>
			if timeout = '0' then
				nxt  <= b6;
			else
				nxt  <= b7;
				CE   <= '1';
				full <= '1';
			end if;
		when b7 =>
			if timeout = '0' then
				nxt  <= b7;
			else
				nxt  <= stop_bit;
				CE   <= '1';
				full <= '1';
			end if;
		when stop_bit =>
			if timeout = '0' then
				nxt  <= stop_bit;
			elsif s = '1' then
				ready <= '1';
				nxt  <= idle;
			else
				nxt  <= frame_err;
			end if;
		when frame_err =>
			if s = '0' then
				nxt  <= frame_err;
			else
				nxt  <= idle;
			end if;
		end case;
end process;
	
end Behavioral;
