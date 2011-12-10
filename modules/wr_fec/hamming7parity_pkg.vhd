LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

PACKAGE hamm_package_64bit IS
	SUBTYPE parity_ham_64bit IS std_logic_vector(7 DOWNTO 0);
	SUBTYPE data_ham_64bit IS std_logic_vector(63 DOWNTO 0);
	SUBTYPE coded_ham_64bit IS std_logic_vector(71 DOWNTO 0);

	FUNCTION hamming_encoder_64bit(data_in:data_ham_64bit) RETURN parity_ham_64bit;

END hamm_package_64bit;

PACKAGE BODY hamm_package_64bit IS

---------------------
-- HAMMING ENCODER --  not used in FEC
---------------------
FUNCTION hamming_encoder_64bit(data_in:data_ham_64bit) RETURN parity_ham_64bit  IS
	VARIABLE parity: parity_ham_64bit;
BEGIN

	parity(7)	:=	data_in(57) XOR data_in(58) XOR data_in(59) XOR data_in(60) XOR data_in(61) XOR 
					data_in(62) XOR data_in(63);
   
	parity(6)	:=	data_in(26) XOR data_in(27) XOR data_in(28) XOR data_in(29) XOR data_in(30) XOR 
					data_in(31) XOR data_in(32) XOR data_in(33) XOR data_in(34) XOR data_in(35) XOR 
					data_in(36) XOR data_in(37) XOR data_in(38) XOR data_in(39) XOR data_in(40) XOR 
					data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR data_in(45) XOR 
					data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56);
   
	parity(5)	:=	data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR data_in(15) XOR 
					data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR data_in(45) XOR 
					data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56);
   
	parity(4)	:=	data_in(4) XOR data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(33) XOR data_in(34) XOR data_in(35) XOR data_in(36) XOR data_in(37) XOR 
					data_in(38) XOR data_in(39) XOR data_in(40) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56);
   
	parity(3)	:=	data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(14) XOR data_in(15) XOR data_in(16) XOR 
					data_in(17) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(29) XOR data_in(30) XOR data_in(31) XOR data_in(32) XOR data_in(37) XOR 
					data_in(38) XOR data_in(39) XOR data_in(40) XOR data_in(45) XOR data_in(46) XOR 
					data_in(47) XOR data_in(48) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(60) XOR data_in(61) XOR data_in(62) XOR data_in(63);
   
					
	parity(2)	:=	data_in(0) XOR data_in(2) XOR data_in(3) XOR data_in(5) XOR data_in(6) XOR 
					data_in(9) XOR data_in(10) XOR data_in(12) XOR data_in(13) XOR data_in(16) XOR 
					data_in(17) XOR data_in(20) XOR data_in(21) XOR data_in(24) XOR data_in(25) XOR 
					data_in(27) XOR data_in(28) XOR data_in(31) XOR data_in(32) XOR data_in(35) XOR 
					data_in(36) XOR data_in(39) XOR data_in(40) XOR data_in(43) XOR data_in(44) XOR 
					data_in(47) XOR data_in(48) XOR data_in(51) XOR data_in(52) XOR data_in(55) XOR 
					data_in(56) XOR data_in(58) XOR data_in(59) XOR data_in(62) XOR data_in(63);
   
					
	parity(1)	:=	data_in(0) XOR data_in(1) XOR data_in(3) XOR data_in(4) XOR data_in(6) XOR 
					data_in(8) XOR data_in(10) XOR data_in(11) XOR data_in(13) XOR data_in(15) XOR 
					data_in(17) XOR data_in(19) XOR data_in(21) XOR data_in(23) XOR data_in(25) XOR 
					data_in(26) XOR data_in(28) XOR data_in(30) XOR data_in(32) XOR data_in(34) XOR 
					data_in(36) XOR data_in(38) XOR data_in(40) XOR data_in(42) XOR data_in(44) XOR 
					data_in(46) XOR data_in(48) XOR data_in(50) XOR data_in(52) XOR data_in(54) XOR 
					data_in(56) XOR data_in(57) XOR data_in(59) XOR data_in(61) XOR data_in(63);
   
					
	parity(0)	:=	data_in(0) XOR data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(4) XOR 
					data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR data_in(9) XOR 
					data_in(10) XOR data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR 
					data_in(15) XOR data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR 
					data_in(20) XOR data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR 
					data_in(25) XOR data_in(26) XOR data_in(27) XOR data_in(28) XOR data_in(29) XOR 
					data_in(30) XOR data_in(31) XOR data_in(32) XOR data_in(33) XOR data_in(34) XOR 
					data_in(35) XOR data_in(36) XOR data_in(37) XOR data_in(38) XOR data_in(39) XOR 
					data_in(40) XOR data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR 
					data_in(45) XOR data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR 
					data_in(50) XOR data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR 
					data_in(55) XOR data_in(56) XOR data_in(57) XOR data_in(58) XOR data_in(59) XOR 
					data_in(60) XOR data_in(61) XOR data_in(62) XOR data_in(63) XOR parity(1) XOR 
					parity(2) XOR parity(3) XOR parity(4) XOR parity(5) XOR parity(6) XOR 
					parity(7) ;


	RETURN parity;
END;


END PACKAGE BODY;
