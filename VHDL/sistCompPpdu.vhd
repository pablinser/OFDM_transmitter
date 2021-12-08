----------------------------------------------------------------------------------
-- 
--			Este fichero simplemente interconecta los bloques del sistema
--			completo y la ppdu.
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity sistCompPpdu is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           cons : in  STD_LOGIC_VECTOR (2 downto 0);
           entrada : in  STD_LOGIC;
           output : out  STD_LOGIC);
end sistCompPpdu;

architecture Behavioral of sistCompPpdu is

	COMPONENT PPDU
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		entrada_ON : IN std_logic;
		cons : IN std_logic_vector(2 downto 0);
		convolucionador_listo : IN std_logic;          
		datos : OUT std_logic;
		datos_OK : OUT std_logic;
		datos_fin : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT sistemaCompletoDef
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		cons : IN std_logic_vector(2 downto 0);
		datos : IN std_logic;
		datosFin : IN std_logic;
		datosOk : IN std_logic;          
		output : OUT std_logic;
		sistListo : OUT std_logic
		);
	END COMPONENT;
	
	-- Señales
	signal datos : std_logic;
	signal datosFin : std_logic;
	signal datosOk : std_logic; 
	signal sistListo : std_logic;
	
	
begin
	sistema: sistemaCompletoDef PORT MAP(
		clk => clk,
		reset => reset,
		cons => cons,
		datos => datos,
		datosFin => datosFin,
		datosOk => datosOk,
		output => output,
		sistListo => sistListo
	);
	
	Inst_PPDU: PPDU PORT MAP(
		clk => clk,
		reset => reset,
		entrada_ON => entrada,
		cons => cons,
		convolucionador_listo => sistListo,
		datos => datos,
		datos_OK => datosOk,
		datos_fin => datosFin
	);

end Behavioral;

