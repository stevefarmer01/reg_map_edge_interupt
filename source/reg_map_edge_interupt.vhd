----------------------------------------------------------------------------------
-- Company: FFEI
-- Engineer: Steve Farmer
-- 
-- Create Date: 04.02.2016 23:33:56
-- Design Name: common_ip
-- Module Name: reg_map_edge_interupt - Behavioral
-- Project Name: Griffin
-- Target Devices: 
-- Tool Versions: 
-- Description: Common IP module for edge detection and generating interupts in GDRB in Griffin system
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg_map_edge_interupt is
    generic (
             reg_width : positive := 16
             );
    Port ( 
          clk : in std_logic;
          status_reg : in std_logic_vector(reg_width-1 downto 0) := (others => '0');
          edge_detect_toggle_en : in std_logic := '0';
          edge_detect_toggle_reg : in std_logic_vector(reg_width-1 downto 0) := (others => '0');
          edge_detect_reg : out std_logic_vector(reg_width-1 downto 0) := (others => '0');
          interupt_mask_reg : in std_logic_vector(reg_width-1 downto 0) := (others => '0');
          interupt_flag : out std_logic := '0'
          );
end reg_map_edge_interupt;

architecture Behavioral of reg_map_edge_interupt is

signal edge_detect_reg_s : std_logic_vector(reg_width-1 downto 0) := (others => '0');

begin

edge_detect_reg <= edge_detect_reg_s;

edge_detect_proc : process
    variable edge_detect_toggle_en_v : std_logic := '0';
    variable status_reg_v, edge_detect_toggle_reg_v : std_logic_vector(status_reg'RANGE) := (others => '0');
begin
    wait until rising_edge(clk);
    for i in status_reg'RANGE loop
        if edge_detect_toggle_reg(i) = '1' and (edge_detect_toggle_en_v = '0' and edge_detect_toggle_en = '1') then -- If revelant toggle bit has just had a '1' written to it..
            edge_detect_reg_s(i) <= not edge_detect_reg_s(i);                                                     -- ..toggle detect bit
        elsif status_reg_v(i) /= status_reg(i) then                                              							-- If +ve or -ve edge detected on status bit then..
            edge_detect_reg_s(i) <= '1';                                                                        -- .. set edge detect bit
        end if;
    end loop;
    edge_detect_toggle_en_v := edge_detect_toggle_en;
    status_reg_v := status_reg;
end process;

interupt_proc : process
begin
    wait until rising_edge(clk);
    interupt_flag <= '0';                                           -- Default interupt to not active
    for i in status_reg'RANGE loop
        if interupt_mask_reg(i) = '1' and edge_detect_reg_s(i) = '1' then -- Any unmasked edge detect that is high will activate/keep active interupt (all must be masked or cleared to deactivate interupt)
            interupt_flag <= '1';
        end if;
    end loop;
end process;

end Behavioral;
