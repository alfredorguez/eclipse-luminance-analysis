function obscuration = circleOverlapFraction(Rsun, Rmoon, separation)
%CIRCLEOVERLAPFRACTION Calcula la fracción del disco solar ocultada.
%
%   OBSCURATION = CIRCLEOVERLAPFRACTION(RSUN, RMOON, SEPARATION)
%   calcula la fracción del área aparente del disco solar que queda
%   cubierta por el disco lunar.
%
%   Autor: Alfredo Rodríguez Magdalena
%   Fecha: 16(08/2026
%
%   ENTRADAS
%       Rsun       - Radio aparente del Sol.
%       Rmoon      - Radio aparente de la Luna.
%       separation - Distancia entre los centros aparentes del Sol
%                    y la Luna.
%
%       Las tres magnitudes deben expresarse en las mismas unidades.
%
%   SALIDA
%       obscuration - Fracción del área solar ocultada [-].
%
%                     0 -> Sol completamente visible
%                     1 -> Sol completamente ocultado
%
%   NOTA
%       La función es puramente geométrica y no depende de ningún
%       eclipse concreto ni de los elementos besselianos.

    arguments
        Rsun       (1,1) double {mustBePositive}
        Rmoon      (1,1) double {mustBePositive}
        separation (1,1) double {mustBeNonnegative}
    end

    %% Caso 1: discos separados

    if separation >= Rsun + Rmoon

        obscuration = 0;
        return

    end


    %% Caso 2: un disco está completamente contenido en el otro

    if separation <= abs(Rmoon - Rsun)

        % Si la Luna es igual o mayor que el Sol, hay ocultación total
        if Rmoon >= Rsun
            obscuration = 1;

        % Si la Luna es menor, tenemos un eclipse anular y el área
        % ocultada es simplemente el área completa de la Luna
        else
            obscuration = (Rmoon / Rsun)^2;
        end

        return

    end


    %% Caso 3: intersección parcial de los dos discos

    d = separation;

    alpha = acos( ...
        (d^2 + Rsun^2 - Rmoon^2) / ...
        (2 * d * Rsun));

    beta = acos( ...
        (d^2 + Rmoon^2 - Rsun^2) / ...
        (2 * d * Rmoon));

    radical = ...
        (-d + Rsun + Rmoon) * ...
        ( d + Rsun - Rmoon) * ...
        ( d - Rsun + Rmoon) * ...
        ( d + Rsun + Rmoon);

    overlapArea = ...
        Rsun^2  * alpha + ...
        Rmoon^2 * beta  - ...
        0.5 * sqrt(max(0, radical));


    %% Normalización respecto al área solar

    solarArea = pi * Rsun^2;

    obscuration = overlapArea / solarArea;

end