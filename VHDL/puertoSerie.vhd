
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity puertoSerie is
    Port ( 
			  -- Salida de la memoria que usa el puerto serie.
			  DOUT : in  STD_LOGIC_VECTOR (31 downto 0);
			  
			  -- Entradas por defecto:
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  
			  -- Señales que marcan el comienzo de la descarga
			  -- de datos desde la ifft.
			  unload : in  STD_LOGIC;
			  DV : in  STD_LOGIC;
			  
			  -- Salida del puerto serie.
           output : out  STD_LOGIC;
			  
			  -- Señal que indica al mapper que el puerto serie está en reposo.
			  finMapp : out  STD_LOGIC;
			  
			  -- Entrada de las muestras desde la ifft.
			  rein : in STD_LOGIC_VECTOR (15 downto 0);
			  imin : in STD_LOGIC_VECTOR (15 downto 0);
			  
			  -- Señal que activa la escritura en la memoria.
           W : out  STD_LOGIC_VECTOR (0 downto 0);
			  
			  -- Señal para la gestión de las direcciones de la memoria.
           ADDR : out  STD_LOGIC_VECTOR (7 downto 0);
			  
			  -- Salida de datos desde el puerto serie a la memoria.
           DIN : out  STD_LOGIC_VECTOR (31 downto 0)
 );
end puertoSerie;

architecture Behavioral of puertoSerie is

type estados is (reposo, escribiendo, leyendo);
type estados2 is  (start, data, paridad, fin);
	
	signal estado: estados;
	signal pestado: estados;
	signal subestado: estados2;
	signal psubestado: estados2;
	signal contp: unsigned(7 downto 0);
	signal pcontp: unsigned(7 downto 0);
	-- contp guardará la posición de memoria sobre la que estamos operando
	
	signal contb: unsigned(4 downto 0);
	signal pcontb: unsigned(4 downto 0);
	-- contb guardará el numero de bit que se está enviando. 
	
	signal divfrec: unsigned(12 downto 0);
	signal pdivfrec: unsigned(12 downto 0);
	-- divfrec será el divisor de frecuencia para el puerto serie
	constant endDivfrec		: unsigned(12 downto 0):= "1010001010111"; -- valor para implementación
	--constant endDivfrec		: unsigned(12 downto 0):= "0000000000010"; -- valor para simulación
	

begin

comb: process(estado, DOUT, unload, contp, rein, imin, divfrec, subestado, contb)

begin
	-- si no lo cambiamos en el estado en el que estamos:
		-- se mantiene el estado.
		-- el contador se incrementa en 1.
		-- la dirección a la entrada de la ram es el valor del contador.
		-- la señal de escritura está desactivada.
		-- la entrada de la memoria tiene los valores a la salida de la ifft.

	output <= '1';
	pdivfrec <= (others => '0');
	pcontb <= contb;
	psubestado <= subestado;
	w <= "0";
	pestado <= estado;
	ADDR <= std_logic_vector(contp);
	pcontp <= contp+1;
	DIN <= (others => '0');
	
	DIN (31 downto 16) <= rein;
	-- Los 16 bits más significativos serán 
	-- la parte real de cada muestra
	DIN (15 downto 0) <= imin;
	-- Los 16 bits menos significaticos serán
	-- la parte imaginaria de cada muestra
	finMapp <= '0';
	
	case estado is
		when reposo => 
			-- mantenemos el contador de posición a cero 
			-- la señal de escritura estará desactivada.
			finMapp <= '1';
			pcontp <= (others => '0');
			if unload = '1' then
				pestado <= escribiendo;
				psubestado <= start;
				w <= "1";
			end if;
			
		when escribiendo =>
			-- Estado en el que la ifft estará descargando datos.
			-- Activamos la señal de escritura.
			w <= "1";
			if not(DV = '1') then
				pcontp <= (others => '0');
			end if;
			if contp = "10001011" then
				-- cuando escribimos la muestra número 140 (139)
				-- tedremos todos los datos: empezará la transmisión.
				pcontp <= (others => '0');
				pestado <= leyendo;
			end if;
			
		when leyendo =>
			pdivfrec <= divfrec+1;
			pcontp <= contp;
			-- Estado en el que leemos de la ram a la vez que pasamos
			-- los datos por el puerto serie.
			case subestado is
				when start =>
				--Bit de inicio de cada trama
					output <= '0';
					if divfrec = endDivfrec then
						psubestado <= data;
						pdivFrec <= (others => '0');
					end if;
				
				when data =>
			-- En este esubestado se envían los bits que contienen datos	
			
					output <= DOUT(to_integer(contb));
					if divfrec = endDivfrec then
						
						-- si es el último bit del octeto se pasa al estado paridad
						-- por cada palabra en memoria habrá 32 bits, 16 de la parte real (primero) y 
						-- 16 de la parte imaginaria (últimos), por tanto, 4 tandas de 8 bits.
						-- En definitiva: se recorrerán todos los estados 4 veces por 4 muestras, o lo que
						-- es lo mismo: enviaremos cuatro tramas por cada muestra de la IFFT.
						if contb = "00111" then
							-- Fin de la 1a trama de cada muestra.
							psubestado <= paridad;
							pcontb <= contb + 1;
						elsif contb = "01111" then
							-- Fin de la 2a trama de cada muestra
							psubestado <= paridad;
							pcontb <= contb + 1;
						elsif contb = "10111" then
							-- Fin de la 3a trama de cada muestra
							psubestado <= paridad;
							pcontb <= contb + 1;
						elsif contb = "11111" then
							-- Fin de la 4a y última trama de cada muestra.
							psubestado <= paridad;
							pcontb <= contb;
						else
							pcontb <= contb + 1;
						end if;
						pdivFrec <= (others => '0');
					end if;
					
				when paridad =>
					-- se envía el bit de paridad del octeto en cuestión
					output <= DOUT(to_integer(contb)-1) xor DOUT(to_integer(contb)-2) xor DOUT(to_integer(contb)-3)xor DOUT(to_integer(contb)-4) xor DOUT(to_integer(contb)-5) xor DOUT(to_integer(contb)-6) xor DOUT(to_integer(contb)-7) xor DOUT(to_integer(contb)-8);
					if divfrec = endDivfrec then	
						if contb = "11111" then
							pcontb <= (others => '0');
							-- si se han envíado todos los bits de una palabra (ha desbordado contb)
							-- se accede a la siguiente palabra de memoria
							pcontp <= contp + 1;
						end if;
						psubestado <= fin;
						pdivfrec <= (others => '0');
					end if;
				
				when fin =>
					-- se envia el bit de fin de trama (octeto)
					output <= '1';
					if divFrec = endDivfrec then
					-- Se vuelve al subestado de inicio para enviar un nuevo octeto.
						pdivfrec <= (others => '0');
						psubestado <= start;
						if contp = "10001100" then
						-- cuando se ha vaciado la memoria completa, se vuelve al estado de reposo
							pestado <= reposo;
						end if;
					end if;
					
			end case;
	end case;
end process;
			
				

sinc: process(clk, reset)
		-- Proceso síncrono: actualizamos el valor de todos los
		-- estados y contadores cada ciclo de reloj.
begin
	if reset = '1' then
		contp <= (others => '0');
		estado <= reposo;
		divfrec <= (others => '0');
		subestado <= start;
		contb <= (others => '0');
	elsif rising_edge(clk) then
		contp <= pcontp;
		estado <= pestado;
		divfrec <= pdivfrec;
		subestado <= psubestado;
		contb <= pcontb;
	end if;

end process;


end Behavioral;

