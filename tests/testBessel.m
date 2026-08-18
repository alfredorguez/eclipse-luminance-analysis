%% TESTS DEL MODELO BESSELIANO

clear;
clc;

fprintf('\nVALIDACION DEL MODELO BESSELIANO\n');
fprintf('================================\n\n');


%% Datos del eclipse NASA 2026-08-12

deltaT = 75.4;  % [s]

t0TT = datetime(2026,8,12,18,0,0);

coeffs.x = [ ...
   -0.0000080, ...
   -0.0000773, ...
    0.5189249, ...
    0.4755140];

coeffs.y = [ ...
    0.0000038, ...
   -0.0001246, ...
   -0.2301680, ...
    0.7711830];

coeffs.d = [ ...
   -0.0000030, ...
   -0.0120650, ...
   14.7966700];

coeffs.l1 = [ ...
   -0.0000121, ...
    0.0000939, ...
    0.5379550];

coeffs.l2 = [ ...
   -0.0000121, ...
    0.0000935, ...
   -0.0081420];

coeffs.mu = [ ...
    15.003090, ...
    88.747787];

tanF1 = 0.0046141;
tanF2 = 0.0045911;


%% Coordenadas Cabo Busto

lat = 43.5628;
lon = -6.4737;
h   = 60;       % [m], aproximado


%% =========================================================
% TEST 1
% Comprobar los polinomios exactamente en t0
% ==========================================================

fprintf('TEST 1 - Elementos besselianos en t0\n');

elements0 = evaluateBesselElements(t0TT, t0TT, coeffs);

fprintf('x  = %.7f  (esperado 0.4755140)\n', elements0.x);
fprintf('y  = %.7f  (esperado 0.7711830)\n', elements0.y);
fprintf('d  = %.7f  (esperado 14.7966700)\n', elements0.d);
fprintf('l1 = %.7f  (esperado 0.5379550)\n', elements0.l1);
fprintf('l2 = %.7f  (esperado -0.0081420)\n', elements0.l2);
fprintf('mu = %.6f   (esperado 88.747787)\n', elements0.mu);

tol = 1e-10;

assert(abs(elements0.x  - 0.4755140) < tol);
assert(abs(elements0.y  - 0.7711830) < tol);
assert(abs(elements0.d  - 14.7966700) < tol);
assert(abs(elements0.l1 - 0.5379550) < tol);
assert(abs(elements0.l2 + 0.0081420) < tol);
assert(abs(elements0.mu - 88.747787) < tol);

fprintf('-> OK\n\n');


%% =========================================================
% TEST 2
% Comprobar UT -> TT usando el máximo global de NASA
% ==========================================================

fprintf('TEST 2 - Conversion temporal NASA\n');

tGreatestUT = datetime(2026,8,12,17,45,51);

tGreatestTT = tGreatestUT + seconds(deltaT);

fprintf('UT : %s\n', string(tGreatestUT, ...
    'yyyy-MM-dd HH:mm:ss.SSS'));

fprintf('TT : %s\n', string(tGreatestTT, ...
    'yyyy-MM-dd HH:mm:ss.SSS'));

% NASA publica aproximadamente 17:47:06 TDT
expectedTT = datetime(2026,8,12,17,47,6.4);

assert(abs(seconds(tGreatestTT - expectedTT)) < 1e-6);

fprintf('-> OK\n\n');


%% =========================================================
% TEST 3
% Comprobar contactos C2 / max / C3 de Cabo Busto
% ==========================================================

fprintf('TEST 3 - Geometria local Cabo Busto\n');

tC2  = datetime(2026,8,12,18,26,45.0);
tMax = datetime(2026,8,12,18,27,40.0);
tC3  = datetime(2026,8,12,18,28,34.8);

timesUT = [tC2 tMax tC3];

labels = ["C2", "MAX", "C3"];

fprintf('       rho         |L2|       |L2|-rho\n');
fprintf('-----------------------------------------\n');

margins = zeros(1,3);

for k = 1:3

    % UT -> TT
    tTT = timesUT(k) + seconds(deltaT);

    % Elementos besselianos
    elements = evaluateBesselElements( ...
        tTT, t0TT, coeffs);

    % Posicion del observador
    [xi, eta, zeta] = observerBesselCoordinates( ...
        lat, lon, h, ...
        elements.d, elements.mu);

    % Geometria local
    geom = localEclipseGeometry( ...
        elements, ...
        xi, eta, zeta, ...
        tanF1, tanF2);

    margins(k) = abs(geom.L2) - geom.rho;

    fprintf('%-4s %10.6f  %10.6f  %+10.6f\n', ...
        labels(k), ...
        geom.rho, ...
        abs(geom.L2), ...
        margins(k));

end

% En el maximo debemos estar claramente dentro de la umbra
assert(margins(2) > 0);

% C2 y C3 deben estar cerca de la frontera
assert(abs(margins(1)) < 1e-3);
assert(abs(margins(3)) < 1e-3);

fprintf('-> Geometria cualitativamente coherente\n\n');


%% =========================================================
% TEST 4
% Encontrar numericamente C2 y C3
% ==========================================================

fprintf('TEST 4 - Contactos calculados con fzero\n');

contactResidual = @(offset) eclipseContactResidual( ...
    tC2 + seconds(offset), ...
    lat, lon, h, ...
    deltaT, t0TT, coeffs, ...
    tanF1, tanF2);

offsetC2 = fzero(contactResidual, [-30 30]);

expectedC3Offset = seconds(tC3 - tC2);

offsetC3 = fzero(contactResidual, ...
    [expectedC3Offset - 30, ...
     expectedC3Offset + 30]);

tC2calc = tC2 + seconds(offsetC2);
tC3calc = tC2 + seconds(offsetC3);

errC2 = seconds(tC2calc - tC2);
errC3 = seconds(tC3calc - tC3);

fprintf('C2 calculado : %s   error = %+6.3f s\n', ...
    string(tC2calc,'HH:mm:ss.SSS'), errC2);

fprintf('C3 calculado : %s   error = %+6.3f s\n', ...
    string(tC3calc,'HH:mm:ss.SSS'), errC3);

fprintf('\nDuracion oficial   : %.3f s\n', ...
    seconds(tC3-tC2));

fprintf('Duracion calculada : %.3f s\n', ...
    seconds(tC3calc-tC2calc));

%% =========================================================
% TEST 5
% Validacion C1-C4 contra el mapa NASA
%
% Dataset:
%   VSOP87/ELP2000-82
%   DeltaT = 75.4 s
%
% Circunstancias locales NASA para:
%   Lat = 41.8940 N
%   Lon = 5.3802 W
% ==========================================================

fprintf('\nTEST 5 - Validacion C1-C4 contra mapa NASA\n');


%% Punto de referencia NASA

latNASA = 41.8940;
lonNASA = -5.3802;      % Este positivo, oeste negativo
hNASA   = 0;            % [m], asumimos nivel del mar


%% Circunstancias locales publicadas por NASA [UT]

tC1_NASA  = datetime(2026,8,12,17,33,56.4);
tC2_NASA  = datetime(2026,8,12,18,29,33.6);
tMax_NASA = datetime(2026,8,12,18,30,15.3);
tC3_NASA  = datetime(2026,8,12,18,30,56.8);
tC4_NASA  = datetime(2026,8,12,19,23,00.2);


%% ---------------------------------------------------------
% Residuales
% ---------------------------------------------------------

partialResidual = @(t) eclipseContactResidualGeneral( ...
    t, ...
    latNASA, lonNASA, hNASA, ...
    deltaT, t0TT, coeffs, ...
    tanF1, tanF2, ...
    "partial");

totalResidual = @(t) eclipseContactResidualGeneral( ...
    t, ...
    latNASA, lonNASA, hNASA, ...
    deltaT, t0TT, coeffs, ...
    tanF1, tanF2, ...
    "total");


%% ---------------------------------------------------------
% Buscar C1
% ---------------------------------------------------------

fC1 = @(dt) partialResidual( ...
    tC1_NASA + seconds(dt));

dtC1 = fzero(fC1, [-30 30]);

tC1_calc_NASA = tC1_NASA + seconds(dtC1);


%% ---------------------------------------------------------
% Buscar C2
% ---------------------------------------------------------

fC2 = @(dt) totalResidual( ...
    tC2_NASA + seconds(dt));

dtC2 = fzero(fC2, [-30 30]);

tC2_calc_NASA = tC2_NASA + seconds(dtC2);


%% ---------------------------------------------------------
% Buscar C3
% ---------------------------------------------------------

fC3 = @(dt) totalResidual( ...
    tC3_NASA + seconds(dt));

dtC3 = fzero(fC3, [-30 30]);

tC3_calc_NASA = tC3_NASA + seconds(dtC3);


%% ---------------------------------------------------------
% Buscar C4
% ---------------------------------------------------------

fC4 = @(dt) partialResidual( ...
    tC4_NASA + seconds(dt));

dtC4 = fzero(fC4, [-30 30]);

tC4_calc_NASA = tC4_NASA + seconds(dtC4);


%% ---------------------------------------------------------
% Buscar maximo local
%
% Como primer diagnostico buscamos el minimo de rho.
% ---------------------------------------------------------

fMax = @(dt) eclipseLocalRho( ...
    tMax_NASA + seconds(dt), ...
    latNASA, lonNASA, hNASA, ...
    deltaT, t0TT, coeffs, ...
    tanF1, tanF2);

dtMax = fminbnd(fMax, -60, 60);

tMax_calc_NASA = tMax_NASA + seconds(dtMax);


%% ---------------------------------------------------------
% Errores
% ---------------------------------------------------------

errC1_NASA = seconds(tC1_calc_NASA - tC1_NASA);
errC2_NASA = seconds(tC2_calc_NASA - tC2_NASA);
errMax_NASA = seconds(tMax_calc_NASA - tMax_NASA);
errC3_NASA = seconds(tC3_calc_NASA - tC3_NASA);
errC4_NASA = seconds(tC4_calc_NASA - tC4_NASA);


%% ---------------------------------------------------------
% Mostrar resultados
% ---------------------------------------------------------

fprintf('\n');
fprintf('Evento       NASA             Calculado          Error\n');
fprintf('----------------------------------------------------------\n');

fprintf('C1       %s     %s     %+8.3f s\n', ...
    string(tC1_NASA,'HH:mm:ss.SSS'), ...
    string(tC1_calc_NASA,'HH:mm:ss.SSS'), ...
    errC1_NASA);

fprintf('C2       %s     %s     %+8.3f s\n', ...
    string(tC2_NASA,'HH:mm:ss.SSS'), ...
    string(tC2_calc_NASA,'HH:mm:ss.SSS'), ...
    errC2_NASA);

fprintf('MAX      %s     %s     %+8.3f s\n', ...
    string(tMax_NASA,'HH:mm:ss.SSS'), ...
    string(tMax_calc_NASA,'HH:mm:ss.SSS'), ...
    errMax_NASA);

fprintf('C3       %s     %s     %+8.3f s\n', ...
    string(tC3_NASA,'HH:mm:ss.SSS'), ...
    string(tC3_calc_NASA,'HH:mm:ss.SSS'), ...
    errC3_NASA);

fprintf('C4       %s     %s     %+8.3f s\n', ...
    string(tC4_NASA,'HH:mm:ss.SSS'), ...
    string(tC4_calc_NASA,'HH:mm:ss.SSS'), ...
    errC4_NASA);


%% Duracion de la totalidad

durationNASA = seconds(tC3_NASA - tC2_NASA);
durationCalc = seconds(tC3_calc_NASA - tC2_calc_NASA);

fprintf('\n');

fprintf('Duracion totalidad NASA      : %.3f s\n', ...
    durationNASA);

fprintf('Duracion totalidad calculada : %.3f s\n', ...
    durationCalc);

fprintf('Error de duracion            : %+.3f s\n', ...
    durationCalc - durationNASA);


%% Resumen

errorsNASA = [ ...
    errC1_NASA, ...
    errC2_NASA, ...
    errMax_NASA, ...
    errC3_NASA, ...
    errC4_NASA];

fprintf('\n');

fprintf('Error medio absoluto         : %.3f s\n', ...
    mean(abs(errorsNASA)));

fprintf('Error maximo absoluto        : %.3f s\n', ...
    max(abs(errorsNASA)));

fprintf('\n');


fprintf('\nVALIDACION COMPLETADA\n');

%%

function residual = eclipseContactResidualGeneral( ...
    tUT, lat, lon, h, ...
    deltaT, t0TT, coeffs, ...
    tanF1, tanF2, contactType)
%ECLIPSECONTACTRESIDUALGENERAL Residuo para contactos de eclipse.
%
%   Para C1/C4:
%
%       residual = rho - L1
%
%   Para C2/C3:
%
%       residual = rho - |L2|
%
%   Una raiz del residuo corresponde al contacto geometrico.

    % UT -> TT según el DeltaT adoptado por NASA
    tTT = tUT + seconds(deltaT);

    % Elementos besselianos
    elements = evaluateBesselElements( ...
        tTT, t0TT, coeffs);

    % Coordenadas besselianas del observador
    [xi, eta, zeta] = observerBesselCoordinates( ...
        lat, lon, h, ...
        elements.d, elements.mu);

    % Geometria local
    geom = localEclipseGeometry( ...
        elements, ...
        xi, eta, zeta, ...
        tanF1, tanF2);

    switch contactType

        case "partial"
            residual = geom.rho - geom.L1;

        case "total"
            residual = geom.rho - abs(geom.L2);

        otherwise
            error('Tipo de contacto no reconocido.');

    end

end

function rho = eclipseLocalRho( ...
    tUT, lat, lon, h, ...
    deltaT, t0TT, coeffs, ...
    tanF1, tanF2)
%ECLIPSELOCALRHO Calcula la separacion local rho.
%
%   Se utiliza como funcion objetivo para localizar aproximadamente
%   el instante de maxima aproximacion al eje de la sombra.

    % UT -> TT
    tTT = tUT + seconds(deltaT);

    % Elementos besselianos
    elements = evaluateBesselElements( ...
        tTT, t0TT, coeffs);

    % Coordenadas besselianas del observador
    [xi, eta, zeta] = observerBesselCoordinates( ...
        lat, lon, h, ...
        elements.d, elements.mu);

    % Geometria local
    geom = localEclipseGeometry( ...
        elements, ...
        xi, eta, zeta, ...
        tanF1, tanF2);

    rho = geom.rho;

end

function residual = eclipseContactResidual( ...
    tUTC, lat, lon, h, ...
    deltaT, t0TT, coeffs, ...
    tanF1, tanF2)
%ECLIPSECONTACTRESIDUAL Residuo geométrico para los contactos C2/C3.
%
%   RESIDUAL = rho - |L2|
%
%   La raíz RESIDUAL = 0 corresponde, dentro del modelo utilizado,
%   al cruce del observador con el límite de la umbra.

    % UTC -> TT
    tTT = utc2TT(tUTC, deltaT);

    % Elementos besselianos
    elements = evaluateBesselElements(tTT, t0TT, coeffs);

    % Posición besseliana del observador
    [xi, eta, zeta] = observerBesselCoordinates( ...
        lat, lon, h, ...
        elements.d, elements.mu);

    % Geometría local
    geom = localEclipseGeometry( ...
        elements, xi, eta, zeta, ...
        tanF1, tanF2);

    % Condición de contacto con la umbra
    residual = geom.rho - abs(geom.L2);

end