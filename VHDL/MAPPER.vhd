
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MAPPER is
    Port ( 	--entradas generales
				clk 	: in  STD_LOGIC;
				reset : in  STD_LOGIC;
				cons	: in	STD_LOGIC_VECTOR (2 downto 0);
				
				--entradas desde el interleaver
				inOK 	: in  STD_LOGIC;
				input : in  STD_LOGIC_VECTOR(2 DOWNTO 0);
				
				-- salida hacia el interleaver
				fInOK : out  STD_LOGIC;
				mapLib		: out	STD_LOGIC;
				
				-- entrada desde el puerto serie
				finSerie 	: in  STD_LOGIC;
				
				-- salidas hacia la ifft
				START 			: out std_logic := '0';
				UNLOAD 			: out std_logic := '0';
				FWD_INV			: out std_logic := '0';
				FWD_INV_WE 		: out std_logic := '0';
				SCALE_SCH_WE 	: out std_logic := '0';
				CP_LEN_WE 		: out std_logic := '0';
				
				iOut 				: out  std_logic_vector(15 downto 0);
				rOut 				: out  std_logic_vector(15 downto 0);
				SCALE_SCH 		: out std_logic_vector(13 downto 0):= (others => '0'); 
				CP_LEN 			: out std_logic_vector(6 downto 0):= (others => '0');
				
				-- entradas desde la ifft:
				
				--XK_RE 	: std_logic_vector(15 downto 0);
				--XK_IM 	: std_logic_vector(15 downto 0);
				
				XN_INDEX	: in std_logic_vector(6 downto 0);
				
				--XK_INDEX	: std_logic_vector(6 downto 0);
						
				RFD 	: in std_logic := '0';
				BUSY 	: in std_logic := '0';
				DV 	: in std_logic := '0';
				EDONE	: in std_logic := '0';
				DONE 	: in std_logic := '0';
				CPV 	: in std_logic := '0');
end MAPPER;

architecture Behavioral of MAPPER is

	type estados is (reposo, opciones, ceros1, datos, ceros2, espera);

	signal estado		: estados;
	signal pEstado		: estados;
	
	-- El contador contendrá el índice de la muestra que le pasamos	
	-- a la ifft. Lo emplearemos para los cambios de estado.
	signal cont			: unsigned(6 downto 0);
	signal pCont		: unsigned(6 downto 0);
	
	signal fase			: unsigned(2 downto 0);
	signal lFase		: unsigned(2 downto 0);
	
	-- constantes que se emplearán para generar las salidas hacia la ifft, con aritmética de punto fijo.
	
	constant uno		: std_logic_vector(15 downto 0):= "0111111111111111";
	constant rdos		: std_logic_vector(15 downto 0):= "0101101010000010";
	constant mUno		: std_logic_vector(15 downto 0):= "1000000000000000";
	constant mRdos		: std_logic_vector(15 downto 0):= "1010010101111110";
	
begin

comb1: process(estado, cont, inOK, input, fase, RFD, BUSY, EDONE, DONE, CPV, finSerie)
begin
	-- Asignamos las salidas y estados por defecto: 
	pEstado 		 <= estado;
	pCont			 <= cont + 1;
	iOut			 <= (others =>'0');
	rOut			 <= (others =>'0');
	fInOK			 <= '0';
	SCALE_SCH 	 <= (others =>'0'); 
	CP_LEN		 <= (others =>'0');
	START 		 <= '0';
	UNLOAD 		 <= '0';
	FWD_INV		 <= '0';
	FWD_INV_WE 	 <= '0';
	SCALE_SCH_WE <= '0';
	CP_LEN_WE 	 <= '0';
	mapLib 		 <= '0';

	
	case estado is
		when reposo =>
		-- Estado en el que permanecemos hasta que el interleaver ponga el primer
		-- dato correcto a la entrada.
			pCont <= (others => '0');
			if finSerie = '1' then
				-- La señal mapLib indica al interleaver que tanto el mapper como el 
				-- puerto serie están en reposo. Por eso solo la ponemos a 1 cuanto esta-
				-- mos en reposo y el puerto serie nos indica que también lo está, a través
				-- de la señal finSerie.
				mapLib <= '1';
			
				if inOK = '1'  then
					-- cambiamos de estado cuando el interleaver confirma el primer dato.
					pestado <= opciones;
				end if;
			end if;
			
		when opciones =>
			-- Estado de paso en el que permanecemos un ciclo e indicamos a la ifft
			-- con que opciones debe operar.
			pestado <= ceros1;
			SCALE_SCH 	 <= "01010101010010";
			CP_LEN		 <= "0001100";
			FWD_INV_WE 	 <= '1';
			SCALE_SCH_WE <= '1';
			CP_LEN_WE 	 <= '1';
			pCont 	<= (others =>'0');
		
		when ceros1 =>
			-- Estado en el que insertamos la primera ristra de ceros (16).
			if not(RFD = '1') then
				pCont 	<= (others =>'0');
			end if;
			start <= '1';
			if cont = 16 then
				-- antes de cambiar de estado, pasamos la muestra de referencia.
				iOut		<= (others =>'0');
				rOut		<= mUno;
				pEstado 	<= datos;
			end if;
			
		when datos =>
			-- Estado en el que recibimos los datos del interleaver y simultáneamente 
			-- los pasamos a la ifft.
			-- Con la señal fInOk confirmamos al interleaver que hemos comenzado a tomar
			-- datos.
			fInOK		<= '1';
			
			-- Sentencia case que convierte la fase de la portadora que toca a punto  
			-- fijo, para pasar a la ifft.
			case fase is
				when "000" =>
					rOut		<= uno;
					iOut		<= (others => '0');
				when "001" =>
					rOut		<= rdos;
					iOut		<= rdos;
				when "010" =>
					rOut		<= (others => '0');
					iOut		<= uno;
				when "011" =>
					rOut		<= mRdos;
					iOut		<= rdos;
				when "100" =>
					rOut		<= mUno;
					iOut		<= (others => '0');
				when "101" =>
					rOut		<= mRdos;
					iOut		<= mRdos;
				when "110" =>
					rOut		<= (others => '0');
					iOut		<= mUno;
				when "111" =>
					rOut		<= rdos;
					iOut		<= mRdos;
				when others =>
					rOut		<= uno;
					iOut		<= (others => '0');
			end case;
			
			if cont = 112 then
				-- última muestra con datos.
				pEstado <= ceros2;
			end if;
			
		when ceros2 =>
			-- Insetamos la segunda ristra de ceros en la ifft.
			-- Cambiamos de estado cuando ésta nos indique con
			-- la señal BUSY que ha comenzado a operar.
			if BUSY = '1' then
				pEstado <= espera;
			end if;
			
		when espera =>
			-- Estado en el que esperamos que la ifft termine de
			-- operar para descargar los resultados hacia el 
			-- puerto serie.
			if BUSY = '0' then
				UNLOAD <= '1';
				pEstado <= reposo;
			end if;
		end case;

end process;

comb2: process(cons, lFase, input, estado)
	-- Proceso que se corresponde con el circuito combinacional 
	-- que convierte los bits que recibimos del interleaver y la 
	-- última fase enviada en la nueva fase a enviar.
	begin
	
	-- Si el mapper no está enviando datos, ponemos la señal fase a
	-- 4 (corresponde con [-1, 0]) para asegurar que se toma la
	-- referencia correcta al inicio de cada símbolo.
	fase <= "100";
	if estado = datos then
			-- Se realiza la asignación en función de la constelación empleada.
			-- las asignaciones por defecto de cada case no deberían darse nunca.
			-- las ponemos para evitar latches.
			if cons = "001" then
				-- NBPC = 3
				case input is
				
					when "000" =>
						fase <= lFase;
					when "001" =>
						fase <= lFase + 1;
					when "010" =>
						fase <= lFase + 3;
					when "011" =>
						fase <= lFase + 2;
					when "100" =>
						fase <= lFase + 7;
					when "101" =>
						fase <= lFase + 6;
					when "110" =>
						fase <= lFase + 4;
					when "111" =>
						fase <= lFase + 5;
					when others =>
						fase <= lFase;
				end case;
				
			elsif cons = "010" then
				--NBPC = 2
				case input is
					when "000" =>
						fase <= lFase;
					when "001" =>
						fase <= lFase + 2;
					when "010" =>
						fase <= lFase + 6;
					when "011" =>
						fase <= lFase + 4;
					when others =>
						fase <= lFase;
				end case;
				
			else
				--NBPC = 1
				case input is
					when "000" =>
						fase <= lFase;
					when "001" =>
						fase <= lFase + 4;
					when others =>
						fase <= lFase;
				end case;
			end if;
		end if;
end process;

sinc: process(clk, reset)
	-- Proceso síncrono en el que actualizamos los valores de 
	-- los estados y contadores. También implementa el reset
	-- asíncrono del mapper.
begin
	if reset = '1' then
		cont		<= (others => '0');
		estado	<= reposo;
		lFase		<= "100";
	elsif rising_edge(clk) then
		lFase		<= fase;
		estado	<= pEstado;
		cont 		<= pCont;
	end if;

end process;

end Behavioral;

