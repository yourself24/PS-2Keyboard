library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BCD_7segments is
port(
ADR0: in std_logic_vector(7 downto 0);	   --cei 4 vectori primiti de la unitatea de executie a functiilor speciale
ADR1: in std_logic_vector(7 downto 0);
ADR2: in std_logic_vector(7 downto 0);
ADR3: in std_logic_vector(7 downto 0);
CLK : in std_logic;							   --clk-ul placutei 
catod0: out std_logic_vector(0 to 7);
catod1: out std_logic_vector(0 to 7);
catod2: out std_logic_vector(0 to 7);
catod3: out std_logic_vector(0 to 7)

);
end BCD_7segments;


architecture arh_bcd of BCD_7segments is
	 --cnt folosit pentru divizarea frecventei
signal aux0 : std_logic_vector(7 downto 0):=(others=>'0');
signal aux1 : std_logic_vector(7 downto 0):=(others=>'0') ;
signal aux2: std_logic_vector(7 downto 0):=(others=>'0') ;
signal aux3 : std_logic_vector(7 downto 0):=(others=>'0') ;

type MEMORY_MAP is array(0 to 255) of STD_LOGIC_VECTOR(7 downto 0);	

signal MMAP: MEMORY_MAP;

begin
	MMAP <= (
--aici se realizeaza corespondenta dintre byte-ul perceput de la tastatura si reprezentarea pe 7 segmente a tastei
-- Litere

28 =>  "10001000" ,--A fara . 
156 => "00001000" ,--A cu .
50 =>  "10000011" ,--B fara .
178 => "00000011" ,--B cu .  
33 =>  "11000110" ,--C fara .
161 => "01000110" ,--C cu .
35 =>  "10100001" ,--D fara . 
163 => "00100001" ,--D cu .
36 =>  "10000110" ,--E fara . 
164 => "00000110" ,--E cu . 
43 =>  "10001110" ,--F fara . 
171 => "00001110" ,--F cu . 
52 =>  "11000010" ,--G fara . 
180 => "01000010" ,--G cu .
51 =>  "10001001" ,--H fara . 
179 => "00001001" ,--H cu .
67 =>  "11001111" ,--I fara . 
195 => "01001111" ,--I cu .
59 =>  "11100001" ,--J fara .
187 => "01100001" ,--J cu . 
66 =>  "10001011" ,--K fara . 
194 => "00001011" ,--K cu .
75 =>  "11000111" ,--L fara . 
203 => "01000111" ,--L cu .
58 =>  "11101010" ,--M fara . 
186 => "01101010" ,--M cu .
49 =>  "10101011" ,--N fara . 
177 => "00101011" ,--N cu . 
68 =>  "10100011" ,--O fara . 
196 => "00100011" ,--O cu . 
77 =>  "10001100" ,--P fara .
205 => "00001100" ,--P cu .
21 =>  "10011000" ,--Q fara . 
149 => "00011000" ,--Q cu . 
45 =>  "10101111" ,--R fara . 
173 => "00101111" ,--R cu .
27 =>  "10010011" ,--S fara . 
155 => "00010011" ,--S cu .
44 =>  "10000111" ,--T fara . 
172 => "00000111" ,--T cu . 
60 =>  "11000001" ,--U fara . 
188 => "01000001" ,--U cu .
42 =>  "11100011" ,--V fara . 
170 => "01100011" ,--V cu .
29 =>  "11010101" ,--W fara . 
157 => "01010101" ,--W cu .  
34 =>  "10011011" ,--X fara . 
162 => "00011011" ,--X cu .
53 =>  "10010001" ,--Y fara . 
181 => "00010001" ,--Y cu .
26 =>  "10100101" ,--Z fara . 
154 => "00100101" ,--Z cu .


--Cifre

69 =>  "11000000" ,--0 Fara . 
197 => "01000000" ,--0 Cu .
22 =>  "11111001" ,--1 Fara . 
150 => "01111001" ,--1 Cu .
30 =>  "10100100" ,--2 Fara . 
158 => "00100100" ,--2 Cu .
38 =>  "10110000" ,--3 Fara . 
166 => "00110000" ,--3 Cu .
37 =>  "10011001" ,--4 Fara . 
165 => "00011001" ,--4 Cu . 
46 =>  "10010010" ,--5 Fara . 
174 => "00010010" ,--5 Cu .
54 =>  "10000010" ,--6 Fara .
182 => "00000010" ,--6 Cu . 
61 =>  "11111000" ,--7 Fara . 
189 => "01111000" ,--7 Cu .
62 =>  "10000000" ,--8 Fara . 
190 => "00000000" ,--8 Cu . 
70 =>  "10010000" ,--9 Fara . 
198 => "00010000" ,--9 Cu . 

-- Functii speciale

102 => "11111111", -- BACKSPACE
90 =>  "11111111" ,--ENTER

others => "10000110");
		
	process(CLK,ADR0,ADR1,ADR2,ADR3)
	begin 
		  
		if rising_edge( CLK ) then 
			    aux0<=ADR0;
				aux1<=ADR1;
				aux2<=ADR2;
				aux3<=ADR3;
	

				catod0 <= MMAP (conv_integer(aux0))(7 downto 0); 
				catod1 <= MMAP (conv_integer(aux1))(7 downto 0);
				catod2 <= MMAP (conv_integer(aux2))(7 downto 0);
				catod3 <= MMAP (conv_integer(aux3))(7 downto 0);
			end if;
		end 
	process;
end arh_bcd;