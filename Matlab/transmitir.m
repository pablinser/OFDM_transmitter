function [ES,SS,IS,MS,FS,PS] =  transmitir(data,NBPC)
    ES = codificador_convolucional(data);
    dim = size(ES);
    resto = mod(dim(1), 96*NBPC);
    if resto ~= 0
        ES = [ES;zeros(96 * NBPC - resto, dim(2))];
    end
    
    SS = scrambler(ES);
    IS = interleaver(SS, NBPC);
    MS = mapper2(IS, NBPC);
    FS = modulacion(MS);
    PS = prefijo_ciclico(FS);
    
end
