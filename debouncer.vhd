LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY DEBOUNCER IS
  GENERIC(
  counter_size  :NATURAL:= 20); --un numarator de 19 biti este suficient cat sa ne dam seama daca semnaul este stabil
                                --(avand in vedere clockul de 50 MHZ) => 10,49 microsecunde (atat timp trebue sa avem un semal staul pt
                                -- a-l valida)
PORT(
    clk      : IN  STD_LOGIC;  --clock
    tasta 	 : IN  STD_LOGIC;  	--semnalul care trebuie sa fie stabilizat
    rezultat : OUT STD_LOGIC); --semnalul stabilizat
END DEBOUNCER;

ARCHITECTURE ARH_DEBOUNCER OF DEBOUNCER IS
  SIGNAL bistabil   : STD_LOGIC_VECTOR(1 DOWNTO 0); --ne ajuta la determianre satbilitatii 
  SIGNAL counter_set : STD_LOGIC;                    --resetare sincrona 
  SIGNAL counter_out : STD_LOGIC_VECTOR(counter_size DOWNTO 0) := (OTHERS => '0'); 
BEGIN

  counter_set <= bistabil(0) xor bistabil(1);   --determina cand incepe/se reseteaza numaratoarea(daca am ajuns la safrasit sau un semal
                                                -- nu a fost satabil)
  
  PROCESS(clk)
  BEGIN
    IF(clk'EVENT and clk = '1') THEN   -- se retin ultimele 2 valori ale semalului care trebuie sa ramana identice intr-un cliclu de CLK
      bistabil(0) <= tasta;
      bistabil(1) <= bistabil(0);
      If(counter_set = '1') THEN                  --reset counter pentru ca input se schimba
        counter_out <= (OTHERS => '0');
      ELSIF(counter_out(counter_size) = '0') THEN --input time stabil neintalnit 
        counter_out <= counter_out + 1;
      ELSE                                        --input time intalnit
        rezultat <= bistabil(1);
      END IF;    
    END IF;
  END PROCESS;
END ARH_DEBOUNCER;