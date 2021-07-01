library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

entity alarm is
    port(
        clk,rst: in std_logic;
        CT,WT: in std_logic_vector(15 downto 0);
        alarm: out std_logic
    );
end entity alarm;

architecture HLSM of alarm is
    type stateType is (S_init,S_off,S_on);
    signal currState,nextState : stateType;
    signal currPrev1,currPrev2,currPrev3,currPrev4,nextPrev2,nextPrev3,nextPrev4,currAvg,nextAvg: std_logic_vector(15 downto 0);
    
begin
    
    regs: process(clk,rst)
    begin
        if (rst='1') then
            currState<=S_init;
            currPrev1<=(others => '0');
            currPrev2<=(others => '0');
            currPrev3<=(others => '0');
            currPrev4<=(others => '0');
            currAvg<=(others => '0');
        elsif (rising_edge(clk)) then
            currState<=nextState;
            currPrev1<=CT;
            currPrev2<=nextPrev2;
            currPrev3<=nextPrev3;
            currPrev4<=nextPrev4;
            currAvg<=nextAvg;
        end if;
    end process regs;
    
    comb: process(currState,WT,currPrev1,currPrev2,currPrev3,currPrev4,currAvg)
    variable sum: integer :=0;
    begin
        case currState is
            when S_init => alarm<='0';nextPrev2<=(others => '0');nextPrev3<=(others => '0');nextPrev4<=(others => '0');nextAvg<=(others => '0'); nextState<=S_off;
            
            when S_off => alarm <='0'; nextPrev2<=currPrev1; nextPrev3<=currPrev2; nextPrev4<=currPrev3;
                          sum := integer(ceil(real((to_integer(unsigned(currPrev1))+to_integer(unsigned(currPrev2))+to_integer(unsigned(currPrev3))+to_integer(unsigned(currPrev4)))/4)));
                          nextAvg<=std_logic_vector(to_unsigned(sum,nextAvg'length));
                          if(currAvg > WT) then
                            nextState<=S_on;
                          else
                            nextState<=S_off;
                          end if;
            when S_on  => alarm <='1'; nextPrev2<=currPrev1; nextPrev3<=currPrev2; nextPrev4<=currPrev3;
                          sum := integer(ceil(real((to_integer(unsigned(currPrev1))+to_integer(unsigned(currPrev2))+to_integer(unsigned(currPrev3))+to_integer(unsigned(currPrev4)))/4)));
                          nextAvg<=std_logic_vector(to_unsigned(sum,nextAvg'length));
                          if(currAvg > WT) then
                            nextState<=S_on;
                          else
                            nextState<=S_off;
                          end if;
            when others=> nextState<=S_off; alarm<='0';nextPrev2<=(others => '0');nextPrev3<=(others => '0');nextPrev4<=(others => '0');nextAvg<=(others => '0');
                          
                                        
        end case;
    end process comb;

end HLSM;

architecture FSMD of alarm is
    -- shared cntl
    signal avg_gt,p2_sel,p3_sel,p4_sel: std_logic;
    
    -- datapath signals
    signal currPrev1,currPrev2,currPrev3,currPrev4,nextPrev1,nextPrev2,nextPrev3,nextPrev4,currAvg,nextAvg,p4_in,p2_in,p1_in,p3_in,add1_out,add2_out,add3_out: std_logic_vector(15 downto 0);
    
    -- FSM signals
    type stateType is (S_init,S_off,S_on);
    signal currState,nextState : stateType;
    
    
begin
    -- DP
    DPregs: process(clk,rst)
    begin
        if (rst='1') then
            currPrev1<=(others => '0');
            currPrev2<=(others => '0');
            currPrev3<=(others => '0');
            currPrev4<=(others => '0');
            currAvg<=(others => '0');
        elsif (rising_edge(clk)) then
            currPrev1<=nextPrev1;
            currPrev2<=nextPrev2;
            currPrev3<=nextPrev3;
            currPrev4<=nextPrev4;
            currAvg<=nextAvg;
        end if;
    end process DPregs;
    
    DPcomb: process(p2_sel,p3_sel,p4_sel,CT,WT,currPrev1,currPrev2,currPrev3,currPrev4,currAvg,add1_out,add2_out,add3_out)
    begin
        nextPrev1<=CT;
        
        if(p2_sel='1') then
            nextPrev2<=currPrev1;
        else
            nextPrev2<=(others=>'0');
        end if;
        
        if(p3_sel='1') then
            nextPrev3<=currPrev2;
        else
            nextPrev3<=(others=>'0');
        end if;
        
        if(p4_sel='1') then
            nextPrev4<=currPrev3;
        else
            nextPrev4<=(others=>'0');
        end if;
        
        add1_out<=std_logic_vector(unsigned(currPrev4)+unsigned(currPrev1));
        add2_out<=std_logic_vector(unsigned(add1_out)+unsigned(currPrev2));
        add3_out<=std_logic_vector(unsigned(add2_out)+unsigned(currPrev3));
        nextAvg<=std_logic_vector(TO_UNSIGNED(integer(ceil(real(to_integer(unsigned(add3_out))/4))),nextAvg'length));
        
        if(currAvg>WT) then
            avg_gt<='1';
        else
            avg_gt<='0';
        end if;
        
    end process DPcomb;
    
    
    
    -- FSM
    
    FSMregs: process(clk,rst)
    begin
        if (rst='1') then
            currState<=S_init;
        elsif (rising_edge(clk)) then
            currState<=nextState;
        end if;
    end process FSMregs;
    
    
    comb: process(currState,avg_gt)
    begin
        case currState is
            when S_init => alarm<='0'; nextState<=S_off; p2_sel<='0'; p3_sel<='0'; p4_sel<='0';
            
            when S_off => alarm <='0'; p2_sel<='1'; p3_sel<='1'; p4_sel<='1';
                          if(avg_gt='1') then
                            nextState<=S_on;
                          else
                            nextState<=S_off;
                          end if;
            when S_on  => alarm <='1'; p2_sel<='1'; p3_sel<='1'; p4_sel<='1';
                          if(avg_gt='1') then
                            nextState<=S_on;
                          else
                            nextState<=S_off;
                          end if;
            when others=> nextState<=S_off; alarm<='0'; p2_sel<='0'; p3_sel<='0'; p4_sel<='0';
                                        
        end case;
    end process comb;

end FSMD;
