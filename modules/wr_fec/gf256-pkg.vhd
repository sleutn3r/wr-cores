------------------------------------------------------
-- model:     PACKAGE gf256_pkg
-- copyright: Wesley W. Terpstra, GSI GmbH, 12/11/2010
--
-- description
--   arithmetic functions for elements in GF(2^8)
--   compiled for modulus = 1B and generator = 03
--
------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

PACKAGE gf256_pkg IS

  TYPE multab_type IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(63 DOWNTO 0);
  TYPE tab_type IS ARRAY (0 TO 255) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

  CONSTANT multab : multab_type := (
    0 => x"62C4881020408001",
    1 => x"A64C983060C08102",
    2 => x"4C983060C0810204",
    3 => x"FAF4E8D0A1428408",
    4 => x"962C58B162C48810",
    5 => x"2C58B162C4881020",
    6 => x"58B162C488102040",
    7 => x"B162C48810204080");
  CONSTANT gentab : tab_type := (
      0 => x"01",   1 => x"03",   2 => x"05",   3 => x"0F", 
      4 => x"11",   5 => x"33",   6 => x"55",   7 => x"FF", 
      8 => x"1A",   9 => x"2E",  10 => x"72",  11 => x"96", 
     12 => x"A1",  13 => x"F8",  14 => x"13",  15 => x"35", 
     16 => x"5F",  17 => x"E1",  18 => x"38",  19 => x"48", 
     20 => x"D8",  21 => x"73",  22 => x"95",  23 => x"A4", 
     24 => x"F7",  25 => x"02",  26 => x"06",  27 => x"0A", 
     28 => x"1E",  29 => x"22",  30 => x"66",  31 => x"AA", 
     32 => x"E5",  33 => x"34",  34 => x"5C",  35 => x"E4", 
     36 => x"37",  37 => x"59",  38 => x"EB",  39 => x"26", 
     40 => x"6A",  41 => x"BE",  42 => x"D9",  43 => x"70", 
     44 => x"90",  45 => x"AB",  46 => x"E6",  47 => x"31", 
     48 => x"53",  49 => x"F5",  50 => x"04",  51 => x"0C", 
     52 => x"14",  53 => x"3C",  54 => x"44",  55 => x"CC", 
     56 => x"4F",  57 => x"D1",  58 => x"68",  59 => x"B8", 
     60 => x"D3",  61 => x"6E",  62 => x"B2",  63 => x"CD", 
     64 => x"4C",  65 => x"D4",  66 => x"67",  67 => x"A9", 
     68 => x"E0",  69 => x"3B",  70 => x"4D",  71 => x"D7", 
     72 => x"62",  73 => x"A6",  74 => x"F1",  75 => x"08", 
     76 => x"18",  77 => x"28",  78 => x"78",  79 => x"88", 
     80 => x"83",  81 => x"9E",  82 => x"B9",  83 => x"D0", 
     84 => x"6B",  85 => x"BD",  86 => x"DC",  87 => x"7F", 
     88 => x"81",  89 => x"98",  90 => x"B3",  91 => x"CE", 
     92 => x"49",  93 => x"DB",  94 => x"76",  95 => x"9A", 
     96 => x"B5",  97 => x"C4",  98 => x"57",  99 => x"F9", 
    100 => x"10", 101 => x"30", 102 => x"50", 103 => x"F0", 
    104 => x"0B", 105 => x"1D", 106 => x"27", 107 => x"69", 
    108 => x"BB", 109 => x"D6", 110 => x"61", 111 => x"A3", 
    112 => x"FE", 113 => x"19", 114 => x"2B", 115 => x"7D", 
    116 => x"87", 117 => x"92", 118 => x"AD", 119 => x"EC", 
    120 => x"2F", 121 => x"71", 122 => x"93", 123 => x"AE", 
    124 => x"E9", 125 => x"20", 126 => x"60", 127 => x"A0", 
    128 => x"FB", 129 => x"16", 130 => x"3A", 131 => x"4E", 
    132 => x"D2", 133 => x"6D", 134 => x"B7", 135 => x"C2", 
    136 => x"5D", 137 => x"E7", 138 => x"32", 139 => x"56", 
    140 => x"FA", 141 => x"15", 142 => x"3F", 143 => x"41", 
    144 => x"C3", 145 => x"5E", 146 => x"E2", 147 => x"3D", 
    148 => x"47", 149 => x"C9", 150 => x"40", 151 => x"C0", 
    152 => x"5B", 153 => x"ED", 154 => x"2C", 155 => x"74", 
    156 => x"9C", 157 => x"BF", 158 => x"DA", 159 => x"75", 
    160 => x"9F", 161 => x"BA", 162 => x"D5", 163 => x"64", 
    164 => x"AC", 165 => x"EF", 166 => x"2A", 167 => x"7E", 
    168 => x"82", 169 => x"9D", 170 => x"BC", 171 => x"DF", 
    172 => x"7A", 173 => x"8E", 174 => x"89", 175 => x"80", 
    176 => x"9B", 177 => x"B6", 178 => x"C1", 179 => x"58", 
    180 => x"E8", 181 => x"23", 182 => x"65", 183 => x"AF", 
    184 => x"EA", 185 => x"25", 186 => x"6F", 187 => x"B1", 
    188 => x"C8", 189 => x"43", 190 => x"C5", 191 => x"54", 
    192 => x"FC", 193 => x"1F", 194 => x"21", 195 => x"63", 
    196 => x"A5", 197 => x"F4", 198 => x"07", 199 => x"09", 
    200 => x"1B", 201 => x"2D", 202 => x"77", 203 => x"99", 
    204 => x"B0", 205 => x"CB", 206 => x"46", 207 => x"CA", 
    208 => x"45", 209 => x"CF", 210 => x"4A", 211 => x"DE", 
    212 => x"79", 213 => x"8B", 214 => x"86", 215 => x"91", 
    216 => x"A8", 217 => x"E3", 218 => x"3E", 219 => x"42", 
    220 => x"C6", 221 => x"51", 222 => x"F3", 223 => x"0E", 
    224 => x"12", 225 => x"36", 226 => x"5A", 227 => x"EE", 
    228 => x"29", 229 => x"7B", 230 => x"8D", 231 => x"8C", 
    232 => x"8F", 233 => x"8A", 234 => x"85", 235 => x"94", 
    236 => x"A7", 237 => x"F2", 238 => x"0D", 239 => x"17", 
    240 => x"39", 241 => x"4B", 242 => x"DD", 243 => x"7C", 
    244 => x"84", 245 => x"97", 246 => x"A2", 247 => x"FD", 
    248 => x"1C", 249 => x"24", 250 => x"6C", 251 => x"B4", 
    252 => x"C7", 253 => x"52", 254 => x"F6", 255 => x"01");
  CONSTANT invtab : tab_type := (
      0 => x"00",   1 => x"01",   2 => x"8D",   3 => x"F6", 
      4 => x"CB",   5 => x"52",   6 => x"7B",   7 => x"D1", 
      8 => x"E8",   9 => x"4F",  10 => x"29",  11 => x"C0", 
     12 => x"B0",  13 => x"E1",  14 => x"E5",  15 => x"C7", 
     16 => x"74",  17 => x"B4",  18 => x"AA",  19 => x"4B", 
     20 => x"99",  21 => x"2B",  22 => x"60",  23 => x"5F", 
     24 => x"58",  25 => x"3F",  26 => x"FD",  27 => x"CC", 
     28 => x"FF",  29 => x"40",  30 => x"EE",  31 => x"B2", 
     32 => x"3A",  33 => x"6E",  34 => x"5A",  35 => x"F1", 
     36 => x"55",  37 => x"4D",  38 => x"A8",  39 => x"C9", 
     40 => x"C1",  41 => x"0A",  42 => x"98",  43 => x"15", 
     44 => x"30",  45 => x"44",  46 => x"A2",  47 => x"C2", 
     48 => x"2C",  49 => x"45",  50 => x"92",  51 => x"6C", 
     52 => x"F3",  53 => x"39",  54 => x"66",  55 => x"42", 
     56 => x"F2",  57 => x"35",  58 => x"20",  59 => x"6F", 
     60 => x"77",  61 => x"BB",  62 => x"59",  63 => x"19", 
     64 => x"1D",  65 => x"FE",  66 => x"37",  67 => x"67", 
     68 => x"2D",  69 => x"31",  70 => x"F5",  71 => x"69", 
     72 => x"A7",  73 => x"64",  74 => x"AB",  75 => x"13", 
     76 => x"54",  77 => x"25",  78 => x"E9",  79 => x"09", 
     80 => x"ED",  81 => x"5C",  82 => x"05",  83 => x"CA", 
     84 => x"4C",  85 => x"24",  86 => x"87",  87 => x"BF", 
     88 => x"18",  89 => x"3E",  90 => x"22",  91 => x"F0", 
     92 => x"51",  93 => x"EC",  94 => x"61",  95 => x"17", 
     96 => x"16",  97 => x"5E",  98 => x"AF",  99 => x"D3", 
    100 => x"49", 101 => x"A6", 102 => x"36", 103 => x"43", 
    104 => x"F4", 105 => x"47", 106 => x"91", 107 => x"DF", 
    108 => x"33", 109 => x"93", 110 => x"21", 111 => x"3B", 
    112 => x"79", 113 => x"B7", 114 => x"97", 115 => x"85", 
    116 => x"10", 117 => x"B5", 118 => x"BA", 119 => x"3C", 
    120 => x"B6", 121 => x"70", 122 => x"D0", 123 => x"06", 
    124 => x"A1", 125 => x"FA", 126 => x"81", 127 => x"82", 
    128 => x"83", 129 => x"7E", 130 => x"7F", 131 => x"80", 
    132 => x"96", 133 => x"73", 134 => x"BE", 135 => x"56", 
    136 => x"9B", 137 => x"9E", 138 => x"95", 139 => x"D9", 
    140 => x"F7", 141 => x"02", 142 => x"B9", 143 => x"A4", 
    144 => x"DE", 145 => x"6A", 146 => x"32", 147 => x"6D", 
    148 => x"D8", 149 => x"8A", 150 => x"84", 151 => x"72", 
    152 => x"2A", 153 => x"14", 154 => x"9F", 155 => x"88", 
    156 => x"F9", 157 => x"DC", 158 => x"89", 159 => x"9A", 
    160 => x"FB", 161 => x"7C", 162 => x"2E", 163 => x"C3", 
    164 => x"8F", 165 => x"B8", 166 => x"65", 167 => x"48", 
    168 => x"26", 169 => x"C8", 170 => x"12", 171 => x"4A", 
    172 => x"CE", 173 => x"E7", 174 => x"D2", 175 => x"62", 
    176 => x"0C", 177 => x"E0", 178 => x"1F", 179 => x"EF", 
    180 => x"11", 181 => x"75", 182 => x"78", 183 => x"71", 
    184 => x"A5", 185 => x"8E", 186 => x"76", 187 => x"3D", 
    188 => x"BD", 189 => x"BC", 190 => x"86", 191 => x"57", 
    192 => x"0B", 193 => x"28", 194 => x"2F", 195 => x"A3", 
    196 => x"DA", 197 => x"D4", 198 => x"E4", 199 => x"0F", 
    200 => x"A9", 201 => x"27", 202 => x"53", 203 => x"04", 
    204 => x"1B", 205 => x"FC", 206 => x"AC", 207 => x"E6", 
    208 => x"7A", 209 => x"07", 210 => x"AE", 211 => x"63", 
    212 => x"C5", 213 => x"DB", 214 => x"E2", 215 => x"EA", 
    216 => x"94", 217 => x"8B", 218 => x"C4", 219 => x"D5", 
    220 => x"9D", 221 => x"F8", 222 => x"90", 223 => x"6B", 
    224 => x"B1", 225 => x"0D", 226 => x"D6", 227 => x"EB", 
    228 => x"C6", 229 => x"0E", 230 => x"CF", 231 => x"AD", 
    232 => x"08", 233 => x"4E", 234 => x"D7", 235 => x"E3", 
    236 => x"5D", 237 => x"50", 238 => x"1E", 239 => x"B3", 
    240 => x"5B", 241 => x"23", 242 => x"38", 243 => x"34", 
    244 => x"68", 245 => x"46", 246 => x"03", 247 => x"8C", 
    248 => x"DD", 249 => x"9C", 250 => x"7D", 251 => x"A0", 
    252 => x"CD", 253 => x"1A", 254 => x"41", 255 => x"1C");

  FUNCTION gf256_fma (a, b, c : STD_LOGIC_VECTOR(7 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR;
  FUNCTION gf256_mul (a, b : STD_LOGIC_VECTOR(7 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR;
  FUNCTION gf256_mulc (a, c : STD_LOGIC_VECTOR(7 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR;
  FUNCTION gf256_gen (x : INTEGER)
    RETURN STD_LOGIC_VECTOR;
  FUNCTION gf256_inv (x : STD_LOGIC_VECTOR(7 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR;

END gf256_pkg;

PACKAGE BODY gf256_pkg IS

  FUNCTION gf256_fma (a, b, c : STD_LOGIC_VECTOR(7 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR IS
    VARIABLE result : STD_LOGIC_VECTOR(7 DOWNTO 0);
  BEGIN
    result := c;
    FOR o IN 0 TO 7 LOOP
      FOR i IN 0 TO 7 LOOP
        FOR j IN 0 TO 7 LOOP
          IF multab(o)(i*8+j) = '1' THEN
            result(o) := result(o) XOR (a(i) AND b(j));
          END IF;
        END LOOP;
      END LOOP;
    END LOOP;
    RETURN result;
  END gf256_fma;

  FUNCTION gf256_mul (a, b : STD_LOGIC_VECTOR(7 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN gf256_fma(a, b, x"00");
  END gf256_mul;

  FUNCTION gf256_mulc (a, c : STD_LOGIC_VECTOR(7 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR IS
    VARIABLE result : STD_LOGIC_VECTOR(7 DOWNTO 0);
    VARIABLE toggle : STD_LOGIC;
  BEGIN
    result := x"00";
    FOR o IN 0 TO 7 LOOP
      FOR i IN 0 TO 7 LOOP
        toggle := '0';
        FOR j IN 0 TO 7 LOOP
          IF multab(o)(i*8+j) = '1' THEN
            toggle := toggle XOR c(j);
          END IF;
        END LOOP;
        IF toggle = '1' THEN
          result(o) := result(o) XOR a(i);
        END IF;
      END LOOP;
    END LOOP;
    RETURN result;
  END gf256_mulc;

  FUNCTION gf256_gen (x : INTEGER)
    RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN gentab(x MOD 255);
  END gf256_gen;

  FUNCTION gf256_inv (x : STD_LOGIC_VECTOR(7 DOWNTO 0))
    RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN invtab(to_integer(unsigned(x)));
  END gf256_inv;

END gf256_pkg;
