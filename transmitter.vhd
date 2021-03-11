----------------------------------------------------------------------------------
-- Company: Weber State
-- Engineer: Aaron Spilker
-- Create Date:    14:12:51 09/22/2015 
-- Module Name:    transmitter - Behavioral 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity transmitter is
    Port ( clk   : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  valid : in  STD_LOGIC;
           pdata : in  STD_LOGIC_VECTOR (7 downto 0); -- data want to xfer
           sdata : out  STD_LOGIC); -- route out to fpga pin to serial port
end transmitter;

architecture Behavioral of transmitter is

type state_type is (idle, start_bit, b0, b1, b2, b3, b4, b5, b6, b7, stop_bit);
signal TSR : std_logic_vector(8 downto 0);
signal TBR : std_logic_vector(7 downto 0);
signal Q: integer range 0 to 6770;
signal load, shift, full, timeout, fb : std_logic;
signal nxt, cur : state_type;

begin
sdata <= TSR(0);
timeout <= '0' when Q /= 0 else '1';

--TSR MODULE
process(clk, reset)
begin
	if reset = '1' then
		TSR <= "111111111";
	elsif rising_edge(clk) then
		if load = '1' then
			TSR <= TBR & '0';
	elsif shift = '1' then
		TSR <= '1' & TSR(8 downto 1);
		end if;
	end if;
end process;

--TBR MODULE
process(clk, reset)
begin
	if rising_edge(clk) then
		if valid = '1' then
			TBR <= pdata;
		else
			TBR <= TBR;
		end if;
	end if;
end process;

--SR FLIP FLOP
process(clk, reset)
begin
		if reset = '1' then
			full <= '0';
		elsif rising_edge(clk) then
			if load = '1' then
				full <= '0';
			elsif valid = '1' then
				full <= '1';
			end if;
		end if;
end process;

--TIME MODULE
process(clk)
begin
	if rising_edge(clk) then
		if fb = '1' then
			Q <= 6770;
		else
			Q <= Q - 1;
		end if;
	end if;
end process;
			
--STATE DECODER
process(clk, reset)
begin
	if reset = '1' then
		cur <= idle;
	elsif rising_edge(clk) then
		cur <= nxt;
	end if;
end process;

--CONTROLLER MODULE
process(cur, timeout, full)
begin
load  <= '0';
shift <= '0';
fb    <= '0';
nxt   <= idle;

case cur is
	when idle =>
		if full = '1' then
			nxt  <= start_bit;
			load <= '1';
			fb   <= '1';
		else
			nxt <= idle;
		end if;
	when start_bit =>
		if timeout = '1' then
			nxt  <= b0;
			shift<= '1';
			fb   <= '1';
		else
			nxt <= start_bit;
		end if;
	when b0 =>
		if timeout = '1' then
			nxt  <= b1;
			shift <= '1';
			fb   <= '1';
		else
			nxt <= b0;
		end if;
	when b1 =>
		if timeout = '1' then
			nxt  <= b2;
			shift<= '1';
			fb   <= '1';
		else
			nxt <= b1;
		end if;
	when b2 =>
		if timeout = '1' then
			nxt  <= b3;
			shift <= '1';
			fb   <= '1';
		else
			nxt <= b2;
		end if;
	when b3 =>
		if timeout = '1' then
			nxt  <= b4;
			shift <= '1';
			fb   <= '1';
		else
			nxt <= b3;
		end if;
	 when b4 =>
		if timeout = '1' then
			nxt  <= b5;
			shift <= '1';
			fb   <= '1';
		else
			nxt <= b4;
		end if;
	when b5 =>
		if timeout = '1' then
			nxt  <= b6;
			shift <= '1';
			fb   <= '1';
		else
			nxt <= b5;
		end if;
	when b6 =>
		if timeout = '1' then
			nxt  <= b7;
			shift <= '1';
			fb   <= '1';
		else
			nxt <= b6;
		end if;
	when b7 =>
		if timeout = '1' then
			nxt  <= stop_bit;
			shift <= '1';
			fb   <= '1';
		else
			nxt <= b7;
		end if;
	when stop_bit =>
		if timeout = '1' then
			nxt  <= idle;
			shift <= '1';
			fb   <= '1';
		else
			nxt <= stop_bit;
		end if;
	end case;
end process;
end Behavioral;

