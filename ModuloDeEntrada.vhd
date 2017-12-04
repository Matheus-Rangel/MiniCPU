LIBRARY ieee ;
USE ieee.std_logic_1164.all;

entity ModuloDeEntrada IS
	PORT(
			clock : IN std_logic;
			switchs: IN std_logic_vector (17 downto 0);
			buttons : IN std_logic_vector(3 downto 0);
			operating : IN std_logic;
			op, valid, reset : OUT std_logic;
			algorithm : OUT std_logic_vector(1 downto 0);
			valor : OUT std_logic_vector (15 downto 0));
END ModuloDeEntrada;

ARCHITECTURE dataflow of ModuloDeEntrada IS

signal lastR, R, lastO, O, lastV, V : std_logic;
BEGIN
	algorithm <= switchs(17 downto 16);
	process(clock, switchs, buttons, operating)
		begin
			if(clock'event and clock = '0') then
				lastO <= O;
				O <= buttons(0);
				lastV <= V;
				V <= buttons(1);
				lastR <= R;
				R <= buttons(2);
				if(operating = '0') then
					if(lastO /= O and O = '1') then
						op <= '1';
					else
						op <= '0';
					end if;
					if(lastV /= V and V = '1') then
						valid <= '1';
						valor <= switchs(15 downto 0);
					else
						valid <= '0';
					end if;
					if(lastR /= R and R = '1') then
						reset <= '1';
					else
						reset <= '0';
					end if;
				end if;
			end if;
	end process;
END dataflow;
