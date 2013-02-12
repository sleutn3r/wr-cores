library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
entity prog_1 is
    Port (	
--..................... VME signals ...................	
		AD	  	: inout std_logic_vector(31 downto 0);-- VME address/data bus
		AMI	  : in std_logic_vector(5 downto 0);-- VME address modifier
		ASI	  : in std_logic;					-- vme address strobe
		WRI	  : in std_logic;					-- vme write strobe
		DS0I, DS1I : in std_logic;				-- VMEdata strobe
		CAIV, OAIV	  : in std_logic;		-- vme address buffer INT->VME
		OAVI, CAVI	  : inout std_logic;		-- vme address buffer VME->INT
		ODVI, ODIV, CDIV, CDVI	  : inout std_logic; -- vme data buffer 
		DACKP	  : out std_logic;		-- vme acknowledge (also from FPGA)
		IACK	  : in std_logic;		-- vme interrupt acknowledge
		MON	  	: in std_logic_vector(7 downto 0);-- VME address offset
--..................... FLASH signals .................
		-- flash address is ad[21...2]
		CEFSH  : inout std_logic;					-- chip select FLASH
		FL	  : inout std_logic_vector(24 downto 22);	-- FLASH	address offset
		OEFSH  : inout std_logic;					-- output enable FLASH
		WEFSH  : inout std_logic;					-- write enable FLASH
		BYTEN  : out std_logic;					-- L= 8bit FLASH data bus 1=16 bit
		STS	 : in std_logic;					-- L= busy
		DF	  : inout std_logic_vector(15 downto 0);	-- FLASH	data bus
--..................... FPGA configuration signals .................
		CCLK	  : inout std_logic;				  	-- conf. clock  for FPGAs
		PDONE	  : in std_logic;	-- config. done
		M	  : out std_logic_vector(2 downto 0); 	-- FPGA configuration mode
		PDIN	  : inout std_logic; 	-- conf data for FPGAs
		PPROG	  : inout std_logic;	-- config start 
		HSW	  : out std_logic;   -- 0 = enable I/O pullups during configuration
		PINIT	  : in std_logic;	   -- config init 
--..................... System signals .................
		DLL_LOCK : in std_logic;   -- from FPGA
		PLLBY  : in std_logic;   -- PLL signal not used
		PRESX  : in std_logic;   -- PLL signal not used
--		SRESI  : in std_logic;				   -- VME system reset
		CKPRO  : in std_logic;					--	clock 50MHz
		MRES	  : inout std_logic;				--	"manual" reset from CPLD to reset chip
		NRES	  : in std_logic;					--	reset, start of configuration
		PRES	  : in std_logic;					--	reset, start of configuration
		HPR	  : out std_logic_vector(15 downto 0);
		PLED		: out std_logic_vector(4 downto 1);	--	programming status LED
		RES		: inout std_logic_vector(2 downto 1);
		CON		: inout std_logic_vector(15 downto 0));	--	connection to VMELOG
end prog_1;
--
	architecture rtl of prog_1 is
-- ............................. VME interface ..................................
signal ckad, stda, ckdf, oedf, ckdr, oedr 		: std_logic;				-- clock for internal address, data register
-- ............... vme address phase state machine, states declaration .........................
type vme_adr_typ is (va00,va01,va02,va03,va04,va05,va0b);	-- va06,va07,va08,va09,va0a,
signal vme_adr, vme_anx : vme_adr_typ;
--
-- ............... vme data phase state machine for flash .........................
signal st_rd_flash		: std_logic;	 -- start state machine for flash read
signal st_wr_flash		: std_logic;	 -- start state machine for flash write   
type vmdafl_typ is (vf00,vf01,vf02,vf03,vf04,vf14,vf05,vf06,vf07,vf08,vf09,vf0a,vf0b,vf0c,vf0d,vf0e,vf0f);	  --
signal vmdafl, vmdafl_nx : vmdafl_typ;
-- ............... vme data phase state machine for CSR .........................
signal st_csr_drd		: std_logic;	 -- start state machine for CSR read
signal st_csr_dwr		: std_logic;	 -- start state machine for CSR write   
type vmdacs_typ is (vc00,vc01,vc02,vc03,vc04,vc05,vc06,vc08,vc09,vc0a,vc0b,vc0c,vc0d,vc0e);
signal vmdacs, vmdacs_nx : vmdacs_typ;
--
signal contr	: std_logic_vector (9 downto 0);
--
signal asis, dsr, dsx, wrs, vulom_sel, am_sel, sel_rnd, selflsh		: std_logic;				-- synchronized  VME !AS, (!DS0 and !DS1)
signal ad_co	: std_logic_vector (1 downto 0);  	-- vme address phase outputs for: stda = start data phase...
signal vabuf, vafsh	: std_logic_vector (1 downto 0);  	-- vme address phase outputs for external vme buffer register 
signal aph_sta, fsh_sta	: std_logic_vector (3 downto 0);  	-- states of state machines
signal csr_sta	: std_logic_vector (2 downto 0);  	-- states of state machines
signal drfsh, vdfsh, vdcsr	: std_logic_vector (3 downto 0);  	-- vme data phase outputs for external vme buffer register 
signal hp	: std_logic_vector (1 downto 0);  	-- states of flash machine
signal ad_reg, din		: std_logic_vector (31 downto 0);	 -- internal address register for VME address
--signal dr		: std_logic_vector (15 downto 0);	 -- internal address register for VME address
signal dr, dfi		: std_logic_vector (7 downto 0);	 -- internal address register for VME address
signal csro1, csro0, dro, inco		: std_logic_vector (31 downto 0);	 -- internal data bus
signal amr		: std_logic_vector (5 downto 0);	 -- internal address modifier register for VME address
signal int_res		: std_logic_vector (23 downto 22);	 -- internal address register for VME address
constant am_9	:std_logic_vector(5 downto 0)  := b"001001";--AM543210=001001 ext. Extended non-privileged data access
constant am_b	:std_logic_vector(5 downto 0)  := b"001011";--AM543210=001011 ext. Extended non-privileged data access    
constant flash_ad	:std_logic_vector(3 downto 2)  := b"11";----vmeaddr=XXC0 0000 - XXC0 FFFC    
constant csr_ad	:std_logic_vector(3 downto 2)  := b"10";----vmeaddr=XX80 0000 - XX80 000C    
constant nul24	:std_logic_vector(31 downto 8)  := x"000000";--leading zeros    
constant nul16	:std_logic_vector(31 downto 16)  := x"0000";--leading zeros    
signal fsh_o	: std_logic_vector (2 downto 0);  	-- vme data phase outputs for flash 
signal ack_fsh, ack_csr		: std_logic;				-- internal acknowledge flash, csr
signal dack_i		: std_logic;				-- internal acknowledge
signal selcsr		: std_logic;	 -- CSR selected
signal csr_o	: std_logic_vector (1 downto 0) := b"00";  	-- vme data phase outputs for csr 
signal ckcsr, oecsr		: std_logic := '0';	 -- internal CSR
signal ckcsro, oecsro		: std_logic_vector (1 downto 0) := b"00";	 -- internal CSR
signal csrr0, csrrr0		: std_logic_vector (7 downto 0) := x"00";	 -- internal CSR
signal csrr1		: std_logic_vector (7 downto 0);	 -- internal CSR
--
signal counf :	std_logic_vector (7 downto 0);
signal ldaf :	std_logic_vector (7 downto 0);
signal encf :	std_logic;
signal pulsf :	std_logic;
--
-- ............................. FPGA configuration ............................
-- The following encoding is done in such way that the LSB represent prog signal:
	constant start 			:std_logic_vector(2 downto 0) := "000";	 -- idle state 
	constant wait_nCfg_2us 	:std_logic_vector(2 downto 0) := "100";	 -- delay 2 us
	constant status 			:std_logic_vector(2 downto 0) := "001";	 -- vme or flash decision
	constant clr_csr 		:std_logic_vector(2 downto 0) := "101";	 -- no operation
	constant fconfig 			:std_logic_vector(2 downto 0) := "011";	 -- configuration 
	constant vconfig	 		:std_logic_vector(2 downto 0) := "110";	 -- vme configuration
	constant init 				:std_logic_vector(2 downto 0) := "111";	 -- configuration finished
	constant vme_con 			:std_logic_vector(2 downto 0) := "010";	 -- vme configuration
-----....................... end states .................................
	constant d_zero 		:std_logic_vector(1 downto 0) := "00";	-- device number set to zero
	constant c_zero 		:std_logic_vector(2 downto 0) := "000";	-- bit in byte set to zero
	constant i_zero 		:std_logic_vector(19 downto 0):= "00000000000000000000"; -- set address counter	to zero
	constant i_full 		:std_logic_vector(19 downto 0):= "11101110101000100000"; -- config ready 7819520 bits loaded	
	constant w_zero 		:std_logic_vector(9 downto 0) := "0000000000"; -- set delay counter to zero
--
	signal pp				:std_logic_vector(2 downto 0);    -- state machine
	signal count			:std_logic_vector(2 downto 0);    -- bits in byte
	signal res_cnt			:std_logic_vector(7 downto 0);    -- reset pulse counter
	signal data0_int, data0_v		:std_logic;
	signal cfff, repro, vprog, ka_data, data_da, dat_end, mresi, mresj		:std_logic;
	signal ck_fpga, done_s, init_s, progi, wr_cyc, csr1_d, csr1_f		:std_logic;	
	signal inc				:std_logic_vector(19 downto 0);	-- address counter
	signal div				:std_logic_vector(4 downto 0); 	-- 50Mhz-20ns : 2^5(32) -> 640 ns
	signal waitd			:std_logic_vector(9 downto 0);	-- delay counter
------------------------------- module nr ------------------------------------------
--type monu_typ is (mu00,mu01,mu02,mu03,mu04,mu05,mu06,mu07);	-- 
--signal mon_sta, mon_nx : monu_typ;
--
--	signal mon_vn1, mon_vn2 :	std_logic_vector(3 downto 0);
--	signal mucnt, mon_st :	std_logic_vector(3 downto 0);
--	signal pucnt :	std_logic_vector(7 downto 0);
	signal mox, cox			:std_logic_vector(1 downto 0);	-- vme address from cpld to fpga, 2 bit wise
---------------------------------------------------------------------------------------
	begin
-- ............................. VME interface ..................................
----* ADPH @@@@@@@@@@@@@@@@ VME ADDRESS PHASE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--...................... synchronize and invert address strobe .......................
	process(ckpro, asi, ds0i, ds1i) begin
		if (ckpro'EVENT and ckpro = '1') then 
		    asis <= not asi;
		    dsr  <= not ds0i and not ds1i;		-- synchronized DS input from VME
			 dsx  <=  ds0i and ds1i;            --  DS input from VME for acknowledge 
			 byten 	<= '0';	-- byten enables the device to be used in x8 or x16 read/write mode; byten = 0 selects an 8-bit mode,
--			 hsw		<= '0';  -- 0 = weak pre-configuration I/O pull-ups enabled
		end if;
	end process;
--
--...................... VME address phase state machine .......................
	process (vme_adr,asis) 	-- states are - va00,va01,va02,va03,va04,va05,va06,va07,va08 
		begin			-- 							ad_co[]=stda,ckad  vabuf[]=cavi,oavi
			case vme_adr is
				when va00 => 							ad_co <= b"00"; vabuf <= b"11"; aph_sta <= x"0";		
					if 		pp=fconfig then	vme_anx <= va00;														  --and pp=init
					elsif 	asis ='1'  then	vme_anx <= va01;														  --and pp=init
					else    vme_anx <= va00;
					end if;
				when va01 => 							ad_co <= b"00"; vabuf <= b"00";  aph_sta <= x"1";		
					if 		asis ='1' then	 vme_anx <= va02;
					else    vme_anx <= va00;
					end if;
				when va02 => vme_anx <= va03;		ad_co <= b"01"; vabuf <= b"10"; aph_sta <= x"2";
				when va03 => vme_anx <= va04;		ad_co <= b"01"; vabuf <= b"10"; aph_sta <= x"3";
				when va04 => vme_anx <= va05;		ad_co <= b"00"; vabuf <= b"10"; aph_sta <= x"4";
				when va05 => vme_anx <= va0b;		ad_co <= b"10"; vabuf <= b"10"; aph_sta <= x"5";
				when va0b => 							ad_co <= b"10"; vabuf <= b"11"; aph_sta <= x"6";
					if 		asis ='1'	 then  vme_anx <= va0b;
					else 	vme_anx <= va00;				
					end if;
			 end case;
	end process;
-- ............................ clock for address phase state machine ................................
	 process(ckpro) begin  -- 50 MHz clock
		if (ckpro'EVENT and ckpro = '1') then 
		    vme_adr <= vme_anx;
		end if;
	end process ;
-- .............................. synchronize outputs ..................................
	process(ckpro) begin
		if (ckpro'EVENT and ckpro = '1') then 
		stda		<=	ad_co(1);	-- start data phase	(low=address phase - high =data phase)
		ckad		<=	ad_co(0);	-- ckad = clock for internal address register
		end if;
	end process ;
--------------------------- Multiplexer	for VME buffer and VME control signals -------------------------------
--------------------------- Multiplexer	for VME buffer and VME control signals -------------------------------
--vabuf[]=cavi,oavi,caiv,oaiv
	process(ckpro, stda, selflsh) begin
		if (ckpro'EVENT AND ckpro = '1') then 
    		if (stda='1' and selflsh='1') then -- address register/buffer controlled for FLASH memory
				cavi		<=	vafsh(1);	-- clock for address register VME<-internal
				oavi		<=	vafsh(0);	-- OE for address register VME<-internal
----			--------------------------------
				hp(1)		<=	vafsh(1);	-- test
				hp(0)		<=	vafsh(0);	-- test
			else										  -- address register/buffer controlled for VME address phase
				cavi		<=	vabuf(1);	-- clock for address register VME<-internal
				oavi		<=	vabuf(0);	-- OE for address register VME<-internal
---- 			---------------------------------
				hp(1)		<=	vabuf(1);	-- test
				hp(0)		<=	vabuf(0);	-- test
   			end if;    
		end if;
	end process;
--		cavi		<=	vabuf(3);	-- clock for address register VME<-internal
--		oavi		<=	vabuf(2);	-- OE for address register VME<-internal
----................... end of VME address phase state machine ...................
---................... save VME address into CPLD internal address register ...................
		process(ckpro, ckad)
			begin
				if (ckpro'EVENT and ckpro = '1') then
					if  ckad = '1' then
						ad_reg <= ad;       wrs <= wri;  amr <= ami;
					elsif  asis = '1' then
						ad_reg <= ad_reg;       wrs <= wrs;  amr <= amr;
					else  
						ad_reg <= (others =>'0');       wrs <= '1';  amr <= (others =>'0');
					end if;
				end if;
		end process;
		int_res	<= ad_reg(23 downto 22);  -- internal resources 
--.................. select VULOM1 module = compare address register with hex switch ...............
--		process(ckpro, ad, mon)
--			begin
--				if (ckpro'EVENT and ckpro = '1') then
--					if  (ad_reg(31 downto 24) = mon) then
--						vulom_sel <= '1';
--					else vulom_sel <= '0';
--					end if;
--				end if;
--		end process;
--..................  compare address register and address modifier .............................
		vulom_sel <= '1' when (ad_reg(31 downto 24) = mon) else '0';
		am_sel <= '1' when (amr = am_9) else '0';
		process(ckpro, ad_reg, amr)								  
		begin
   			if (ckpro'event and ckpro ='1') then   
    				if (am_sel='1' and vulom_sel = '1' and iack='1') then sel_rnd <= '1'; con(7) <='1'; -- FLASH, CSR, FPGA random access
    				else sel_rnd <= '0';  con(7) <='0';
    				end if;    
    				if ((amr = am_b) and vulom_sel = '1' and iack='1') then  con(8) <='1'; -- FPGA bt32 access
    				else   con(8) <='0';
    				end if;    
    			end if;
		end process;

-- * FLASH @@@@@@@@@@@@@@@@@@@@@@@@@@@@@ DATA PHASE for FLASH @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--................................  comparator for flash  .......................................
		process(ckpro, dsr, stda, wrs, int_res, sel_rnd)
		begin
   			if (ckpro'event and ckpro ='1') then   
    				if (dsr='1' and stda='1' and wrs='1' and int_res=flash_ad and sel_rnd='1') then st_rd_flash <= '1'; -- flash sta-ma
    				else st_rd_flash <= '0';
    				end if;    
    				if (dsr='1' and stda='1' and wrs='0' and int_res=flash_ad and sel_rnd='1') then st_wr_flash <= '1'; -- flash sta-ma
    				else st_wr_flash <= '0';
    				end if;    
    				if (int_res=flash_ad and sel_rnd='1') then selflsh <= '1'; -- flash selected
    				else selflsh <= '0';
    				end if;    
    			end if;
		end process;
------------------------------------ data phase state machine --------------------------------------------        
--
	process (vmdafl, dsr, st_rd_flash, st_wr_flash, pulsf) 	-- states are - (vf00,vf01,vf02,vf03,vf04,vf05,vf08,vf09,vf0a,vf0b,vf0c) 
		begin
															fsh_o <= b"111"; drfsh <= b"0000"; vafsh <= b"11";  vdfsh <= b"1011"; ack_fsh <='1'; fsh_sta<=x"0";
			case vmdafl is
				when vf00 => 							fsh_o <= b"111"; drfsh <= b"0000"; vafsh <= b"11";  vdfsh <= b"1011"; ack_fsh <='1'; fsh_sta<=x"0";		
					if 	st_rd_flash ='1' then vmdafl_nx <= vf01;						
					elsif st_wr_flash ='1' then vmdafl_nx <= vf08;		
					else 	
						vmdafl_nx <= vf00;
					end if;
-- ldaf <= x"10"; -- loads pulse duration data    
-- if 	pulsf='1' ...	-- means that pulse counter is ready
-- encf <= '1'; -- enables the pulse counter				
--------------------     fsh_o=oefsh,wefsh,cefsh 		drfsh <= ckdf,oedf,oedr,ckdr ; 		vafsh <= cavi, oavi;  		vdfsh=odvi,cdvi,odiv,cdiv   	 
--.............................................................. read flash ....................................................................
				when vf01 => vmdafl_nx <= vf02;	fsh_o <= b"110"; drfsh <= b"0000"; vafsh <= b"10";  vdfsh <= b"1111"; ack_fsh <='1'; encf <= '0'; ldaf <= x"07";fsh_sta<=x"1";	
--				
				when vf02 => 							fsh_o <= b"010"; drfsh <= b"0001"; vafsh <= b"10";  vdfsh <= b"1111"; ack_fsh <='1'; encf <= '1'; fsh_sta<=x"2";
					if 	pulsf = '1' then	vmdafl_nx <= vf03;						
					else 	vmdafl_nx <= vf02;						
					end if;										
				when vf03 => vmdafl_nx <= vf04;	fsh_o <= b"010"; drfsh <= b"0000"; vafsh <= b"11";  vdfsh <= b"1111"; ack_fsh <='1'; fsh_sta<=x"3";
--							
				when vf04 => vmdafl_nx <= vf14;	fsh_o <= b"111"; drfsh <= b"0010"; vafsh <= b"11";  vdfsh <= b"1110"; ack_fsh <='1'; fsh_sta<=x"4";
				when vf14 => vmdafl_nx <= vf05;	fsh_o <= b"111"; drfsh <= b"0010"; vafsh <= b"11";  vdfsh <= b"1110"; ack_fsh <='1'; fsh_sta<=x"4";
				when vf05 => vmdafl_nx <= vf06;	fsh_o <= b"111"; drfsh <= b"0010"; vafsh <= b"11";  vdfsh <= b"1101"; ack_fsh <='1'; fsh_sta<=x"5";						
				when vf06 => 							fsh_o <= b"111"; drfsh <= b"0010"; vafsh <= b"11";  vdfsh <= b"1101"; ack_fsh <='0'; fsh_sta<=x"6"; 
					if 	dsr = '1' then	vmdafl_nx <= vf06;						
					else 	vmdafl_nx <= vf07;						
					end if;										
				when vf07 => vmdafl_nx <= vf00;	fsh_o <= b"111"; drfsh <= b"0000"; vafsh <= b"11";  vdfsh <= b"1111"; ack_fsh <='1'; fsh_sta<=x"7"; 		
--------------------     fsh_o=oefsh,wefsh,cefsh 		drfsh <= ckdf,oedf,oedr,ckdr ;  vafsh <= cavi, oavi;  	vdfsh=odvi,cdvi,odiv,cdiv  
--............................................................ write flash ....................................................................
				when vf08 => vmdafl_nx <= vf09;	fsh_o <= b"111"; drfsh <= b"1000"; vafsh <= b"11";  vdfsh <= b"0111"; ack_fsh <='1'; fsh_sta<=x"8";
				when vf09 => vmdafl_nx <= vf0a;	fsh_o <= b"111"; drfsh <= b"1000"; vafsh <= b"11";  vdfsh <= b"0111"; ack_fsh <='1'; fsh_sta<=x"9";
				when vf0a => vmdafl_nx <= vf0f;	fsh_o <= b"111"; drfsh <= b"0100"; vafsh <= b"11";  vdfsh <= b"1111"; ack_fsh <='1'; fsh_sta<=x"a";
				when vf0f => vmdafl_nx <= vf0b;	fsh_o <= b"111"; drfsh <= b"0100"; vafsh <= b"11";  vdfsh <= b"1111"; ack_fsh <='1'; encf <= '0'; ldaf <= x"06";fsh_sta<=x"b";
				when vf0b => 							fsh_o <= b"100"; drfsh <= b"0100"; vafsh <= b"10";  vdfsh <= b"1111"; ack_fsh <='1'; encf <= '1'; fsh_sta<=x"c";
					if 	pulsf = '1' then	vmdafl_nx <= vf0c;						
					else 	vmdafl_nx <= vf0b;						
					end if;										
				when vf0c => vmdafl_nx <= vf0d;	fsh_o <= b"110"; drfsh <= b"0100"; vafsh <= b"10";  vdfsh <= b"1111"; ack_fsh <='1'; fsh_sta<=x"d";
				when vf0d => 							fsh_o <= b"111"; drfsh <= b"0100"; vafsh <= b"11";  vdfsh <= b"1111"; ack_fsh <='0'; fsh_sta<=x"e"; 		
					if 		dsr ='1' then	vmdafl_nx <= vf0d;
					else   vmdafl_nx <= vf0e;	
					end if;
				when vf0e => vmdafl_nx <= vf00;	fsh_o <= b"111"; drfsh <= b"0000"; vafsh <= b"11";  vdfsh <= b"1111"; ack_fsh <='1'; fsh_sta<=x"f";
			 end case;
	end process;
-- ............................ clock for vmdafl state machine ................................
	 process(ckpro) begin
		if (ckpro'EVENT and ckpro = '1') then 
		    vmdafl <= vmdafl_nx;
		end if;
	end process ;
-- ............................ end of vmdafl state machine ................................
-- .............................. synchronize control signals for FLASH ..................................
			dfi	<= df(7 downto 0);
	process(ckpro) begin
		if (ckpro'EVENT and ckpro = '1') then 
--	fsh_o=oefsh,wefsh,cefsh
--			oefsh		<=	fsh_o(2);	-- output enable for FLASH (external)
			wefsh		<=	fsh_o(1);	-- write enable for FLASH (external)
--			cefsh		<=	fsh_o(0);	-- chip select for FLASH (external)
			if drfsh(3) ='1' then dr <= ad(7 downto 0); 
			elsif drfsh(0) ='1' then dr <= dfi;
			else 	dr <= dr;
			end if;			
		end if;
	end process;
			df(7 downto 0) <= dr when drfsh(2) ='1' else (others => 'Z');
			df(15 downto 8) <= (others => 'Z');		  
-- * CSR0 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ DATA PHASE for CSR @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--................................  comparator for CSR  .......................................
		process(ckpro, dsr, stda, wrs, int_res, sel_rnd)
		begin
   			if (ckpro'event and ckpro ='1') then   
    				if (dsr='1' and stda='1' and wrs='1' and int_res=csr_ad and sel_rnd='1') then st_csr_drd <= '1'; -- CSR sta-ma
    				else st_csr_drd <= '0';
    				end if;    
    				if (dsr='1' and stda='1' and wrs='0' and int_res=csr_ad and sel_rnd='1') then st_csr_dwr <= '1'; -- CSR sta-ma
    				else st_csr_dwr <= '0';
    				end if;    
    				if (int_res=csr_ad and sel_rnd='1') then selcsr <= '1'; -- CSR selected
    				else selcsr <= '0';
    				end if;    
    			end if;
		end process;
--			csr_o[]=ckcsr,oecsr, 		vdcsr[]=odvi,cdvi,odiv,cdiv
	process (vmdacs, dsr, st_csr_dwr, st_csr_drd) 	-- states are - vc00,vc01,vc02,vc03,vc04,vc05,vc06,vc07,vc08 
		begin
											csr_o <= b"00"; vdcsr <= b"1111"; ack_csr	<='1';
			case vmdacs is
				when vc00 => 					csr_o <= b"00"; vdcsr <= b"1111"; ack_csr	<='1'; 		
					if 	 st_csr_drd ='1' then vmdacs_nx <= vc01;						
					elsif st_csr_dwr ='1' then vmdacs_nx <= vc08;		
					else 	
						vmdacs_nx <= vc00;
					end if;
--............................. read csr ................................
				when vc01 => vmdacs_nx <= vc02;	csr_o <= b"01"; vdcsr <= b"1110"; ack_csr	<='1'; csr_sta<=b"001";								
				when vc02 => vmdacs_nx <= vc03;	csr_o <= b"01"; vdcsr <= b"1110"; ack_csr	<='1'; csr_sta<=b"010";						
				when vc03 => vmdacs_nx <= vc04;	csr_o <= b"01"; vdcsr <= b"1110"; ack_csr	<='1'; csr_sta<=b"011";						
				when vc04 => vmdacs_nx <= vc05;	csr_o <= b"01"; vdcsr <= b"1100"; ack_csr	<='1'; csr_sta<=b"100";						
				when vc05 => 							csr_o <= b"01"; vdcsr <= b"1101"; ack_csr	<='0'; csr_sta<=b"101"; 		
					if 		dsr ='1' then	vmdacs_nx <= vc05;						
					else 	vmdacs_nx <= vc06;						
					end if;
				when vc06 => vmdacs_nx <= vc00;	csr_o <= b"00"; vdcsr <= b"1111"; ack_csr	<='1'; csr_sta<=b"110";						
--............................. write csr ................................
				when vc08 => vmdacs_nx <= vc09;	csr_o <= b"10"; vdcsr <= b"0011"; ack_csr	<='1'; csr_sta<=b"001";
				when vc09 => vmdacs_nx <= vc0a;	csr_o <= b"10"; vdcsr <= b"0011"; ack_csr	<='1'; csr_sta<=b"010";
				when vc0a => vmdacs_nx <= vc0b;	csr_o <= b"10"; vdcsr <= b"0111"; ack_csr	<='1'; csr_sta<=b"011";
				when vc0b => 							csr_o <= b"10"; vdcsr <= b"0111"; ack_csr	<='1'; csr_sta<=b"100";
					if 		ad_reg(2) ='0' then	vmdacs_nx <= vc0d;
					elsif 	vprog ='1' then	vmdacs_nx <= vc0c;
					else   vmdacs_nx <= vc0d;	
					end if;
				when vc0c => 							csr_o <= b"10"; vdcsr <= b"0111"; ack_csr	<='1'; csr_sta<=b"101";
					if 		(vprog ='1' and ka_data ='1') then	vmdacs_nx <= vc0d;
					elsif 	dsr ='0' then	vmdacs_nx <= vc0e;
					else   vmdacs_nx <= vc0c;	
					end if;
				when vc0d => 							csr_o <= b"10"; vdcsr <= b"0111"; ack_csr	<='0'; csr_sta<=b"110"; 		
					if 		dsr ='1' then	vmdacs_nx <= vc0d;
					else   vmdacs_nx <= vc0e;	
					end if;
				when vc0e => vmdacs_nx <= vc00;	csr_o <= b"00"; vdcsr <= b"1111"; ack_csr	<='1'; csr_sta<=b"111";
			 end case;
	end process;
-- ............................ clock for vmedacs state machine ................................
	 process(ckpro) begin
		if (ckpro'EVENT AND ckpro = '1') then 
		    vmdacs <= vmdacs_nx;
		end if;
	end process ;
-- .............................. synchronize outputs ..................................
	process(ckpro) begin
		if (ckpro'EVENT AND ckpro = '1') then 
--			csr_o = ckcsr,oecsr, 		
		ckcsr		<=	csr_o(1);	-- clock data into csr
		oecsr		<=	csr_o(0);	-- output data from csr to VME
		end if;
	end process ;
-- .................... decoder for CSR registers ................................
		process(ckpro, ckcsr, ad_reg)
		begin
   			if (ckpro'event and ckpro ='1') then   
    				if (ckcsr='1' and ad_reg(4 downto 2)=b"000" ) then ckcsro(0) <= '1'; 
    				else  ckcsro(0) <= '0'; 
    				end if;    
    				if (ckcsr='1' and ad_reg(4 downto 2)=b"001" ) then ckcsro(1) <= '1'; 
    				else  ckcsro(1) <= '0';
    				end if;    
    			end if;
		end process;
		process(ckpro, oecsr, ad_reg)
		begin
   			if (ckpro'event and ckpro ='1') then   
    				if (oecsr='1' and ad_reg(4 downto 2)=b"000" ) then oecsro(0) <= '1'; 
    				else oecsro(0) <= '0';
    				end if;    
    				if (oecsr='1' and ad_reg(4 downto 2)=b"001" ) then oecsro(1) <= '1'; 
    				else oecsro(1) <= '0';
    				end if;    
    			end if;
		end process;
-- ................... write in to register csr 0, 1 ..................................
		process(ckpro, ckcsro, ad)
		begin
   			if (ckpro'event and ckpro ='1') then   
--					if cl_crs='1' then csrr0 <= x"00"; 
    				if (ckcsro(0)='1' ) then  	csrr0 <= ad(7 downto 0);
    				end if;    
--					if cl_crs='1' then csrr1 <= x"00"; 
    				if (ckcsro(1)='1' ) then  	csrr1 <= ad(7 downto 0);
    				end if;    
    			end if;
		end process;
------------------------------ reload fpga ----------------------------------------------
		process(ckpro, ckcsro, csrr1)
		begin
   			if (ckpro'event and ckpro ='1') then   
    				if (ckcsro(0)='1' and csrr0(3)='1' and ack_csr='0') then  	mresi <= '0';
					else mresi <= '1';
    				end if;    
    			end if;
		end process;
--------------------------- Multiplexer	for VME buffer and VME control signals -------------------------------
--			vdbuf = odvi,cdvi,odiv,cdiv
		process(ckpro)
		begin
   			if (ckpro'event and ckpro ='1') then   
    				if (selflsh='1' and selcsr='0') then 
					odvi		<=	vdfsh(3);	-- OE for data register VME<-internal
					cdvi		<=	vdfsh(2);	-- clock for data register VME<-internal
					odiv		<=	vdfsh(1);	-- OE for data register internal<-VME  
					cdiv		<=	vdfsh(0);	-- clock for data register internal<-VME
					dack_i	<=	ack_fsh;	-- acknowledge from hpi
    				elsif (selcsr='1' and selflsh='0') then 
					odvi		<=	vdcsr(3);	-- OE for data register VME<-internal
					cdvi		<=	vdcsr(2);	-- clock for data register VME<-internal
					odiv		<=	vdcsr(1);	-- OE for data register internal<-VME  
					cdiv		<=	vdcsr(0);	-- clock for data register internal<-VME
					dack_i	<=	ack_csr;	-- acknowledge from csr
    				else 
					odvi <= con(4); cdvi	<=	con(3); odiv <= con(2);	cdiv <= con(1); dack_i <= con(0);	-- from fpga
--					odvi <= '1'; cdvi	<=	'0'; odiv <= '1';	cdiv <= '1'; dack_i <= '1';	-- from fpga
    				end if;    
    			end if;
		end process;
--		odvi		<=	vdbuf(3);	-- OE for data register VME<-internal
--		cdvi		<=	vdbuf(2);	-- clock for data register VME<-internal
--		odiv		<=	vdbuf(1);	-- OE for data register internal<-VME  
--		cdiv		<=	vdbuf(0);	-- clock for data register internal<-VME
--					dackp		<= 	dack_i  or not dsr; -- end of DTACK signal ( no interrupts)
					dackp    <=    dack_i  or  dsx;    -- end of DTACK signal ( with interrupts) 
					--                                    ds0i, ds1i, dackp corresponds to VME DS0, DS1, DACK 
	csrrr0 <= (csrr0(7) & init_s & done_s & csrr0(4 downto 0));
	csro0	<= (nul24 & csrrr0);		    -- 8 bit csr + 24 bit zeros
	csro1	<= (nul24 & csrr1);		    -- 8 bit csr + 24 bit zeros
	dro	<= (nul24 & dr);		    -- 8 bit csr + 24 bit zeros
----------................................ Pulse counter for FLASH ...............................................
-- ldaf <= x"10"; -- loads pulse duration data    								 
-- if 	pulsf='1' ...	-- means that pulse counter is ready
-- encf <= '1'; -- enables the pulse counter
process (ckpro, encf,ldaf)
begin
   if ckpro='1' and ckpro'event then
		if encf ='0' then	counf <= ldaf;	pulsf <= '0';
		elsif encf ='1' and counf /=0 then
               counf <= counf - 1; 	
		elsif encf ='1' and counf =0 then
					counf <= (others => '0'); pulsf <= '1';
		end if;
   end if;
end process;
--..................................................................................................................
-- The following process is used to divide CLOCK :
--.................... synchronize reset = reprogramm ............................. 
		PROCESS (ckpro, nres)
		BEGIN
				IF (ckpro'EVENT and ckpro = '1') THEN
					vprog <= csrr0(4) and not csrr0(7);
					mresj <= mresi;
					mres <= mresi or mresj;
					if nres='0' then repro <= '1';
					else repro <= '0'; 
					end if;
					done_s	<= pdone;
					con(5)	<= done_s;
					init_s   <= pinit;
				end if;
		END PROCESS;
--....................... frequency devider ........................................
		process (ckpro,repro)  -- 5 bit counter=devide/32
		begin
			if repro = '1' then
				div <= (others => '0');
			else
				IF (ckpro'EVENT and ckpro = '1') THEN
					div <= div + 1;		-- 32 x 20 ns -> 640 ns
				end if;
			end if;
		END process;
--........................ state machine .............................................
		process(ckpro,repro)
		begin
			if repro = '1' then
				pp<=start;			-- state 0 reset
				count <= c_zero;  inc <= i_zero; waitd <= w_zero;
			else
				if ckpro'event and ckpro='1' then
--........................ 00000000000000000000000000000000 ......... start ...........
-- The following state is used to divide 20 MHz CLOCK to ca. 1.56 MHz
					if (div = 31) then		--  shift
						case pp is			
						when start =>		-- state 0 reset
							count <= c_zero;  inc <= i_zero; -- 
							pp <= wait_nCfg_2us;
--........................ 444444444444444444444444444444444 ......... wait_nCfg_2us ..........
-- This state is used in order to verify the tcfg timing (prog low pulse width).
-- Tcfg = 51µs min => 80 clock cycles of a 1.5MHz clock (this clock is CLOCK divide
-- by the divider -div-)
						when wait_nCfg_2us =>	-- state 4
								count <= c_zero;  inc <= i_zero;						
--								waitd <= waitd + 1;
--							if waitd = 415 then		-- min 266 us delay (wait for init high)
							if init_s = '1' then		-- (wait for init high, the whole fpga memory is cleared)
								pp <= status;
							end if;
--........................ 111111111111111111111111111111111 ............. status ...................
						when status =>				-- state 1
							count <= c_zero;  inc <= i_zero; waitd <= w_zero;
							if vprog = '0' then		-- (wait for init high, the whole fpga memory is cleared)
								pp <= fconfig;
							elsif (vprog = '1') then
								pp <= vme_con;
							end if;
--........................ 2222222222222222222222222222222222 .............. vme_con ...................
						when vme_con =>			-- state 2	
							dat_end <='0';
							if data_da = '1' then pp <= vconfig;
							else pp <= vme_con;
							end if;
--......................... 666666666666666666666666666666666 ............... vconfig.................
						when vconfig =>						-- state 6									
								count <= count + 1;			-- bit # in byte MSB first
									if (done_s='1' and vprog = '0') then 	--  done or overflow 
--										waitd <= waitd + 1;									
										pp<= init;
									end if;
									if count=7 then			-- last bit of byte 
										dat_end <='1';
										pp <= vme_con;
									end if;
--									if waitd = 40 then 			-- add 40 clocks delay after done_/-
--										pp<= init;
--									end if;
--.......................... 33333333333333333333333333333333 ................. fconfig ................
--This state is used to increment the memory address. In the same state when
--the done=Conf_Done is high some clock cycles are added to avoid issues with old
--files (the 10 clocks cycles).
						when fconfig =>						-- state 3
							count <= count + 1;			-- bit # in byte MSB first
								if (done_s='1') or (inc > b"11111110101000100000")  then --  done or overflow 	  
--															 11101110101000100000 bytes, FPGA config ready
-- programming file byte length Xilinx spartan xc2s150 hex=1FBDC (virtex XC4VLX25 hex-EEA20)
									waitd <= waitd + 1;		-- delay after config finished
								end if;
								if count=7 then			-- last bit of byte 
									inc <= inc + 1;		-- FLASH address increment
								end if;
								if waitd = 40 then 			-- add 40 clocks delay after done_/-
									pp<= init;
--									pp<= clr_csr;
								end if;
--............................ 55555555555555555555555555555555555 ................ clr_csr ...................
-- this state clears csr
--						when clr_csr =>				-- state 5								
--								cl_crs <= '1';
--						pp<= init;								
--............................ 77777777777777777777777777777777 ................ init ...................
-- this state selects device to be configured, holds after the configuration
						when init =>				-- state 7
--							cl_crs <= '0';
							if repro = '1'  then		 --  done 
								pp <= start;
							else
								pp <= init;
							end if;
						when others =>
								pp <= start;
						end case;
					end if;
				end if;
			end if;
		end process;
--================================================================================================
		process (ckpro) 
		begin
			if (ckpro'EVENT and ckpro = '1') then
					csr1_d <= ckcsro(1);
					csr1_f <= csr1_d;
					wr_cyc <= csr1_d and not csr1_f;
					if (ka_data = '1' or dsr = '0') then data_da <='0';
					elsif wr_cyc = '1' then data_da <='1';
					end if;
					if dsr = '0' then ka_data <='0';
					elsif dat_end = '1' then ka_data <= '1';
					end if;
			end if;	
		end process;
-- ......................... synchronizing FLASH control signals ...............................
		process (ckpro) 
		begin
			if (ckpro'EVENT and ckpro = '1') then
					cfff <= (not div(4) and not div(3) and not div(2) and not count(2) and not count(1) and not count(0));
					if  pp=fconfig then ck_fpga <= div(4); -- 640 ns of clock cycle to FPGA
					elsif  pp=vconfig then ck_fpga <= div(4); -- 640 ns of clock cycle to FPGA
					else ck_fpga <= '0';
					end if;
--					ck_fpga <= div(4); -- 640 ns of clock cycle to FPGA
			end if;	
		end process;
		cclk	<= ck_fpga;
--................................... tristate output signals ..................................
		process (ckpro,pp,cfff,inc,fsh_o)
		begin
   		if (ckpro'event and ckpro ='1') then   
				if (pp=fconfig) then
						oefsh <= '0'; 			cefsh <= cfff; 		 
				else 	oefsh	<=	fsh_o(2);  	cefsh	<=	fsh_o(0); 	
				end if;
			end if;
		end process;
-------------------------------------------------------------------------	
	inco	<= (b"0000000000" & inc & b"00");		    -- 
----------------------- DATA MULTIPLEXER for OUTPUT to VME and address for FLASH -------------------------------------------
		process(ckpro, csro0, csro1, oecsro, inc)
		begin
   			if (ckpro'event and ckpro ='1') then   
    				if 		(oecsro(0)='1' ) then  	din	<=  csro0;
    				elsif 	(oecsro(1)='1' ) then  	din	<=  csro1;
					elsif (drfsh(1)='1') then 	din	<=  dro;
					elsif (pp=fconfig) 	then 	din	<=  inco; -- address counter output to FLASH address bus
    				else  							din	<=  (others => '0');
    				end if;    
    			end if;
		end process;
	ad <= din when ((oecsro(0) ='1') or (oecsro(1) ='1') or (drfsh(1)='1') or (pp=fconfig)) else (others => 'Z');		  


--...................The following process is used to serialize the data byte.
		process(count,pp,ckpro)	-- df is here parallel data in
		begin
			if  (ckpro'EVENT and ckpro = '1') then
				if (pp=fconfig) then -- config from flash
					case count is
					when "000" => data0_int <= df(7); 		-- data
					when "001" => data0_int <= df(6); 		-- data
					when "010" => data0_int <= df(5); 		-- data
					when "011" => data0_int <= df(4); 		-- data
					when "100" => data0_int <= df(3); 		-- data
					when "101" => data0_int <= df(2); 		-- data
					when "110" => data0_int <= df(1); 		-- data
					when "111" => data0_int <= df(0); 		-- LSB data
					when others => null;	-- null = no operation
					end case;
				elsif (pp=vconfig) then -- config over vme
					case count is
					when "000" => data0_v <= csrr1(7); 		-- data
					when "001" => data0_v <= csrr1(6); 		-- data
					when "010" => data0_v <= csrr1(5); 		-- data
					when "011" => data0_v <= csrr1(4); 		-- data
					when "100" => data0_v <= csrr1(3); 		-- data
					when "101" => data0_v <= csrr1(2); 		-- data
					when "110" => data0_v <= csrr1(1); 		-- data
					when "111" => data0_v <= csrr1(0); 		-- LSB data
					when others => null;	-- null = no operation
					end case;
				else
					data0_int <= '0';
				end if;
			end if;
		end process;
--..................................................................................
		process(ckpro)	-- 
		begin
			if  (ckpro'EVENT and ckpro = '1') then
				if (pp=b"000") then progi <= '0';
				else progi <= '1';
				end if;
			end if;
		end process;
--				pprog		<=  progi;		-- low resets configuration logic (_/- starts config)
				pprog		<=  nres;		-- low resets configuration logic (_/- starts config)
--...................... seriall data output ...............................................
		process(ckpro)	
		begin
			if  (ckpro'EVENT and ckpro = '1') then
				if (pp=fconfig) then pdin <= data0_int;	-- 
				elsif (pp=vconfig) then pdin <= data0_v;	-- 
				else pdin <= '0';														-- 
				end if;
			end if;
		end process;
--------------- XILINX configuration pins --------------
		m 	<= b"111"; 	-- M2-M0 - 101 boundary scan	 TCK
							-- M2-M0 - 111 slave serial (cclk ->fpga)
							-- M2-M0 - 011 master select map	8 bit	(cclk<-fpga)
							-- M2-M0 - 110 slave select map	8 bit	(cclk->fpga)
							-- M2-M0 - 000 master serial (cclk <-fpga)
-------------- FLASH control ----------------
--		process(ckpro)	
--		begin
--			if  (ckpro'EVENT and ckpro = '1') then
--				if (csrr0(3)='1') then fl 	<= csrr0(2 downto 0);	-- 
--				else fl 	<= b"000";														-- 
--				end if;
--			end if;
--		end process;
--
		fl 	<= csrr0(2 downto 0);	--
--		fl 	<= b"000";	--
---------------- Misc. ----------------------	
		process(ckpro)	-- select device to be configured
		begin
			if (ckpro'EVENT and ckpro = '1') then
					pled(1) 	<=  repro;  -- dsplog
					pled(2) 	<=  inc(16);  -- dsplog
					pled(3) 	<=  inc(15);  -- dsplog
					pled(4) 	<=  done_s;  -- dsplog
			end if;
		end process;
------------------------------------------------------------------------------------------------------------------------------------------
--			con(15 downto 9)	<= (others => '0');
			con(15 downto 14)	<= cox;
			mox	<= con(13 downto 12);
--			con(6)	<= mon(0);
		process(mox)	-- df is here parallel data in
			begin
				case mox is
					when "00" => cox <= mon(7 downto 6); 		-- 
					when "01" => cox <= mon(5 downto 4); 		-- 
					when "10" => cox <= mon(3 downto 2); 		-- 
					when "11" => cox <= mon(1 downto 0); 		-- 
					when others => null;	-- null = no operation
				end case;
		end process;
---------------------- delay counter with 5 bits  --------------------------------
		process (ckpro)
		begin
				if (rising_edge(ckpro)) then
					if (div = 31) then		
						if (done_s='0') then contr <= (others => '0');
						elsif (done_s='1' and contr(9)='0') then
						contr <= contr + 1;
						end if;
					end if;
					res(1) <= '0'; res(2) <= '0';
					if  (contr(9 downto 0) = "0000010000") then res(1) <= '1'; end if;
					if  (contr(9 downto 1) = "011111111") then res(2) <= '1'; end if;
   			end if;
		end process;
------------------------------------------------------------------------------------------------------------------------------------------
--...................................................................
--		hpr(0) 	<= repro;	-- HP-LA
--		hpr(3 downto 1) 	<= ppp;	-- HP-LA
--		hpr(2) 	<= '0';	-- HP-LA
--		hpr(3) 	<= '0'; -- = oavi	-- HP-LA
--		hpr(4) 	<= '0'; -- = cavi	-- HP-LA
--		hpr(5) 	<= '0';	-- HP-LA
--		hpr(6) 	<= '0';	-- HP-LA
--		hpr(7) 	<= '0';	-- HP-LA
--		hpr(8) 	<= '0';	-- HP-LA
--		hpr(9) 	<= '0';	-- HP-LA
--		hpr(10) 	<= '0';	-- HP-LA
--		hpr(11) 	<= '0';	-- HP-LA
--		hpr(14 downto 12) 	<= (others=>'0');	-- HP-LA	
--		hpr(15) 	<= '0';	-- HP-LA	

		hpr(0) 	<= pp(0);	-- HP-LA
		hpr(1) 	<= pp(1);	-- HP-LA
		hpr(2) 	<= pp(2);	-- HP-LA
		hpr(3) 	<= done_s;	-- done
		hpr(4) 	<= pdin;	-- HP-LA
		hpr(5) 	<= repro;	-- HP-LA
		hpr(6) 	<= nres;	-- HP-LA		
		hpr(7) 	<= vprog;	-- HP-LA
--		hpr(7) 	<= ;
		hpr(10 downto 8) 	<= csrr0(2 downto 0);	-- HP-LA
--		hpr(9) 	<= ckcsro(0);	-- HP-LA
--		hpr(10) 	<= vprog;	-- HP-LA	
		hpr(11) 	<= init_s;	-- HP-LA	
		hpr(12) 	<= cclk;	-- HP-LA	
		hpr(13) 	<= fl(23);	-- HP-LA	
--		hpr(13 downto 8) 	<= contr;	-- HP-LA	
		hpr(14) 	<= fl(24);	-- HP-LA	
--		hpr(15) 	<= ka_data;	-- HP-LA	
--		hpr(14) 	<= res(1);	-- HP-LA	
--		hpr(15) 	<= res(2);	-- HP-LA	
---------------------------- vme interface ------------------------------
--		hpr(0) 	<= asis;	-- HP-LA
--		hpr(1) 	<= sts;	-- HP-LA
--		hpr(2) 	<= cefsh;	-- HP-LA	
--		hpr(3) 	<= oefsh;	-- done
--		hpr(3) 	<= wefsh;	-- HP-LA
--		hpr(5) 	<= ad(2);	-- HP-LA
--		hpr(4) 	<= oavi;	-- HP-LA
--		hpr(5) 	<= odiv;	-- HP-LA
--		hpr(6) 	<= cavi;	-- HP-LA
--		hpr(7) 	<= cdiv;	-- HP-LA
--		hpr(10) 	<= drfsh(1);	-- oedr
--		hpr(10) 	<= drfsh(2);	-- oedf
--		hpr(11) 	<= drfsh(3);	-- =ckdf
--		hpr(11) 	<= drfsh(0);	-- =ckdr
--		hpr(11 downto 8) 		<= aph_sta;	-- HP-LA
--		hpr(15 downto 12) 	<= fsh_sta;	-- HP-LA	
--		hpr(15 downto 12) 	<= df(3 downto 0);	-- HP-LA	
		
---...................................................................
	end;	
