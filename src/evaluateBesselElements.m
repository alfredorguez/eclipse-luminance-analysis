function elements = evaluateBesselElements(timestampTT, t0TT, coeffs)
%EVALUATEBESSELELEMENTS Evalúa los elementos besselianos en un instante dado.
%
%   ELEMENTS = EVALUATEBESSELELEMENTS(TIMESTAMPTT, T0TT, COEFFS)
%   evalúa los polinomios de los elementos besselianos x, y, d, l1, l2 y mu
%   en el instante TIMESTAMPTT.
%
%   La función es independiente de un eclipse concreto. Los coeficientes
%   polinómicos deben proporcionarse mediante la estructura COEFFS.
%
%   Autor: Alfredo Rodríguez Magdalena ©
%   Fecha: 15/08/2026
%
%   ENTRADAS
%       timestampTT - Instante en el que se quieren evaluar los elementos.
%                     Debe estar expresado en TT/TDT [datetime].
%
%       t0TT        - Instante de referencia de los polinomios [datetime].
%                     Por ejemplo, NASA puede indicar:
%
%                         2026 Aug 12 18.000 TDT (= t0)
%
%       coeffs      - Estructura con los coeficientes de los polinomios:
%
%                         coeffs.x
%                         coeffs.y
%                         coeffs.d
%                         coeffs.l1
%                         coeffs.l2
%                         coeffs.mu
%
%                     Los coeficientes deben almacenarse en el orden que
%                     espera POLYVAL:
%
%                         [a3 a2 a1 a0]
%
%                     para un polinomio:
%
%                         a(t) = a0 + a1*t + a2*t^2 + a3*t^3
%
%                     Si un elemento tiene menor grado, se pueden omitir
%                     los coeficientes iniciales nulos. Por ejemplo:
%
%                         [a1 a0]
%
%                     representa:
%
%                         a(t) = a0 + a1*t
%
%   SALIDA
%       elements - Estructura con los elementos besselianos evaluados:
%
%                      elements.x
%                      elements.y
%                      elements.d
%                      elements.l1
%                      elements.l2
%                      elements.mu
%
%                  También incluye:
%
%                      elements.t
%
%                  que representa el tiempo transcurrido desde t0,
%                  expresado en horas decimales.
%
%   UNIDADES
%       t              : horas desde t0
%       x, y           : radios ecuatoriales terrestres
%       d, mu          : grados
%       l1, l2         : radios ecuatoriales terrestres
%
%   NOTA
%       TIMESTAMPTT y T0TT deben pertenecer a la misma escala temporal
%       (TT/TDT). Esta función no realiza conversiones UTC -> TT.
%
%   Véase también POLYVAL, DATETIME, HOURS.

    arguments
        timestampTT datetime
        t0TT (1,1) datetime
        coeffs struct
    end

    %% Tiempo desde la época de referencia

    % POLYVAL utiliza una variable numérica. Los elementos besselianos de
    % NASA se expresan normalmente como polinomios en horas decimales
    % respecto a t0.
    t = hours(timestampTT - t0TT);

    %% Evaluación de los polinomios

    elements.x  = polyval(coeffs.x,  t);
    elements.y  = polyval(coeffs.y,  t);
    elements.d  = polyval(coeffs.d,  t);
    elements.l1 = polyval(coeffs.l1, t);
    elements.l2 = polyval(coeffs.l2, t);
    elements.mu = polyval(coeffs.mu, t);

    %% Información auxiliar

    elements.t = t;

end