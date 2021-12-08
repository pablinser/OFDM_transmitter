% PREFIJO C�CLICO
% Se ponen los �ltimos 12 bits(n� muestras) al comienzo
% 
 function salida=prefijo_ciclico(data) 
    %nos llega un símbolo en cada fila. le añadimos las doce últimas
    %muestras al principio y usamos reshape para que sea un vector fila.
    salida = reshape([data(:,length(data)-11:length(data)),data].', 1, []);
 end