function videoData = analyzeLuminanceVideo(videoPath)
%ANALYZELUMINANCEVIDEO Analiza la evolución de la luminancia de un vídeo.
%
%   VIDEODATA = ANALYZELUMINANCEVIDEO(VIDEOPATH)
%
%   procesa un vídeo frame a frame, convierte cada imagen del espacio
%   RGB al espacio de color CIELAB y analiza el canal de luminancia L*.
%
%   Para cada frame se calcula:
%
%       - Histograma normalizado de L*.
%       - Media de L*.
%       - Mediana de L*.
%       - Desviación típica de L*.
%       - Percentiles P10, P25, P75 y P90.
%
%   Autor: Alfredo Rodríguez Magdalena ©
%   Fecha: 17/08/2026
%
%   ENTRADA
%       videoPath - Ruta al archivo de vídeo.
%
%   SALIDA
%       videoData - Estructura con los resultados:
%
%           .time
%               Tiempo relativo desde el comienzo del vídeo [s].
%
%           .frame
%               Número de frame.
%
%           .histogram
%               Matriz con la evolución temporal del histograma.
%               Cada columna corresponde a un frame.
%
%           .binCenters
%               Centros de los bins de L*.
%
%           .meanL
%               Media de L* para cada frame.
%
%           .medianL
%               Mediana de L* para cada frame.
%
%           .stdL
%               Desviación típica de L* para cada frame.
%
%           .p10L, .p25L, .p75L, .p90L
%               Percentiles de la distribución de L*.
%
%           .frameRate
%               Frame rate nominal del vídeo [fps].
%
%           .duration
%               Duración nominal del vídeo [s].
%
%   NOTA
%       El tiempo generado por esta función es relativo al comienzo del
%       vídeo. La sincronización con UT/CEST se realizará posteriormente.
%
%       El histograma se normaliza como probabilidad, por lo que cada
%       columna suma aproximadamente 1.

    arguments
        videoPath {mustBeTextScalar}
    end


    %% =====================================================
    % Abrir vídeo
    % ======================================================

    video = VideoReader(videoPath);

    frameRate = video.FrameRate;
    duration  = video.Duration;

    % Número estimado de frames
    nFramesEstimated = floor(duration * frameRate);


    %% =====================================================
    % Histograma L*
    % ======================================================

    % 100 bins entre L*=0 y L*=100
    edges = linspace(0, 100, 101);

    binCenters = ...
        (edges(1:end-1) + edges(2:end)) / 2;

    nBins = numel(binCenters);


    %% =====================================================
    % Preasignación
    % ======================================================

    frameNumber = zeros(1, nFramesEstimated);
    time        = zeros(1, nFramesEstimated);

    histEvolution = zeros(nBins, nFramesEstimated);

    meanL   = zeros(1, nFramesEstimated);
    medianL = zeros(1, nFramesEstimated);
    stdL    = zeros(1, nFramesEstimated);

    p10L = zeros(1, nFramesEstimated);
    p25L = zeros(1, nFramesEstimated);
    p75L = zeros(1, nFramesEstimated);
    p90L = zeros(1, nFramesEstimated);


    %% =====================================================
    % Procesamiento frame a frame
    % ======================================================

    k = 0;

    fprintf('\nAnalizando vídeo...\n');

    while hasFrame(video)

        k = k + 1;

        % Tiempo correspondiente al comienzo del frame
        frameTime = video.CurrentTime;

        % Leer frame RGB
        frameRGB = readFrame(video);


        %% RGB -> CIELAB

        frameLAB = rgb2lab(frameRGB);

        % Canal de luminancia
        L = frameLAB(:,:,1);

        % Convertir a vector para los cálculos estadísticos
        Lvector = L(:);


        %% Histograma normalizado

        counts = histcounts( ...
            Lvector, ...
            edges, ...
            'Normalization', 'probability');

        histEvolution(:,k) = counts(:);


        %% Estadísticos

        meanL(k)   = mean(Lvector);
        medianL(k) = median(Lvector);
        stdL(k)    = std(Lvector);

        percentiles = prctile( ...
            Lvector, ...
            [10 25 75 90]);

        p10L(k) = percentiles(1);
        p25L(k) = percentiles(2);
        p75L(k) = percentiles(3);
        p90L(k) = percentiles(4);


        %% Información temporal

        frameNumber(k) = k;
        time(k)        = frameTime;


        %% Progreso

        if mod(k,100) == 0

            fprintf( ...
                'Procesados %d frames (%.1f s)\n', ...
                k, frameTime);

        end

    end


    %% =====================================================
    % Ajustar tamaño real
    % ======================================================

    frameNumber = frameNumber(1:k);
    time        = time(1:k);

    histEvolution = histEvolution(:,1:k);

    meanL   = meanL(1:k);
    medianL = medianL(1:k);
    stdL    = stdL(1:k);

    p10L = p10L(1:k);
    p25L = p25L(1:k);
    p75L = p75L(1:k);
    p90L = p90L(1:k);


    %% =====================================================
    % Construir salida
    % ======================================================

    videoData.frame = frameNumber;
    videoData.time  = time;

    videoData.histogram  = histEvolution;
    videoData.binCenters = binCenters;

    videoData.meanL   = meanL;
    videoData.medianL = medianL;
    videoData.stdL    = stdL;

    videoData.p10L = p10L;
    videoData.p25L = p25L;
    videoData.p75L = p75L;
    videoData.p90L = p90L;

    videoData.frameRate = frameRate;
    videoData.duration  = duration;


    %% =====================================================
    % Resumen
    % ======================================================

    fprintf('\nAnálisis completado.\n');
    fprintf('Frames procesados : %d\n', k);
    fprintf('Frame rate         : %.3f fps\n', frameRate);
    fprintf('Duración           : %.3f s\n\n', duration);

end