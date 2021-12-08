
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity scrambler2 is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           in1 : in  STD_LOGIC; --entrada de la primera salida del convolucionador
           in2 : in  STD_LOGIC; --entrada de la segunda salida del convolucionador
           inOK : in  STD_LOGIC; -- señal que nos indica que el convolucionador tiene el dato preparado
           inFin : in  STD_LOGIC; -- indicacion de que ya nos han enviado todos los datos
           fInOkInt : in  STD_LOGIC; -- Señal para avisar al scrambler que el interleaver ya ha cogido el dato proporcionado
           output : out  STD_LOGIC; --salida del scrambler
           outOk : out  STD_LOGIC; -- señal que indica que tenemos el bit preparado para su envio.
           fInOk : out  STD_LOGIC); -- señal usada para indicar al convolucionador que hemos cogido su dato.
end scrambler2;

architecture Behavioral of scrambler2 is

type estados is (esperaIn, out1, out2);

signal estado, pestado : estados;
signal reg1, reg2, preg1, preg2 : std_logic; --registros donde guardaremos el valor de las entradas.
signal registro, pregistro : std_logic_vector(6 downto 0); -- registro que usaremos para barajar los datos.

begin
sinc: process(reset, clk)
begin
	if reset = '1' then
		-- en este caso al reiniciar el sistema los registros los reiniciamos a 1.
		registro <= (others => '1');
		reg1 <= '0';
		reg2 <= '0';
		estado <= esperaIn;
	elsif rising_edge(clk) then
		registro <= pregistro;
		reg1 <= preg1;
		reg2 <= preg2;
		estado <= pestado;
	end if;
end process;

comb: process (estado, in1, in2, inOK, inFin, fINOkInt, reg1, reg2, registro)
begin
	output <= '0';
	outOK <= '0';
	fInOk <= '0';
	pestado <= estado;
	preg1 <= reg1;
	preg2 <= reg2;
	pregistro <= registro;
		case estado is
			when esperaIn =>
				 --estado inicial en el que esperamos a recibir los datos
				if inOk = '1' then
				fInOk <= '1';
					-- cuando los recibimos avisamos al convolucionador que puede preprarar los siguientes
					pestado <= out1;
					-- cargamos los valores recibidos.
					preg1 <= in1;
					preg2 <= in2;
				end if;
			when out1 =>
			--Haremos la primera multiplicacion con la primera entrada.
			output <= reg1 xor registro(6) xor registro(3);
			--E indicamos que lo tenemos preparado y esperamos
			outOK <= '1';
			if fInOkInt = '1' then
				--Cuando el interleaver lo coge, hacemos unas preparaciones y cambiamos de estado
				outOK <= '0';
				-- Paramos de enviar
				pestado <= out2;
				-- Hacemos un desplazamiento de los datos del registro de barajar
				pregistro(6 downto 1) <= registro (5 downto 0);
				-- y el nuevo dato es la combinacion de dos registros
				pregistro(0) <= registro(3) xor registro(6);
			end if;
			
			when out2 =>
			-- en este nuevo estado hacemos o mismo con la segunda entrada.
			output <= reg2 xor registro(6) xor registro(3);
			outOK <= '1';
			if fInOkInt = '1' then
				-- en este caso volveriamos a esperar a que el 
				-- convolucionador nos proporcione los siguientes 2 valores
				outOK <= '0';
				pestado <= esperaIn;
				pregistro(6 downto 1) <= registro (5 downto 0);
				pregistro(0) <= registro(3) xor registro(6);
			end if;
	end case;
end process;

end Behavioral;

