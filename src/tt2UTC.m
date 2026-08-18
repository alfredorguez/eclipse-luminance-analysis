function timestampUTC = tt2UTC(timestampTT, deltaT)
%TTTOUTC Convierte un instante en Tiempo Terrestre TT a UTC/UT.
%
%   TIMESTAMPUTC = TTTOUTC(TIMESTAMPTT, DELTAT)
%   convierte un instante expresado en Tiempo Terrestre a tiempo
%   universal utilizando:
%
%       UT = TT - DeltaT
%
%   Autor: Alfredo Rodríguez Magdalena ©
%   Fecha: 15/08/2026
%
%   ENTRADAS
%       timestampTT - Instante o vector de instantes en TT [datetime].
%
%       deltaT      - Diferencia TT - UT [s].
%
%   SALIDA
%       timestampUTC - Instante equivalente en UT/UTC [datetime].
%
%   Véase también UTCTOTT, DATETIME, SECONDS.

    arguments
        timestampTT datetime
        deltaT double
    end

    timestampUTC = timestampTT - seconds(deltaT);

end