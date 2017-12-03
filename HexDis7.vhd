LIBRARY ieee ;
USE ieee.std_logic_1164.all;

ENTITY HexDis7 IS
	PORT(x : IN std_logic_vector(3 downto 0);	
			display: out std_logic_vector(6 downto 0));
END HexDis7;

ARCHITECTURE Comp of HexDis7 IS
BEGIN
	with x select
		display <= 	"0111111" when "0000",
						"0000110" when "0001",
						"1011011" when "0010",
						"1001111" when "0011",
						"1100110" when "0100",
						"1101101" when "0101",
						"1111101" when "0110",
						"0000111" when "0111",
						"1111111" when "1000",
						"1100111" when "1001",
						"1110111" when "1010",
						"1111100" when "1011",
						"0111001" when "1100",
						"1011110" when "1101",
						"1111001" when "1110",
						"1110001" when "1111";
END Comp;
