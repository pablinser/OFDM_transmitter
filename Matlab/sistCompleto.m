

% load('d8psk.mat')
% NBPC = 3;

% load('dqpsk.mat')
% NBPC = 2;

load('dbpsk.mat')
NBPC = 1;

[ES,SS,IS,MS,FS,PS] =  transmitir(inputStream,NBPC);

norm(ES-encStream)
norm(SS-scrambStream)
norm(IS-intlvStream)
norm(MS-mappedStream)
norm(FS-ifftStream)
norm(PS-txOut)