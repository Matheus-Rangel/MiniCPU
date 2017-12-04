library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers is
    generic (
        DATA_WIDTH : integer := 16
    );
    port (
        clock  : in std_logic;
        reset 	: in std_logic;
		  wren   : in std_logic;
        addr   : in std_logic_vector(2 downto 0);
        data_i : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        data_o : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end registers;

architecture reg_arch of registers is
    type reg_t is array (0 to 2**3 - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal reg_image : reg_t := (others => x"0000");
begin
    process (clock)
    begin
        if clock'event and clock = '1' then
            data_o <= reg_image(to_integer(unsigned(addr)));
            if wren = '1' then
                reg_image(to_integer(unsigned(addr))) <= data_i;
            end if;
				if reset = '1' then
					reg_image <= (others => x"0000");
				end if;
        end if;
    end process;
end reg_arch;
