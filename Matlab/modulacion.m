function salida=modulacion(data)

    a = size(data);
    entrada = fftshift([zeros(a(1), 16) data zeros(a(1),15)], 2);
    salida = ifft(entrada, 128, 2);
end