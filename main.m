%% Script para mostrar la relación entre luminancia percibida
% y tasa de ocultación del Sol durante un eclipse total
%
% Fecha: 17/08/2026
% Autor: Alfredo Rodríguez Magdalena ©

clear;
clc;
close all;

projectRoot = pwd;%fileparts(mfilename('fullpath'));

addpath(fullfile(projectRoot, 'src'));

%% =========================================================
% CONFIGURACIÓN
% ==========================================================

% Ruta al timelapse de Cabo Busto
videoPath = 'data/raw/timelapse_cabo_busto.mp4';

% Factor de aceleración del timelapse:
%
%   1 s de vídeo = 15 s reales
%
timeLapseFactor = 15;

% Hora local correspondiente al comienzo del timelapse
tVideoStartLocal = datetime(2026,8,12,20,25,4);

% Exportar animación a MP4
exportVideo = false;

outputVideoPath = 'eclipse_cabo_busto.mp4';


%% =========================================================
% DATOS NASA - ECLIPSE 12/08/2026
% ==========================================================

% Fuente:
% NASA/GSFC - Solar Eclipse Predictions
% Besselian Elements for the Total Solar Eclipse of 2026 Aug 12
%
% Efemérides: VSOP87/ELP2000-82
% Delta T = 75.4 s
%
% URL: <https://eclipse.gsfc.nasa.gov/SEsearch/SEdata.php?Ecl=+20260812> 

eclipseData.deltaT = 75.4;

eclipseData.t0TT = datetime(2026,8,12,18,0,0);

eclipseData.coeffs.x = [ ...
   -0.0000080, ...
   -0.0000773, ...
    0.5189249, ...
    0.4755140];

eclipseData.coeffs.y = [ ...
    0.0000038, ...
   -0.0001246, ...
   -0.2301680, ...
    0.7711830];

eclipseData.coeffs.d = [ ...
   -0.0000030, ...
   -0.0120650, ...
   14.7966700];

eclipseData.coeffs.l1 = [ ...
   -0.0000121, ...
    0.0000939, ...
    0.5379550];

eclipseData.coeffs.l2 = [ ...
   -0.0000121, ...
    0.0000935, ...
   -0.0081420];

eclipseData.coeffs.mu = [ ...
    15.003090, ...
    88.747787];

eclipseData.tanF1 = 0.0046141;
eclipseData.tanF2 = 0.0045911;


%% =========================================================
% OBSERVADOR - CABO BUSTO
% ==========================================================

lat = 43.5628;
lon = -6.4737;
h   = 60;       % [m], aproximado


%% =========================================================
% CURVA TEÓRICA COMPLETA DEL ECLIPSE
% ==========================================================

tUT = datetime(2026,8,12,17,30,0) ...
    :seconds(1): ...
      datetime(2026,8,12,19,30,0);

% Hora local de España peninsular (CEST = UT + 2 h)
tLocal = tUT + hours(2);

Obs = theoreticalEclipseObscuration( ...
    lat, lon, h, ...
    tUT, eclipseData);

%% =========================================================
% CONTACTOS TEÓRICOS C2 Y C3
% ==========================================================

% Función auxiliar para evaluar el residuo geométrico de la umbra:
%
%       residual = rho - |L2|
%
% residual = 0 -> C2 o C3

contactResidual = @(tUT) localContactResidual( ...
    tUT, ...
    lat, lon, h, ...
    eclipseData);


% Intervalos aproximados que contienen cada contacto [UT]

tRef = datetime(2026,8,12,18,0,0);

bracketC2 = seconds([ ...
    datetime(2026,8,12,18,26,0) ...
    datetime(2026,8,12,18,27,0)] - tRef);

bracketC3 = seconds([ ...
    datetime(2026,8,12,18,28,0) ...
    datetime(2026,8,12,18,29,0)] - tRef);


% fzero trabaja aquí sobre segundos respecto a tRef

offsetC2 = fzero( ...
    @(offset) contactResidual(tRef + seconds(offset)), ...
    bracketC2);

offsetC3 = fzero( ...
    @(offset) contactResidual(tRef + seconds(offset)), ...
    bracketC3);


% Contactos en UT

tC2UT = tRef + seconds(offsetC2);
tC3UT = tRef + seconds(offsetC3);


% UT -> hora local CEST

tC2Local = tC2UT + hours(2);
tC3Local = tC3UT + hours(2);


% Mostrar resultados

fprintf('\nContactos teóricos - Cabo Busto\n');

fprintf('C2: %s CEST\n', ...
    string(tC2Local, 'HH:mm:ss.SSS'));

fprintf('C3: %s CEST\n', ...
    string(tC3Local, 'HH:mm:ss.SSS'));

fprintf('Duración de la totalidad: %.3f s\n\n', ...
    seconds(tC3UT - tC2UT));

%% Representación general del eclipse

figure(1);

plot( ...
    tLocal, ...
    100*Obs, ...
    'LineWidth', 1.5);

xlabel('Hora local (CEST)');
ylabel('Obscuration [%]');

ylim([0 105]);

grid on;

title('Ocultación teórica - Cabo Busto');


%% =========================================================
% ANÁLISIS DEL TIMELAPSE
% ==========================================================

videoData = analyzeLuminanceVideo(videoPath);


%% =========================================================
% SINCRONIZACIÓN TEMPORAL DEL TIMELAPSE
% ==========================================================

% videoData.time está expresado en segundos de reproducción.
%
% Como el timelapse está acelerado x15:
%
%   tiempo real = tiempo vídeo * 15
%

tVideoLocal = tVideoStartLocal ...
    + seconds(videoData.time * timeLapseFactor);

% CEST -> UT
tVideoUT = tVideoLocal - hours(2);


%% =========================================================
% OBSCURATION CORRESPONDIENTE A CADA FRAME
% ==========================================================

ObsVideo = theoreticalEclipseObscuration( ...
    lat, lon, h, ...
    tVideoUT, eclipseData);

% Expresarla directamente en porcentaje
ObsVideo = 100 * ObsVideo;


%% =========================================================
% LUMINANCIA PERCIBIDA
% ==========================================================

% Utilizamos como estadístico la mediana del canal L*.
%
% Es más robusta que la media ante regiones pequeñas
% extremadamente claras u oscuras.

Lvideo = videoData.medianL;

%% =========================================================
% FIGURA DOCUMENTACION - HISTOGRAMA TEMPORAL DE L*
% ==========================================================

fig = figure( ...
    'Color', 'w', ...
    'Position', [100 100 1200 600]);

ax = axes(fig);

imagesc( ...
    ax, ...
    tVideoLocal, ...
    videoData.binCenters, ...
    videoData.histogram);

axis(ax, 'xy');

xlabel(ax, 'Hora local (CEST)');
ylabel(ax, 'L^*');

title(ax, 'Evolución temporal de la distribución de L^*');

cb = colorbar(ax);
ylabel(cb, 'Fracción de píxeles');

ylim(ax, [0 100]);

hold(ax, 'on');

% Mediana de L*
plot( ...
    ax, ...
    tVideoLocal, ...
    videoData.medianL, ...
    'w', ...
    'LineWidth', 2);

% Contactos de totalidad
xline(ax, ...
    tC2Local, ...
    '--w', ...
    'C2', ...
    'LineWidth', 1.3, ...
    'LabelVerticalAlignment', 'bottom');

xline(ax, ...
    tC3Local, ...
    '--w', ...
    'C3', ...
    'LineWidth', 1.3, ...
    'LabelVerticalAlignment', 'bottom');

grid(ax, 'on');

% Exportar
outputPath = fullfile( ...
    projectRoot, ...
    'docs', ...
    'figuras', ...
    'histograma-luminancia.png');

exportgraphics( ...
    fig, ...
    outputPath, ...
    'Resolution', 200);

%% =========================================================
% FIGURA DOCUMENTACION - RESULTADO DEL EXPERIMENTO
% ==========================================================

fig = figure( ...
    'Color', 'w', ...
    'Position', [100 100 1200 800]);

tl = tiledlayout( ...
    fig, ...
    2, 1, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');


% ---------------------------------------------------------
% Fracción de ocultación
% ----------------------------------------------------------

axObs = nexttile(tl, 1);

hold(axObs, 'on');

ylim(axObs, [95 101]);

xlabel(axObs, 'Hora local (CEST)');
ylabel(axObs, 'Ocultación del disco solar [%]');

title(axObs, 'Fracción de ocultación teórica');

grid(axObs, 'on');


% Curva teórica
plot( ...
    axObs, ...
    tVideoLocal, ...
    ObsVideo, ...
    'LineWidth', 2);


% Banda de totalidad
ylObs = ylim(axObs);

hTotalityObs = patch( ...
    axObs, ...
    [tC2Local tC3Local tC3Local tC2Local], ...
    [ylObs(1) ylObs(1) ylObs(2) ylObs(2)], ...
    [0.75 0.75 0.75], ...
    'FaceAlpha', 0.35, ...
    'EdgeColor', 'none');

uistack(hTotalityObs, 'bottom');


% C2 y C3
xline(axObs, ...
    tC2Local, ...
    '--', ...
    'C2', ...
    'LineWidth', 1.2, ...
    'LabelVerticalAlignment', 'top');

xline(axObs, ...
    tC3Local, ...
    '--', ...
    'C3', ...
    'LineWidth', 1.2, ...
    'LabelVerticalAlignment', 'top');


% Referencia del modelo
text( ...
    axObs, ...
    0.99, ...
    0.06, ...
    'Modelo besseliano · NASA/GSFC', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'FontSize', 9);


% ---------------------------------------------------------
% Luminancia percibida
% ----------------------------------------------------------

axLum = nexttile(tl, 2);

hold(axLum, 'on');

Lmin = min(Lvideo);
Lmax = max(Lvideo);

Lmargin = 0.05 * (Lmax - Lmin);

ylim(axLum, ...
    [Lmin - Lmargin, ...
     Lmax + Lmargin]);

xlabel(axLum, 'Hora local (CEST)');
ylabel(axLum, 'Mediana de L^*');

title(axLum, 'Luminancia percibida');

grid(axLum, 'on');


% Curva de luminancia
plot( ...
    axLum, ...
    tVideoLocal, ...
    Lvideo, ...
    'LineWidth', 2);


% Banda de totalidad
ylLum = ylim(axLum);

hTotalityLum = patch( ...
    axLum, ...
    [tC2Local tC3Local tC3Local tC2Local], ...
    [ylLum(1) ylLum(1) ylLum(2) ylLum(2)], ...
    [0.75 0.75 0.75], ...
    'FaceAlpha', 0.35, ...
    'EdgeColor', 'none');

uistack(hTotalityLum, 'bottom');


% C2 y C3
xline(axLum, ...
    tC2Local, ...
    '--', ...
    'C2', ...
    'LineWidth', 1.2, ...
    'LabelVerticalAlignment', 'top');

xline(axLum, ...
    tC3Local, ...
    '--', ...
    'C3', ...
    'LineWidth', 1.2, ...
    'LabelVerticalAlignment', 'top');


% ---------------------------------------------------------
% Exportar
% ----------------------------------------------------------

outputPath = fullfile( ...
    projectRoot, ...
    'docs', ...
    'figuras', ...
    'resultado-experimento.png');

exportgraphics( ...
    fig, ...
    outputPath, ...
    'Resolution', 200);
%% =========================================================
% ANIMACIÓN
%
%   Izquierda:
%       vídeo de Cabo Busto
%
%   Derecha arriba:
%       obscuration teórica
%
%   Derecha abajo:
%       luminancia percibida
% ==========================================================

video = VideoReader(videoPath);

nSamples = numel(videoData.time);


% Crear figura

fig = figure( ...
    'Color', 'w', ...
    'Position', [100 100 1400 750]);

tl = tiledlayout( ...
    fig, ...
    2, 2, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');


% ---------------------------------------------------------
% Panel izquierdo: vídeo
% ----------------------------------------------------------

axVideo = nexttile(tl, [2 1]);

firstFrame = readFrame(video);

hImage = image( ...
    axVideo, ...
    firstFrame);

axis(axVideo, 'image');
axis(axVideo, 'off');

title( ...
    axVideo, ...
    'Cabo Busto — 12/08/2026');


% Hora local sobre el vídeo

hTime = text( ...
    axVideo, ...
    0.03, ...
    0.95, ...
    '', ...
    'Units', 'normalized', ...
    'Color', 'w', ...
    'FontSize', 16, ...
    'FontWeight', 'bold', ...
    'VerticalAlignment', 'top');


% ---------------------------------------------------------
% Panel superior derecho: obscuration
% ----------------------------------------------------------

axObs = nexttile(tl, 2);

hold(axObs, 'on');

hObs = plot( ...
    axObs, ...
    NaT, ...
    NaN, ...
    'LineWidth', 2);

hObsPoint = plot( ...
    axObs, ...
    NaT, ...
    NaN, ...
    'o', ...
    'MarkerFaceColor', 'auto');

xlabel(axObs, 'Hora local (CEST)');
ylabel(axObs, 'Magnitud [%]');

title(axObs, 'Magnitud teórica del eclipse');

xlim(axObs, ...
    [tVideoLocal(1), tVideoLocal(end)]);

ylim(axObs, [96 102]);

grid(axObs, 'on');

% Zona de totalidad teórica

ylObs = ylim(axObs);

hTotalityObs = patch(axObs, ...
    [tC2Local tC3Local tC3Local tC2Local], ...
    [ylObs(1) ylObs(1) ylObs(2) ylObs(2)], ...
    [0.75 0.75 0.75], ...
    'FaceAlpha', 0.35, ...
    'EdgeColor', 'none');

uistack(hTotalityObs, 'bottom');

% Contactos teóricos

xline(axObs, tC2Local, '--', ...
    'C2', ...
    'LineWidth', 1.2, ...
    'LabelVerticalAlignment', 'top');

xline(axObs, tC3Local, '--', ...
    'C3', ...
    'LineWidth', 1.2, ...
    'LabelVerticalAlignment', 'top');

text(axObs, ...
    0.99, 0.04, ...
    'Modelo besseliano · NASA/GSFC', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 9);


% ---------------------------------------------------------
% Panel inferior derecho: luminancia
% ----------------------------------------------------------

axLum = nexttile(tl, 4);

hold(axLum, 'on');

hLum = plot( ...
    axLum, ...
    NaT, ...
    NaN, ...
    'LineWidth', 2);

hLumPoint = plot( ...
    axLum, ...
    NaT, ...
    NaN, ...
    'o', ...
    'MarkerFaceColor', 'auto');

xlabel(axLum, 'Hora local (CEST)');
ylabel(axLum, 'Mediana de L^*');

title(axLum, 'Luminancia percibida');

xlim(axLum, ...
    [tVideoLocal(1), tVideoLocal(end)]);


% Límites verticales fijos para evitar que cambie la escala
% durante la animación

Lmin = min(Lvideo);
Lmax = max(Lvideo);

Lmargin = 0.05 * (Lmax - Lmin);

ylim(axLum, ...
    [Lmin - Lmargin, ...
     Lmax + Lmargin]);

grid(axLum, 'on');

% Zona de totalidad teórica

ylLum = ylim(axLum);

hTotalityLum = patch(axLum, ...
    [tC2Local tC3Local tC3Local tC2Local], ...
    [ylLum(1) ylLum(1) ylLum(2) ylLum(2)], ...
    [0.75 0.75 0.75], ...
    'FaceAlpha', 0.35, ...
    'EdgeColor', 'none');

uistack(hTotalityLum, 'bottom');


% Contactos teóricos

xline(axLum, tC2Local, '--', ...
    'C2', ...
    'LineWidth', 1.2, ...
    'LabelVerticalAlignment', 'top');

xline(axLum, tC3Local, '--', ...
    'C3', ...
    'LineWidth', 1.2, ...
    'LabelVerticalAlignment', 'top');

%% =========================================================
% PREPARAR EXPORTACIÓN
% ==========================================================

if exportVideo

    writer = VideoWriter( ...
        outputVideoPath, ...
        'MPEG-4');

    writer.FrameRate = video.FrameRate;

    open(writer);

end


%% =========================================================
% REPRODUCIR ANIMACIÓN
% ==========================================================

video.CurrentTime = 0;

k = 0;

while hasFrame(video) && k < nSamples

    k = k + 1;


    % Frame actual

    frameRGB = readFrame(video);

    hImage.CData = frameRGB;


    % Hora local

    hTime.String = ...
        string( ...
            tVideoLocal(k), ...
            'HH:mm:ss');


    % Obscuration acumulada

    hObs.XData = tVideoLocal(1:k);
    hObs.YData = ObsVideo(1:k);

    hObsPoint.XData = tVideoLocal(k);
    hObsPoint.YData = ObsVideo(k);


    % Luminancia acumulada

    hLum.XData = tVideoLocal(1:k);
    hLum.YData = Lvideo(1:k);

    hLumPoint.XData = tVideoLocal(k);
    hLumPoint.YData = Lvideo(k);


    % Actualizar figura

    drawnow;


    % Guardar frame

    if exportVideo

        animationFrame = getframe(fig);

        writeVideo( ...
            writer, ...
            animationFrame);

    end

end


%% =========================================================
% CERRAR EXPORTACIÓN
% ==========================================================

if exportVideo

    close(writer);

    fprintf( ...
        '\nAnimación guardada en:\n%s\n', ...
        outputVideoPath);

end

%% Funciones auxiliares
function residual = localContactResidual( ...
    tUT, lat, lon, h, eclipseData)

    % UT -> TT
    tTT = tUT + seconds(eclipseData.deltaT);

    % Elementos besselianos
    elements = evaluateBesselElements( ...
        tTT, ...
        eclipseData.t0TT, ...
        eclipseData.coeffs);

    % Coordenadas besselianas del observador
    [xi, eta, zeta] = observerBesselCoordinates( ...
        lat, lon, h, ...
        elements.d, ...
        elements.mu);

    % Geometría local
    geom = localEclipseGeometry( ...
        elements, ...
        xi, eta, zeta, ...
        eclipseData.tanF1, ...
        eclipseData.tanF2);

    % Condición de entrada/salida de la umbra
    residual = geom.rho - abs(geom.L2);

end