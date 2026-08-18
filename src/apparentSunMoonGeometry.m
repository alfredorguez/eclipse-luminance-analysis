function geom = apparentSunMoonGeometry( ...
    elements, xi, eta, zeta, tanF1, tanF2)
%APPARENTSUNMOONGEOMETRY Calcula la geometría aparente Sol-Luna.
%
%   GEOM = APPARENTSUNMOONGEOMETRY( ...
%       ELEMENTS, XI, ETA, ZETA, TANF1, TANF2)
%
%   obtiene una representación equivalente de los discos aparentes del
%   Sol y la Luna en el plano del observador a partir de los elementos
%   besselianos y de la posición besseliana del observador.
%
%   La geometría resultante puede utilizarse directamente para calcular
%   la fracción del disco solar ocultada mediante la intersección de dos
%   círculos.
%
%   Autor: Alfredo Rodríguez Magdalena ©
%   Fecha: 17/08/2026
%
%   ENTRADAS
%       elements - Estructura con los elementos besselianos evaluados
%                  en el instante considerado. Debe contener:
%
%                      elements.x
%                      elements.y
%                      elements.l1
%                      elements.l2
%
%       xi       - Primera coordenada besseliana del observador
%                  [radios ecuatoriales terrestres].
%
%       eta      - Segunda coordenada besseliana del observador
%                  [radios ecuatoriales terrestres].
%
%       zeta     - Coordenada del observador perpendicular al plano
%                  fundamental [radios ecuatoriales terrestres].
%
%       tanF1    - Tangente del semiángulo del cono de penumbra [-].
%
%       tanF2    - Tangente del semiángulo del cono de
%                  umbra/antumbra [-].
%
%   SALIDA
%       geom - Estructura con:
%
%           geom.Rsun
%               Radio efectivo del disco solar en el plano del
%               observador [radios ecuatoriales terrestres].
%
%           geom.Rmoon
%               Radio efectivo del disco lunar en el plano del
%               observador [radios ecuatoriales terrestres].
%
%           geom.separation
%               Separación entre los centros aparentes del Sol y
%               la Luna [radios ecuatoriales terrestres].
%
%           geom.L1
%               Radio local de la penumbra.
%
%           geom.L2
%               Radio local firmado de la umbra/antumbra.
%
%           geom.rho
%               Distancia transversal entre el observador y el eje
%               de la sombra.
%
%   RELACIONES
%
%       L1 = Rsun + Rmoon
%
%       L2 = Rsun - Rmoon
%
%   por lo que:
%
%       Rsun  = (L1 + L2)/2
%
%       Rmoon = (L1 - L2)/2
%
%   Además:
%
%       separation = rho
%
%   INTERPRETACIÓN DEL SIGNO DE L2
%
%       L2 < 0  -> Rmoon > Rsun -> eclipse total
%
%       L2 > 0  -> Rmoon < Rsun -> eclipse anular
%
%   NOTA
%       Rsun y Rmoon no son radios angulares expresados en grados o
%       radianes. Son radios efectivos en el plano del observador,
%       expresados en la misma unidad besseliana que L1, L2 y rho.
%
%       Como circleOverlapFraction() solo necesita que radios y
%       separación estén expresados en las mismas unidades, esta
%       representación es suficiente para calcular la obscuration.
%
%   Véase también LOCALECLIPSEGEOMETRY, CIRCLEOVERLAPFRACTION.

    arguments
        elements struct
        xi      (1,1) double
        eta     (1,1) double
        zeta    (1,1) double
        tanF1   (1,1) double
        tanF2   (1,1) double
    end


    %% Geometría local de la sombra

    localGeom = localEclipseGeometry( ...
        elements, ...
        xi, eta, zeta, ...
        tanF1, tanF2);

    L1  = localGeom.L1;
    L2  = localGeom.L2;
    rho = localGeom.rho;


    %% Radios efectivos de los discos aparentes

    Rsun = (L1 + L2) / 2;

    Rmoon = (L1 - L2) / 2;


    %% Separación aparente entre centros

    separation = rho;


    %% Comprobaciones

    if Rsun <= 0
        error('El radio solar calculado no es positivo.');
    end

    if Rmoon <= 0
        error('El radio lunar calculado no es positivo.');
    end


    %% Salida

    geom.Rsun       = Rsun;
    geom.Rmoon      = Rmoon;
    geom.separation = separation;

    % Información auxiliar útil para diagnóstico
    geom.L1  = L1;
    geom.L2  = L2;
    geom.rho = rho;

end