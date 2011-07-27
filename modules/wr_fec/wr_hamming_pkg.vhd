-------------------------------------------------------------------------------
-- Title      : Forward Error Correction
-- Project    : WhiteRabbit Node
-------------------------------------------------------------------------------
-- File       : hamming_pkg.vhd
-- Author     : Maciej Lipinski
-- Company    : CERN BE-Co-HT
-- Created    : 2011-04-05
-- Last update: 2011-04-05
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
--
-- Copyright (c) 2011 Maciej Lipinski / CERN
--
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2011-04-05  1.0      mlipinsk Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.CEIL;
use ieee.math_real.log2;
--use work.hamm_package_496bit.all;
use work.hamm_package_64bit.all;

package wr_hamming_pkg is
  
  function hamming
      (data_in     : data_ham_64bit;
       data_in_size: integer )
      return parity_ham_64bit;


end wr_hamming_pkg;  

package body wr_hamming_pkg is
  
  function hamming(data_in     : data_ham_64bit;
                   data_in_size: integer )
                   --data_in_size: std_logic_vector(8 downto 0)) 
          return parity_ham_64bit is
          VARIABLE parity: parity_ham_64bit;
  begin
    
    parity := (others =>'0');
    
    --if(data_in_size < "000111001") then  -- 57
    if(data_in_size < 65) then  -- 57
    
       parity(7 downto 0) := hamming_encoder_64bit(data_in(63 downto 0));
       

--   elsif(data_in_size < 497) then  -- 497
--       parity(9 downto 0) := hamming_encoder_496bit(data_in(495 downto 0));
   end if;
  
   return parity;
 end hamming;
  
end package body;  