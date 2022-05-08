library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decizii_date is
	port(
		Code:in std_logic_vector(7 downto 0);		--reprezentarea  tastei
		EnableCode:in std_logic;						--pt val.1 anunta ca datele sunt corecte si sunt pregatite pentru decodificare
		OData0 : out std_logic_vector(7 downto 0);	--4 vectori a cate 8 biti, fiecare avand reprezentarea in cod hexa a poz din memorie(adresa) la care se afla
		OData1 : out std_logic_vector(7 downto 0);	--reprezentarea tastelor pe BCD 7 segmente (continutul)
		OData2 : out std_logic_vector(7 downto 0);	--totodata, acesti vectori corespund anozilor de pe afisor de la dr la stg
		OData3 : out std_logic_vector(7 downto 0)
	);
end decizii_date;

architecture arh of decizii_date is
	signal Data0 : std_logic_vector(7 downto 0);  --semnale auxiliare pe care le-am utilizat in process pentru a modifica vectorii
	signal Data1 : std_logic_vector(7 downto 0);
	signal Data2 : std_logic_vector(7 downto 0);
	signal Data3 : std_logic_vector(7 downto 0);

	 
	signal tData1 : std_logic_vector(7 downto 0); 
												  
												  --codul precedent perceput de catre sistem
	signal mode : std_logic:='1';					  --mode retine daca afisorul e golit complet sau nu
	signal pos:natural:=0;						  --pos retine pozitia punctului
	signal backsp_pos: natural:=0;				  --backsp_pos retine pozitia in care ne aflam in prezent, in cazul in care backspace-ul a fost apasat 
begin
	process(EnableCode)
	begin
				
			
			if (falling_edge(EnableCode)) then --valid doar pe front descendent
				if tData1="11100000" and Code = "01110100"    then --sageata dreapta, E0 74	  
																   -- "11100000" reprez. E0 ,iar "01110100" reprez. 74	
					 case pos is
						
					when 0 => 					  --start(cazul in care punctul nu este activat)
						 Data0(7) <= '1';		  --se activeaza punctul pe AN0
						 Data1(7) <= '0';
						 Data2(7) <= '0';
						 Data3(7) <= '0';
						 pos <= 1;				   --acum pozitia curenta a punctului este pe AN0
					 when 1 =>
						 Data0(7) <= '0';		   --cand punctul se afla pe AN0 si apas pe -> se activeaza punctul pe AN3
						 Data1(7) <= '0';
						 Data2(7) <= '0';
						 Data3(7) <= '1';
						 pos <= 4;				   --acum pozitia curenta a punctului este pe AN3
					 when 2 =>
						 Data0(7) <= '1';
						 Data1(7) <= '0';
						 Data2(7) <= '0';
						 Data3(7) <= '0';
						 pos <=1;
					 when 3 =>
						 Data0(7) <= '0';
						 Data1(7) <= '1';
						 Data2(7) <= '0';
						 Data3(7) <= '0';
						 pos <=2;
					 when 4 =>
						 Data0(7) <= '0';
						 Data1(7) <= '0';
						 Data2(7) <= '1';
						 Data3(7) <= '0';
						 pos<=3;
					 when others=>null;
						 end case;
				else	
				if tData1="11100000" and Code = "01101011"  then --sageata stanga, E0 6B
					case pos is
					
					
					  when 0 => --start(cazul in care punctul nu este activat)
							 Data0(7) <= '1';		  --se activeaza punctul pe anodul AN0
							 Data1(7) <= '0';
							 Data2(7) <= '0';
							 Data3(7) <= '0';
							 pos <= 1;			      
						 when 1 =>					  --daca punctul de pe AN0 este activ, se activeaza punctul de pe AN1 
							 Data0(7) <= '0';
							 Data1(7) <= '1';
							 Data2(7) <= '0';
							 Data3(7) <= '0';
							 pos <= 2;
						 when 2 =>
							 Data0(7) <= '0';
							 Data1(7) <= '0';
							 Data2(7) <= '1';
							 Data3(7) <= '0';
							 pos <=3;
						 when 3 =>
							 Data0(7) <= '0';
							 Data1(7) <= '0';
							 Data2(7) <= '0';
							 Data3(7) <= '1';
							 pos <=4;
						 when 4 =>
							 Data0(7) <= '1';
							 Data1(7) <= '0';
							 Data2(7) <= '0';
							 Data3(7) <= '0';
							 pos<=1;
						 when others=>null;
				 end case;
				 else
					if Code = "01011010" then --Enter  (golim afisorul)
								Data3<="01011010";
								Data2<="01011010";
								Data1<="01011010";
								Data0<="01011010";
								backsp_pos <= 0;
								pos<=0;
					else
						if Code = "01100110" then  	--Backspace (la apasarea tastei Bksp se goleste primul anod activ de la dr la stg )
							mode<=not mode;	   	   --Dc mode=0 => afisorul nu este golit 
												   --Dc mode=1 => altfel
									if (mode='0' and backsp_pos < 4) then --afisorul nu e golit complet si mai avem ce sa golim
										case backsp_pos is
										when 0 =>					--niciun anod nu este golit	=> il goleste pe primul de la dr la stg			
											Data0<="01100110";
										when 1 =>
											Data1<="01100110";
										when 2 =>
											Data2<="01100110";
										when 3 =>
											Data3<="01100110";
										when others => null;
										end case;
										backsp_pos <= backsp_pos+1;	  
									end if;
						else
							if (Code /= x"F0" and Code /= x"E0" and Code /= x"6B" and Code /= x"74") then  --daca tasta apasata nu e sageata stg/dr sau tasta speciala sau break code,
																										   --ci o tasta normala 
									if mode = '0' then			  --afisorul nu e gol
											case backsp_pos is		   
											when 0 =>			 	--cand toate afisoarele sunt pline se shifteaza cu o poz la stg,iar noul caracter va fi afisat pe AN0
												Data3<=Data2;
												Data2<=Data1;
												Data1<=Data0;
												Data0<=Code;
											when 1 =>			 --primul afisor e liber(golit)				
											Data0<=Code;
										
											when 2 =>			 --primele 2 afisoare sunt libere(golite)
											Data1<=Code;
											
											when 3 =>			 --primele 3 afisoare sunt libere(golite)
											Data2<=Code;
										
											when 4 =>			 --toate afisoarele au fost golite ,in acest caz se completeaza de la stg la dr afisorul
											Data3<=Code;
											
											when others => null;
											end case;
								
											
										if (backsp_pos > 0) then
											backsp_pos <= backsp_pos-1;	   --acum se umple de la stg la dr afisorul
										end if;
												
									end if;	
									mode <= mode xor '1';
								end if;
						end if;
						end if;
					end if;
					end if;
				end if;
				tData1 <= Code;
			
	end
	process;
	
	process (Data0,Data1,Data2,Data3)
	begin
			OData0 <= Data0;
			OData1 <= Data1;
			OData2 <= Data2;
			OData3 <= Data3;
	end
	process;
	
end arh;

