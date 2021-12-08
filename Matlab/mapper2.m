function salida=mapper2(data,NBPC)
    % funcion maper. La codificación es diferencial. Es decir, la
    % información va en el desfase de unas muestras con respecto a otras,
    % siendo la primera de referencia.
    % en funcion del numero de bits por portadora (NBPC) el desfase de las
    % puestras será distinto, por eso hacemos un switch para cada
    % constelación.
    % la matriz de salida tendrá las mismas filas que columnas la entrada y
    % calculamos cada simbolo según el desfase acumulado. Para obtener un
    % vector con el desfase acumulado multiplicamos la entrada por una
    % matriz triangular superior que nos hace de 'sumador'. luedo
    % calculamos el resto al dividir esa matriz por 8 y lo multiplicamos
    % por pi/4, para que la misma operación valga para las 3
    % constelaciones. En la segunda linea convertimos los datos a decimal
    % para poder usarlos como indices del vector 'constel'
    dim = size(data);
    data = reshape(bin2dec(char(reshape(data, NBPC, []).'+48)), [], dim(2));
    
    switch NBPC
        case 1
            constel = [0, 4];
        case 2
            constel = [0, 2, 6, 4];
        case 3
            constel = [0, 1, 3, 2, 7, 6, 4, 5];
    end
    dim = size(data);
    if dim(2) == 1
        data = [4*ones(1,dim(2));constel(data+1).'];
    else
        data = [4*ones(1,dim(2));constel(data+1)];
    end
    fase = (pi/4).*mod(data.' * triu(ones(dim(1)+1)),8);
    salida = exp(1).^(1i*fase);
    
    
    
end