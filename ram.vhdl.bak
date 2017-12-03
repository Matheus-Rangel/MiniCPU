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
        0 => "1111010010010000",
        1 => "0010011111110110",
        2 => "1111011011011000",
        3 => "0100000000000000",
        4 => "1001011010000000",
        5 => "1111000000000000",
        6 => "0010000000000000",
        7 => "1111001001001000",
        8 => "0000111100000000",
        9 => "1111011011011000",
        10 => "0000000000000000",
        11 => "1100011001000101",
        12 => "1001000010000000",
        13 => "1110001001111111",
        14 => "1110000000000001",
        15 => "1100000000111100",
        16 => "1111101101101000",
        17 => "0100000000000010",
        18 => "1111011011011000",
        19 => "0010000000000000",
        20 => "1001101011000000",
        21 => "1111101101101000",
        22 => "1100001101010000",
        23 => "1111011011011000",
        24 => "0000000000000000",
        25 => "1100011101000110",
        26 => "1110101101111111",
        27 => "1111000000000000",
        28 => "0100000000000001",
        29 => "1001000010000000",
        30 => "1100000000111011",
        31 => "1110010010000001",
        32 => "1111101101101000",
        33 => "0000000001111011",
        others => "1100000000100011"
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
