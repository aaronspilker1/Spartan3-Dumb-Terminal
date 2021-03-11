----------------------------------------------------------------------------------
-- Company: Weber State
-- Engineer: Aaron Spilker
-- Module Name: scan_ascii 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity scan_ascii is
    Port ( clk     : in  STD_LOGIC;
           reset   : in  STD_LOGIC;
			  go      : in  STD_LOGIC;
			  pdata_I : in  STD_LOGIC_VECTOR (7 downto 0); -- data in from PS2
			  valid   : out STD_LOGIC;
           pdata_O : out STD_LOGIC_VECTOR (7 downto 0) -- route out to transmitter
			 );
end scan_ascii;

architecture Behavioral of scan_ascii is

type map_type is array (0 to 1023) of integer range 0 to 127;
constant scan2ascii: map_type :=
  ( -- NUMBER KEYS
    16#045#=>48,  16#145#=>41,               -- 0)
    16#016#=>49,  16#116#=>33,               -- 1!
    16#01E#=>50,  16#11E#=>64,  16#31E#=>0,  -- 2@ CTRL+@
    16#026#=>51,  16#126#=>35,               -- 3#
    16#025#=>52,  16#125#=>36,               -- 4$
    16#02E#=>53,  16#12E#=>37,               -- 5%
    16#036#=>54,  16#136#=>94,  16#336#=>30, -- 6^ CTRL+^
    16#03D#=>55,  16#13D#=>38,               -- 7&
    16#03E#=>56,  16#13E#=>42,               -- 8*
    16#046#=>57,  16#146#=>40,               -- 9(
  
    -- ALPHABETIC KEYS
    16#01C#=>97,  16#11C#=>65,  16#21C#=>1,  -- aA
    16#032#=>98,  16#132#=>66,  16#232#=>2,  -- bB
    16#021#=>99,  16#121#=>67,  16#221#=>3,  -- cC
    16#023#=>100, 16#123#=>68,  16#223#=>4,  -- dD
    16#024#=>101, 16#124#=>69,  16#224#=>5,  -- eE
    16#02B#=>102, 16#12B#=>70,  16#22B#=>6,  -- fF
    16#034#=>103, 16#134#=>71,  16#234#=>7,  -- gG
    16#033#=>104, 16#133#=>72,  16#233#=>8,  -- hH
    16#043#=>105, 16#143#=>73,  16#243#=>9,  -- iI
    16#03B#=>106, 16#13B#=>74,  16#23B#=>10, -- jJ
    16#042#=>107, 16#142#=>75,  16#242#=>11, -- kK
    16#04B#=>108, 16#14B#=>76,  16#24B#=>12, -- lL
    16#03A#=>109, 16#13A#=>77,  16#23A#=>13, -- mM
    16#031#=>110, 16#131#=>78,  16#231#=>14, -- nN
    16#044#=>111, 16#144#=>79,  16#244#=>15, -- oO
    16#04D#=>112, 16#14D#=>80,  16#24D#=>16, -- pP
    16#015#=>113, 16#115#=>81,  16#215#=>17, -- qQ
    16#02D#=>114, 16#12D#=>82,  16#22D#=>18, -- rR
    16#01B#=>115, 16#11B#=>83,  16#21B#=>19, -- sS
    16#02C#=>116, 16#12C#=>84,  16#22C#=>20, -- tT
    16#03C#=>117, 16#13C#=>85,  16#23C#=>21, -- uU
    16#02A#=>118, 16#12A#=>86,  16#22A#=>22, -- vV
    16#01D#=>119, 16#11D#=>87,  16#21D#=>23, -- wW
    16#022#=>120, 16#122#=>88,  16#222#=>24, -- xX
    16#035#=>121, 16#135#=>89,  16#235#=>25, -- yY
    16#01A#=>122, 16#11A#=>90,  16#21A#=>26, -- zZ
    16#054#=>91,  16#154#=>123, 16#254#=>27, -- [{
    16#05D#=>92,  16#15D#=>124, 16#25D#=>28, -- \|
    16#05B#=>93,  16#15B#=>125, 16#25B#=>29, -- ]}
    
    -- OTHER PRINTABLE KEYS
    16#00E#=>96,  16#10E#=>126,              -- `~
    16#04E#=>45,  16#14E#=>95,  16#34E#=>31, -- -_ CTRL+_
    16#055#=>61,  16#155#=>43,               -- =+
    16#04C#=>59,  16#14C#=>58,               -- ;:
    16#052#=>39,  16#152#=>34,               -- '"
    16#041#=>44,  16#141#=>60,               -- ,<
    16#049#=>46,  16#149#=>62,               -- .>
    16#04A#=>47,  16#14A#=>63,               -- /?
    16#029#=>32,  16#129#=>32,  16#229#=>32, -- SPACE
    
    -- CONTROL KEYS
    16#076#=>27,  16#176#=>27,  16#276#=>27, -- ESC
    16#066#=>8,   16#166#=>8,   16#266#=>8,  -- BS
    16#00D#=>9,   16#10D#=>9,   16#20D#=>9,  -- TAB
    16#05A#=>13,  16#15A#=>13,  16#25A#=>13, -- CR
    
    others=>127 );

type state_type is (idle, wait_release);
signal smap: std_logic;
signal cur: state_type;
signal shift, ctrl: std_logic;
signal address: std_logic_vector(9 downto 0);
signal ascii: integer range 0 to 127;

begin

address(9) <= ctrl;
address(8) <= shift;
address(7 downto 0) <= pdata_I;
valid <= '1' when smap = '1' and ascii/= 127 else '0';
pdata_O <= std_logic_vector(to_unsigned(ascii,8));

process(clk)
begin
	if rising_edge(clk) then
		ascii <= scan2ascii(to_integer(unsigned(address)));
		if go = '1' and cur = idle then
			smap <= '1';
		else
			smap <= '0';
		end if;
	end if;
end process;

process(clk, reset)
begin
	if reset = '1' then
		cur <= idle;
		shift <= '0';
		ctrl <= '0';
	elsif rising_edge(clk) then
	if	go ='1' then
		if cur = idle then
			if pdata_I = X"F0" then
				cur <= wait_release;
			elsif pdata_I = X"12" or pdata_I = X"59" then
				shift <= '1';
			elsif pdata_I = X"14" then
				ctrl <= '1';
			end if;
		
		else -- now in wait release
			cur <= idle;
			if pdata_I = X"12" or pdata_I = X"59" then
				shift <= '0';
			elsif pdata_I = X"14" then
				ctrl <= '0';
			end if;
		end if;
	end if;
end if;
end process;

end Behavioral;

