%% TEST_GEOMETRIA_APARENTE
%
% Validación de apparentSunMoonGeometry() contra las circunstancias
% locales publicadas por NASA para el eclipse total del 12/08/2026.
%
% Dataset NASA:
%   VSOP87 / ELP2000-82
%   DeltaT = 75.4 s
%
% Punto de referencia:
%   Latitud  = 41.8940 deg
%   Longitud = -5.3802 deg
%
% El test comprueba:
%   1. Contactos exteriores C1/C4:
%          separation = Rsun + Rmoon
%
%   2. Contactos interiores C2/C3:
%          separation = |Rmoon - Rsun|
%
%   3. En el máximo:
%          Rmoon > Rsun
%          separation < Rmoon - Rsun
%
%   4. La obscuration calculada en el máximo es 1.
%

clear;
clc;

fprintf('\nVALIDACION DE LA GEOMETRIA APARENTE SOL-LUNA\n');
fprintf('============================================\n\n');


%% =========================================================
% 1. Datos del eclipse NASA
% ==========================================================

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


%% =========================================================
% 2. Punto de referencia NASA
% ==========================================================

lat = 41.8940;
lon = -5.3802;  % Este positivo, oeste negativo
h   = 0;        % [m]


%% =========================================================
% 3. Circunstancias locales NASA [UT]
% ==========================================================

tC1  = datetime(2026,8,12,17,33,56.4);
tC2  = datetime(2026,8,12,18,29,33.6);
tMax = datetime(2026,8,12,18,30,15.3);
tC3  = datetime(2026,8,12,18,30,56.8);
tC4  = datetime(2026,8,12,19,23,00.2);

timesUT = [tC1, tC2, tMax, tC3, tC4];

labels = ["C1", "C2", "MAX", "C3", "C4"];


%% =========================================================
% 4. Evaluar geometría aparente
% ==========================================================

Rsun        = zeros(1,5);
Rmoon       = zeros(1,5);
separation  = zeros(1,5);
resExternal = zeros(1,5);
resInternal = zeros(1,5);
obscuration = zeros(1,5);

fprintf('Evento      Rsun       Rmoon       sep        ResExt      ResInt      O\n');
fprintf('----------------------------------------------------------------------------\n');

for k = 1:numel(timesUT)

    % UT -> TT
    tTT = timesUT(k) + seconds(deltaT);

    % Elementos besselianos
    elements = evaluateBesselElements( ...
        tTT, t0TT, coeffs);

    % Coordenadas besselianas del observador
    [xi, eta, zeta] = observerBesselCoordinates( ...
        lat, lon, h, ...
        elements.d, elements.mu);

    % Geometría aparente Sol-Luna
    geomApp = apparentSunMoonGeometry( ...
        elements, ...
        xi, eta, zeta, ...
        tanF1, tanF2);

    Rsun(k)       = geomApp.Rsun;
    Rmoon(k)      = geomApp.Rmoon;
    separation(k) = geomApp.separation;

    % Residuo de contacto exterior
    resExternal(k) = ...
        geomApp.separation - ...
        (geomApp.Rsun + geomApp.Rmoon);

    % Residuo de contacto interior
    resInternal(k) = ...
        geomApp.separation - ...
        abs(geomApp.Rmoon - geomApp.Rsun);

    % Obscuration
    obscuration(k) = circleOverlapFraction( ...
        geomApp.Rsun, ...
        geomApp.Rmoon, ...
        geomApp.separation);

    fprintf('%-4s    %9.6f  %9.6f  %9.6f  %+10.6f  %+10.6f  %.6f\n', ...
        labels(k), ...
        geomApp.Rsun, ...
        geomApp.Rmoon, ...
        geomApp.separation, ...
        resExternal(k), ...
        resInternal(k), ...
        obscuration(k));

end


%% =========================================================
% 5. Comprobaciones geométricas
% ==========================================================

tolGeometry = 2e-3;

fprintf('\nCOMPROBACIONES\n');
fprintf('--------------\n');

% C1 y C4 -> contacto exterior
assert(abs(resExternal(1)) < tolGeometry, ...
    'C1 no cumple la condición de contacto exterior.');

assert(abs(resExternal(5)) < tolGeometry, ...
    'C4 no cumple la condición de contacto exterior.');

fprintf('C1/C4 -> contacto exterior: OK\n');


% C2 y C3 -> contacto interior
assert(abs(resInternal(2)) < tolGeometry, ...
    'C2 no cumple la condición de contacto interior.');

assert(abs(resInternal(4)) < tolGeometry, ...
    'C3 no cumple la condición de contacto interior.');

fprintf('C2/C3 -> contacto interior: OK\n');


% En el máximo, la Luna debe ser mayor que el Sol
assert(Rmoon(3) > Rsun(3), ...
    'En el máximo la Luna no aparece mayor que el Sol.');

fprintf('Rmoon > Rsun en el máximo: OK\n');


% En el máximo debe haber totalidad
assert(separation(3) < (Rmoon(3) - Rsun(3)), ...
    'La geometría del máximo no corresponde a totalidad.');

fprintf('Separación compatible con totalidad: OK\n');


% El máximo debe tener la menor separación entre los cinco hitos
assert(separation(3) == min(separation), ...
    'El máximo no presenta la menor separación.');

fprintf('Separación mínima en el máximo: OK\n');


%% =========================================================
% 6. Comprobación de obscuration
% ==========================================================

tolObscuration = 1e-10;

assert(abs(obscuration(3) - 1) < tolObscuration, ...
    'La obscuration en el máximo no es 1.');

fprintf('Obscuration máxima = 1: OK\n');


%% =========================================================
% 7. Resumen
% ==========================================================

fprintf('\nRESUMEN\n');
fprintf('-------\n');

fprintf('Obscuration C1  : %.8f\n', obscuration(1));
fprintf('Obscuration C2  : %.8f\n', obscuration(2));
fprintf('Obscuration MAX : %.8f\n', obscuration(3));
fprintf('Obscuration C3  : %.8f\n', obscuration(4));
fprintf('Obscuration C4  : %.8f\n', obscuration(5));

fprintf('\nVALIDACION COMPLETADA\n');