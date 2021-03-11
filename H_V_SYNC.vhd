----------------------------------------------------------------------------------
-- Company: Weber State
-- Engineer: Aaron SPilker
-- Module Name:    H_V_SYNC - Behavioral 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA is
port (clk, reset: in std_logic;
		hsync, vsync, blanking, hstart: out std_logic;
		row : out std_logic_vector(9 downto 0));
end VGA;

architecture Behavioral of VGA is
signal hcount: integer range 0 to 1343; --1184
signal vcount: integer range 0 to 805;
signal hblank, vblank: std_logic;

begin
--For HSYNC
process(clk, reset)
begin
	if reset = '1' then
		hcount <= 0;
	elsif rising_edge(clk) then
		if hcount /= 1343 then
			hcount <= hcount + 1;
		else
			hcount <= 0;
		end if;
	end if;
end process;

--Clean up Horz Glitches
process(clk)
begin
	if rising_edge(clk) then
		if hcount = 1047 then
			hsync <= '0';
		elsif hcount = 1183 then
			hsync <= '1';
		end if;
		if hcount = 1023 then
			hblank <= '0';
		elsif hcount = 1343 then
			hblank <= '1';
		end if;
	end if;
end process;

--For VSYNC
process(clk)
begin
	if rising_edge(clk) and hcount = 1100 then
		if vcount /= 805 then
			vcount <= vcount + 1;
		else
			vcount <= 0;
		end if;
	end if;
end process;

--Clean up Vertical Glitches
process(clk)
begin
	if rising_edge(clk) and hcount = 1100 then
		if vcount = 770 then
			vsync <= '0';
		elsif vcount = 776 then 
			vsync <= '1';
		end if;
		if vcount = 767 then
			vblank <= '0';
		elsif vcount = 805 then
			vblank <= '1';
		end if;
	end if;
end process;

blanking <= vblank and hblank;
hstart <= '1' when hcount = 1343 else '0';
row <= std_logic_vector(to_unsigned(vcount, row'length));

end Behavioral;

