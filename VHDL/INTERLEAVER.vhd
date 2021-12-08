
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity INTERLEAVER is
    Port ( 
		-- Declaramos las entradas y salidas del componente:
				-- Entradas generales:
				clk			: in	STD_LOGIC;
				reset			: in	STD_LOGIC;
				cons			: in	STD_LOGIC_VECTOR (2 downto 0);
				
				-- Entrada de datos desde el scrambler:
				input			: in	STD_LOGIC;
				
				-- Señal de confirmación del dato a la entrada:
				inOK			: in	STD_LOGIC;
				
				-- Señal de fin de envío de datos por el puerto
				-- serie, para cargar un nuevo símbolo:
				finSerie 	: in  STD_LOGIC;
				
				-- Salidas para la gestión de la memoria
				W				: out STD_LOGIC_VECTOR(0 DOWNTO 0);
				DIN			: out std_logic_vector(31 downto 0);
				ADDR			: out std_logic_vector(7 downto 0);
				
				-- Entrada desde la memoria:
				DOUT			: in std_logic_vector(31 downto 0);
				
				-- Salida  hacia el mapper. Cada ciclo pasa los 
				-- bits correspondientes a una portadora.
				-- Cuando se empleen las constelaciones de menos 
				-- bits por simbolo, los bits más significativos
				-- estarán a cero.
				output		: out	STD_LOGIC_VECTOR(2 downto 0);
				
				-- Señal que se pone a 1 cuando hay un dato 
				-- correcto a la salida
				outOK			: out	STD_LOGIC;
				
				-- Señal que confirma al scrambler que se ha tomado
				-- el dato a la entrada del ciclo anterior.
				fInOK			: out	STD_LOGIC;
				
				-- Señal que se activa cuando el mapper reclama al 
				-- interliver que le entregue los bits de un símbolo
				-- completo de corrido, llenando un punto de la ifft
				-- cada ciclo.
				mapOK			: in	STD_LOGIC);
				
end INTERLEAVER;

architecture Behavioral of INTERLEAVER is
				
				-- El estado "transición" es de paso, ni siquiera aparece
				-- en el diagrama de bolas (ver más abajo en el código).
				-- El estado "recibiendo" es cuando se reciben los bits de
				-- un símbolo completo del scrambler.
				-- El estado "pasando" se corresponde con el tiempo de 
				-- entregar los bits ya barajados al mapper.
				type estados is (recibiendo, pasando, transicion);
				
				type subEstados is (reposo, leer, escribir);
				-- los subestados se emplean dentro de estado "recibiendo" para
				-- manejar los accesos a la memoria, escribiendo por columnas.
				-- Al pasar los datos al mapper se usan solo los contadores, 
				-- declarados más adelante.
				
				-- Declaración de las señales de estado y subestado:
				signal estado		: estados;
				signal pEstado		: estados;
				signal subEstado	: subestados;
				signal pSubEstado	: subestados;
				
				-- como la memoria es más grande de lo que necesitamos y el 
				-- tamaño de la "matriz" que empleamos para el interleaver 
				-- varía en función de la constelación, guardamos la máxima 
				-- columna y fila a escribir/leer. 
				signal endContC	: unsigned(4 downto 0);
				signal endContF	: unsigned(3 downto 0);
				
				--contF cuenta en que fila estamos escribiendo/leyendo
				signal contF		: unsigned(3 downto 0);
				signal pContF		: unsigned(3 downto 0);
				
				--contC cuenta en que columna(s) estamos escribiendo/leyendo
				signal contC		: unsigned(4 downto 0);
				signal pContC		: unsigned(4 downto 0);
				
				-- Señal que contiene el número de bits que se pasan al mapper
				-- en cada ciclo.
				signal nBitsOut	: unsigned(1 downto 0);
				
	begin
		constelacion: process(cons)
			-- Proceso síncrono que establece endConF, endContC y 
			-- nBitsOut en función de la constelación empleada.
			-- NBPC es el número de bits por portadora.
		begin
			if cons = "001" then
				-- NBPC = 3
				endContF <= "1111";
				endContC <= "10001";
				nBitsOut <= "11";
				
			elsif cons = "010" then
				--NBPC = 2
				endContF <= "1111";
				endContC <= "01011";
				nBitsOut <= "10";
				
			else
				--NBPC = 1
				endContF <= "0111";
				endContC <= "01011";
				nBitsOut <= "01";
				
			end if;
		end process;
			
			

				
		sinc: process (clk, reset) 
		-- Proceso síncrono de actualización de estados y contadores.
		-- Implementa también el reset asíncrono.
		begin 
			if reset = '1' then
				estado		<= recibiendo;
				subEstado 	<= reposo;
				contC			<= (others => '0');
				contF			<= (others => '0');
			elsif rising_edge(clk) then
				estado		<= pEstado;
				subEstado 	<= pSubEstado;
				contC			<= pContC;
				contF			<= pContF;
			end if;
		end process;
		
		comb: process (estado, subEstado, contC, contF, endContC, endContF, input, inOK, mapOK, DOUT, nBitsOut,finSerie)
		-- Proceso combinacional del bloque.
		begin
			-- asignación estandar de valores para evitar latches.
			pEstado <= estado;
			pSubEstado <= subEstado;
			pContC <= contC;
			pContF <= contF;
			W <= "0";
			DIN <= (others => '0');
			ADDR <= (others => '0');
			ADDR (3 downto 0) <= std_logic_vector(contF);
			output <= (others => '0');
			outOK <= '0';
			fInOK <= '0';
			
			case estado is
		
				when recibiendo =>
				-- recibiendo datos del scrambler.
					case subEstado is
					
						when reposo =>
							-- Esperando la confirmación del primer dato del símbolo.
							-- Al ser el comienzo de simbolo se asignan nuevos valores 
							-- a contC y contF.
							pcontC <= endContC;
							pcontF <= (others =>'0');
							if inOK = '1' and finSerie = '1' then
								-- Cuando se confirme el primer dato y estén libres
								-- el mapper y el puerto serie se comienza la carga de
								-- bits al interliver.
								pSubEstado <= escribir;
							end if;
						
						when escribir =>
							-- Ciclo en el que se escribe en memoria (W=1).
							if inOK = '1' then
								
								W <= "1";
								
								-- Escribimos lo mismo que hay en la celda, cambiando
								-- el bit de la columna que toca escribir.
								DIN <= DOUT;
								DIN(to_integer(contC)) <= input;
								pSubEstado <= leer;
								
								-- Al escribir por columnas, incrementamos la fila
								-- que escribimos.
								pContF <= contF + 1;
								
								if contF = endContF then
									-- Al terminar de escribir una columna, incrementamos
									-- conC para escribir la siguiente.
									pContF <= (others => '0');
									pContC <= contC - 1;
								
									if contC = 0 then
										-- Caso en el que hemos completado la escritura.
										-- Cambiamos al estado de pasar datos al mapper.
										pcontC <= endContC;
										pEstado <= transicion;
										pSubEstado <= reposo;
									end if;
								end if;
							end if;
							
						when leer =>
							-- Ciclo en el que leemos lo que hay en la celda que vamos
							-- a sobreescribir, para no perder los datos anteriores.
							-- Además confirmamos al Scrambler que hemos tomado el dato del 
							-- ciclo anterior.
							fInOK <= '1';
							pSubEstado <= escribir;
							
					end case;
					
					when pasando =>
					
						outOK <= '1';
						-- Escribimos los bits que corresponden en función de la 
						-- constelación empleada
						if nBitsOut = "01" then
							output(0) <= DOUT(to_integer(contC));
						elsif nBitsOut = "10" then
							output(0) <= DOUT(to_integer(contC-1));
							output(1) <= DOUT(to_integer(contC));
						elsif nBitsOut = "11" then
							output(0) <= DOUT(to_integer(contC-2));
							output(1) <= DOUT(to_integer(contC-1));
							output(2) <= DOUT(to_integer(contC));
						end if;
						
						
						if mapOK = '1' then
						
							-- La señal mapOK se ponea 1 cuando el mapper entra
							-- en el estado "datos". Mientras esté a 1, enviamos 
							-- nBitsOut bits por ciclo al mapper (ver arriba).
							pContC <= contC-nBitsOut;
							
							if contC = (nBitsOut -1) then
							
								-- Cuando terminamos de enviar una fila, pasamos 
								-- a la siguiente
								pContC <= endContC;
								
								-- cambiamos la dirección que le damos a la memoria
								-- sin esperar al cambio de ciclo, para que esté
								-- disponible al siguiente ciclo la nueva fila.
								ADDR (3 downto 0) <= std_logic_vector(contF + 1);
								pContF <= contF + 1;
								
								if contF = endContF then
									-- Cuando terminamos de pasar la última fila, 
									-- volvemos al estado inicial.
									pEstado <= recibiendo;
									pContC <= endContC;
									pContF <=(others => '0');
									
								end if;
							end if;
						end if;
						when transicion =>
							-- Como en al escribir el último bit no pasamos por el 
							-- subestado leer, confirmamos aquí al scrambler que hemos
							-- tomado el dato.
							-- En este estado se está solo durante un ciclo.
							fInOK <= '1';
							pEstado <= pasando;
						
			end case;
			
		end process;

end Behavioral;

