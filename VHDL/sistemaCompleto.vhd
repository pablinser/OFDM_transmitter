------------------------------------------------
--
--			Fichero que conecta todos los bloques.
--
--			Esta versión no conecta el shift
--
--
--
--
--
------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity sistemaCompleto is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           cons : in  STD_LOGIC_VECTOR (2 downto 0);
           datos : in  STD_LOGIC;
           datosFin : in  STD_LOGIC;
           datosOk : in  STD_LOGIC;
           output : out  STD_LOGIC;
           sistListo : out  STD_LOGIC);
end sistemaCompleto;

architecture Behavioral of sistemaCompleto is

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
    signal xk_re 			: STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal xk_im 			: STD_LOGIC_VECTOR(15 DOWNTO 0);
	 
	 -- Señales de la memoria
	 
    signal wea 	: STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal addra 	: STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal dina 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal douta 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal rstb 	: STD_LOGIC;
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
	 signal inInt		: std_logic;
	 signal inOKInt	: std_logic;
	 
	 -- Señales del scrambler
	 
	 signal in1Scra	: std_logic;
	 signal in2Scra	: std_logic;
	 signal inOKScra	: std_logic;
	 signal FinInScra	: std_logic;
	 signal fInOKScra	: std_logic;
	 

begin

	conv: CONV2 PORT MAP(
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
	
	inte: INTERLEAVER PORT MAP(
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
	
	mapp: MAPPER PORT MAP(
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
	
	scra: SCRAMBLER2 PORT MAP(
			  
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
	
	puer: puertoSerie PORT MAP(
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
    xk_re => xk_re,
    xk_im => xk_im
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
    rstb => rstb,
    web => web,
    addrb => addrb,
    dinb => dinb,
    doutb => doutb
  );


end Behavioral;

