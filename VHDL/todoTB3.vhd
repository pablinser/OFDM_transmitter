
		--Declaración de librerías
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.all;
use ieee.std_logic_textio.all;
USE ieee.numeric_std.ALL;
 
ENTITY TBcompleto IS
END TBcompleto;
 
ARCHITECTURE behavior OF TBcompleto IS 
 
    -- Declaración de todos los bloques a emplear
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
 
    COMPONENT CONV2
	PORT(
		clk : in  STD_LOGIC;
      reset : in  STD_LOGIC;
      input : in  STD_LOGIC;
      inOK : in  STD_LOGIC;
		inFin : in  STD_LOGIC;
      fInOkScr : in  STD_LOGIC;
      out1 : out  STD_LOGIC;
      out2 : out  STD_LOGIC;
      outOK : out  STD_LOGIC;
		outFin: out std_logic;
      fInOk : out  STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT INTERLEAVER
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		finSerie : in  STD_LOGIC;
		cons : IN std_logic_vector(2 downto 0);
		input : IN std_logic;
		inOK : IN std_logic;
		DOUT : IN std_logic_vector(31 downto 0);
		mapOK : IN std_logic;          
		W : OUT std_logic_vector(0 downto 0);
		DIN : OUT std_logic_vector(31 downto 0);
		ADDR : OUT std_logic_vector(7 downto 0);
		output : OUT std_logic_vector(2 downto 0);
		outOK : OUT std_logic;
		fInOK : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT MAPPER
	PORT(
	
		 mapLib: out	STD_LOGIC;
		 clk : IN std_logic;
		 reset : IN std_logic;
		 cons : IN std_logic_vector(2 downto 0);
		 inOK : IN std_logic;
		 input : IN std_logic_vector(2 downto 0);
		 XN_INDEX : IN std_logic_vector(6 downto 0);
		 RFD : IN std_logic;
		 BUSY : IN std_logic;
		 DV : IN std_logic;
		 EDONE : IN std_logic;
		 DONE : IN std_logic;
		 CPV : IN std_logic;
		 finSerie : in  STD_LOGIC;
		 fInOK : OUT std_logic;
		 START : OUT std_logic;
		 UNLOAD : OUT std_logic;
		 FWD_INV : OUT std_logic;
		 FWD_INV_WE : OUT std_logic;
		 SCALE_SCH_WE : OUT std_logic;
		 CP_LEN_WE : OUT std_logic;
		 iOut : OUT std_logic_vector(15 downto 0);
		 rOut : OUT std_logic_vector(15 downto 0);
		 SCALE_SCH : OUT std_logic_vector(13 downto 0);
		 CP_LEN : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;
	
	COMPONENT SCRAMBLER2
	PORT(
	
		 clk : in  STD_LOGIC;
       reset : in  STD_LOGIC;
       in1 : in  STD_LOGIC;
       in2 : in  STD_LOGIC;
       inOK : in  STD_LOGIC;
       inFin : in  STD_LOGIC;
       fInOkInt : in  STD_LOGIC;
       output : out  STD_LOGIC;
       outOk : out  STD_LOGIC;
       fInOk : out  STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT puertoSerie
	PORT(
		DOUT : IN std_logic_vector(31 downto 0);
		clk : IN std_logic;
		reset : IN std_logic;
		unload : IN std_logic;
		rein : IN std_logic_vector(15 downto 0);
		imin : IN std_logic_vector(15 downto 0);          
		output : OUT std_logic;
		finMapp : out  STD_LOGIC;
		W : OUT std_logic_vector(0 downto 0);
		ADDR : OUT std_logic_vector(7 downto 0);
		DIN : OUT std_logic_vector(31 downto 0);
		DV : in  STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT ifft
  PORT (
    clk : IN STD_LOGIC;
    start : IN STD_LOGIC;
    unload : IN STD_LOGIC;
    cp_len : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    cp_len_we : IN STD_LOGIC;
    xn_re : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    xn_im : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    fwd_inv : IN STD_LOGIC;
    fwd_inv_we : IN STD_LOGIC;
    scale_sch : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    scale_sch_we : IN STD_LOGIC;
    rfd : OUT STD_LOGIC;
    xn_index : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    busy : OUT STD_LOGIC;
    edone : OUT STD_LOGIC;
    done : OUT STD_LOGIC;
    dv : OUT STD_LOGIC;
    xk_index : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    cpv : OUT STD_LOGIC;
    xk_re : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    xk_im : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
	END COMPONENT;
	
	COMPONENT memInterleaver
  PORT (
    clka : IN STD_LOGIC;
    rsta : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	 clkb : IN STD_LOGIC;
    rstb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
	END COMPONENT;
	
	COMPONENT shift is
  PORT (
	 reIn : in  STD_LOGIC_VECTOR (15 downto 0);
	 imIn : in  STD_LOGIC_VECTOR (15 downto 0);
    paridad : in  STD_LOGIC;
    reOut : out  STD_LOGIC_VECTOR (15 downto 0);
	 imOut : out  STD_LOGIC_VECTOR (15 downto 0));
  END COMPONENT;
	

		-- Señales de la ifft
	
    signal start 			: STD_LOGIC;
	 signal mapLib			: STD_LOGIC;
    signal unload 		: STD_LOGIC;
    signal cp_len 		: STD_LOGIC_VECTOR(6 DOWNTO 0);
    signal cp_len_we 	: STD_LOGIC;
    signal xn_re 			: STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal xn_im 			: STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal fwd_inv 		: STD_LOGIC;
    signal fwd_inv_we	: STD_LOGIC;
    signal scale_sch 	: STD_LOGIC_VECTOR(13 DOWNTO 0);
    signal scale_sch_we : STD_LOGIC;
    signal rfd 			: STD_LOGIC;
    signal xn_index 		: STD_LOGIC_VECTOR(6 DOWNTO 0);
    signal busy 			: STD_LOGIC;
    signal edone			: STD_LOGIC;
    signal done 			: STD_LOGIC;
    signal dv 				: STD_LOGIC;
    signal xk_index 		: STD_LOGIC_VECTOR(6 DOWNTO 0);
    signal cpv 			: STD_LOGIC;
	 signal xk_rep			: STD_LOGIC_VECTOR(15 DOWNTO 0);
			-- las señales xk_rep y xk_imp van de la ifft al 
			--	bloque shift. xk_re y xk_im van del shift al 
			-- puerto serie.
    signal xk_re 			: STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal xk_imp 		: STD_LOGIC_VECTOR(15 DOWNTO 0);
	 signal xk_im 			: STD_LOGIC_VECTOR(15 DOWNTO 0);
	 
	 -- Señales de la memoria
	 
    signal wea 	: STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal addra 	: STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal dina 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal douta 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal web 	: STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal addrb 	: STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal dinb 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal doutb 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	 
	 -- Señales del mapper
	 
	 signal inOKMapp	: std_logic;
	 signal inMapp		: std_logic_vector(2 downto 0);
	 signal fInOKMapp	: std_logic;
	 signal finSerie	: std_logic;
	 
	 -- Señales del interleaver
	 
	 signal fInOKInt	: std_logic;
	 signal LinOKInt	: std_logic;
	 signal inInt		: std_logic;
	 signal inOKInt	: std_logic;
	 
	 -- Señales del scrambler
	 
	 signal in1Scra	: std_logic;
	 signal in2Scra	: std_logic;
	 signal inOKScra	: std_logic;
	 signal FinInScra	: std_logic;
	 signal fInOKScra	: std_logic;
	 
	 -- señales del sistema a ppdu o viceversa
	 
	signal datos : std_logic;
	signal datosFin : std_logic;
	signal datosOk : std_logic; 
	signal sistListo : std_logic;
	 
	 --señales de test: entradas, salida, clk y reset
	signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal cons : std_logic_vector(2 downto 0) := (others => '0');
   signal entrada : std_logic := '0';
	signal output : std_logic := '0';
	
	  -- Clock period definitions
   constant clk_period : time := 10 ns;
 
 
	--Decraracion de fiheros
	file f1 : text open write_mode is "ficheroSalidaScram.txt";
	file f2 : text open write_mode is "ficheroSalidaInter.txt";
	file f3 : text open write_mode is "ficheroSalidaImmap.txt";
	file f4 : text open write_mode is "ficheroSalidaRemap.txt";
	file f5 : text open write_mode is "ficheroSalidaReSis.txt";
	file f6 : text open write_mode is "ficheroSalidaImSis.txt";
	 

begin
--	 Instanciamos todos los bloques

	Inst_PPDU: PPDU 
	PORT MAP(
	
		clk => clk,
		reset => reset,
		entrada_ON => entrada,
		cons => cons,
		convolucionador_listo => sistListo,
		datos => datos,
		datos_OK => datosOk,
		datos_fin => datosFin
	);

	

	conv: CONV2 
	PORT MAP(

      input => datos,
      inOK => datosOk,
		inFin => datosFin,
      fInOkScr => fInOKScra,
      out1 => in1Scra,
      out2 => in2Scra,
      outOK => inOKScra,
		outFin => FinInScra, 
      fInOk => sistListo,
		clk => clk,
		reset => reset
	);
	
	inte: INTERLEAVER 
	PORT MAP(
	
		finSerie => maplib,
		clk => clk,
		reset => reset,
		cons => cons,
		input => inInt,
		inOK => inOKInt,
		W => wea,
		DIN => dina,
		ADDR => addra,
		DOUT => douta,
		output => inMapp,
		outOK => inOKMapp,
		fInOK => fInOKInt,
		mapOK => fInOKMapp 
	);
	
	mapp: MAPPER 
	PORT MAP(
	
		mapLib => mapLib,
		finSerie => finSerie,
		clk => clk,
		reset => reset,
		cons => cons,
		inOK => inOKMapp,
		input => inMapp,
		fInOK => fInOKMapp,
		START => start,
		UNLOAD => UNLOAD,
		FWD_INV => FWD_INV,
		FWD_INV_WE => FWD_INV_WE,
		SCALE_SCH_WE => SCALE_SCH_WE,
		CP_LEN_WE => CP_LEN_WE,
		iOut => xn_im,
		rOut => xn_re,
		SCALE_SCH => SCALE_SCH,
		CP_LEN => CP_LEN,
		XN_INDEX => XN_INDEX,
		RFD => RFD,
		BUSY => BUSY,
		DV => DV,
		EDONE => EDONE,
		DONE => DONE,
		CPV => CPV 
	);
	
	scra: SCRAMBLER2 
	PORT MAP(
			  
      in1 => in1Scra,
      in2 => in2Scra,
      inOK => inOKScra,
      inFin => FinInScra,
      fInOkInt => fInOKInt,
      output => inInt,
      outOk => inOKInt,
      fInOk => fInOKScra,
		clk => clk,
		reset => reset
	);
	
	puer: puertoSerie 
	PORT MAP(
	
		finMapp => finSerie,
		DOUT => doutb,
		clk => clk,
		reset => reset,
		unload => unload,
		output => output,
		rein => xk_re,
		imin => xk_im,
		W => web,
		ADDR => addrb,
		DIN => dinb,
		DV => DV
	);
	
	iff : ifft
	PORT MAP (
	
		clk => clk,
		start => start,
		unload => unload,
		cp_len => cp_len,
		cp_len_we => cp_len_we,
		xn_re => xn_re,
		xn_im => xn_im,
		fwd_inv => fwd_inv,
		fwd_inv_we => fwd_inv_we,
		scale_sch => scale_sch,
		scale_sch_we => scale_sch_we,
		rfd => rfd,
		xn_index => xn_index,
		busy => busy,
		edone => edone,
		done => done,
		dv => dv,
		xk_index => xk_index,
		cpv => cpv,
		xk_re => xk_rep,
		xk_im => xk_imp
  );
  
	shift1 : shift
	PORT MAP (
	
		reIn => xk_rep,
		imIn => xk_imp,
		paridad => xk_index(0),
		reOut => xk_re,
		imOut => xk_im
  );
  
	memI : memInterleaver
	PORT MAP (
		clka => clk,
		rsta => reset,
		wea => wea,
		addra => addra,
		dina => dina,
		douta => douta,
		clkb => clk,
		rstb => reset,
		web => web,
		addrb => addrb,
		dinb => dinb,
		doutb => doutb
  );


   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

    -- Estímulos, tanto de reloj como señales de entrada
	 
	 
	 
   stim_proc: process
   begin		
      -- hacemos un reset de 100 ns
		-- la señal cons no varia en toda la simulación. Codifica la 
		-- modulación empleada:
					--> "001"	: 8psk
					--> "010"	: qpsk
					--> "100"	: bpsk
		-- si nos cupiese el sistema en la fpga asignariamos cada bit a un switch.
		-- en caso de que se use un número distinto, todo funcionaria como bpsk.
		cons <= "100";
		reset <= '1';
		
      wait for 100 ns;	
		reset <= '0';
		-- entrada es la señal de inicio del envio, se conectaría a un botón.
		entrada <='1';

      wait for clk_period*10;
		entrada <= '0';
		-- El envío de datos no comenzaría hasta que volviese a valer 0.

      wait;
   end process;
	
	sinc: process (clk)
	begin
	
	if rising_edge(clk) then
		LinOKInt <= inOKInt;
		-- esta variable fuarda el valor que tuvo 
		-- inOkInt en el ciclo anterior. Se emplea únicamente
		-- para escribir en los ficheros sin tomar dos veces 
		-- el mismo dato. En el fichero del sistema completo 
		-- no existe (sería absurdo).
	end if;
	
	end process;
	escribirArchivo1 : PROCESS(clk)
		variable linea : line;
		variable intToWrite: integer := 0;
BEGIN
		if (rising_edge(clk)) then
			if  inOKInt = '1' and LinOKInt = '0' then
				if inInt = '1' then
					intToWrite := 1;
				else intToWrite := 0;
				end if;
				write(linea, intToWrite);
				write(linea, ";");
				writeline(f1,linea);
			end if;
		end if;
	END PROCESS;



	escribirArchivo2 : PROCESS(clk)
		variable linea2 : line;
		--generamos el fichero con la salida del interleaver (entrada del mapper)
		
BEGIN
		if (rising_edge(clk)) then
			if  inOKMapp = '1' and fInOKMapp = '1' then
				-- le damos el formato de una cadena de caracteres en matlab para luego
				-- emplear la funcion bin2dec y tratar los datos.
				write(linea2, inMapp(2));
				write(linea2, ";");
				write(linea2, inMapp(1));
				write(linea2, ";");
				write(linea2, inMapp(0));
				write(linea2, ";");
				writeline(f2,linea2);
			end if;
		end if;
	END PROCESS;
	
	escribirArchivo3 : PROCESS(clk)
		variable linea2 : line;
		--generamos el fichero de la parte imaginaria de la salida del mapper
		
BEGIN
		if (rising_edge(clk)) then
		
			if  to_integer(unsigned(xn_index))> 15 and to_integer(unsigned(xn_index)) < 113 then
				-- las condiciones nos garantizan que el mapper esté en el estado 'datos'.
				
				-- le damos el formato de una cadena de caracteres en matlab para luego
				-- emplear la funcion bin2dec y tratar los datos.
				write(linea2, "'");
				write(linea2, xn_im(15));
				write(linea2, xn_im(14));
				write(linea2, xn_im(13));
				write(linea2, xn_im(12));
				write(linea2, xn_im(11));
				write(linea2, xn_im(10));
				write(linea2, xn_im(9));
				write(linea2, xn_im(8));
				write(linea2, xn_im(7));
				write(linea2, xn_im(6));
				write(linea2, xn_im(5));
				write(linea2, xn_im(4));
				write(linea2, xn_im(3));
				write(linea2, xn_im(2));
				write(linea2, xn_im(1));
				write(linea2, xn_im(0));
				write(linea2, "'");
				write(linea2, ";");
				writeline(f3,linea2);
			end if;
		end if;
	END PROCESS;
	
		escribirArchivo4 : PROCESS(clk)
		variable linea2 : line;
		--generamos el fichero de la parte real de salida del mapper
		
BEGIN
		if (rising_edge(clk)) then
			if  to_integer(unsigned(xn_index))> 15 and to_integer(unsigned(xn_index)) < 113 then
				-- le damos el formato de una cadena de caracteres en matlab para luego
				-- emplear la funcion bin2dec y tratar los datos.
				write(linea2, "'");
				write(linea2, xn_re(15));
				write(linea2, xn_re(14));
				write(linea2, xn_re(13));
				write(linea2, xn_re(12));
				write(linea2, xn_re(11));
				write(linea2, xn_re(10));
				write(linea2, xn_re(9));
				write(linea2, xn_re(8));
				write(linea2, xn_re(7));
				write(linea2, xn_re(6));
				write(linea2, xn_re(5));
				write(linea2, xn_re(4));
				write(linea2, xn_re(3));
				write(linea2, xn_re(2));
				write(linea2, xn_re(1));
				write(linea2, xn_re(0));
				write(linea2, "'");
				write(linea2, ";");
				writeline(f4,linea2);
			end if;
		end if;
	END PROCESS;
	
	escribirArchivo5 : PROCESS(clk)
		variable linea2 : line;
		-- generamos el fichero de la parte real de la salida
		-- del sistema completo
		
BEGIN
		if (rising_edge(clk)) then
			if  dv = '1' then
				-- le damos el formato de una cadena de caracteres en matlab para luego
				-- emplear la funcion bin2dec y tratar los datos.
				write(linea2, "'");
				write(linea2, xk_re(15));
				write(linea2, xk_re(14));
				write(linea2, xk_re(13));
				write(linea2, xk_re(12));
				write(linea2, xk_re(11));
				write(linea2, xk_re(10));
				write(linea2, xk_re(9));
				write(linea2, xk_re(8));
				write(linea2, xk_re(7));
				write(linea2, xk_re(6));
				write(linea2, xk_re(5));
				write(linea2, xk_re(4));
				write(linea2, xk_re(3));
				write(linea2, xk_re(2));
				write(linea2, xk_re(1));
				write(linea2, xk_re(0));
				write(linea2, "'");
				write(linea2, ";");
				writeline(f5,linea2);
			end if;
		end if;
	END PROCESS;

escribirArchivo6 : PROCESS(clk)
		variable linea2 : line;
		--generamos el fichero de la parte imaginaria de la salida de la ifft
		
BEGIN
		if (rising_edge(clk)) then
			if  dv = '1' then
			-- le damos el formato de una cadena de caracteres en matlab para luego
			-- emplear la funcion bin2dec y tratar los datos.
				write(linea2, "'");
				write(linea2, xk_im(15));
				write(linea2, xk_im(14));
				write(linea2, xk_im(13));
				write(linea2, xk_im(12));
				write(linea2, xk_im(11));
				write(linea2, xk_im(10));
				write(linea2, xk_im(9));
				write(linea2, xk_im(8));
				write(linea2, xk_im(7));
				write(linea2, xk_im(6));
				write(linea2, xk_im(5));
				write(linea2, xk_im(4));
				write(linea2, xk_im(3));
				write(linea2, xk_im(2));
				write(linea2, xk_im(1));
				write(linea2, xk_im(0));
				write(linea2, "'");
				write(linea2, ";");
				writeline(f6,linea2);
			end if;
		end if;
	END PROCESS;

END; 