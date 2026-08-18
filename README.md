# Análisis de luminancia durante un eclipse solar total

Análisis experimental de la relación entre la **ocultación teórica del disco solar** y la evolución de la **luminancia aparente** registrada durante el eclipse solar total del **12 de agosto de 2026** desde **Cabo Busto, Asturias (España)**.

El proyecto combina:

- Modelado geométrico del eclipse mediante elementos besselianos de NASA/GSFC.
- Cálculo de la ocultación teórica del disco solar.
- Procesamiento frame a frame de un timelapse.
- Transformación RGB → CIELAB.
- Análisis de la mediana del canal \(L^*\).
- Comparación temporal entre el modelo teórico y el vídeo.

![Comparación entre ocultación y luminancia](docs/figuras/resultado-experimento.png)

---

## Documentación

El desarrollo del proyecto se encuentra dividido en dos documentos:

- 📐 [Modelo teórico del eclipse](docs/modelo-teorico.md)
- 📷 [Procesamiento de imagen](docs/procesamiento-imagen.md)

---

## Estructura

```text
.
├── main.m
├── src/
├── tests/
├── docs/
│   ├── modelo-teorico.md
│   ├── procesamiento-imagen.md
│   └── figuras/
├── README.md
└── LICENSE
```

La carpeta `data/` no se incluye en el repositorio.

---

## Reproducir el experimento

Para reproducir el análisis con otro eclipse solo es necesario modificar la configuración correspondiente en `main.m`.

### 1. Añadir el vídeo

Crea localmente:

```text
data/
└── raw/
    └── timelapse.mp4
```

e indica su ruta:

```matlab
videoPath = 'data/raw/timelapse.mp4';
```

### 2. Configurar el timelapse

Indica su factor de aceleración y la hora local de comienzo:

```matlab
timeLapseFactor = 15;

tVideoStartLocal = datetime(...);
```

### 3. Introducir los datos del eclipse

Sustituye los elementos besselianos por los correspondientes al eclipse que quieras analizar:

```matlab
eclipseData.deltaT = ...;
eclipseData.t0TT   = datetime(...);

eclipseData.coeffs.x  = [...];
eclipseData.coeffs.y  = [...];
eclipseData.coeffs.d  = [...];
eclipseData.coeffs.l1 = [...];
eclipseData.coeffs.l2 = [...];
eclipseData.coeffs.mu = [...];

eclipseData.tanF1 = ...;
eclipseData.tanF2 = ...;
```

Los coeficientes utilizados en este proyecto proceden de NASA/GSFC.

### 4. Indicar la posición del observador

```matlab
lat = ...;
lon = ...;
h   = ...;
```

Finalmente, ajusta el intervalo temporal y los intervalos aproximados de búsqueda de C2 y C3 en `main.m`.

Ejecuta:

```matlab
main
```

---

## Datos de referencia

Los elementos besselianos utilizados para el eclipse solar total del 12 de agosto de 2026 proceden de **NASA/GSFC**.

Las predicciones fueron generadas para el centro de masas de la Luna utilizando las efemérides **VSOP87/ELP2000-82** y un valor de:

$$
\Delta T=75.4\ \mathrm{s}
$$

NASA Eclipse Web Site:  
https://eclipse.gsfc.nasa.gov/

---

## Autor

**Alfredo Rodríguez Magdalena**

© 2026 Alfredo Rodríguez Magdalena

---

## Licencia

El código original de este repositorio se distribuye bajo la [MIT License](LICENSE).

Los elementos besselianos y demás datos astronómicos procedentes de NASA/GSFC se utilizan como datos externos y no constituyen trabajo original del autor.