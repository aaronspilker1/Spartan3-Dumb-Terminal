----------------------------------------------------------------------------------
-- Company: Weber State
-- Engineer: Aaron Spilker
-- Module Name:    Lab7 - Behavioral 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Lab7 is
	Port(	CLK_50: in std_logic;
			reset: in std_logic;
			btn_east, btn_west, btn_north: in std_logic;
			PS_2: in std_logic;
			PS_2_clk: in std_logic;
			TXD: out std_logic; --RS232 out
			RXD: in std_logic; --RS232 In
			vga_red, vga_green, vga_blue, vga_hsync, vga_vsync: out std_logic);
end Lab7;

architecture Behavioral of Lab7 is

Component Cursor_Control is
	Port (clk: in std_logic;
			reset: in std_logic;
			ready : in std_logic;
			clear : out std_logic;
			scroll : out std_logic;
			write_char : out std_logic;
			row : out std_logic_vector(5 downto 0);
			col : out std_logic_vector(6 downto 0);
			ascii : out std_logic_vector(7 downto 0);
			ascii_data : in std_logic_vector(7 downto 0));
end Component;

Component PS2 is
	Port (clk      : in  STD_LOGIC;
         reset    : in  STD_LOGIC;
         PS2_clk  : in  STD_LOGIC;
         PS2_data : in  STD_LOGIC;
         Pdata    : out  STD_LOGIC_VECTOR (7 downto 0);
         go       : out  STD_LOGIC);
end Component;

Component VGA is
	Port (clk, reset: in std_logic;
			hsync, vsync, blanking, hstart: out std_logic;
			row : out std_logic_vector(9 downto 0));
end Component;

Component chargen is
	Port (clk : in  STD_LOGIC;
         reset : in  STD_LOGIC;
         hstart : in  STD_LOGIC;
         vga_row : in  STD_LOGIC_VECTOR (9 downto 0);
			ascii: in STD_LOGIC_VECTOR (6 downto 0);
			row_addr: out STD_LOGIC_VECTOR (5 downto 0);
			col_addr: out STD_LOGIC_VECTOR (6 downto 0);
         pix : out  STD_LOGIC);
end Component;

Component charmem is
	Port (clk:  in std_logic;
		   row1: in  std_logic_vector(5 downto 0); -- row address for display side
		   col1: in  std_logic_vector(6 downto 0); -- column address for display
		   out1: out std_logic_vector(6 downto 0); -- character to be displayed
		   row2: in  std_logic_vector(5 downto 0); -- row address for input
		   col2: in  std_logic_vector(6 downto 0); -- column address for input
		   in2:  in  std_logic_vector(6 downto 0); -- character to be input
		   writec: in std_logic; -- write one char (int2) at row2,col2
		   clear:  in std_logic; -- clear the screen (memory)
		   scroll: in std_logic); -- scroll the screen (memory)
end Component;

Component clock_ctrl is
	Port (Clk_in : in std_logic;
         Clk_out : out std_logic);
end Component;

Component receiver is
	Port (clk : in std_logic;                			-- clock input, f=50MHz
			reset : in std_logic;                     -- reset, active high
			sdata : in std_logic;                     -- serial data in
			pdata : out std_logic_vector(7 downto 0); -- parallel data out
			ready : out std_logic);                   -- ready strobe, active high-
end Component;

Component scan_ascii is
	Port (clk     : in  STD_LOGIC;
         reset   : in  STD_LOGIC;
			go      : in  STD_LOGIC;
			pdata_I : in  STD_LOGIC_VECTOR (7 downto 0); -- data in from PS2
			valid   : out STD_LOGIC;
         pdata_O : out STD_LOGIC_VECTOR (7 downto 0)); -- route out to transmitter
end Component;

Component transmitter is
	Port (clk   : in  STD_LOGIC;
         reset : in  STD_LOGIC;
			valid : in  STD_LOGIC;
         pdata : in  STD_LOGIC_VECTOR (7 downto 0); -- data want to xfer
         sdata : out  STD_LOGIC); -- route out to fpga pin to serial port
end Component;

signal ready: std_logic; --PS2 to scan_ascii
signal ready2: std_logic; --scan_ascii to transmitter
signal ready3: std_logic; --receiver to cursor_control
signal data: std_logic_vector (7 downto 0); --PS2 to scan_ascii
signal data2: std_logic_vector(7 downto 0); --scan_ascii to transmitter
signal data3: std_logic_vector(7 downto 0); --receiver to cursor_control
signal data4: std_logic_vector(7 downto 0); --cursor_control to char_mem
signal data5: std_logic_vector(6 downto 0);
signal data6: std_logic_vector(9 downto 0);
signal Wr, Sc, Cl, Hs, clk, pix, blanking: std_logic;
signal row_1,row_2: std_logic_vector(5 downto 0);
signal col_1,col_2: std_logic_vector(6 downto 0);
signal blinker: std_logic; 

begin
clk1: clock_ctrl     port map (CLK_50, clk);
PS21: PS2            port map (clk, reset, PS_2_clk, PS_2, data, ready);
S2A : scan_ascii     port map (clk, reset, ready, data, ready2, data2);
TSM1: transmitter    port map (clk, reset, ready2, data2, TXD);
RCV1: receiver       port map (clk, reset, RXD, data3, ready3);
CURC: Cursor_Control port map (clk, reset, ready3, Cl, Sc, Wr, row_1, col_1, data4, data3);
CHEM: charmem        port map (clk, row_2, col_2, data5, row_1, col_1, data4(6 downto 0), Wr, Cl, Sc);
CGEN: chargen        port map (clk, reset, Hs, data6, data5, row_2, col_2, pix);
VG1: VGA             port map (clk, reset, vga_hsync, vga_vsync, blanking, Hs, data6);

blinker <= '1' when row_1 = row_2 and col_1 = std_logic_vector(to_unsigned((to_integer(unsigned(col_2))-1),7)) else '0';
vga_green <= (blanking and pix) or blinker;
vga_red   <= blanking and pix;
vga_blue  <= blanking and pix;

end Behavioral;

