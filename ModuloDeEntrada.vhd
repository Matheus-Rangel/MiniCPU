LIBRARY ieee ;
USE ieee.std_logic_1164.all;

entity ModuloDeEntrada IS
	PORT(
			switchs: IN std_logic_vector (17 downto 0);
			buttons : IN std_logic_vector(3 downto 0);
			operating : IN std_logic;
			op, valid, reset : OUT std_logic;
			algorithm : OUT std_logic_vector(1 downto 0);
			valor : OUT std_logic_vector (15 downto 0);
END ModuloDeEntrada;

ARCHITECTURE dataflow of ModuloDeEntrada IS
BEGIN
	algorithm <= switchs(17)&switchs(16);
	process(valid, reset, op, switchs) 
		begin
			if(operating = '0') then
				if(buttons(0)'event and buttons(0) = '1') then
					op <= '1';
				end if;
				if(buttons(1)'event and buttons(1) = '1') then
					valid <='1';
					valor <= switchs(15)&switchs(14)&switchs(13)&switchs(12)&switchs(11)&switchs(10)&switchs(9)&switchs(8)&
								switchs(7)&switchs(6)&switchs(5)&switchs(4)&switchs(3)&switchs(2)&switchs(1)&switchs(0)&;
				end if;
				if(buttons(2)'event and buttons(2) = '1') then
					reset <= '1';
				end if;
			end if;
		end process;
END dataflow;
