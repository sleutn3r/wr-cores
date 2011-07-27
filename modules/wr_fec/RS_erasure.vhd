------------------------------------------------------
-- model:     ENTITY RS_erasure
-- copyright: Wesley W. Terpstra, GSI GmbH, 12/11/2010
--
-- description
--   Reed-Solomon Erasure encoder/decoder
--
------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.gf256_pkg.ALL;
USE work.rs_pkg.ALL;

ENTITY RS_erasure IS
  PORT(
    clk_in     : IN    STD_LOGIC;
    --reset_in   : IN    STD_LOGIC;
    rst_n_i   : IN    STD_LOGIC;

    
    -- controls to program the loss pattern
    i_in       : IN    Karray;    -- indices of the losses given to stream_in
    request_in : IN    STD_LOGIC; -- load the requested loss pattern
    ready_out  : OUT   STD_LOGIC; -- the loss pattern has been programmed
    
    -- controls for decoding the preprogrammed loss pattern
    enable_in  : IN    STD_LOGIC; -- data is flowing in on stream_in
    stream_in  : IN    Marray;    -- byte stream to repair (EOS signalled by enable low)
    done_out   : OUT   STD_LOGIC; -- decoded result is ready
    result_out : OUT   KMarray);
END RS_erasure;

ARCHITECTURE rtl OF RS_erasure IS
  -- Signals used in the preprocessor
  SIGNAL shift       : Karray; -- the loss indices shifting down
  SIGNAL g2i         : STD_LOGIC_VECTOR(7 DOWNTO 0); -- g^2^i
  SIGNAL counter     : STD_LOGIC_VECTOR(7 DOWNTO 0); -- count from 0 to K
  
  -- Output values of the preprocessor
  SIGNAL lambda      : Larray; -- l(x) the polynomial
  SIGNAL wi          : Karray; -- g^i
  
  -- Pipeline control flags
  SIGNAL stage1done  : STD_LOGIC; -- Stage1 registers are filled
  SIGNAL stage2done  : STD_LOGIC; -- Stage2 registers are filled
  
  -- Stage 0.5 registers (switched with lambda and wi)
  SIGNAL chien       : Larray; -- l[i]*g^{(i-1)*c}
  SIGNAL wg1i        : Karray; -- w[i]*g^{-c}
  -- Stage 1 registers
  SIGNAL idlx        : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL mux         : Marray;
  SIGNAL divisor     : Karray;
  -- Stage 2 registers
  SIGNAL selection   : Karray;
  SIGNAL accumulator : KMarray;
  -- Stage 3 registers (output)
BEGIN
  preprocess : PROCESS(clk_in)
    VARIABLE w : STD_LOGIC_VECTOR(7 DOWNTO 0);
  BEGIN
    IF rising_edge(clk_in) THEN
      --IF reset_in = '1' THEN
      IF rst_n_i = '0' THEN
        FOR k IN 0 TO K-1 LOOP
          shift(k) <= x"00";
          wi(k) <= x"01";
          lambda(k+1) <= x"00";
        END LOOP;
        lambda(0) <= x"01";
        
        g2i <= gf256_gen(1);
        counter <= x"00"; --STD_LOGIC_VECTOR(TO_SIGNED(8+K));
        ready_out <= '1';
      ELSIF request_in = '1' THEN
        FOR k IN 0 TO K-1 LOOP
          shift(k) <= i_in(k);
          wi(k) <= x"01";
          lambda(k+1) <= x"00";
        END LOOP;
        lambda(0) <= x"01";
        
        g2i <= gf256_gen(1);
        counter <= x"00";
        ready_out <= '0';
      ELSE
        FOR k IN 0 TO K-1 LOOP
          if shift(k)(0) = '1' THEN
            wi(k) <= gf256_mul(wi(k), g2i);
          END IF;
          FOR b IN 0 TO 6 LOOP
            shift(k)(b) <= shift(k)(b+1);
          END LOOP;
          shift(k)(7) <= '0';
        END LOOP;
        g2i <= gf256_mul(g2i, g2i);
        
        IF UNSIGNED(counter) < 8 THEN
          counter <= STD_LOGIC_VECTOR(UNSIGNED(counter) + 1);
        ELSIF UNSIGNED(counter) < 8+K THEN
          w := wi(TO_INTEGER(UNSIGNED(counter)) - 8);
          FOR k IN K DOWNTO 1 LOOP
            lambda(k) <= gf256_fma(lambda(k), w, lambda(k-1));
          END LOOP;
          lambda(0) <= gf256_mul(lambda(0), w);
          counter <= STD_LOGIC_VECTOR(UNSIGNED(counter) + 1);
        ELSE
          ready_out <= '1';
        END IF;
      END IF;
    END IF;
  END PROCESS preprocess;
  
  control : PROCESS(clk_in)
  BEGIN
    IF rising_edge(clk_in) THEN
      --IF reset_in = '1' THEN
      IF rst_n_i = '0' THEN
        stage1done <= '0';
        stage2done <= '0';
        done_out <= '1';
      ELSE
        stage1done <= enable_in;
        stage2done <= stage1done;
        done_out <= NOT (enable_in OR stage1done);
      END IF;
    END IF;
  END PROCESS control;

  stage05 : PROCESS(clk_in)
    VARIABLE first : STD_LOGIC;
    VARIABLE chien_old : Larray;
    VARIABLE wg1i_old  : Karray;
  BEGIN
    IF rising_edge(clk_in) THEN
      first := enable_in AND NOT stage1done;
      
      --IF reset_in = '1' THEN
      IF rst_n_i = '0' THEN
        FOR k IN 0 TO K-1 LOOP
          chien(k) <= x"00";
          wg1i(k) <= x"00";
        END LOOP;
        chien(K) <= x"00";
      ELSE
        IF first = '1' THEN
          chien_old := lambda;
          wg1i_old := wi;
        ELSE
          chien_old := chien;
          wg1i_old := wg1i;
        END IF;
        
        FOR k IN 0 TO K-1 LOOP
          chien(k) <= gf256_mulc(chien_old(k), gf256_gen(k-1));
          wg1i(k) <= gf256_mulc(wg1i_old(k), gf256_gen(-1));
        END LOOP;
        chien(K) <= gf256_mulc(chien_old(K), gf256_gen(K-1));
      END IF;
    END IF;
  END PROCESS stage05;
  
  stage1 : PROCESS(clk_in)
    VARIABLE lx  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    VARIABLE dlx : STD_LOGIC_VECTOR(7 DOWNTO 0);
    VARIABLE chien_old : Larray;
    VARIABLE wg1i_old  : Karray;
    VARIABLE first : STD_LOGIC;
  BEGIN
    IF rising_edge(clk_in) THEN
      first := enable_in AND NOT stage1done;
      --IF reset_in = '1' THEN
      IF rst_n_i = '0' THEN
        FOR k IN 0 TO K-1 LOOP
          divisor(k) <= x"00";
        END LOOP;
        FOR m IN 0 TO M-1 LOOP
          mux(m) <= x"00";
        END LOOP;
        
        idlx <= x"00";
      ELSE
        IF first = '1' THEN
          chien_old := lambda;
          wg1i_old := wi;
        ELSE
          chien_old := chien;
          wg1i_old := wg1i;
        END IF;
        
        lx := x"00";
        dlx := x"00";
        FOR k IN 0 TO K LOOP
          lx := lx XOR chien_old(k);
          IF k MOD 2 = 1 THEN
            dlx := dlx XOR chien_old(k);
          END IF;
        END LOOP;
        
        FOR k IN 0 TO K-1 LOOP
          divisor(k) <= gf256_inv(x"01" XOR wg1i_old(k));
        END LOOP;
        
        FOR m IN 0 TO M-1 LOOP
          mux(m) <= gf256_mul(stream_in(m), lx);
        END LOOP;
        idlx <= gf256_inv(dlx);
      END IF;
    END IF;
  END PROCESS stage1;
  
  stage2 : PROCESS(clk_in)
    VARIABLE first : STD_LOGIC;
  BEGIN
    IF rising_edge(clk_in) THEN
      first := stage1done AND NOT stage2done;
      
      --IF reset_in = '1' THEN
      IF rst_n_i = '0' THEN
        FOR k IN 0 TO K-1 LOOP
          FOR m IN 0 TO M-1 LOOP
            accumulator(k)(m) <= x"00";
          END LOOP;
          selection(k) <= x"00";
        END LOOP;
      ELSE
        FOR k IN 0 TO K-1 LOOP
          IF divisor(k) = x"00" THEN
            selection(k) <= idlx;
          ELSE
            selection(k) <= selection(k);
          END IF;
          
          FOR m IN 0 TO M-1 LOOP
            IF first = '1' THEN
              accumulator(k)(m) <= gf256_mul(mux(m), divisor(k));
            ELSIF stage1done = '1' THEN
              accumulator(k)(m) <= gf256_fma(mux(m), divisor(k), accumulator(k)(m));
            END IF;
          END LOOP;
        END LOOP;
      END IF;
    END IF;
  END PROCESS stage2;
  
  stage3 : PROCESS(clk_in)
  BEGIN
    IF rising_edge(clk_in) THEN
      --IF reset_in = '1' THEN
      IF rst_n_i = '0' THEN

        FOR k IN 0 TO K-1 LOOP
          FOR m IN 0 TO M-1 LOOP
            result_out(k)(m) <= x"00";
          END LOOP;
        END LOOP;
      ELSE
        FOR k IN 0 TO K-1 LOOP
          FOR m IN 0 TO M-1 LOOP
            result_out(k)(m) <= gf256_mul(accumulator(k)(m), selection(k));
          END LOOP;
        END LOOP;
      END IF;
    END IF;
  END PROCESS stage3;

END rtl;
