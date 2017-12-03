LIBRARY ieee ;
USE ieee.std_logic_1164.all;

entity ProjetoFinal IS
	generic (
        DATA_WIDTH : integer := 16;
        ADDR_WIDTH : integer := 16
    );
	PORT(	clock : IN std_logic;
			switchs: IN STD_LOGIC_VECTOR (17 downto 0);
			buttons : IN std_logic_vector(3 downto 0);
			Leds : OUT STD_LOGIC_VECTOR (16 downto 0);
			Display0, Display1, Display2, Display3, Display4, Display5: OUT  STD_LOGIC_VECTOR(6 downto 0);
END ProjetoFinal;

ARCHITECTURE dataflow of ProjetoFinal IS
--Componentes
COMPONENT ModuloDeEntrada IS
	PORT(switchs: IN std_logic_vector (17 downto 0);
			buttons : IN std_logic_vector(3 downto 0);
			operating : IN std_logic;
			op, valid, reset : OUT std_logic;
			algorithm : OUT std_logic_vector(1 downto 0);
			valor : OUT std_logic_vector (15 downto 0);
END COMPONENT;

COMPONENT registers is
    port (
        clock  : in std_logic;
        reset	: in std_logic;
		  wren   : in std_logic;
        addr   : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
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
			reset, op : IN std_logic;
			algorithm : IN std_logic_vector(1 downto 0);
			ramOperation: IN std_logic_vector (DATA_WIDTH - 1 downto 0);
			ramOpAddrs : OUT std_logic_vector (ADDR_WIDTH - 1 downto 0); 
			operation : OUT std_logic_vector (3 downto 0);
			RA, RB, RC: OUT std_logic_vector (2 downto 0);
			const : OUT std_logic_vector(5 downto 0);
			curAlgorithm : OUT std_logic_vector(1 downto 0);
END COMPONENT;

COMPONENT ULA IS
	PORT(	A, B : IN std_logic_vector (DATA_WIDTH - 1 downto 0);
			op : IN std_logic_vector (2 downto 0);
			S : OUT std_logic_vector (DATA_WIDTH - 1 downto 0));
END COMPONENT;
--Sinais
--ModuloDeAcesso:

--ModuloDeEntrada:
SIGNAL algorithm, valor, reset, op, valid : std_logic;


--ModuloDeSaida:
SIGNAL DisplayValue : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);  

--TOP-LEVEL:
SIGNAL invalidOp, operating : std_logic;
SIGNAL curAlgorithm : std_logic_vector(1 downto 0);
SIGNAL operation : std_logic_vector(3 downto 0);
SIGNAL RA, RB, RC: STD_LOGIC_VECTOR(2 downto 0); --VALORES 
SIGNAL const : STD_LOGIC_VECTOR(5 downto 0); -- VALOR DA CONTANTE
--ULA:
SIGNAL A, B, S: STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0); --ULA
SIGNAL ULAop: STD_LOGIC_VECTOR(2 downto 0);--Operação a ser realizada pela ULA

--REGISTRADORES:
SIGNAL regAddrs: STD_LOGIC_VECTOR(2 downto 0); --ENDEREÇO DO REGISTRADOR
SIGNAL regWren, regReset: std_logic; --LEITURA OU ESCRITA REGISTRADORES
SIGNAL regIN, regOUT: STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0); --ENTRADA E SAIDA DOS DADOS DOS REGISTRADORES

--instRAM:
SIGNAL ramOpAddrs: std_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0); --ENDEREÇO DA OPERAÇÃO NA MEMORIA
SIGNAL ramOperation: std_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0); --SAIDA DA MEMORIA DE INSTRUÇÕES

--dataRAM:
SIGNAL ramDataAddrs: STD_LOGIC_VECTOR(ADDR_WIDTH downto 0); --ENDEREÇO DA RAM DE DADOS
SIGNAL ramDataWren: std_logic; --LEITURA OU ESCRITA REGISTRADORES
SIGNAL ramDataIN, ramDataOUT: STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0); --ENTRADA E SAIDA DOS DADOS DOS REGISTRADORES

BEGIN
	entrada : ModuloDeEntrada PORT MAP(switchs, buttons, operating, op, valid, reset, algorithm, valor);
	acesso: ModuloDeAcesso PORT MAP(clock, reset, op, algorithm, ramOperation, ramOpAddrs, operation, RA, RB, RC, const, curAlgorithm);
	saida: ModuloDeSaida PORT MAP(operating, curAlgorithm, ValorOUT, Leds, Display0, Display1, Display2, Display3, Display4, Display5);
	regs: registers PORT MAP(clock, regReset, regWren, regAddrs, regIN, regOUT);
	instRAM: RAM PORT MAP(clock, '0', ramOpAddrs, x"0000", ramOperation);
	dataRAM:	RAM PORT MAP(clock, ramDataWren, ramDataAddrs, ramDataIN, ramDataOUT);
	ULA0: ULA PORT MAP (A, B, ULAop, S);
	
	process(clock, valor, operation, op, operating, reset, invalidOp,valid, regIN, regOUT, regAddrs, regWren, ramOperation, A, B, ULAop, S) then
		variable state : std_logic_vector(1 downto 0);
		variable subState: std_logic_vector(1 downto 0);
		variable nextReg: std_logic_vector(1 downto 0);
	begin
		if(clock'event and clock ='1') then
			case state is
				when "00" =>
					case subState is
						when "00" =>
							operating <= '0';
							if(valid = '1')
								valid <= '0';
								regWren <= '1';
								regIN <= valor;
								regAddrs <= nextReg;
								subState := "01";
							end if;
						when "01" =>
							subState :="00";
							regWren <= '0';
							nextReg := nextReg + "001";
						when others =>
							subState := "00";
					end case;
					if(op = '1') then
						subState := "00";
						state := "01";
					end if;
				when "01" =>
					operating <= '1';
					if(operation(3) = '0') then
						if(ramOperation(2)&ramOperation(1)&ramOperation(0) = "000") then
							ULAop<=operation(2)&operation(1)&operation(0);
							invalidOp <= '0';
							case subState is
								when "00" =>
									regWren <= '0';
									regAddrs <= RA;
									subState := "01";
								when "01" =>
									A <= regOUT;
									regWren <= '0';
									regAddrs <= RB;
									subState := "10";
								when "10" =>
									B <= regOUT;
									regWren <= '1';
									regAddrs <= RC;
									subState := "11";
								when "11" =>
									regIN <= S;
									subState := "00";
									state := "00";
							end case;
						else
							invalidOp<= '1';
							state := "00";
						end if;
					else
						case operation(2)&operation(1)&operation(0) is
							when "000" =>
								case subState is
									when "00" =>
										ULAop<="000";
										regWren <= '0';
										regAddrs <= RA;
										subState := "01";
									when "01" =>
										A <= regOUT;
										B <= const;
										subState := "10";
									when "10" =>
										ramDataAddrs <= S;
										subState := "11";
									when "11" =>
										regIN <= ramDataOUT;
										regAddrs <= RB;
										regWren <= '1';
										ramDataWren <= '0';
										subState := "00";
										state := "00";
								end case;
							when "001" =>
								case subState is
									when "00" =>
										ULAop<="000";
										regWren <= '0';
										regAddrs <= RA;
										subState := "01";
									when "01" =>
										A <= regOUT;
										B <= const;
										subState := "10";
									when "10" =>
										ramDataAddrs <= S;
										subState := "11";
									when "11" =>
										ramDataIN <= regOUT;
										regAddrs <= RB;
										regWren <= '0';
										ramDataWren <= '1';
										subState := "00";
										state := "00";
								end case;
							when "110" =>
								case subState is
									when "00" =>
										ULAop<="000";
										regWren <= '0';
										regAddrs <= RA;
										subState := "01";
									when "01" =>
										A <= regOUT;
										B <= const;
										subState := "10";
									when "10" =>
										regWren <= '1';
										regAddrs <= RB;
										regDataIN <= S;
										subState := "11";
									when "11" =>
										regWren <= '0';
										subState := "00";
										state := "00";
								end case;
							when others =>
								invalidOp<='1';
								state := "00";
						end case;
					end if;
			end case;
		end if;
	end process;
END dataflow;