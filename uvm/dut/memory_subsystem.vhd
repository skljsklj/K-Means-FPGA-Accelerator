library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use work.utils_pkg.all;

entity memory_subsystem is
    generic ( WIDTH: integer := 8 );
    port ( 
            clk : in std_logic;
            reset: in std_logic;
            
            -- Interface to the AXI controllers
            reg_data_i : in std_logic_vector (WIDTH-1 downto 0);
            rows_wr_i : in std_logic;
            cols_wr_i : in std_logic;
            cmd_wr_i: in std_logic;
            
            rows_axi_o: out std_logic_vector(WIDTH-1 downto 0);
            cols_axi_o: out std_logic_vector(WIDTH-1 downto 0);
            cmd_axi_o: out std_logic;
            status_axi_o: out std_logic;
            
            -- Interface to the IP module
            rows_o : out std_logic_vector(WIDTH-1 downto 0);
            cols_o : out std_logic_vector(WIDTH-1 downto 0);
            start_o: out std_logic;
            ready_i: in std_logic );
            
end memory_subsystem;

architecture Behavioral of memory_subsystem is

    signal rows_s, cols_s : std_logic_vector(WIDTH-1 downto 0);
    signal cmd_s, status_s : std_logic;
    
    --signal mem_data_wr_slika_o, mem_data_wr_centri_o : std_logic;
    --signal mem_data_rd_slika_o, mem_data_rd_centri_o : std_logic;
    
    --signal addr_s : std_logic_vector (2*WIDTH downto 0);

begin
    rows_o <= rows_s;
    start_o <= cmd_s;
    cols_o <= cols_s;
    start_o <= cmd_s;
    -----------------REGISTERS-----------------
    rows_axi_o <= rows_s;
    cols_axi_o <= cols_s;
    cmd_axi_o <= cmd_s;
    status_axi_o <= status_s;
    
    -- rows register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                rows_s <= (others => '0');
            elsif rows_wr_i = '1' then
                rows_s <= reg_data_i (WIDTH-1 downto 0);
            end if;
        end if;   
    end process;
    
    -- cols register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                cols_s <= (others => '0');
            elsif cols_wr_i = '1' then
                cols_s <= reg_data_i (WIDTH-1 downto 0);
            end if;
        end if;   
    end process;
    
    -- cmd register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                cmd_s <= '0';
            elsif cmd_wr_i = '1' then
                cmd_s <= reg_data_i(0);
            end if;
        end if;   
    end process;
    
    -- status register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                status_s <= '0';
            else
                status_s <= ready_i;
            end if;
        end if;   
    end process;
    
end Behavioral;
