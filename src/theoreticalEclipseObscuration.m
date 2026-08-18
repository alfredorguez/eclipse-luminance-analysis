function obscuration = theoreticalEclipseObscuration( ...
    lat, lon, h, tUT, eclipseData)
%THEORETICALECLIPSEOBSCURATION Calcula la obscuration teórica de un eclipse.
%
%   OBSCURATION = THEORETICALECLIPSEOBSCURATION( ...
%       LAT, LON, H, TUT, ECLIPSEDATA)
%
%   calcula la fracción teórica del área del disco solar ocultada por
%   la Luna para un observador situado en unas coordenadas determinadas
%   y para uno o varios instantes temporales.
%
%   Autor: Alfredo Rodríguez Magdalena ©
%   Fecha: 17/08/2026
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
%       tUT - Instante o vector de instantes en tiempo universal [datetime].
%
%       eclipseData - Estructura con los parámetros del eclipse:
%
%           .deltaT  - Diferencia TT - UT adoptada para la predicción [s].
%           .t0TT    - Instante de referencia de los polinomios [datetime].
%           .coeffs  - Coeficientes de los elementos besselianos.
%           .tanF1   - Tangente del semiángulo de la penumbra [-].
%           .tanF2   - Tangente del semiángulo de la umbra/antumbra [-].
%
%   SALIDA
%       obscuration - Fracción teórica del área solar ocultada [-].
%
%                     0 -> Sol completamente visible.
%                     1 -> Sol completamente ocultado.
%
%   DESCRIPCIÓN
%       Para cada instante:
%
%       1. Convierte UT a TT mediante deltaT.
%       2. Evalúa los elementos besselianos.
%       3. Calcula las coordenadas besselianas del observador.
%       4. Obtiene la geometría aparente Sol-Luna.
%       5. Calcula el área de intersección de ambos discos.
%
%   El flujo es:
%
%       tUT -> tTT
%            -> elementos besselianos
%            -> posición besseliana del observador
%            -> geometría aparente Sol-Luna
%            -> obscuration
%
%   UNIDADES
%       lat, lon       : grados
%       h              : metros
%       tUT            : datetime
%       obscuration    : adimensional [0,1]

    arguments
        lat         (1,1) double
        lon         (1,1) double
        h           (1,1) double
        tUT         datetime
        eclipseData struct
    end

    %% Inicialización

    obscuration = zeros(size(tUT));


    %% Cálculo para cada instante

    for k = 1:numel(tUT)

        % UT -> TT
        tTT = tUT(k) + seconds(eclipseData.deltaT);


        % Evaluación de los elementos besselianos
        elements = evaluateBesselElements( ...
            tTT, ...
            eclipseData.t0TT, ...
            eclipseData.coeffs);


        % Coordenadas besselianas del observador
        [xi, eta, zeta] = observerBesselCoordinates( ...
            lat, lon, h, ...
            elements.d, ...
            elements.mu);


        % Geometría aparente Sol-Luna
        geomApp = apparentSunMoonGeometry( ...
            elements, ...
            xi, eta, zeta, ...
            eclipseData.tanF1, ...
            eclipseData.tanF2);


        % Fracción del disco solar ocultada
        obscuration(k) = circleOverlapFraction( ...
            geomApp.Rsun, ...
            geomApp.Rmoon, ...
            geomApp.separation);

    end

end