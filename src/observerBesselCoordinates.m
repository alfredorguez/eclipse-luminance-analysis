function [xi, eta, zeta] = observerBesselCoordinates(lat, lon, h, d, mu)
%OBSERVERBESSELCOORDINATES Calcula las coordenadas besselianas del observador.
%
%   [XI, ETA, ZETA] = OBSERVERBESSELCOORDINATES(LAT, LON, H, D, MU)
%   transforma las coordenadas geodésicas de un observador situado sobre
%   el elipsoide WGS84 al sistema de coordenadas besseliano asociado al
%   plano fundamental de un eclipse solar.
%
%   Autor: Alfredo Rodríguez Magdalena ©
%   Fecha: 15/08/2026
%
%   ENTRADAS
%       lat - Latitud geodésica del observador [grados].
%             Positiva hacia el norte y negativa hacia el sur.
%
%       lon - Longitud geodésica del observador [grados].
%             Positiva hacia el este y negativa hacia el oeste.
%
%       h   - Altura del observador sobre el elipsoide WGS84 [m].
%
%       d   - Declinación del eje de la sombra [grados].
%             Es uno de los elementos besselianos proporcionados por NASA.
%
%       mu  - Ángulo horario besseliano [grados].
%             Es uno de los elementos besselianos proporcionados por NASA.
%
%       deltaT - Diferencia entre relojes TT y UT1
%
%   SALIDAS
%       xi   - Primera coordenada del observador proyectado sobre el
%              plano fundamental [radios ecuatoriales terrestres].
%
%       eta  - Segunda coordenada del observador proyectado sobre el
%              plano fundamental [radios ecuatoriales terrestres].
%
%       zeta - Coordenada del observador perpendicular al plano
%              fundamental y paralela al eje de la sombra
%              [radios ecuatoriales terrestres].
%
%   DESCRIPCIÓN
%       1. Modela la Tierra mediante el elipsoide WGS84.
%       2. Convierte la latitud geodésica en componentes geocéntricas
%          normalizadas por el radio ecuatorial terrestre.
%       3. Rota dichas componentes al sistema besseliano mediante d, mu
%          y la longitud geográfica del observador.
%
%   CONVENCIÓN
%       Esta función usa la convención IAU:
%
%           longitud este  > 0
%           longitud oeste < 0
%
%       NASA indica esta misma convención para sus predicciones modernas.
%
%   UNIDADES
%       lat, lon, d, mu : grados
%       h               : metros
%       xi, eta, zeta   : radios ecuatoriales terrestres
%
%   NOTA
%       Esta implementación utiliza longitud positiva hacia el este.
%       Debe verificarse que esta convención coincide con la utilizada
%       en los elementos besselianos antes de realizar predicciones
%       definitivas del eclipse.

    arguments
        lat (1,1) double
        lon (1,1) double
        h   (1,1) double
        d   (1,1) double
        mu  (1,1) double
    end

    %% Elipsoide de referencia WGS84

    % Semieje mayor (radio ecuatorial) [m]
    a = 6378137.0;

    % Achatamiento [-]
    f = 1 / 298.257223563;

    % Primera excentricidad al cuadrado [-]
    e2 = f * (2 - f);


    %% Conversión de los ángulos a radianes

    phi    = deg2rad(lat);
    lambda = deg2rad(lon);
    d      = deg2rad(d);
    mu     = deg2rad(mu);


    %% Posición del observador sobre el elipsoide WGS84

    % Radio de curvatura del primer vertical [m]
    N = a / sqrt(1 - e2 * sin(phi)^2);

    % Componentes geocéntricas normalizadas respecto al
    % radio ecuatorial terrestre [-]
    rhoCosPhi = ((N + h) / a) * cos(phi);

    rhoSinPhi = ((N * (1 - e2) + h) / a) * sin(phi);


    %% Transformación al sistema de referencia besseliano

    % Ángulo horario local respecto al sistema besseliano [rad]
    H = mu + lambda;

    % Coordenadas besselianas del observador
    xi = rhoCosPhi * sin(H);

    eta = rhoSinPhi * cos(d) ...
        - rhoCosPhi * cos(H) * sin(d);

    zeta = rhoSinPhi * sin(d) ...
         + rhoCosPhi * cos(H) * cos(d);
end