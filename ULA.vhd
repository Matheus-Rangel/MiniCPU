LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity ULA IS
	generic (
        DATA_WIDTH : integer := 16;
    );
	PORT(	A, B : IN std_logic_vector (DATA_WIDTH - 1 downto 0);
			op : IN std_logic_vector (2 downto 0);
			S : OUT std_logic_vector (DATA_WIDTH - 1 downto 0));
END ULA;
ARCHITECTURE dataflow of ULA IS
begin
	with op select 
		S <= 	A + B  WHEN "000",
				A - B WHEN "001",
				A and B when "010",
				A nor B when "011",
				A or B when "100",
				A shift_left 1 when "101",
				A shift_right 1 when "110",
				A when "111";
end dataflow;