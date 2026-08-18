function geom = localEclipseGeometry(elements, xi, eta, zeta, tanF1, tanF2)
%LOCALECLIPSEGEOMETRY Calcula la geometría local de un eclipse solar.
%
%   GEOM = LOCALECLIPSEGEOMETRY(ELEMENTS, XI, ETA, ZETA, TANF1, TANF2)
%   calcula la posición relativa del observador respecto al eje de la
%   sombra lunar y los radios locales de penumbra y umbra/antumbra.
%
%   Autor: Alfredo Rodríguez Magdalena ©
%   Fecha: 15/08/2026
%
%   ENTRADAS
%       elements - Estructura con los elementos besselianos evaluados
%                  para el instante considerado. Debe contener:
%
%                      elements.x
%                      elements.y
%                      elements.l1
%                      elements.l2
%
%                  x, y  : coordenadas del eje de la sombra sobre el
%                          plano fundamental
%                          [radios ecuatoriales terrestres].
%
%                  l1    : radio de referencia de la penumbra sobre el
%                          plano fundamental
%                          [radios ecuatoriales terrestres].
%
%                  l2    : radio de referencia de la umbra/antumbra
%                          sobre el plano fundamental
%                          [radios ecuatoriales terrestres].
%
%       xi      - Primera coordenada besseliana del observador
%                 [radios ecuatoriales terrestres].
%
%       eta     - Segunda coordenada besseliana del observador
%                 [radios ecuatoriales terrestres].
%
%       zeta    - Coordenada del observador perpendicular al plano
%                 fundamental, paralela al eje de la sombra
%                 [radios ecuatoriales terrestres].
%
%       tanF1   - Tangente del semiángulo del cono de penumbra [-].
%
%       tanF2   - Tangente del semiángulo del cono de umbra/antumbra [-].
%
%   SALIDA
%       geom - Estructura con:
%
%           geom.u
%               Diferencia en la primera coordenada del plano fundamental:
%
%                   u = x - xi
%
%               [radios ecuatoriales terrestres].
%
%           geom.v
%               Diferencia en la segunda coordenada:
%
%                   v = y - eta
%
%               [radios ecuatoriales terrestres].
%
%           geom.rho
%               Distancia transversal entre la proyección del observador
%               y el eje de la sombra:
%
%                   rho = sqrt(u^2 + v^2)
%
%               [radios ecuatoriales terrestres].
%
%           geom.L1
%               Radio local de la penumbra en la sección del cono que
%               contiene al observador
%               [radios ecuatoriales terrestres].
%
%           geom.L2
%               Radio local firmado de la umbra/antumbra
%               [radios ecuatoriales terrestres].
%
%   INTERPRETACIÓN
%       rho describe a qué distancia lateral se encuentra el observador
%       del eje de la sombra.
%
%       zeta indica la posición del observador a lo largo del eje de la
%       sombra. Debido a que penumbra y umbra son conos y no cilindros,
%       sus radios cambian con zeta.
%
%   UNIDADES
%       x, y, xi, eta, zeta, l1, l2, L1, L2, rho :
%           radios ecuatoriales terrestres
%
%       tanF1, tanF2 :
%           adimensionales
%
%   Véase también EVALUATEBESSELELEMENTS,
%   OBSERVERBESSELCOORDINATES.

    arguments
        elements struct
        xi      double
        eta     double
        zeta    double
        tanF1   double
        tanF2   double
    end

    %% Posición relativa observador - eje de la sombra

    u = elements.x - xi;
    v = elements.y - eta;

    % Distancia transversal al eje de la sombra
    rho = hypot(u, v);


    %% Radios locales de los conos de sombra

    % Debido a la geometría cónica, el radio observado cambia con la
    % distancia axial zeta respecto al plano fundamental.
    L1 = elements.l1 - zeta .* tanF1;
    L2 = elements.l2 - zeta .* tanF2;


    %% Salida

    geom.u   = u;
    geom.v   = v;
    geom.rho = rho;

    geom.L1  = L1;
    geom.L2  = L2;

end