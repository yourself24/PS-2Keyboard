library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2_controller is
port(
CLK : in std_logic;
ps2_data : in std_logic;
ps2_clk : in std_logic;
catod0 : out std_logic_vector(7 downto 0);
error: out std_logic;
catod1: out std_logic_vector(7 downto 0);
catod2 : out std_logic_vector(7 downto 0);
catod3 : out std_logic_vector(7 downto 0)
);
end ps2_controller;

architecture arhitectura_controller of ps2_controller is

component INPUT IS
  GENERIC(
    clk_freq              : NATURAL := 100_000_000; 
    debounce_counter_size : NATURAL := 9);        
  PORT(
    CLK          : IN  STD_LOGIC;                     
    ps2_clk      : IN  STD_LOGIC;                     
    ps2_data     : IN  STD_LOGIC;                     
    EnableCode   : 	OUT STD_LOGIC;
	error: OUT STD_LOGIC;
    ps2_code     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); 
END component;

component BCD_7segments is
port(
ADR0: in std_logic_vector(7 downto 0);
ADR1: in std_logic_vector(7 downto 0);
ADR2: in std_logic_vector(7 downto 0);
ADR3: in std_logic_vector(7 downto 0);
CLK : in std_logic;
catod0: out std_logic_vector(0 to 7);
catod1: out std_logic_vector(0 to 7);
catod2: out std_logic_vector(0 to 7);
catod3: out std_logic_vector(0 to 7)
);
end component;

component decizii_date is
	port(
		Code:in std_logic_vector(7 downto 0);
		EnableCode:in std_logic;
		OData0 : out std_logic_vector(7 downto 0);
		OData1 : out std_logic_vector(7 downto 0);
		OData2 : out std_logic_vector(7 downto 0);
		OData3 : out std_logic_vector(7 downto 0)
	);
end component;

signal Data0 : std_logic_vector(7 downto 0);
signal Data1 : std_logic_vector(7 downto 0);
signal Data2 : std_logic_vector(7 downto 0);
signal Data3 : std_logic_vector(7 downto 0);

signal Code : std_logic_vector(7 downto 0);
signal EnableCode : std_logic;

begin

KEYBOARD :INPUT
generic map(clk_freq => 100_000_000,debounce_counter_size=>9)
port map(CLK,ps2_clk,ps2_data,EnableCode,error,Code);

BCD_AFISARE: BCD_7segments
port map(Data3,Data2,Data1,Data0,CLK,catod0,catod1,catod2,catod3);

DECIZII_TASTE : decizii_date port map(Code,EnableCode,Data0,Data1,Data2,Data3);
end arhitectura_controller;

