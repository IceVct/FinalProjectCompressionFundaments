function codedBlocks = imTransformEncoder(image, alpha, N)
%Funcao que vai implementar a etapa de codificacao do codificador de
%imagens por transformada
% Funcao recebe uma imagem, o nome do arquivo binario a ser codificado e um
% parametro para ser usado na matriz de quantizacao
% Retorna um vetor de structs, aonde cada struct contem o vetor reordenado
% e a quantidade de zeros do vetor antes do run-length coding, de todos os
% blocos

image = double(image); % transformando a imagem em double, para subtrair 128

%% Inicializacao das variaveis
[h, w, c] = size(image); % altura, comprimento e canais da imagem

if(c > 1)
    error('Only gray scale images are accepted as arguments!');
end

% O passo de quantizacao usado eh padrao, e vai utilizar uma das matrizes
% padrao usadas em codificadores como MPEG-2 ou H264
% Vai ser multiplicado pelo parametro alpha, que servira para ajustar a
% quantidade de quantizacao
quantizationMatrix = alpha*[16 11 10 16 24 40 51 61;
                      12 12 14 19 26 58 60 55;
                      14 13 16 24 40 57 69 56;
                      14 17 22 29 51 87 80 62;
                      18 22 37 56 68 109 103 77;
                      24 35 55 64 81 104 113 92;
                      49 64 78 87 103 121 120 101;
                      72 92 95 98 112 100 103 99];

% Parametros fixos do algoritmo

amountBlocks = (h*w)/(N*N);
blockVector = zeros(N*N, 1);

sortedQuanDctArray = zeros(64, 1); % array que vai receber os valores retornados do zigzag
countOfZeros = 0;
% vetor de structs que vai armazenar o array reordenado dos componentes DCT
% e a quantidade de zeros presentes no mesmo, para cada bloco
codedBlocks = struct('runLengthArray',{},...
                  'countOfZeros',{});

%% Percorrendo os blocos de tamanho 8x8, calculando o dct, quantizando cada um, reordenando e escrevendo no arquivo de saida cada um
% blocks = reshape(image, N, N, []);
for i = 1:N:w
    for j = 1:N:h
        currentBlock = image(i:(i + N - 1), j:(j + N - 1));
        %currentBlock = blocks(:, :, i);
        currentBlock = currentBlock - 128; % subtrai todos os pixels por 128, para centralizar os componentes DC da DCT
        dctBlock = dct2(currentBlock); % calcula o DCT 2D para o bloco atual
        quantizedDCT = round(dctBlock./quantizationMatrix); % dividindo cada um dos elementos do bloco pelo correspondente na matriz de quantizacao
        sortedQuantDctArray = zigzag(quantizedDCT); % usando o algoritmo zigzag para reordenar os coeficientes DCT
        [runLenghtArray, countOfZeros] = runLengthCoding(sortedQuantDctArray); % aplica o algoritmo run length coding no vetor reordenado pelo zigzag
        
        % x eh uma struct temporario para armazenar os valores que
        % correspondem ao vetor reordenado e o count de 0s no final do array
        x.runLengthArray = runLenghtArray;
        x.countOfZeros = countOfZeros;
        codedBlocks(end + 1) = x;
    end
end



end

