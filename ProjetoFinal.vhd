LIBRARY ieee ;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

entity ProjetoFinal IS
	generic (
        DATA_WIDTH : integer := 16;
        ADDR_WIDTH : integer := 16
    );
	PORT(	clock : IN std_logic;
			switchs: IN STD_LOGIC_VECTOR (17 downto 0);
			buttons : IN std_logic_vector(3 downto 0);
			leds : OUT STD_LOGIC_VECTOR (16 downto 0);
			display0, display1, display2, display3, display4, display5, display6, display7: OUT  STD_LOGIC_VECTOR(6 downto 0));
END ProjetoFinal;

ARCHITECTURE dataflow of ProjetoFinal IS
--Componentes
COMPONENT ModuloDeEntrada IS
	PORT(	
			clock : IN std_logic;
			switchs: IN std_logic_vector (17 downto 0);
			buttons : IN std_logic_vector(3 downto 0);
			operating : IN std_logic;
			op, valid, reset : OUT std_logic;
			algorithm : OUT std_logic_vector(1 downto 0);
			valor : OUT std_logic_vector (15 downto 0));
END COMPONENT;
COMPONENT ModuloDeSaida IS
	PORT(
			valor : IN std_logic_vector (15 downto 0);
			ramOpAddrs: IN std_logic_vector(15 downto 0);
			curAlgorithm: IN std_logic_vector(1 downto 0);
			operating, invalidOp	: IN std_logic;
			leds : OUT STD_LOGIC_VECTOR (16 downto 0);
			display0, display1, display2, display3, display4, display5, display6, display7: OUT  STD_LOGIC_VECTOR(6 downto 0));
END COMPONENT;

COMPONENT registers is
    port (
        clock  : in std_logic;
        reset	: in std_logic;
		  wren   : in std_logic;
        addr   : in std_logic_vector(2 downto 0);
        data_i : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        data_o : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end COMPONENT;

COMPONENT ram IS
    port (
        clock  : in std_logic;
        wren   : in std_logic;
        addr   : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        data_i : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        data_o : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
END COMPONENT;

COMPONENT ModulodeAcesso IS
	PORT(	clock: IN std_logic;
			operating : IN std_logic;
			reset, op : IN std_logic;
			algorithm : IN std_logic_vector(1 downto 0);
			ramOperation: IN std_logic_vector (DATA_WIDTH - 1 downto 0);
			ramOpAddrs : OUT std_logic_vector (ADDR_WIDTH - 1 downto 0); 
			operation : OUT std_logic_vector (3 downto 0);
			RA, RB, RC: OUT std_logic_vector (2 downto 0);
			const : OUT std_logic_vector(5 downto 0);
			curAlgorithm : OUT std_logic_vector(1 downto 0));
END COMPONENT;

COMPONENT ULA IS
	PORT(	A, B : IN std_logic_vector (DATA_WIDTH - 1 downto 0);
			op : IN std_logic_vector (2 downto 0);
			S : OUT std_logic_vector (DATA_WIDTH - 1 downto 0));
END COMPONENT;
--Sinais

--ModuloDeEntrada:
SIGNAL reset, op, valid : std_logic;
SIGNAL algorithm : std_logic_vector(1 downto 0);
SIGNAL valor : std_logic_vector(15 downto 0);
  
--TOP-LEVEL:
SIGNAL invalidOp, operating : std_logic:= '0';
SIGNAL curAlgorithm : std_logic_vector(1 downto 0);
SIGNAL operation : std_logic_vector(3 downto 0):= (others => '0');
SIGNAL RA, RB, RC: STD_LOGIC_VECTOR(2 downto 0):= (others => '0'); --VALORES 
SIGNAL const : STD_LOGIC_VECTOR(5 downto 0); -- VALOR DA CONSTANTE
SIGNAL valorOUT: STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);--VALOR DE SAIDA
--ULA:
SIGNAL A, B, S: STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0'); --ULA
SIGNAL ULAop: STD_LOGIC_VECTOR(2 downto 0):= (others => '0');--Operação a ser realizada pela ULA

--REGISTRADORES:
SIGNAL regAddrs: STD_LOGIC_VECTOR(2 downto 0):= (others => '0'); --ENDEREÇO DO REGISTRADOR
SIGNAL regWren: std_logic:= '0'; --LEITURA OU ESCRITA REGISTRADORES
SIGNAL regIN, regOUT: STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0):= (others => '0'); --ENTRADA E SAIDA DOS DADOS DOS REGISTRADORES

--instRAM:
SIGNAL ramOpAddrs: std_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0):= (others => '0'); --ENDEREÇO DA OPERAÇÃO NA MEMORIA
SIGNAL ramOperation: std_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0):= (others => '0'); --SAIDA DA MEMORIA DE INSTRUÇÕES

--dataRAM:
SIGNAL ramDataAddrs: STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0):= (others => '0'); --ENDEREÇO DA RAM DE DADOS
SIGNAL ramDataWren: std_logic:= '0'; --LEITURA OU ESCRITA REGISTRADORES
SIGNAL ramDataIN, ramDataOUT: STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0):= (others => '0'); --ENTRADA E SAIDA DOS DADOS DOS REGISTRADORES

BEGIN
	entrada : ModuloDeEntrada PORT MAP(clock, switchs, buttons, operating, op, valid, reset, algorithm, valor);
	acesso: ModuloDeAcesso PORT MAP(clock, operating, reset, op, algorithm, ramOperation, ramOpAddrs, operation, RA, RB, RC, const, curAlgorithm);
	saida: ModuloDeSaida PORT MAP(valorOUT, ramOpAddrs, curAlgorithm, operating, invalidOp,leds, display0, display1, display2, display3, display4, display5, display6, display7);
	regs: registers PORT MAP(clock, reset, regWren, regAddrs, regIN, regOUT);
	instRAM: RAM PORT MAP(clock, '0', ramOpAddrs, x"0000", ramOperation);
	dataRAM:	RAM PORT MAP(clock, ramDataWren, ramDataAddrs, ramDataIN, ramDataOUT);
	ULA0: ULA PORT MAP (A, B, ULAop, S);
	
	process(clock, valor, operation, op, operating, reset, invalidOp, valid, regIN, regOUT, regAddrs, regWren, ramOperation, A, B, ULAop, S, ramOpAddrs)
		variable state : std_logic := '0';
		variable subState: std_logic_vector(2 downto 0);
		variable nextReg: std_logic_vector(2 downto 0);
		variable subOp : std_logic_vector(2 downto 0);--operacoes com const
	begin
		if(clock'event and clock ='1') then
			case state is
				when '0' =>--estado de entrada, waiting
					operating <= '0';
					case subState is
						when "000" =>
							if(valid = '1') then 
								regIN <= valor;
								valorOUT<= valor;
								regAddrs <= nextReg;
								subState := "001";
							end if;
							if(op = '1') then
								subState := "000";
								state := '1';
							end if;
							if(reset = '1') then
								nextReg := "000";
								ValorOUT <= x"0000";
							end if;
						when "001" =>
							regWren <= '1';
							subState :="010";
							nextReg := nextReg + "001";
						when others =>
							subState := "000";
					end case;
				when '1' =>--operating
					operating <= '1';
					if(operation(3) = '0') then
						if(ramOperation(2) = '0' and ramOperation(1) = '0' and ramOperation(0) = '0') then
							ULAop<=operation(2)&operation(1)&operation(0);
							invalidOp <= '0';
							case subState is
								when "000" =>
									regWren <= '0';
									regAddrs <= RA;
									subState := "001";
								when "001" =>
									--wait
									subState := "010";
								when "010" =>
									A <= regOUT;
									regAddrs <= RB;
									subState := "011";
								when "011" =>
									--wait
									subState := "100";
								when "100" =>
									B <= regOUT;
									regAddrs <= RC;
									regIN <= S;
									valorOUT <= S;--SAIDA
									subState :="101";
								when "101" =>
									--wait
									subState := "110";
								when others =>
									regWren <= '1';
									subState := "000";
									state := '0';
							end case;
						else
							invalidOp<= '1';
							subState := "000";
							state := '0';--estado de entrada, waiting
						end if;
					else
						subOp := operation(2)&operation(1)&operation(0);
						case subOp is
							when "000" =>
								case subState is
									when "000" =>
										ULAop<="000";
										regWren <= '0';
										regAddrs <= RA;
										subState := "001";
									when "001" =>
										--WAIT
										subState := "010";
									when "010" =>
										A <= regOUT;
										B <= "0000000000"&const;
										subState := "011";
										ramDataWren <= '0';
									WHEN "011"=>
										ramDataAddrs <= S;
										subState :="100";
									when "100" =>
										--WAIT
										subState := "101";
									when "101" =>
										regIN <= ramDataOUT;
										valorOUT <= ramDataOUT;
										regAddrs <= RB;
										regWren <= '1';
										subState := "000";
										state := '0';
									when others =>
										subState := "000";
										state := '0';
								end case;
							when "001" =>
								case subState is
									when "000" =>
										ULAop<="000";
										regWren <= '0';
										regAddrs <= RA;
										subState := "001";
									when "001" =>
										--WAIT
										subState := "010";
									when "010" =>
										A <= regOUT;
										B <= "0000000000"&const;
										subState := "011";
										ramDataAddrs <= S;
									when "011" =>
										subState := "100";
										regAddrs <= RB;
									when "100" =>
										--WAIT
										subState := "101";
									when "101" =>
										ramDataWren <= '1';
										ramDataIN <= regOUT;
										valorOUT <= regOUT;
										subState := "000";
										state := '0';
									when others =>
										subState := "000";
										state := '0';
								end case;
							when "110" =>
								case subState is
									when "000" =>
										ULAop<="000";
										regWren <= '0';
										regAddrs <= RA;
										subState := "001";
									when "001" =>
										--WAIT
										subState := "010";
									when "010" =>
										A <= regOUT;
										B <= "0000000000"&const;
										subState := "011";
									when "011" =>
										regWren <= '1';
										regAddrs <= RB;
										regIN <= S;
										subState := "100";
									when "100" =>
										regIN <= S;
										valorOUT <= S;
										subState := "000";
										state := '0';
									when others =>
										subState := "000";
										state := '0';
								end case;
							when others =>
								invalidOp<='1';
								subState := "000";
								state := '0';--estado de entrada, waiting
						end case;
					end if;
			end case;
		end if;
	end process;
END dataflow;