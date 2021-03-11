----------------------------------------------------------------------------------
-- Company: Weber State
-- Engineer: Aaron Spilker
-- Module Name: PS2
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PS2 is
    Port ( clk      : in  STD_LOGIC;
           reset    : in  STD_LOGIC;
           PS2_clk  : in  STD_LOGIC;
           PS2_data : in  STD_LOGIC;
           Pdata    : out  STD_LOGIC_VECTOR (7 downto 0);
           go       : out  STD_LOGIC);
end PS2;

architecture Behavioral of PS2 is
type state_type is (idle, b0, b1, b2, b3, b4, b5, b6, b7, parity, wait_stop, wait_go);
signal clean_PS2_clk, PS2_clk2, pulse: std_logic;
signal Q       : std_logic_vector(9 downto 0);
signal count   : integer range 0 to 63 :=63;
signal nxt, cur: state_type;

begin
-- Clean up the Clock.
pulse <= PS2_clk2 and not clean_PS2_clk;

Process(clk, reset)
begin
	if reset = '1' then
		count         <= 63;
		clean_PS2_clk <= '1';
	
-- Counter --
	elsif rising_edge(clk) then                  
		if PS2_clk = '1' and count /= 63 then
			count <= count + 1;
		elsif PS2_clk = '0' and count /= 0 then
			count <= count - 1;
		end if;

-- SR Flip Flop --
		if count = 63 then
			clean_PS2_clk <= '1';
		elsif count = 0 then
			clean_PS2_clk <= '0';
		end if;
	end if;
end process;

-- D Flip Flop --
Process (clk,reset)
begin
	if reset = '1' then
		PS2_clk2 <= '1';
	elsif rising_edge(clk) then
		PS2_clk2 <= clean_PS2_clk;
	end if;
end process;
-------------------
	

--10 Bit Shift Register
Pdata <= Q(7 downto 0);
process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			Q <= "0000000000";
		elsif pulse = '1' then
			Q <= PS2_data & Q(9 downto 1);
		else
			Q <= Q;
		end if;
	end if;
end process;


--State Register
process(clk, reset)
begin
	if reset = '1' then
		cur <= idle;
	elsif rising_edge(clk) then
		cur <= nxt;
	end if;
end process;

--Controller
process(cur, pulse)
begin
go <= '0';

case cur is
	when idle =>
		if pulse = '1' then
			nxt <= b0;
		else
			nxt <= cur;
		end if;
	when b0 =>
		if pulse = '1' then
			nxt <= b1;
		else
			nxt <= cur;
		end if;
	when b1 =>
		if pulse = '1' then
			nxt <= b2;
		else
			nxt <= cur;
		end if;
	when b2 =>
		if pulse = '1' then
			nxt <= b3;
		else
			nxt <= cur;
		end if;
	when b3 =>
		if pulse = '1' then
			nxt <= b4;
		else
			nxt <= cur;
		end if;
	when b4 =>
		if pulse = '1' then
			nxt <= b5;
		else
			nxt <= cur;
		end if;
	when b5 =>
		if pulse = '1' then
			nxt <= b6;
		else
			nxt <= cur;
		end if;
	when b6 =>
		if pulse = '1' then
			nxt <= b7;
		else
			nxt <= cur;
		end if;
	when b7 =>
		if pulse = '1' then
			nxt <= parity;
		else
			nxt <= cur;
		end if;
	when parity =>
		if pulse = '1' then
			nxt <= wait_stop;
		else
			nxt <= cur;
		end if;
	when wait_stop =>
		if pulse = '1' then
			nxt <= wait_go;
		else
			nxt <= cur;
		end if;
	when wait_go =>
		go  <= '1';
		nxt <= idle;
end case;
end process;


end Behavioral;

