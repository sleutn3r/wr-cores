------------------------------------------------------
-- model:     RS_erasure configuration parameters
-- copyright: Wesley W. Terpstra, GSI GmbH, 12/11/2010
--
-- description
--   The parameters K and M used in the (de/en)coder
--
------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

PACKAGE rs_pkg IS
	CONSTANT K : INTEGER := 2; -- Number of lost symbols to recover
	CONSTANT M : INTEGER := 8; -- Number of bytes to decode in parallel
	
	TYPE Marray  IS ARRAY(0 TO M-1) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	TYPE Karray  IS ARRAY(0 TO K-1) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	TYPE Larray  IS ARRAY(0 TO K)   OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	TYPE KMarray IS ARRAY(0 TO K-1) OF Marray;
	
	component RS_erasure is
	  port(
	    clk_in     : in    std_logic;
	    --reset_in   : in    std_logic;
	    rst_n_i    : in    std_logic;
	  
	    -- controls to program the loss pattern
	    i_in       : in    Karray;    -- indices of the losses given to stream_in
	    request_in : in    std_logic; -- load the requested loss pattern
	    ready_out  : out   std_logic; -- the loss pattern has been programmed
	  
	    -- controls for decoding the preprogrammed loss pattern
	    enable_in  : in    std_logic; -- data is flowing in on stream_in
	    stream_in  : in    Marray;    -- byte stream to repair (EOS signalled by enable low)
	    done_out   : out   std_logic; -- decoded result is ready
	    result_out : out   KMarray);
	  end component;   
END rs_pkg;
