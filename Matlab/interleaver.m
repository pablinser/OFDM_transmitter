% INTERLEAVER
% Se barajan los datos


function [salida] = interleaver(dato_in,NBPC)

NBPS=96*NBPC;                                   
% número de bits por símbolo

Ns=floor(length(dato_in)/NBPS);
% número de símbolos recibidos para transmitir


s=8*(1+floor(NBPC/2));                          
% profundidad de la matriz que contendrá cada símbolo


dato_in = reshape(dato_in, [], Ns);
% ponemos cada símbolo completo en una columna

dato_in = reshape(dato_in, s, floor(NBPS/s), []);
% ponemos cada columna en un 'plano' distinto y cada 'plano' tendrá un
% simbolo dimensionado en s x NBPS/s

salida = reshape(permute(dato_in, [2,1,3]), floor(NBPS/s), []);
% trasponemos cada plano

salida = reshape(salida, [], Ns);
% volvemos a tener dos dimensiones, donde cada símbolo ocupa una columna ya
% barajado

end
