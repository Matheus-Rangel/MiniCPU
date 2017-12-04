library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
    generic (
        DATA_WIDTH : integer := 16;
        ADDR_WIDTH : integer := 16
    );
    port (
        clock  : in std_logic;
        wren   : in std_logic;
        addr   : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        data_i : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        data_o : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end ram;

architecture ram_arch of ram is
    type ram_t is array (0 to 2**ADDR_WIDTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

    signal ram_image : ram_t := (
        0 => "1111111111111111",--NO OPERATION
        --algoritmo1 A=000,B=001.
		  1 => "0110000000000000",--divide o valor de A por 2 e armazena em A
        2 => "0110000000000000",--divide o valor de A por 2 e armazena em A
        3 => "0101001001010000",--multiplica o valor de B por 2 e armazena em "010"
        4 => "0101010010010000",--multiplica o valor de "010" por2 e armazena em "010"
        5 => "0101010010010000",--multiplica o valor de "010" por2 e armazena em "010"
        6 => "0000001010010000",--soma o valor de B com o de "010" e armazena em "010"
        7 => "0000001010001000",--soma o valor de B com o de "010" e armazena em "B"
        8 => "0000000001111000",--soma o valor de A e B e armazena em "111"
        9 => "1111111111111111",--NO OPERATION
        --algoritmo2 A=000, B=001, C=010 
		  10 => "1110000000000001",--soma o valor de A com 1 e armazena em A
        11 => "0101001001001000",--multiplica o valor de B por 2 e armazena em B
        12 => "0110010010010000",--divide o valor de C por 2 e armazena em C
        13 => "0000000001000000",--soma o valor de A com o de B e armazena em A
        14 => "0001000010111000",--subtrai o valor de A com o de c e armazena em "111"
        15 => "1111111111111111",--NO OPERATION
        --algoritmo3 A=000, B=001, C=010, D = 011
		  16 => "0010000001010000",--C = A and B
        17 => "0011010010010000",--C = C nor C
        18 => "0100000001011000",--D = A or B
        19 => "0010010011010000",--C = C and D, C = A xor B.
        20 => "0011000000000000",--A = A nor A
        21 => "0100000001000000",--A = A or B
        22 => "0010000010111000",--111 = A and C
        23 => "1111111111111111",--NO OPERATION
		  --algoritmo4 A=000, B=001
        24 => "0101000000001000",--multiplica o valor de A por 2 e armazena em B
        25 => "0101001001001000",--multiplica o valor de B por 2 e armazena em B
        26 => "0000000001000000",--soma o valor de A com o de B e armazena em A
        27 => "1111111111111111",--NO OPERATION
        others => "1111111111111111" --NO OPERATION
    );
begin
    process (clock)
    begin
        if clock'event and clock = '1' then
            data_o <= ram_image(to_integer(unsigned(addr)));
            if wren = '1' then
                ram_image(to_integer(unsigned(addr))) <= data_i;
            end if;
        end if;
    end process;
end ram_arch;
