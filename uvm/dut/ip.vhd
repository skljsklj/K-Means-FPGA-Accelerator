----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 02/16/2024 12:10:51 PM
-- Design Name:
-- Module Name: ip - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;

entity ip is
	generic (
		WIDTH : integer := 8
	);

	port (
	    ---------------REGISTRI----------------------------------
		rows_i : in std_logic_vector (WIDTH - 1 downto 0);
		cols_i : in std_logic_vector (WIDTH - 1 downto 0);
		---------------------------------------------------------
		clk : in std_logic;
		reset : in std_logic;
		---------------MEM INTERFEJS ZA SLIKU--------------------
		addr_di_o : out std_logic_vector (4 * WIDTH - 1 downto 0);
		data_i : in std_logic_vector (3 * WIDTH - 1 downto 0);
		ctrl_data_o : out std_logic;
		---------------MEM INTERFEJS ZA CENTRE-------------------
		addr_clusters_o : out std_logic_vector (4 * WIDTH - 1 downto 0);
		clusters_Centers_i : in std_logic_vector (3 * WIDTH - 1 downto 0);
        ctrl_clusters_Centers_o : out std_logic;
		---------------MEM INTERFEJS ZA IZLAZ--------------------
		addr_do_o : out std_logic_vector (4 * WIDTH - 1 downto 0);
		data_o : out std_logic_vector (3 * WIDTH - 1 downto 0);
		c_data_o : out std_logic;
		---------------KOMANDNI INTERFEJS------------------------
        start_i : in std_logic;
        ---------------STATUSNI INTERFEJS------------------------
		ready_o : out std_logic
		
	);
end ip;

architecture Behavioral of ip is
	type state_type is (idle, sqrt, l0, l1, l2, l3, l4, l5, l6, l7, l8);
	signal state_reg, state_next : state_type;
	signal i_reg, i_next : unsigned(WIDTH - 1 downto 0);
	signal j_reg, j_next : unsigned(WIDTH - 1 downto 0);
	signal k_reg, k_next : unsigned(WIDTH - 1 downto 0);
	signal op_reg, op_next : unsigned(4 * WIDTH - 1 downto 0);
	signal res_reg, res_next : unsigned(4 * WIDTH - 1 downto 0);
	signal one_reg, one_next : unsigned(4 * WIDTH - 1 downto 0);
	signal diff_blue_reg, diff_blue_next : signed(2 * WIDTH - 1 downto 0);
	signal diff_green_reg, diff_green_next : signed(2 * WIDTH - 1 downto 0);
	signal diff_red_reg, diff_red_next : signed(2 * WIDTH - 1 downto 0);
	signal closestClusterIndex_reg, closestClusterIndex_next : unsigned(WIDTH - 1 downto 0);
	signal min_dis_reg, min_dis_next : unsigned(4 * WIDTH - 1 downto 0);

begin
	--State and data registers
	process (clk, reset)
	begin
		if reset = '1' then
			state_reg <= idle;
			i_reg <= (others => '0');
			j_reg <= (others => '0');
			k_reg <= (others => '0');
			diff_blue_reg <= (others => '0');
			diff_green_reg <= (others => '0');
			diff_red_reg <= (others => '0');
			closestClusterIndex_reg <= (others => '0');
			min_dis_reg <= (others => '0');
			op_reg <= (others => '0');
			res_reg <= (others => '0');
			one_reg <= (others => '0');
		elsif (rising_edge(clk)) then
			state_reg <= state_next;
			i_reg <= i_next;
			j_reg <= j_next;
			k_reg <= k_next;
			diff_blue_reg <= diff_blue_next;
			diff_green_reg <= diff_green_next;
			diff_red_reg <= diff_red_next;
			closestClusterIndex_reg <= closestClusterIndex_next;
			min_dis_reg <= min_dis_next;
			op_reg <= op_next;
			res_reg <= res_next;
			one_reg <= one_next;

		end if;
	end process;

	--Combinatorial circuits
	process (state_reg, start_i, data_i, clusters_Centers_i, i_reg, j_reg, k_reg, diff_blue_reg, diff_green_reg, diff_red_reg, closestClusterIndex_reg, 
	 min_dis_reg, i_next, j_next, k_next, diff_blue_next, diff_green_next, diff_red_next, closestClusterIndex_next, 
	 min_dis_next, rows_i, cols_i, op_reg, op_next, res_reg, res_next, one_reg, one_next)

		begin
			state_next <= state_reg;
			i_next <= i_reg;
			j_next <= j_reg;
			k_next <= k_reg;
			diff_blue_next <= diff_blue_reg;
			diff_green_next <= diff_green_reg;
			diff_red_next <= diff_red_reg;
			closestClusterIndex_next <= closestClusterIndex_reg;
			min_dis_next <= min_dis_reg;
			op_next <= op_reg;
			res_next <= res_reg;
			one_next <= one_reg;
 
			addr_di_o <= std_logic_vector ((i_reg * unsigned(cols_i) + j_reg) * 4);
			addr_clusters_o <= std_logic_vector (resize(k_reg * 4, 4*WIDTH));	
			addr_do_o <= std_logic_vector((i_reg * unsigned(cols_i) + j_reg) * 4);		          
			
			ctrl_data_o <= '1';
			ctrl_clusters_Centers_o <= '1'; 
			c_data_o <= '0';
			
			data_o <= (others => '0');
			 
			ready_o <= '0';
 
			case state_reg is
 
				when idle => 
				    ready_o <= '1';
					if start_i = '1' then
						i_next <= TO_UNSIGNED (0, WIDTH);
						state_next <= l0;
					else
						state_next <= idle;
					end if;

				when l0 => 

					j_next <= TO_UNSIGNED(0, WIDTH);
					state_next <= l1;

				when l1 => 
 
					k_next <= TO_UNSIGNED (0, WIDTH);
					closestClusterIndex_next <= TO_UNSIGNED (0, WIDTH);
					min_dis_next <= TO_UNSIGNED (443 * 4096, 4 * WIDTH);
					state_next <= l2;

				when l2 => 
 
					state_next <= l3; --Update signals				
 
				when l3 => 				    
			        
					diff_blue_next <= signed(resize(unsigned(data_i(23 downto 16)), 2 * WIDTH)) - signed(resize(unsigned(clusters_Centers_i(23 downto 16)), 2 * WIDTH));
					diff_green_next <= signed(resize(unsigned(data_i(15 downto 8)), 2 * WIDTH)) - signed(resize(unsigned(clusters_Centers_i(15 downto 8)), 2 * WIDTH));
					diff_red_next <= signed(resize(unsigned(data_i(7 downto 0)), 2 * WIDTH)) - signed(resize(unsigned(clusters_Centers_i(7 downto 0)), 2 * WIDTH)); 
					state_next <= sqrt;
 
				when sqrt => 
 
					op_next <= (unsigned((diff_blue_reg * diff_blue_reg)) + unsigned((diff_green_reg * diff_green_reg)) + unsigned((diff_red_reg * diff_red_reg))) sll 12;
					res_next <= to_unsigned(0, 4 * WIDTH);
					one_next <= shift_left (to_unsigned(1, 4 * WIDTH), 30);

					state_next <= l4;

				when l4 => 
 
					if (one_reg > op_reg) then
						one_next <= shift_right(unsigned(one_reg), 2);
						state_next <= l4;
					else
						state_next <= l5;
					end if;

				when l5 => 
 
					if (op_reg >= (res_reg + one_reg)) then
						op_next <= op_reg - (res_reg + one_reg);
						res_next <= res_reg + one_reg + one_reg;
					end if;
					state_next <= l6;
 
				when l6 => 
 
					res_next <= shift_right(unsigned(res_reg), 1);
					one_next <= shift_right(unsigned(one_reg), 2);
					if (one_next /= to_unsigned(0, WIDTH)) then
						state_next <= l5;
					else
						state_next <= l7;
					end if;

				when l7 => 
 
					if (res_reg < min_dis_reg) then
						min_dis_next <= res_reg;
						closestClusterIndex_next <= k_reg;
					end if;
					state_next <= l8;
 
				when l8 => 
 
					k_next <= k_reg + 1; 
					if (k_next /= 6) then 
						state_next <= l2; 
					else 					    
						c_data_o <= '1'; 
						data_o <= std_logic_vector(j_reg) & std_logic_vector(i_reg) & std_logic_vector(closestClusterIndex_reg); 
						j_next <= j_reg + 1;
						if (j_next /= unsigned(cols_i)) then
							state_next <= l1;
						else
							i_next <= i_reg + 1;
							if (i_next = unsigned(rows_i)) then
								state_next <= idle;
							else
								state_next <= l0;
							end if;
						end if;
					end if;
			end case;
		end process;

end Behavioral;