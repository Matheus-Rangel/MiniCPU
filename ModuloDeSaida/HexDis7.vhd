LIBRARY ieee ;
USE ieee.std_logic_1164.all;

ENTITY HexDis7 IS
	PORT(x : IN std_logic_vector(3 downto 0);	
			display: out std_logic_vector(6 downto 0));
END HexDis7;

ARCHITECTURE Comp of HexDis7 IS
BEGIN
	with x select
		display <= 	"1000000" when "0000",
						"1111001" when "0001",
						"0100100" when "0010",
						"0110000" when "0011",
						"0011001" when "0100",
						"0010010" when "0101",
						"0000010" when "0110",
						"1111000" when "0111",
						"0000000" when "1000",
						"0011000" when "1001",
						"0001000" when "1010",
						"0000011" when "1011",
						"1000110" when "1100",
						"0100001" when "1101",
						"0000110" when "1110",
						"0001110" when "1111";
END Comp;
