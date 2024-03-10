library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use std.textio.all;
use work.txt_util.all;

entity ip_test is
end ip_test;

architecture Behavioral of ip_test is

    file slika_bits : text open read_mode is
	"C:\Users\DK\Desktop\ip_v20_3\ip_repo\slika_bits.txt";
	file centri_bits : text open read_mode is
	"C:\Users\DK\Desktop\ip_v20_3\ip_repo\centri_bits.txt";
	file izlazi_bits : text open read_mode is
	"C:\Users\DK\Desktop\ip_v20_3\ip_repo\izlazi\izlaz_bits.txt";
	file izlaz : text open write_mode is "C:/Users/DK/Desktop/ip_v20_3/ip_repo/izlazi/izlazi_ip.txt";  

    constant WIDTH : integer := 8;
    constant cols_c : integer := 100;
    constant rows_c : integer := 100;
    constant clusters_c : integer := 6;
        
    ---------------------------------------------------------------
    
    signal clk_s: std_logic;
    signal reset_s: std_logic;
    
    ----------------------IP registers-----------------------------
    
    constant ROWS_REG_ADDR_C : integer := 0;
    constant COLS_REG_ADDR_C : integer := 4;
    constant CMD_REG_ADDR_C : integer := 8;
    constant STATUS_REG_ADDR_C : integer := 12;
    
    ------------------Ports for BRAM Initialization-----------------
    
    signal tb_a_en_i : std_logic;
    signal tb_a_addr_i : std_logic_vector(4*WIDTH-1 downto 0);
    signal tb_a_data_i : std_logic_vector(3*WIDTH-1 downto 0);
    signal tb_a_we_i : std_logic;
    
    signal tb_b_en_i : std_logic;
    signal tb_b_addr_i : std_logic_vector(4*WIDTH-1 downto 0);
    signal tb_b_data_i : std_logic_vector(3*WIDTH-1 downto 0);
    signal tb_b_we_i : std_logic; 
    
    signal tb_c_en_i : std_logic;
    signal tb_c_addr_i : std_logic_vector(4*WIDTH-1 downto 0);
    signal tb_c_data_o : std_logic_vector(3*WIDTH-1 downto 0);
    signal tb_c_we_i : std_logic;
    
    ------------------------- Ports to IP ---------------------
    
    signal ip_a_en : std_logic;
    signal ip_a_we : std_logic;
    signal ip_a_addr : std_logic_vector(4*WIDTH-1 downto 0);
    signal ip_a_data: std_logic_vector(3*WIDTH-1 downto 0);
    
    signal ip_b_en : std_logic;
    signal ip_b_we : std_logic;
    signal ip_b_addr : std_logic_vector(4*WIDTH-1 downto 0);
    signal ip_b_data: std_logic_vector(3*WIDTH-1 downto 0);
    
    signal ip_c_en : std_logic;
    signal ip_c_we : std_logic;
    signal ip_c_addr : std_logic_vector(4*WIDTH-1 downto 0);
    signal ip_c_data: std_logic_vector(3*WIDTH-1 downto 0);
    
    ------------------- AXI Interfaces signals ----------------------
    
    -- Parameters of Axi-Lite Slave Bus Interface S00_AXI
    constant C_S00_AXI_DATA_WIDTH_c : integer := 32;
    constant C_S00_AXI_ADDR_WIDTH_c : integer := 4;
    
    -- Ports of Axi-Lite Slave Bus Interface S00_AXI
    signal s00_axi_aclk_s : std_logic := '0';
    signal s00_axi_aresetn_s : std_logic := '1';
    signal s00_axi_awaddr_s : std_logic_vector(C_S00_AXI_ADDR_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_awprot_s : std_logic_vector(2 downto 0) := (others => '0');
    signal s00_axi_awvalid_s : std_logic := '0';
    signal s00_axi_awready_s : std_logic := '0';
    signal s00_axi_wdata_s : std_logic_vector(C_S00_AXI_DATA_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_wstrb_s : std_logic_vector((C_S00_AXI_DATA_WIDTH_c/8)-1 downto 0) := (others => '0');
    signal s00_axi_wvalid_s : std_logic := '0';
    signal s00_axi_wready_s : std_logic := '0';
    signal s00_axi_bresp_s : std_logic_vector(1 downto 0) := (others => '0');
    signal s00_axi_bvalid_s : std_logic := '0';
    signal s00_axi_bready_s : std_logic := '0';
    signal s00_axi_araddr_s : std_logic_vector(C_S00_AXI_ADDR_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_arprot_s : std_logic_vector(2 downto 0) := (others => '0');
    signal s00_axi_arvalid_s : std_logic := '0';
    signal s00_axi_arready_s : std_logic := '0';
    signal s00_axi_rdata_s : std_logic_vector(C_S00_AXI_DATA_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_rresp_s : std_logic_vector(1 downto 0) := (others => '0');
    signal s00_axi_rvalid_s : std_logic := '0';
    signal s00_axi_rready_s : std_logic := '0';
    
    begin
    reset_s <= not s00_axi_aresetn_s; --reset for BRAM
    
    clk_gen: process is
    begin
        clk_s <= '0', '1' after 10 ns;
        wait for 20 ns;
    end process;
    
    stimulus_generator: process
    variable tv_slika, tv_centri : line;
    begin
    report "Start !";

    -- reset AXI-lite interface. Reset will be 10 clock cycles wide
    s00_axi_aresetn_s <= '0';
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    -- release reset
    s00_axi_aresetn_s <= '1';
    wait until falling_edge(clk_s);
    
    
    ----------------------------------------------------------------------
    -- Initialize the core --
    ----------------------------------------------------------------------
     report "Loading the picture dimensions into the core!" ;
    
    -- Set the value for COLS
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(COLS_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(cols_c, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s); 
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
   
    
    -- Set the value for ROWS
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(ROWS_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(rows_c, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
     
    -------------------------------------------------------------------------------------------
    -- Load the picture into the memory  --
    -------------------------------------------------------------------------------------------
    report "Loading picture into the memory!" ;
	  
    wait until falling_edge(clk_s);
    
    for i in 0 to (rows_c*cols_c)-1 loop 
        wait until falling_edge(clk_s);
        readline(slika_bits, tv_slika);
        tb_a_en_i <= '1';
        tb_a_addr_i <= conv_std_logic_vector( i*4 , 4*WIDTH); 
        tb_a_data_i <= to_std_logic_vector(string(tv_slika));
        tb_a_we_i <= '1';
        
        for i in 1 to 3 loop
            wait until falling_edge(clk_s);
        end loop;
        tb_a_en_i <= '0';
        tb_a_we_i <= '0';
    end loop;
    tb_a_en_i <= '0';
    tb_a_we_i <= '0';
    
    
    -------------------------------------------------------------------------------------------
    -- Load the centers into the memory --
    -------------------------------------------------------------------------------------------
    report "Loading centers into the memory!";
    
	  for j in 0 to clusters_c - 1 loop
	  
        wait until falling_edge(clk_s);
        readline(centri_bits,tv_centri);
        tb_b_en_i <= '1';
        tb_b_we_i <= '1';
        tb_b_addr_i <= conv_std_logic_vector( j*4 , 4*WIDTH ); 
		tb_b_data_i <= to_std_logic_vector(string(tv_centri));
        
        for i in 1 to 3 loop
            wait until falling_edge(clk_s);
        end loop;
        tb_b_en_i <= '0';
        tb_b_we_i <= '0';
    end loop;
    tb_b_en_i <= '0';
    tb_b_we_i <= '0';
    
    -------------------------------------------------------------------------------------------
    -- Start the ip core --
    -------------------------------------------------------------------------------------------
    report "Starting proccesing!";
    -- Set the start bit (bit 0 in the CMD register) to 1
    
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(CMD_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(1, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
     -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;


    report "Clearing the start bit!";
    -- Set the start bit (bit 0 in the CMD register) to 0
    
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(CMD_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
     -------------------------------------------------------------------------------------------
    -- Wait until ip core finishes processing --
    -------------------------------------------------------------------------------------------
    report "Waiting for the process to complete!";
    loop
        -- Read the content of the Status register
        wait until falling_edge(clk_s);
        s00_axi_araddr_s <= conv_std_logic_vector(STATUS_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_arvalid_s <= '1';
        s00_axi_rready_s <= '1';
        wait until s00_axi_arready_s = '1';
        wait until s00_axi_arready_s = '0';
        wait until falling_edge(clk_s);
        s00_axi_araddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_arvalid_s <= '0';
        s00_axi_rready_s <= '0';
        
       
        
        -- Check is the 1st bit of the Status register set to one
        if (s00_axi_rdata_s(0) = '1') then
            -- ip core done
             report "IP core is done!";
            exit;
        else
            wait for 1000 ns;
        end if;
    end loop;
    
    -------------------------------------------------------------------------------------------
    -- Read the output --
    -------------------------------------------------------------------------------------------
    report "Reading the results of from output memory!";

	for k in 0 to (cols_c*rows_c) loop
        wait until falling_edge(clk_s);
        tb_c_en_i <= '1';
        tb_c_we_i <= '0';
        tb_c_addr_i <= conv_std_logic_vector ( k*4 , 4*WIDTH);
    end loop;
    
    tb_c_en_i <= '0';
    report "Finished!";
    report "RESULTS MATCH!";
    wait;
    
end process;

write_to_output_file : process(clk_s)
    variable data_output_line : line;
    variable data_output_string : string(1 to 24) := (others => '0'); 
begin
    if falling_edge(clk_s) then
    if tb_c_en_i = '1' then
    data_output_string := (others => '0');
    
    for i in 0 to 23 loop
        if tb_c_data_o(i) = '1' then
    
            data_output_string(24 - i) := '1';  
        else
            data_output_string(24 - i) := '0';  
        end if;
    end loop;          
    write(data_output_line, data_output_string);
    writeline(izlaz, data_output_line);
      
    end if;
    end if;
end process;

checker : process(clk_s)
    variable tv_izlazi : line;  
    variable tmp: std_logic_vector(3*WIDTH-1 downto 0); 
begin              
        if falling_edge (clk_s) then
        if tb_c_en_i = '1' then
        readline(izlazi_bits, tv_izlazi);
        tmp := to_std_logic_vector(string(tv_izlazi));
        if (tmp /= tb_c_data_o) then
        report "RESULT MISMATCH" severity failure;
        --if (tmp = tb_c_data_o) then
        --report "RESULT MATCH" severity failure;
        end if;
        end if;
        end if;
end process;

---------------------------------------------------------------------------
---- DUT --
---------------------------------------------------------------------------
uut: entity work.ip_v1_0(arch_imp)
    generic map(   WIDTH => WIDTH  )
             
    port map (
        -- Interfejs za sliku
        ena     => ip_a_en,
        wea     => ip_a_we,
        addra   => ip_a_addr,
        dina    => open,
        douta   => ip_a_data,
        reseta  => open,
        clka    => open,
        
        -- Interfejs za centre
        
        enb     => ip_b_en,
        web     => ip_b_we,
        addrb   => ip_b_addr,
        dinb    => open,
        doutb   => ip_b_data,
        resetb  => open,
        clkb    => open,
        
        -- Interfejs za izlaz
        
        enc     => ip_c_en,
        wec     => ip_c_we,
        addrc   => ip_c_addr,
        dinc    => ip_c_data,
        doutc   =>(others=>'0'),
        resetc  => open,
        clkc    => open,

        -- Ports of Axi Slave Bus Interface S00_AXI
        s00_axi_aclk    => clk_s,
        s00_axi_aresetn => s00_axi_aresetn_s,
        s00_axi_awaddr  => s00_axi_awaddr_s,
        s00_axi_awprot  => s00_axi_awprot_s, 
        s00_axi_awvalid => s00_axi_awvalid_s,
        s00_axi_awready => s00_axi_awready_s,
        s00_axi_wdata   => s00_axi_wdata_s,
        s00_axi_wstrb   => s00_axi_wstrb_s,
        s00_axi_wvalid  => s00_axi_wvalid_s,
        s00_axi_wready  => s00_axi_wready_s,
        s00_axi_bresp   => s00_axi_bresp_s,
        s00_axi_bvalid  => s00_axi_bvalid_s,
        s00_axi_bready  => s00_axi_bready_s,
        s00_axi_araddr  => s00_axi_araddr_s,
        s00_axi_arprot  => s00_axi_arprot_s,
        s00_axi_arvalid => s00_axi_arvalid_s,
        s00_axi_arready => s00_axi_arready_s,
        s00_axi_rdata   => s00_axi_rdata_s,
        s00_axi_rresp   => s00_axi_rresp_s,
        s00_axi_rvalid  => s00_axi_rvalid_s,
        s00_axi_rready  => s00_axi_rready_s);
        
Bram_A: entity work.bram(Behavioral) --Slika
    generic map( WIDTH => WIDTH)                            
    port map(
               clka => clk_s,
               clkb => clk_s,
	           reseta=> reset_s,
	           ena=>tb_a_en_i,
	           wea=> tb_a_we_i,
	           addra=> tb_a_addr_i,
	           dia=> tb_a_data_i,
	           doa=> open,
	
	           resetb=>reset_s,
	           enb=>ip_a_en,
	           web=>ip_a_we,
	           addrb=>ip_a_addr,
	           dib=>(others=>'0'),
	           dob=> ip_a_data
	        );
	        
Bram_B: entity work.bram(Behavioral) --Centri
    generic map( WIDTH  =>  WIDTH )
             
    port map(
               clka => clk_s,
               clkb => clk_s,
               reseta=> reset_s,
	           ena=>tb_b_en_i,
	           wea=> tb_b_we_i,
	           addra=> tb_b_addr_i,
	           dia=> tb_b_data_i,
	           doa=> open,
	
	           resetb=>reset_s,
	           enb=>ip_b_en,
	           web=>ip_b_we,
	           addrb=>ip_b_addr,
	           dib=>(others=>'0'),
	           dob=> ip_b_data
	        );    
	        
Bram_C: entity work.bram(Behavioral)
    generic map( WIDTH  =>  WIDTH   ) --Izlaz
              
    port map(
               clka => clk_s,
               clkb => clk_s,
	           reseta=> reset_s,
	           ena=> ip_c_en, 
	           wea=> ip_c_we , 
	           addra=> ip_c_addr , 
	           dia=> ip_c_data , 
	           doa=> open,
	
	           resetb=>reset_s,
	           enb=> tb_c_en_i,
	           web=> tb_c_we_i,
	           addrb=> tb_c_addr_i,
	           dib=> (others=>'0'),
	           dob=> tb_c_data_o
	        );
    
end Behavioral;
