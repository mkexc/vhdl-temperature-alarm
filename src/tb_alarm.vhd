library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity tb_alarm is
end tb_alarm;

architecture Behavioral of tb_alarm is
    component alarm is
        port(
            clk,rst: in std_logic;
            CT,WT: in std_logic_vector(15 downto 0);
            alarm: out std_logic
        );
    end component alarm;
    
    signal clk_s,rst_s,alarm_s,alarmFSMD_s: std_logic;
    signal CT_s,WT_s: std_logic_vector(15 downto 0);
    constant clkper: time := 10 ns;
    
    for HLSM:alarm use entity work.alarm(HLSM);
    for FSMD:alarm use entity work.alarm(FSMD);
    
begin

    HLSM: alarm port map(clk=>clk_s,rst=>rst_s,CT=>CT_s,WT=>WT_s,alarm=>alarm_s);
    FSMD: alarm port map(clk=>clk_s,rst=>rst_s,CT=>CT_s,WT=>WT_s,alarm=>alarmFSMD_s);
    

    process
    begin
        clk_s<='0';
        wait for clkper/2;
        clk_s<='1';
        wait for clkper/2;
    end process;
    
    process
    begin
        rst_s<='1'; CT_s<=std_logic_vector(TO_UNSIGNED(30,CT_s'length));
        WT_s<=std_logic_vector(TO_UNSIGNED(20,WT_s'length));
        wait for clkper;
        rst_s<='0'; 
        wait for clkper;
        CT_s<=std_logic_vector(TO_UNSIGNED(30,CT_s'length));
        WT_s<=std_logic_vector(TO_UNSIGNED(20,WT_s'length));
        wait for clkper;
        CT_s<=std_logic_vector(TO_UNSIGNED(30,CT_s'length));
        WT_s<=std_logic_vector(TO_UNSIGNED(20,WT_s'length));
        wait for clkper;
        CT_s<=std_logic_vector(TO_UNSIGNED(30,CT_s'length));
        WT_s<=std_logic_vector(TO_UNSIGNED(20,WT_s'length));
        wait for clkper;
        CT_s<=std_logic_vector(TO_UNSIGNED(30,CT_s'length));
        WT_s<=std_logic_vector(TO_UNSIGNED(20,WT_s'length));
        wait for clkper;
        CT_s<=std_logic_vector(TO_UNSIGNED(30,CT_s'length));
        WT_s<=std_logic_vector(TO_UNSIGNED(100,WT_s'length));
        wait for clkper;
        CT_s<=std_logic_vector(TO_UNSIGNED(110,CT_s'length));
        WT_s<=std_logic_vector(TO_UNSIGNED(100,WT_s'length));
        wait for clkper;
        CT_s<=std_logic_vector(TO_UNSIGNED(120,CT_s'length));
        WT_s<=std_logic_vector(TO_UNSIGNED(100,WT_s'length));
        wait for clkper;
        CT_s<=std_logic_vector(TO_UNSIGNED(70,CT_s'length));
        WT_s<=std_logic_vector(TO_UNSIGNED(100,WT_s'length));
        wait for clkper;
        CT_s<=std_logic_vector(TO_UNSIGNED(150,CT_s'length));
        WT_s<=std_logic_vector(TO_UNSIGNED(100,WT_s'length));
        wait for clkper;
        
        wait for clkper;
        wait;
        
    end process;
end Behavioral;
