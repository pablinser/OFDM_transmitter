% SCRAMBLER

function [out]=scrambler(in)

prf=[0;0;0;0;1;1;1;0;1;1;1;1;0;0;1;0;1;1;0;0;1;0;0;1;0;0;0;0;0;0;1;0;0;0;1;0;0;1;1;0;0;0;1;0;1;1;1;0;1;0;1;1;0;1;1;0;0;0;0;0;1;1;0;0;1;1;0;1;0;1;0;0;1;1;1;0;0;1;1;1;1;0;1;1;0;1;0;0;0;0;1;0;1;0;1;0;1;1;1;1;1;0;1;0;0;1;0;1;0;0;0;1;1;0;1;1;1;0;0;0;1;1;1;1;1;1;1];
%introducimos la secuecia con la que se debe hacer la xor

%multiplicamos la secuencia por una matriz fila de unos, de longitud igual
%al número de veces que habrá que repetir la secuencia entera.
%con un reshape le damos forma de vector columna.
%por último lo concatenamos con lo que faltaría de secuencia y le hacemos
%la xor con la entrada.

out = xor(in, [reshape(prf*ones(1, floor(length(in)/length(prf))), [], 1);prf(1:mod(length(in)-length(prf), length(prf)))]);





end