% CODIFICADOR CONVOLUCIONAL
% Salen dos datos de salida tras hacer la xor

function [out] = codificador_convolucional(in)     % Devuelve m�s de una salida
                   
    dataCeros = [zeros(6, 1); in; zeros(6, 1)];           % Matriz formada por 6 ceros + datos de entrada (N bytes) + 6 ceros.

    N = length(dataCeros);                                     % Se establece la longitud de la matriz creada anteriormente.

    % hemos sustituido el bucle que teniamos antes por unas matrices que
    % realizan la misma operación. son matrices formadas por una serie de
    % vectores columna que tienen a uno las posiciones que hay que sumar en
    % cada iteración.
    %hay una matriz por cada salida (cada una de las puertas xor)
    %esta operación nos da la suma en decimal, para tener la suma en
    %binario simplemente realizamos la operacion n%2 y así nos quedamos con
    %el resto de la división, siendo ese el número buscado.
    %cuando tenemos las dos vectores fila con los resultados de cada xor,
    %los concatenamos (en una matriz de dos filas y después hacemos un
    %reshape para entremexclar las dos filas, formando una sola columna,
    %obteniendo el resultado buscado.
    
    unos = ones(N-6, 1);
    b = diag(unos, -1);
    c = diag(unos, -3);
    d = diag(unos, -5);
    e = diag(unos, -6);
    
    out = dataCeros.'*([diag(unos, 0);zeros(6, N-6)]+[b(:,1:N-6); zeros(5, N-6)]+[c(:, 1:N-6); zeros(3, N-6)]+[d(:, 1:N-6); zeros(1, N-6)]+e(:, 1:N-6));
    
    b = diag(unos, -2);
    c = diag(unos, -3);
    e = diag(unos, -6);
    
    out = [out; dataCeros.'*([diag(unos, 0);zeros(6, N-6)]+[b(:,1:N-6); zeros(4, N-6)]+[c(:, 1:N-6); zeros(3, N-6)]+e(:, 1:N-6))];
    out = mod(reshape(out, [], 1), 2);

end
