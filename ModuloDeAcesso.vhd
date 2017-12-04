LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity ModuloDeAcesso IS
	generic (
		DATA_WIDTH : integer := 16;
		ADDR_WIDTH : integer := 16;
		Algo1Addrs : std_logic_vector := x"0000";
		Algo2Addrs : std_logic_vector := x"0009";
		Algo3Addrs : std_logic_vector := x"000F";
		Algo4Addrs : std_logic_vector := x"0017"
	 );
	PORT(
			clock: IN std_logic;
			operating : IN std_logic;
			reset, op : IN std_logic;
			algorithm : IN std_logic_vector(1 downto 0);
			ramOperation: IN std_logic_vector (DATA_WIDTH - 1 downto 0);
			ramOpAddrs : OUT std_logic_vector (ADDR_WIDTH - 1 downto 0); 
			operation : OUT std_logic_vector (3 downto 0);
			RA, RB, RC: OUT std_logic_vector (2 downto 0);
			const : OUT std_logic_vector(5 downto 0);
			curAlgorithm : OUT std_logic_vector(1 downto 0)
			);
END ModuloDeAcesso;

ARCHITECTURE dataflow of ModuloDeAcesso IS
SIGNAL ramAddrs: std_logic_vector(ADDR_WIDTH - 1 downto 0) ;
BEGIN
	ramOpAddrs <= ramAddrs;
	process(clock, reset, algorithm, ramOperation) 
	begin
		if(clock'event and clock = '1') then
			if(ramAddrs = Algo1Addrs) then
						curAlgorithm <= "00";
					elsif(ramAddrs = Algo2Addrs) then
						curAlgorithm <= "01";
					elsif(ramAddrs = Algo3Addrs) then
						curAlgorithm <= "10";
					elsif(ramAddrs = Algo4Addrs) then
						curAlgorithm <= "11";
					end if;
			if(operating = '0') then 
				if(op = '1') then
					ramAddrs <= ramAddrs + x"0001";
				end if;
				if(reset = '1') then
					case algorithm is
						when "00" =>
							ramAddrs <= Algo1Addrs;
						when "01" =>
							ramAddrs <= Algo2Addrs;
						when "10" =>
							ramAddrs <= Algo3Addrs;
						when "11" =>
							ramAddrs <= Algo4Addrs;
					end case;
				end if;
				if(ramOperation(15) = '0') then
					operation <= ramOperation(15)&ramOperation(14)&ramOperation(13)&ramOperation(12);
					RA <= ramOperation(11)&ramOperation(10)&ramOperation(9);
					RB <= ramOperation(8)&ramOperation(7)&ramOperation(6);
					RC <= ramOperation(5)&ramOperation(4)&ramOperation(3);
				else
					operation <= ramOperation(15)&ramOperation(14)&ramOperation(13)&ramOperation(12);
					RA <= ramOperation(11)&ramOperation(10)&ramOperation(9);
					RB <= ramOperation(8)&ramOperation(7)&ramOperation(6);
					const <= ramOperation(5)&ramOperation(4)&ramOperation(3)&ramOperation(2)&ramOperation(1)&ramOperation(0);
				end if;
			end if;
		end if;
	end process;
END dataflow;
