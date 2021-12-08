
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity conv2 is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           input : in  STD_LOGIC; --datos de la ppdu
           inOK : in  STD_LOGIC; -- señal que nos indica que la ppdu tiene el dato preparado
			  inFin : in  STD_LOGIC; -- indicacion de que ya nos han enviado todos los datos
           fInOkScr : in  STD_LOGIC; -- Señal para avisar al convolucionador que el scrambler ya ha cogido el dato proporcionado
           out1 : out  STD_LOGIC; --salida 1 del convolucionador
           out2 : out  STD_LOGIC; --salida 2 del convolucionador
           outOK : out  STD_LOGIC; -- señal que indica que tenemos los bits preparados para su envio.
			  outFin: out std_logic; -- se ha terminado la trama-datos
           fInOk : out  STD_LOGIC); -- señal para indicar a la ppdu que hemos cogido su dato.
end conv2;

architecture Behavioral of conv2 is

type estados is (redundancia, relleno); --estados principales del sistema 
type subestados is (esperaIn, esperaOut);
--subestados donde llevamos a cabo 
--los procesos de lectura y escritura en ambos procesos principales.

signal estado 		: estados;
signal pestado 	: estados;
signal subestado	: subestados;
signal psubestado	: subestados;
signal reg			: std_logic_vector (6 downto 0); --registros del sistema y proximos registros
signal preg			: std_logic_vector (6 downto 0);
signal cont			: unsigned (2 downto 0);
signal pcont		: unsigned (2 downto 0);


begin

sinc: process(clk, reset)
 --Proceso sincrono con el reset asincrono y el reinicio global.
begin
	if reset = '1' then
		-- cuando pulsamos el reset del sistema, incorporamos los valores por defecto
		-- estado inicial con su correspondiente subestado.
		estado <= redundancia;
		subestado <= esperaIn;
		-- registros a 0.
		reg <= (others =>'0');
		-- contador inicialmente nulo.
		cont <= (others =>'0');
	elsif rising_edge(clk) then
		-- con cada ciclo de reloj proceso de cambio.
		estado <= pestado;
		subestado <= psubestado;
		reg <= preg;
		cont <= pcont;
	end if;

end process;

comb: process(input, inOK, fInOkScr, estado, subestado, reg, inFin, cont)
begin
	pcont <= cont;
	pestado <= estado;
	psubestado <= subestado;
	out1 <= '0';
	out2 <= '0';
	outOK <= '0';
	fInOk <= '0';
	preg <= reg;
	outFin <= '0';
	case estado is
	
		when redundancia=>
			--Primer estado en el que vamos introduciendo los datos que pasa la PPDU de uno en uno.
			case subestado is
				--Division de subestados
				when esperaIn =>
					--Primero esperamos a que la PPDU nos deje preparado e dato
					if inOK = '1' then
						--Cuando recibimos dato
						--Lo introducimos en el registro mas significativo
						preg(6) <= input;
						--y desplazamos el resto de registros
						preg(5 downto 0) <= reg(6 downto 1);
						psubestado <= esperaOut;
						fInOk <= '1';
					end if;
					if inFin = '1' then
						-- Si recibimos todos los datos, pasamos a rellenar con 0.
						pcont <= (others =>'0');
						pestado <= relleno;
					end if;
				
				when esperaOut =>
					-- Una vez hecho el dezplazamiento genermos las 2 salidas
					out1 <= reg(6) xor reg(5) xor reg(3) xor reg(1) xor reg(0);
					out2 <= reg(6) xor reg(3) xor reg(2) xor reg(0);
					outOK <= '1';
					-- avisamos que tenemos las salidas preparadas
					if fInOkScr = '1' then
						-- cuando coge ambos valores el scrambler volvemos a esperar dato.
						psubestado <= esperaIn;
					end if;
			end case;
		when relleno =>
			-- ponemos a rellenar los registros con ceros.
			case subestado is
			
				when esperaIn =>
						-- el proceso es el mismo que el anterior, pero en este caso vamos rellenando un contador
						pcont <= cont +1;
						preg(6) <= '0';
						preg(5 downto 0) <= reg(6 downto 1);
						psubestado <= esperaOut;
						if cont = "110" then
							--Tenemos que rellenar con 6 ceros
							outFin <= '1';
							pcont <= cont;
							pestado <= relleno;
							psubestado <= esperaIn;
						end if;
				
				when esperaOut =>
					--exactamente igual que el anterior
					out1 <= reg(6) xor reg(5) xor reg(3) xor reg(1) xor reg(0);
					out2 <= reg(6) xor reg(3) xor reg(2) xor reg(0);
					outOK <= '1';
					if fInOkScr = '1' then
						psubestado <= esperaIn;
					end if;
			end case;
	end case;
end process;

end Behavioral;

