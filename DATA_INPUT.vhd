LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY INPUT IS
  GENERIC(
    clk_freq              : INTEGER := 100_000_000; --clock-ul sistemului in Hz
    debounce_counter_size : INTEGER := 9);         --2^9/100_000_000= 5 microsecude
  PORT(
    clk          : IN  STD_LOGIC;                     --clock sistem
    ps2_clk      : IN  STD_LOGIC;                     --clock-ul tastaturii
    ps2_data     : IN  STD_LOGIC;                     --data primita de la tastatura
    EnableCode : OUT STD_LOGIC;
	error: out std_logic;--un flag care semnaleaza case un nou cod se poate citi
    ps2_code     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --vector de 11 biti primiti serial de la taastatura
END INPUT;

ARCHITECTURE DATA_INPUT OF INPUT IS	
--declarare de semnale
  SIGNAL sincronizare_bistabile:STD_LOGIC_VECTOR(1 DOWNTO 0);      
  SIGNAL ps2_clk_int : STD_LOGIC;                          --debounced clock signal de la tastatura 
  SIGNAL ps2_data_int: STD_LOGIC;                          --debounced data signal de la tastatura
  SIGNAL vector11: STD_LOGIC_VECTOR(10 DOWNTO 0);      --memoraeaza data de la tastatura
  SIGNAL eroare: STD_LOGIC;                          --valideaza bitii de paritatate, start si stop
  SIGNAL count_idle:std_logic_vector(3 downto 0):="0000"; --numarator 
  --
  COMPONENT DEBOUNCER IS
    GENERIC(counter_size:NATURAL); 
    PORT(
      clk:IN  STD_LOGIC;  --input clock
      tasta:IN  STD_LOGIC;  --semnalul ce trebuie stabilizar
      rezultat:OUT STD_LOGIC); --semnalul stabilizat
  END COMPONENT;
BEGIN

--sincronizare bistabile
  PROCESS(clk)
  BEGIN
    IF(clk'EVENT AND clk = '1') THEN 
      sincronizare_bistabile(0) <= ps2_clk;           --sincronizare semnalul PS/2 clock 
      sincronizare_bistabile(1) <= ps2_data;          --sincronizare semnalul PS/2 data
    END IF;
  END PROCESS;

  --stabilizare semnale input PS2 
--  --debouncer folosit de 2 ori
-- debounce_ps2_clk: DEBOUNCER
--    GENERIC MAP(counter_size => debounce_counter_size)
--    PORT MAP(clk => clk, tasta => sincronizare_bistabile(0), rezultat => ps2_clk_int);
-- debounce_ps2_data: DEBOUNCER
--    GENERIC MAP(counter_size => debounce_counter_size)
--    PORT MAP(clk => clk,tasta=> sincronizare_bistabile(1), rezultat=> ps2_data_int);
--
  --input PS2 data
  PROCESS(ps2_clk)
  BEGIN
    IF(ps2_clk'EVENT AND ps2_clk = '1') THEN    
      vector11 <= ps2_data&vector11(10 DOWNTO 1);   --shifare bitilor ai PS2 data
    END IF;
  END PROCESS;
    
  --verificare corectitudine date(paritate, start si stop)
   eroare <= NOT (NOT vector11(0) AND vector11(10) AND (vector11(9) XOR vector11(8) XOR
        vector11(7) XOR vector11(6) XOR vector11(5) XOR vector11(4) XOR vector11(3) XOR 
        vector11(2) XOR vector11(1)));   

  
		--determine if PS2 port is idle (i.e. last transaction is finished) and output result
			PROCESS(clk)
  BEGIN
    IF(clk'EVENT AND clk = '1') THEN           --frontul crescator al clock-ului sistemului
    
      IF(ps2_clk = '0') THEN                 --low PS2 clock
        count_idle <= "0000";                           --resetare idle counter
      ELSIF(ps2_clk='1') THEN 
          count_idle <= count_idle + 1;            --cotinuare numarare
      END IF;
      
      IF(count_idle="1011") then --and eroare='0') then-- -- AND eroare = '0') THEN  --idle threshold reached si fara erori detectate
        EnableCode <= '1';                                   -- PS/2 code nou este disponibil
        ps2_code <= vector11(8 downto 1);
		 count_idle<="0000";                          --output new PS/2 code
      ELSE                                                   --PS/2 port active sau eroare detectata
        EnableCode <= '0';                                   --seteaza semnalul ca s-a terminat tranzactia
      END IF;
      
    END IF;
  END PROCESS;
  error<=eroare;
END DATA_INPUT;