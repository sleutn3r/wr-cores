---------------------------------------------------------------------
----                                                             ----
----  Reed Solomon decoder/encoder IP core                       ----
----                                                             ----
----  Authors: Anatoliy Sergienko, Volodya Lepeha                ----
----  Company: Unicore Systems http://unicore.co.ua              ----
----                                                             ----
----  Downloaded from: http://www.opencores.org                  ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2006-2010 Unicore Systems LTD                 ----
---- www.unicore.co.ua                                           ----
---- o.uzenkov@unicore.co.ua                                     ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
---- THIS SOFTWARE IS PROVIDED "AS IS"                           ----
---- AND ANY EXPRESSED OR IMPLIED WARRANTIES,                    ----
---- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED                  ----
---- WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT              ----
---- AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.        ----
---- IN NO EVENT SHALL THE UNICORE SYSTEMS OR ITS                ----
---- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,            ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL            ----
---- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT         ----
---- OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,               ----
---- DATA, OR PROFITS; OR BUSINESS INTERRUPTION)                 ----
---- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,              ----
---- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING                 ----
---- IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,                 ----
---- EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.          ----
----                                                             ----
---------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {test} architecture {test}}

library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.std_logic_arith.all;  
use ieee.std_logic_unsigned.all; 
use IEEE.math_real.all;	   
use IEEE.STD_LOGIC_TEXTIO.all;
use std.textio.all;    
use work.type1.all;	  
-- library UNISIM;
-- use UNISIM.VCOMPONENTS.ALL;


entity test is	 
			 
	--generic( G_range:  integer := 4;
--	A_range:  integer := 9);
end test;

--}} End of automatically maintained section

architecture test of test is  
signal i,j,k,m : integer := 0;			

 

component RS_EN4 is	  
	 
	--generic( G_range:  integer := 4;
--	A_range:  integer := 9);
	 port(
		 CLK : in STD_LOGIC;
		 RST : in STD_LOGIC;
		 EN : in STD_LOGIC;
		 D_IN : in STD_LOGIC_VECTOR(7 downto 0);  
		 STR : in STD_LOGIC;
		 RD : in STD_LOGIC;
		 D_OUT : out STD_LOGIC_VECTOR(7 downto 0);
		 SNB : out STD_LOGIC
	     );
end component;	  

component RS_DEC4 is
	 port(
		 CLK : in STD_LOGIC;
		 RST : in STD_LOGIC; 
		 EN : in STD_LOGIC; 
		 STR : in STD_LOGIC;
		 D_IN : in STD_LOGIC_VECTOR(7 downto 0);
		 RD : in STD_LOGIC;
		 D_OUT : out STD_LOGIC_VECTOR(7 downto 0);
		 S_er : out STD_LOGIC;		
		 S_ok : out STD_LOGIC;
		 SNB : out STD_LOGIC
	     );
end component;

 
 






signal clk,rst: std_logic := '1';	

   
signal rgA0 : tregA1 := 
(x"00",x"00",x"00",x"00",x"00",x"00",x"07",x"D0",others=>x"B6"); 	   
--(x"01",x"02",x"03",x"04",x"05",x"06",x"07",x"08",x"09",x"0A",x"0B",x"0C",others=>x"A5"); 	   
signal rgA10 : tregA1 := (x"00",x"00",x"00",x"27", others=>x"00"); 

signal   enc_din,enc_dout,dec_din,dec_dout : std_logic_vector(7 downto 0);
signal   enc_rd,dec_rd,enc_str,dec_str : std_logic := '0';	

signal enc_snb,dec_snb : std_logic;	 
signal cntc,cntc1 : integer := 0;	
signal rgA1,rgA2 : tregA; 
signal s_er, s_ok, enable : std_logic;
signal prov : std_logic := '0';	

signal c1,c2,c3,c4,cc : std_logic;
begin		

	rst <= '0' after 25 ns;
	clk <= not clk after 5 ns;	
	c1 <= clk after 1 ns;		
	c2 <= clk after 2 ns;
	c3 <= clk after 3 ns;		
	c4 <= clk after 4 ns;
	cc <= clk xor c1 xor c2 xor c3 xor c4;

-- vector after encoding		
process(clk) 	
begin  			 
	if clk = '1' and clk'event then	 
		if enc_rd = '1' then
			rgA1(A_range - 1 downto 1) <= rgA1(A_range - 2 downto 0);
			rgA1(0) <= enc_dout; 	 
		end if;
	end if;	 
end process;   		 

-- vector after decoding		
process(clk) 	
begin  			 
	if clk = '1' and clk'event then	 
		if dec_rd = '1' then
			rgA2(A_range - 1 downto 1) <= rgA2(A_range - 2 downto 0);
			rgA2(0) <= dec_dout; 	 
		end if;
	end if;	 	
end process; 

process
variable cnt : integer;
variable loopidx : integer := 0;

begin				  
--	for i in 0 to A_range-1 loop
--		rgA0(i) <= conv_std_logic_vector(i,8);
--	end loop;
dec_str <= '0';
enable <= '1';
	cnt := 0; 
	loopidx := loopidx+1;
	enc_str <= '0';
	enc_din <= (others => 'X');
	wait for 100 ns;
  wait until clk = '1';
	enc_str <= '1';	 	
	wait until clk = '1';
	enc_str <= '0';   		
	-- data for encoding
	for i in 0 to A_range -5 loop
	enc_din <= rgA0(cnt);
	cnt := cnt + 1;	  	
	wait until clk = '1';
	end loop;	
	-- после окончания потока данных на вход кодера выставляютя нули (потом уберу)
	cnt := 0;  
	enc_din <= x"00";																 	
	wait until clk = '1';
	-- waiting for encoding to finish
	wait until enc_snb = '1';	
	wait for 1 ps;					 
	-- adding errors
	
wait until clk = '1';  
dec_din <= 	(others => '1');
wait until clk = '1';  

wait until clk = '1';  
dec_str <= '1';
wait until clk = '1';  
dec_str <= '0';
enable <= '0';
wait until clk = '1';
enable <= '0';
wait until clk = '1';
enable <= '1';

 

	if loopidx>2 then
		dec_din <= 	enc_dout xor rgA10(cnt);  
	else
		dec_din <= 	enc_dout;  
	end if;
	-- receiving data for decoding
	enc_rd <= '1';	
	wait until clk = '1';  
	for i in 0 to A_range -1 loop  		
	wait for 1 ps;
		if loopidx>2 then
			dec_din <= 	enc_dout xor rgA10(cnt);	
		else
			dec_din <= 	enc_dout;  
		end if;
		cnt := cnt + 1;
		wait until clk = '1';
if i=5 then
enable <= '0';
wait until clk = '1';
enable <= '0';
wait until clk = '1';
enable <= '1';
end if;
	end loop;	 		 	 
	-- end of receiving
	enc_rd <= '0';	 		 
	wait until clk = '1';
	-- waiting the end of decoding
	wait until dec_snb = '1';
	wait until clk = '1'; 				
	-- read the result
	dec_rd <= '1';	
	wait until clk = '1';  
	for i in 0 to A_range -1 loop  			
	wait until clk = '1';
	end loop;	 		 
	dec_rd <= '0';	 
	wait until clk = '1';
	-- compare received data with the original data
	if rgA2 = rgA1 then prov <= '1'; else prov <= '0'; end if;
	wait until clk = '1'; 					   
	-- change the data vector and error vector
	rgA0 <= (rgA0(A_range - 1) + rgA0(0)) & rgA0(0 to A_range - 2);	
	rgA10 <= rgA10(1 to A_range - 1) & rgA10(0);
	
end process;


--- encoder
u_rs_en1 : RS_EN4 								
	 port map(
		 CLK => clk, 
		 RST => rst,
		 EN => enable,
		 D_IN => enc_din,
		 STR => enc_str,
		 RD => enc_rd,
		 D_OUT => enc_dout,
		 SNB => enc_snb
	     );	
-- dec_str <= enc_snb;
-- decoder  
u_rs_dec1 :  RS_DEC4 
	 port map(
		 CLK => clk, 
		 RST => rst,
		 EN => enable,
		 D_IN => dec_din,
		 STR => dec_str,
		 RD => dec_rd,
		 D_OUT => dec_dout,
		 S_er =>s_er,
		 S_ok => s_ok,
		 SNB => dec_snb
	     );	
-- culculate cycles		 				    
process(clk,rst) 
begin  
	if rst = '1' then  
		cntc <= 0;	  
		cntc1 <= 0;
	elsif clk = '1' and clk'event then
		if enc_snb = '1' then cntc <= 0; else cntc <= cntc + 1; end if;
		if dec_snb = '1' then cntc1 <= cntc; end if;			
	end if;
end process;



 
end test; 