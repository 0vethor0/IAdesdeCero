// ============================================================
//  AlgoritmoGenetico.pde  —  Motor evolutivo de la IA
//  Implementa: selección por fitness, cruce de pesos,
//              mutación gaussiana (igual al repo de Fiorino)
//  Cada "gen" es el array completo de pesos de una RedNeuronal
// ============================================================

class AlgoritmoGenetico {

  int    tamanioPoblacion;
  float  tasaMutacion    = 0.10;  // 10% de pesos mutan por generación
  float  fuerzaMutacion  = 0.20;  // desviación estándar de la mutación

  // ──────────────────────────────────────────
  //  Constructor
  // ──────────────────────────────────────────
  AlgoritmoGenetico(int tamanioPoblacion) {
    this.tamanioPoblacion = tamanioPoblacion;
  }

  // ──────────────────────────────────────────
  //  Crear nueva generación a partir de la
  //  población actual con sus puntajes (fitness)
  //
  //  Proceso:
  //  1. Ordenar por fitness descendente
  //  2. Élite: copiar directamente los 2 mejores
  //  3. Resto: selección por ruleta + cruce + mutación
  // ──────────────────────────────────────────
  RedNeuronal[] evolucionarPoblacion(RedNeuronal[] redes, float[] puntajes) {
    RedNeuronal[] nuevaGeneracion = new RedNeuronal[tamanioPoblacion];

    // Ordenar índices por puntaje descendente (bubble sort simple)
    int[] indicesOrdenados = ordenarPorPuntaje(puntajes);

    // Élite: los 2 mejores pasan directos sin mutación
    int cantElite = 2;
    for (int i = 0; i < cantElite; i++) {
      nuevaGeneracion[i] = new RedNeuronal(redes[indicesOrdenados[i]]);
    }

    // Resto de la población: cruce + mutación
    for (int i = cantElite; i < tamanioPoblacion; i++) {
      // Seleccionar dos padres por ruleta de aptitud
      int indicePadreA = seleccionRuleta(puntajes);
      int indicePadreB = seleccionRuleta(puntajes);

      // Cruce de pesos entre padre A y padre B
      RedNeuronal hijo = cruzar(redes[indicePadreA], redes[indicePadreB]);

      // Mutar al hijo
      mutar(hijo);

      nuevaGeneracion[i] = hijo;
    }

    return nuevaGeneracion;
  }

  // ──────────────────────────────────────────
  //  Selección por ruleta de aptitud
  //  Los individuos con mayor puntaje tienen
  //  mayor probabilidad de ser elegidos
  // ──────────────────────────────────────────
  int seleccionRuleta(float[] puntajes) {
    float sumaTotal = 0;
    for (float p : puntajes) sumaTotal += max(p, 0);

    if (sumaTotal == 0) return int(random(puntajes.length));

    float ruleta = random(sumaTotal);
    float acumulado = 0;
    for (int i = 0; i < puntajes.length; i++) {
      acumulado += max(puntajes[i], 0);
      if (acumulado >= ruleta) return i;
    }
    return puntajes.length - 1;
  }

  // ──────────────────────────────────────────
  //  Cruce de pesos (crossover uniforme)
  //  Cada peso tiene 50% de probabilidad de
  //  venir del padre A o del padre B
  // ──────────────────────────────────────────
  RedNeuronal cruzar(RedNeuronal padreA, RedNeuronal padreB) {
    RedNeuronal hijo = new RedNeuronal(padreA); // empieza como copia de A

    // Cruzar pesos entrada → oculta
    for (int i = 0; i < hijo.cantEntradas; i++)
      for (int j = 0; j < hijo.cantOcultas; j++)
        if (random(1) < 0.5)
          hijo.pesosEntradaOculta[i][j] = padreB.pesosEntradaOculta[i][j];

    // Cruzar sesgos ocultos
    for (int j = 0; j < hijo.cantOcultas; j++)
      if (random(1) < 0.5)
        hijo.sesgosOculta[j] = padreB.sesgosOculta[j];

    // Cruzar pesos oculta → salida
    for (int j = 0; j < hijo.cantOcultas; j++)
      for (int k = 0; k < hijo.cantSalidas; k++)
        if (random(1) < 0.5)
          hijo.pesosOcultaSalida[j][k] = padreB.pesosOcultaSalida[j][k];

    // Cruzar sesgos de salida
    for (int k = 0; k < hijo.cantSalidas; k++)
      if (random(1) < 0.5)
        hijo.sesgosSalida[k] = padreB.sesgosSalida[k];

    return hijo;
  }

  // ──────────────────────────────────────────
  //  Mutación gaussiana
  //  Cada peso tiene tasaMutacion de probabilidad
  //  de recibir un desplazamiento gaussiano
  // ──────────────────────────────────────────
  void mutar(RedNeuronal red) {
    // Pesos entrada → oculta
    for (int i = 0; i < red.cantEntradas; i++)
      for (int j = 0; j < red.cantOcultas; j++)
        if (random(1) < tasaMutacion)
          red.pesosEntradaOculta[i][j] += red.randomGaussiano() * fuerzaMutacion;

    // Sesgos ocultos
    for (int j = 0; j < red.cantOcultas; j++)
      if (random(1) < tasaMutacion)
        red.sesgosOculta[j] += red.randomGaussiano() * fuerzaMutacion;

    // Pesos oculta → salida
    for (int j = 0; j < red.cantOcultas; j++)
      for (int k = 0; k < red.cantSalidas; k++)
        if (random(1) < tasaMutacion)
          red.pesosOcultaSalida[j][k] += red.randomGaussiano() * fuerzaMutacion;

    // Sesgos de salida
    for (int k = 0; k < red.cantSalidas; k++)
      if (random(1) < tasaMutacion)
        red.sesgosSalida[k] += red.randomGaussiano() * fuerzaMutacion;
  }

  // ──────────────────────────────────────────
  //  Ordenar índices por puntaje (mayor primero)
  //  Retorna array de índices ordenados
  // ──────────────────────────────────────────
  int[] ordenarPorPuntaje(float[] puntajes) {
    int n = puntajes.length;
    int[] indices = new int[n];
    for (int i = 0; i < n; i++) indices[i] = i;

    // Bubble sort (población pequeña, rendimiento suficiente)
    for (int i = 0; i < n - 1; i++) {
      for (int j = 0; j < n - i - 1; j++) {
        if (puntajes[indices[j]] < puntajes[indices[j + 1]]) {
          int tmp = indices[j];
          indices[j] = indices[j + 1];
          indices[j + 1] = tmp;
        }
      }
    }
    return indices;
  }

  // ──────────────────────────────────────────
  //  Ajuste dinámico de la fuerza de mutación
  //  Si no hay mejora entre generaciones,
  //  se incrementa para explorar más
  // ──────────────────────────────────────────
  void ajustarMutacion(float mejorPuntajeActual, float mejorPuntajeAnterior) {
    if (mejorPuntajeActual <= mejorPuntajeAnterior) {
      fuerzaMutacion = min(fuerzaMutacion * 1.1, 0.8);
    } else {
      fuerzaMutacion = max(fuerzaMutacion * 0.95, 0.05);
    }
  }
}
