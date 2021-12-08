
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift is
    Port ( 	reIn : in  STD_LOGIC_VECTOR (15 downto 0);
				imIn : in  STD_LOGIC_VECTOR (15 downto 0);
				paridad : in  STD_LOGIC;
				reOut : out  STD_LOGIC_VECTOR (15 downto 0);
				imOut : out  STD_LOGIC_VECTOR (15 downto 0));
end shift;

architecture Behavioral of shift is

-- Señales que contendran las entradas invertidas.
signal reInInv : unsigned (15 downto 0);
signal imInInv : unsigned (15 downto 0);

begin

comb: process (reIn, paridad, reInInv, imIn, imInInv)
begin
	
	reInInv(0) <= not reIn(0);
	reInInv(1) <= not reIn(1);
	reInInv(2) <= not reIn(2);
	reInInv(3) <= not reIn(3);
	reInInv(4) <= not reIn(4);
	reInInv(5) <= not reIn(5);
	reInInv(6) <= not reIn(6);
	reInInv(7) <= not reIn(7);
	reInInv(8) <= not reIn(8);
	reInInv(9) <= not reIn(9);
	reInInv(10) <= not reIn(10);
	reInInv(11) <= not reIn(11);
	reInInv(12) <= not reIn(12);
	reInInv(13) <= not reIn(13);
	reInInv(14) <= not reIn(14);
	reInInv(15) <= not reIn(15);
	
	imInInv(0) <= not imIn(0);
	imInInv(1) <= not imIn(1);
	imInInv(2) <= not imIn(2);
	imInInv(3) <= not imIn(3);
	imInInv(4) <= not imIn(4);
	imInInv(5) <= not imIn(5);
	imInInv(6) <= not imIn(6);
	imInInv(7) <= not imIn(7);
	imInInv(8) <= not imIn(8);
	imInInv(9) <= not imIn(9);
	imInInv(10) <= not imIn(10);
	imInInv(11) <= not imIn(11);
	imInInv(12) <= not imIn(12);
	imInInv(13) <= not imIn(13);
	imInInv(14) <= not imIn(14);
	imInInv(15) <= not imIn(15);
	
	if paridad = '1' then
		-- Si la muestra e cuestión es actual, por la
		-- salida ponemos el complemento A2 (le cambiamos el signo):
		
		reOut <= STD_LOGIC_VECTOR (reInInv + 1);
		imOut <= STD_LOGIC_VECTOR (imInInv + 1);
		
	else
		-- Sin la muestra es par, no habrá que cambiarle el signo.
		-- tener en cuenta que la 1a muestra es par (0).
		reOut <= reIn;
		imOut <= imIn;
		
	end if;
		
	

end process;


end Behavioral;

