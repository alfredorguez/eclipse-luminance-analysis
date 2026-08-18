function timestampTT = utc2TT(timestampUTC, deltaT)
%UTCTOTT Convierte un instante UTC/UT a Tiempo Terrestre TT.
%
%   TIMESTAMPTT = UTCTOTT(TIMESTAMPUTC, DELTAT)
%   convierte un instante expresado en tiempo universal a Tiempo
%   Terrestre (TT), utilizando el valor de Delta T correspondiente.
%
%   Autor: Alfredo Rodríguez Magdalena ©
%   Fecha: 15/08/2026
%
%   ENTRADAS
%       timestampUTC - Instante o vector de instantes [datetime].
%                      Se interpreta como tiempo universal.
%
%       deltaT       - Diferencia entre TT y UT [s]:
%
%                          DeltaT = TT - UT
%
%                      Este valor depende de la fecha y debe proceder de
%                      una fuente astronómica fiable, por ejemplo NASA.
%
%   SALIDA
%       timestampTT  - Instante equivalente expresado en TT [datetime].
%
%   ECUACIÓN
%
%       TT = UT + DeltaT
%
%   EJEMPLO
%       Para el eclipse del 12 de agosto de 2026 NASA proporciona:
%
%           DeltaT = 75.4 s
%
%       Por tanto:
%
%           tUTC = datetime(2026,8,12,17,45,51);
%           tTT  = utcToTT(tUTC,75.4);
%
%   NOTAS
%       MATLAB no dispone de una escala temporal TT nativa en DATETIME.
%       El objeto DATETIME se utiliza aquí simplemente como contenedor
%       numérico del instante. La variable timestampTT representa
%       conceptualmente Tiempo Terrestre.
%
%       Delta T no es una constante universal: cambia lentamente con el
%       tiempo debido principalmente a las irregularidades de la
%       rotación terrestre.
%
%   UNIDADES
%       timestampUTC : datetime
%       deltaT       : segundos
%       timestampTT  : datetime
%
%   Véase también DATETIME, SECONDS.

    arguments
        timestampUTC datetime
        deltaT double
    end

    timestampTT = timestampUTC + seconds(deltaT);

end