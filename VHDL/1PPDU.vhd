
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity PPDU is
	Generic (
		
		ancho_bus_direcciones : integer :=  7 
		-----------------------
	);
	Port (  clk								: in  STD_LOGIC;
           reset							: in  STD_LOGIC;
			  entrada_ON					: in  STD_LOGIC;	--boton de inicio del sistema
			  cons							: in  STD_LOGIC_VECTOR(2 downto 0); --constelacion del sistma para saber si NBPC es 1, 2 o 3.
           convolucionador_listo		: in  STD_LOGIC; 	-- Señal para avisar a la PPDU que el convolucionador ya ha cogido el dato proporcionado
           datos							: out  STD_LOGIC;	-- bit de salida que vamos pasando al convolucionador.
           datos_OK						: out  STD_LOGIC; 	-- señal que indica que tenemos el bit preparado para su envio.
           datos_fin						: out  STD_LOGIC	-- se ha terminado la trama-datos
	); 	
end PPDU;

architecture Behavioral of PPDU is
	
	COMPONENT memoryCard 											-- bloque predefinido a la hora de meter la memoria
	PORT (
		  clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;
	
	type estado is (reposo, PulsadoSoltarBoton, EsperandoAlConvolucionador, PuedoMandarteDato, relleno, DatosHaAcabado);
	signal estado_actual : estado;
	signal estado_nuevo: estado;
	
	signal direcciones, p_direcciones: unsigned (ancho_bus_direcciones-1 downto 0);-- señal que usamos para ir recorriendo las direcciones de la memoria.
	signal cambio : STD_LOGIC_VECTOR(ancho_bus_direcciones-1 DOWNTO 0);-- señal que conecta con la memoria de datos y nos indica las direcciones.
	signal dato : STD_LOGIC_VECTOR(7 DOWNTO 0);-- dato proporcionado por la memoria.
	signal i, p_i : integer:=0;-- componente que usamos como contador para recorrer los bits de la direccion de memoria
	signal nCeros : unsigned(6 downto 0);-- Dependiendo de la constelacion, rellenamos el sistema con 0´s sobrantes.
	signal cont : unsigned (6 downto 0);-- variable contador.
	signal pcont : unsigned (6 downto 0);
	signal datoSeguro: STD_LOGIC_VECTOR(7 DOWNTO 0); -- Variable que guarda la salida anterior de la memoria para evitar desfases
	signal pdatoSeguro: STD_LOGIC_VECTOR(7 DOWNTO 0);
	
begin
	-- con esta conversion relacionamos el contador
	--  para recorrer las direcciones de la memoria.
	cambio <= std_logic_vector(direcciones);
	mem : memoryCard
	PORT MAP (
		   clka		=>	clk,
		   addra	=>	cambio , -- addra es el numero de filas de la memoria
		   douta	=>	dato
	);
	comCons: process(cons)
	begin
		-- determinamos el número de ceros a añadir para completar los símbolos
		-- en función de la constelación empleada.
			if cons = "001" then
				-- NBPC = 3
				nCeros <= "0010001";
				
			elsif cons = "010" then
				--NBPC = 2
				nCeros <= "1000001";
				
			else
				--NBPC = 1
				nCeros <= "0010001";
				
			end if;
	end process;
	
	comb: process (estado_actual, entrada_ON, convolucionador_listo, dato, direcciones, i, cont, nCeros, datoSeguro)
	--Proceso combinacional donde se ejecutan las variables de cambio
	--	de estado y los distintos procesos que cada uno conlleva.
	begin
		datos 		  <= '0';
		datos_OK 	  <= '0';
		datos_fin 	  <= '0';
		p_direcciones <= (others=>'0');
		p_i<= i;
		pdatoSeguro <= datoSeguro;
		pcont <= nCeros;
		estado_nuevo<=estado_actual;
		case estado_actual is
			when reposo 	=>
			--Empezamos inicialmente en reposo y nos mantenemos en este
			-- estado esperando a que se pulse el boton de inicio.
				datos 		  <= '0';
				datos_OK 	  <= '0';
				datos_fin 	  <= '0';
				p_direcciones <= (others=>'0');
				pdatoSeguro <= dato;
				-- Guardamos el vector en un registro para tener
				-- en todo momento el dato preparado.
				if (entrada_ON='1') then
				 --cuando pulsamos cambiamos de estado,
				 -- y esperamos que suelte el boton.
					p_direcciones <= "0000001";
					estado_nuevo<=PulsadoSoltarBoton;
				else
					estado_nuevo<=reposo;
				end if;
			
			when PulsadoSoltarBoton	=>
				datos 		  <= '0';
				datos_OK 	  <= '0';
				datos_fin 	  <= '0';
				p_direcciones <= "0000001";
				if (entrada_ON='0') then
					estado_nuevo<=EsperandoAlConvolucionador;
				else
					estado_nuevo<=PulsadoSoltarBoton;
				end if;
				
			when EsperandoAlConvolucionador	=>
			-- Cuando soltamos el boton nos aseguramos que hay dato, y que no este vacio.
				if (datoSeguro /= "00000000") then
					datos		  <= datoSeguro(i);
					datos_OK      <= '1';
					--Indicamos que tenemos el dato preparado para el envio.
					datos_fin	  <= '0';
					p_direcciones <= direcciones;			
					if (convolucionador_listo = '0') then
					--Mientras el convolucionador no haya cogido el dato previo,
					-- no confirma que pueda coger el siguiente.
						estado_nuevo <= EsperandoAlConvolucionador;
					else
						estado_nuevo <= PuedoMandarteDato;
					end if;
				else
					p_direcciones<=(others=>'0');
					estado_nuevo<=relleno;
				end if;
				
			when PuedoMandarteDato =>
			-- En este estado incrementamos el contador del bit para recoger el bit del dato.
				datos 		  <= datoSeguro(i);
				datos_OK 	  <= '0';
				datos_fin	  <= '0';
				p_direcciones <= direcciones;
				p_i <= i+1;
				if (i = 7) then
					--Si hemos cogido el ultimo bit del vector, pues pasamos al siguiente caracter 
					p_i<= 0;
					--de nuevo desde el bit menos significativo
					pdatoSeguro <= dato;
					p_direcciones<= direcciones + 1;				
				end if;
				estado_nuevo<=EsperandoAlConvolucionador;
				
			when relleno =>
				--Hemos terminado de mandar los datos, así que lo rellenamos todos con 0
				datos 		  <= '0';
				datos_OK 	  <= '1';
				datos_fin	  <= '0';
				p_direcciones <= direcciones;
				if (convolucionador_listo = '0') then
					pcont <= cont;
				else
					--cuando terminemos de rellenar los 0, damos por finalizado.
					pcont <= cont-1;
					if cont = 0 then
						estado_nuevo <= DatosHaAcabado;
					end if;
				end if;
								
			when DatosHaAcabado 	=>
				--Cuando todo acabe mandamos una señal de que todo ha acabado
				datos		  <= '0';
				datos_OK      <= '0';
				datos_fin	  <= '1';
				p_direcciones <= (others=>'0');
				
				if (convolucionador_listo = '1') then
					--Cuando el convolucionador avisa que ha recibido el aviso,la PPDU vuelve a reposo
					estado_nuevo <= reposo;
				else
					estado_nuevo <= DatosHaAcabado;
				end if;
			end case;
	end process;
	

	
	sinc: process (reset, clk)
	begin
		if (reset='1') then
			estado_actual <= reposo;
			direcciones   <= (others=> '0');
			i <= 0;
			datoSeguro <= (others => '0');
			
		elsif (rising_edge(clk)) then
			estado_actual <= estado_nuevo;
			direcciones   <= p_direcciones;
			i <= p_i;
			cont <= pcont;
			datoSeguro <= pdatoSeguro;
		end if;
	end process;

end Behavioral;

